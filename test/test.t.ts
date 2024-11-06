import { expect } from "chai"
import { makeSuite } from "./utils/makeSuite"

import {
    checkIfCollectionsExist,
    checkIfContractsExist,
} from "../src/utils/checkers"
import fs from "fs"
import { ContractDefinition } from "@solidity-parser/parser/dist/src/ast-types"
import {
    isContractFromCollections,
    shouldFilterMethod,
} from "../src/utils/filter"
import { readFileAndParse } from "../src/main"
import { Method } from "../src/mermaid/contract"

function checkIfContractsExistTest() {
    it("shouldn't return an error", async () => {
        checkIfContractsExist(["TestContract"])
    })

    it("should throw an error", async () => {
        expect(() =>
            checkIfContractsExist(["TestContract", "NonExistentContract"]),
        ).to.throw
    })
}

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
    const config = {
        excludeContracts: {
            collections: ["TestCollection"],
        },
    } as Config

    it("should return true if contract is in collection", async () => {
        const contractToFilter = {
            name: "ContractInCollection",
        } as ContractDefinition

        const result = isContractFromCollections(contractToFilter, config)

        expect(result).to.be.true
    })

    it("should return false if contract is not in collection", async () => {
        const contractToFilter = {
            name: "ContractNotInCollection",
        } as ContractDefinition

        const result = isContractFromCollections(contractToFilter, config)

        expect(result).to.be.false
    })
}

function readFileAndParseTest() {
    it("should return an array of contracts", async () => {
        const config = {
            inputContracts: ["TestContract"],
        } as Config

        const contracts = readFileAndParse(config)

        expect(contracts).to.be.an("array")

        contracts.forEach((contract) => {
            expect(contract).to.have.property("name")
            expect(contract).to.have.property("type")
        })
    })
}

function shouldFilterMethodTest() {
    const config = {
        excludeFunctions: {
            regExps: [/.*test.*/i, /.*abc.*/i, /.*exception.*/i],
            exceptions: ["exception"],
        },
    } as Config

    it("should return true if method name matches regex", async () => {
        const method = {
            name: "testMethod",
        } as Method

        const result = shouldFilterMethod(method, config)

        expect(result).to.be.true
    })

    it("should return false if method name doesn't match regex", async () => {
        const method = {
            name: "jestMethod",
        } as Method

        const result = shouldFilterMethod(method, config)

        expect(result).to.be.false
    })

    it("should return false if method name is in exceptions", async () => {
        const method = {
            name: "exception",
        } as Method

        const result = shouldFilterMethod(method, config)

        expect(result).to.be.false
    })
}

makeSuite("checkIfContractsExist", checkIfContractsExistTest)
makeSuite("checkIfCollectionsExist", checkIfCollectionsExistTest)
makeSuite("isContractFromCollections", isContractFromCollectionsTest)
makeSuite("readFileAndParse", readFileAndParseTest)
makeSuite("shouldFilterMethod", shouldFilterMethodTest)
