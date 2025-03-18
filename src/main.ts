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
import { ParsedDefinition } from "./parse/types.js"
import { getDefinitionName } from "./utils/getDefinitionName.js"
import { Definition } from "@nomicfoundation/slang/bindings"

export async function parseContracts(): Promise<Diagram> {
	/* ======= READ INPUT FILE ======= */

	const { contracts, interfaces, libraries } = await parseFileForDefinitions()

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
		if (preparedContracts.has(contract.definition.id)) continue

		preparedContracts.set(
			contract.definition.id,
			convertContractDefinitionToContract(contract),
		)
	}

	for (const interfaceDef of filteredInterfaces) {
		if (preparedContracts.has(interfaceDef.definition.id)) continue

		preparedContracts.set(
			interfaceDef.definition.id,
			convertInterfaceDefinitionToInterface(interfaceDef),
		)
	}

	for (const library of filteredLibraries) {
		if (preparedContracts.has(library.definition.id)) continue

		preparedContracts.set(
			library.definition.id,
			convertLibraryDefinitionToLibrary(library),
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

function isInFilteredList(
	definition: Definition,
	filteredList: ParsedDefinition<any>[],
) {
	return filteredList.find((d) => d.definition.id === definition.id)
}
