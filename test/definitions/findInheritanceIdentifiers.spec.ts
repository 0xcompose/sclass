import { NonterminalKind } from "@nomicfoundation/slang/cst"
import { buildCompilationUnit } from "../../src/parse/buildCompilationUnit.js"
import { findDefinitionsOfKindsInFile } from "../../src/parse/findDefinitions.js"
import { expect } from "chai"
import { CompilationUnit } from "@nomicfoundation/slang/compilation"
import { findInheritanceIdentifiers } from "../../src/parse/findDescendantDefinitions.js"
import { getDefinitionName } from "../../src/utils/getDefinitionName.js"

describe("findInheritanceIdentifiers()", () => {
	const fileId = "test/definitions/Inheritance.sol"
	let unit: CompilationUnit

	before(async () => {
		unit = await buildCompilationUnit(fileId)
	})

	it("MUST find InheritanceIdentifiers in ContractDefinition", async () => {
		const contractDefinitions = findDefinitionsOfKindsInFile(unit, fileId, [
			NonterminalKind.ContractDefinition,
		])

		expect(contractDefinitions).to.have.lengthOf(
			5,
			"Expected 5 ContractDefinitions",
		)

		const expected: Record<string, string[]> = {
			Parent1: [],
			Parent2: [],
			Child1: ["Parent1", "Parent2"],
			Child2: [],
			GrandChild: ["Child1", "Child2"],
		}

		for (const contract of contractDefinitions) {
			const inheritanceIdentifiers = findInheritanceIdentifiers(
				unit,
				contract,
			)

			expect(expected[getDefinitionName(contract)]).to.deep.equal(
				inheritanceIdentifiers.map((definition) =>
					getDefinitionName(definition),
				),
			)
		}
	})

	it("MUST find InheritanceIdentifiers in InterfaceDefinition", async () => {
		const interfaceDefinitions = findDefinitionsOfKindsInFile(
			unit,
			fileId,
			[NonterminalKind.InterfaceDefinition],
		)

		expect(interfaceDefinitions).to.have.lengthOf(
			4,
			"Expected 4 InterfaceDefinitions",
		)

		const expectedInheritance: Record<string, string[]> = {
			Parent3: [],
			Parent4: [],
			Child3: ["Parent3", "Parent4"],
			Child4: ["Child3"],
		}

		for (const interfaceDefinition of interfaceDefinitions) {
			const inheritanceIdentifiers = findInheritanceIdentifiers(
				unit,
				interfaceDefinition,
			)

			const expected =
				expectedInheritance[getDefinitionName(interfaceDefinition)]

			expect(expected).to.deep.equal(
				inheritanceIdentifiers.map((definition) =>
					getDefinitionName(definition),
				),
			)
		}
	})
})
