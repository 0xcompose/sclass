"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.collections = void 0;
const layerzero_json_1 = __importDefault(require("../collections/layerzero.json"));
const openzeppelin_json_1 = __importDefault(require("../collections/openzeppelin.json"));
const common_utils_json_1 = __importDefault(require("../collections/common-utils.json"));
const stargate_json_1 = __importDefault(require("../collections/stargate.json"));
exports.collections = {
    layerzero: layerzero_json_1.default,
    openzeppelin: openzeppelin_json_1.default,
    "common-utils": common_utils_json_1.default,
    stargate: stargate_json_1.default,
};
//# sourceMappingURL=collections.js.map