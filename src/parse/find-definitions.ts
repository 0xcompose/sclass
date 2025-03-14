import assert from "node:assert"
import {
	assertTerminalNode,
	TerminalKindExtensions,
} from "@nomicfoundation/slang/cst"
import { CompilationUnit } from "@nomicfoundation/slang/compilation"
import {
	assertUserFileLocation,
	Definition,
} from "@nomicfoundation/slang/bindings"

export function findDefinitionsInFile(
	unit: CompilationUnit,
	fileId: string,
): Definition[] {
	console.log(fileId)
	console.log(JSON.stringify(unit.files(), null, 4))
	console.log(unit.file(fileId))
	console.log(unit.files())
	const file = unit.file(fileId)

	assert(file)

	const definitions: Definition[] = []

	// traverse the file's CST tree looking for identifiers
	const cursor = file.createTreeCursor()

	while (cursor.goToNextTerminal()) {
		assertTerminalNode(cursor.node)
		console.log("Unparsed node", cursor.node.unparse())
		if (!TerminalKindExtensions.isIdentifier(cursor.node.kind)) {
			continue
		}

		// attempt to resolve a definition
		const definition = unit.bindingGraph.definitionAt(cursor)

		if (definition) {
			// name should be located in the file we queried
			assertUserFileLocation(definition.nameLocation)
			assert.strictEqual(definition.nameLocation.fileId, fileId)

			// definiens should too be located in the file we queried
			assertUserFileLocation(definition.definiensLocation)
			assert.strictEqual(definition.definiensLocation.fileId, fileId)

			definitions.push(definition)
		}
	}

	return definitions
}
