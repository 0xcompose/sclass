import { NonterminalKind } from "@nomicfoundation/slang/cst"
import { buildCompilationUnit } from "../../src/parse/buildCompilationUnit.js"
import { findDefinitionsOfKindsInFile } from "../../src/utils/definitions.js"
import { expect } from "chai"
import { CompilationUnit } from "@nomicfoundation/slang/compilation"
import { findInheritanceIdentifiers } from "../../src/parse/findDescendingDefinitions.js"
import { getDefinitionName } from "../../src/utils/definitions.js"
import { TEST_CONTRACT_PATH } from "../utils/makeSuite.js"

describe("findInheritanceIdentifiers()", () => {
	const fileId = "test/definitions/Inheritance.sol"
	let unit: CompilationUnit

	before(async () => {
		unit = await buildCompilationUnit(fileId)
	})

	it("MUST find InheritanceIdentifiers in ContractDefinition", () => {
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

	it("MUST find InheritanceIdentifiers in InterfaceDefinition", () => {
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

	it("MUST find InheritanceIdentifiers in TestContract", async () => {
		const fileId = TEST_CONTRACT_PATH
		const unit = await buildCompilationUnit(fileId)

		const contractDefinitions = findDefinitionsOfKindsInFile(unit, fileId, [
			NonterminalKind.ContractDefinition,
		])

		const expectedInheritance: Record<string, string[]> = {
			ITestContract: [],
			Base: [],
			ContractInCollection: [],
			MiddleInInheritance: ["Base"],
			TestContract1: [
				"MiddleInInheritance",
				"ContractInCollection",
				"ITestContract",
			],
			TestContract2: ["MiddleInInheritance"],
		}

		for (const contractDefinition of contractDefinitions) {
			const inheritanceIdentifiers = findInheritanceIdentifiers(
				unit,
				contractDefinition,
			)

			const expected =
				expectedInheritance[getDefinitionName(contractDefinition)]

			expect(expected).to.deep.equal(
				inheritanceIdentifiers.map((definition) =>
					getDefinitionName(definition),
				),
				`Expected inheritance of ${getDefinitionName(
					contractDefinition,
				)} to be ${expected.join(
					", ",
				)}, but found ${inheritanceIdentifiers
					.map((definition) => getDefinitionName(definition))
					.join(", ")}`,
			)
		}
	})
})
