# S Class

Solidity to Class Diagram Interpreter

Parses Solidity files using [@nomicfoundation/slang](https://github.com/NomicFoundation/slang) and generates mermaid markdown, or rendered files (SVG, PNG, PDF, MD, MMD) class diagrams.

Supports Foundry projects, doesn't support Hardhat project (create issue to request hardhat support)

## Getting Started

```
sudo npm i -g sclass
sclass --help
```

## Usage example

```
sclass src/FlattenedContract.sol --format svg --output FlattenedContract.svg
```

or with short flags

```
sclass src/FlattenedContract.sol -f svg
```

which will output a scheme in svg format with name 'FlattenedContract.svg'.

You can view the FlattenedContract.svg in any web browser or using this [preview extension](https://marketplace.visualstudio.com/items?itemName=vitaliymaz.vscode-svg-previewer)

## Configuration

Configuration of diagram generation is evaluated via cli flags

### inputContracts

Array of **file names** without `.sol` extension of contracts to be included in the diagram, you can put your contracts in `/contracts` folder and add them here

### excludeContracts

If you want to exclude some contracts, you can setup object with following fields:

-   interfaces: boolean - whether to exclude interfaces
-   libraries: boolean - whether to exclude libraries

// TODO: remove collections and replace it with parsing imports

-   collections: array of collection **file names** to exclude
    > **ℹ️ Note:** Collections are groups of related contracts that can be defined in `src/collections`. We've already have LayerZero, OpenZeppelin and Stargate collections. You can create your own collections by adding new file in `src/collections` folder.
-   contracts: array of contract names to exclude
    > You don't need to create a new collection, you can just add contract names here
-   exceptions: array of contract names to be included in the diagram despite of being excluded by other fields

### excludeFunctions

Object with following fields:

-   regExps: array of regular expressions to exclude functions by name
-   exceptions: array of function names to be included in the diagram despite of being excluded by other fields

### disableFunctionParamType

Boolean - whether to disable function parameter type rendering

Also filters out OpenZeppelin, LayerZero and Stargate contracts.

## Use cases

-   Contracts high level review
-   Finding unused variables, functions
-   Finding deprecated code blocks

## Error handling

If interpreter stumbles across unhandled code variation it will put "empty" to type/name or throw Error with data about unhandled invariant.

Doesn't support nested mappings.

## Possible features

-   Enforcing code style and best practices
    -   defining comments formatting
    -   enforcing internal variable and function name to start with "\_"
    -   validating requirements existence for address (null address) in functions with address param
-   Generating full inheritance tree for contract
-   Generating other types of Mermaid diagrams from Solidity code (Flowchart, Sequence, Use Case, Entity Relationship)
-   Linking diagram elements to source code to use diagram as a navigation

## Other tools by 0xCompose

-   [sspec](https://github.com/0xcompose/sspec) - smart contract specification generator for Foundry
