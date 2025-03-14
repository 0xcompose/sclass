import fs from "fs"
import {
	CompilationBuilder,
	CompilationUnit,
} from "@nomicfoundation/slang/compilation"
import { assertNonterminalNode } from "@nomicfoundation/slang/cst"
import assert from "assert"
import { NonterminalKind } from "@nomicfoundation/slang/cst"

export async function buildCompilationUnit(
	fileId: string,
): Promise<CompilationUnit> {
	const builder = CompilationBuilder.create({
		languageVersion: "0.8.28",
		readFile,
		resolveImport,
	})
	console.log("Adding file", fileId)
	await builder.addFile(fileId)
	console.log("Building compilation unit")

	const unit = builder.build()

	const files = unit.files()

	assert.equal(files.length, 1)

	assert.equal(files[0].id, "test/constants/TestContract.sol")
	assertNonterminalNode(files[0].tree, NonterminalKind.SourceUnit)

	return unit
}

// TODO: Implement to support non flattened files
function resolveImport(importPath: string) {
	console.log("Resolving import path", importPath)
	return undefined
}

async function readFile(filePath: string): Promise<string> {
	console.log(filePath)
	console.log(fs.readFileSync(filePath, "utf-8"))
	return fs.readFileSync(filePath, "utf-8")
}
