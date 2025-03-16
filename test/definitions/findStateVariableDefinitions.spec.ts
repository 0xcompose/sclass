import { NonterminalKind } from "@nomicfoundation/slang/cst"
import { buildCompilationUnit } from "../../src/parse/buildCompilationUnit.js"
import { findDefinitionsOfKindsInFile } from "../../src/parse/findDefinitions.js"
import { findStateVariableDefinitions } from "../../src/parse/findDescendantDefinitions.js"
import { expect } from "chai"
import { parseDefinitions } from "../../src/parse/parseDefinitions.js"

describe("findStateVariableDefinitions()", () => {
	const fileId = "test/definitions/StateVariables.sol"

	it("MUST find StateVariableDefinitions in ContractDefinition", async () => {
		const unit = await buildCompilationUnit(fileId)

		const contractDefinition = findDefinitionsOfKindsInFile(unit, fileId, [
			NonterminalKind.ContractDefinition,
		])

		expect(contractDefinition).to.have.lengthOf(
			2,
			"Expected 2 ContractDefinitions",
		)

		const definitionCountInEachContract = [10, 2]

		for (const [index, contract] of contractDefinition.entries()) {
			const definitions = findStateVariableDefinitions(unit, contract)

			const parsedDefinitions = parseDefinitions(definitions)

			const expectedVariablesCount = definitionCountInEachContract[index]

			expect(parsedDefinitions).to.have.lengthOf(
				expectedVariablesCount,
				`Expected ${expectedVariablesCount} StateVariableDefinitions in ContractDefinition ${index}`,
			)
		}
	})
})
