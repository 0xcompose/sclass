import path from "path"
import { Config } from "../config.js"
import { Contract } from "./contract.js"

function getDiagramTemplate(): string {
	const inputContractFilePath = Config.inputContractFilePath

	const fileName = path.basename(inputContractFilePath).split(".")[0]

	return `
---
title: ${fileName} Class Diagram
---
classDiagram

`
}

export function getClassDiagramString(
	classes: Contract[],
	relations: string[],
): string {
	const disableFunctionParamType = Config.disableFunctionParamType

	let str = getDiagramTemplate()

	for (const contract of classes) {
		str += contract.toMermaidString(disableFunctionParamType)
	}

	for (const relation of relations) {
		str += `\n\n${relation}`
	}

	return str
}
