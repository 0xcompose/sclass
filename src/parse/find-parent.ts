import { Cursor } from "@nomicfoundation/slang/cst"
import { DefinitionKind } from "../misc/constants.js"
import { ParsedDefinition } from "./parse-definitions.js"
import { CompilationUnit } from "@nomicfoundation/slang/compilation"

const DefinitionParents = {
	[DefinitionKind.Contract]: null,
	[DefinitionKind.Interface]: null,
	[DefinitionKind.Library]: null,
	[DefinitionKind.Function]: DefinitionKind.Contract,
	[DefinitionKind.Receive]: DefinitionKind.Contract,
	[DefinitionKind.Fallback]: DefinitionKind.Contract,
	[DefinitionKind.StateVariable]: DefinitionKind.Contract,
	[DefinitionKind.Parameter]: DefinitionKind.Function,
}

export function findParent(
	unit: CompilationUnit,
	parsedDefinition: ParsedDefinition,
): ParsedDefinition | undefined {
	const userFileLocation =
		parsedDefinition.definition.definiensLocation.asUserFileLocation()
	const cursor: Cursor = userFileLocation.cursor

	if (DefinitionParents[parsedDefinition.kind] === null) return

	while (cursor.goToParent()) {
		const parentDefinition = unit.bindingGraph.definitionAt(cursor)

		// const parsedDefinitions =
	}
}
