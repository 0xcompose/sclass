import { Format, Theme } from "./misc/constants"
import path from "path"
import fs from "fs"

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

	// executionTime: false,

	collections: parseCollectionsFolder(),

	output: {
		filePath: "",
		format: Format.MMD,
		theme: Theme.DEFAULT,
	},

	disableFunctionParamType: false,
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
