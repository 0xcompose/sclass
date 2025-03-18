import { StateMutability, Visibility } from "../../src/mermaid/contract.js"

// TODO: Broken Mermaid scheme, used only for testing in migration process
// export const TEST_CONTRACT_MERMAID = `\
// ---
// title: TestContract Class Diagram
// ---
// classDiagram

// 	class Base {
// 		${Visibility.public}${StateMutability.pure} baseFunc()
// 	}

// 	class MiddleInInheritance {
// 		${Visibility.public}${StateMutability.pure} middleFunc()
// 	}

// 	class ContractInCollection {
// 		${Visibility.public}${StateMutability.view} contractToFilterFunc()
// 	}

// 	class TestContract1 {
// 		${Visibility.public} uint256 uint256PublicVar
// 		${Visibility.private} address addressPrivateVar
// 		${Visibility.public}${StateMutability.mutative} setUint256PublicVar()
// 	}

// 	class TestContract2 {
// 		${Visibility.public}${StateMutability.pure} testContract2Func()
// 	}

// 	Base <|-- MiddleInInheritance

// 	MiddleInInheritance <|-- TestContract1

// 	ContractInCollection <|-- TestContract1

// 	MiddleInInheritance <|-- TestContract2\
// `

export const TEST_CONTRACT_MERMAID = `\
---
title: TestContract Class Diagram
---
classDiagram

	class Base {
		${Visibility.public}${StateMutability.pure} baseFunc() returns (uint256)
	}

	class MiddleInInheritance {
		${Visibility.public}${StateMutability.pure} middleFunc() returns (uint256)
	}

	class ContractInCollection {
		${Visibility.internal} mapping(address => bool) addressToBool
		${Visibility.public} mapping(address => mapping(bytes32 => uint256)) positions
		${Visibility.public}${StateMutability.view} contractToFilterFunc() returns (address)
	}

	class TestContract1 {
		${Visibility.public} uint256 uint256PublicVar
		${Visibility.private} address addressPrivateVar
		${Visibility.public}${StateMutability.mutative} setUint256PublicVar(uint256 _uint256PublicVar)
	}

	class TestContract2 {
		${Visibility.public}${StateMutability.pure} testContract2Func() returns (uint256)
	}

	class ITestContract {
		${Visibility.external}${StateMutability.mutative} setUint256PublicVar(uint256 _uint256PublicVar)
	}

	

	Base <|-- MiddleInInheritance

	MiddleInInheritance <|-- TestContract1

	ContractInCollection <|-- TestContract1

	MiddleInInheritance <|-- TestContract2\
`
