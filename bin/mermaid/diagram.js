"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getClassDiagramString = getClassDiagramString;
const config_1 = require("../config");
const classDiagram = `
---
title: ${config_1.config.inputContractFilePath} Class Diagram
---
classDiagram

`;
function getClassDiagramString(classes, relations, disableFunctionParamType) {
    let str = classDiagram;
    for (const contract of classes) {
        str += contract.toMermaidString(disableFunctionParamType);
    }
    for (const relation of relations) {
        str += `\n\n${relation}`;
    }
    return str;
}
//# sourceMappingURL=diagram.js.map