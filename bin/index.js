#!/usr/bin/env node
"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const child_process_1 = require("child_process");
const util_1 = require("util");
const picocolors_1 = __importDefault(require("picocolors"));
const main_1 = require("./main");
const config_1 = require("./config");
const constants_1 = require("./misc/constants");
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
const parseArguments_1 = require("./parseArguments");
const execAsync = (0, util_1.promisify)(child_process_1.exec);
async function main() {
    console.time("Total Execution Time");
    (0, parseArguments_1.parseArguments)(config_1.config);
    const diagram = (await (0, main_1.parseContracts)(config_1.config)).trim();
    switch (config_1.config.output.format) {
        case constants_1.Format.MMD:
            if (config_1.config.output.filePath.length > 0) {
                writeToFile(diagram, config_1.config.output.filePath);
            }
            else {
                console.log(diagram);
            }
            break;
        default:
            await generatePictureFile(diagram, config_1.config.output);
            break;
    }
    console.log();
    console.timeEnd("Total Execution Time");
}
async function generatePictureFile(diagram, output) {
    const { filePath, theme } = output;
    const { stderr } = await execAsync(`echo "${diagram}" | npx mmdc --input - --output ${filePath} --theme ${theme}`);
    if (stderr)
        console.error(picocolors_1.default.yellow(stderr));
}
async function writeToFile(content, outputFilePath) {
    const filePath = outputFilePath || "diagram.mmd";
    // Ensure directory exists
    const dir = path_1.default.dirname(filePath);
    if (!fs_1.default.existsSync(dir)) {
        fs_1.default.mkdirSync(dir, { recursive: true });
    }
    fs_1.default.writeFileSync(filePath, content);
}
main();
//# sourceMappingURL=index.js.map