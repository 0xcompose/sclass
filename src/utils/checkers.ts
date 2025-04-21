import fs from "fs"
import path from "path"

export function checkIfCollectionsExist(collections: string[]) {
	for (const collection of collections) {
		// Get absolute path of collections
		const pathToCollection = path.join(
			process.cwd(),
			"collections",
			`${collection}.json`,
		)

		if (!fs.existsSync(pathToCollection)) {
			throw new Error(`Collection ${collection} does not exist`)
		}
	}
}

export function isSolidityFile(filePath: string): boolean {
	// Validate file path
	if (!filePath.endsWith(".sol")) return false

	// Validate file exists
	if (!fs.existsSync(filePath)) return false

	return true
}
