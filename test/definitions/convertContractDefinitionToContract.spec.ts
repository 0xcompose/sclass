import { CompilationUnit } from "@nomicfoundation/slang/compilation"
import { convertContractDefinitionToContract } from "../../src/parse/convertContractDefinitionToContract.js"
import { buildCompilationUnit } from "../../src/parse/buildCompilationUnit.js"
import { NonterminalKind } from "@nomicfoundation/slang/cst"
import { findDefinitionsOfKindsInFile } from "../../src/utils/definitions.js"

describe.skip("convertContractDefinitionToContract", () => {
	const fileId = "test/constants/TestContract.sol"
	let unit: CompilationUnit

	before(async () => {
		unit = await buildCompilationUnit(fileId)
	})

	it("should convert a contract definition to a contract", () => {
		const contractDefinitions = findDefinitionsOfKindsInFile(unit, fileId, [
			NonterminalKind.ContractDefinition,
		])

		for (const def of contractDefinitions) {
			convertContractDefinitionToContract(unit, def)
		}
	})
})
