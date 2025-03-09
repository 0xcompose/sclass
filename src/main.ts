import { ContractDefinition } from "@solidity-parser/parser/dist/src/ast-types"
import { convertContractDefinitionToContract } from "./ast/astContractDefinitionToContract"
import { parse } from "@solidity-parser/parser"
import { getClassDiagramString } from "./mermaid/diagram"
import { Contract } from "./mermaid/contract"
import { shouldFilterContract } from "./utils/filter"
import { exec } from "child_process"
import { promisify } from "util"
import { Config } from "./config"

export async function parseContracts(): Promise<Diagram> {
	/* ======= READ FILES ======= */

	const contracts = await readInputFileAndParse()

	/* ======= FILTER ======= */

	const filteredContracts: ContractDefinition[] = []
	const excludedContractNames: Map<string, boolean> = new Map()

	for (const contract of contracts) {
		const shouldFilter = shouldFilterContract(contract)

		if (!shouldFilter) filteredContracts.push(contract)
		else excludedContractNames.set(contract.name, true)
	}

	/* ======= PARSE CONTRACTS ======= */

	let parsedContracts: Contract[] = []

	for (const contract of filteredContracts) {
		if (parsedContracts.find((c) => c.className === contract.name)) continue

		parsedContracts.push(convertContractDefinitionToContract(contract))
	}

	/* ======= PARSE INHERITANCE ======= */

	let relations: string[] = []
	for (const contract of filteredContracts) {
		for (const base of contract.baseContracts) {
			if (excludedContractNames.get(base.baseName.namePath)) continue

			const relationStr = `\t${base.baseName.namePath} <|-- ${contract.name}`

			if (relations.includes(relationStr)) continue

			relations.push(relationStr)
		}
	}

	// /* ======= DIAGRAM ======= */

	const diagram = getClassDiagramString(parsedContracts, relations)

	return diagram.trim()
}

export async function readInputFileAndParse() {
	const filePath = Config.inputContractFilePath

	if (!filePath) {
		throw new Error("Input file path is not set")
	}

	const contracts: ContractDefinition[] = []

	// const path = filePath
	const execAsync = promisify(exec)
	const { stdout, stderr } = await execAsync(`forge flatten ${filePath}`)
	// const buffer = fs.readFileSync(path)
	const solidityCode = stdout

	let ast = parse(solidityCode)

	// console.log(`Parsed ${file}`)
	// console.log(inspect(ast, { depth: 10 }))
	contracts.push(...(ast.children as ContractDefinition[]))

	return contracts
}
