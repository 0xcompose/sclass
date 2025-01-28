export interface Field {
    type: string;
    name: string;
    visibility: Visibility;
}
export declare enum Visibility {
    external = "\u2757",
    public = "\u2757",
    internal = "\u2699\uFE0F",
    private = "\uD83D\uDD12"
}
export declare enum StateMutability {
    mutative = "",
    view = "\uD83D\uDC40",
    pure = "\uD83E\uDDEE",
    constant = "\u210F",
    payable = "\uD83D\uDCB0"
}
export interface Declaration {
    type: string;
    name: string;
}
export interface Method {
    visibility: Visibility;
    name: string;
    params: Declaration[];
    returnType: string;
    stateMutability: StateMutability | "mutative";
}
export interface Mapping {
    key: string;
    value: string;
    name: string;
    visibility: Visibility;
}
export declare class Contract {
    className: string;
    fields: Field[];
    methods: Method[];
    mappings: Mapping[];
    constructor(className: string);
    addField(field: Field): void;
    addMethod(method: Method): void;
    addMapping(mapping: Mapping): void;
    toMermaidString(disableFunctionParamType: boolean): string;
    getParamsString(params: Declaration[], disableFunctionParamType: boolean): string;
}
