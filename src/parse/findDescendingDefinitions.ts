import assert from "node:assert"
import {
	assertTerminalNode,
	TerminalKindExtensions,
	NonterminalKind,
} from "@nomicfoundation/slang/cst"
import { CompilationUnit } from "@nomicfoundation/slang/compilation"
import { Definition } from "@nomicfoundation/slang/bindings"
import { getDefinitionKind, getDefinitionCursor } from "../utils/definitions.js"

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

	return findDefinitionsOfKindInContract(unit, contractDefinition, [
		NonterminalKind.StateVariableDefinition,
	])
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

	return findDefinitionsOfKindInContract(
		unit,
		contractDefinition,
		expectedOutputDefinitionKinds,
	)
}

function findDefinitionsOfKindInContract(
	unit: CompilationUnit,
	contractDefinition: Definition,
	definitionKinds: NonterminalKind[],
): Definition[] {
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

		if (!definitionKinds.includes(kind)) continue

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
