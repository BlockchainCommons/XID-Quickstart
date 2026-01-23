#!/bin/bash
#
# Tutorial 07: Encrypted Sharing - Test Script
#
# Tests all commands from Tutorial 07, verifying:
# - Sensitive attestation creation (CivilTrust)
# - Encryption for specific recipient (DevReviewer)
# - Decryption and verification
# - Failed decryption by unauthorized party
#
# Usage: bash tests/07-encrypted-sharing-TEST.sh

set -euo pipefail

echo "========================================"
echo "Tutorial 07: Encrypted Sharing"
echo "========================================"
echo ""

# Create output directory
OUTPUT_DIR="output/xid-tutorial07-$(date +%Y%m%d%H%M%S)"
mkdir -p "$OUTPUT_DIR"

echo "=== Part I: Setting Up for Encryption ==="
echo ""

echo "Step 1: Establish Amira's identity..."

# Create Amira's XID
XID=$(envelope generate keypairs --signing ed25519 | \
    envelope xid new --nickname "BRadvoc8" --generator include --sign inception)

UNWRAPPED_XID=$(envelope extract wrapped "$XID")
XID_ID=$(envelope xid id "$UNWRAPPED_XID")

# Attestation signing keys
ATTESTATION_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
ATTESTATION_PUBKEYS=$(envelope generate pubkeys "$ATTESTATION_PRVKEYS")

echo "✅ Created Amira's XID: $XID_ID"
echo ""

echo "Step 2: Create DevReviewer's keys (recipient)..."

# DevReviewer generates keys for receiving encrypted data
DEVREVIEWER_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
DEVREVIEWER_PUBKEYS=$(envelope generate pubkeys "$DEVREVIEWER_PRVKEYS")

echo "✅ DevReviewer's keys created for receiving encrypted data"
echo ""

echo "=== Part II: Creating the Sensitive Attestation ==="
echo ""

echo "Step 3: Create CivilTrust attestation..."

# The sensitive claim (too dangerous for any public trace)
CIVILTRUST_CLAIM=$(envelope subject type string \
  "I designed the authentication system for CivilTrust human rights documentation platform (2024)")

# Add attestation metadata
CIVILTRUST_ATTESTATION=$(envelope assertion add pred-obj known isA string "SelfAttestation" "$CIVILTRUST_CLAIM")
CIVILTRUST_ATTESTATION=$(envelope assertion add pred-obj string "attestedBy" string "$XID_ID" "$CIVILTRUST_ATTESTATION")
CIVILTRUST_ATTESTATION=$(envelope assertion add pred-obj string "attestedOn" date "2026-01-21T00:00:00Z" "$CIVILTRUST_ATTESTATION")
CIVILTRUST_ATTESTATION=$(envelope assertion add pred-obj string "privacyRisk" string "Links to legal identity via contributor list" "$CIVILTRUST_ATTESTATION")

# Sign first (proves authenticity)
CIVILTRUST_SIGNED=$(envelope sign --signer "$ATTESTATION_PRVKEYS" "$CIVILTRUST_ATTESTATION")

echo "✅ Created CivilTrust attestation (before encryption)"
echo ""
echo "Attestation structure:"
envelope format "$CIVILTRUST_SIGNED" | head -10
echo ""

echo "Step 4: Encrypt for DevReviewer..."

CIVILTRUST_ENCRYPTED=$(envelope encrypt --recipient "$DEVREVIEWER_PUBKEYS" "$CIVILTRUST_SIGNED")

echo "✅ Encrypted attestation for DevReviewer"
echo ""
echo "Encrypted format (content completely hidden):"
envelope format "$CIVILTRUST_ENCRYPTED"
echo ""

echo "=== Part III: DevReviewer Receives and Verifies ==="
echo ""

echo "Step 5: DevReviewer decrypts..."

CIVILTRUST_DECRYPTED=$(envelope decrypt --recipient "$DEVREVIEWER_PRVKEYS" "$CIVILTRUST_ENCRYPTED")

echo "DevReviewer sees after decryption:"
envelope format "$CIVILTRUST_DECRYPTED" | head -10
echo ""

echo "Step 6: DevReviewer verifies the signature..."

if envelope verify --verifier "$ATTESTATION_PUBKEYS" "$CIVILTRUST_DECRYPTED"; then
    echo "✅ DevReviewer verified the decrypted attestation"
else
    echo "❌ Verification failed"
    exit 1
fi
echo ""

echo "Step 7: Test decryption failure (Charlie intercepts)..."

# Charlie generates his own keys
CHARLIE_PRVKEYS=$(envelope generate prvkeys --signing ed25519)

# Charlie tries to decrypt - should fail
if envelope decrypt --recipient "$CHARLIE_PRVKEYS" "$CIVILTRUST_ENCRYPTED" 2>/dev/null; then
    echo "❌ Charlie should NOT have been able to decrypt"
    exit 1
else
    echo "✅ Charlie's decryption correctly failed (no matching recipient)"
fi
echo ""

echo "=== Part IV: Wrap-Up ==="
echo ""

# Save artifacts
echo "$CIVILTRUST_ENCRYPTED" > "$OUTPUT_DIR/civiltrust-for-devreviewer.envelope"
echo "$XID" > "$OUTPUT_DIR/BRadvoc8-xid.envelope"
echo "$ATTESTATION_PRVKEYS" > "$OUTPUT_DIR/attestation-prvkeys.envelope"

echo "Saved files to $OUTPUT_DIR:"
ls -la "$OUTPUT_DIR"
echo ""

echo "========================================"
echo "Tutorial 07 Test: ALL PASSED ✅"
echo "========================================"
echo ""
echo "Summary:"
echo "  - Created CivilTrust attestation (too sensitive for public trace)"
echo "  - Encrypted for DevReviewer specifically"
echo "  - DevReviewer successfully decrypted and verified"
echo "  - Charlie's decryption correctly failed"
echo ""
echo "Disclosure Approaches Summary:"
echo "  - T05: Public attestation (Galaxy Project - already public)"
echo "  - T06: Commit elided (crypto audit - prove timing later)"
echo "  - T07: Encrypt for recipient (CivilTrust - no public trace)"
echo ""
