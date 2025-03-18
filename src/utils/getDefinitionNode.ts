import { NonterminalNode } from "@nomicfoundation/slang/cst"
import { Definition } from "@nomicfoundation/slang/bindings"
import { ParsedDefinition } from "../parse/types.js"
import { getDefinitionCursor } from "./getDefinitionCursor.js"

export function getDefinitionNode(
	definition: ParsedDefinition<any>,
): NonterminalNode

export function getDefinitionNode(definition: Definition): NonterminalNode

export function getDefinitionNode(
	definition: ParsedDefinition<any> | Definition,
): NonterminalNode {
	// Is ParsedDefinition?
	if ("definition" in definition) {
		const cursor = getDefinitionCursor(definition.definition)
		return cursor.node as NonterminalNode
	}

	const cursor = getDefinitionCursor(definition)
	return cursor.node as NonterminalNode
}
