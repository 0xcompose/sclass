import { assertUserFileLocation } from "@nomicfoundation/slang/bindings"
import { getDefinitionName } from "../utils/getDefinitionName.js"
import { getDefinitionKind } from "../utils/getDefinitionKind.js"
import { Definition } from "@nomicfoundation/slang/bindings"
import { ParsedDefinition } from "./types.js"
import { NonterminalKind } from "@nomicfoundation/slang/cst"

export function parseDefinitions(
	definitions: Definition[],
): ParsedDefinition<NonterminalKind>[] {
	const found: ParsedDefinition<NonterminalKind>[] = []

	for (const definition of definitions) {
		assertUserFileLocation(definition.nameLocation)
		assertUserFileLocation(definition.definiensLocation)

		const name = getDefinitionName(definition)
		const kind = getDefinitionKind(definition)

		found.push({ name, kind, definition })
	}

	return found
}
