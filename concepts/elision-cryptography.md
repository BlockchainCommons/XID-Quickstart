# Elision Cryptography

## Expected Learning Outcomes

By the end of this document, you will:

- Learn how cryptography & the structure of Gordian Envelope enable secure elision
- Know the different types of elision and their specific cryptographic effects
- See how cryptographic signatures remain valid after content is removed
- Learn how to verify and validate elided content
- Understand how salting prevents correlation attacks on elided content

> **Related Concepts**: This document focuses on the technical aspects of elision. For the ethical principles and applications of data minimization, see [Data Minimization Principles](data-minimization-principles.md).

## The Cryptographic Structure of Gordian Envelopes

Elision works because of the specific cryptographic design of Gordian
Envelopes. They use a hierarchical hash-based structure that enables
selective removal while maintaining overall integrity.

### Structural Elements

As discussed in [Gordian Envelope Basics](gordian-envelope.md), each
Envelope contains a Subject, and an Assertion made up of a Predicate
and an Object: the Subject Predicates the Object.

### Hash-Based Integrity

Each component of the envelope is cryptographically bound through hashes:

1. **Component Hashing**: Every element (subject, predicate, object) is individually hashed.
2. **Hierarchical Structure**: These hashes form a Merkle tree-like structure.
3. **Structural Integrity**: Parent nodes sum up hashes of their children.
4. **Root Validation**: The envelope's root hash sups up the entire structure.

### Advanced Technical Considerations

For implementers and cryptography specialists:

1. **Hash Algorithm**: Elision typically uses SHA-256 for structural hashing
2. **Elision Marking**: The CBOR encoding includes special tags to mark elided content
3. **Signature Algorithm Compatibility**: Works with standard digital signature algorithms
4. **Nested Elision**: Supports hierarchical elision of nested structures


## The Elision Process

When content is elided, it undergoes a cryptographically secure
one-way transformation:

```
Original Content:  "name": "BWHacker"
↓
Elision Process:   hash("name": "BWHacker" + salt)
↓  
Result:            ELIDED: h'8d7f117fa8511c9c...'
```

The elided content is replaced by its cryptographic digest, which:

- Is a fixed-length representation of the original data
- Cannot be reversed to reveal the original content (one-way function)
- Uniquely identifies exactly what was elided
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
   - A signature in a Gordian Envelope covers the whole Envelope or a sub-Envelope.
   - It signs that Envelope or sub-Envelope's root hash, which represents the complete document.
2. **Hash Substitution During Elision**:
   - As discussed above, hashes remain intact even when the data underlying them is elided.
3. **Verification After Elision**:
   - When verifying a signature on an elided document:
     - The signature validates against thie Envelope or sub-Envelope's hash, not the original content.

This mechanism allows for the removal of sensitive content while
ensuring that signatures attesting to the contents' authenticity
remain valid.

## Types of Elision and Their Effects

Gordian Envelopes support different types of elision for different disclosure needs:

### 1. Predicate Elision (Hide the Attribute Name)

```sh
envelope elide assertion predicate string "phoneNumber" "$ENVELOPE"
```

Cryptographic effect:
- Replaces the field name with its hash
- Keeps the value visible
- Hides what type of information is being shared
- Use when: The value is safe to share but the category is sensitive

### 2. Object Elision (Hide the Value)

```sh
envelope elide assertion object "$ENVELOPE"
```

Cryptographic effect:
- Keeps the field name visible
- Replaces the value with its hash
- Shows that a specific type of information exists without revealing it
- Use when: Acknowledging the existence of information without disclosing it

### 3. Assertion Elision (Hide Both Name and Value)

```sh
envelope elide assertion "$ENVELOPE"
```

Cryptographic effect:
- Replaces the entire name-value pair with its hash
- Hides both the type and content of information
- Preserves only the fact that some information existed
- Use when: The entire attribute is sensitive

### 4. Subject Elision (Hide the Identity)

```sh
envelope elide subject "$ENVELOPE"
```

Cryptographic effect:
- Replaces the subject identifier with its hash
- Preserves all assertions about the subject
- Hides who or what the information is about
- Use when: The subject's identity should remain private while sharing claims about them

## Verification Techniques with Elided Content

Several verification methods are available for elided content:

### 1. Signature Verification

```sh
envelope verify -v "$PUBLIC_KEY" "$ELIDED_ENVELOPE"
```

This confirms:
- The envelope was signed by the claimed entity
- No part of the content has been tampered with
- All elisions were performed correctly

### 2. Structural Integrity Verification

```sh
envelope extract digest "$ELIDED_ENVELOPE"
```

This confirms:
- The overall structure remains intact
- All hashing relationships are preserved
- The envelope maintains its cryptographic consistency

### 3. Known-Content Verification

```sh
ELIDED_HASH=$(envelope extract elided-digest "$ELIDED_ENVELOPE")
EXPECTED_HASH=$(envelope digest string "expected-content" --salt "$SHARED_SALT")
if [ "$ELIDED_HASH" = "$EXPECTED_HASH" ]; then echo "Verified content was elided"; fi
```

This confirms:
- What was elided (with shared salt)

## Cryptographic Security Guarantees

Elision in Gordian Envelopes provides these specific security guarantees:

1. **Structural Integrity**: The cryptographic structure remains intact and verifiable
2. **Tamper Evidence**: Any modification to elements in the Envelope invalidates signatures
3. **Non-Reversibility**: Elided content cannot be recovered from its hash
4. **Salt-Based Privacy**: With salting, identical content produces different hashes
5. **Mathematical Soundness**: Based on cryptographically secure hash functions

## Practical Examples

### Example 1: Field Elision with Complete Input/Output

Original envelope:
```
"API Security Enhancement" [
   "methodology": "Static analysis with open source tools"
   "limitations": "No penetration testing performed"
   "dataSources": "Public API documentation"
   SIGNATURE
]
```

Command to elide the "limitations" field:
```sh
ELIDED_DOC=$(envelope elide assertion predicate string "limitations" "$ORIGINAL_DOC")
```

Resulting envelope:
```
"API Security Enhancement" [
   "methodology": "Static analysis with open source tools"
   ELIDED: h'8d7f117fa8511c9c8ef2092176596cca48a797c69e0a0e12a244faea715a8f82'
   "dataSources": "Public API documentation"
   SIGNATURE
]
```

The signature verification still works because the hash maintains the cryptographic structure:
```sh
envelope verify -v "$PUBLIC_KEY" "$ELIDED_DOC"
# Result: ✅ Signature verified successfully
```

### Example 2: Multiple Field Elision for Different Contexts

Original document:
```
"Professional Review" [
   "reviewer": "Senior Security Auditor"
   "company": "SecureReview Inc."
   "internalID": "SR-2023-0472"
   "finding": "API authentication implementation is robust"
   "severity": "Pass"
   "billingCode": "ACCT-7729-B"
   SIGNATURE
]
```

Elision for sharing with client (removing internal fields):
```sh
CLIENT_DOC=$(envelope elide assertion predicate string "internalID" "$ORIGINAL_DOC")
CLIENT_DOC=$(envelope elide assertion predicate string "billingCode" "$CLIENT_DOC")
```

Resulting client-appropriate document:
```
"Professional Review" [
   "reviewer": "Senior Security Auditor"
   "company": "SecureReview Inc."
   ELIDED: h'a1c8b3d7e5f2a6c9b4d8e2f1a3c6b9d8e5f2a1c4b7d8e5f2a1c4b7d8e5f2a1c4'
   "finding": "API authentication implementation is robust"
   "severity": "Pass"
   ELIDED: h'f2e1d5c8b3a6f9e2d5c8b3a6f9e2d5c8b3a6f9e2d5c8b3a6f9e2d5c8b3a6f9e2'
   SIGNATURE
]
```

These examples demonstrate how elision preserves both the signature
validity and structural integrity of documents while allowing
appropriate content sharing for different contexts.

## Salting for Privacy Protection

Salting is a critical privacy enhancement for Gordian Envelopes that
keeps elided data remains private. It ensures that even when the same
information is elided from multiple documents, the resulting hashes
are different, preventing correlation attacks.

### The Problem Without Salting

Without salting, elision would have a serious privacy weakness:

- Identical content would produce identical hashes.
- This would allow correlation between different elided documents.
- An observer could determine if the same information was elided across documents.
- Common values could be guessed through dictionary attacks.

### How Salting Works

Salting solves this by adding random data to an Envelope leaf or node before hashing:

```
Without salt:  hash("name": "John Smith") → always the same hash
With salt:     hash("name": "John Smith" + random_salt) → different hash each time
```

### Salting Implementation

The
[envelope-cli](https://github.com/BlockchainCommons/bc-envelope-cli-rust)
can explicitly add salt or not to any Envelope element:

```sh
# Default behavior uses random salt
ELIDED_XID=$(envelope elide assertion predicate string "email" "$ENVELOPE")

# Explicitly no salt (NOT recommended for privacy)
ELIDED_XID=$(envelope elide --no-salt assertion predicate string "email" "$ENVELOPE")
```

### Advanced Technical Considerations

For implementers and cryptography specialists:

1. **Salt Entropy**: Salts should be cryptographically random and of sufficient length

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

## Appendix: Implementation Guide

This section provides practical guidance for implementing elision in your own applications.

### Implementation Workflow

1. **Create and Sign the Complete Document First**
   ```sh
   # Create the complete document with all possible information
   COMPLETE_DOC=$(envelope subject type string "Complete Profile")
   COMPLETE_DOC=$(envelope assertion add pred-obj string "attribute1" string "value1" "$COMPLETE_DOC")
   COMPLETE_DOC=$(envelope assertion add pred-obj string "sensitiveAttribute" string "sensitiveValue" "$COMPLETE_DOC")
   
   # Sign the complete document before any elision
   SIGNED_DOC=$(envelope sign -s "$PRIVATE_KEY" "$COMPLETE_DOC")
   ```

2. **Elide Based on Context and Audience**
   ```sh
   # Create different views by eliding different parts
   PUBLIC_VIEW=$(envelope elide assertion predicate string "sensitiveAttribute" "$SIGNED_DOC")
   
   # Multiple elisions can be applied sequentially
   MINIMAL_VIEW=$(envelope elide assertion predicate string "attribute1" "$PUBLIC_VIEW")
   ```

3. **Verify Elided Documents**
   ```sh
   # Always verify that signatures remain valid after elision
   envelope verify -v "$PUBLIC_KEY" "$PUBLIC_VIEW"
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

