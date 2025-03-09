import path from "path"
import { HELP_MESSAGE, Theme, Format } from "./misc/constants"
import fs from "fs"

export function parseArguments(config: Config) {
	// Skip node and script path
	const [, , ...args] = process.argv

	// If help flag is provided, print help message and exit
	if (containsHelpFlag(args)) {
		console.log(HELP_MESSAGE)
		process.exit(0)
	}

	const [smartContractFilePath, ...additionalArgs] = args

	// Parse first argument - smart contract file path
	// Validate smart contract file path
	if (!isSolidityFile(smartContractFilePath)) {
		throw new Error("Invalid .sol file path")
	}

	config.inputContractFilePath = smartContractFilePath

	// Parse pairs of arguments
	for (let i = 0; i < additionalArgs.length; i += 2) {
		const arg = additionalArgs[i]
		const nextArg = additionalArgs[i + 1]

		parsePairOfArguments(config, arg, nextArg)
	}

	console.log("Config.output.format", config.output.format)
	console.log("Config.output.filePath", config.output.filePath)

	// If format is a file, but output file path is not provided, throw an error
	if (config.output.format != Format.MMD && config.output.filePath === "") {
		console.log(
			"Config.inputContractFilePath",
			config.inputContractFilePath,
		)
		console.log(
			"path.basename(config.inputContractFilePath)",
			path.basename(config.inputContractFilePath),
		)
		config.output.filePath = path.join(
			"./",
			path.basename(config.inputContractFilePath) +
				"." +
				config.output.format,
		)
	}

	// Append file extension to output file path, if it is not provided
	const filePath = path.parse(config.output.filePath)

	if (filePath.ext === "") {
		config.output.filePath = path.join(
			filePath.dir,
			filePath.base + "." + config.output.format,
		)
	}
}

function parsePairOfArguments(config: Config, arg: string, nextArg: string) {
	if (!nextArg) throw new Error(`Missing value for argument: ${arg}`)

	switch (arg) {
		case "--output":
		case "-o":
			config.output.filePath = nextArg
			break

		case "--format":
		case "-f":
			config.output.format = parseFormat(nextArg)
			break

		case "--theme":
		case "-t":
			config.output.theme = parseTheme(nextArg)
			break
	}
}

function parseTheme(value: string): Theme {
	const isTheme = Object.values(Theme).includes(value as Theme)
	if (!isTheme) throw new Error(`Invalid theme: ${value}`)

	return value as Theme
}

function parseFormat(value: string): Format {
	const isFormat = Object.values(Format).includes(value as Format)
	if (!isFormat) throw new Error(`Invalid format: ${value}`)

	return value as Format
}

function isSolidityFile(filePath: string): boolean {
	// Validate file path
	if (!filePath.endsWith(".sol")) return false

	// Validate file exists
	if (!fs.existsSync(filePath)) return false

	return true
}

function containsHelpFlag(args: string[]): boolean {
	return args.includes("--help") || args.includes("-h")
}
