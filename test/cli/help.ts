import { expect } from "chai"
import { HELP_MESSAGE } from "../../src/constants.js"
import { sclass } from "../utils/cli.js"

export function helpFlagTest() {
	it("should print help with --help flag", async () => {
		const result = await sclass({
			flags: "--help",
		})
		expect(result.stdout).to.include(HELP_MESSAGE)
	})

	it("should print help with -h flag", async () => {
		const result = await sclass({
			flags: "-h",
		})
		expect(result.stdout).to.include(HELP_MESSAGE)
	})
}
