import { expect } from "chai"
import { CliConfig } from "../../src/config.js"

describe("parseFlagsWithoutArguments()", () => {
	it("should remove flags without arguments", () => {
		const cliConfig = new CliConfig()

		const args = [
			"--exclude-interfaces",
			"-ei",
			"--exclude-libraries",
			"-el",
		]

		cliConfig.parseFlagsWithoutArguments(args)

		expect(cliConfig.exclude.contracts.interfaces).to.be.equal(true)
		expect(args).to.deep.equal([])
	})

	it("MUST NOT remove flags with arguments", () => {
		const cliConfig = new CliConfig()

		const args = [
			"src/contracts/Contract1.sol",
			"--output",
			"output.md",
			"-t",
			"forest",
			"--exclude-contracts",
			`["Contract1", "Contract2"]`,
		]
		const argsDuplicate = [...args]

		cliConfig.parseFlagsWithoutArguments(args)
		expect(args).to.deep.equal(argsDuplicate)
	})

	it("MUST exclude interfaces if --exclude-interfaces flag is provided", () => {
		const cliConfig = new CliConfig()

		const args = ["--exclude-interfaces"]

		cliConfig.parseFlagsWithoutArguments(args)
		expect(cliConfig.exclude.contracts.interfaces).to.be.equal(true)
	})

	it("MUST exclude interfaces if -ei flag is provided", () => {
		const cliConfig = new CliConfig()

		const args = ["-ei"]

		cliConfig.parseFlagsWithoutArguments(args)
		expect(cliConfig.exclude.contracts.interfaces).to.be.equal(true)
	})

	it("MUST exclude libraries if --exclude-libraries flag is provided", () => {
		const cliConfig = new CliConfig()

		const args = ["--exclude-libraries"]

		cliConfig.parseFlagsWithoutArguments(args)
		expect(cliConfig.exclude.contracts.libraries).to.be.equal(true)
	})

	it("MUST exclude libraries if -el flag is provided", () => {
		const cliConfig = new CliConfig()

		const args = ["-el"]

		cliConfig.parseFlagsWithoutArguments(args)
		expect(cliConfig.exclude.contracts.libraries).to.be.equal(true)
	})
})
