import { assert, expect } from "chai"
import { findDefinitionsInFile } from "../../src/parse/findDefinitions.js"
import { parseDefinitions } from "../../src/parse/parseDefinitions.js"
import { TEST_CONTRACT_PATH } from "../utils/makeSuite.js"
import { buildCompilationUnit } from "../../src/parse/buildCompilationUnit.js"

describe("parseDefinitions()", () => {
	it("MUST parse Definitions", async () => {
		const unit = await buildCompilationUnit(TEST_CONTRACT_PATH)

		const definitions = findDefinitionsInFile(unit, TEST_CONTRACT_PATH)

		const parsedDefinitions = parseDefinitions(definitions)

		assert.equal(parsedDefinitions.length, 18)

		for (const definition of parsedDefinitions) {
			expect(definition).to.have.property("name")
			expect(definition).to.have.property("kind")
			expect(definition).to.have.property("definition")
		}
	})
})
