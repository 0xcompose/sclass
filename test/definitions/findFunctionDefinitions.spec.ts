import { NonterminalKind } from "@nomicfoundation/slang/cst"
import { buildCompilationUnit } from "../../src/parse/buildCompilationUnit.js"
import { findDefinitionsOfKindsInFile } from "../../src/utils/definitions.js"
import { findFunctionDefinitions } from "../../src/parse/findDescendingDefinitions.js"
import { expect } from "chai"
import { CompilationUnit } from "@nomicfoundation/slang/compilation"

describe("findFunctionDefinitions()", () => {
	const fileId = "test/definitions/Functions.sol"
	let unit: CompilationUnit

	before(async () => {
		unit = await buildCompilationUnit(fileId)
	})

	it("MUST find FunctionDefinitions in ContractDefinition", () => {
		const contractDefinition = findDefinitionsOfKindsInFile(unit, fileId, [
			NonterminalKind.ContractDefinition,
		])

		expect(contractDefinition).to.have.lengthOf(
			1,
			"Expected 1 ContractDefinition",
		)

		// TODO: connect with slang team to discuss if receive and fallback should be considered defitinitions
		// besides not having identifiers
		const expectedFunctionCount = 2 // Actually 4 including fallback and receive

		const definitions = findFunctionDefinitions(unit, contractDefinition[0])

		expect(definitions).to.have.lengthOf(
			expectedFunctionCount,
			`Expected ${expectedFunctionCount} FunctionDefinitions in ContractDefinition`,
		)
	})

	it("MUST find FunctionDefinitions in InterfaceDefinition", () => {
		const interfaceDefinition = findDefinitionsOfKindsInFile(unit, fileId, [
			NonterminalKind.InterfaceDefinition,
		])

		expect(interfaceDefinition).to.have.lengthOf(
			1,
			"Expected 1 InterfaceDefinition",
		)

		const expectedFunctionCount = 3

		const definitions = findFunctionDefinitions(
			unit,
			interfaceDefinition[0],
		)

		expect(definitions).to.have.lengthOf(
			expectedFunctionCount,
			`Expected ${expectedFunctionCount} FunctionDefinitions in ContractDefinition`,
		)
	})

	it("MUST find FunctionDefinitions in LibraryDefinition", () => {
		const libraryDefinition = findDefinitionsOfKindsInFile(unit, fileId, [
			NonterminalKind.LibraryDefinition,
		])

		expect(libraryDefinition).to.have.lengthOf(
			1,
			"Expected 1 LibraryDefinition",
		)

		const expectedFunctionCount = 2

		const definitions = findFunctionDefinitions(unit, libraryDefinition[0])

		expect(definitions).to.have.lengthOf(
			expectedFunctionCount,
			`Expected ${expectedFunctionCount} FunctionDefinitions in ContractDefinition`,
		)
	})
})
