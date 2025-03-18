import {
	Contract,
	Field,
	Visibility,
	Method,
	Mapping,
	StateMutability,
} from "../mermaid/contract.js"
import { shouldFilterMethod } from "../utils/filter.js"
import {
	ArrayTypeName,
	FunctionAttribute,
	FunctionDefinition,
	IdentifierPath,
	MappingType,
	ModifierInvocation,
	OverrideSpecifier,
	StateVariableAttribute,
	StateVariableDefinition,
	TypeName,
} from "@nomicfoundation/slang/ast"
import { getDefinitionName, getDefinitionNode } from "../utils/definitions.js"
import {
	NonterminalKind,
	TerminalKind,
	TerminalNode,
} from "@nomicfoundation/slang/cst"
import { UserDefinedTypeName } from "@solidity-parser/parser/dist/src/ast-types.js"
import { Definition } from "@nomicfoundation/slang/bindings"
import {
	findStateVariableDefinitions,
	findFunctionDefinitions,
	findInheritanceIdentifiers,
} from "./findDescendingDefinitions.js"
import { CompilationUnit } from "@nomicfoundation/slang/compilation"

export function convertContractDefinitionToContract(
	unit: CompilationUnit,
	contractDefinition: Definition,
): Contract {
	const name = getDefinitionName(contractDefinition)

	const contract = new Contract(name)

	/* ====== Variables ====== */

	const variables = findStateVariableDefinitions(unit, contractDefinition)

	for (const variable of variables) {
		// Special process for mapping

		const node = getDefinitionNode(variable)
		const astVariable = new StateVariableDefinition(node)

		const variableTypeKind = astVariable.typeName.variant.cst.kind

		if (variableTypeKind === NonterminalKind.MappingType) {
			const mapping = parseMapping(astVariable)
			contract.addMapping(mapping)
			continue
		}

		contract.addField(parseVariable(astVariable))
	}

	/* ====== Functions ====== */

	const functions = findFunctionDefinitions(unit, contractDefinition)

	for (const func of functions) {
		const method = parseFunction(func)

		if (shouldFilterMethod(method)) continue

		contract.addMethod(method)
	}

	/* ====== Inheritance ====== */

	const inheritsFrom = findInheritanceIdentifiers(unit, contractDefinition)

	contract.addInheritance(inheritsFrom)

	return contract
}

export function convertInterfaceDefinitionToInterface(
	unit: CompilationUnit,
	interfaceDefinition: Definition,
): Contract {
	const name = getDefinitionName(interfaceDefinition)

	const contract = new Contract(name)

	/* ====== Functions ====== */

	const functions = findFunctionDefinitions(unit, interfaceDefinition)

	for (const func of functions) {
		const method = parseFunction(func)

		if (shouldFilterMethod(method)) continue

		contract.addMethod(method)
	}

	/* ====== Inheritance ====== */

	const inheritsFrom = findInheritanceIdentifiers(unit, interfaceDefinition)

	contract.addInheritance(inheritsFrom)

	return contract
}

export function convertLibraryDefinitionToLibrary(
	unit: CompilationUnit,
	libraryDefinition: Definition,
): Contract {
	const name = getDefinitionName(libraryDefinition)

	const contract = new Contract(name)

	/* ====== Functions ====== */

	const functions = findFunctionDefinitions(unit, libraryDefinition)

	for (const func of functions) {
		const method = parseFunction(func)

		if (shouldFilterMethod(method)) continue

		contract.addMethod(method)
	}

	return contract
}

function parseMapping(variable: StateVariableDefinition): Mapping {
	const mapping = new MappingType(
		variable.typeName.variant.cst.asNonterminalNode(),
	)

	const key = mapping.keyType.cst.unparse().trim()

	return {
		name: variable.name.unparse(),
		key,
		value: mapping.valueType.cst.unparse().trim(),
		visibility: parseVariableVisibility(variable),
	}
}

// Returns name of type, prefers user defined names instead of elementary ones
export function parseTypeName(typeName: TypeName | null): string {
	if (!typeName) return "empty"

	const variant = typeName.variant

	switch (variant.cst.kind) {
		case NonterminalKind.ElementaryType:
			return variant.cst.unparse()

		case NonterminalKind.MappingType:
			// Handle mapping with named parameters
			const mapping = new MappingType(variant.cst.asNonterminalNode())
			const keyVariant = mapping.keyType.keyType.variant

			let key = "undefined"

			if (keyVariant.cst.kind === NonterminalKind.ElementaryType) {
				key = keyVariant.cst.unparse()
			} else {
				key = (keyVariant as unknown as IdentifierPath).items
					.map((item) => item.unparse())
					.join(".")
			}

			const value = parseTypeName(mapping.valueType.typeName)
			return `mapping(${key} => ${value})`

		case NonterminalKind.UserDefinedValueTypeDefinition:
			return (typeName as unknown as UserDefinedTypeName).namePath

		case NonterminalKind.ArrayTypeName:
			const array = new ArrayTypeName(variant.cst.asNonterminalNode())
			return parseTypeName(array.operand) + "[]"

		default:
			throw new Error(`Unhandled typeName: ${variant.cst.kind}`)
	}
}

function parseVariable(variable: StateVariableDefinition): Field {
	const name = variable.name.unparse().trim()
	const type = parseTypeName(variable.typeName).trim()
	const visibility = parseVariableVisibility(variable)

	return { name, type, visibility }
}

function parseFunction(func: Definition): Method | null {
	/* ====== Name ====== */
	let name = getDefinitionName(func)

	// function name can be null - then it's constructor
	if (!name) return null

	/* ====== Visibility ====== */

	const node = getDefinitionNode(func)
	const astFunc = new FunctionDefinition(node)

	const params = astFunc.parameters.cst
		.unparse()
		.replace(/\n/g, "")
		.replace(/\t/g, "")
		.trim()

	/* ====== Visibility ====== */

	let visibility: Visibility = parseFunctionVisibility(func)

	/* ====== Mutability ====== */

	let stateMutability = parseFunctionStateMutability(func)

	/* ====== Return Type ====== */

	let returnType = parseFunctionReturnType(func)

	/* ====== Construction ====== */

	const method: Method = {
		name,
		returnType,
		visibility,
		params,
		stateMutability,
	}

	return method
}

function parseFunctionReturnType(func: Definition): string {
	const node = getDefinitionNode(func)
	const astFunc = new FunctionDefinition(node)

	// Remove all new lines/tabs and trim
	if (!astFunc.returns) return ""

	return astFunc.returns.cst
		.unparse()
		.replace(/\n/g, "")
		.replace(/\t/g, "")
		.trim()
}

function parseVariableVisibility(
	variable: StateVariableDefinition,
): Visibility {
	let visibility: string = "internal"

	for (const item of variable.attributes.items) {
		if (isVisibilityAttribute(item)) {
			visibility = (item.variant as TerminalNode).unparse()
		}
	}

	return parseVisibility(visibility)
}

function parseFunctionVisibility(func: Definition): Visibility {
	const node = getDefinitionNode(func)
	const astFunc = new FunctionDefinition(node)

	let visibility = "internal"

	for (const item of astFunc.attributes.items) {
		if (isVisibilityAttributeOfFunction(item)) {
			visibility = (item.variant as TerminalNode).unparse()
		}
	}

	return parseVisibility(visibility)
}

function parseVisibility(visibility: string | undefined): Visibility {
	switch (visibility) {
		case "external":
			return Visibility.external
		case "public":
			return Visibility.public
		case "internal":
			return Visibility.internal
		case "private":
			return Visibility.private
		default:
			return Visibility.internal
	}
}

function parseFunctionStateMutability(func: Definition): StateMutability {
	const node = getDefinitionNode(func)
	const astFunc = new FunctionDefinition(node)

	let stateMutability = StateMutability.mutative

	for (const item of astFunc.attributes.items) {
		if (!isStateMutabilityAttribute(item)) continue

		const terminalNode = item.variant as unknown as TerminalNode
		stateMutability =
			terminalNode.kind === TerminalKind.ViewKeyword
				? StateMutability.view
				: StateMutability.pure
	}

	return stateMutability
}

function isVisibilityAttribute(attribute: StateVariableAttribute): boolean {
	const kind = attribute.variant

	const visibilityTerminals = [
		TerminalKind.InternalKeyword,
		TerminalKind.PrivateKeyword,
		TerminalKind.PublicKeyword,
		TerminalKind.ExternalKeyword,
	]

	const overrideSpecifier = kind as unknown as OverrideSpecifier

	if (overrideSpecifier.cst?.kind === NonterminalKind.OverrideSpecifier)
		return false

	const terminalNode = kind as unknown as TerminalNode

	return visibilityTerminals.includes(terminalNode.kind)
}

function isVisibilityAttributeOfFunction(
	functionAttribute: FunctionAttribute,
): boolean {
	const kind = functionAttribute.variant

	const visibilityTerminals = [
		TerminalKind.InternalKeyword,
		TerminalKind.PrivateKeyword,
		TerminalKind.PublicKeyword,
		TerminalKind.ExternalKeyword,
	]

	const overrideSpecifier = kind as unknown as OverrideSpecifier

	if (overrideSpecifier.cst?.kind === NonterminalKind.OverrideSpecifier)
		return false

	const modifierInvocation = kind as unknown as ModifierInvocation

	if (modifierInvocation.cst?.kind === NonterminalKind.ModifierInvocation)
		return false

	const terminalNode = kind as unknown as TerminalNode

	return visibilityTerminals.includes(terminalNode.kind)
}

function isStateMutabilityAttribute(attribute: FunctionAttribute): boolean {
	const kind = attribute.variant

	const stateMutabilityTerminals = [
		TerminalKind.ViewKeyword,
		TerminalKind.PureKeyword,
	]

	const overrideSpecifier = kind as unknown as OverrideSpecifier

	if (overrideSpecifier.cst?.kind === NonterminalKind.OverrideSpecifier)
		return false

	const modifierInvocation = kind as unknown as ModifierInvocation

	if (modifierInvocation.cst?.kind === NonterminalKind.ModifierInvocation)
		return false

	const terminalNode = kind as unknown as TerminalNode

	return stateMutabilityTerminals.includes(terminalNode.kind)
}
