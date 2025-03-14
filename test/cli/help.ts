import { expect } from "chai"
import { HELP_MESSAGE } from "../../src/misc/constants.js"
import { sclass } from "../utils/cli"

export function helpFlagTest() {
	it("should print help with --help flag", () => {
		const result = sclass({
			flags: "--help",
		})
		expect(result).to.include(HELP_MESSAGE)
	})

	it("should print help with -h flag", () => {
		const result = sclass({
			flags: "-h",
		})
		expect(result).to.include(HELP_MESSAGE)
	})
}
