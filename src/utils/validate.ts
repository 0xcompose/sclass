import { Field, Mapping, Method, Visibility } from "../mermaid/contract"
import pc from "picocolors"

const warn = "[WARN]"

export function validateFunction(method: Method) {
    if (method.visibility === Visibility.internal && method.name[0] !== "_") {
        const warnStr = `\n${warn} Internal function with name not starting with '_', function name: ${method.name}\n`

        console.warn(pc.bold(pc.yellow(warnStr)))
    }
}

export function validateMapping(mapping: Mapping) {
    if (mapping.visibility === Visibility.internal && mapping.name[0] !== "_") {
        const warnStr = `\n${warn} Internal mapping with name not starting with '_', function name: ${mapping.name}\n`

        console.warn(pc.bold(pc.yellow(warnStr)))
    }
}

export function validateVariable(field: Field) {
    if (field.visibility === Visibility.internal && field.name[0] !== "_") {
        const warnStr = `\n${warn} Internal variable with name not starting with '_', function name: ${field.name}\n`

        console.warn(pc.bold(pc.yellow(warnStr)))
    }
}
