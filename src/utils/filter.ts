import { Method } from "../mermaid/contract.js"
import { Config } from "../config.js"
import {
	ParsedContractDefinition,
	ParsedDefinition,
	ParsedInterfaceDefinition,
	ParsedLibraryDefinition,
} from "../parse/types.js"

export function shouldIncludeContract(
	definition: ParsedContractDefinition,
): boolean {
	if (isException(definition)) return true

	return shouldFilter(definition)
}

export function shouldIncludeLibrary(definition: ParsedLibraryDefinition) {
	if (isException(definition)) return true

	const excludeLibs = Config.exclude.contracts.libraries

	if (excludeLibs) return false

	return shouldFilter(definition)
}

export function shouldIncludeInterface(definition: ParsedInterfaceDefinition) {
	if (isException(definition)) return true

	const excludeInterfaces = Config.exclude.contracts.interfaces

	if (excludeInterfaces) return false

	return shouldFilter(definition)
}

function shouldFilter(
	definition:
		| ParsedContractDefinition
		| ParsedLibraryDefinition
		| ParsedInterfaceDefinition,
) {
	const contracts = Config.exclude.contracts

	/* ====== COLLECTIONS ====== */

	if (isContractFromCollections(definition)) return false

	/* ====== EXCLUDE ====== */

	if (contracts.contracts.includes(definition.name)) return false

	return true
}

function isException(definition: ParsedDefinition<any>) {
	const contracts = Config.exclude.contracts

	return contracts.exceptions.includes(definition.name)
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
