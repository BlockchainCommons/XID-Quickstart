# Understanding XID Structure (Under the Hood)

This tutorial explores how Amira's pseudonymous "BWHacker" XID is structured at a technical level, revealing how Gordian Envelopes provide the cryptographic foundation for XIDs. You'll learn how the data structures work under the hood to enable stable identity, verifiable claims, and selective disclosure.

**Time to complete: 30-40 minutes**

> **Related Concepts**: Before or after completing this tutorial, you may want to read about [Gordian Envelope Basics](../concepts/gordian-envelope-basics.md) and [Data Minimization Principles](../concepts/data-minimization-principles.md) to understand the theoretical foundations behind XID structure and elision.

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
XID_DOC=$(cat output/amira-xid.envelope)
XID=$(envelope xid id "$XID_DOC")
echo "BWHacker's XID identifier: $XID"
```

🔍 
```console
BWHacker's XID identifier: 7e1e25d7c4b9e4c92753f4476158e972be2fbbd9dffdd13b0561b5f1177826d3
```

Now, let's look at several different formats of this XID to understand how it works at a technical level:

👉 
```sh
# View CBOR diagnostic format (human-readable CBOR)
echo "CBOR Diagnostic Format:"
envelope format --type diagnostic "$XID_DOC"
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

👉 
```sh
# View the hex encoding (lower-level representation)
echo "Hex Encoding (first 100 bytes):"
envelope format --type hex "$XID_DOC" | head -c 100
echo "..."
```

🔍 
```console
Hex Encoding (first 100 bytes):
a1684257486163686572a8646e616d65684257486163686572697075626c69634b657973d825258854c2d39daafb1eee9c8bab32d41...
```

👉 
```sh
# View the CBOR encoding in a more structured way
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

👉 
```sh
echo "Basic structure breakdown:"
echo "1. Subject: 'BWHacker' - The entity this envelope is about"
echo "2. Assertions: Each key-value pair in the map"
echo "   - Predicate: The key (like 'name', 'sshKey')"
echo "   - Object: The value (could be text, binary data, or nested structures)"
```

Let's examine this structure in the XID:

👉 
```sh
# List all predicates (the keys of the assertions)
echo "Predicates in the XID:"
envelope format --type diagnostic "$XID_DOC" | grep -o '"[^"]*":' | sort | uniq
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

👉 
```sh
# Extract just the public key from the XID
PUBLIC_KEY=$(envelope format --type diagnostic "$XID_DOC" | grep -o '"publicKeys": [^,]*' | sed 's/"publicKeys": //')
echo "Public key (in diagnostic format): $PUBLIC_KEY"

# Extract the XID identifier again
XID=$(envelope xid id "$XID_DOC")
echo "XID identifier: $XID"

echo "The XID identifier is a SHA-256 hash derived from specific parts of the initial public key"
```

🔍 
```console
Public key (in diagnostic format): 37([h'8854c2d39daafb1eee9c8bab32d41e97c775c286bfcabc4b7c3ff77f1eac268d', "ur:crypto-pubkeys/hdcxlkadjnghfejtmyyloeadmyfqzswdaeayfnmddpjygtmyaeaelytsqdisaeaeaeae"])
XID identifier: 7e1e25d7c4b9e4c92753f4476158e972be2fbbd9dffdd13b0561b5f1177826d3
The XID identifier is a SHA-256 hash derived from specific parts of the initial public key
```

This derivation process is what allows XIDs to maintain stability: the identifier is cryptographically derived from the initial key, creating a stable reference that persists even as the XID evolves.

## 4. Adding a Device Key While Maintaining Stable Identity

Now that we understand how XID identifiers work, let's see how adding a key preserves the stable identity:

👉 
```sh
# Generate a key for a second device (tablet)
TABLET_PRIVATE_KEYS=$(envelope generate prvkeys)
echo "$TABLET_PRIVATE_KEYS" > output/tablet-key.private
TABLET_PUBLIC_KEYS=$(envelope generate pubkeys "$TABLET_PRIVATE_KEYS")
echo "$TABLET_PUBLIC_KEYS" > output/tablet-key.public

# Add this tablet key to BWHacker's XID
UPDATED_XID=$(envelope xid key add --name "Tablet Key" "$TABLET_PUBLIC_KEYS" "$XID_DOC")
echo "$UPDATED_XID" > output/amira-xid-with-tablet.envelope

# Compare the XID identifiers
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

👉 
```sh
# View key structure in CBOR diagnostic format
echo "Updated XID with tablet key (CBOR diagnostic format):"
envelope format --type diagnostic "$UPDATED_XID" | grep -A 3 "key"
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

👉 
```sh
echo "Verification chain elements:"
echo "1. The XID contains an SSH key fingerprint:"
envelope format --type diagnostic "$XID_DOC" | grep "sshKeyFingerprint"
echo "2. This fingerprint can be verified against GitHub's API:"
envelope format --type diagnostic "$XID_DOC" | grep "sshKeyVerificationURL"
echo "3. Git commits signed with this SSH key can be verified as coming from BWHacker"
echo "4. The XID can sign assertions that reference this SSH key, completing the chain"
```

🔍 
```console
Verification chain elements:
1. The XID contains an SSH key fingerprint:
    "sshKeyFingerprint": "SHA256:dFbxBGrqMQNJKpZccInX7l/QE1xH/jNzDvUo/jICSHE",
2. This fingerprint can be verified against GitHub's API:
    "sshKeyVerificationURL": "https://api.github.com/users/BWHacker/ssh_signing_keys",
3. Git commits signed with this SSH key can be verified as coming from BWHacker
4. The XID can sign assertions that reference this SSH key, completing the chain
```

This verification chain allows others to cryptographically verify that GitHub activity and XID attestations come from the same entity without revealing Amira's real identity.

## 6. Understanding Signatures and Verification

To understand how signatures work, let's create and examine a signed statement:

👉 
```sh
# Create a simple statement
STATEMENT=$(envelope subject type string "Technical Assertion")
STATEMENT=$(envelope assertion add pred-obj string "capability" string "Zero-knowledge proof systems" "$STATEMENT")

# Sign the statement with the XID's private key
PRIVATE_KEYS=$(cat output/amira-key.private)
SIGNED_STATEMENT=$(envelope sign -s "$PRIVATE_KEYS" "$STATEMENT")

# Save the signed statement
echo "$SIGNED_STATEMENT" > output/signed-tech-statement.envelope

# Examine the signature in CBOR format
echo "Signed statement structure (CBOR diagnostic):"
envelope format --type diagnostic "$SIGNED_STATEMENT"
```

🔍 
```console
Signed statement structure (CBOR diagnostic):
{
  "Technical Assertion": {
    "capability": "Zero-knowledge proof systems",
    "verifiedBy": h'ac6167d7732c11485856ef80597687be6a5fc9e06a3f77dfa3c8e2eb87ca148f6c2c70a4ef111c55db09c3cf81bf23b16b9b0edc2bf7ec28e6903c0f74d5b80d'
  }
}
```

The signature is stored in the "verifiedBy" predicate as a binary value. Let's verify this signature:

👉 
```sh
# Verify the signature using the public key
PUBLIC_KEYS=$(cat output/amira-key.public)
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

👉 
```sh
# First, let's add some more information to make elision more interesting
ENHANCED_XID=$(envelope assertion add pred-obj string "potentialBias" string "Particular focus on solutions for privacy-preserving systems" "$UPDATED_XID")
ENHANCED_XID=$(envelope assertion add pred-obj string "methodologicalApproach" string "Security-first, user-focused development processes" "$ENHANCED_XID")
echo "$ENHANCED_XID" > output/enhanced-xid.envelope

# Create an elided version by removing the potential bias
ELIDED_XID=$(envelope elide assertion predicate string "potentialBias" "$ENHANCED_XID")
echo "$ELIDED_XID" > output/elided-xid.envelope

# Compare sizes of original and elided versions
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

👉 
```sh
# Check if XID identifiers remain the same
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

Now let's see what happened at the CBOR level:

👉 
```sh
# Look for evidence of elision in the CBOR diagnostic view
echo "Examining elided XID for cryptographic proof of elision:"
envelope format --type diagnostic "$ELIDED_XID" | grep -A 1 elided
```

🔍 
```console
Examining elided XID for cryptographic proof of elision:
    "elided": [
      h'8d7f117fa8511c9c8ef2092176596cca48a797c69e0a0e12a244faea715a8f82'
    ],
```

This "elided" field contains a cryptographic digest (hash) of what was removed. This hash serves as a placeholder that:
1. Proves something was present and has been elided
2. Maintains the cryptographic integrity of the document
3. Allows verification that the document hasn't been tampered with

## 8. Creating an Advanced Verification Chain

Let's demonstrate an end-to-end verification chain that links GitHub commits to XID-signed attestations:

👉 
```sh
# Create a contribution attestation with GitHub references
CONTRIBUTION=$(envelope subject type string "Code Contribution")
CONTRIBUTION=$(envelope assertion add pred-obj string "repository" string "github.com/blockchain-commons/bc-envelope" "$CONTRIBUTION")
CONTRIBUTION=$(envelope assertion add pred-obj string "commit" string "a1b2c3d4e5f6" "$CONTRIBUTION")
CONTRIBUTION=$(envelope assertion add pred-obj string "description" string "Fixed performance issue in CBOR encoding" "$CONTRIBUTION")

# Add a reference to the SSH key fingerprint
CONTRIBUTION=$(envelope assertion add pred-obj string "sshKeyFingerprint" string "SHA256:dFbxBGrqMQNJKpZccInX7l/QE1xH/jNzDvUo/jICSHE" "$CONTRIBUTION")
CONTRIBUTION=$(envelope assertion add pred-obj string "verificationMethod" string "Compare SSH key fingerprint with the one in the XID document" "$CONTRIBUTION")

# Sign the contribution
SIGNED_CONTRIBUTION=$(envelope sign -s "$PRIVATE_KEYS" "$CONTRIBUTION")
echo "$SIGNED_CONTRIBUTION" > output/verified-contribution.envelope

# Examine the signed contribution
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

## Next Steps

In the next tutorial, we'll explore how Amira can create comprehensive self-attestations with verifiable evidence and proper context, building trust without revealing her identity.

## Exercises

1. Experiment with elision to create different views of an XID for different audiences.

2. Create nested assertions with multiple levels of data to see how they're represented in CBOR.

3. Sign data with multiple different keys from the same XID and verify the signatures.

4. Examine the binary structure of different XIDs to understand the encoding patterns.

5. Create a verification chain that connects an XID to a specific Git commit via SSH key fingerprint.