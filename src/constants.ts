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
  /* ====== COMMON OPTIONS ====== */

  --help    [-h]  Show help
  --output  [-o]  Write diagram to file (default is output to stdout)
  --format  [-f]  Output format (mmd, svg, png, pdf, md)
  --theme   [-t]  Theme for mermaid (default is white)
  
  /* ====== EXCLUDE OPTIONS ====== */

  --exclude [-e]  Exclude contracts from diagram (f.e. --exclude ["Contract1", "Contract2"])
  --include [-i]  Include contracts to diagram (f.e. --include ["Contract1", "Contract2"])
  
  --exclude-interfaces [-ei]  Exclude interfaces from diagram
  --exclude-libraries  [-el]  Exclude libraries from diagram
  --exclude-functions  [-ef]  Exclude functions from diagram, takes RegExp as an argument

  /* ====== COLLECTIONS OPTIONS ====== */

  --collections [-c]  Show collections

File:
  Path to the .sol file to parse
`
