# XID Tutorials

Welcome to the eXtensible IDentifiers (XIDs) tutorial series. These tutorials will guide you through creating, understanding, and working with XIDs - a powerful identity framework built on Gordian Envelope technology.

## Getting Started

To complete these tutorials, you'll need:

1. The `envelope` CLI tool installed
2. Basic familiarity with the command line
3. No prior knowledge of XIDs or Gordian Envelope is required

## Tutorial Structure

The tutorials are designed to be completed in order:

1. [Creating Your First XID](01-your-first-xid.md) - Learn to create a basic XID and understand its components
2. [Understanding XID Structure](02-understanding-xid-structure.md) - Explore the inner workings of XIDs
3. [Self-Attestation with XIDs](03-self-attestation-with-xids.md) - Create structured self-claims with verifiable evidence
4. [Peer Endorsement with XIDs](04-peer-endorsement-with-xids.md) - Build a network of trust through independent verification
5. [Key Management with XIDs](05-key-management-with-xids.md) - Learn to manage keys while maintaining identity

Each tutorial builds on skills from previous sections. Complete working examples for each tutorial can be found in the `examples` directory.

## Key Concepts

XIDs (eXtensible IDentifiers) provide:

- **Stable Identity**: Your identifier remains stable even as keys change
- **Self-Sovereign Control**: You control your identity, not a third party
- **Cryptographic Verification**: Digitally sign and verify information
- **Privacy Features**: Selectively share aspects of your identity

## Running the Examples

For each tutorial, there is a corresponding example script in the `examples` directory. These scripts implement the full functionality covered in the tutorials.

To run an example:

👉 
```sh
cd examples/01-basic-xid
./create_basic_xid.sh
```

## Next Steps

After completing these tutorials, you'll be able to:

- Create and manage XIDs
- Understand the relationship between XIDs and cryptographic keys
- Build rich, structured identity profiles
- Sign and verify data using your XID

Advanced tutorials on secure messaging, selective disclosure, and integration with other systems will be coming soon.