#!/bin/bash
#
# 03_1_Creating_Edges-SCRIPT.sh
#
# Tests all commands from §3.1, verifying:
# - SSH Signing key creation
# - Edge creation
# - Edge attachment
#
# Usage: bash 03_1_Creating_Edges-SCRIPT.sh


set -e

echo "=== LEARNING XIDS §3.1: Creating Edges ==="
echo ""

# Configuration
XID_NAME="BRadvoc8"
PASSWORD="test-password-for-tutorial"
PUBLISH_URL="https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt"

# Create output directory
OUTPUT_DIR="output/script-03-1-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUTPUT_DIR"


echo "Step 0: Recreate XID"
echo "===================="

# Rebuild seq:0 XID

XID=$(envelope generate keypairs --signing ed25519 | \
    envelope xid new --nickname "BRadvoc8" --generator include --sign inception)
XID_ID=$(envelope xid id $XID)

# Add dereferenceVia
XID_WITH_URL=$(envelope xid resolution add \
    "$PUBLISH_URL" \
    --verify inception \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$XID")

# Rebuild seq:1 XID

ATTESTATION_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
ATTESTATION_PUBKEYS=$(envelope generate pubkeys "$ATTESTATION_PRVKEYS")

XID=$(envelope xid key add \
    --verify inception \
    --nickname "attestation-key" \
    --allow sign \
    --private encrypt \
    --encrypt-password "$PASSWORD" \
    "$ATTESTATION_PRVKEYS" \
    "$XID")

XID=$(envelope xid provenance next \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$XID")

echo ""
echo "Step 1: Generate SSH Signing Key"
echo "================================"

SSH_PRVKEYS=$(envelope generate prvkeys --signing ssh-ed25519)
SSH_PUBKEYS=$(envelope generate pubkeys "$SSH_PRVKEYS")
SSH_EXPORT=$(envelope export "$SSH_PUBKEYS")

if echo "$SSH_EXPORT" | grep -q "ssh-ed25519"; then
    echo "✅ Generated SSH signing key"
    echo "$SSH_EXPORT"
else
    echo "❌ ERROR: SSH key not in expected format"
    exit 1
fi

echo ""
echo "Step 4: Create Ownership Claim"
echo "=============================="


# isA

ISA="foaf:OnlineAccount"

# Target

GH_NAME="BRadvoc8"
TARGET=$(envelope subject type ur "$XID_ID")
TARGET=$(envelope assertion add pred-obj string "foaf:accountName" string "$GH_NAME" "$TARGET")
TARGET=$(envelope assertion add pred-obj string "foaf:accountServiceHomepage" uri "https://github.com/$GH_NAME/$GH_NAME" "$TARGET")
TARGET=$(envelope assertion add pred-obj string "sshSigningKey" ur "$SSH_PUBKEYS" "$TARGET")
TARGET=$(envelope assertion add pred-obj string "sshSigningKeyText" string "$SSH_EXPORT" "$TARGET")
TARGET=$(envelope assertion add pred-obj string "sshSigningKeysURL" uri "https://api.github.com/users/$GH_NAME/ssh_signing_keys" "$TARGET")
TARGET=$(envelope assertion add pred-obj known conformsTo uri "https://github.com" "$TARGET")
TARGET=$(envelope assertion add pred-obj known date string `date -Iminutes` "$TARGET")
TARGET=$(envelope assertion add pred-obj known verifiableAt uri "https://api.github.com/users/$GH_NAME" "$TARGET")

echo "GitHub account credential details:"
envelope format "$TARGET"

echo ""
echo "Step 5: Create the Edge"
echo "======================="

EDGE=$(envelope subject type string "account-credential-github")
EDGE=$(envelope assertion add pred-obj known isA string "$ISA" "$EDGE")
EDGE=$(envelope assertion add pred-obj known source ur "$XID_ID" "$EDGE")
EDGE=$(envelope assertion add pred-obj known target envelope "$TARGET" "$EDGE")

echo "GitHub edge details:"
envelope format "$EDGE"

# Verify all required fields

echo ""

if envelope format "$EDGE" | grep -q "isA"; then
    echo "✅ isA assertion present"
else
    echo "❌ ERROR: isA assertion missing"
    exit 1
fi

if envelope format "$EDGE" | grep -q "source"; then
    echo "✅ source assertion present"
else
    echo "❌ ERROR: source assertion missing"
    exit 1
fi

if envelope format "$EDGE" | grep -q "target"; then
    echo "✅ target assertion present"
else
    echo "❌ ERROR: target assertion missing"
    exit 1
fi

echo ""
echo "Step 6: Wrap & Sign the Edge"
echo "============================"

WRAPPED_EDGE=$(envelope subject type wrapped $EDGE)
SIGNED_EDGE=$(envelope sign --signer "$SSH_PRVKEYS" "$WRAPPED_EDGE")

if envelope format "$SIGNED_EDGE" | grep -q "signed.*SshEd25519"; then
    echo "✅ signed with SSH key"
else
    echo "❌ ERROR: signing missing or incorrect type"
    exit 1
fi

echo ""
echo "Step 7: Link Your Edge"
echo "======================"

XID_WITH_EDGE=$(envelope xid edge add \
    --verify inception \
    $SIGNED_EDGE $XID)

echo "XID with GitHub edge:"
envelope format "$XID_WITH_EDGE"


# Verify edge is present
echo ""
if envelope format "$XID_WITH_EDGE" | grep -q "'edge'"; then
    echo "✅ edge assertion present"
else
    echo "❌ ERROR: edge not found in XID"
    exit 1
fi

echo ""
echo "Step 8: Advance Your Provenance Mark"
echo "===================================="

XID_WITH_EDGE=$(envelope xid provenance next \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$XID_WITH_EDGE")

# Verify provenance advanced to sequence 1
PROV_MARK=$(envelope xid provenance get "$XID_WITH_EDGE")
PROV_JSON=$(provenance validate --format json-compact "$PROV_MARK" 2>&1 | grep -o '{.*}')
PROV_SEQ=$(echo "$PROV_JSON" | jq -r '.chains[0].sequences[0].end_seq')
if [ "$PROV_SEQ" = "2" ]; then
    echo "✅ Provenance advanced to sequence $PROV_SEQ"
else
    echo "❌ ERROR: Expected sequence 2, got $PROV_SEQ"
    exit 1
fi


echo ""
echo "Step 9: Export & Store Your Work"
echo "================================"

PUBLIC_XID_WITH_EDGE=$(envelope xid export --private elide --generator elide "$XID_WITH_EDGE")

echo "$XID_WITH_EDGE" > $OUTPUT_DIR/01-private-xid-with-edge.envelope
echo "$PUBLIC_XID_WITH_EDGE" > $OUTPUT_DIR/02-public-xid-with-edge.envelope
echo "$SSH_PUBKEYS" > $OUTPUT_DIR/03-ssh-keys.ur

echo "✅ XIDs and keys exported"


echo ""
echo "==============================="
echo "All Tutorial §3.1 Tests Passed!"
echo "==============================="
echo ""
echo "Output files saved to: $OUTPUT_DIR/"
ls -la "$OUTPUT_DIR/"
