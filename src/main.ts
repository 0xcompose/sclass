import {
	convertContractDefinitionToContract,
	convertInterfaceDefinitionToInterface,
	convertLibraryDefinitionToLibrary,
} from "./parse/convertContractDefinitionToContract.js"
import { getClassDiagramString } from "./mermaid/diagram.js"
import { Contract } from "./mermaid/contract.js"
import {
	shouldIncludeContract,
	shouldIncludeInterface,
	shouldIncludeLibrary,
} from "./utils/filter.js"
import { parseFileForDefinitions } from "./parse/parseFileForDefinitions.js"
import { getDefinitionKind, getDefinitionName } from "./utils/definitions.js"
import { Definition } from "@nomicfoundation/slang/bindings"
import { Config } from "./config.js"
import { buildCompilationUnit } from "./parse/buildCompilationUnit.js"
import { CompilationUnit } from "@nomicfoundation/slang/compilation"
import { NonterminalKind } from "@nomicfoundation/slang/cst"

type Diagram = string

export async function parseContracts(): Promise<Diagram> {
	const filePath = Config.inputContractFilePath
	const unit = await buildCompilationUnit(filePath)

	if (!filePath) {
		throw new Error("Input file path is not set")
	}

	/* ======= READ INPUT FILE ======= */

	const { contracts, interfaces, libraries } = parseFileForDefinitions(
		unit,
		filePath,
	)

	/* ======= FILTER ======= */

	const filteredContracts = contracts.filter((contract) =>
		shouldIncludeContract(contract),
	)

	const filteredInterfaces = interfaces.filter((interfaceDef) =>
		shouldIncludeInterface(interfaceDef),
	)

	const filteredLibraries = libraries.filter((library) =>
		shouldIncludeLibrary(library),
	)

	/* ======= PARSE CONTRACTS ======= */

	const classDefinitions = [
		...filteredContracts,
		...filteredInterfaces,
		...filteredLibraries,
	]

	const preparedContracts = prepareContracts(unit, classDefinitions)

	/* ======= PARSE INHERITANCE ======= */

	// /* ======= DIAGRAM ======= */

	const diagram = getClassDiagramString(
		Array.from(preparedContracts.values()),
		constructMermaidRelations(preparedContracts),
	)

	return diagram.trim()
}

function prepareContracts(
	unit: CompilationUnit,
	filteredContracts: Definition[],
): Map<number, Contract> {
	const preparedContracts: Map<number, Contract> = new Map()

	for (const contract of filteredContracts) {
		if (preparedContracts.has(contract.id)) continue

		const convert = getConverter(contract)

		const convertedContract = convert(unit, contract)

		preparedContracts.set(contract.id, convertedContract)
	}

	return preparedContracts
}

function getConverter(definition: Definition) {
	switch (getDefinitionKind(definition)) {
		case NonterminalKind.ContractDefinition:
			return convertContractDefinitionToContract
		case NonterminalKind.InterfaceDefinition:
			return convertInterfaceDefinitionToInterface
		case NonterminalKind.LibraryDefinition:
			return convertLibraryDefinitionToLibrary
		default:
			throw new Error(
				`Incorrect definition kind passed: ${getDefinitionKind(
					definition,
				)}, expected contracts`,
			)
	}
}

function constructMermaidRelations(preparedContracts: Map<number, Contract>) {
	const relations: string[] = []

	for (const contract of preparedContracts.values()) {
		for (const parent of contract.inheritsFrom) {
			const parentName = getDefinitionName(parent)

			const relationStr = `\t${parentName} <|-- ${contract.className}`

			if (relations.includes(relationStr)) continue

			relations.push(relationStr)
		}
	}

	return relations
}
