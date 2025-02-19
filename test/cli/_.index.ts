import { makeSuite } from "../utils/makeSuite"
import { helpFlagTest } from "./help"
import { mermaidGenerationTest } from "./mermaid"

makeSuite("cli", () => {
	makeSuite("mermaid generation", mermaidGenerationTest)
	makeSuite("help flag", helpFlagTest)
})
