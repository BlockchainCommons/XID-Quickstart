# XID Learning Path

This document outlines a streamlined approach to teaching XIDs (eXtensible IDentifiers) through a combination of conceptual documentation and hands-on tutorials.

## Core Principles

1. **Focus on XIDs as the Primary Subject**
   - Introduce Gordian Envelope and DCBOR only as needed
   - Keep technical explanations minimal and directly relevant

2. **Learn by Doing**
   - Each tutorial is primarily hands-on
   - Concepts are introduced through practical examples
   - Users should be typing commands and seeing results immediately

3. **Progressive Complexity**
   - Start with the absolute minimum (creating a basic XID)
   - Each tutorial builds on skills from previous ones
   - Advanced features are introduced only after basics are mastered

4. **Narrative Continuity**
   - Use consistent examples and characters throughout
   - Build a story that naturally introduces features when needed
   - Avoid abstract explanations disconnected from practical usage

5. **Testable Steps**
   - Every command should work in an actual CLI environment
   - Each tutorial has validation steps to confirm success
   - Commands should be designed to be copy-paste friendly

## Learning Components

### Conceptual Documentation

To help users understand the theoretical foundations behind XIDs, we provide conceptual documentation:

1. [XID Fundamentals](concepts/xid-fundamentals.md) - Understanding the basics of eXtensible IDentifiers
2. [Gordian Envelope Basics](concepts/gordian-envelope-basics.md) - The data structure that powers XIDs
3. [Data Minimization Principles](concepts/data-minimization-principles.md) - How to control information disclosure
4. [Fair Witness Approach](concepts/fair-witness-approach.md) - Making trustworthy assertions
5. [Pseudonymous Trust Building](concepts/pseudonymous-trust-building.md) - Building trust without revealing identity
6. [Key Management Essentials](concepts/key-management-essentials.md) - Securing and managing cryptographic keys

### Hands-on Tutorials

The tutorials provide practical, step-by-step instructions for working with XIDs:

1. [Creating Your First XID](tutorials/01-your-first-xid.md) - Learn to create a basic pseudonymous identity
2. [Understanding XID Structure](tutorials/02-understanding-xid-structure.md) - Explore how XIDs are structured
3. [Self-Attestation with XIDs](tutorials/03-self-attestation-with-xids.md) - Create structured self-claims with verifiable evidence
4. [Peer Endorsement with XIDs](tutorials/04-peer-endorsement-with-xids.md) - Build a network of trust through independent verification
5. [Key Management with XIDs](tutorials/05-key-management-with-xids.md) - Master secure key management for XIDs

## Recommended Learning Approach

For the most effective learning experience:

1. **Concept First**: Read the relevant concept document
2. **Hands-on Practice**: Complete the related tutorial
3. **Reflection**: Review the concept again with your new practical understanding
4. **Experimentation**: Try the exercises at the end of each tutorial

### Concept-Tutorial Mapping

| Concept | Related Tutorial |
|---------|------------------|
| XID Fundamentals | Tutorial 1: Creating Your First XID |
| Gordian Envelope Basics | Tutorial 1 & 2 |
| Data Minimization Principles | Tutorial 2: Understanding XID Structure |
| Fair Witness Approach | Tutorial 3 & 4: Self-Attestation and Peer Endorsement |
| Attestation & Endorsement Model | Tutorial 3 & 4 |
| Pseudonymous Trust Building | Tutorial 3 & 4 |
| Key Management Essentials | Tutorial 5: Key Management with XIDs |

## Learning Outcomes

By completing this learning path, developers will be able to:

1. Create and manage XIDs for various identity purposes
2. Implement secure authentication using XIDs
3. Enable private, selectively disclosed identity information
4. Build applications that leverage XID capabilities
5. Design systems with strong identity and authentication
6. Understand the relationship between XIDs and wider trust frameworks

## Tutorial Structure

### 1. XID Essentials

**Tutorial: Creating Your First XID**
- Installing the envelope CLI
- Creating a simple XID with a name
- Examining its structure
- Extracting the identifier
- Saving and loading an XID document

**Tutorial: Understanding XID Structure**
- The relationship between keys and XIDs
- Examining the parts of an XID
- How XIDs maintain stable identity
- Adding basic assertions to an XID

### 2. XID Identity Management

**Tutorial: Self-Attestation with XIDs**
- Creating structured self-claims with proper context
- Adding verifiable evidence to self-attestations
- Building cryptographic commitments to evidence
- Applying fair witness principles to self-claims
- Linking to independently verifiable external sources

**Tutorial: Peer Endorsement with XIDs**
- Creating structured endorsements of others
- Evaluating and accepting endorsements from peers
- Building a network of multiple perspectives
- Implementing a formal endorsement acceptance model
- Creating verifiable chains of trust through signatures

**Tutorial: Key Management with XIDs**
- Adding and removing keys while maintaining identity
- Setting permission boundaries for different keys
- Implementing secure key rotation
- Recovering from lost or compromised keys
- Understanding how XIDs provide stable identity across key changes


## Implementation Notes

- Each tutorial should be completely self-contained
- All code snippets must be tested in a real CLI environment
- Examples should build on each other, not introduce disconnected concepts
- Keep prerequisite knowledge minimal
- Provide clear success criteria for each tutorial step
- Focus on practical developer use cases, not theoretical explanations