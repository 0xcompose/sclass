import {
	Definition,
	assertUserFileLocation,
} from "@nomicfoundation/slang/bindings"
import {
	assertTerminalNode,
	Cursor,
	NonterminalKind,
	NonterminalNode,
	TerminalKindExtensions,
} from "@nomicfoundation/slang/cst"
import { CompilationUnit } from "@nomicfoundation/slang/compilation"
import { assert } from "chai"

/* ====== FINDERS ====== */

export function findDefinitionsInFile(
	unit: CompilationUnit,
	fileId: string,
): Definition[] {
	const file = unit.file(fileId)

	assert(file, `File with id ${fileId} not found`)

	const definitions: Definition[] = []

	// traverse the file's CST tree looking for identifiers
	const cursor = file.createTreeCursor()

	while (cursor.goToNextTerminal()) {
		assertTerminalNode(cursor.node)

		const isIdentifier = TerminalKindExtensions.isIdentifier(
			cursor.node.kind,
		)

		if (!isIdentifier) continue

		// attempt to resolve a definition
		const definition = unit.bindingGraph.definitionAt(cursor)

		if (!definition) continue

		// name should be located in the file we queried
		assertUserFileLocation(definition.nameLocation)
		assert.strictEqual(definition.nameLocation.fileId, fileId)

		// definiens should too be located in the file we queried
		assertUserFileLocation(definition.definiensLocation)
		assert.strictEqual(definition.definiensLocation.fileId, fileId)
		definition.definiensLocation.cursor

		definitions.push(definition)
	}

	return definitions
}

export function findDefinitionsOfKindsInFile(
	unit: CompilationUnit,
	fileId: string,
	definitionKinds: NonterminalKind[],
): Definition[] {
	const file = unit.file(fileId)

	assert(file, `File with id ${fileId} not found`)

	const definitions: Definition[] = []

	// traverse the file's CST tree looking for identifiers
	const cursor = file.createTreeCursor()

	while (cursor.goToNextTerminal()) {
		assertTerminalNode(cursor.node)

		const isIdentifier = TerminalKindExtensions.isIdentifier(
			cursor.node.kind,
		)

		if (!isIdentifier) continue

		// attempt to resolve a definition
		const definition = unit.bindingGraph.definitionAt(cursor)

		if (!definition) continue

		const kind = getDefinitionKind(definition)

		if (!definitionKinds.includes(kind)) continue

		// name should be located in the file we queried
		assertUserFileLocation(definition.nameLocation)
		assert.strictEqual(definition.nameLocation.fileId, fileId)

		// definiens should too be located in the file we queried
		assertUserFileLocation(definition.definiensLocation)
		assert.strictEqual(definition.definiensLocation.fileId, fileId)
		definition.definiensLocation.cursor

		definitions.push(definition)
	}

	return definitions
}

/* ====== GETTERS ====== */

export function getDefinitionCursor(definition: Definition): Cursor {
	const location = definition.definiensLocation.asUserFileLocation()

	assertUserFileLocation(location)

	return location.cursor
}

export function getDefinitionKind(definition: Definition): NonterminalKind {
	const cursor = definition.definiensLocation.asUserFileLocation().cursor

	return cursor.node.kind as NonterminalKind
}

export function getDefinitionName(definition: Definition): string {
	const cursor = definition.nameLocation.asUserFileLocation().cursor

	return cursor.node.unparse()
}

export function getDefinitionNode(definition: Definition): NonterminalNode {
	const cursor = getDefinitionCursor(definition)

	return cursor.node as NonterminalNode
}
