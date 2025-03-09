import { Format, HELP_MESSAGE, Theme } from "./misc/constants"
import path from "path"
import fs from "fs"
import { isSolidityFile } from "./utils/checkers"
import { parseTheme } from "./utils/parse"
import { parseFormat } from "./utils/parse"

export interface OutputConfig {
	filePath: string
	format: Format
	theme: Theme
}

export interface ExcludeConfig {
	contracts: {
		interfaces: boolean
		libraries: boolean
		collections: string[]
		contracts: string[]
		exceptions: string[]
	}
	functions: {
		regExps: RegExp[]
		exceptions: string[]
	}
}

export class Config {
	private static instance: CliConfig

	private constructor() {}

	public static getInstance(): CliConfig {
		if (!this.instance) {
			this.instance = new CliConfig()
		}
		return this.instance
	}

	public static get inputContractFilePath(): string | undefined {
		const instance = Config.getInstance()
		return instance.inputContractFilePath
	}

	public static get exclude(): Readonly<ExcludeConfig> {
		const instance = Config.getInstance()
		return Object.freeze(instance.exclude)
	}

	public static get collections(): Readonly<Record<string, string[]>> {
		const instance = Config.getInstance()
		return Object.freeze(instance.collections)
	}

	public static get output(): Readonly<OutputConfig> {
		const instance = Config.getInstance()
		return Object.freeze(instance.output)
	}

	public static get disableFunctionParamType(): boolean {
		const instance = Config.getInstance()
		return instance.disableFunctionParamType
	}
}

class CliConfig {
	private _inputContractFilePath: string | undefined

	private _exclude: ExcludeConfig = {
		contracts: {
			interfaces: true,
			libraries: false,
			collections: ["layerzero", "common-utils", "openzeppelin"],
			contracts: ["Excluded"],
			exceptions: ["Relayer"],
		},
		functions: {
			regExps: [/.*reg.*/i],
			exceptions: ["exceptionRegExp"],
		},
	}

	// executionTime: false,

	private _collections: Record<string, string[]> = parseCollectionsFolder()

	private _output: OutputConfig = {
		filePath: "",
		format: Format.MMD,
		theme: Theme.DEFAULT,
	}

	disableFunctionParamType: boolean = false

	constructor() {
		this.parseCliArguments()
	}

	/* ===== FUNCTIONS ===== */

	parseCliArguments() {
		// Skip node and script path
		const [, , ...args] = process.argv

		// If help flag is provided, print help message and exit
		if (this.containsHelpFlag(args)) {
			console.log(HELP_MESSAGE)
			process.exit(0)
		}

		const [smartContractFilePath, ...additionalArgs] = args

		// Parse first argument - smart contract file path
		// Validate smart contract file path
		if (!isSolidityFile(smartContractFilePath)) {
			throw new Error("Invalid .sol file path")
		}

		this._inputContractFilePath = smartContractFilePath

		// Parse pairs of arguments
		for (let i = 0; i < additionalArgs.length; i += 2) {
			const arg = additionalArgs[i]
			const nextArg = additionalArgs[i + 1]

			this.parsePairOfArguments(arg, nextArg)
		}

		// console.log("Config.output.format", config.output.format)
		// console.log("Config.output.filePath", config.output.filePath)

		// If format is a file, but output file path is not provided, throw an error
		if (this._output.format != Format.MMD && this._output.filePath === "") {
			const fileName = path
				.basename(this._inputContractFilePath)
				.split(".")[0]

			this._output.filePath = path.join(
				"./",
				fileName + "." + this._output.format,
			)

			console.log("Config.output.filePath", this._output.filePath)
		}

		if (!this._output.filePath) return

		// Append file extension to output file path, if it is not provided
		const filePath = path.parse(this._output.filePath)

		if (filePath.ext === "") {
			this._output.filePath = path.join(
				filePath.dir,
				filePath.base + "." + this._output.format,
			)
		}
	}

	parsePairOfArguments(arg: string, nextArg: string) {
		if (!nextArg) throw new Error(`Missing value for argument: ${arg}`)

		switch (arg) {
			case "--output":
			case "-o":
				this._output.filePath = nextArg
				break

			case "--format":
			case "-f":
				this._output.format = parseFormat(nextArg)
				break

			case "--theme":
			case "-t":
				this._output.theme = parseTheme(nextArg)
				break
		}
	}

	containsHelpFlag(args: string[]): boolean {
		return args.includes("--help") || args.includes("-h")
	}

	/* ===== GETTERS ===== */

	public get inputContractFilePath(): string {
		return this._inputContractFilePath
	}

	public get exclude(): Readonly<ExcludeConfig> {
		return Object.freeze(this._exclude)
	}

	public get output(): Readonly<OutputConfig> {
		return Object.freeze(this._output)
	}

	public get collections(): Readonly<Record<string, string[]>> {
		return Object.freeze(this._collections)
	}
}

function parseCollectionsFolder(): Record<string, string[]> {
	const collectionsFolder = path.join(process.cwd(), "collections")
	const collections = fs.readdirSync(collectionsFolder)

	return collections.reduce((acc, collection) => {
		const collectionPath = path.join(collectionsFolder, collection)
		const collectionContent = fs.readFileSync(collectionPath, "utf8")
		const collectionName = collection.replace(".json", "")
		acc[collectionName] = JSON.parse(collectionContent)
		return acc
	}, {} as Record<string, string[]>)
}
