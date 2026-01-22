#!/bin/bash
#
# 01-your-first-xid-TEST.sh - Test all code examples from Tutorial 01
#
# Validates that every command in Tutorial 01: Your First XID works correctly.
# Tests XID creation, elision, signature verification, and provenance validation.
#
# Usage: ./01-your-first-xid-TEST.sh
#
# Dependencies: envelope (bc-envelope-cli-rust), provenance
#
# Exit Codes:
#   0   All tests passed
#   1   Test failure
#

set -e

echo "=== COMPREHENSIVE TUTORIAL 01 CODE TEST ==="
echo ""

# Step 1: Create Your XID
echo "STEP 1: Create Your XID"
echo "========================"

XID_NAME=BRadvoc8
PASSWORD="Amira's strong password"

XID=$(envelope generate keypairs --signing ed25519 | \
    envelope xid new \
    --private encrypt \
    --encrypt-password "$PASSWORD" \
    --nickname "$XID_NAME" \
    --generator encrypt \
    --sign inception)

if [ $XID ]
then
  echo "✓ Created your XID: $XID_NAME"
else
  echo "❌ ERROR: XID creation"
fiecho ""

# View XID structure
echo "Viewing XID structure:"
envelope format "$XID"
echo ""

# Step 2: Creating a Public Version by Elision
echo "STEP 2: Creating a Public Version by Elision"
echo "============================================="

# Unwrap the signed XID
UNWRAPPED_XID=$(envelope extract wrapped "$XID")
echo "✓ Unwrapped signed XID"

# Find the key assertion
KEY_ASSERTION=$(envelope assertion find predicate known key "$UNWRAPPED_XID")
KEY_OBJECT=$(envelope extract object "$KEY_ASSERTION")

# Find the private key assertion within the key object
PRIVATE_KEY_ASSERTION=$(envelope assertion find predicate known privateKey "$KEY_OBJECT")
PRIVATE_KEY_DIGEST=$(envelope digest "$PRIVATE_KEY_ASSERTION")

if [ $PRIVATE_KEY_DIGEST ]
then
  echo "✓ Found private key digest"
else
  echo "❌ Error: Private Key Retrieval"
fi

# Elide the private key
PUBLIC_XID=$(envelope elide removing "$PRIVATE_KEY_DIGEST" "$XID")
echo "✓ Created public version by eliding private key"
echo ""

echo "Public XID structure:"
envelope format "$PUBLIC_XID"
echo ""

# Proving Elision Preserves the Envelope Hash
echo "Proving elision preserves envelope hash:"
ORIGINAL_DIGEST=$(envelope digest "$XID")
PUBLIC_DIGEST=$(envelope digest "$PUBLIC_XID")

echo "Original XID digest: $ORIGINAL_DIGEST"
echo "Public XID digest:   $PUBLIC_DIGEST"

if [ "$ORIGINAL_DIGEST" = "$PUBLIC_DIGEST" ]; then
    echo "✅ VERIFIED: Digests are identical - elision preserved the root hash\!"
else
    echo "❌ ERROR: Digests differ"
    exit 1
fi
echo ""

# Step 3: Verification
echo "STEP 3: Verification"
echo "===================="

# Extract public keys from unwrapped XID
KEY_ASSERTION=$(envelope assertion find predicate known key "$UNWRAPPED_XID")
KEY_OBJECT=$(envelope extract object "$KEY_ASSERTION")
PUBLIC_KEYS=$(envelope extract ur "$KEY_OBJECT")

# Verify signature
envelope verify -v "$PUBLIC_KEYS" "$PUBLIC_XID" >/dev/null && echo "✅ Signature verified!"

# Verify provenance mark from PUBLIC XID (no secrets needed!)
echo ""
echo "Verifying provenance mark from public XID:"
PROVENANCE_MARK=$(envelope xid provenance get "$PUBLIC_XID")

# Validate it (silent success)
if provenance validate "$PROVENANCE_MARK" 2>/dev/null; then
    echo "✅ Provenance mark verified from public XID (no secrets needed)"
else
    echo "❌ Provenance mark validation failed"
    exit 1
fi
echo ""

# Test Common Questions code snippets
echo "TESTING COMMON QUESTIONS CODE SNIPPETS"
echo "======================================="

# Q: How can I verify that elision really preserves the envelope hash?
echo "Test: Verifying elision preserves hash (from Q&A)"
SIGNED_XID="$XID"
PUBLIC_SIGNED_XID="$PUBLIC_XID"

# Before elision
ORIGINAL_DIGEST=$(envelope digest "$SIGNED_XID")

# After elision
PUBLIC_DIGEST=$(envelope digest "$PUBLIC_SIGNED_XID")

# Compare
if [ "$ORIGINAL_DIGEST" = "$PUBLIC_DIGEST" ]; then
    echo "✅ Same hash! (from Common Questions example)"
else
    echo "❌ Different hash!"
    exit 1
fi
echo ""

echo "=== ALL TUTORIAL CODE BLOCKS TESTED SUCCESSFULLY ==="
echo ""

# Check for Ed25519 in output
echo "Verifying Ed25519 usage:"
if envelope format "$XID" | grep -q "Ed25519PublicKey"; then
    echo "✅ Ed25519PublicKey found in XID"
else
    echo "❌ Ed25519PublicKey NOT found in XID"
    exit 1
fi

if envelope format "$XID" | grep -q "Signature(Ed25519)"; then
    echo "✅ Ed25519 Signature found"
else
    echo "❌ Ed25519 Signature NOT found"
    exit 1
fi

# Check for encrypted generator
if envelope format "$XID" | grep -q "'provenanceGenerator': ENCRYPTED"; then
    echo "✅ Encrypted provenance generator found"
else
    echo "❌ Encrypted provenance generator NOT found"
    exit 1
fi

# Save files for Tutorial 02 to use
echo "Saving Tutorial 01 artifacts..."
OUTPUT_DIR="output/xid-$(date +%Y%m%d%H%M%S)"
mkdir -p "$OUTPUT_DIR"

# Save signed XID (complete version)
echo "$XID" > "$OUTPUT_DIR/BRadvoc8-xid.envelope"
envelope format "$XID" > "$OUTPUT_DIR/BRadvoc8-xid.format"

# Save public XID (elided version)
echo "$PUBLIC_XID" > "$OUTPUT_DIR/BRadvoc8-public.envelope"
envelope format "$PUBLIC_XID" > "$OUTPUT_DIR/BRadvoc8-public.format"

echo "✅ Files saved to: $OUTPUT_DIR"
ls "$OUTPUT_DIR"
echo ""
echo "✅ ALL TESTS PASSED - Tutorial code is correct!"
