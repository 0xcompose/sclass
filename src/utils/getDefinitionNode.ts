import { NonterminalNode } from "@nomicfoundation/slang/cst"
import { ParsedDefinition } from "../parse/types.js"
import { getDefinitionCursor } from "./getDefinitionCursor.js"

export function getDefinitionNode(definition: ParsedDefinition<any>) {
	const cursor = getDefinitionCursor(definition.definition)
	return cursor.node as NonterminalNode
}
