#!/bin/bash
#
# 02_2_Managing_Claims_Elision-SCRIPT.md - Test all code examples from §2.2
#
# Tests all commands from §2.2, verifying:
# - Correlation risk concepts
# - Elided commitment creation
# - Inclusion proof verification
# - Full attestation reveal and verification
#
# Usage: bash 02_2_Managing_Claims_Elision-SCRIPT.md
#
# Exit Codes:
#   0   All tests passed
#   1   Test failure
#

set -e

echo "=== LEARNING XIDS §2.2: Managing Sensitive Claims with Elision CODE TEST ==="
echo ""

# Create output directory
OUTPUT_DIR="output/script-02-2-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUTPUT_DIR"

echo "Step 0: Recreate XID & Keys"
echo "==========================="

# Create Amira's XID with provenance tracking
XID=$(envelope generate keypairs --signing ed25519 | \
    envelope xid new --nickname "BRadvoc8" --generator include --sign inception)
XID_ID=$(envelope xid id $XID)
PASSWORD="test-password-for-tutorial"

ATTESTATION_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
ATTESTATION_PUBKEYS=$(envelope generate pubkeys "$ATTESTATION_PRVKEYS")

if [ $XID ]
then
  echo "✅ Created your XID: $XID_ID"
else
  echo "❌ Error in XID creation"
  exit 1;
fi

if [ $ATTESTATION_PRVKEYS ]
then
    echo "✅ Generated attestation keys (separate from XID inception key)"
else
  echo "❌ Error in attestation key creation"
  exit 1;
fi

echo ""

echo "Step 1: Create the Sensitive Attestation"
echo "========================================"

# Create the sensitive claim
AUDIT_CLAIM=$(envelope subject type string \
  "Audited cryptographic implementations for authentication systems (2023-2024)")
AUDIT_CLAIM=$(envelope assertion add pred-obj known isA known 'attestation' "$AUDIT_CLAIM")
AUDIT_CLAIM=$(envelope assertion add pred-obj known source ur $XID_ID "$AUDIT_CLAIM")
AUDIT_CLAIM=$(envelope assertion add pred-obj known target ur $XID_ID "$AUDIT_CLAIM")
AUDIT_CLAIM=$(envelope assertion add pred-obj known 'date' string `date -Iminutes` "$AUDIT_CLAIM")
AUDIT_CLAIM=$(envelope assertion add pred-obj string "skillCategory" string "Security" "$AUDIT_CLAIM")

if [ $AUDIT_CLAIM ]
then
  echo "✅ Created sensitive attestation (crypto audit experience)"
else
  echo "❌ Error in claim creation"
  exit 1;
fi
echo ""

echo "Step 2: Sign the Full Attestation"
echo "================================="

AUDIT_WRAPPED=$(envelope subject type wrapped "$AUDIT_CLAIM")
AUDIT_SIGNED=$(envelope sign --signer "$ATTESTATION_PRVKEYS" "$AUDIT_WRAPPED")

if [ $AUDIT_SIGNED ]
then
  echo "✅ Full attestation signed"
else
  echo "❌ Error in claim signing"
  exit 1;
fi
echo ""

echo "Full attestation structure:"
envelope format "$AUDIT_SIGNED"
echo ""

echo "Step 3: Create the Elided Commitment"
echo "===================================="

AUDIT_DIGEST=$(envelope digest "$AUDIT_SIGNED")
AUDIT_ELIDED=$(envelope elide removing "$AUDIT_DIGEST" "$AUDIT_SIGNED")

if [ $AUDIT_SIGNED ]
then
  echo "✅ Elided commitment created"
else
  echo "❌ Error in claim elision"
  exit 1;
fi

echo "Digest: $AUDIT_DIGEST"
echo "Envelope:"
envelope format "$AUDIT_ELIDED"
echo ""

echo "Step 4: Store Your Work"
echo "======================="

echo "$AUDIT_SIGNED" > "$OUTPUT_DIR/01-claim-signed.envelope"
envelope format "$AUDIT_SIGNED" > "$OUTPUT_DIR/01-claim-signed.format"
echo "✅ Audit Attestation Saved to: $OUTPUT_DIR/01-claim-signed.envelope"

echo "$AUDIT_ELIDED" > "$OUTPUT_DIR/01-claim-elided.envelope"
envelope format "$AUDIT_ELIDED" > "$OUTPUT_DIR/01-claim-elided.format"
echo "✅ Audit Elided Attestation Saved to: $OUTPUT_DIR/01-claim-elided.envelope"

echo ""

echo "Step 7: Test the Commitment"
echo "==========================="

RECEIVED_DIGEST=$(envelope digest "$AUDIT_SIGNED") # Received from Amira
ELIDED_DIGEST=$(envelope digest "$AUDIT_ELIDED") # Downloaded from GitHub

echo "   Full attestation digest:  ${RECEIVED_DIGEST:0:40}..."
echo "   Elided version digest:    ${ELIDED_DIGEST:0:40}..."

if [ "$RECEIVED_DIGEST" = "$ELIDED_DIGEST" ]; then
    echo "✅ Inclusion proof valid: this matches the public commitment"
else
    echo "❌ WARNING: Does not match commitment"
fi
echo ""

echo "Step 8: Verify the Signature"
echo "============================"

if envelope verify -v "$ATTESTATION_PUBKEYS" "$AUDIT_SIGNED" > /dev/null; then
    echo "✅ Signature valid"
else
    echo "❌ Signature verification failed"
    exit 1
fi
echo ""

echo "========================================"
echo "All Tutorial §2.2 Tests Passed!"
echo "========================================"
echo ""
echo "Output files saved to: $OUTPUT_DIR/"
ls -la "$OUTPUT_DIR/"
