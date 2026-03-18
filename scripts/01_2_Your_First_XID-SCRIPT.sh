#!/bin/bash
#
# 01_2_Your_First_XID-SCRIPT.sh - Test all code examples from §1.2
#
# Validates that every command in §1.2: Creating Your First XID works correctly.
# Tests XID creation, elision, signature verification, and provenance validation.
#
# Usage: bash 01_2_Your_First_XID-SCRIPT.sh
#
# Dependencies: envelope (bc-envelope-cli-rust), provenance
#
# Exit Codes:
#   0   All tests passed
#   1   Test failure
#

set -e

echo "=== LEARNING XIDS §1.2: Creating Your First XID CODE TEST ==="
echo ""

echo "Step 1: Create Your XID"
echo "======================="

XID_NAME=BRadvoc8
PASSWORD="Amira's strong password"

XID=$(envelope generate keypairs --signing ed25519 \
    | envelope xid new \
    --private encrypt \
    --encrypt-password "$PASSWORD" \
    --nickname "$XID_NAME" \
    --generator encrypt \
    --sign inception)

if [ $XID ]
then
  echo "✅ Created your XID: $XID_NAME"
else
  echo "❌ Error in XID creation"
fi
echo ""

echo "Step 2: View Your XID Structure"
echo "==============================="

# View XID structure
echo "Viewing XID structure:"
envelope format "$XID"
echo ""

echo "Step 3: Create a Public View of Your XID with Elision"
echo "====================================================="


PUBLIC_XID=$(envelope xid export --private elide --generator elide "$XID")
echo "✅ Created public view by eliding private key"
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
    echo "✅ VERIFIED: Digests are identical - elision preserved the root hash!"
else
    echo "❌ ERROR: Digests differ"
fi
echo ""

echo "Step 4: Verify the XID"
echo "======================"

# Extract public keys from unwrapped XID
KEY_OBJECT=$(envelope xid key all $PUBLIC_XID)
PUBLIC_KEYS=$(envelope extract ur "$KEY_OBJECT")

# Verify signature
envelope verify -v "$PUBLIC_KEYS" "$PUBLIC_XID" >/dev/null && echo "✅ Signature verified!"
echo ""

echo "Step 5: Verify the Provenance Mark"
echo "=================================="
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
echo ""

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
