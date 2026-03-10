#!/bin/bash
#
# Tutorial 06: Managing Sensitive Claims - Test Script
#
# Tests all commands from Tutorial 06, verifying:
# - Correlation risk concepts
# - Elided commitment creation
# - Inclusion proof verification
# - Full attestation reveal and verification
#
# Usage: bash tests/06-managing-sensitive-claims-TEST.sh

set -euo pipefail

echo "========================================"
echo "Tutorial 06: Managing Sensitive Claims"
echo "========================================"
echo ""

# Create output directory
OUTPUT_DIR="output/xid-tutorial06-$(date +%Y%m%d%H%M%S)"
mkdir -p "$OUTPUT_DIR"

echo "=== Part I: Environment Setup ==="
echo ""

echo "Step 1: Create XID and attestation keys..."

# Create Amira's XID
XID=$(envelope generate keypairs --signing ed25519 | \
    envelope xid new --nickname "BRadvoc8" --generator include --sign inception)

UNWRAPPED_XID=$(envelope extract wrapped "$XID")
XID_ID=$(envelope xid id "$UNWRAPPED_XID")

# Attestation keys
ATTESTATION_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
ATTESTATION_PUBKEYS=$(envelope generate pubkeys "$ATTESTATION_PRVKEYS")

echo "✅ Created XID: $XID_ID"
echo ""

echo "=== Part II: Creating Sensitive Attestation ==="
echo ""

echo "Step 2: Create crypto audit attestation..."

# Create the sensitive claim
AUDIT_CLAIM=$(envelope subject type string \
  "I audited cryptographic implementations for authentication systems (2023-2024)")

AUDIT_CLAIM=$(envelope assertion add pred-obj known isA string "SelfAttestation" "$AUDIT_CLAIM")
AUDIT_CLAIM=$(envelope assertion add pred-obj string "attestedBy" string "$XID_ID" "$AUDIT_CLAIM")
AUDIT_CLAIM=$(envelope assertion add pred-obj string "attestedOn" date "2026-01-21T00:00:00Z" "$AUDIT_CLAIM")
AUDIT_CLAIM=$(envelope assertion add pred-obj string "skillCategory" string "Security" "$AUDIT_CLAIM")

echo "✅ Created sensitive attestation (crypto audit experience)"
echo ""

echo "Step 3: Sign the full attestation..."

AUDIT_SIGNED=$(envelope sign --signer "$ATTESTATION_PRVKEYS" "$AUDIT_CLAIM")

echo "✅ Full attestation signed"
echo ""
echo "Full attestation structure:"
envelope format "$AUDIT_SIGNED" | head -10
echo ""

echo "=== Part III: Creating Elided Commitment ==="
echo ""

echo "Step 4: Create elided version..."

AUDIT_DIGEST=$(envelope digest "$AUDIT_SIGNED")
AUDIT_ELIDED=$(envelope elide removing "$AUDIT_DIGEST" "$AUDIT_SIGNED")

echo "✅ Elided commitment created"
echo "   Digest: ${AUDIT_DIGEST:0:40}..."
echo ""

echo "Step 5: Verify digests match (inclusion proof foundation)..."

FULL_DIGEST=$(envelope digest "$AUDIT_SIGNED")
ELIDED_DIGEST=$(envelope digest "$AUDIT_ELIDED")

echo "   Full attestation digest:  ${FULL_DIGEST:0:40}..."
echo "   Elided version digest:    ${ELIDED_DIGEST:0:40}..."

if [ "$FULL_DIGEST" = "$ELIDED_DIGEST" ]; then
    echo "✅ Digests match - inclusion proof possible"
else
    echo "❌ Digests don't match - this should not happen"
    exit 1
fi
echo ""

echo "Step 6: Show what elided version looks like..."

echo "   Elided format:"
envelope format "$AUDIT_ELIDED"
echo ""
echo "   (Content hidden, but cryptographic identity preserved)"
echo ""

echo "=== Part IV: Simulating Reveal to DevReviewer ==="
echo ""

echo "Step 7: DevReviewer receives full attestation..."
echo "   (Amira sends AUDIT_SIGNED to DevReviewer)"
echo ""

echo "Step 8: DevReviewer verifies inclusion proof..."

# DevReviewer computes digest of received attestation
RECEIVED_DIGEST=$(envelope digest "$AUDIT_SIGNED")

if [ "$RECEIVED_DIGEST" = "$ELIDED_DIGEST" ]; then
    echo "✅ Inclusion proof valid: matches public commitment"
else
    echo "❌ Does not match commitment"
    exit 1
fi
echo ""

echo "Step 9: DevReviewer verifies signature..."

if envelope verify --verifier "$ATTESTATION_PUBKEYS" "$AUDIT_SIGNED"; then
    echo "✅ Signature valid"
else
    echo "❌ Signature verification failed"
    exit 1
fi
echo ""

echo "=== Part V: Demonstrating Elided Limitations ==="
echo ""

echo "Step 10: Show that elided version alone proves nothing about content..."

echo "   Elided version format: $(envelope format "$AUDIT_ELIDED")"
echo "   (No content to read, no signature to verify against content)"
echo ""

echo "Step 11: Try to verify elided version (should fail)..."

if envelope verify --verifier "$ATTESTATION_PUBKEYS" "$AUDIT_ELIDED" 2>/dev/null; then
    echo "❌ Elided version should NOT have verified"
    exit 1
else
    echo "✅ Verification correctly failed - no signature in elided version"
fi
echo ""
echo "   The elided version proves EXISTENCE and TIMING"
echo "   The full version proves CONTENT and AUTHENTICITY"
echo ""

echo "=== Part VI: Wrap-Up ==="
echo ""

# Save artifacts
echo "$AUDIT_SIGNED" > "$OUTPUT_DIR/audit-attestation-FULL.envelope"
echo "$AUDIT_ELIDED" > "$OUTPUT_DIR/audit-attestation-ELIDED.envelope"
echo "$AUDIT_DIGEST" > "$OUTPUT_DIR/audit-digest.txt"
echo "$XID" > "$OUTPUT_DIR/BRadvoc8-xid.envelope"
echo "$ATTESTATION_PRVKEYS" > "$OUTPUT_DIR/attestation-prvkeys.envelope"

echo "Saved files to $OUTPUT_DIR:"
ls -la "$OUTPUT_DIR"
echo ""

echo "========================================"
echo "Tutorial 06 Test: ALL PASSED ✅"
echo "========================================"
echo ""
echo "Summary:"
echo "  - Created sensitive attestation (crypto audit)"
echo "  - Created elided commitment (safe to share publicly)"
echo "  - Verified inclusion proof (digests match)"
echo "  - Simulated reveal to DevReviewer"
echo "  - Verified signature on full attestation"
echo ""
echo "Three Disclosure Approaches:"
echo "  1. Omit entirely - never publish"
echo "  2. Commit elided - prove timing, reveal later"
echo "  3. Encrypt for recipient - direct private sharing"
echo ""
echo "Correlation Risk Reminder:"
echo "  Each claim narrows your anonymity set."
echo "  Combined claims can uniquely identify you."
echo ""
