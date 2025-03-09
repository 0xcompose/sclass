import { Theme } from "../misc/constants"
import { Format } from "../misc/constants"

export function parseTheme(value: string): Theme {
	const isTheme = Object.values(Theme).includes(value as Theme)
	if (!isTheme) throw new Error(`Invalid theme: ${value}`)

	return value as Theme
}

export function parseFormat(value: string): Format {
	const isFormat = Object.values(Format).includes(value as Format)
	if (!isFormat) throw new Error(`Invalid format: ${value}`)

	return value as Format
}
