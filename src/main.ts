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
import { getDefinitionName } from "./utils/definitions.js"
import { Definition } from "@nomicfoundation/slang/bindings"
import { Config } from "./config.js"
import { buildCompilationUnit } from "./parse/buildCompilationUnit.js"

type Diagram = string

export async function parseContracts(): Promise<Diagram> {
	const filePath = Config.inputContractFilePath
	const unit = await buildCompilationUnit(filePath)

	if (!filePath) {
		throw new Error("Input file path is not set")
	}

	/* ======= READ INPUT FILE ======= */

	const { contracts, interfaces, libraries } = await parseFileForDefinitions(
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

	let preparedContracts: Map<number, Contract> = new Map()

	for (const contract of filteredContracts) {
		// If contract is already prepared, skip
		// this case is relevant for multiple contracts referenced in inheritance
		if (preparedContracts.has(contract.id)) continue

		preparedContracts.set(
			contract.id,
			convertContractDefinitionToContract(unit, contract),
		)
	}

	for (const interfaceDef of filteredInterfaces) {
		if (preparedContracts.has(interfaceDef.id)) continue

		preparedContracts.set(
			interfaceDef.id,
			convertInterfaceDefinitionToInterface(unit, interfaceDef),
		)
	}

	for (const library of filteredLibraries) {
		if (preparedContracts.has(library.id)) continue

		preparedContracts.set(
			library.id,
			convertLibraryDefinitionToLibrary(unit, library),
		)
	}

	/* ======= PARSE INHERITANCE ======= */

	let relations: string[] = []

	for (const contract of preparedContracts.values()) {
		for (const parent of contract.inheritsFrom) {
			const parentName = getDefinitionName(parent)

			if (!isInFilteredList(parent, filteredContracts)) continue

			const relationStr = `\t${parentName} <|-- ${contract.className}`

			if (relations.includes(relationStr)) continue

			relations.push(relationStr)
		}
	}

	// /* ======= DIAGRAM ======= */

	const diagram = getClassDiagramString(
		Array.from(preparedContracts.values()),
		relations,
	)

	return diagram.trim()
}

function isInFilteredList(definition: Definition, filteredList: Definition[]) {
	return filteredList.find((d) => d.id === definition.id)
}
