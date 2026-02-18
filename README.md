# XID-Quickstart

> :warning: **NOTE:** This Quickstart is in process. The [concepts guide](concepts/README.md) is robust at this time, but the examples reflect a version of `envelope-cli` that is slightly old, and so may be out of date. [Tutorial #1](tutorials/01-your-first-xid.md) and [Tutorial #2](tutorials/02-making-your-xid-verifiable.md) have been fully released, while the later tutorials are undergoing updates for the newest capabilities of `envelope-cli` as well as a full edit.

## Introduction

_**A Tutorial Series for eXtensible IDentifiers (XIDs)**_

[![License](https://img.shields.io/badge/License-BSD_2--Clause--Patent-blue.svg)](https://spdx.org/licenses/BSD-2-Clause-Patent.html)
[![Project Status: WIP](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](CHANGELOG.md)

**XID-Quickstart** is a tutorial series for learning about eXtensible IDentifiers (XIDs) using Gordian Envelope technology. This repository contains conceptual documentation and hands-on examples to guide you through creating, understanding, and working with XIDs to support secure, privacy-preserving identity management.

## Why To Use XIDs

A XID is a decentralized self-sovereign identifier that's built on the concept of [data minimization](https://www.blockchaincommons.com/musings/musings-data-minimization/). It allows you to initially share only the minimum necessary information about an identity, and then to slowly disclose additional information through the process of [progressive trust](https://www.blockchaincommons.com/musings/musings-progressive-trust/).

A XID can be a foundation for attestation frameworks and fair witness models. But it's a transformational technology that goes beyond current designs: it puts privacy and moreso user agency first in a way that the rest of the identity and credentials community generally doesn't, in part due to [their failure to adhere to early self-sovereign principles](https://www.blockchaincommons.com/musings/musings-ssi-bankruptcy/).

If self-sovereign identity and the desire to protect and empower users are important to you, then we hope you'll find XIDs a crucial next step in making ethical, autonomous, self-sovereign identity a reality.

### Why To Use This Tutorial

Working with XIDs in this tutorial will give you hands-on experience with how you can maintain a stable identifier even through key rotation, device additions, and recovery scenarios. It will also demonstrate how to cryptographically elide data while maintaining verifiability through signatures.
 
## Learning Materials

This repository contains conceptual documentation, hands-on tutorials, and examples used by those tutorials.

### Prerequisites

- Basic familiarity with command-line tools
- The `envelope` CLI tool, which can be installed from the [bc-envelope-cli-rust](https://github.com/BlockchainCommons/bc-envelope-cli-rust) repository

_No prior knowledge of XIDs or Gordian Envelope is required._

### Quick-Start

1. Install the `envelope` CLI tool: `cargo install bc-envelope-cli`
2. Clone this repository: `git clone https://github.com/BlockchainCommons/XID-Quickstart.git`
3. Optionally, review the core concepts from `concepts/README.md` until you're ready to get hands-on
4. Navigate to the tutorials directory: `cd XID-Quickstart/tutorials`
5. Start with the first tutorial: [Creating Your First XID](tutorials/01-your-first-xid.md)

### Core Concepts

The [concepts guide](concepts/README.md) covers ten foundational concepts for XIDs, organized into:
- Core technical concepts (XIDs, Gordian Envelopes, cryptography)
- Trust and identity frameworks
- Practical implementation guidance

The guide includes a visual concept map and multiple learning paths.

### Hands-on Tutorials

The tutorials provide practical experience with XIDs:

1. [Creating Your First XID](tutorials/01-your-first-xid.md) - Create a pseudonymous identity
2. [Understanding XID Structure](tutorials/02-making-your-xid-verifiable.md) - Internal structure and components
3. [Self-Attestation with XIDs](tutorials/03-self-attestation-with-xids.md) - Make verifiable claims about yourself
4. [Peer Endorsement with XIDs](tutorials/04-peer-endorsement-with-xids.md) - Third-party verification methods
5. [Key Management with XIDs](tutorials/05-key-management-with-xids.md) - Key rotation and recovery strategies

See also the [concept map](concepts/README.md#concept-map) and [Learning Path](LEARNING_PATH.md) for alternative ways to navigate these materials.

### Examples

The `examples` directory contains complete scripts implementing the functionality covered in each tutorial. These scripts can be used to see the full implementation or as a reference when working through the tutorials.

## ⚠️  Warning: Experimental Material Ahead! ⚠️

Fundamentally, Blockchain Commons' current work with XIDs is **experimental**. This is more a **sandbox** for play with XIDs than a proper tutorial, we're just sharing what our play looks like in case you want to play with XIDs yourself.

But please be aware, XIDs are in an early development stage, and our experiments may not be the best way to do things. It's especially important to note that the methodologies that we're working with here have not been security tested. What does it really mean to have an elision-first philosophy? What are the ramifications of including, then eliding private keys? Is the current XID structure the best one from a security point of view?

These are the type of questions we're asking here, and indeed we've refined and revisited some of our answers as we iterated these documents.

We welcome your experiments and your feedback (as issues, PRs, or in direct conversation), but we do not yet suggest using this work in any type of deployed system.

## Project Status - Experimental

These tutorials are currently in an experimental state. While usable for learning purposes, the underlying technologies and APIs may change significantly as development continues.

## Contributing

We encourage public contributions through issues and pull requests! Please review [CONTRIBUTING.md](./CONTRIBUTING.md) for details on our development process. All contributions to this repository require a GPG signed [Contributor License Agreement](./CLA.md).

## Author

Originally developed by Christopher Allen. Maintained by the Blockchain Commons team.

## Gordian Principles

The [Gordian Principles](https://github.com/BlockchainCommons/Gordian#gordian-principles) describe the requirements for our Gordian-compliant reference apps, including:

* Independence: DIDs and keys must remain in users' control
* Privacy: Tools must not share data without explicit permission
* Resilience: Solutions must be able to recover from failures
* Openness: Open-source code base and development

XIDs build on these principles by providing a stable identity that remains under your control, even as your cryptographic keys change over time.

## License

This tutorial content is licensed under a [Creative Commons Attribution 4.0 International License](LICENSE-CC-BY-4.0) with script examples in [BSD-2-Clause Plus Patent License](LICENSE-BSD-2-Clause-Patent.md).

## Financial Support

These tutorials are a project of [Blockchain Commons](https://www.blockchaincommons.com/). We are proudly a "not-for-profit" social benefit corporation committed to open source & open development. Our work is funded entirely by donations and collaborative partnerships with people like you. Every contribution will be spent on building open tools, technologies, and techniques that sustain and advance blockchain and internet security infrastructure and promote an open web.

To financially support further development of these tutorials and other projects, please consider becoming a Patron of Blockchain Commons through ongoing monthly patronage as a [GitHub Sponsor](https://github.com/sponsors/BlockchainCommons).
