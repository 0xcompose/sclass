"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.checkIfContractsExist = checkIfContractsExist;
exports.checkIfCollectionsExist = checkIfCollectionsExist;
const fs_1 = __importDefault(require("fs"));
const constants_1 = require("../misc/constants");
function checkIfContractsExist(contracts) {
    for (const contract of contracts) {
        const path = `${constants_1.CONTRACTS_DIR}/${contract}.sol`;
        if (!fs_1.default.existsSync(path)) {
            throw new Error(`Contract ${contract} does not exist`);
        }
    }
}
function checkIfCollectionsExist(collections) {
    for (const collection of collections) {
        const path = `${constants_1.COLLECTIONS_DIR}/${collection}.json`;
        if (!fs_1.default.existsSync(path)) {
            throw new Error(`Collection ${collection} does not exist`);
        }
    }
}
//# sourceMappingURL=checkers.js.map