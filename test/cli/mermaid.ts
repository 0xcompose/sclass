import { TEST_CONTRACT_MERMAID } from "../constants/TestContractMermaid"
import { sclass } from "../utils/cli"
import { compareMermaidSchemes } from "../utils/compareMermaidSchemes"

export function mermaidGenerationTest() {
	it("should generate mermaid code", () => {
		const result = sclass()

		compareMermaidSchemes(result, TEST_CONTRACT_MERMAID)
	})
}
