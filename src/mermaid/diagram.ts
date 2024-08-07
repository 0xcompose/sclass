import { Contract } from "./contract"

const classDiagram = `
---
title: Testing generation of schemes
---
classDiagram

`
export function getClassDiagramString(
    classes: Contract[],
    relations: string[],
    disableFunctionParamType: boolean
) {
    let str = classDiagram

    for (const contract of classes) {
        str += contract.toMermaidString(disableFunctionParamType)
    }

    for (const relation of relations) {
        str += `\n\n${relation}`
    }

    return str
}
