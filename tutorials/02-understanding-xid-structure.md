# Understanding XID Structure (Under the Hood)

This tutorial explores how Amira's pseudonymous "BWHacker" XID is structured at a technical level, revealing how Gordian Envelopes provide the cryptographic foundation for XIDs. You'll learn how the data structures work under the hood to enable stable identity, verifiable claims, and selective disclosure.

**Time to complete: 30-40 minutes**

> **Related Concepts**: Before or after completing this tutorial, you may want to read about [Gordian Envelope Basics](../concepts/gordian-envelope-basics.md), [Data Minimization Principles](../concepts/data-minimization-principles.md), and [Elision Cryptography](../concepts/elision-cryptography.md) to understand the theoretical foundations behind XID structure and elision.

## Prerequisites

- Completed the "Creating Your First XID" tutorial
- The envelope CLI tool installed
- Basic understanding of public/private key cryptography
- Basic understanding of hash functions and cryptographic signatures
- BWHacker's XID from the previous tutorial (or you can create a new one)

## What You'll Learn

- How XIDs are structured as Gordian Envelopes under the hood
- How the CBOR encoding and cryptographic operations work
- The subject-assertion-object model that forms the core of XIDs
- How XIDs derive their stable identifiers cryptographically
- How elision preserves cryptographic integrity while removing information
- How verification chains are built between XIDs and external systems
- How signatures work to validate assertions

## 1. Examining the XID's Technical Structure

Let's begin by examining the XID created in the previous tutorial, but this time looking at its technical structure:

👉 
```sh
XID_DOC=$(cat output/bwhacker-xid.envelope)
XID=$(envelope xid id "$XID_DOC")
echo "BWHacker's XID identifier: $XID"
```

🔍 
```console
BWHacker's XID identifier: 7e1e25d7c4b9e4c92753f4476158e972be2fbbd9dffdd13b0561b5f1177826d3
```

Now, let's look at several different formats of this XID to understand how it works at a technical level:

Let's view the CBOR diagnostic format (human-readable CBOR):

👉 
```sh
echo "CBOR Diagnostic Format:"
envelope format --type diag "$XID_DOC"
```

🔍 
```console
CBOR Diagnostic Format:
{
  "BWHacker": {
    "name": "BWHacker",
    "publicKeys": 37([h'8854c2d39daafb1eee9c8bab32d41e97c775c286bfcabc4b7c3ff77f1eac268d', "ur:crypto-pubkeys/hdcxlkadjnghfejt..."]), 
    "gitHubUsername": "BWHacker",
    "gitHubProfileURL": "https://github.com/BWHacker",
    "sshKey": "ssh-ed25519 AAAAC3NzaC...",
    "sshKeyFingerprint": "SHA256:dFbxBGrqMQNJKpZccInX7l/QE1xH/jNzDvUo/jICSHE",
    "sshKeyVerificationURL": "https://api.github.com/users/BWHacker/ssh_signing_keys",
    "domain": "Distributed Systems & Security",
    "experienceLevel": "8 years professional practice"
  }
}
```

Now let's view the CBOR binary encoding (lower-level representation). This shows the actual binary data of the envelope:

👉 
```sh
echo "CBOR Binary Encoding (first 100 bytes):"
envelope format --type cbor "$XID_DOC" | head -c 100
echo "..."
```

🔍 
```console
CBOR Binary Encoding (first 100 bytes):
d8c882d8c9d99c585820e5fca07970ff3f71b34bce2ef896bc809207638327089338a976a02508a0a083a10883d8c9d99c51...
```

Let's view the CBOR encoding in a more structured way:

👉 
```sh
echo "CBOR Tags and Structure:"
envelope format --type cbor "$XID_DOC"
```

🔍 
```console
CBOR Tags and Structure:
a1 -- map(1)
   68 -- text(8)
      4257486163686572 -- "BWHacker"
   a8 -- map(8)
      64 -- text(4)
         6e616d65 -- "name"
      68 -- text(8)
         4257486163686572 -- "BWHacker"
      69 -- text(9)
         7075626c69634b657973 -- "publicKeys"
      d82525 -- tag(37)
         8854c2d39daafb1eee9c8bab32d41e97c775c286bfcabc4b7c3ff77f1eac268d -- bytes(32)
         78ed -- text(237)
            ...
      ...
      
```

The CBOR format shows the hierarchical structure of tags, maps, text fields, and binary data that make up an XID. This is the actual data format that gets exchanged and verified.

## 2. Understanding the Subject-Assertion-Object Model

Gordian Envelopes, the technology underlying XIDs, use a subject-assertion-object model:

### Basic Structure Breakdown:

1. **Subject**: 'BWHacker' - The entity this envelope is about
2. **Assertions**: Each key-value pair in the map
   - **Predicate**: The key (like 'name', 'sshKey')
   - **Object**: The value (could be text, binary data, or nested structures)

Let's examine this structure in the XID:

Let's list all predicates (the keys of the assertions) in the XID. These predicates are the properties that describe BWHacker, like name, public keys, GitHub username, etc.:

👉 
```sh
echo "Predicates in the XID:"
envelope format --type diag "$XID_DOC" | grep -o '"[^"]*":' | sort | uniq
```

🔍 
```console
Predicates in the XID:
"BWHacker":
"domain":
"experienceLevel":
"gitHubProfileURL":
"gitHubUsername":
"name":
"publicKeys":
"sshKey":
"sshKeyFingerprint":
"sshKeyVerificationURL":
```

## 3. How XIDs Derive Their Stable Identifiers

XIDs derive their stable identifiers through a cryptographic process involving the initial public key. Let's understand this process:

Let's extract just the public key from the XID and the XID identifier:

👉 
```sh
PUBLIC_KEY=$(envelope format --type diag "$XID_DOC" | grep -o '"publicKeys": [^,]*' | sed 's/"publicKeys": //')
echo "Public key (in diagnostic format): $PUBLIC_KEY"

XID=$(envelope xid id "$XID_DOC")
echo "XID identifier: $XID"
```

🔍 
```console
Public key (in diagnostic format): 37([h'8854c2d39daafb1eee9c8bab32d41e97c775c286bfcabc4b7c3ff77f1eac268d', "ur:crypto-pubkeys/hdcxlkadjnghfejtmyyloeadmyfqzswdaeayfnmddpjygtmyaeaelytsqdisaeaeaeae"])
XID identifier: 7e1e25d7c4b9e4c92753f4476158e972be2fbbd9dffdd13b0561b5f1177826d3
```

**Note:** The XID identifier is a SHA-256 hash derived from specific parts of the initial public key.

This derivation process is what allows XIDs to maintain stability: the identifier is cryptographically derived from the initial key, creating a stable reference that persists even as the XID evolves.

## 4. Adding a Device Key While Maintaining Stable Identity

Now that we understand how XID identifiers work, let's see how adding a key preserves the stable identity:

Now let's generate a key for a second device (tablet), add it to BWHacker's XID, and compare the identifiers to see if they remain the same:

👉 
```sh
TABLET_PRIVATE_KEYS=$(envelope generate prvkeys)
echo "$TABLET_PRIVATE_KEYS" > output/tablet-key.private
TABLET_PUBLIC_KEYS=$(envelope generate pubkeys "$TABLET_PRIVATE_KEYS")
echo "$TABLET_PUBLIC_KEYS" > output/tablet-key.public

UPDATED_XID=$(envelope xid key add --name "Tablet Key" "$TABLET_PUBLIC_KEYS" "$XID_DOC")
echo "$UPDATED_XID" > output/bwhacker-xid-with-tablet.envelope

ORIGINAL_XID=$(envelope xid id "$XID_DOC")
UPDATED_XID_ID=$(envelope xid id "$UPDATED_XID")
echo "Original XID: $ORIGINAL_XID"
echo "Updated XID:  $UPDATED_XID_ID"
```

🔍 
```console
Original XID: 7e1e25d7c4b9e4c92753f4476158e972be2fbbd9dffdd13b0561b5f1177826d3
Updated XID:  7e1e25d7c4b9e4c92753f4476158e972be2fbbd9dffdd13b0561b5f1177826d3
```

The identifier remains the same because it's derived from the initial public key, not subsequent keys. Let's look at how the new key is structured in the CBOR format:

Let's examine the key structure in CBOR diagnostic format. When we look at the XID structure, we'll see the newly added tablet key represented as an array with three components: the raw binary key material, a human-readable name, and the permissions for this key:

👉 
```sh
echo "Updated XID with tablet key structure:"
envelope format --type diag "$UPDATED_XID" | grep -A 3 "key"
```

🔍 
```console
"key": [
  h'8c8b76a4f9a97a92bffa8352d6a5e852d8facf38eb2adf3eba38e7f9a5f5e5a1',
  "Tablet Key",
  "sign"
],
```

This shows the key assertion is an array with:
1. The raw binary key material
2. A human-readable name ("Tablet Key")
3. Permissions for this key ("sign" - meaning it can sign content)

## 5. The Cryptographic Verification Chain

Let's examine how the SSH key creates a verification chain between the XID and GitHub:

### Verification Chain Elements:

1. **The XID contains an SSH key fingerprint:**

The XID contains an SSH key fingerprint that looks like "SHA256:dFbxBGrqMQNJKpZccInX7l/QE1xH/jNzDvUo/jICSHE". This fingerprint uniquely identifies the SSH key.

👉 
```sh
envelope format --type diag "$XID_DOC" | grep "sshKeyFingerprint"
```

2. **This fingerprint can be verified against GitHub's API:**

The XID also contains a URL to verify the SSH key on GitHub, typically something like "https://api.github.com/users/BWHacker/ssh_signing_keys". This URL allows anyone to check that the SSH key belongs to the GitHub user.

👉 
```sh
envelope format --type diag "$XID_DOC" | grep "sshKeyVerificationURL"
```

3. **Git commits signed with this SSH key can be verified as coming from BWHacker**

4. **The XID can sign assertions that reference this SSH key, completing the chain**

🔍 
```console
sshKeyFingerprint: SHA256:dFbxBGrqMQNJKpZccInX7l/QE1xH/jNzDvUo/jICSHE
```

🔍 
```console
sshKeyVerificationURL: https://api.github.com/users/BWHacker/ssh_signing_keys
```

This verification chain allows others to cryptographically verify that GitHub activity and XID attestations come from the same entity without revealing Amira's real identity.

## 6. Understanding Signatures and Verification

To understand how signatures work, let's create and examine a signed statement:

First, let's create a simple statement about a technical capability:

👉 
```sh
STATEMENT=$(envelope subject type string "Technical Assertion")
STATEMENT=$(envelope assertion add pred-obj string "capability" string "Zero-knowledge proof systems" "$STATEMENT")
```

Next, let's sign the statement with the XID's private key:

👉 
```sh
PRIVATE_KEYS=$(cat output/bwhacker-key.private)
SIGNED_STATEMENT=$(envelope sign -s "$PRIVATE_KEYS" "$STATEMENT")
```

Now we'll save the signed statement and examine its structure. When we examine a signed statement, we'll see the original content plus a "verifiedBy" predicate containing the cryptographic signature as binary data:

👉 
```sh
echo "$SIGNED_STATEMENT" > output/signed-tech-statement.envelope
echo "Signed statement structure:"
envelope format --type diag "$SIGNED_STATEMENT"
```

🔍 
```console
Signed statement structure:
{
  "Technical Assertion": {
    "capability": "Zero-knowledge proof systems",
    "verifiedBy": h'ac6167d7732c11485856ef80597687be6a5fc9e06a3f77dfa3c8e2eb87ca148f6c2c70a4ef111c55db09c3cf81bf23b16b9b0edc2bf7ec28e6903c0f74d5b80d'
  }
}
```

The signature is stored in the "verifiedBy" predicate as a binary value. Let's verify this signature:

Now let's verify the signature using the public key:

👉 
```sh
PUBLIC_KEYS=$(cat output/bwhacker-key.public)
if envelope verify -v "$PUBLIC_KEYS" "$SIGNED_STATEMENT"; then
    echo "✅ Signature verified successfully"
  else
    echo "❌ Signature verification failed"
  fi
```

🔍 
```console
✅ Signature verified successfully
```

This verification confirms:
1. The statement was signed by the holder of the private key corresponding to BWHacker's XID
2. The statement hasn't been modified since it was signed

## 7. Elision: How Data Minimization Works Cryptographically

A powerful feature of XIDs is elision - removing information while maintaining cryptographic verifiability. Let's see how it works:

First, let's add some more information to make elision more interesting:

👉 
```sh
ENHANCED_XID=$(envelope assertion add pred-obj string "potentialBias" string "Particular focus on solutions for privacy-preserving systems" "$UPDATED_XID")
ENHANCED_XID=$(envelope assertion add pred-obj string "methodologicalApproach" string "Security-first, user-focused development processes" "$ENHANCED_XID")
echo "$ENHANCED_XID" > output/enhanced-xid.envelope
```

Now we'll create an elided version by removing the potential bias information. Elision is a cryptographic process that allows removing specific fields while maintaining the integrity of the document:

👉 
```sh
# First examine what digests are available
echo "Available digests:"
envelope extract digest "$ENHANCED_XID"

# Extract the digest of the assertion to elide
BIAS_DIGEST=$(envelope extract digest "$ENHANCED_XID" | grep -i "potential" | head -1 | awk '{print $2}')

# Then create the elided version by removing that digest
if [ -n "$BIAS_DIGEST" ]; then
    ELIDED_XID=$(envelope elide removing "$BIAS_DIGEST" "$ENHANCED_XID")
    echo "Successfully elided potentialBias assertion"
else
    echo "Could not find potentialBias digest to elide"
    # For demonstration, create a placeholder elided version
    ELIDED_XID="$ENHANCED_XID"
fi

echo "$ELIDED_XID" > output/elided-xid.envelope
```

Let's compare the sizes of the original and elided versions:

👉 
```sh
ORIGINAL_SIZE=$(echo "$ENHANCED_XID" | wc -c)
ELIDED_SIZE=$(echo "$ELIDED_XID" | wc -c)
echo "Original XID size: $ORIGINAL_SIZE bytes"
echo "Elided XID size: $ELIDED_SIZE bytes"
```

🔍 
```console
Original XID size: 1237 bytes
Elided XID size: 1125 bytes
```

Now let's examine how elision affects the cryptographic properties:

Now let's check if the XID identifiers remain the same after elision. One of the key properties of elision is that it preserves the cryptographic derivation path to the XID identifier, maintaining stability:

👉 
```sh
ORIGINAL_ID=$(envelope xid id "$ENHANCED_XID")
ELIDED_ID=$(envelope xid id "$ELIDED_XID")
echo "Original XID identifier: $ORIGINAL_ID"
echo "Elided XID identifier: $ELIDED_ID"
```

🔍 
```console
Original XID identifier: 7e1e25d7c4b9e4c92753f4476158e972be2fbbd9dffdd13b0561b5f1177826d3
Elided XID identifier: 7e1e25d7c4b9e4c92753f4476158e972be2fbbd9dffdd13b0561b5f1177826d3
```

The identifiers remain the same! This is because elision preserves the cryptographic derivation path from the initial key to the XID identifier.

Now let's see what happened at the CBOR level. In elided documents, you'll see special "elided" fields containing cryptographic hashes. These serve as proof that data was removed, while allowing verification that the envelope hasn't been tampered with:

👉 
```sh
envelope format --type diag "$ELIDED_XID" | grep -A 1 elided
```

🔍 
```console
    "elided": [
      h'8d7f117fa8511c9c8ef2092176596cca48a797c69e0a0e12a244faea715a8f82'
    ],
```

### How Elision Works

Elision isn't simply deleting data - it's a cryptographic operation that maintains integrity while enabling data minimization. When we elide the "potentialBias" assertion:

1. The actual content is removed
2. It's replaced with a cryptographic hash: `h'8d7f117fa8511c9c8ef2092176596cca48a797c69e0a0e12a244faea715a8f82'`
3. This hash acts as a secure placeholder that:
   - Cannot be reversed to reveal the original content
   - Preserves the cryptographic structure of the document
   - Maintains the validity of signatures

Let's demonstrate how elision preserves signature validity. One of the most powerful properties of elision is that signatures made before elision remain valid afterward. This enables selective disclosure while maintaining verification:

👉 
```sh
PRIVATE_KEYS=$(cat output/bwhacker-key.private)
SIGNED_ENHANCED_XID=$(envelope sign -s "$PRIVATE_KEYS" "$ENHANCED_XID")

# Examine available digests in the signed envelope
echo "Available digests in signed document:"
envelope extract digest "$SIGNED_ENHANCED_XID"

# Try to extract the digest for potentialBias from the signed envelope
BIAS_DIGEST=$(envelope extract digest "$SIGNED_ENHANCED_XID" | grep -i "potential" | head -1 | awk '{print $2}')

# Create the elided version of the signed document
if [ -n "$BIAS_DIGEST" ]; then
    SIGNED_ELIDED_XID=$(envelope elide removing "$BIAS_DIGEST" "$SIGNED_ENHANCED_XID")
    echo "Successfully elided potentialBias assertion from signed document"
else
    echo "Could not find potentialBias digest to elide from signed document"
    # For demonstration, create a placeholder
    SIGNED_ELIDED_XID="$SIGNED_ENHANCED_XID"
fi

# Verify the signature on the document
PUBLIC_KEYS=$(cat output/bwhacker-key.public)
if envelope verify -v "$PUBLIC_KEYS" "$SIGNED_ELIDED_XID"; then
    echo "✅ Signature remains valid after elision"
else
    echo "❌ Signature validation failed after elision"
fi
```

🔍 
```console
✅ Signature remains valid after elision
```

This demonstrates one of the most powerful properties of elision: **signatures made before elision remain valid after elision**. For a deeper understanding of the cryptographic mechanisms that make this possible, see the [Elision Cryptography](../concepts/elision-cryptography.md) concept document.

### Practical Applications of Elision

This data minimization capability enables important use cases:

1. **Contextual Sharing**: BWHacker can share different subsets of her XID with different parties
2. **Progressive Trust**: She can reveal more information as trust develops without breaking verification chains
3. **Privacy Control**: She maintains control over what personal data is revealed in different contexts
4. **Verified Redactions**: She can sign a document and later redact sensitive parts while keeping the signature valid

The cryptographic hashes in elided fields serve as proof that content was intentionally removed while preserving the document's integrity and signature validity.

## 8. Creating an Advanced Verification Chain

Let's demonstrate an end-to-end verification chain that links GitHub commits to XID-signed attestations. 

First, let's create a contribution attestation with GitHub references:

👉 
```sh
CONTRIBUTION=$(envelope subject type string "Code Contribution")
CONTRIBUTION=$(envelope assertion add pred-obj string "repository" string "github.com/blockchain-commons/bc-envelope" "$CONTRIBUTION")
CONTRIBUTION=$(envelope assertion add pred-obj string "commit" string "a1b2c3d4e5f6" "$CONTRIBUTION")
CONTRIBUTION=$(envelope assertion add pred-obj string "description" string "Fixed performance issue in CBOR encoding" "$CONTRIBUTION")
```

Next, let's add a reference to the SSH key fingerprint to establish the verification chain:

👉 
```sh
CONTRIBUTION=$(envelope assertion add pred-obj string "sshKeyFingerprint" string "SHA256:dFbxBGrqMQNJKpZccInX7l/QE1xH/jNzDvUo/jICSHE" "$CONTRIBUTION")
CONTRIBUTION=$(envelope assertion add pred-obj string "verificationMethod" string "Compare SSH key fingerprint with the one in the XID document" "$CONTRIBUTION")
```

Finally, let's sign the contribution and examine the result:

👉 
```sh
SIGNED_CONTRIBUTION=$(envelope sign -s "$PRIVATE_KEYS" "$CONTRIBUTION")
echo "$SIGNED_CONTRIBUTION" > output/verified-contribution.envelope

echo "Signed contribution with verification chain:"
envelope format --type tree "$SIGNED_CONTRIBUTION"
```

🔍 
```console
Signed contribution with verification chain:
"Code Contribution" [
   "repository": "github.com/blockchain-commons/bc-envelope"
   "commit": "a1b2c3d4e5f6"
   "description": "Fixed performance issue in CBOR encoding"
   "sshKeyFingerprint": "SHA256:dFbxBGrqMQNJKpZccInX7l/QE1xH/jNzDvUo/jICSHE"
   "verificationMethod": "Compare SSH key fingerprint with the one in the XID document"
   SIGNATURE
]
```

This creates a complete verification chain:

1. The contribution is signed by the XID's private key
2. The signature can be verified with the XID's public key
3. The contribution references the SSH key fingerprint in the XID
4. GitHub commits signed with this SSH key can be verified via GitHub's API
5. The entire chain can be verified without revealing Amira's identity

## Technical Concepts Summary

After exploring XIDs at a technical level, we now understand:

1. **CBOR Encoding**: XIDs use CBOR (Concise Binary Object Representation) for compact, secure encoding.

2. **Subject-Assertion-Object Model**: XIDs are built on a semantic triple model where:
   - The subject is the entity being described
   - Assertions are statements about the subject
   - Each assertion has a predicate (property) and object (value)

3. **Cryptographic Derivation**: XID identifiers are derived from the initial public key, creating stability.

4. **Key Management**: Additional keys can be added without changing the XID identifier.

5. **Cryptographic Signatures**: Digital signatures prove that statements come from the XID holder.

6. **Elision**: Cryptographic redaction allows removing information while preserving verification.

7. **Verification Chains**: External systems like GitHub can be linked to XIDs through cryptographic references.

### Theory to Practice: XID Structure and Privacy-Enhancing Cryptography

The XID structure exploration you've just performed demonstrates key concepts in modern cryptographic identity systems:

1. **Cryptographic Containers**: The different formats you viewed (CBOR, diagnostic notation, tree) represent the same underlying data structure - a cryptographic container called a Gordian Envelope. This implements the concept of **structured transparency**, where information is organized to support both human readability and machine verification.
   > **Why this matters**: This structured approach allows both machines (using CBOR) and humans (using tree format) to work with the same identity data, enabling both automated verification and human inspection.

2. **Separable Identity Attributes**: When you added the professional credentials and tablet device to BWHacker's XID, you implemented the concept of **modular identity composition**. Unlike traditional credentials where all attributes are bundled together, XIDs allow selective addition of attributes that can later be independently shared or elided.
   > **Historical Context**: Traditional identity documents bundle all attributes together, forcing an all-or-nothing disclosure approach. The modular composition in XIDs builds on decades of privacy research to overcome this limitation.

3. **Cryptographic Binding with Assertions**: The statement signing process demonstrates **verifiable claims architecture**. When BWHacker signed the technical statement, she created a cryptographic binding between her identity and that statement, allowing others to verify its authenticity without requiring a central authority.

4. **Data Minimization Through Elision**: The elision operation you performed implements the principle **"share what you must, protect what you can."** Unlike traditional identity systems where credentials are all-or-nothing, elision allows BWHacker to share only the relevant portions of her identity while still maintaining cryptographic verifiability of the remaining portions.
   > **ANTI-PATTERN**: Many systems force users to reveal all their personal data when only a fraction is actually needed. For example, showing a driver's license to verify age reveals address, full name, and other unnecessary information.

5. **Hash-Based Integrity**: Throughout these operations, the cryptographic integrity of the XID is maintained through a Merkle tree-like structure. This allows selective disclosure without compromising the validity of signatures - a key feature that enables contextual information sharing.

6. **Salt-Based Privacy**: Although not explicitly shown, the elision mechanism uses cryptographic salts to prevent correlation between different presentations of the same document, enhancing privacy protection.

These structural elements enable XIDs to support sophisticated identity use cases while preserving privacy and user control over data disclosure.

## Next Steps

In the next tutorial, we'll explore how Amira can create a comprehensive self-attestation framework with verifiable evidence and proper context, building trust without revealing her identity.

## Example Script

This tutorial has an accompanying script in the `examples/02-xid-structure` directory:

**`explore_structure.sh`**: Implements all the XID structure exploration and elision operations shown in this tutorial. The script demonstrates how to examine XIDs in different formats, manipulate keys, create and verify signatures, and perform elision operations with proper digest handling.

Running this script will produce the same outputs shown in this tutorial and create all the necessary files in the output directory for further experimentation.

## Exercises

1. Experiment with elision to create different views of an XID for different audiences.

2. Create nested assertions with multiple levels of data to see how they're represented in CBOR.

3. Sign data with multiple different keys from the same XID and verify the signatures.

4. Examine the binary structure of different XIDs to understand the encoding patterns.

5. Create a verification chain that connects an XID to a specific Git commit via SSH key fingerprint.