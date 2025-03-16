import { DefinitionKind } from "../misc/constants.js"
import { ParsedDefinition } from "./parse-definitions.js"

const definitionKindsToInclude = [
	DefinitionKind.Contract,
	DefinitionKind.Interface,
	DefinitionKind.Library,
	DefinitionKind.Function,
	DefinitionKind.Receive,
	DefinitionKind.Fallback,
	DefinitionKind.StateVariable,
	// DefinitionKind.Struct,
	DefinitionKind.Parameter,
]

export function filterDefinitions(definitions: ParsedDefinition[]) {
	return definitions.filter((definition) => {
		return definitionKindsToInclude.includes(
			definition.kind as DefinitionKind,
		)
	})
}
