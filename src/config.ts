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
		contracts?: string[]
		exceptions?: string[]
	}
	functions: {
		regExps?: RegExp[]
		exceptions?: string[]
	}
}

/**
 * @description Singleton wrapper class for the CliConfig class
 */
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

	/* ===== SETTERS FOR UNIT TESTING ===== */

	public static set inputContractFilePath(filePath: string) {
		this._checkIfTesting()
		Config.getInstance().inputContractFilePath = filePath
	}

	public static set exclude(exclude: ExcludeConfig) {
		this._checkIfTesting()
		Config.getInstance().exclude = exclude
	}

	public static set excludeContracts(exclude: ExcludeConfig["contracts"]) {
		this._checkIfTesting()
		Config.getInstance().excludeContracts = exclude
	}

	public static set excludeFunctions(exclude: ExcludeConfig["functions"]) {
		this._checkIfTesting()
		Config.getInstance().excludeFunctions = exclude
	}

	public static set collections(collections: Record<string, string[]>) {
		this._checkIfTesting()
		Config.getInstance().collections = collections
	}

	public static set output(output: OutputConfig) {
		this._checkIfTesting()
		Config.getInstance().output = output
	}

	public static set disableFunctionParamType(disable: boolean) {
		this._checkIfTesting()
		Config.getInstance().disableFunctionParamType = disable
	}

	private static _checkIfTesting() {
		if (process.env.NODE_ENV !== "test") {
			throw new Error("This function is only available in testing mode")
		}
	}
}

/**
 * @description Global config class used throughout the application,
 * parses arguments from the CLI and provides it to the rest of the application
 */
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

	private _disableFunctionParamType: boolean = false

	constructor() {
		if (process.env.NODE_ENV === "test") {
			try {
				this.parseCliArguments()
			} catch (error) {
				// Ignore errors during testing
			}
		} else {
			this.parseCliArguments()
		}
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

	public get disableFunctionParamType(): boolean {
		return this._disableFunctionParamType
	}

	/* ===== SETTERS FOR UNIT TESTING ===== */

	set inputContractFilePath(filePath: string) {
		this._checkIfTesting()
		this._inputContractFilePath = filePath
	}

	set exclude(exclude: ExcludeConfig) {
		this._checkIfTesting()
		this._exclude = exclude
	}

	set excludeContracts(exclude: ExcludeConfig["contracts"]) {
		this._checkIfTesting()
		this._exclude.contracts = exclude
	}

	set excludeFunctions(exclude: ExcludeConfig["functions"]) {
		this._checkIfTesting()
		this._exclude.functions = exclude
	}

	set collections(collections: Record<string, string[]>) {
		this._checkIfTesting()
		this._collections = collections
	}

	set output(output: OutputConfig) {
		this._checkIfTesting()
		this._output = output
	}

	set disableFunctionParamType(disable: boolean) {
		this._checkIfTesting()
		this._disableFunctionParamType = disable
	}

	private _checkIfTesting() {
		if (process.env.NODE_ENV !== "test") {
			throw new Error("This function is only available in testing mode")
		}
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
