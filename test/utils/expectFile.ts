import fs from "fs"
import { expect } from "chai"

export function expectToBeSVG(filePath: string) {
	const fileContent = fs.readFileSync(filePath, "utf8")

	expect(fileContent).to.include("svg")
	expect(fileContent).length.to.be.greaterThan(1000)
}

export function expectToBePNG(filePath: string) {
	const fileContent = fs.readFileSync(filePath, "utf8")

	expect(fileContent).to.include("PNG")
	expect(fileContent).length.to.be.greaterThan(1000)
}

export function expectToBePDF(filePath: string) {
	const fileContent = fs.readFileSync(filePath, "utf8")

	expect(fileContent).to.include("PDF")
	expect(fileContent).length.to.be.greaterThan(1000)
}
