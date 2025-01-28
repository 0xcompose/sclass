"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.config = void 0;
const constants_1 = require("./misc/constants");
exports.config = {
    inputContractFilePath: "",
    excludeContracts: {
        interfaces: true,
        libraries: false,
        collections: ["layerzero", "common-utils", "openzeppelin"],
        contracts: ["Excluded"],
        exceptions: ["Relayer"],
    },
    excludeFunctions: {
        regExps: [/.*reg.*/i],
        exceptions: ["exceptionRegExp"],
    },
    output: {
        filePath: "",
        format: constants_1.Format.MMD,
        theme: constants_1.Theme.DEFAULT,
    },
    disableFunctionParamType: false,
};
//# sourceMappingURL=config.js.map