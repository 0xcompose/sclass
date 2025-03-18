import { convertContractDefinitionToContract } from "./parse/convertContractDefinitionToContract.js"
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

	let preparedContracts: Contract[] = []

	for (const contract of filteredContracts) {
		// If contract is already prepared, skip
		// this case is relevant for multiple contracts referenced in inheritance
		if (preparedContracts.find((c) => c.className === contract.name))
			continue

		preparedContracts.push(convertContractDefinitionToContract(contract))
	}

	/* ======= PARSE INHERITANCE ======= */

	let relations: string[] = []
	for (const contract of filteredContracts) {
		for (const parent of contract.inheritsFrom) {
			const parentName = getDefinitionName(parent)

			if (!isInFilteredList(parent, filteredContracts)) continue

			const relationStr = `\t${parentName} <|-- ${contract.name}`

			if (relations.includes(relationStr)) continue

			relations.push(relationStr)
		}
	}

	// /* ======= DIAGRAM ======= */

	const diagram = getClassDiagramString(preparedContracts, relations)

	return diagram.trim()
}

function isInFilteredList(
	definition: Definition,
	filteredList: ParsedDefinition<any>[],
) {
	return filteredList.find((d) => d.definition.id === definition.id)
}
