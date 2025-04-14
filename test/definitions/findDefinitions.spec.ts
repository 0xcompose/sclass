import { CompilationUnit } from "@nomicfoundation/slang/compilation"

import { assert } from "chai"
import {
	findDefinitionsInFile,
	findDefinitionsOfKindsInFile,
} from "../../src/utils/definitions.js"
import { buildCompilationUnit } from "../../src/parse/buildCompilationUnit.js"
import { TEST_CONTRACT_PATH } from "../utils/makeSuite.js"
import { NonterminalKind } from "@nomicfoundation/slang/cst"

describe("findDefinitionsInFile() / findDefinitionsOfKindsInFile()", () => {
	const fileId = TEST_CONTRACT_PATH
	let unit: CompilationUnit

	before(async () => {
		unit = await buildCompilationUnit(fileId)
	})

	it("MUST find Definitions in a file", () => {
		const definitions = findDefinitionsInFile(unit, fileId)

		assert.equal(definitions.length, 18)
	})

	it("MUST find ContractDefinition in a file", () => {
		const definitions = findDefinitionsOfKindsInFile(unit, fileId, [
			NonterminalKind.ContractDefinition,
		])

		assert.equal(definitions.length, 5)
	})

	it("MUST find FunctionDefinition in a file", () => {
		const definitions = findDefinitionsOfKindsInFile(unit, fileId, [
			NonterminalKind.FunctionDefinition,
		])

		assert.equal(definitions.length, 6)
	})

	it("MUST find Parameter in a file", () => {
		const definitions = findDefinitionsOfKindsInFile(unit, fileId, [
			NonterminalKind.Parameter,
		])

		assert.equal(definitions.length, 2)
	})

	it("MUST find StateVariableDefinition in a file", () => {
		const definitions = findDefinitionsOfKindsInFile(unit, fileId, [
			NonterminalKind.StateVariableDefinition,
		])

		assert.equal(definitions.length, 4)
	})
})
