// Executes sclass CLI command for every .sol file in test/definitions

import { expect } from "chai"
import { sclass } from "../utils/cli.js"
import fs from "fs"

describe("CLI runs with various definition test files", () => {
	// Get all .sol files in test/definitions
	const files = fs.readdirSync("./test/definitions")

	for (const file of files) {
		it(`should generate diagram for ${file}`, async () => {
			const output = await sclass({
				input: `./test/definitions/${file}`,
			})

			expect(output.stdout.length).to.be.greaterThan(100)
		})
	}
})
