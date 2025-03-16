import { Definition } from "@nomicfoundation/slang/bindings"

export function getDefinitionName(definition: Definition): string {
	const cursor = definition.nameLocation.asUserFileLocation().cursor

	return cursor.node.unparse()
}
