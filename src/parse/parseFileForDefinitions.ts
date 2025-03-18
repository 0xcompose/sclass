import { Cursor, NonterminalKind } from "@nomicfoundation/slang/cst"
import { Config } from "../config.js"
import { buildCompilationUnit } from "./buildCompilationUnit.js"
import { findDefinitionsOfKindsInFile } from "./findDefinitions.js"
import { BindingGraph, Definition } from "@nomicfoundation/slang/bindings"
import {
	ParsedContractDefinition,
	ParsedFunctionDefinition,
	ParsedInterfaceDefinition,
	ParsedLibraryDefinition,
	ParsedParameterDefinition,
	ParsedStateVariableDefinition,
} from "./types.js"
import { getDefinitionName } from "../utils/getDefinitionName.js"
import { getDefinitionKind } from "../utils/getDefinitionKind.js"
import assert from "node:assert"
import { CompilationUnit } from "@nomicfoundation/slang/compilation"
import {
	findFunctionDefinitions,
	findFunctionParameterDefinitions,
	findInheritanceIdentifiers,
	findStateVariableDefinitions,
} from "./findDescendantDefinitions.js"
import { getDefinitionNode } from "../utils/getDefinitionNode.js"
import { FunctionDefinition } from "@nomicfoundation/slang/ast"
import { parseTypeName } from "./convertContractDefinitionToContract.js"
import { getDefinitionCursor } from "../utils/getDefinitionCursor.js"

export async function parseFileForDefinitions(): Promise<{
	contracts: ParsedContractDefinition[]
	interfaces: ParsedInterfaceDefinition[]
	libraries: ParsedLibraryDefinition[]
}> {
	const filePath = Config.inputContractFilePath

	if (!filePath) {
		throw new Error("Input file path is not set")
	}

	const unit = await buildCompilationUnit(filePath)

	// Find and Parse ContractDefinitions

	const contracts = findDefinitionsOfKindsInFile(unit, filePath, [
		NonterminalKind.ContractDefinition,
	]).map((contract) => parseContractDefinition(unit, contract))

	// Find and Parse LibraryDefinitions

	const libraries = findDefinitionsOfKindsInFile(unit, filePath, [
		NonterminalKind.LibraryDefinition,
	]).map((lib) => parseLibraryDefinition(unit, lib))

	// Find and Parse InterfaceDefinitions

	const interfaces = findDefinitionsOfKindsInFile(unit, filePath, [
		NonterminalKind.InterfaceDefinition,
	]).map((interfaceDef) => parseInterfaceDefinition(unit, interfaceDef))

	return { contracts, interfaces, libraries }
}

export function parseContractDefinition(
	unit: CompilationUnit,
	contractDefinition: Definition,
): ParsedContractDefinition {
	const name = getDefinitionName(contractDefinition)
	const kind = getDefinitionKind(contractDefinition)

	assert(
		kind === NonterminalKind.ContractDefinition,
		"ContractDefinition expected",
	)

	const stateVariableDefinitions = findStateVariableDefinitions(
		unit,
		contractDefinition,
	)

	const parsedStateVariables = parseStateVariableDefinitions(
		stateVariableDefinitions,
	)

	const functionDefinitions = findFunctionDefinitions(
		unit,
		contractDefinition,
	)

	const parsedFunctions = parseFunctionDefinitions(functionDefinitions)

	// Query all the inheritance identifiers
	const inheritsFrom = findInheritanceIdentifiers(unit, contractDefinition)

	const contract: ParsedContractDefinition = {
		name,
		kind: NonterminalKind.ContractDefinition,
		definition: contractDefinition,
		variables: parsedStateVariables,
		functions: parsedFunctions,
		inheritsFrom,
	}

	return contract
}

export function parseLibraryDefinition(
	unit: CompilationUnit,
	libraryDefinition: Definition,
): ParsedLibraryDefinition {
	const name = getDefinitionName(libraryDefinition)
	const kind = getDefinitionKind(libraryDefinition)

	assert(
		kind === NonterminalKind.LibraryDefinition,
		"LibraryDefinition expected",
	)

	const functionDefinitions = findFunctionDefinitions(unit, libraryDefinition)

	const parsedFunctions = parseFunctionDefinitions(functionDefinitions)

	const library: ParsedLibraryDefinition = {
		name,
		kind: NonterminalKind.LibraryDefinition,
		definition: libraryDefinition,
		functions: parsedFunctions,
	}

	return library
}

export function parseInterfaceDefinition(
	unit: CompilationUnit,
	interfaceDefinition: Definition,
): ParsedInterfaceDefinition {
	const name = getDefinitionName(interfaceDefinition)
	const kind = getDefinitionKind(interfaceDefinition)

	assert(
		kind === NonterminalKind.InterfaceDefinition,
		"InterfaceDefinition expected",
	)

	const functionDefinitions = findFunctionDefinitions(
		unit,
		interfaceDefinition,
	)

	const parsedFunctions = parseFunctionDefinitions(functionDefinitions)

	const inheritsFrom = findInheritanceIdentifiers(unit, interfaceDefinition)

	const parsedInterface: ParsedInterfaceDefinition = {
		name,
		kind: NonterminalKind.InterfaceDefinition,
		definition: interfaceDefinition,
		functions: parsedFunctions,
		inheritsFrom,
	}

	return parsedInterface
}

function parseStateVariableDefinitions(
	stateVariableDefinitions: Definition[],
): ParsedStateVariableDefinition[] {
	const parsedStateVariables: ParsedStateVariableDefinition[] = []

	for (const stateVariableDefinition of stateVariableDefinitions) {
		assert(
			getDefinitionKind(stateVariableDefinition) ===
				NonterminalKind.StateVariableDefinition,
			"StateVariableDefinition expected",
		)

		parsedStateVariables.push({
			name: getDefinitionName(stateVariableDefinition),
			kind: NonterminalKind.StateVariableDefinition,
			definition: stateVariableDefinition,
		})
	}

	return parsedStateVariables
}

function parseFunctionDefinitions(
	functionDefinitions: Definition[],
): ParsedFunctionDefinition[] {
	const parsedFunctions: ParsedFunctionDefinition[] = []

	for (const functionDefinition of functionDefinitions) {
		assert(
			getDefinitionKind(functionDefinition) ===
				NonterminalKind.FunctionDefinition,
			"FunctionDefinition expected",
		)

		parsedFunctions.push({
			name: getDefinitionName(functionDefinition),
			kind: NonterminalKind.FunctionDefinition,
			definition: functionDefinition,
		})
	}

	return parsedFunctions
}
