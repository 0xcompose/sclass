export const config: Config = {
    inputContracts: ["ExampleContract1", "ExampleContract2"],

    excludeContracts: {
        interfaces: true,
        libraries: false,
        collections: ["layerzero", "common-utils", "openzeppelin"],
        contracts: ["Excluded"],
        exceptions: ["Relayer"],
    },

    excludeFunctions: {
        regExps: [/.*reg.*/i],
        exceptions: ["exceptionRegExp"],
    },

    disableFunctionParamType: false,
}
