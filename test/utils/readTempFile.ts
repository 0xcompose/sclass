import fs from "fs"
import { TEST_OUTPUT_DIR } from "./makeSuite"

export function readTempFile(fileName: string) {
	return fs.readFileSync(`${TEST_OUTPUT_DIR}/${fileName}`, "utf8")
}
