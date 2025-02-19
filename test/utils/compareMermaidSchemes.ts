import { expect } from "chai"

export function compareMermaidSchemes(generated: string, expected: string) {
	const generatedLines = generated.trim().split("\n")
	const expectedLines = expected.trim().split("\n")

	for (let i = 0; i < generatedLines.length; i++) {
		expect(generatedLines[i]?.trim()).to.eq(expectedLines[i]?.trim())
	}
}
