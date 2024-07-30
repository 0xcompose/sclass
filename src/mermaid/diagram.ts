import { Contract } from "./contract"

const classDiagram = `
---
title: Testing generation of schemes
---
classDiagram

`
export function getClassDiagramString(
    classes: Contract[],
    disableFunctionParamType: boolean
) {
    let str = classDiagram
    for (const contract of classes) {
        str += contract.toMermaidString(disableFunctionParamType)
    }

    return str
}
