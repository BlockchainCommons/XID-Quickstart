#!/bin/bash
#
# 02_3_Managing_Claims_Encryption-SCRIPT.md - Test all code examples from §2.3
#
# Tests all commands from §2.3, verifying:
# - Sensitive attestation creation (CivilTrust)
# - Encryption for specific recipient (DevReviewer)
# - Decryption and verification
# - Failed decryption by unauthorized party
#
# Usage: bash 02_3_Managing_Claims_Encryption-SCRIPT.md

set -e

echo "=== LEARNING XIDS §2.3: Managing Sensitive Claims with Encryption CODE TEST ==="
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

echo "Step 1: Create Keys for Receiving"
echo "================================="

# DevReviewer generates keypair for receiving encrypted content
DEVREVIEWER_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
DEVREVIEWER_PUBKEYS=$(envelope generate pubkeys "$DEVREVIEWER_PRVKEYS")

echo "✅ DevReviewer's public key ready to receive encrypted data"

if [ $DEVREVIEWER_PRVKEYS ]
then
  echo "✅ DevReviewer's keys created for receiving encrypted data"
else
  echo "❌ Error in DevReviewer key creation"
  exit 1;
fi

echo "Step 2 Create the CivilTrust Claim"
echo "=================================="

# The sensitive claim (too dangerous for any public trace)
CIVILTRUST_CLAIM=$(envelope subject type string \
  "Designed the authentication system for CivilTrust human rights documentation platform (2024)")

CIVILTRUST_ATTESTATION=$(envelope assertion add pred-obj known isA known 'attestation' "$CIVILTRUST_CLAIM")
CIVILTRUST_ATTESTATION=$(envelope assertion add pred-obj known source ur $XID_ID "$CIVILTRUST_ATTESTATION")
CIVILTRUST_ATTESTATION=$(envelope assertion add pred-obj known target ur $XID_ID "$CIVILTRUST_ATTESTATION")
CIVILTRUST_ATTESTATION=$(envelope assertion add pred-obj known 'date' string `date -Iminutes` "$CIVILTRUST_ATTESTATION")
CIVILTRUST_ATTESTATION=$(envelope assertion add pred-obj string "privacyRisk" string "Links to legal identity via contributor list" "$CIVILTRUST_ATTESTATION")
CIVILTRUST_ATTESTATION_WRAPPED=$(envelope subject type wrapped $CIVILTRUST_ATTESTATION)
CIVILTRUST_ATTESTATION_SIGNED=$(envelope sign --signer "$ATTESTATION_PRVKEYS" "$CIVILTRUST_ATTESTATION_WRAPPED")

if [ $CIVILTRUST_ATTESTATION ]
then
  echo "✅ Created CivilTrust attestation"
else
  echo "❌ Error in CivilTrust attestation creation"
  exit 1;
fi

echo ""
echo "Attestation structure  (before encryption):"
envelope format "$CIVILTRUST_SIGNED"
echo ""

echo "Step 3: Encrypt for DevReviewer"
echo "==============================="

CIVILTRUST_ATTESTATION_ENCRYPTED=$(envelope encrypt --recipient "$DEVREVIEWER_PUBKEYS" "$CIVILTRUST_ATTESTATION_SIGNED")

if [ envelope format $CIVILTRUST_ATTESTATION_ENCRYPTED | grep -q "ENCRYPTED" ]
then
  echo "✅ Encrypted attestation (only DevReviewer can decrypt):"
else
  echo "❌ Error in CivilTrust attestation encryption"
  exit 1;
fi

echo "Encrypted format (content completely hidden):"
envelope format "$CIVILTRUST_ATTESTATION_ENCRYPTED"
echo ""

echo "Step 4: Review Your Work & Store It"
echo "==================================="

echo "$CIVILTRUST_ATTESTATION" > "$OUTPUT_DIR/01-claim-signed.envelope"
envelope format "$ATTESTATION_SIGNED" > "$OUTPUT_DIR/01-claim-signed.format"
echo "✅ Attestation Saved to: $OUTPUT_DIR/01-claim-signed.envelope"

echo "$CIVILTRUST_ATTESTATION_ENCRYPTED" > "$OUTPUT_DIR/01-claim-signed-encrypted.envelope"
envelope format "$ATTESTATION_SIGNED_ENCRYPTED" > "$OUTPUT_DIR/01-claim-signed-encrypted.format"
echo "✅ Attestation Saved to: $OUTPUT_DIR/01-claim-signed-encrypted.envelope"


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
