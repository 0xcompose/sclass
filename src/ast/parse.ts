import * as parser from "@solidity-parser/parser"

export function parse(solidityFileContent: string) {
    try {
        // Doesn't parse structs outside of contracts
        const ast = parser.parse(solidityFileContent)
        return ast
    } catch (e) {
        console.error(e)
        if (e instanceof parser.ParserError) {
            console.error(e.errors)
        }
        throw e
    }
}
