import { NonterminalKind } from "@nomicfoundation/slang/cst"
import { buildCompilationUnit } from "../../src/parse/buildCompilationUnit.js"
import { findDefinitionsOfKindsInFile } from "../../src/parse/findDefinitions.js"
import { findFunctionDefinitions } from "../../src/parse/findDescendantDefinitions.js"
import { expect } from "chai"
import { parseDefinitions } from "../../src/parse/parseDefinitions.js"
import { CompilationUnit } from "@nomicfoundation/slang/compilation"

describe("findFunctionDefinitions()", () => {
	const fileId = "test/definitions/Functions.sol"
	let unit: CompilationUnit

	before(async () => {
		unit = await buildCompilationUnit(fileId)
	})

	it("MUST find FunctionDefinitions in ContractDefinition", async () => {
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

		const parsedDefinitions = parseDefinitions(definitions)

		expect(parsedDefinitions).to.have.lengthOf(
			expectedFunctionCount,
			`Expected ${expectedFunctionCount} FunctionDefinitions in ContractDefinition`,
		)
	})

	it("MUST find FunctionDefinitions in InterfaceDefinition", async () => {
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

		const parsedDefinitions = parseDefinitions(definitions)

		expect(parsedDefinitions).to.have.lengthOf(
			expectedFunctionCount,
			`Expected ${expectedFunctionCount} FunctionDefinitions in ContractDefinition`,
		)
	})

	it("MUST find FunctionDefinitions in LibraryDefinition", async () => {
		const libraryDefinition = findDefinitionsOfKindsInFile(unit, fileId, [
			NonterminalKind.LibraryDefinition,
		])

		expect(libraryDefinition).to.have.lengthOf(
			1,
			"Expected 1 LibraryDefinition",
		)

		const expectedFunctionCount = 2

		const definitions = findFunctionDefinitions(unit, libraryDefinition[0])

		const parsedDefinitions = parseDefinitions(definitions)

		expect(parsedDefinitions).to.have.lengthOf(
			expectedFunctionCount,
			`Expected ${expectedFunctionCount} FunctionDefinitions in ContractDefinition`,
		)
	})
})
