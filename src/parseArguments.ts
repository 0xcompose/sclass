import { HELP_MESSAGE, Theme, Format } from "./misc/constants"
import fs from "fs"

export function parseArguments(config: Config) {
	// Skip node and script path
	const [, , smartContractFilePath, ...additionalArgs] = process.argv

	// If help flag is provided, print help message and exit
	if (containsHelpFlag(additionalArgs)) {
		console.log(HELP_MESSAGE)
		process.exit(0)
	}

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
