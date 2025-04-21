import { sclass } from "../utils/cli.js"
import fs from "fs"
import { makeSuite, TEST_OUTPUT_DIR } from "../utils/makeSuite.js"
import { compareMermaidSchemes } from "../utils/compareMermaidSchemes.js"
import { TEST_CONTRACT_MERMAID } from "../constants/TestContractMermaid.js"
import {
	expectToBePNG,
	expectToBeSVG,
	expectToBePDF,
} from "../utils/expectFile.js"

export function outputTest() {
	// it("should generate mermaid code in stdout", () => {
	// 	const result = sclass()
	// })

	it("Doesn't throw error if file with given name already exists", async () => {
		// Create temp file
		fs.writeFileSync(`${TEST_OUTPUT_DIR}/Test.mmd`, "occupy file name")

		await sclass({
			flags: `-o ${TEST_OUTPUT_DIR}/Test.mmd`,
		})

		const fileContent = fs.readFileSync(
			`${TEST_OUTPUT_DIR}/Test.mmd`,
			"utf8",
		)

		compareMermaidSchemes(fileContent, TEST_CONTRACT_MERMAID)
	})

	it("Creates folder, if it doesn't exist", async () => {
		await sclass({
			flags: `-o ${TEST_OUTPUT_DIR}/Test/Test.mmd`,
		})

		const fileContent = fs.readFileSync(
			`${TEST_OUTPUT_DIR}/Test/Test.mmd`,
			"utf8",
		)

		compareMermaidSchemes(fileContent, TEST_CONTRACT_MERMAID)
	})

	it("Can create multiple child folders to write file into", async () => {
		await sclass({
			flags: `-o ${TEST_OUTPUT_DIR}/Test/abc/Test.mmd`,
		})

		const fileContent = fs.readFileSync(
			`${TEST_OUTPUT_DIR}/Test/abc/Test.mmd`,
			"utf8",
		)

		compareMermaidSchemes(fileContent, TEST_CONTRACT_MERMAID)
	})

	makeSuite(
		"Appends file extension to output file name, if it is not provided",
		function () {
			it("MMD", async () => {
				await sclass({
					flags: `-o ${TEST_OUTPUT_DIR}/Test`,
				})

				const mmdFileContent = fs.readFileSync(
					`${TEST_OUTPUT_DIR}/Test.mmd`,
					"utf8",
				)

				compareMermaidSchemes(mmdFileContent, TEST_CONTRACT_MERMAID)
			})

			it("SVG", async () => {
				await sclass({
					flags: `-o ${TEST_OUTPUT_DIR}/Test -f svg`,
				})

				expectToBeSVG(`${TEST_OUTPUT_DIR}/Test.svg`)
			})

			it("PNG", async () => {
				await sclass({
					flags: `-o ${TEST_OUTPUT_DIR}/Test -f png`,
				})

				expectToBePNG(`${TEST_OUTPUT_DIR}/Test.png`)
			})

			it("PDF", async () => {
				await sclass({
					flags: `-o ${TEST_OUTPUT_DIR}/Test -f pdf`,
				})

				expectToBePDF(`${TEST_OUTPUT_DIR}/Test.pdf`)
			})
		},
	)

	makeSuite(
		"If not specified, uses provided format and generates file with name of the Solidity file name",
		function () {
			// it.only("MMD", function () {
			// 	const result = sclass({
			// 		flags: "-f mmd",
			// 	})

			// 	compareMermaidSchemes(result, TEST_CONTRACT_MERMAID)
			// })

			// Generates SVG in markdown file
			it.skip("MD", async function () {
				const result = await sclass({
					flags: "-f md",
				})

				compareMermaidSchemes(result.stdout, TEST_CONTRACT_MERMAID)
				cleanUpTempFile(`./TestContract.md`)
			})

			it("SVG", async function () {
				await sclass({
					flags: "-f svg",
				})

				expectToBeSVG(`./TestContract.svg`)
				cleanUpTempFile(`./TestContract.svg`)
			})

			it("PNG", async function () {
				await sclass({
					flags: "-f png",
				})

				expectToBePNG(`./TestContract.png`)
				cleanUpTempFile(`./TestContract.png`)
			})

			it("PDF", async function () {
				await sclass({
					flags: "-f pdf",
				})

				expectToBePDF(`./TestContract.pdf`)
				cleanUpTempFile(`./TestContract.pdf`)
			})
		},
	)

	function cleanUpTempFile(filePath: string) {
		fs.unlinkSync(filePath)
	}
}
