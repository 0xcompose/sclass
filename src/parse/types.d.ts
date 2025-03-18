import type { NonterminalKind } from "@nomicfoundation/slang/cst"
import type { Definition } from "@nomicfoundation/slang/bindings"

interface ParsedDefinition<K extends keyof typeof NonterminalKind> {
	name: string
	kind: K
	definition: Definition
}

type ParsedContractDefinition = ParsedDefinition<"ContractDefinition"> & {
	variables: ParsedStateVariableDefinition[]
	functions: ParsedFunctionDefinition[]
	inheritsFrom: Definition[]
}

type ParsedInterfaceDefinition = ParsedDefinition<"InterfaceDefinition"> & {
	functions: ParsedFunctionDefinition[]
	inheritsFrom: Definition[]
}

type ParsedLibraryDefinition = ParsedDefinition<"LibraryDefinition"> & {
	functions: ParsedFunctionDefinition[]
}

type ParsedStateVariableDefinition = ParsedDefinition<"StateVariableDefinition">

// Input and Output parameters are accesses via node unparse()
// that's why we don't need to parse them!
type ParsedFunctionDefinition = ParsedDefinition<"FunctionDefinition">

type ParsedParameterDefinition = ParsedDefinition<"Parameter"> & {
	type: string
}
