#!/usr/bin/env node

import { exec } from "child_process"
import { promisify } from "util"
import pc from "picocolors"
import { parseContracts } from "./main"
import { config } from "./config"
import { Format } from "./misc/constants"
import fs from "fs"
import path from "path"
import { parseArguments } from "./parseArguments"

const execAsync = promisify(exec)

async function main() {
	// console.time("Total Execution Time")

	parseArguments(config)

	const diagram = (await parseContracts(config)).trim()

	switch (config.output.format) {
		case Format.MMD:
			if (config.output.filePath.length > 0) {
				writeToFile(diagram, config.output.filePath)
			} else {
				console.log(diagram)
			}
			break
		default:
			await generatePictureFile(diagram, config.output)
			break
	}

	console.log()
	// console.timeEnd("Total Execution Time")
}

async function generatePictureFile(
	diagram: string,
	output: typeof config.output,
) {
	const { filePath, theme } = output

	const { stderr } = await execAsync(
		`echo "${diagram}" | npx mmdc --input - --output ${filePath} --theme ${theme}`,
	)
	if (stderr) console.error(pc.yellow(stderr))
}

async function writeToFile(content: string, outputFilePath: string) {
	const filePath = outputFilePath || "diagram.mmd"

	// Ensure directory exists
	const dir = path.dirname(filePath)

	if (!fs.existsSync(dir)) {
		fs.mkdirSync(dir, { recursive: true })
	}

	fs.writeFileSync(filePath, content)
}

main()
