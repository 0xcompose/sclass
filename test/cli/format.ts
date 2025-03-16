import { Format } from "../../src/misc/constants.js"
import { sclass } from "../utils/cli.js"
import { TEST_OUTPUT_DIR } from "../utils/makeSuite.js"
import { TEST_CONTRACT_MERMAID } from "../constants/TestContractMermaid.js"
import { readTempFile } from "../utils/readTempFile.js"
import { expect } from "chai"
import { compareMermaidSchemes } from "../utils/compareMermaidSchemes.js"

export function formatTest() {
	it("should generate mermaid code in mmd format", () => {
		const format = Format.MMD
		sclass({
			flags: `-f ${format} -o ${TEST_OUTPUT_DIR}/Test.${format}`,
		})

		const result = readTempFile(`Test.${format}`)

		compareMermaidSchemes(result, TEST_CONTRACT_MERMAID)
	})

	// TODO: investigate why it generates svg
	it.skip("should generate mermaid code in md format", () => {
		const format = Format.MD
		sclass({
			flags: `-f ${format} -o ${TEST_OUTPUT_DIR}/Test.${format}`,
		})

		const result = readTempFile(`Test.${format}`)

		compareMermaidSchemes(result, TEST_CONTRACT_MERMAID)
	})

	it("should generate mermaid code in svg format", () => {
		const format = Format.SVG
		sclass({
			flags: `-f ${format} -o ${TEST_OUTPUT_DIR}/Test.${format}`,
		})

		const result = readTempFile(`Test.${format}`)
		// console.log(result)

		expect(result).to.be.a("string")
		expect(result).to.include("svg")
		expect(result).length.to.be.greaterThan(1000)
	})

	it("should generate mermaid code in png format", () => {
		const format = Format.PNG
		sclass({
			flags: `-f ${format} -o ${TEST_OUTPUT_DIR}/Test.${format}`,
		})

		const result = readTempFile(`Test.${format}`)

		expect(result).to.be.a("string")
		expect(result).to.include("PNG")
		expect(result).length.to.be.greaterThan(1000)
	})

	it("should generate mermaid code in pdf format", () => {
		const format = Format.PDF

		sclass({
			flags: `-f ${format} -o ${TEST_OUTPUT_DIR}/Test.${format}`,
		})

		const result = readTempFile(`Test.${format}`)

		expect(result).to.be.a("string")
		expect(result).to.include("PDF")
		expect(result).length.to.be.greaterThan(1000)
	})
}
