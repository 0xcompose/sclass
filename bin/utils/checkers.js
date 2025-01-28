"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.checkIfCollectionsExist = checkIfCollectionsExist;
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
function checkIfCollectionsExist(collections) {
    for (const collection of collections) {
        // Get absolute path of collections
        const pathToCollection = path_1.default.join(process.cwd(), "collections", `${collection}.json`);
        if (!fs_1.default.existsSync(pathToCollection)) {
            throw new Error(`Collection ${collection} does not exist`);
        }
    }
}
//# sourceMappingURL=checkers.js.map