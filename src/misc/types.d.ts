interface Config {
	inputContractFilePath: string

	readonly excludeContracts: {
		readonly interfaces: boolean
		readonly libraries: boolean

		readonly collections: string[]
		readonly contracts: string[]

		readonly exceptions: string[]
	}

	readonly excludeFunctions: {
		readonly regExps: RegExp[]
		readonly exceptions: string[]
	}

	output: { filePath: string; format: string; theme: string }

	readonly disableFunctionParamType: boolean
}
