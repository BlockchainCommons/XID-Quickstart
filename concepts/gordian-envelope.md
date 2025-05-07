# Gordian Envelope Basics

## Expected Learning Outcomes

By the end of this document, you will:

- Understand the structure and purpose of Gordian Envelopes
- Know how the subject-assertion-object model works
- Understand how signing and verification function with Envelopes
- See how Envelopes enable both verification and privacy

## What is a Gordian Envelope?

A Gordian Envelope is a data structure that combines:

- Structured semantic information (like who did what)
- Cryptographic verification (like digital signatures)
- Selective disclosure capabilities (through elision)

Think of an envelope as a container that can hold information in a
structured way, be securely sealed to verify its source, and have
parts selectively revealed while keeping other parts private.

## The Subject-Assertion-Object Model

Gordian Envelopes use a structure similar to sentences in natural language:

```
<SUBJECT> [
   <PREDICATE>: <OBJECT>
   <PREDICATE>: <OBJECT>
   ...
]
```

For example:
```
"BWHacker" [
   "name": "BWHacker"
   "domain": "Distributed Systems & Security"
   "experienceLevel": "8 years professional practice"
]
```

In this structure:
- **Subject**: The main entity the envelope is about ("BWHacker")
- **Predicate**: A property or relationship ("domain", "experienceLevel")
- **Object**: The value of that property ("Distributed Systems & Security")

This structure creates clear, semantic relationships that are both
human-readable and machine-processable.

### Types of Assertions You Can Make

You can make various types of assertions within an envelope:

1. **String assertions**: Simple text values
   ```
   "name": "BWHacker"
   ```

2. **Structured data assertions**: Complex data types
   ```
   "location": {
      "latitude": 47.6062
      "longitude": -122.3321
   }
   ```

3. **Nested envelope assertions**: Envelopes within envelopes
   ```
   "project": ProjectEnvelope [...]
   ```

4. **Cryptographic assertions**: Digests, signatures, etc.
   ```
   "documentHash": SHA256(a7f3ec...)
   ```

## Signing and Verification

Envelopes can be cryptographically signed to verify:

- Who created or endorsed an Envelope
- That the content hasn't been altered since signing

The signing process consists of two steps:

1. A private key is used to generate a digital signature of the envelope
2. The signature is attached to the envelope

In the [envelope-cli
tool](https://github.com/BlockchainCommons/bc-envelope-cli-rust), the
process looks like this:

```sh
PRIVATE_KEYS=$(envelope generate prvkeys)
PUBLIC_KEYS=$(envelope generate pubkeys "$PRIVATE_KEYS")
SIGNED_PROPOSAL=$(envelope sign -s "$PRIVATE_KEYS" "$PROPOSAL")
```

In the verification process, the public of the keypair is then used to
verify the signature. This confirms the envelope was signed by
the corresponding private key.

```sh
envelope verify -v "$PUBLIC_KEYS" "$SIGNED_PROPOSAL"
```

This creates non-repudiation: the signer cannot deny creating the
signature if it verifies with their public key.

### Wrapping & Signing

Any assertion in Envelope always applys to its subject: the subject
predicates the object. This applies to signatures too: a signature
signs the subject. It does _not_ sign the other assertions on that
subject.

As a result, the following is usually not what's intended:

```
"BWHacker" [
   "name": "BWHacker"
   "domain": "Distributed Systems & Security"
   "experienceLevel": "8 years professional practice"
   SIGNATURE
]
```

That `SIGNATURE` only applies to `BWHacker`, not to the assertions
about their experience.

The solution is to "wrap" the envelope before signing it, creating a new envelope with the original envelope as its subject. This way, the signature applies to the entire original envelope, including all its assertions.

```sh
# First create your envelope with all assertions
ENVELOPE=$(envelope subject type string "BWHacker")
ENVELOPE=$(envelope assertion add pred-obj string "name" string "BWHacker" "$ENVELOPE")
ENVELOPE=$(envelope assertion add pred-obj string "domain" string "Distributed Systems & Security" "$ENVELOPE")
ENVELOPE=$(envelope assertion add pred-obj string "experienceLevel" string "8 years professional practice" "$ENVELOPE")

# Wrap the envelope before signing
WRAPPED_ENVELOPE=$(envelope subject type wrapped "$ENVELOPE")

# Sign the wrapped envelope
SIGNED_ENVELOPE=$(envelope sign -s "$PRIVATE_KEYS" "$WRAPPED_ENVELOPE")
```

This creates a structure where the signature applies to the entire original envelope:

```
WRAPPED [
   subject: "BWHacker" [
      "name": "BWHacker"
      "domain": "Distributed Systems & Security"
      "experienceLevel": "8 years professional practice"
   ]
   SIGNATURE
]
```

This approach ensures the signature verifies the integrity of all assertions in the original envelope, not just its subject.

## Enabling Both Verification and Privacy

One of the most powerful features of Gordian Envelopes is the ability
to maintain cryptographic verification even when parts of the data are
hidden through elision.

For example, if you have a properly wrapped and signed envelope:

```
WRAPPED [
   subject: "BWHacker" [
      "name": "BWHacker"
      "domain": "Distributed Systems & Security"
      "experienceLevel": "8 years professional practice"
   ]
   SIGNATURE
]
```

You can elide (remove) the "experienceLevel" assertion while maintaining the signature's validity:

```
WRAPPED [
   subject: "BWHacker" [
      "name": "BWHacker"
      "domain": "Distributed Systems & Security"
      ELIDED
   ]
   SIGNATURE
]
```

The signature remains valid because the cryptographic structure of the envelope preserves the integrity of the relationship between the remaining assertions and the signature, while replacing the elided assertion with a cryptographic placeholder.

This allows for:
- Revealing different information to different audiences
- Progressive disclosure as trust develops
- Minimizing data exposure while maintaining verification
- Privacy-preserving information sharing

## Using Envelopes with XIDs

XIDs use Gordian Envelopes as their container format, which enables:
1. Structured, semantic representation of identity information
2. Cryptographic verification of identity control
3. Selective disclosure for privacy protection
4. Progressive trust building through controlled information sharing

For example, the XID document from Tutorial 2:
```
"BWHacker" [
   "name": "BWHacker"
   "publicKeys": ur:crypto-pubkeys/hdcx...
   "domain": "Distributed Systems & Security"
   "experienceLevel": "8 years professional practice"
   "key": [
      ur:crypto-pubkeys/hdcx...
      "Tablet Key"
      "sign"
   ]
]
```

## Practical Examples

1. **Identity Information**: Structuring claims about a person or entity
2. **Signed Documents**: Creating verifiable records and attestations
3. **Evidence Commitments**: Committing to evidence without revealing it prematurely
4. **Trust Assertions**: Making claims that others can verify and build upon

## Check Your Understanding

1. What is the basic structure of a Gordian Envelope?
2. How does the subject-assertion-object model represent information?
3. What happens when an envelope is signed, and how is the signature verified?
4. How can an envelope be elided while maintaining signature validity?
5. Why is the combination of verification and privacy so powerful?

## Next Steps

After understanding Gordian Envelope basics, you can:
- Apply these concepts in [Tutorial 1: Creating Your First XID](../tutorials/01-your-first-xid.md) and [Tutorial 2: Understanding XID Structure](../tutorials/02-understanding-xid-structure.md)
- Learn about [Data Minimization Principles](data-minimization-principles.md)
- Explore [Fair Witness Approach](fair-witness-approach.md)