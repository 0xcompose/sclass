import fs from "fs"
import { ozContracts } from "./collections/openzeppelin"
import {
    ASTNode,
    ContractDefinition,
} from "@solidity-parser/parser/dist/src/ast-types"
import { convertContractDefinitionToContract } from "./astContractDefinitionToContract"
import { parse } from "@solidity-parser/parser"
import { getClassDiagramString } from "./mermaid/diagram"
import { Contract } from "./mermaid/contract"
import { layerZeroContract } from "./collections/layerzero"
import { stargateContracts } from "./collections/stargate"

const filterInterfaces = true
const filterLibraries = true
const filterOz = true
const filterStargate = true
const filterLayerZero = true

export const disableFunctionParamType = false

const excludeContracts = ["ERC165Registry"]

// Flatten Solidity files
const files = [
    "./contracts/AddressProvider.flatten.sol",
    "./contracts/TokenVault.flatten.sol",
    "./contracts/StargateAdapter.flatten.sol",
    "./contracts/OracleGlobalPPS.flatten.sol",
]

function main() {
    let contracts: ContractDefinition[] = []

    /* ======= READ FILES ======= */

    for (const file of files) {
        const buffer = fs.readFileSync(file)
        const solidityCode = buffer.toString()

        let ast = parse(solidityCode)
        contracts.push(...(ast.children as ContractDefinition[]))
    }

    /* ======= FILTER ======= */

    const filteredContracts = filterNodes(contracts as ContractDefinition[])

    /* ======= PARSE ======= */

    let parsedContracts: Contract[] = []

    for (const contract of filteredContracts) {
        parsedContracts.push(convertContractDefinitionToContract(contract))
    }

    /* ======= DIAGRAM ======= */

    const diagram = getClassDiagramString(
        parsedContracts,
        disableFunctionParamType
    )

    console.log(diagram)

    fs.writeFileSync("./diagram.mmd", diagram)
}

function parseContract(node: ASTNode) {
    return node as ContractDefinition
}

// function isContract(node: ASTNode) {
// 	return node.type === "ContractDefinition";
// }

function filterNodes(nodes: ASTNode[]): ContractDefinition[] {
    let contractNodes = nodes.filter(
        (node) => node.type === "ContractDefinition"
    ) as ContractDefinition[]

    if (filterInterfaces) {
        contractNodes = contractNodes.filter((node) => !isInterface(node))
    }

    if (filterOz) {
        contractNodes = contractNodes.filter(
            (node) => !ozContracts.includes(node.name)
        )
    }

    if (filterLayerZero) {
        contractNodes = contractNodes.filter(
            (node) => !layerZeroContract.includes(node.name)
        )
    }

    if (filterStargate) {
        contractNodes = contractNodes.filter(
            (node) => !stargateContracts.includes(node.name)
        )
    }

    if (filterLibraries) {
        contractNodes = contractNodes.filter((node) => !isLibrary(node))
    }

    if (excludeContracts.length > 0) {
        contractNodes = contractNodes.filter(
            (node) => !excludeContracts.includes(node.name)
        )
    }

    return contractNodes
}

function isInterface(node: ContractDefinition) {
    return node.kind === "interface"
}

function isContract(node: ContractDefinition) {
    return node.kind === "contract"
}

function isAbstract(node: ContractDefinition) {
    return node.kind === "abstract"
}

function isLibrary(node: ContractDefinition) {
    return node.kind === "library"
}

main()
// .then(() => process.exit(0))
// .catch((error) => {
//     console.error(error)
//     process.exit(1)
// })
