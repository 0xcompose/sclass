import { NonterminalKind } from "@nomicfoundation/slang/cst"
import { buildCompilationUnit } from "../../src/parse/buildCompilationUnit.js"
import { findDefinitionsOfKindsInFile } from "../../src/utils/definitions.js"
import { findStateVariableDefinitions } from "../../src/parse/findDescendingDefinitions.js"
import { expect } from "chai"

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

			const expectedVariablesCount = definitionCountInEachContract[index]

			expect(definitions).to.have.lengthOf(
				expectedVariablesCount,
				`Expected ${expectedVariablesCount} StateVariableDefinitions in ContractDefinition ${index}`,
			)
		}
	})
})
