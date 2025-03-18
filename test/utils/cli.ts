import { execSync } from "child_process"
import { PathLike } from "fs"
import { TEST_CONTRACT_PATH } from "./makeSuite.js"

interface Args {
	input?: PathLike
	flags?: string
}

export function sclass(args?: Args): string {
	const input = args?.input ? ` ${args.input}` : TEST_CONTRACT_PATH

	return execSync(
		`node bin/src/index.js ${input} ${args?.flags ?? ""}`,
	).toString()

	// Get last line from response, it contains execution time
	// const executionTime = response.split("\n").pop()

	// Get all lines except last one
	// const result = response.split("\n").slice(0, -1).join("\n")

	// return response
}
