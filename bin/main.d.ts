import { ContractDefinition } from "@solidity-parser/parser/dist/src/ast-types";
export type Diagram = string;
export declare function parseContracts(config: Config): Promise<string>;
export declare function readFileAndParse(filePath: string): Promise<ContractDefinition[]>;
