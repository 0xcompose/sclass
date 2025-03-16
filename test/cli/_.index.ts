import { makeSuite } from "../utils/makeSuite.js"
import { helpFlagTest } from "./help.js"
import { mermaidGenerationTest } from "./mermaid.js"
import { formatTest } from "./format.js"
import { outputTest } from "./output.js"

makeSuite("cli", () => {
	makeSuite("mermaid generation", mermaidGenerationTest)
	makeSuite("help flag", helpFlagTest)
	makeSuite("format", formatTest)
	makeSuite("output", outputTest)
})
