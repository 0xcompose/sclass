import { NonterminalKind } from "@nomicfoundation/slang/cst"
import { buildCompilationUnit } from "../../src/parse/buildCompilationUnit.js"
import { findDefinitionsOfKindsInFile } from "../../src/parse/findDefinitions.js"
import {
	findFunctionDefinitions,
	findFunctionParameterDefinitions,
} from "../../src/parse/findDescendantDefinitions.js"
import { expect } from "chai"
import { parseDefinitions } from "../../src/parse/parseDefinitions.js"
import { CompilationUnit } from "@nomicfoundation/slang/compilation"
import { getDefinitionCursor } from "../../src/utils/getDefinitionCursor.js"

describe("findFunctionParameterDefinitions()", () => {
	const fileId = "test/definitions/Parameters.sol"
	let unit: CompilationUnit

	before(async () => {
		unit = await buildCompilationUnit(fileId)
	})

	it("MUST find FunctionParameterDefinitions in FunctionDefinition", async () => {
		const contractDefinition = findDefinitionsOfKindsInFile(unit, fileId, [
			NonterminalKind.ContractDefinition,
		])

		const functionDefinitions = findFunctionDefinitions(
			unit,
			contractDefinition[0],
		)

		const expectedFunctionCount = 6

		expect(functionDefinitions).to.have.lengthOf(
			expectedFunctionCount,
			`Expected ${expectedFunctionCount} FunctionDefinitions`,
		)

		// Unnamed return parameters are no t considered identifiers by slang
		const expectedParameterCountForEachFunction = [3, 2, 1, 1, 2, 3]

		for (const [
			index,
			functionDefinition,
		] of functionDefinitions.entries()) {
			const functionCursor = getDefinitionCursor(functionDefinition)

			const definitions = findFunctionParameterDefinitions(
				unit,
				functionCursor,
			)

			const parsedDefinitions = parseDefinitions(definitions)

			expect(parsedDefinitions).to.have.lengthOf(
				expectedParameterCountForEachFunction[index],
				`Expected ${expectedParameterCountForEachFunction[index]} FunctionParameterDefinitions in FunctionDefinition ${index}`,
			)
		}
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
