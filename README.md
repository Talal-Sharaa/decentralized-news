# Title: Decentralized News Platform on Ethereum

## Abstract

In an era of information overload and potential biases, ensuring access to unbiased and reliable news sources is paramount. This project implements a decentralized news platform on the Ethereum blockchain (Sepolia testnet) to combat censorship, promote transparency, and preserve news article integrity.

Our platform allows publishers to distribute content with traceable authorship and assured permanence. Readers can trust the authenticity and historical accuracy of the news they consume. This addresses the critical issues of platform bias and content manipulation that have plagued centralized news distribution models, as seen in recent Facebook controversies and the Gaza conflict.

## Key Features

- **Decentralized Storage:** News articles are stored on the Ethereum blockchain, ensuring immutability and preventing unauthorized changes or deletions.
- **Publisher and Reader Management:** Smart contracts facilitate permissions for publishers and readers, fostering a responsible and accountable network.
- **Version Tracking:** Article updates are recorded on the blockchain, providing full transparency of edits and allowing readers to access the complete history of an article.
- **Reputation System:** (Consider implementing) A reputation system to incentivize high-quality content and establish trust in publishers.

## Technical Overview

- **Blockchain:** Ethereum (Sepolia testnet)
- **Framework:** Hardhat
- **Smart Contracts:** Solidity
- **Access Control:** OpenZeppelin's AccessControl

## Project Structure

- `contracts/NewsPlatform.sol:` Core smart contract with the following structs and functions:
  - Structs: Publisher, Reader, Article, ArticleVersion, ArticlewithOutVersion
  - Functions:
    - `registerPublisher()`
    - `submitArticle()`
    - `updateArticle()`
    - `getArticleHistory()`
    - `getArticle()`
    - `getArticlesByPublisher()`
- `test/:` Unit tests to ensure contract functionality.
- `scripts/:` Deployment and interaction scripts.

## How to Run

- Prerequisites: Node.js, npm, Hardhat development environment.
- Clone the repository: `git clone https://github.com/<your_username>/<repo_name>`
- Install dependencies: `npm install`
- Compile the contracts: `npx hardhat compile`
- Deploy to Sepolia testnet: Use deployment scripts and ensure you have a testnet wallet with test ETH.
- Interact with the platform: Develop a user interface or use scripts to submit articles, view articles, and manage publishers/readers.

## UML Diagram

```plaintext
   classDiagram

   Article : +title (string)
   Article : +content (string)
   Article : +timestamp (datetime)
   Article : +publisherID (address)
   Article : +articleHash (string)
   Article : +versionHistory (array of ArticleVersion)

   ArticleVersion : +versionNumber (integer)
   ArticleVersion : +articleHash (string)
   ArticleVersion : +editorID (address)
   ArticleVersion : +editTimestamp (datetime)

   Publisher : +publisherID (address)
   Publisher : +registrationTimestamp (datetime)
   Publisher : +reputationScore (integer)
   Publisher : +registerPublisher()
   Publisher : +submitArticle()
   Publisher : +updateArticle()

   Reader : +readerID (address)

   SmartContract : +getArticle()
   SmartContract : +getArticleHistory()
   SmartContract : +verifyPublisher()
   SmartContract : +verifyReader()

   SmartContract <|-- Article : manages
   SmartContract <|-- Publisher : manages
   SmartContract <|-- Reader : manages
   Article *-- ArticleVersion : has a
```

## Future Development

- **Reputation System**: _Design and implement a reputation system._
- **Frontend Development**: _Create a user-friendly interface._
- **IPFS Integration**: _Consider integrating with IPFS for more efficient storage of larger content._
