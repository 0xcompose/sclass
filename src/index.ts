#!/usr/bin/env node

import { exec } from "child_process"
import { promisify } from "util"
import pc from "picocolors"
import { parseContracts } from "./main.js"
import { Format } from "./constants.js"
import fs from "fs"
import path from "path"
import { Config } from "./config.js"

const execAsync = promisify(exec)

async function main() {
	// console.time("Total Execution Time")

	const output = Config.output

	const diagram = await parseContracts()

	switch (output.format) {
		case Format.MMD:
			if (output.filePath) {
				writeToFile(diagram, output.filePath)
			} else {
				console.log(diagram)
			}
			break
		default:
			await generatePictureFile(diagram)
			break
	}

	// console.log()
	// console.timeEnd("Total Execution Time")
}

async function generatePictureFile(diagram: string) {
	console.log("Generating picture file")

	const { filePath, theme } = Config.output

	const { stderr } = await execAsync(
		`echo "${diagram}" | npx mmdc --input - --output ${filePath} --theme ${theme}`,
	)
	if (stderr) console.error(pc.yellow(stderr))
}

function writeToFile(content: string, outputFilePath: string) {
	const filePath = outputFilePath || "diagram.mmd"

	// Ensure directory exists
	const dir = path.dirname(filePath)

	if (!fs.existsSync(dir)) {
		fs.mkdirSync(dir, { recursive: true })
	}

	fs.writeFileSync(filePath, content)
}

main().catch((error) => {
	console.error(error)
	process.exit(1)
})
