import assert from "node:assert"
import {
	assertTerminalNode,
	TerminalKindExtensions,
	Cursor,
	NonterminalKind,
	Query,
} from "@nomicfoundation/slang/cst"
import { CompilationUnit } from "@nomicfoundation/slang/compilation"
import { Definition } from "@nomicfoundation/slang/bindings"
import { getDefinitionKind } from "../utils/getDefinitionKind.js"
import { getDefinitionCursor } from "../utils/getDefinitionCursor.js"

/**
 * Finds all Parameter definitions within a function definition
 */
export function findFunctionParameterDefinitions(
	unit: CompilationUnit,
	functionCursor: Cursor,
): Definition[] {
	assert(
		functionCursor.node.kind === NonterminalKind.FunctionDefinition,
		"Cursor must point to FunctionDefinition",
	)

	const definitions: Definition[] = []
	const childCursor = functionCursor.spawn()

	while (childCursor.goToNextTerminal()) {
		assertTerminalNode(childCursor.node)

		const isIdentifier = TerminalKindExtensions.isIdentifier(
			childCursor.node.kind,
		)

		if (!isIdentifier) continue

		const definition = unit.bindingGraph.definitionAt(childCursor)

		if (!definition) continue

		const kind = getDefinitionKind(definition)

		if (kind !== NonterminalKind.Parameter) continue

		definitions.push(definition)
	}

	return definitions
}

/**
 * @note Finds all state variable definitions within a contract/interface/library
 */
export function findStateVariableDefinitions(
	unit: CompilationUnit,
	contractDefinition: Definition,
): Definition[] {
	const definitionKind = getDefinitionKind(contractDefinition)

	assert(
		definitionKind === NonterminalKind.ContractDefinition,
		"Definition must be a Contract definition",
	)

	const definitions: Definition[] = []
	const childCursor = getDefinitionCursor(contractDefinition).spawn()

	while (childCursor.goToNextTerminal()) {
		assertTerminalNode(childCursor.node)

		const isIdentifier = TerminalKindExtensions.isIdentifier(
			childCursor.node.kind,
		)

		if (!isIdentifier) continue

		const definition = unit.bindingGraph.definitionAt(childCursor)

		if (!definition) continue

		const kind = getDefinitionKind(definition)

		if (kind !== NonterminalKind.StateVariableDefinition) continue

		definitions.push(definition)
	}

	return definitions
}

/**
 * Finds all function definitions within a contract/interface/library
 */
export function findFunctionDefinitions(
	unit: CompilationUnit,
	contractDefinition: Definition,
): Definition[] {
	const definitionKind = getDefinitionKind(contractDefinition)

	const expectedInputDefinitionKinds = [
		NonterminalKind.ContractDefinition,
		NonterminalKind.InterfaceDefinition,
		NonterminalKind.LibraryDefinition,
	]

	const expectedOutputDefinitionKinds = [
		NonterminalKind.FunctionDefinition,
		NonterminalKind.ReceiveFunctionDefinition,
		NonterminalKind.FallbackFunctionDefinition,
	]

	assert(
		expectedInputDefinitionKinds.includes(definitionKind),
		"Definition must be a Contract/Interface/Library definition",
	)

	const definitions: Definition[] = []
	const childCursor = getDefinitionCursor(contractDefinition).spawn()

	while (childCursor.goToNextTerminal()) {
		assertTerminalNode(childCursor.node)

		const isIdentifier = TerminalKindExtensions.isIdentifier(
			childCursor.node.kind,
		)

		if (!isIdentifier) continue

		const definition = unit.bindingGraph.definitionAt(childCursor)

		if (!definition) continue

		const kind = getDefinitionKind(definition)

		if (!expectedOutputDefinitionKinds.includes(kind)) continue

		definitions.push(definition)
	}

	return definitions
}

export function findInheritanceIdentifiers(
	unit: CompilationUnit,
	contractDefinition: Definition,
): Definition[] {
	const childCursor = getDefinitionCursor(contractDefinition).spawn()
	const inheritanceDefinitions: Definition[] = []

	console.log(
		"Finding inheritance identifiers for",
		childCursor.node.unparse(),
	)

	while (childCursor.goToNextTerminal()) {
		assertTerminalNode(childCursor.node)

		const isIdentifier = TerminalKindExtensions.isIdentifier(
			childCursor.node.kind,
		)

		if (!isIdentifier) continue

		const reference = unit.bindingGraph.referenceAt(childCursor)

		if (!reference) continue

		assert(
			reference.definitions().length === 1,
			"Expected 1 definition for a reference",
		)

		const definition = reference.definitions()[0]

		if (!definition) continue

		inheritanceDefinitions.push(definition)
	}

	return inheritanceDefinitions
}
