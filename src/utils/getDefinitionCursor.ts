import {
	assertUserFileLocation,
	Definition,
} from "@nomicfoundation/slang/bindings"
import { Cursor } from "@nomicfoundation/slang/cst"

export function getDefinitionCursor(definition: Definition): Cursor {
	const location = definition.definiensLocation.asUserFileLocation()

	assertUserFileLocation(location)

	return location.cursor
}
