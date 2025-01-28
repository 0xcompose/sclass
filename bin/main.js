"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.parseContracts = parseContracts;
exports.readFileAndParse = readFileAndParse;
const astContractDefinitionToContract_1 = require("./ast/astContractDefinitionToContract");
const parser_1 = require("@solidity-parser/parser");
const diagram_1 = require("./mermaid/diagram");
const filter_1 = require("./utils/filter");
const child_process_1 = require("child_process");
const util_1 = require("util");
async function parseContracts(config) {
    /* ======= READ FILES ======= */
    const contracts = await readFileAndParse(config.inputContractFilePath);
    /* ======= FILTER ======= */
    const filteredContracts = [];
    const excludedContractNames = new Map();
    for (const contract of contracts) {
        const shouldFilter = (0, filter_1.shouldFilterContract)(contract, config);
        if (!shouldFilter)
            filteredContracts.push(contract);
        else
            excludedContractNames.set(contract.name, true);
    }
    /* ======= PARSE CONTRACTS ======= */
    let parsedContracts = [];
    for (const contract of filteredContracts) {
        if (parsedContracts.find((c) => c.className === contract.name))
            continue;
        parsedContracts.push((0, astContractDefinitionToContract_1.convertContractDefinitionToContract)(contract, config));
    }
    /* ======= PARSE INHERITANCE ======= */
    let relations = [];
    for (const contract of filteredContracts) {
        for (const base of contract.baseContracts) {
            if (excludedContractNames.get(base.baseName.namePath))
                continue;
            const relationStr = `\t${base.baseName.namePath} <|-- ${contract.name}`;
            if (relations.includes(relationStr))
                continue;
            relations.push(relationStr);
        }
    }
    // /* ======= DIAGRAM ======= */
    const diagram = (0, diagram_1.getClassDiagramString)(parsedContracts, relations, config.disableFunctionParamType);
    return diagram;
}
async function readFileAndParse(filePath) {
    const contracts = [];
    // const path = filePath
    const execAsync = (0, util_1.promisify)(child_process_1.exec);
    const { stdout, stderr } = await execAsync(`forge flatten ${filePath}`);
    // const buffer = fs.readFileSync(path)
    const solidityCode = stdout;
    let ast = (0, parser_1.parse)(solidityCode);
    // console.log(`Parsed ${file}`)
    // console.log(inspect(ast, { depth: 10 }))
    contracts.push(...ast.children);
    return contracts;
}
//# sourceMappingURL=main.js.map