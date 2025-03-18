import { TEST_CONTRACT_MERMAID } from "../constants/TestContractMermaid.js"
import { sclass } from "../utils/cli.js"
import { compareMermaidSchemes } from "../utils/compareMermaidSchemes.js"

export function mermaidGenerationTest() {
	it.only("should generate mermaid code", () => {
		const result = sclass()

		compareMermaidSchemes(result, TEST_CONTRACT_MERMAID)
	})
}
