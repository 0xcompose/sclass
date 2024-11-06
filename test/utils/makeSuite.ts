import fs from "fs"
import { COLLECTIONS_DIR, CONTRACTS_DIR } from "../../src/misc/constants"

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

    const fileContent = fs.readFileSync("./test/utils/TestContract.sol")

    fs.writeFileSync(`${CONTRACTS_DIR}/TestContract.sol`, fileContent)

    /* ======== COPY TEST COLLECTION ======== */

    const collectionContent = fs.readFileSync(
        "./test/utils/TestCollection.json",
    )

    fs.writeFileSync(
        `${COLLECTIONS_DIR}/TestCollection.json`,
        collectionContent,
    )
}

async function cleanup() {
    /* ======== DELETE TEST ENV ======== */

    fs.unlinkSync(`${CONTRACTS_DIR}/TestContract.sol`)
    fs.unlinkSync(`${COLLECTIONS_DIR}/TestCollection.json`)
}
