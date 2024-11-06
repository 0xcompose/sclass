import fs from "fs"
import {
    ASTNode,
    ContractDefinition,
} from "@solidity-parser/parser/dist/src/ast-types"
import { convertContractDefinitionToContract } from "./ast/astContractDefinitionToContract"
import { parse } from "@solidity-parser/parser"
import { getClassDiagramString } from "./mermaid/diagram"
import { Contract } from "./mermaid/contract"
import { inspect } from "util"
import { CONTRACTS_DIR, OUTPUT_DIAGRAM_FILE } from "./misc/constants"
import { shouldFilterContract } from "./utils/filter"
import { config } from "../config"

function main() {
    /* ======= READ FILES ======= */

    const contracts = readFileAndParse(config)

    /* ======= FILTER ======= */

    const filteredContracts: ContractDefinition[] = []
    const excludedContractNames: Map<string, boolean> = new Map()

    for (const contract of contracts) {
        const shouldFilter = shouldFilterContract(contract, config)

        if (!shouldFilter) filteredContracts.push(contract)
        else excludedContractNames.set(contract.name, true)
    }

    /* ======= PARSE CONTRACTS ======= */

    let parsedContracts: Contract[] = []

    for (const contract of filteredContracts) {
        if (parsedContracts.find((c) => c.className === contract.name)) continue

        parsedContracts.push(
            convertContractDefinitionToContract(contract, config),
        )
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

    const diagram = getClassDiagramString(
        parsedContracts,
        relations,
        config.disableFunctionParamType,
    )

    console.log(diagram)
    fs.writeFileSync(OUTPUT_DIAGRAM_FILE, diagram)
}

export function readFileAndParse(config: Config) {
    const contracts: ContractDefinition[] = []

    for (const file of config.inputContracts) {
        const path = `${CONTRACTS_DIR}/${file}.sol`

        const buffer = fs.readFileSync(path)
        const solidityCode = buffer.toString()

        let ast = parse(solidityCode)

        // console.log(`Parsed ${file}`)
        // console.log(inspect(ast, { depth: 10 }))
        contracts.push(...(ast.children as ContractDefinition[]))
    }

    return contracts
}

main()
