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
