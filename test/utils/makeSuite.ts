import fs from "fs"
import { COLLECTIONS_DIR } from "../../src/constants.js"

export const TEST_CONTRACT_PATH = "./test/constants/TestContract.sol"
export const TEST_COLLECTION_PATH = "./test/constants/TestCollection.json"
export const TEST_OUTPUT_DIR = "./test/temp"

export function makeSuite(
	name: string,
	test: () => void,
	behavior?: "skip" | "only",
) {
	switch (behavior) {
		case "skip":
			describe.skip(name, () => {
				runTest(test)
			})

		case "only":
			describe.only(name, () => {
				runTest(test)
			})

		default:
			describe(name, () => {
				runTest(test)
			})
	}
}

// we copy test files to required directories and delete them after the test
function runTest(test: () => void) {
	before(async () => {
		await makeEnv()
	})

	test()

	after(async () => {
		await cleanup()
	})
}

async function makeEnv() {
	/* ======== COPY TEST CONTRACT ======== */
	// const fileContent = fs.readFileSync(TEST_CONTRACT_PATH)
	// fs.writeFileSync(`${CONTRACTS_DIR}/TestContract.sol`, fileContent)
	/* ======== COPY TEST COLLECTION ======== */
	const collectionContent = fs.readFileSync(TEST_COLLECTION_PATH)

	if (!fs.existsSync(TEST_OUTPUT_DIR)) {
		fs.mkdirSync(TEST_OUTPUT_DIR)
	}

	fs.writeFileSync(
		`${COLLECTIONS_DIR}/TestCollection.json`,
		collectionContent,
	)
}

async function cleanup() {
	/* ======== DELETE TEST ENV ======== */
	// fs.unlinkSync(`${CONTRACTS_DIR}/TestContract.sol`)

	// If collection exists - delete it
	const collectionPath = `${COLLECTIONS_DIR}/TestCollection.json`

	if (fs.existsSync(collectionPath)) {
		fs.unlinkSync(collectionPath)
	}

	// If output directory exists - delete it
	const outputDirPath = `${TEST_OUTPUT_DIR}`

	if (fs.existsSync(outputDirPath)) {
		fs.rmSync(outputDirPath, { recursive: true })
	}
}
