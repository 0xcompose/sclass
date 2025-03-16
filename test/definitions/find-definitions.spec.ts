import { CompilationUnit } from "@nomicfoundation/slang/compilation"

import { assert } from "chai"
import {
	findDefinitionsInFile,
	findDefinitionsOfKindsInFile,
} from "../../src/parse/find-definitions.js"
import { buildCompilationUnit } from "../../src/parse/buildCompilationUnit.js"
import { TEST_CONTRACT_PATH } from "../utils/makeSuite.js"
import { parseDefinitions } from "../../src/parse/parse-definitions.js"
import { DefinitionKind } from "../../src/misc/constants.js"

describe("findDefinitionsInFile() / findDefinitionsOfKindsInFile()", () => {
	const fileId = TEST_CONTRACT_PATH
	let unit: CompilationUnit

	before(async () => {
		unit = await buildCompilationUnit(fileId)
	})

	it("MUST find Definitions in a file", async () => {
		const definitions = findDefinitionsInFile(unit, fileId)

		const parsedDefinitions = parseDefinitions(definitions)

		assert.equal(parsedDefinitions.length, 16)
	})

	it("MUST find ContractDefinition in a file", async () => {
		const definitions = findDefinitionsOfKindsInFile(unit, fileId, [
			DefinitionKind.Contract,
		])

		const parsedDefinitions = parseDefinitions(definitions)

		assert.equal(parsedDefinitions.length, 5)
	})

	it("MUST find FunctionDefinition in a file", async () => {
		const definitions = findDefinitionsOfKindsInFile(unit, fileId, [
			DefinitionKind.Function,
		])

		const parsedDefinitions = parseDefinitions(definitions)

		assert.equal(parsedDefinitions.length, 6)
	})

	it("MUST find Parameter in a file", async () => {
		const definitions = findDefinitionsOfKindsInFile(unit, fileId, [
			DefinitionKind.Parameter,
		])

		const parsedDefinitions = parseDefinitions(definitions)

		assert.equal(parsedDefinitions.length, 2)
	})

	it("MUST find StateVariableDefinition in a file", async () => {
		const definitions = findDefinitionsOfKindsInFile(unit, fileId, [
			DefinitionKind.StateVariable,
		])

		const parsedDefinitions = parseDefinitions(definitions)

		assert.equal(parsedDefinitions.length, 2)
	})
})
