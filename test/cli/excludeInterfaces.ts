import { expect } from "chai"
import { sclass } from "../utils/cli.js"

export const excludeInterfacesTest = () => {
	it("should exclude interfaces from the diagram", () => {
		const result = sclass({
			flags: "-ei",
		})

		expect(result).to.equal("interfaces excluded")
	})
}
