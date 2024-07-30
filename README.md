# Solidity to Class Diagram Interpreter

Parses Solidity files using [@solidity-parser/parser](https://www.npmjs.com/package/@solidity-parser/parser) and creates .mmd (Mermaid) Class Diagrams.

## Getting Started

Load your **flattened** and **compilable** smart contracts into `/contracts` folder

Then run following commands:

```bash
npm install
npm run start
```

You can open resulting diagram.svg in browser or [preview extension](https://marketplace.visualstudio.com/items?itemName=vitaliymaz.vscode-svg-previewer)

## Configuration

Basically interpreter parses only contracts, excluding Interfaces and Libraries.

Also filters out OpenZeppelin, LayerZero and Stargate contracts.

New contracts to filter out can be added in `main.ts` array `excludeContracts: string[] = []`. Or by adding contract collection in `src/collections` and adding new filter in `filterNodes(nodes)` in `main.ts`

You can change basic behavior by changing boolean values of variables at the top of `main.ts` file:

```typescript
const filterInterfaces = true
const filterLibraries = true
const filterOz = true
const filterStargate = true
const filterLayerZero = true

export const disableFunctionParamType = false
```

## Making custom validation

`/src/validate.ts` contains functions for variables, mappings and functions validation.

You can add your own validations to this functions to warn or throw errors about misguiding code style or best practice in namings

## Use cases

-   Contracts high level review
-   Source code validation
-   Finding unused variables, imports, functions
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
