import { expect } from "chai"

export function compareMermaidSchemes(generated: string, expected: string) {
	const generatedLines = generated.trim().split("\n")
	const expectedLines = expected.trim().split("\n")

	// Log differences in a more readable way

	const maxLines = Math.max(generatedLines.length, expectedLines.length)
	for (let i = 0; i < maxLines; i++) {
		const genLine = generatedLines[i]?.trim() || "<missing>"
		const expLine = expectedLines[i]?.trim() || "<missing>"
		if (genLine !== expLine) {
			console.log(`Line ${i + 1}:`)
			console.log(`  Generated: "${genLine}"`)
			console.log(`  Expected:  "${expLine}"`)
		}
	}

	expect(generatedLines.length).to.eq(
		expectedLines.length,
		"Lines length mismatch",
	)

	for (let i = 0; i < generatedLines.length; i++) {
		expect(generatedLines[i]?.trim()).to.eq(
			expectedLines[i]?.trim(),
			`Mismatch at line ${i + 1}`,
		)
	}
}
