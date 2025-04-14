import { TEST_CONTRACT_MERMAID } from "../constants/TestContractMermaid.js"
import { sclass } from "../utils/cli.js"
import { compareMermaidSchemes } from "../utils/compareMermaidSchemes.js"

export function mermaidGenerationTest() {
	it("should generate mermaid code", async () => {
		const result = await sclass()

		compareMermaidSchemes(result.stdout, TEST_CONTRACT_MERMAID)
	})
}
