import fs from "fs"

import { COLLECTIONS_DIR, CONTRACTS_DIR } from "../misc/constants"

export function checkIfContractsExist(contracts: string[]) {
    for (const contract of contracts) {
        const path = `${CONTRACTS_DIR}/${contract}.sol`

        if (!fs.existsSync(path)) {
            throw new Error(`Contract ${contract} does not exist`)
        }
    }
}

export function checkIfCollectionsExist(collections: string[]) {
    for (const collection of collections) {
        const path = `${COLLECTIONS_DIR}/${collection}.json`

        if (!fs.existsSync(path)) {
            throw new Error(`Collection ${collection} does not exist`)
        }
    }
}
