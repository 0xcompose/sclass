import { Definition } from "@nomicfoundation/slang/bindings"

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

export interface Method {
	visibility: Visibility
	name: string
	params: string
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
	inheritsFrom: Definition[] = []

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
			methods += `${margin}\t${method.visibility}${method.stateMutability} ${method.name}${method.params} ${method.returnType}\n`
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

	addInheritance(definitions: Definition[]) {
		this.inheritsFrom.push(...definitions)
	}
}
