import { NonterminalKind } from "@nomicfoundation/slang/cst"
import { Definition } from "@nomicfoundation/slang/bindings"
import { findDefinitionsOfKindsInFile } from "../utils/definitions.js"
import { CompilationUnit } from "@nomicfoundation/slang/compilation"

export async function parseFileForDefinitions(
	unit: CompilationUnit,
	filePath: string,
): Promise<{
	contracts: Definition[]
	interfaces: Definition[]
	libraries: Definition[]
}> {
	// Find and Parse ContractDefinitions

	const contracts = findDefinitionsOfKindsInFile(unit, filePath, [
		NonterminalKind.ContractDefinition,
	])

	// Find and Parse LibraryDefinitions

	const libraries = findDefinitionsOfKindsInFile(unit, filePath, [
		NonterminalKind.LibraryDefinition,
	])

	// Find and Parse InterfaceDefinitions

	const interfaces = findDefinitionsOfKindsInFile(unit, filePath, [
		NonterminalKind.InterfaceDefinition,
	])

	return { contracts, interfaces, libraries }
}
