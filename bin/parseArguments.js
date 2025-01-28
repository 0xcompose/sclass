"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.parseArguments = parseArguments;
const constants_1 = require("./misc/constants");
const fs_1 = __importDefault(require("fs"));
function parseArguments(config) {
    // Skip node and script path
    const [, , ...args] = process.argv;
    // If help flag is provided, print help message and exit
    if (containsHelpFlag(args)) {
        console.log(constants_1.HELP_MESSAGE);
        process.exit(0);
    }
    const [smartContractFilePath, ...additionalArgs] = args;
    // Parse first argument - smart contract file path
    // Validate smart contract file path
    if (!isSolidityFile(smartContractFilePath)) {
        throw new Error("Invalid .sol file path");
    }
    config.inputContractFilePath = smartContractFilePath;
    // Parse pairs of arguments
    for (let i = 0; i < additionalArgs.length; i += 2) {
        const arg = additionalArgs[i];
        const nextArg = additionalArgs[i + 1];
        parsePairOfArguments(config, arg, nextArg);
    }
}
function parsePairOfArguments(config, arg, nextArg) {
    if (!nextArg)
        throw new Error(`Missing value for argument: ${arg}`);
    switch (arg) {
        case "--output":
        case "-o":
            config.output.filePath = nextArg;
            break;
        case "--format":
        case "-f":
            config.output.format = parseFormat(nextArg);
            break;
        case "--theme":
        case "-t":
            config.output.theme = parseTheme(nextArg);
            break;
    }
}
function parseTheme(value) {
    const isTheme = Object.values(constants_1.Theme).includes(value);
    if (!isTheme)
        throw new Error(`Invalid theme: ${value}`);
    return value;
}
function parseFormat(value) {
    const isFormat = Object.values(constants_1.Format).includes(value);
    if (!isFormat)
        throw new Error(`Invalid format: ${value}`);
    return value;
}
function isSolidityFile(filePath) {
    // Validate file path
    if (!filePath.endsWith(".sol"))
        return false;
    // Validate file exists
    if (!fs_1.default.existsSync(filePath))
        return false;
    return true;
}
function containsHelpFlag(args) {
    return args.includes("--help") || args.includes("-h");
}
//# sourceMappingURL=parseArguments.js.map