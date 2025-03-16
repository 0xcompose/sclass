import { Method } from "../mermaid/contract.js"
import { Config } from "../config.js"
import { ParsedDefinition } from "../parse/types.js"
import { NonterminalKind } from "@nomicfoundation/slang/cst"

export function shouldFilterContract(
	definition: ParsedDefinition<any>,
): boolean {
	const contracts = Config.exclude.contracts

	if (definition.kind !== NonterminalKind.ContractDefinition) return true

	/* ====== EXClUDE EXCEPTIONS ====== */

	if (contracts.exceptions.includes(definition.name)) return false

	/* ====== LIBRARY ====== */

	if (contracts.libraries && isLibrary(definition)) return true

	/* ====== INTERFACE ====== */

	if (contracts.interfaces && isInterface(definition)) return true

	/* ====== COLLECTIONS ====== */

	if (isContractFromCollections(definition)) return true

	/* ====== EXCLUDE ====== */

	if (contracts.contracts.includes(definition.name)) return true

	return false
}

export function isContractFromCollections(definition: ParsedDefinition<any>) {
	const collections = Config.exclude.contracts.collections

	for (const collectionName of collections) {
		// Get absolute path of collections

		const collection = Config.collections[collectionName]

		if (!collection) return false

		if (collection.includes(definition.name)) return true
	}

	return false
}

function isInterface(node: ParsedDefinition<any>) {
	return node.kind === NonterminalKind.InterfaceDefinition
}

function isLibrary(node: ParsedDefinition<any>) {
	return node.kind === NonterminalKind.LibraryDefinition
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
