import { expect } from "chai"
import { makeSuite, TEST_CONTRACT_PATH } from "./utils/makeSuite.js"

import { checkIfCollectionsExist } from "../src/utils/checkers.js"
import { ContractDefinition } from "@solidity-parser/parser/dist/src/ast-types.js"
import {
	isContractFromCollections,
	shouldFilterMethod,
} from "../src/utils/filter.js"
import { readInputFileAndParse } from "../src/main.js"
import { Method } from "../src/mermaid/contract.js"
import { Config } from "../src/config.js"

function checkIfCollectionsExistTest() {
	it("shouldn't return an error", async () => {
		checkIfCollectionsExist(["TestCollection"])
	})

	it("should throw an error", async () => {
		expect(() =>
			checkIfCollectionsExist([
				"TestCollection",
				"NonExistentCollection",
			]),
		).to.throw
	})
}

function isContractFromCollectionsTest() {
	Config.excludeContracts = {
		collections: ["TestCollection"],
		interfaces: false,
		libraries: false,
	}

	Config.collections = {
		TestCollection: ["ContractInCollection"],
	}

	it("should return true if contract is in collection", async () => {
		const contractToFilter = {
			name: "ContractInCollection",
		} as ContractDefinition

		const result = isContractFromCollections(contractToFilter)

		expect(result).to.be.true
	})

	it("should return false if contract is not in collection", async () => {
		const contractToFilter = {
			name: "ContractNotInCollection",
		} as ContractDefinition

		const result = isContractFromCollections(contractToFilter)

		expect(result).to.be.false
	})
}

function readFileAndParseTest() {
	it("should return an array of contracts", async () => {
		Config.inputContractFilePath = TEST_CONTRACT_PATH

		const contracts = await readInputFileAndParse()

		expect(contracts).to.be.an("array")

		contracts.forEach((contract) => {
			expect(contract).to.have.property("name")
			expect(contract).to.have.property("type")
		})
	})
}

function shouldFilterMethodTest() {
	Config.excludeFunctions = {
		regExps: [/.*test.*/i, /.*abc.*/i, /.*exception.*/i],
		exceptions: ["exception"],
	}

	it("should return true if method name matches regex", async () => {
		const method = {
			name: "testMethod",
		} as Method

		const result = shouldFilterMethod(method)

		expect(result).to.be.true
	})

	it("should return false if method name doesn't match regex", async () => {
		const method = {
			name: "jestMethod",
		} as Method

		const result = shouldFilterMethod(method)

		expect(result).to.be.false
	})

	it("should return false if method name is in exceptions", async () => {
		const method = {
			name: "exception",
		} as Method

		const result = shouldFilterMethod(method)

		expect(result).to.be.false
	})
}

// makeSuite("checkIfContractsExist", checkIfContractsExistTest)
makeSuite("checkIfCollectionsExist", checkIfCollectionsExistTest)
makeSuite("isContractFromCollections", isContractFromCollectionsTest)
makeSuite("readFileAndParse", readFileAndParseTest)
makeSuite("shouldFilterMethod", shouldFilterMethodTest)
