import fs from "fs"
import {
	CompilationBuilder,
	CompilationUnit,
} from "@nomicfoundation/slang/compilation"
import { assertNonterminalNode } from "@nomicfoundation/slang/cst"
import assert from "assert"
import { NonterminalKind } from "@nomicfoundation/slang/cst"
import path from "path"

export async function buildCompilationUnit(
	fileId: string,
): Promise<CompilationUnit> {
	const builder = CompilationBuilder.create({
		languageVersion: "0.8.28",
		readFile,
		resolveImport,
	})
	await builder.addFile(fileId)

	const unit = builder.build()

	const files = unit.files()

	assert.equal(files.length, 1)

	assert.deepEqual(path.parse(files[0].id), path.parse(fileId))
	assertNonterminalNode(files[0].tree, NonterminalKind.SourceUnit)

	return unit
}

// TODO: Implement to support non flattened files
function resolveImport(importPath: string) {
	console.log("Resolving import path", importPath)
	return undefined
}

async function readFile(filePath: string): Promise<string> {
	return fs.readFileSync(filePath, "utf-8")
}
