import { convertContractDefinitionToContract } from "./parse/convertContractDefinitionToContract.js"
import { getClassDiagramString } from "./mermaid/diagram.js"
import { Contract } from "./mermaid/contract.js"
import { shouldFilterContract } from "./utils/filter.js"
import { ContractDefinition } from "@solidity-parser/parser/dist/src/ast-types.js"
import { readInputFileAndParse } from "./parse/readInputFileAndParse.js"
import { ParsedContractDefinition } from "./parse/types.js"
import { getDefinitionName } from "./utils/getDefinitionName.js"

export async function parseContracts(): Promise<Diagram> {
	/* ======= READ INPUT FILE ======= */

	const { contracts, interfaces, libraries } = await readInputFileAndParse()

	/* ======= FILTER ======= */

	const filteredContracts: ParsedContractDefinition[] = []
	const excludedContractNames: Map<string, boolean> = new Map()

	for (const contract of contracts) {
		const shouldFilter = shouldFilterContract(contract)

		if (!shouldFilter) filteredContracts.push(contract)
		else excludedContractNames.set(contract.name, true)
	}

	/* ======= PARSE CONTRACTS ======= */

	let parsedContracts: Contract[] = []

	return ""

	for (const contract of filteredContracts) {
		if (parsedContracts.find((c) => c.className === contract.name)) continue

		parsedContracts.push(convertContractDefinitionToContract(contract))
	}

	/* ======= PARSE INHERITANCE ======= */

	let relations: string[] = []
	for (const contract of filteredContracts) {
		for (const parent of contract.inheritsFrom) {
			const parentName = getDefinitionName(parent)
			if (excludedContractNames.get(parentName)) continue

			const relationStr = `\t${parentName} <|-- ${contract.name}`

			if (relations.includes(relationStr)) continue

			relations.push(relationStr)
		}
	}

	// /* ======= DIAGRAM ======= */

	const diagram = getClassDiagramString(parsedContracts, relations)

	return diagram.trim()
}
