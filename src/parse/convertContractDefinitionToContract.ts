import {
	ContractDefinition,
	FunctionDefinition,
	StateVariableDeclaration,
	TypeName,
	VariableDeclaration,
} from "@solidity-parser/parser/dist/src/ast-types"
import {
	Contract,
	Field,
	Visibility,
	Method,
	Mapping,
	Declaration,
	StateMutability,
} from "../mermaid/contract"
import { shouldFilterMethod } from "../utils/filter.js"

export function convertContractDefinitionToContract(
	astContract: ContractDefinition,
): Contract {
	const contract = new Contract(astContract.name)

	/* ====== Variables ====== */

	const variables = astContract.subNodes.filter(
		(node) => node.type === "StateVariableDeclaration",
	) as StateVariableDeclaration[]

	for (const variable of variables) {
		// Special process for mapping

		if (variable.variables[0].typeName?.type === "Mapping") {
			const mapping = parseMapping(variable)
			contract.addMapping(mapping)
			continue
		}

		contract.addField(parseVariable(variable))
	}

	/* ====== Functions ====== */

	const functions = astContract.subNodes.filter(
		(node) => node.type === "FunctionDefinition",
	) as FunctionDefinition[]

	for (const func of functions) {
		const method = parseFunction(func)

		if (shouldFilterMethod(method)) continue

		contract.addMethod(method)
	}

	return contract
}

function parseMapping(variable: StateVariableDeclaration): Mapping {
	const mapping = variable.variables[0].typeName as MappingType

	return {
		name: variable.variables[0].name ?? "empty",
		key: parseTypeName(mapping.keyType),
		value: parseTypeName(mapping.valueType),
		visibility: parseVisibility(variable.variables[0].visibility ?? ""),
	}
}

// Returns name of type, prefers user defined names instead of elementary ones
function parseTypeName(typeName: TypeName | null): string {
	if (!typeName) return "empty"

	switch (typeName.type) {
		case "ElementaryTypeName":
			return typeName.name

		case "Mapping":
			// Handle mapping with named parameters
			const mapping = typeName as MappingType
			const key = parseTypeName(mapping.keyType)
			const value = parseTypeName(mapping.valueType)
			return `mapping(${key} => ${value})`

		case "UserDefinedTypeName":
			return typeName.namePath

		case "ArrayTypeName":
			return parseTypeName(typeName.baseTypeName) + "[]"

		default:
			throw new Error(`Unhandled typeName: ${typeName.type}`)
	}
}

function parseVariable(variable: StateVariableDeclaration): Field {
	if (variable.variables.length != 1)
		throw Error("More than 1 variable!\n" + JSON.stringify(variable))

	const name = variable.variables[0].name ?? "empty"
	const type = parseTypeName(variable.variables[0].typeName) || "empty"
	const visibility = parseVisibility(variable.variables[0].visibility)

	return { name, type, visibility }
}

function parseFunction(func: FunctionDefinition): Method | null {
	/* ====== Name ====== */
	let name = func.name

	// function name can be null - then it's constructor
	if (!name) return null

	/* ====== Visibility ====== */

	let params: Declaration[] = []

	for (const param of func.parameters) {
		params.push({
			type: parseTypeName(param.typeName),
			name: param.name ?? "empty",
		})
	}

	/* ====== Visibility ====== */

	let visibility: Visibility = parseVisibility(func.visibility)

	/* ====== Mutability ====== */

	let stateMutability =
		func.stateMutability === null
			? StateMutability.mutative
			: StateMutability[func.stateMutability]

	/* ====== Return Type ====== */

	let returnType = parseFunctionReturnType(func)

	/* ====== Construction ====== */

	const method: Method = {
		name,
		returnType,
		visibility,
		params,
		stateMutability,
	}

	return method
}

function parseFunctionReturnType(func: FunctionDefinition): string {
	if (!func.returnParameters || func.returnParameters.length == 0) {
		return ""
	}

	// Struct
	// named variable
	// unnamed type
	// array
	// Contract Instance
	const returnParams = func.returnParameters

	let returnType = ""

	for (const param of returnParams) {
		returnType += getReturnTypeName(param) + " "
	}

	return returnType
}

function getReturnTypeName(param: VariableDeclaration): string {
	// Return positive one
	return (
		param.name || // Named return params like: returns(uint shares)
		parseTypeName(param.typeName)
	)
}

function parseVisibility(visibility: string | undefined): Visibility {
	switch (visibility) {
		case "external":
			return Visibility.external
		case "public":
			return Visibility.public
		case "internal":
			return Visibility.internal
		case "private":
			return Visibility.private
		default:
			return Visibility.internal
	}
}
