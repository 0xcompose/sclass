import { getClassDiagramString } from "./diagram"

export interface Field {
    type: string
    name: string
    visibility: Visibility
}

export enum Visibility {
    external = "+",
    public = "+",
    internal = "-",
    private = "#",
}

export interface Declaration {
    type: string
    name: string
}

export interface Method {
    visibility: Visibility
    name: string
    params: Declaration[]
    returnType: string
}

export interface Mapping {
    key: string
    value: string
    name: string
    visibility: Visibility
}

const margin = "\t"

export class Contract {
    className: string = "Empty"
    fields: Field[] = []
    methods: Method[] = []
    mappings: Mapping[] = []

    constructor(className: string) {
        this.className = className
    }

    addField(field: Field) {
        this.fields.push(field)
    }

    addMethod(method: Method) {
        this.methods.push(method)
    }

    addMapping(mapping: Mapping) {
        this.mappings.push(mapping)
    }

    toMermaidString(disableFunctionParamType: boolean) {
        const start = `${margin}class ${this.className} {\n`

        /* ====== Insert Fields ====== */
        let fields: string = ""

        for (const field of this.fields) {
            fields +=
                margin + `\t${field.visibility}${field.type} ${field.name}\n`
        }

        /* ====== Insert Methods ====== */

        let methods: string = ""

        for (const method of this.methods) {
            const params = method.params
                .map(
                    (param) =>
                        (disableFunctionParamType ? "" : param.type + " ") +
                        param.name
                )
                .join(", ")

            methods +=
                margin +
                `\t${method.visibility}${method.name}(${params}) ${method.returnType}\n`
        }

        /* ====== Insert Mappings ====== */

        let mappings: string = ""

        for (const mapping of this.mappings) {
            mappings +=
                margin +
                `\t${mapping.visibility}mapping(${mapping.key} => ${mapping.value}) ${mapping.name}\n`
        }

        /* ====== End ====== */

        const end = `${margin}}\n\n`

        /* ====== Construction ====== */

        return start + fields + mappings + methods + end
    }
}

// Testing code
// const contract = new Contract("ContractName")
// contract.addField("uint", "var")
// contract.addField("address", "addr")
// contract.addMethod("getAddress", Visibility.external, "bool")
// console.log(getClassDiagramString([contract]))
