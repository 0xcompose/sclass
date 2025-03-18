import { CompilationUnit } from "@nomicfoundation/slang/compilation"

import { assert } from "chai"
import {
	findDefinitionsInFile,
	findDefinitionsOfKindsInFile,
} from "../../src/parse/findDefinitions.js"
import { buildCompilationUnit } from "../../src/parse/buildCompilationUnit.js"
import { TEST_CONTRACT_PATH } from "../utils/makeSuite.js"
import { parseDefinitions } from "../../src/parse/parseDefinitions.js"
import { NonterminalKind } from "@nomicfoundation/slang/cst"

describe("findDefinitionsInFile() / findDefinitionsOfKindsInFile()", () => {
	const fileId = TEST_CONTRACT_PATH
	let unit: CompilationUnit

	before(async () => {
		unit = await buildCompilationUnit(fileId)
	})

	it("MUST find Definitions in a file", async () => {
		const definitions = findDefinitionsInFile(unit, fileId)

		const parsedDefinitions = parseDefinitions(definitions)

		assert.equal(parsedDefinitions.length, 18)
	})

	it("MUST find ContractDefinition in a file", async () => {
		const definitions = findDefinitionsOfKindsInFile(unit, fileId, [
			NonterminalKind.ContractDefinition,
		])

		const parsedDefinitions = parseDefinitions(definitions)

		assert.equal(parsedDefinitions.length, 5)
	})

	it("MUST find FunctionDefinition in a file", async () => {
		const definitions = findDefinitionsOfKindsInFile(unit, fileId, [
			NonterminalKind.FunctionDefinition,
		])

		const parsedDefinitions = parseDefinitions(definitions)

		assert.equal(parsedDefinitions.length, 6)
	})

	it("MUST find Parameter in a file", async () => {
		const definitions = findDefinitionsOfKindsInFile(unit, fileId, [
			NonterminalKind.Parameter,
		])

		const parsedDefinitions = parseDefinitions(definitions)

		assert.equal(parsedDefinitions.length, 2)
	})

	it("MUST find StateVariableDefinition in a file", async () => {
		const definitions = findDefinitionsOfKindsInFile(unit, fileId, [
			NonterminalKind.StateVariableDefinition,
		])

		const parsedDefinitions = parseDefinitions(definitions)

		assert.equal(parsedDefinitions.length, 4)
	})
})
