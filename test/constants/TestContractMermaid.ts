import { StateMutability, Visibility } from "../../src/mermaid/contract.js"

// TODO: Broken Mermaid scheme, used only for testing in migration process
export const TEST_CONTRACT_MERMAID = `\
---
title: TestContract Class Diagram
---
classDiagram

	class Base {
		${Visibility.public}${StateMutability.pure} baseFunc()
	}

	class MiddleInInheritance {
		${Visibility.public}${StateMutability.pure} middleFunc()
	}

	class ContractInCollection {
		${Visibility.public}${StateMutability.view} contractToFilterFunc()
	}

	class TestContract1 {
		${Visibility.public} uint256 uint256PublicVar
		${Visibility.private} address addressPrivateVar
		${Visibility.public}${StateMutability.mutative} setUint256PublicVar()
	}

	class TestContract2 {
		${Visibility.public}${StateMutability.pure} testContract2Func()
	}



	Base <|-- MiddleInInheritance

	MiddleInInheritance <|-- TestContract1

	ContractInCollection <|-- TestContract1

	MiddleInInheritance <|-- TestContract2\
`

export const TEST_CONTRACT_MERMAID_CORRECT = `\
---
title: TestContract Class Diagram
---
classDiagram

	class Base {
		${Visibility.public}${StateMutability.pure} baseFunc() uint256
	}

	class MiddleInInheritance {
		${Visibility.public}${StateMutability.pure} middleFunc() uint256
	}

	class ContractInCollection {
		${Visibility.public}${StateMutability.view} contractToFilterFunc() address
	}

	class TestContract1 {
		${Visibility.public} uint256 uint256PublicVar
		${Visibility.private} address addressPrivateVar
		${Visibility.public}${StateMutability.mutative} setUint256PublicVar(uint256 _uint256PublicVar)
	}

	class TestContract2 {
		${Visibility.public}${StateMutability.pure} testContract2Func() uint256
	}



	Base <|-- MiddleInInheritance

	MiddleInInheritance <|-- TestContract1

	ContractInCollection <|-- TestContract1

	MiddleInInheritance <|-- TestContract2\
`
