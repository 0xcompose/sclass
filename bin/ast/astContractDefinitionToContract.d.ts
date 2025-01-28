import { ContractDefinition } from "@solidity-parser/parser/dist/src/ast-types";
import { Contract } from "../mermaid/contract";
export declare function convertContractDefinitionToContract(astContract: ContractDefinition, config: Config): Contract;
