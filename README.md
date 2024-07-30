# Solidity to Class Diagram Interpreter

## Getting Started

Load your **flattened** and **compilable** smart contracts into `/contracts` folder

Then run following commands

```bash
npm install
npm run start
```

You can open resulting diagram.svg in browser or [preview extension](https://marketplace.visualstudio.com/items?itemName=vitaliymaz.vscode-svg-previewer)

## Making custom validation

`/src/validate.ts` contains functions for variables, mappings and functions validation.

You can add your own validations to this functions to warn or throw errors about misguiding code style or best practice in namings

## Use cases

-   Contracts high level review
-   Source code validation
-   Finding unused variables, imports, functions
-   Finding deprecated code blocks

## Possible features

-   Enforcing code style and best practices
    -   defining comments formatting
    -   enforcing internal variable and function name to start with "\_"
    -   validating requirements existence for address (null address) in functions with address param
-   Generating full inheritance tree for contract
-   Generating other types of Mermaid diagrams from Solidity code (Flowchart, Sequence, Use Case, Entity Relationship)
-   Linking diagram elements to source code to use diagram as a navigation
