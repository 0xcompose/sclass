import {
	ASTNode,
	ContractDefinition,
} from "@solidity-parser/parser/dist/src/ast-types.js"
import { Method } from "../mermaid/contract.js"
import { Config } from "../config.js"

export function shouldFilterContract(node: ASTNode): boolean {
	const contracts = Config.exclude.contracts

	if (node.type !== "ContractDefinition") return true

	/* ====== EXClUDE EXCEPTIONS ====== */

	if (contracts.exceptions.includes(node.name)) return false

	/* ====== LIBRARY ====== */

	if (contracts.libraries && isLibrary(node)) return true

	/* ====== INTERFACE ====== */

	if (contracts.interfaces && isInterface(node)) return true

	/* ====== COLLECTIONS ====== */

	if (isContractFromCollections(node)) return true

	/* ====== EXCLUDE ====== */

	if (contracts.contracts.includes(node.name)) return true

	return false
}

export function isContractFromCollections(contract: ContractDefinition) {
	const collections = Config.exclude.contracts.collections

	for (const collectionName of collections) {
		// Get absolute path of collections

		const collection = Config.collections[collectionName]

		if (!collection) return false

		if (collection.includes(contract.name)) return true
	}

	return false
}

function isInterface(node: ContractDefinition) {
	return node.kind === "interface"
}

function isLibrary(node: ContractDefinition) {
	return node.kind === "library"
}

export function shouldFilterMethod(method: Method | null): boolean {
	const functions = Config.exclude.functions

	// Method is null if constructor
	if (!method) return true

	/* ====== EXCEPTIONS ====== */

	if (functions.exceptions.includes(method.name)) return false

	/* ====== REGEX ====== */

	const regExps = functions.regExps

	return regExps.some((regExp) => regExp.test(method.name))
}
