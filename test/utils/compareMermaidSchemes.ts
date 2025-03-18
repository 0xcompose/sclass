import { expect } from "chai"

export function compareMermaidSchemes(generated: string, expected: string) {
	const generatedLines = generated.trim().split("\n")
	const expectedLines = expected.trim().split("\n")

	console.log(generatedLines)
	console.log(expectedLines)

	expect(generatedLines.length).to.eq(
		expectedLines.length,
		"Lines length mismatch",
	)

	for (let i = 0; i < generatedLines.length; i++) {
		expect(generatedLines[i]?.trim()).to.eq(expectedLines[i]?.trim())
	}
}
