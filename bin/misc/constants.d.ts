export declare const CONTRACTS_DIR = "./contracts";
export declare enum Format {
    MMD = "mmd",
    SVG = "svg",
    PNG = "png",
    PDF = "pdf",
    MD = "md"
}
export declare enum Theme {
    DEFAULT = "default",
    FOREST = "forest",
    DARK = "dark",
    NEUTRAL = "neutral"
}
export declare const HELP_MESSAGE = "\nUsage: sclass [FILE PATH] [OPTIONS]\n\nOptions:\n  --help, -h  Show help\n  --output, -o  Write diagram to file (default is output to stdout)\n  --format, -f  Output format (mmd, svg, png, pdf, md)\n  --theme, -t  Theme for mermaid (default is white)\n\nFile:\n  Path to the .sol file to parse\n";
