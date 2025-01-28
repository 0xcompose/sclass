import {
	ASTNode,
	ContractDefinition,
} from "@solidity-parser/parser/dist/src/ast-types"
import { COLLECTIONS_DIR } from "../misc/constants"
import fs from "fs"
import { Method } from "../mermaid/contract"

export function shouldFilterContract(node: ASTNode, config: Config): boolean {
	if (node.type !== "ContractDefinition") return true

	/* ====== EXClUDE EXCEPTIONS ====== */

	if (config.excludeContracts.exceptions.includes(node.name)) return false

	/* ====== LIBRARY ====== */

	if (config.excludeContracts.libraries && isLibrary(node)) return true

	/* ====== INTERFACE ====== */

	if (config.excludeContracts.interfaces && isInterface(node)) return true

	/* ====== COLLECTIONS ====== */

	if (isContractFromCollections(node, config)) return true

	/* ====== EXCLUDE ====== */

	if (config.excludeContracts.contracts.includes(node.name)) return true

	return false
}

export function isContractFromCollections(
	contract: ContractDefinition,
	config: Config,
) {
	for (const collectionName of config.excludeContracts.collections) {
		const file = `${COLLECTIONS_DIR}/${collectionName}.json`

		const collection = fs.readFileSync(file)

		const parsedCollection = JSON.parse(collection.toString())

		if (parsedCollection.includes(contract.name)) return true
	}

	return false
}

function isInterface(node: ContractDefinition) {
	return node.kind === "interface"
}

function isLibrary(node: ContractDefinition) {
	return node.kind === "library"
}

export function shouldFilterMethod(
	method: Method | null,
	config: Config,
): boolean {
	// Method is null if constructor
	if (!method) return true

	/* ====== EXCEPTIONS ====== */

	if (config.excludeFunctions.exceptions.includes(method.name)) return false

	/* ====== REGEX ====== */

	const regExps = config.excludeFunctions.regExps

	return regExps.some((regExp) => regExp.test(method.name))
}
