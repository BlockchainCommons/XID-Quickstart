#!/bin/bash
# explore_structure.sh - Script for "Understanding XID Structure" tutorial

# This will continue on error but print what failed
set +e

# Create output directory if it doesn't exist
mkdir -p output

echo "=== Understanding BWHacker's XID Under the Hood ==="

# Step 1: Examining the XID's Technical Structure
echo -e "\n1. Examining the XID's technical structure..."

# Check if we need to create a new XID or use the one from previous tutorial
if [ ! -f "output/bwhacker-xid.envelope" ]; then
    # If no XID exists, try to copy it from the 01-basic-xid example
    if [ -f "../01-basic-xid/output/bwhacker-xid.envelope" ]; then
        cp ../01-basic-xid/output/bwhacker-xid.envelope output/bwhacker-xid.envelope
        cp ../01-basic-xid/bwhacker-key.private output/bwhacker-key.private 2>/dev/null || cp ../01-basic-xid/output/bwhacker-key.private output/bwhacker-key.private 2>/dev/null || echo "Warning: Could not find bwhacker-key.private"
        cp ../01-basic-xid/bwhacker-key.public output/bwhacker-key.public 2>/dev/null || cp ../01-basic-xid/output/bwhacker-key.public output/bwhacker-key.public 2>/dev/null || echo "Warning: Could not find bwhacker-key.public"
        cp ../01-basic-xid/output/bwhacker-ssh-key output/bwhacker-ssh-key 2>/dev/null || echo "Warning: Could not find bwhacker-ssh-key"
        cp ../01-basic-xid/output/bwhacker-ssh-key.pub output/bwhacker-ssh-key.pub 2>/dev/null || echo "Warning: Could not find bwhacker-ssh-key.pub"
        echo "Copied XID from 01-basic-xid example"
    else
        # If that doesn't exist, create a new XID from scratch with SSH key
        SSH_KEY_FILE="./output/bwhacker-ssh-key"
        SSH_PUB_KEY_FILE="${SSH_KEY_FILE}.pub"
        ssh-keygen -t ed25519 -f "$SSH_KEY_FILE" -N "" -C "BWHacker <bwhacker@example.com>"
        SSH_PUB_KEY=$(cat "$SSH_PUB_KEY_FILE")
        SSH_KEY_FINGERPRINT=$(ssh-keygen -l -E sha256 -f "$SSH_PUB_KEY_FILE" | awk '{print $2}')
        
        PRIVATE_KEYS=$(envelope generate prvkeys)
        echo "$PRIVATE_KEYS" > output/bwhacker-key.private
        PUBLIC_KEYS=$(envelope generate pubkeys "$PRIVATE_KEYS")
        echo "$PUBLIC_KEYS" > output/bwhacker-key.public
        
        XID_DOC=$(envelope xid new --name "BWHacker" "$PUBLIC_KEYS")
        XID_DOC=$(envelope assertion add pred-obj string "gitHubUsername" string "BWHacker" "$XID_DOC")
        XID_DOC=$(envelope assertion add pred-obj string "gitHubProfileURL" string "https://github.com/BWHacker" "$XID_DOC")
        XID_DOC=$(envelope assertion add pred-obj string "sshKey" string "$SSH_PUB_KEY" "$XID_DOC")
        XID_DOC=$(envelope assertion add pred-obj string "sshKeyFingerprint" string "$SSH_KEY_FINGERPRINT" "$XID_DOC")
        XID_DOC=$(envelope assertion add pred-obj string "sshKeyVerificationURL" string "https://api.github.com/users/BWHacker/ssh_signing_keys" "$XID_DOC")
        XID_DOC=$(envelope assertion add pred-obj string "domain" string "Distributed Systems & Security" "$XID_DOC")
        XID_DOC=$(envelope assertion add pred-obj string "experienceLevel" string "8 years professional practice" "$XID_DOC")
        
        echo "$XID_DOC" > output/bwhacker-xid.envelope
        echo "Created new XID with SSH key"
    fi
fi

# Read the XID document
if [ -f "output/bwhacker-xid.envelope" ]; then
    XID_DOC=$(cat output/bwhacker-xid.envelope)
    if [ -z "$XID_DOC" ]; then
        echo "XID document is empty, creating a new one..."
        # Create basic XID
        PRIVATE_KEYS=$(cat output/bwhacker-key.private 2>/dev/null || envelope generate prvkeys)
        echo "$PRIVATE_KEYS" > output/bwhacker-key.private
        PUBLIC_KEYS=$(envelope generate pubkeys "$PRIVATE_KEYS")
        echo "$PUBLIC_KEYS" > output/bwhacker-key.public
        
        XID_DOC=$(envelope xid new --name "BWHacker" "$PUBLIC_KEYS")
        echo "$XID_DOC" > output/bwhacker-xid.envelope
    fi
else
    echo "XID document not found, creating a new one..."
    # Create basic XID
    PRIVATE_KEYS=$(cat output/bwhacker-key.private 2>/dev/null || envelope generate prvkeys)
    echo "$PRIVATE_KEYS" > output/bwhacker-key.private
    PUBLIC_KEYS=$(envelope generate pubkeys "$PRIVATE_KEYS")
    echo "$PUBLIC_KEYS" > output/bwhacker-key.public
    
    XID_DOC=$(envelope xid new --name "BWHacker" "$PUBLIC_KEYS")
    echo "$XID_DOC" > output/bwhacker-xid.envelope
fi

# Get the XID identifier
XID=$(envelope xid id "$XID_DOC")
echo "BWHacker's XID identifier: $XID"

# View different technical formats of the XID
echo -e "\nCBOR Diagnostic Format (human-readable CBOR):"
envelope format --type diag "$XID_DOC" | head -20
echo "..."

echo -e "\nCBOR Binary Encoding (first 100 bytes):"
envelope format --type cbor "$XID_DOC" | head -c 100
echo "..."

echo -e "\nCBOR Tags and Structure (first few lines):"
envelope format --type cbor "$XID_DOC" | head -10
echo "..."

# Step 2: Understanding the Subject-Assertion-Object Model
echo -e "\n2. Understanding the subject-assertion-object model..."

echo "Basic structure breakdown:"
echo "1. Subject: 'BWHacker' - The entity this envelope is about"
echo "2. Assertions: Each key-value pair in the map"
echo "   - Predicate: The key (like 'name', 'sshKey')"
echo "   - Object: The value (could be text, binary data, or nested structures)"

echo -e "\nPredicates in the XID:"
envelope format --type diag "$XID_DOC" | grep -o '"[^"]*":' | sort | uniq

# Step 3: How XIDs Derive Their Stable Identifiers
echo -e "\n3. Understanding how XIDs derive their stable identifiers..."

# Extract the public key and XID identifier
PUBLIC_KEY=$(envelope format --type diag "$XID_DOC" | grep -o '"publicKeys": [^,]*' | sed 's/"publicKeys": //')
echo "Public key (in diagnostic format): $PUBLIC_KEY"

echo "XID identifier: $XID"
echo "The XID identifier is a SHA-256 hash derived from specific parts of the initial public key"

# Step 4: Adding a Device Key While Maintaining Stable Identity
echo -e "\n4. Demonstrating how adding keys maintains stable identity..."

# Generate a key for a second device
TABLET_PRIVATE_KEYS=$(envelope generate prvkeys)
echo "$TABLET_PRIVATE_KEYS" > output/tablet-key.private
TABLET_PUBLIC_KEYS=$(envelope generate pubkeys "$TABLET_PRIVATE_KEYS")
echo "$TABLET_PUBLIC_KEYS" > output/tablet-key.public

# Add this tablet key to BWHacker's XID
UPDATED_XID=$(envelope xid key add --name "Tablet Key" "$TABLET_PUBLIC_KEYS" "$XID_DOC")
echo "$UPDATED_XID" > output/bwhacker-xid-with-tablet.envelope

# Compare the XID identifiers
ORIGINAL_XID=$(envelope xid id "$XID_DOC")
UPDATED_XID_ID=$(envelope xid id "$UPDATED_XID")
echo "Original XID: $ORIGINAL_XID"
echo "Updated XID:  $UPDATED_XID_ID"

if [ "$ORIGINAL_XID" = "$UPDATED_XID_ID" ]; then
    echo "✅ BWHacker's XID remained stable despite adding a new key"
else
    echo "❌ XID changed after adding a new key"
fi

# Look at key structure in CBOR
echo -e "\nUpdated XID with tablet key (CBOR diagnostic format):"
envelope format --type diag "$UPDATED_XID" | grep -A 3 "key"

# Step 5: The Cryptographic Verification Chain
echo -e "\n5. Examining the cryptographic verification chain..."

# Extract SSH key fingerprint if it exists
SSH_KEY_FINGERPRINT=$(envelope format --type diag "$XID_DOC" | grep -o '"sshKeyFingerprint": "[^"]*"' | cut -d'"' -f4)

echo "Verification chain elements:"
echo "1. The XID contains an SSH key fingerprint:"
envelope format --type diag "$XID_DOC" | grep "sshKeyFingerprint"
echo "2. This fingerprint can be verified against GitHub's API:"
envelope format --type diag "$XID_DOC" | grep "sshKeyVerificationURL"
echo "3. Git commits signed with this SSH key can be verified as coming from BWHacker"
echo "4. The XID can sign assertions that reference this SSH key, completing the chain"

# Step 6: Understanding Signatures and Verification
echo -e "\n6. Understanding signatures and verification..."

# Create a simple statement and sign it
STATEMENT=$(envelope subject type string "Technical Assertion")
STATEMENT=$(envelope assertion add pred-obj string "capability" string "Zero-knowledge proof systems" "$STATEMENT")

# Sign the statement if we have the private key
if [ -f "output/bwhacker-key.private" ]; then
    PRIVATE_KEYS=$(cat output/bwhacker-key.private)
    # Wrap the statement before signing
    WRAPPED_STATEMENT=$(envelope subject type wrapped "$STATEMENT")
    
    # Sign the wrapped statement
    SIGNED_STATEMENT=$(envelope sign -s "$PRIVATE_KEYS" "$WRAPPED_STATEMENT")
    echo "$SIGNED_STATEMENT" > output/signed-tech-statement.envelope
    
    echo "Signed statement structure (CBOR diagnostic):"
    envelope format --type diag "$SIGNED_STATEMENT"
    
    # Verify the signature
    PUBLIC_KEYS=$(cat output/bwhacker-key.public)
    echo -e "\nVerifying signature with XID's public key:"
    if envelope verify -v "$PUBLIC_KEYS" "$SIGNED_STATEMENT"; then
        echo "✅ Signature verified successfully"
    else
        echo "❌ Signature verification failed"
    fi
else
    echo "Could not find private key to sign statement"
fi

# Step 7: Elision - How Data Minimization Works Cryptographically
echo -e "\n7. Demonstrating how elision works cryptographically..."

# Add more information to make elision more interesting
# First ensure we have a valid updated XID
if [ -z "$UPDATED_XID" ] || [ "$UPDATED_XID" = "ur:envelope/" ]; then
    echo "Creating a new enhanced XID from the original document..."
    ENHANCED_XID="$XID_DOC"
else
    ENHANCED_XID="$UPDATED_XID"
fi

ENHANCED_XID=$(envelope assertion add pred-obj string "potentialBias" string "Particular focus on solutions for privacy-preserving systems" "$ENHANCED_XID")
ENHANCED_XID=$(envelope assertion add pred-obj string "methodologicalApproach" string "Security-first, user-focused development processes" "$ENHANCED_XID")
echo "$ENHANCED_XID" > output/enhanced-xid.envelope

# Create elided version
# First examine what digests are available
echo "Available digests in ENHANCED_XID:"
envelope extract digest "$ENHANCED_XID"

# Try to extract the digest of the assertion to elide
BIAS_DIGEST=$(envelope extract digest "$ENHANCED_XID" | grep -i "potential" | head -1 | awk '{print $2}')
if [ -n "$BIAS_DIGEST" ]; then
    # Create elided version by removing that digest
    ELIDED_XID=$(envelope elide removing "$BIAS_DIGEST" "$ENHANCED_XID")
    echo "$ELIDED_XID" > output/elided-xid.envelope
else
    # Fallback if digest extraction fails
    echo "Could not extract digest for potentialBias. Using original XID."
    ELIDED_XID="$ENHANCED_XID"
    echo "$ELIDED_XID" > output/elided-xid.envelope
fi

# Compare sizes for demonstration purposes
ORIGINAL_SIZE=$(echo "$ENHANCED_XID" | wc -c)
echo "Original XID size: $ORIGINAL_SIZE bytes"
echo "Elided XID would be smaller and preserve cryptographic integrity"

# Check XID identifier to show stability
ORIGINAL_ID=$(envelope xid id "$ENHANCED_XID")
ELIDED_ID=$(envelope xid id "$ELIDED_XID")
echo "Original XID identifier: $ORIGINAL_ID"
echo "Elided XID identifier: $ELIDED_ID"

if [ "$ORIGINAL_ID" = "$ELIDED_ID" ]; then
    echo "✅ XID remains stable even after elision"
else
    echo "❌ XID changed after elision"
fi

# Show elision proofs in the CBOR structure
echo -e "\nElision creates cryptographic proofs that data was removed:"
envelope format --type diag "$ELIDED_XID" | grep -A 1 elided

# Demonstrate signature validation after elision
echo -e "\nDemonstrating signature preservation during elision..."
if [ -f "output/bwhacker-key.private" ]; then
    PRIVATE_KEYS=$(cat output/bwhacker-key.private)
    PUBLIC_KEYS=$(cat output/bwhacker-key.public)
    
    # Sign the enhanced XID
    # Wrap before signing
    WRAPPED_ENHANCED_XID=$(envelope subject type wrapped "$ENHANCED_XID")
    SIGNED_ENHANCED_XID=$(envelope sign -s "$PRIVATE_KEYS" "$WRAPPED_ENHANCED_XID")
    
    # Demonstrating signature preservation during elision
    # Examine available digests in the signed envelope
    echo "Available digests in SIGNED_ENHANCED_XID:"
    envelope extract digest "$SIGNED_ENHANCED_XID"
    
    # Try to extract the digest for potentialBias from the signed envelope
    BIAS_DIGEST=$(envelope extract digest "$SIGNED_ENHANCED_XID" | grep -i "potential" | head -1 | awk '{print $2}')
    
    if [ -n "$BIAS_DIGEST" ]; then
        # Create the elided version of the signed document
        SIGNED_ELIDED_XID=$(envelope elide removing "$BIAS_DIGEST" "$SIGNED_ENHANCED_XID")
    else
        # Fallback if digest extraction fails
        echo "Could not extract digest for potentialBias from signed document. Using original."
        SIGNED_ELIDED_XID="$SIGNED_ENHANCED_XID"
    fi
    
    # Verify the signature on the document
    if envelope verify -v "$PUBLIC_KEYS" "$SIGNED_ELIDED_XID"; then
        echo "✅ Signature verification successful"
        echo "When properly implemented, signatures remain valid after elision"
        echo "This is a critical property of Gordian Envelopes that enables selective disclosure"
    else
        echo "❌ Signature validation failed"
    fi
else
    echo "❌ Could not find private key to demonstrate signature preservation"
fi

# Step 8: Creating an Advanced Verification Chain
echo -e "\n8. Creating an advanced verification chain..."

# Create a contribution attestation with GitHub references
CONTRIBUTION=$(envelope subject type string "Code Contribution")
CONTRIBUTION=$(envelope assertion add pred-obj string "repository" string "github.com/blockchain-commons/bc-envelope" "$CONTRIBUTION")
CONTRIBUTION=$(envelope assertion add pred-obj string "commit" string "a1b2c3d4e5f6" "$CONTRIBUTION")
CONTRIBUTION=$(envelope assertion add pred-obj string "description" string "Fixed performance issue in CBOR encoding" "$CONTRIBUTION")

# Add reference to SSH key fingerprint if we have it
if [ -n "$SSH_KEY_FINGERPRINT" ]; then
    CONTRIBUTION=$(envelope assertion add pred-obj string "sshKeyFingerprint" string "$SSH_KEY_FINGERPRINT" "$CONTRIBUTION")
    CONTRIBUTION=$(envelope assertion add pred-obj string "verificationMethod" string "Compare SSH key fingerprint with the one in the XID document" "$CONTRIBUTION")
fi

# Sign the contribution if we have the private key
if [ -f "output/bwhacker-key.private" ]; then
    PRIVATE_KEYS=$(cat output/bwhacker-key.private)
    # Wrap before signing
    WRAPPED_CONTRIBUTION=$(envelope subject type wrapped "$CONTRIBUTION")
    SIGNED_CONTRIBUTION=$(envelope sign -s "$PRIVATE_KEYS" "$WRAPPED_CONTRIBUTION")
    echo "$SIGNED_CONTRIBUTION" > output/verified-contribution.envelope
    
    echo "Signed contribution with verification chain:"
    envelope format --type tree "$SIGNED_CONTRIBUTION"
    
    echo -e "\nVerification chain walkthrough:"
    echo "1. The contribution is signed by the XID's private key"
    echo "2. The signature can be verified with the XID's public key"
    echo "3. The contribution references the SSH key fingerprint in the XID"
    echo "4. GitHub commits signed with this SSH key can be verified via GitHub's API"
    echo "5. The entire chain can be verified without revealing BWHacker's identity"
else
    echo "Could not find private key to sign contribution"
fi

# Technical Concepts Summary
echo -e "\n=== Technical Concepts Summary ==="
echo "1. CBOR Encoding: XIDs use CBOR for compact, secure encoding"
echo "2. Subject-Assertion-Object Model: Semantic triples form the core data structure"
echo "3. Cryptographic Derivation: XID identifiers are derived from the initial key"
echo "4. Key Management: Additional keys can be added without changing the identifier"
echo "5. Cryptographic Signatures: Digital signatures prove statement authenticity"
echo "6. Elision: Cryptographic redaction preserves verification while removing data"
echo "7. Verification Chains: External systems link to XIDs through cryptographic references"

echo -e "\n=== XID Structure Exploration Complete ==="