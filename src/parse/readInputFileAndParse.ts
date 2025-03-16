import { NonterminalKind } from "@nomicfoundation/slang/cst"
import { Config } from "../config.js"
import { buildCompilationUnit } from "./buildCompilationUnit.js"
import { findDefinitionsOfKindsInFile } from "./findDefinitions.js"
import { Definition } from "@nomicfoundation/slang/bindings"
import {
	ParsedContractDefinition,
	ParsedFunctionDefinition,
	ParsedInterfaceDefinition,
	ParsedLibraryDefinition,
	ParsedStateVariableDefinition,
} from "./types.js"
import { getDefinitionName } from "../utils/getDefinitionName.js"
import { getDefinitionKind } from "../utils/getDefinitionKind.js"
import assert from "node:assert"
import { CompilationUnit } from "@nomicfoundation/slang/compilation"
import { findInheritanceIdentifiers } from "./findDescendantDefinitions.js"

export async function readInputFileAndParse(): Promise<{
	contracts: ParsedContractDefinition[]
	interfaces: ParsedInterfaceDefinition[]
	libraries: ParsedLibraryDefinition[]
}> {
	const filePath = Config.inputContractFilePath

	if (!filePath) {
		throw new Error("Input file path is not set")
	}

	const unit = await buildCompilationUnit(filePath)

	const contractDefinitions = findDefinitionsOfKindsInFile(unit, filePath, [
		NonterminalKind.ContractDefinition,
	])

	const libraryDefinitions = findDefinitionsOfKindsInFile(unit, filePath, [
		NonterminalKind.LibraryDefinition,
	])

	const interfaceDefinitions = findDefinitionsOfKindsInFile(unit, filePath, [
		NonterminalKind.InterfaceDefinition,
	])

	const contracts: ParsedContractDefinition[] = []

	for (const contractDefinition of contractDefinitions) {
		const contract = parseContractDefinition(
			unit,
			filePath,
			contractDefinition,
		)

		contracts.push(contract)
	}

	const libraries: ParsedLibraryDefinition[] = []

	for (const libraryDefinition of libraryDefinitions) {
		const library = parseLibraryDefinition(
			unit,
			filePath,
			libraryDefinition,
		)

		libraries.push(library)
	}

	const interfaces: ParsedInterfaceDefinition[] = []

	for (const interfaceDefinition of interfaceDefinitions) {
		const parsedInterface = parseInterfaceDefinition(
			unit,
			filePath,
			interfaceDefinition,
		)

		interfaces.push(parsedInterface)
	}

	return { contracts, interfaces, libraries }
}

function parseContractDefinition(
	unit: CompilationUnit,
	filePath: string,
	contractDefinition: Definition,
): ParsedContractDefinition {
	const name = getDefinitionName(contractDefinition)
	const kind = getDefinitionKind(contractDefinition)

	assert(
		kind === NonterminalKind.ContractDefinition,
		"ContractDefinition expected",
	)

	const stateVariableDefinitions = findDefinitionsOfKindsInFile(
		unit,
		filePath,
		[NonterminalKind.StateVariableDefinition],
	)

	const parsedStateVariables = parseStateVariableDefinitions(
		stateVariableDefinitions,
	)

	const functionDefinitions = findDefinitionsOfKindsInFile(unit, filePath, [
		NonterminalKind.FunctionDefinition,
	])

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

function parseLibraryDefinition(
	unit: CompilationUnit,
	filePath: string,
	libraryDefinition: Definition,
): ParsedLibraryDefinition {
	const name = getDefinitionName(libraryDefinition)
	const kind = getDefinitionKind(libraryDefinition)

	assert(
		kind === NonterminalKind.LibraryDefinition,
		"LibraryDefinition expected",
	)

	const functionDefinitions = findDefinitionsOfKindsInFile(unit, filePath, [
		NonterminalKind.FunctionDefinition,
	])

	const parsedFunctions = parseFunctionDefinitions(functionDefinitions)

	const library: ParsedLibraryDefinition = {
		name,
		kind: NonterminalKind.LibraryDefinition,
		definition: libraryDefinition,
		functions: parsedFunctions,
	}

	return library
}

function parseInterfaceDefinition(
	unit: CompilationUnit,
	filePath: string,
	interfaceDefinition: Definition,
): ParsedInterfaceDefinition {
	const name = getDefinitionName(interfaceDefinition)
	const kind = getDefinitionKind(interfaceDefinition)

	assert(
		kind === NonterminalKind.InterfaceDefinition,
		"InterfaceDefinition expected",
	)

	const functionDefinitions = findDefinitionsOfKindsInFile(unit, filePath, [
		NonterminalKind.FunctionDefinition,
	])

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
			parameters: [],
			returnParameters: [],
		})
	}

	return parsedFunctions
}
