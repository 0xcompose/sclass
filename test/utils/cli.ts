import { exec } from "child_process"
import { PathLike } from "fs"
import { TEST_CONTRACT_PATH } from "./makeSuite.js"
import { promisify } from "util"

const execAsync = promisify(exec)

interface Args {
	input?: PathLike
	flags?: string
}

export function sclass(
	args?: Args,
): Promise<{ stdout: string; stderr: string }> {
	const input = args?.input ? ` ${args.input.toString()}` : TEST_CONTRACT_PATH

	return execAsync(`node bin/src/index.js ${input} ${args?.flags ?? ""}`)

	// Get last line from response, it contains execution time
	// const executionTime = response.split("\n").pop()

	// Get all lines except last one
	// const result = response.split("\n").slice(0, -1).join("\n")

	// return response
}
