export interface Field {
	type: string
	name: string
	visibility: Visibility
}

export enum Visibility {
	external = "❗",
	public = "❗",
	internal = "⚙️",
	private = "🔒",
}

export enum StateMutability {
	mutative = "",
	view = "👀",
	pure = "🧮",
	constant = "ℏ",
	payable = "💰",
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
	stateMutability: StateMutability | "mutative"
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
			fields += `${margin}\t${field.visibility} ${field.type} ${field.name}\n`
		}

		/* ====== Insert Methods ====== */

		let methods: string = ""

		for (const method of this.methods) {
			const params = this.getParamsString(
				method.params,
				disableFunctionParamType,
			)

			methods += `${margin}\t${method.visibility}${method.stateMutability} ${method.name}(${params}) ${method.returnType}\n`
		}

		/* ====== Insert Mappings ====== */

		let mappings: string = ""

		for (const mapping of this.mappings) {
			mappings += `${margin}\t${mapping.visibility} mapping(${mapping.key} => ${mapping.value}) ${mapping.name}\n`
		}

		/* ====== End ====== */

		const end = `${margin}}\n\n`

		/* ====== Construction ====== */

		return start + fields + mappings + methods + end
	}

	getParamsString(params: Declaration[], disableFunctionParamType: boolean) {
		return params
			.map(
				(param) =>
					(disableFunctionParamType ? "" : param.type + " ") +
					param.name,
			)
			.join(", ")
	}
}

// Testing code
// const contract = new Contract("ContractName")
// contract.addField("uint", "var")
// contract.addField("address", "addr")
// contract.addMethod("getAddress", Visibility.external, "bool")
// console.log(getClassDiagramString([contract]))
