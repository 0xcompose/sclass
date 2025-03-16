import { Definition } from "@nomicfoundation/slang/bindings"

export const CONTRACTS_DIR = "./contracts"
export const COLLECTIONS_DIR = "./collections"

export enum Format {
	MMD = "mmd",
	SVG = "svg",
	PNG = "png",
	PDF = "pdf",
	MD = "md",
}

export enum Theme {
	DEFAULT = "default",
	FOREST = "forest",
	DARK = "dark",
	NEUTRAL = "neutral",
}

export const HELP_MESSAGE = `
Usage: sclass [FILE PATH] [OPTIONS]

Options:
  --help, -h  Show help
  --output, -o  Write diagram to file (default is output to stdout)
  --format, -f  Output format (mmd, svg, png, pdf, md)
  --theme, -t  Theme for mermaid (default is white)

File:
  Path to the .sol file to parse
`

export enum DefinitionKind {
	// Contract-level definitions
	Contract = "ContractDefinition",
	Interface = "InterfaceDefinition",
	Library = "LibraryDefinition",

	// Contract member definitions
	Function = "FunctionDefinition",
	Constructor = "ConstructorDefinition",
	Receive = "ReceiveFunctionDefinition",
	Fallback = "FallbackFunctionDefinition",
	Modifier = "ModifierDefinition",
	StateVariable = "StateVariableDefinition",

	// Function parameters
	Parameter = "Parameter",

	// Type definitions
	Struct = "StructDefinition",
	Enum = "EnumDefinition",
	UserDefinedValueType = "UserDefinedValueTypeDefinition",

	// Event and error definitions
	Event = "EventDefinition",
	Error = "ErrorDefinition",
}
