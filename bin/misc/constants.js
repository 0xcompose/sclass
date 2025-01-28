"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.HELP_MESSAGE = exports.Theme = exports.Format = exports.COLLECTIONS_DIR = exports.CONTRACTS_DIR = void 0;
exports.CONTRACTS_DIR = "./contracts";
exports.COLLECTIONS_DIR = "./src/collections";
var Format;
(function (Format) {
    Format["MMD"] = "mmd";
    Format["SVG"] = "svg";
    Format["PNG"] = "png";
    Format["PDF"] = "pdf";
    Format["MD"] = "md";
})(Format || (exports.Format = Format = {}));
var Theme;
(function (Theme) {
    Theme["DEFAULT"] = "default";
    Theme["FOREST"] = "forest";
    Theme["DARK"] = "dark";
    Theme["NEUTRAL"] = "neutral";
})(Theme || (exports.Theme = Theme = {}));
exports.HELP_MESSAGE = `
Usage: sol-class [FILE PATH] [OPTIONS]

Options:
  --help, -h  Show help
  --output, -o  Write diagram to file (default is output to stdout)
  --format, -f  Output format (mmd, svg, png, pdf, md)
  --theme, -t  Theme for mermaid (default is white)

File:
  Path to the .sol file to parse
`;
//# sourceMappingURL=constants.js.map