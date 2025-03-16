import { convertContractDefinitionToContract } from "./parse/convertContractDefinitionToContract.js"
import { getClassDiagramString } from "./mermaid/diagram.js"
import { Contract } from "./mermaid/contract.js"
import { shouldFilterContract } from "./utils/filter.js"
import { Config } from "./config.js"
import { buildCompilationUnit } from "./parse/buildCompilationUnit.js"
import assert from "assert"
import { findDefinitionsInFile } from "./parse/find-definitions.js"
import { ContractDefinition } from "@solidity-parser/parser/dist/src/ast-types.js"
import { parseDefinitions } from "./parse/parse-definitions.js"
import { filterDefinitions } from "./parse/filter-definitions.js"

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

	const unit = await buildCompilationUnit(filePath)

	const contracts: ContractDefinition[] = []

	const definitions = findDefinitionsInFile(unit, filePath)

	const found = parseDefinitions(definitions)

	for (const definition of found) {
		console.log(definition.name, definition.kind)
	}

	console.log("\n====== FILTERED DEFINITIONS ======\n")

	const filtered = filterDefinitions(found)

	for (const definition of filtered) {
		console.log(definition.name, definition.kind)
	}

	const path = filePath
	// const execAsync = promisify(exec)
	// const { stdout, stderr } = await execAsync(`forge flatten ${filePath}`)
	// const buffer = fs.readFileSync(path)
	// const solidityCode = stdout

	// let ast = parse(solidityCode)

	// console.log(`Parsed ${file}`)
	// console.log(inspect(ast, { depth: 10 }))
	// contracts.push(...(ast.children as ContractDefinition[]))

	return contracts
}
