interface Config {
    readonly inputContracts: string[]

    readonly excludeContracts: {
        readonly interfaces: boolean
        readonly libraries: boolean

        readonly collections: string[]
        readonly contracts: string[]

        readonly exceptions: string[]
    }

    readonly excludeFunctions: {
        readonly regExps: RegExp[]
        readonly exceptions: string[]
    }

    readonly disableFunctionParamType: boolean
}

type MyType = string
