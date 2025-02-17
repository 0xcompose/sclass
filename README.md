# Solidity to Class Diagram Interpreter (sclass)

Parses Solidity files using [@solidity-parser/parser](https://www.npmjs.com/package/@solidity-parser/parser) and creates .mmd (Mermaid) class diagrams.

## CLI

You can use `sclass` from the CLI by installing the [NPM package](https://www.npmjs.com/package/sclass):

```
npm install -g sclass
sclass --helps
```

## Getting Started

Load your **flattened** and **compilable** smart contracts into the `/contracts` folder.

Set up the configuration in `config.ts` as described in the [Configuration](#configuration) section.

Then run the following commands:

```bash
npm install
npm run start
```

After running the script, two files will be generated in the `/out` directory:

-   `diagram.mmd` (source diagram file)
-   `diagram.svg` (rendered diagram)

You can view `diagram.svg` in any web browser or using this [preview extension](https://marketplace.visualstudio.com/items?itemName=vitaliymaz.vscode-svg-previewer).

## Configuration

Set up the configuration in the `config.ts` file.

### inputContracts

An array of **file names** without the `.sol` extension of contracts to be included in the diagram. You can place your contracts in the `/contracts` folder and add them here.

### excludeContracts

If you want to exclude some contracts, you can set up an object with the following fields:

-   `interfaces`: boolean - whether to exclude interfaces
-   `libraries`: boolean - whether to exclude libraries
-   `collections`: array of collection **file names** to exclude
    > **ℹ️ Note:** Collections are groups of related contracts that can be defined in `src/collections`. We already have LayerZero, OpenZeppelin, and Stargate collections. You can create your own collections by adding a new file in the `src/collections` folder.
-   `contracts`: array of contract names to exclude
    > You don't need to create a new collection; you can just add contract names here.
-   `exceptions`: array of contract names to be included in the diagram despite being excluded by other fields.

### excludeFunctions

An object with the following fields:

-   `regExps`: array of regular expressions to exclude functions by name
-   `exceptions`: array of function names to be included in the diagram despite being excluded by other fields.

### disableFunctionParamType

Boolean - whether to disable function parameter type rendering.

This also filters out OpenZeppelin, LayerZero, and Stargate contracts.

## Making Custom Validation

`/src/validate.ts` contains functions for validating variables, mappings, and functions.

You can add your own validations to these functions to warn or throw errors about misleading code style or best practices in naming.

## Use Cases

-   High-level review of contracts
-   Source code validation
-   Finding unused variables, imports, and functions
-   Identifying deprecated code blocks

## Error Handling

If the interpreter encounters unhandled code variations, it will set "empty" for type/name or throw an error with data about the unhandled invariant.

It does not support nested mappings.

## Possible Features

-   Enforcing code style and best practices:
    -   Defining comment formatting
    -   Enforcing that internal variable and function names start with "\_"
    -   Validating the existence of requirements for addresses (null address) in functions with address parameters
-   Generating a full inheritance tree for contracts
-   Generating other types of Mermaid diagrams from Solidity code (Flowchart, Sequence, Use Case, Entity Relationship)
-   Linking diagram elements to source code to use the diagram as navigation
