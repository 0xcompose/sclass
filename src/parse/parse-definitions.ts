import { assertUserFileLocation } from "@nomicfoundation/slang/bindings"

import { Definition } from "@nomicfoundation/slang/bindings"

export interface ParsedDefinition {
	name: string
	kind: string
	definition: Definition
}

export function parseDefinitions(
	definitions: Definition[],
): ParsedDefinition[] {
	const found: ParsedDefinition[] = []

	for (const definition of definitions) {
		assertUserFileLocation(definition.nameLocation)
		const name = definition.nameLocation.cursor.node.unparse()

		assertUserFileLocation(definition.definiensLocation)
		const kind = definition.definiensLocation.cursor.node.kind

		found.push({ name, kind, definition })
	}

	return found
}
