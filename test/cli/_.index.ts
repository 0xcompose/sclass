import { makeSuite } from "../utils/makeSuite"
import { helpFlagTest } from "./help"
import { mermaidGenerationTest } from "./mermaid"
import { formatTest } from "./format"
import { outputTest } from "./output"

makeSuite("cli", () => {
	makeSuite("mermaid generation", mermaidGenerationTest)
	makeSuite("help flag", helpFlagTest)
	makeSuite("format", formatTest)
	makeSuite("output", outputTest)
})
