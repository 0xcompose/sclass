"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Contract = exports.StateMutability = exports.Visibility = void 0;
var Visibility;
(function (Visibility) {
    Visibility["external"] = "\u2757";
    Visibility["public"] = "\u2757";
    Visibility["internal"] = "\u2699\uFE0F";
    Visibility["private"] = "\uD83D\uDD12";
})(Visibility || (exports.Visibility = Visibility = {}));
var StateMutability;
(function (StateMutability) {
    StateMutability["mutative"] = "";
    StateMutability["view"] = "\uD83D\uDC40";
    StateMutability["pure"] = "\uD83E\uDDEE";
    StateMutability["constant"] = "\u210F";
    StateMutability["payable"] = "\uD83D\uDCB0";
})(StateMutability || (exports.StateMutability = StateMutability = {}));
const margin = "\t";
class Contract {
    constructor(className) {
        this.className = "Empty";
        this.fields = [];
        this.methods = [];
        this.mappings = [];
        this.className = className;
    }
    addField(field) {
        this.fields.push(field);
    }
    addMethod(method) {
        this.methods.push(method);
    }
    addMapping(mapping) {
        this.mappings.push(mapping);
    }
    toMermaidString(disableFunctionParamType) {
        const start = `${margin}class ${this.className} {\n`;
        /* ====== Insert Fields ====== */
        let fields = "";
        for (const field of this.fields) {
            fields += `${margin}\t${field.visibility} ${field.type} ${field.name}\n`;
        }
        /* ====== Insert Methods ====== */
        let methods = "";
        for (const method of this.methods) {
            const params = this.getParamsString(method.params, disableFunctionParamType);
            methods += `${margin}\t${method.visibility}${method.stateMutability} ${method.name}(${params}) ${method.returnType}\n`;
        }
        /* ====== Insert Mappings ====== */
        let mappings = "";
        for (const mapping of this.mappings) {
            mappings += `${margin}\t${mapping.visibility} mapping(${mapping.key} => ${mapping.value}) ${mapping.name}\n`;
        }
        /* ====== End ====== */
        const end = `${margin}}\n\n`;
        /* ====== Construction ====== */
        return start + fields + mappings + methods + end;
    }
    getParamsString(params, disableFunctionParamType) {
        return params
            .map((param) => (disableFunctionParamType ? "" : param.type + " ") +
            param.name)
            .join(", ");
    }
}
exports.Contract = Contract;
// Testing code
// const contract = new Contract("ContractName")
// contract.addField("uint", "var")
// contract.addField("address", "addr")
// contract.addMethod("getAddress", Visibility.external, "bool")
// console.log(getClassDiagramString([contract]))
//# sourceMappingURL=contract.js.map