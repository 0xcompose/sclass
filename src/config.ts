import { Format, Theme } from "./misc/constants"

export const config: Config = {
	inputContractFilePath: "",

	excludeContracts: {
		interfaces: true,
		libraries: false,
		collections: ["layerzero", "common-utils", "openzeppelin"],
		contracts: ["Excluded"],
		exceptions: ["Relayer"],
	},

	excludeFunctions: {
		regExps: [/.*reg.*/i],
		exceptions: ["exceptionRegExp"],
	},

	output: {
		filePath: "",
		format: Format.MMD,
		theme: Theme.DEFAULT,
	},

	disableFunctionParamType: false,
}
