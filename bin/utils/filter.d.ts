import { ASTNode, ContractDefinition } from "@solidity-parser/parser/dist/src/ast-types";
import { Method } from "../mermaid/contract";
export declare function shouldFilterContract(node: ASTNode, config: Config): boolean;
export declare function isContractFromCollections(contract: ContractDefinition, config: Config): boolean;
export declare function shouldFilterMethod(method: Method | null, config: Config): boolean;
