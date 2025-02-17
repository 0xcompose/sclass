"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.shouldFilterContract = shouldFilterContract;
exports.isContractFromCollections = isContractFromCollections;
exports.shouldFilterMethod = shouldFilterMethod;
const collections_1 = require("../collections");
function shouldFilterContract(node, config) {
    if (node.type !== "ContractDefinition")
        return true;
    /* ====== EXClUDE EXCEPTIONS ====== */
    if (config.excludeContracts.exceptions.includes(node.name))
        return false;
    /* ====== LIBRARY ====== */
    if (config.excludeContracts.libraries && isLibrary(node))
        return true;
    /* ====== INTERFACE ====== */
    if (config.excludeContracts.interfaces && isInterface(node))
        return true;
    /* ====== COLLECTIONS ====== */
    if (isContractFromCollections(node, config))
        return true;
    /* ====== EXCLUDE ====== */
    if (config.excludeContracts.contracts.includes(node.name))
        return true;
    return false;
}
function isContractFromCollections(contract, config) {
    for (const collectionName of config.excludeContracts.collections) {
        // Get absolute path of collections
        const collection = collections_1.collections[collectionName];
        if (collection.includes(contract.name))
            return true;
    }
    return false;
}
function isInterface(node) {
    return node.kind === "interface";
}
function isLibrary(node) {
    return node.kind === "library";
}
function shouldFilterMethod(method, config) {
    // Method is null if constructor
    if (!method)
        return true;
    /* ====== EXCEPTIONS ====== */
    if (config.excludeFunctions.exceptions.includes(method.name))
        return false;
    /* ====== REGEX ====== */
    const regExps = config.excludeFunctions.regExps;
    return regExps.some((regExp) => regExp.test(method.name));
}
//# sourceMappingURL=filter.js.map