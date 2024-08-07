import fs from "fs"
import { ozContracts } from "./collections/openzeppelin"
import {
    ASTNode,
    ContractDefinition,
} from "@solidity-parser/parser/dist/src/ast-types"
import { convertContractDefinitionToContract } from "./ast/astContractDefinitionToContract"
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

const excludeContracts = [
    "ERC165Registry",
    "ERC20",
    "ReentrancyGuard",
    "Context",
]
const includeContracts = ["Ownable"]

// Flatten Solidity files
const files = [
    // "./contracts/AddressProvider.flatten.sol",
    "./contracts/TokenVault.flatten.sol",
    // "./contracts/StargateAdapter.flatten.sol",
    // "./contracts/OracleGlobalPPS.flatten.sol",
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

    const filteredContracts: ContractDefinition[] = []

    for (const contract of contracts) {
        const shouldFilter = shouldFilterContract(contract)

        if (!shouldFilter) filteredContracts.push(contract)
    }

    /* ======= PARSE CONTRACTS ======= */

    let parsedContracts: Contract[] = []

    for (const contract of filteredContracts) {
        parsedContracts.push(convertContractDefinitionToContract(contract))
    }

    /* ======= PARSE INHERITANCE ======= */

    let relations: string[] = []

    for (const contract of filteredContracts) {
        for (const base of contract.baseContracts) {
            const parentName = base.baseName.namePath
            if (parentName[0] == "I") continue
            if (excludeContracts.includes(parentName)) continue

            relations.push(`\t${base.baseName.namePath} <|-- ${contract.name}`)
        }
    }

    /* ======= DIAGRAM ======= */

    const diagram = getClassDiagramString(
        parsedContracts,
        relations,
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

function isContractFromCollection(
    contract: ContractDefinition,
    collection: string[]
) {
    return collection.includes(contract.name)
}

function shouldFilterContract(node: ASTNode): boolean {
    let contract: ContractDefinition | null = null

    if (node.type !== "ContractDefinition") return true

    contract = node

    /* ====== INCLUDE ====== */

    if (includeContracts.includes(contract.name)) return false

    /* ====== LIBRARY ====== */

    if (filterLibraries && isLibrary(contract)) return true

    /* ====== INTERFACE ====== */

    if (filterInterfaces && isInterface(node)) return true

    /* ====== COLLECTIONS ====== */

    if (filterOz && isContractFromCollection(contract, ozContracts)) return true
    if (
        filterLayerZero &&
        isContractFromCollection(contract, layerZeroContract)
    )
        return true
    if (filterStargate && isContractFromCollection(contract, stargateContracts))
        return true

    /* ====== EXCLUDE ====== */

    if (isContractFromCollection(contract, excludeContracts)) return true

    return false
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
