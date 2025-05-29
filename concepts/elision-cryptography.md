# Elision Cryptography

## Expected Learning Outcomes

By the end of this document, you will:

- Learn how cryptography & the structure of Gordian Envelope enable secure elision
- Know the different types of elision and their specific privacy support
- See how cryptographic signatures remain valid after content is removed
- Learn how to verify and validate elided content
- Understand how salting prevents correlation attacks on elided content

> **Related Concepts**: This document focuses on the technical aspects
of elision. For the ethical principles and applications of data
minimization, see [Data Minimization Principles](data-minimization-principles.md).

## The Cryptographic Structure of Gordian Envelopes

Elision is the process of removing content. Gordian Envelope has been
specifically built to support the elision of some or all content
within an envelope: the hierarchical hash-based structure enables
selective removal while maintaining overall integrity.

### Structural Elements

As discussed in [Gordian Envelope Basics](gordian-envelope.md), each
envelope contains a subject and an assertion made up of a predicate
and an object: the subject predicates the object.

### Hash-Based Integrity

Each element of an envelope is cryptographically bound through hashes:

1. **Component Hashing**: Every element (subject, predicate, object) is individually hashed.
2. **Hierarchical Structure**: These hashes form a Merkle-like tree structure.
3. **Structural Integrity**: Parent nodes sum up hashes of their children.
4. **Root Validation**: The envelope's root hash sums up the entire structure.

### Advanced Technical Considerations

For implementers and cryptography specialists:

1. **Nested Elision**: Nested structures in a hierarchy can be elided.
2. **Hash Algorithm**: Elision typically uses SHA-256 for structural hashing.
3. **Elision Marking**: The CBOR encoding includes special tags to mark elided content.
4. **Signature Algorithm Compatibility**: Elided content can still be validated with standard digital signature algorithms.

## The Elision Process

When content is elided, it undergoes a cryptographically secure
one-way transformation:

```
Original Content:  "name": "BRadvoc8"
↓
Elision Process:   hash("name": "BRadvoc8" + [optionally] salt)
↓  
Result:            ELIDED: h'8d7f117fa8511c9c...'
```

The elided content is replaced by its cryptographic digest, which:

- Is a fixed-length representation of the original data
- Cannot be reversed to reveal the original content (one-way function)
- Uniquely identifies exactly what was elided
- Can avoid correlation if combined with salt
- Preserves the existing relationships in the document's tree structure

## Merkle-Like Tree Architecture and Elision

Gordian Envelopes implement a structure similar to a Merkle tree, which enables selective removal:

```
                Root Hash
                /      \
          Hash A        Hash B
         /     \        /    \
    Hash A1   Hash A2  Hash B1  Hash B2
    (elided)         (elided)
```

When elision occurs, the content is replaced with its hash, but all
parent hashes remain valid because they incorporate those child
hashes. This hash-based architecture is what allows for selective
disclosure while still ensuring that the overall structure remains
cryptographically sound.

## Signature Preservation During Elision

One of the most powerful features of elision is signature preservation. Here's why signatures remain valid:

1. **Digital Signature Process**:
   - A signature in a Gordian Envelope covers the whole envelope or a sub-envelope.
   - It signs that envelope or sub-envelope's root hash, which represents the complete document.
2. **Hash Substitution During Elision**:
   - As discussed above, hashes remain intact even when the data underlying them is elided.
3. **Verification After Elision**:
   - When verifying a signature on an elided document:
     - The signature validates against the envelope or sub-envelope's hash, not the original content.

This mechanism allows for the removal of sensitive content while
ensuring that signatures attesting to the contents' authenticity
remain valid.

## Types of Elision and Their Effects

Gordian Envelopes support different types of elision for different
disclosure needs. Each one substitutes one part of an envelope with a hash.

1. Subject Elision: hides the identity (e.g., "Alice")
2. Predicate Elision: hides the assertion predicate (e.g., "read")
3. Object Elision: hides the assertion object (e.g., "Pride & Prejudice")
4. Assertion Elision: Hides all of the assertion (e.g., "read Pride & Prejudice")
5. Envelope Elision: hides the entire envelope or subenvelope (e.g., "Alice read Pride & Prejudice")

Obviously, different types of elision will have different uses
depending on the sensitivity of the various parts (is identity
sensitive? is category of information sensitive? is value of
information sensitive?) and some are more powerful than others

## Cryptographic Security Guarantees

Elision in Gordian Envelopes provides these specific security guarantees:

1. **Structural Integrity**: The cryptographic structure remains intact and verifiable.
2. **Tamper Evidence**: Any modification to elements in the Envelope invalidates signatures.
3. **Non-Reversibility**: Elided content cannot be recovered from its hash.
4. **Salt-Based Privacy**: With salting, identical content produces different hashes.
5. **Mathematical Soundness**: Protection is based on cryptographically secure hash functions.

## Salting for Privacy Protection

Salting is a critical privacy enhancement for Gordian Envelopes that
keeps elided data private. It ensures that even when the same
information is elided from multiple documents, the resulting hashes
are different, preventing correlation attacks.

### The Problem Without Salting

Without salting, elision would have a serious privacy weakness:

- Identical content would produce identical hashes.
- This would allow correlation between different elided documents.
- An observer could determine if the same information was elided in multiple documents.
- Common values could be guessed through dictionary attacks.

### How Salting Works

Salting solves this by adding random data to an Envelope leaf or node before hashing:

```
Without salt:  hash("name": "John Smith") → always the same hash
With salt:     hash("name": "John Smith" + random_salt) → different hash each time
```

### Advanced Technical Considerations

For implementers and cryptography specialists:

1. **Salt Entropy**: Salts should be cryptographically random and of sufficient length


## Practical Implementation: Elision

### Example 1: Field Elision with Complete Input/Output

A single assertion is elided from a signed envelope to protect security.

Original envelope:
```
SIGNED_DOC=$(envelope subject type string "API Security Enhancement" | envelope assertion add pred-obj string methodology string "Static analysis with open source tools" | envelope assertion add pred-obj string limitations string "No penetration testing performed" | envelope assertion add pred-obj string dataSources string "Public API documentation" | envelope subject type wrapped | envelope sign -s $PRIVATE_KEYS)
```

```
{
    "API Security Enhancement" [
        "dataSources": "Public API documentation"
        "limitations": "No penetration testing performed"
        "methodology": "Static analysis with open source tools"
    ]
} [
    'signed': Signature
]
```

Command to elide the "limitations" field:
```sh
LIMITATIONS_DIGEST=$(envelope extract wrapped $SIGNED_DOC | envelope assertion find predicate string "limitations")
ELIDED_DOC=$(envelope elide removing $LIMITATIONS_DIGEST $SIGNED_DOC)
```

Resulting envelope:
```
{
    "API Security Enhancement" [
        "dataSources": "Public API documentation"
        "methodology": "Static analysis with open source tools"
        ELIDED
    ]
} [
    'signed': Signature
]
```

The signature verification still works because the hash maintains the cryptographic structure:
```sh
envelope verify -v $PUBLIC_KEYS $ELIDED_DOC
# Result: ✅ Signature verified successfully
```

### Example 2: Multiple Field Elision for Different Contexts

Multiple assertions are removed from a signed internal envelope to
producce a customer-facing envelope.

Original document:
```
{
    "Professional Review" [
        "billingCode": "ACCT-7729-B"
        "company": "SecureReview Inc."
        "finding": "API authentication implementation is robust"
        "internalID": "SR-2023-0472"
        "reviewer": "Senior Security Auditor"
        "severity": "Pass"
    ]
} [
    'signed': Signature
]
```

Elision for sharing with client (removing internal fields):
```sh
ELIDED_DIGEST=()
ELIDED_DIGEST+=$(envelope extract wrapped $ORIGINAL_DOC | envelope assertion find predicate string "internalID")
ELIDED_DIGEST+=$(envelope extract wrapped $ORIGINAL_DOC | envelope assertion find predicate string "billingCode") 
CLIENT_DOC=$(envelope elide removing "$ELIDED_DIGEST" $ORIGINAL_DOC)
```

Resulting client-appropriate document:
```
{
    "Professional Review" [
        "company": "SecureReview Inc."
        "finding": "API authentication implementation is robust"
        "reviewer": "Senior Security Auditor"
        "severity": "Pass"
        ELIDED (2)
    ]
} [
    'signed': Signature
]
```

Again, this demonstrate how elision preserves both the signature
validity and structural integrity of documents while allowing
appropriate content sharing for different contexts.

## Practical Implementation: Salting

The
[envelope-cli](https://github.com/BlockchainCommons/bc-envelope-cli-rust)
can explicitly add salt or not to any Envelope element.

```sh
# Default behavior does not include salt:
envelope subject type string alice | envelope assertion add pred-obj string knows string bob | envelope format
"alice" [
    "knows": "bob"
]


# The salt command adds salt just like another assertion.
# This will protect the "alice" envelope when elided:
envelope subject type string alice | envelope assertion add pred-obj string knows string bob | envelope salt | envelope format
"alice" [
    "knows": "bob"
    'salt': Salt
]

# This will instead protect the "knows bob" assertion
KB=$(envelope assertion create string knows string bob | envelope salt)
AKB_S=$(envelope subject type string alice | envelope assertion add envelope $KB)
envelope format $AKB_S
"alice" [
    {
        "knows": "bob"
    } [
        'salt': Salt
    ]
]
```

## Practical Implementation: Verification

Several verification methods are available for elided content:

### 1. Structural Integrity Verification

Verify an envelope's structure.
```sh
envelope digest "$ELIDED_ENVELOPE"
```

This should return a `ur:digest`.

This confirms:
- The overall structure remains intact.

### 2. Signature Verification

Verify an envelope's signature.

```sh
envelope verify -v "$PUBLIC_KEY" "$ELIDED_ENVELOPE"
```
This will either return `Error: could not verify a signature` (for
failure) or the envelope (for success).

This confirms:
- The envelope was signed by the claimed entity.
- No part of the content has been changed since signature.

### 3. Elided Content Verifications

Verify an envelope hasn't been changed.
```sh
ORIG_DIGEST=$(envelope digest $ENVELOPE)
ELIDED_DIGEST=$(envelope digest $ELIDED_ENVELOPE)
if [ "$ORIG_DIGEST" = "$ELIDED_DIGEST" ]; then echo "Verified content was elided"; fi
```
This should return "Verified content was elided".

This confirms:
- The elided envelope matches the original envelope before elision.

### 4. Known-Content Verification

Verify the contents of an elided envelope (for example "knows bob").

```
ELIDED_DIGEST=$(envelope assertion at 0 $AKB_E | envelope digest) 
EXPECTED_DIGEST=$(envelope assertion create string knows string bob | envelope digest)
if [ "$ELIDED_DIGEST" = "$EXPECTED_DIGEST" ]; then echo "Elided content is 'knows bob'"; fi
```
Note that this just checks the 0th assertion in the elided envelope. A
more robust program would check against all of them.

This should return "Elided content is 'knows bob'.

This confirms:
- The elided content matches the expected content.

### 5. Known-Content Verification with Salt

Verify the contents of an elided and salted envelope (for example "knows bob" with $SALT on the assertion)..

If a "knows" envelope assertion is salted with `salt` (see below),
an envelope of the salt can be retrieved as follows:
```
SALT=$(envelope assertion find predicate string knows $AKB_S | envelope assertion find predicate known salt | envelope extract object)
```

The same process as "Known-Content Verification" is then followed, but
it's testing against an assertion salted with the shared `$SALT`
secret.

```
ELIDED_DIGEST=$(envelope assertion at 0 $AKB_S_E | envelope digest)
EXPECTED_DIGEST=$(envelope assertion create string knows string bob | envelope assertion add pred-obj known salt envelope $SALT | envelope digest)
if [ "$ELIDED_DIGEST" = "$EXPECTED_DIGEST" ]; then echo "Elided content is 'knows bob' with the salt"; fi
```

This should return "Elided content is 'knows bob'.

This confirms:
- The elided content matches the expected content (with shared salt).


## Check Your Understanding

1. How does the hash-based structure of Gordian Envelopes enable elision?
2. Why do digital signatures remain valid after parts of a document are elided?
3. What are the differences between predicate, object, and assertion elision?
4. How can you verify the content of something that has been elided?
5. What specific cryptographic problem does salting solve in elision?

## Next Steps

After understanding the cryptographic mechanics of elision, you can:

- Learn about the ethical principles in [Data Minimization Principles](data-minimization-principles.md)
- Apply this knowledge in [Tutorial 2: Understanding XID Structure](../tutorials/02-understanding-xid-structure.md)
- See how elision is used in real-world applications in later tutorials
- Alternatively explore [fair witness trust](fair-witness.md) or [key-management essentials](key-management.md).
- Move on to [progressive trust](progressive-trust.md)

## Appendix: Practical Implementation Guide

This section provides practical guidance for implementing elision in your own applications.

### Implementation Workflow

0. **Create Keys for Use**

   ```sh
   PRIVATE_KEY=$(envelope generate prvkeys)
   PUBLIC_KEY=$(envelope generate pubkeys $PRIVATE_KEY)
   ```
   
1. **Create and Sign the Complete Document First**
   ```sh
   # Create the complete document with all possible information
   COMPLETE_DOC=$(envelope subject type string "Complete Profile")
   COMPLETE_DOC=$(envelope assertion add pred-obj string "attribute1" string "value1" "$COMPLETE_DOC")
   COMPLETE_DOC=$(envelope assertion add pred-obj string "sensitiveAttribute" string "sensitiveValue" "$COMPLETE_DOC")
   
   # Sign the complete document before any elision
   WRAPPED_DOC=$(envelope subject type wrapped $COMPLETE_DOC)
   SIGNED_DOC=$(envelope sign -s $PRIVATE_KEY $WRAPPED_DOC)
   ```

2. **Elide Based on Context and Audience**
   ```sh
   # Create different views by eliding different parts
   SENSITIVE_VALUE_DIGEST=$(envelope extract wrapped $SIGNED_DOC | envelope assertion find predicate string "sensitiveAttribute")
   PUBLIC_VIEW=$(envelope elide removing $SENSITIVE_VALUE_DIGEST $SIGNED_DOC)
   
   # Multiple elisions can be applied sequentially
   ATTRIBUTE1_DIGEST=$(envelope extract wrapped $SIGNED_DOC | envelope assertion find predicate string "attribute1")
   MINIMAL_VIEW=$(envelope elide removing $ATTRIBUTE1_DIGEST $PUBLIC_VIEW)
   ```

3. **Verify Elided Documents**
   ```sh
   # Always verify that signatures remain valid after elision
   envelope verify -v $PUBLIC_KEY $MINIMAL_VIEW
   ```

### Common Pitfalls and Solutions

1. **Eliding After Signing**
   - ✅ **Do**: Always sign the complete document before elision
   - ❌ **Don't**: Sign an already elided document, as you don't know what you're signing

2. **Salt Management**
   - ✅ **Do**: Use the default salt for most use cases
   - ✅ **Do**: Document when explicit salt values are used (for verification purposes)
   - ❌ **Don't**: Disable salting for privacy-sensitive data

3. **Consistent Structure**
   - ✅ **Do**: Maintain a consistent structure for your envelopes
   - ❌ **Don't**: Change the hierarchical relationships after establishing a structure

4. **Handling Nested Structures**
   - ✅ **Do**: Consider elision impact on nested assertions
   - ❌ **Don't**: Assume nested content is automatically elided with its parent

### Performance Considerations

1. **Document Size**: Elision replaces content with 32-byte hashes, which usually doesn't dramatically reduce document size
2. **Computation Cost**: Elision operations are computationally inexpensive
3. **Verification Overhead**: Verification of elided documents takes approximately the same time as non-elided ones

