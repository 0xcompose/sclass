import { Definition } from "@nomicfoundation/slang/bindings"
import { NonterminalKind } from "@nomicfoundation/slang/cst"

export function getDefinitionKind(definition: Definition): NonterminalKind {
	const cursor = definition.definiensLocation.asUserFileLocation().cursor

	return cursor.node.kind as NonterminalKind
}
