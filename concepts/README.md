# XID Tutorial: Core Concepts

This directory contains conceptual documentation to help you understand the theoretical foundations behind the practical tutorials.

## Start Here

If you're new to XIDs and Gordian Envelopes, we recommend reading these concepts in the following order:

1. [XID Fundamentals](xid-fundamentals.md) - Understanding the basics of eXtensible IDentifiers
2. [Gordian Envelope Basics](gordian-envelope-basics.md) - The data structure that powers XIDs
3. [Data Minimization Principles](data-minimization-principles.md) - How to control information disclosure
4. [Fair Witness Approach](fair-witness-approach.md) - Making trustworthy assertions
5. [Pseudonymous Trust Building](pseudonymous-trust-building.md) - Building trust without revealing identity
6. [Key Management Essentials](key-management-essentials.md) - Securing and managing cryptographic keys

## Concept Map

The following diagram shows how these concepts relate to each other:

```text
                 ┌───────────────────┐
                 │  XID Fundamentals │
                 └──────────┬────────┘
                            │
                            ▼
             ┌─────────────────────────────┐
             │   Gordian Envelope Basics   │
             └───────────┬─────────────────┘
                         │
           ┌─────────────┴──────────────┐
           │                            │
           ▼                            ▼
┌────────────────────────┐  ┌────────────────────────┐
│ Data Minimization      │  │  Fair Witness         │
│ Principles             │  │  Approach             │
└───────────┬────────────┘  └───────────┬────────────┘
            │                           │
            └────────────┬─────────────┘
                         │
                         ▼
         ┌───────────────────────────────┐
         │  Pseudonymous Trust Building  │
         └───────────────┬───────────────┘
                         │
                         ▼
         ┌───────────────────────────────┐
         │   Key Management Essentials   │
         └───────────────────────────────┘
```

## Relating Concepts to Tutorials

Each concept document supports the practical tutorials:

- **Tutorial 1**: Creating Your First XID
  - Supported by: XID Fundamentals, Gordian Envelope Basics
  
- **Tutorial 2**: Understanding XID Structure
  - Supported by: Gordian Envelope Basics, Data Minimization Principles
  
- **Tutorial 3**: Self-Attestation with XIDs
  - Supported by: Fair Witness Approach, Pseudonymous Trust Building
  
- **Tutorial 4**: Peer Endorsement with XIDs
  - Supported by: Fair Witness Approach, Pseudonymous Trust Building
  
- **Tutorial 5**: Key Management with XIDs
  - Supported by: Key Management Essentials

## Reading Approach

You can approach these concepts in different ways:

1. **Concept First**: Read the concept document before trying the related tutorial
2. **Practice First**: Complete the tutorial, then read the concept to deepen understanding
3. **Reference**: Use the concept documents as reference when you need to clarify something

Choose the approach that works best for your learning style!

## Questions to Consider

As you read these concepts, consider:

1. How does this concept relate to real-world trust and identity?
2. What problems does this approach solve compared to traditional methods?
3. How can I apply these concepts to my own projects?
4. What are the trade-offs between security, privacy, and usability?

## Next Steps

After exploring these concepts, you're ready to:

- Follow the [Learning Path](../LEARNING_PATH.md)
- Try the [Tutorials](../tutorials/)
- Experiment with the [Examples](../examples/)