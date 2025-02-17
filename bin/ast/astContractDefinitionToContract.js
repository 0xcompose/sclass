"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.convertContractDefinitionToContract = convertContractDefinitionToContract;
const contract_1 = require("../mermaid/contract");
const filter_1 = require("../utils/filter");
function convertContractDefinitionToContract(astContract, config) {
    const contract = new contract_1.Contract(astContract.name);
    /* ====== Variables ====== */
    const variables = astContract.subNodes.filter((node) => node.type === "StateVariableDeclaration");
    for (const variable of variables) {
        // Special process for mapping
        if (variable.variables[0].typeName?.type === "Mapping") {
            const mapping = parseMapping(variable);
            contract.addMapping(mapping);
            continue;
        }
        contract.addField(parseVariable(variable));
    }
    /* ====== Functions ====== */
    const functions = astContract.subNodes.filter((node) => node.type === "FunctionDefinition");
    for (const func of functions) {
        const method = parseFunction(func);
        if ((0, filter_1.shouldFilterMethod)(method, config))
            continue;
        contract.addMethod(method);
    }
    return contract;
}
function parseMapping(variable) {
    const mapping = variable.variables[0].typeName;
    return {
        name: variable.variables[0].name ?? "empty",
        key: parseTypeName(mapping.keyType),
        value: parseTypeName(mapping.valueType),
        visibility: parseVisibility(variable.variables[0].visibility ?? ""),
    };
}
// Returns name of type, prefers user defined names instead of elementary ones
function parseTypeName(typeName) {
    if (!typeName)
        return "empty";
    switch (typeName.type) {
        case "ElementaryTypeName":
            return typeName.name;
        case "Mapping":
            // Handle mapping with named parameters
            const mapping = typeName;
            const key = parseTypeName(mapping.keyType);
            const value = parseTypeName(mapping.valueType);
            return `mapping(${key} => ${value})`;
        case "UserDefinedTypeName":
            return typeName.namePath;
        case "ArrayTypeName":
            return parseTypeName(typeName.baseTypeName) + "[]";
        default:
            throw new Error(`Unhandled typeName: ${typeName.type}`);
    }
}
function parseVariable(variable) {
    if (variable.variables.length != 1)
        throw Error("More than 1 variable!\n" + JSON.stringify(variable));
    const name = variable.variables[0].name ?? "empty";
    const type = parseTypeName(variable.variables[0].typeName) || "empty";
    const visibility = parseVisibility(variable.variables[0].visibility);
    return { name, type, visibility };
}
function parseFunction(func) {
    /* ====== Name ====== */
    let name = func.name;
    // function name can be null - then it's constructor
    if (!name)
        return null;
    /* ====== Visibility ====== */
    let params = [];
    for (const param of func.parameters) {
        params.push({
            type: parseTypeName(param.typeName),
            name: param.name ?? "empty",
        });
    }
    /* ====== Visibility ====== */
    let visibility = parseVisibility(func.visibility);
    /* ====== Mutability ====== */
    let stateMutability = func.stateMutability === null
        ? contract_1.StateMutability.mutative
        : contract_1.StateMutability[func.stateMutability];
    /* ====== Return Type ====== */
    let returnType = parseFunctionReturnType(func);
    /* ====== Construction ====== */
    const method = {
        name,
        returnType,
        visibility,
        params,
        stateMutability,
    };
    return method;
}
function parseFunctionReturnType(func) {
    if (!func.returnParameters || func.returnParameters.length == 0) {
        return "";
    }
    // Struct
    // named variable
    // unnamed type
    // array
    // Contract Instance
    const returnParams = func.returnParameters;
    let returnType = "";
    for (const param of returnParams) {
        returnType += getReturnTypeName(param) + " ";
    }
    return returnType;
}
function getReturnTypeName(param) {
    // Return positive one
    return (param.name || // Named return params like: returns(uint shares)
        parseTypeName(param.typeName));
}
function parseVisibility(visibility) {
    switch (visibility) {
        case "external":
            return contract_1.Visibility.external;
        case "public":
            return contract_1.Visibility.public;
        case "internal":
            return contract_1.Visibility.internal;
        case "private":
            return contract_1.Visibility.private;
        default:
            return contract_1.Visibility.internal;
    }
}
//# sourceMappingURL=astContractDefinitionToContract.js.map