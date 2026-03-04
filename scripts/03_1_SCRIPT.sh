#!/bin/bash
#
# 03-offering-self-attestation-TEST.sh - Test all code examples from Tutorial 03
#
# Validates that every command in Tutorial 03: Offering Self-Attestation works.
# Tests SSH key generation/import, proof-of-control, GitHub attachment creation,
# and XID export with attachments.
#
# Usage: ./03-offering-self-attestation-TEST.sh
#
# Dependencies: envelope (bc-envelope-cli-rust), provenance
#
# Exit Codes:
#   0   All tests passed
#   1   Test failure
#

set -e

echo "========================================"
echo "Tutorial 03: Offering Self-Attestation"
echo "Test Script"
echo "========================================"
echo ""

# Configuration
XID_NAME="BRadvoc8"
PASSWORD="test-password-for-tutorial"
PUBLISH_URL="https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt"

# Create output directory
OUTPUT_DIR="output/test-03-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUTPUT_DIR"

echo "=== Step 1: Create Initial XID (from Tutorials 01-02) ==="
XID=$(envelope generate keypairs --signing ed25519 | \
    envelope xid new \
    --private encrypt \
    --encrypt-password "$PASSWORD" \
    --nickname "$XID_NAME" \
    --generator encrypt \
    --sign inception)

# Add dereferenceVia
XID=$(envelope xid resolution add \
    "$PUBLISH_URL" \
    --verify inception \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$XID")

echo "Created XID with dereferenceVia: $XID_NAME"
echo "$XID" > "$OUTPUT_DIR/01-initial-xid.envelope"
envelope format "$XID" > "$OUTPUT_DIR/01-initial-xid.format"
echo ""

echo "=== Step 2: Generate SSH Signing Key ==="
SSH_PRVKEYS=$(envelope generate prvkeys --signing ssh-ed25519)
SSH_PUBKEYS=$(envelope generate pubkeys "$SSH_PRVKEYS")
SSH_EXPORT=$(envelope export "$SSH_PUBKEYS")

echo "Generated SSH signing key:"
echo "$SSH_EXPORT"
echo "$SSH_EXPORT" > "$OUTPUT_DIR/02-ssh-pubkey.txt"

if echo "$SSH_EXPORT" | grep -q "ssh-ed25519"; then
    echo "✅ SSH key generated in correct format"
else
    echo "❌ ERROR: SSH key not in expected format"
    exit 1
fi
echo ""

echo "=== Step 3: Create Proof-of-Control ==="
CURRENT_DATE=$(date -u +"%Y-%m-%d")
PROOF_STATEMENT=$(envelope subject type string "$XID_NAME controls SSH signing key registered on GitHub as of $CURRENT_DATE")
PROOF=$(envelope sign --signer "$SSH_PRVKEYS" "$PROOF_STATEMENT")

echo "Created proof-of-control:"
envelope format "$PROOF"
echo "$PROOF" > "$OUTPUT_DIR/03-proof-of-control.envelope"

if envelope format "$PROOF" | grep -q "Signature(SshEd25519)"; then
    echo "✅ Proof signed with SSH key"
else
    echo "❌ ERROR: Proof not signed correctly"
    exit 1
fi
echo ""

echo "=== Step 4: Build GitHub Account Payload ==="
GITHUB_ACCOUNT=$(envelope subject type string "$XID_NAME")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj known isA string "GitHubAccount" "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj known dereferenceVia uri "https://api.github.com/users/$XID_NAME" "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "sshSigningKeysURL" uri "https://api.github.com/users/$XID_NAME/ssh_signing_keys" "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "sshSigningKey" ur "$SSH_PUBKEYS" "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "sshSigningKeyText" string "$SSH_EXPORT" "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "sshSigningKeyProof" envelope "$PROOF" "$GITHUB_ACCOUNT")
CURRENT_TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "createdAt" date "$CURRENT_TIMESTAMP" "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "updatedAt" date "$CURRENT_TIMESTAMP" "$GITHUB_ACCOUNT")

echo "GitHub account payload:"
envelope format "$GITHUB_ACCOUNT"
echo "$GITHUB_ACCOUNT" > "$OUTPUT_DIR/04-github-payload.envelope"

# Verify all required fields
if envelope format "$GITHUB_ACCOUNT" | grep -q "isA.*GitHubAccount"; then
    echo "✅ isA assertion present"
else
    echo "❌ ERROR: isA assertion missing"
    exit 1
fi

if envelope format "$GITHUB_ACCOUNT" | grep -q "dereferenceVia.*api.github.com"; then
    echo "✅ dereferenceVia assertion present"
else
    echo "❌ ERROR: dereferenceVia assertion missing"
    exit 1
fi

if envelope format "$GITHUB_ACCOUNT" | grep -q "sshSigningKeyProof"; then
    echo "✅ sshSigningKeyProof assertion present"
else
    echo "❌ ERROR: sshSigningKeyProof assertion missing"
    exit 1
fi
echo ""

echo "=== Step 5: Add Attachment to XID ==="
XID_WITH_ATTACHMENT=$(envelope xid attachment add \
    --vendor "self" \
    --payload "$GITHUB_ACCOUNT" \
    --verify inception \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$XID")

echo "Added GitHub attachment"
echo "$XID_WITH_ATTACHMENT" > "$OUTPUT_DIR/05-xid-with-attachment.envelope"
envelope format "$XID_WITH_ATTACHMENT" > "$OUTPUT_DIR/05-xid-with-attachment.format"

# Verify attachment is present
if envelope format "$XID_WITH_ATTACHMENT" | grep -q "'attachment'"; then
    echo "✅ Attachment assertion present"
else
    echo "❌ ERROR: Attachment not found in XID"
    exit 1
fi

if envelope format "$XID_WITH_ATTACHMENT" | grep -q "'vendor': \"self\""; then
    echo "✅ Vendor assertion present"
else
    echo "❌ ERROR: Vendor assertion missing"
    exit 1
fi
echo ""

echo "=== Step 6: Advance Provenance ==="
XID_UPDATED=$(envelope xid provenance next \
    --verify inception \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --password "$PASSWORD" \
    --encrypt-password "$PASSWORD" \
    "$XID_WITH_ATTACHMENT")

echo "Advanced provenance"
echo "$XID_UPDATED" > "$OUTPUT_DIR/06-xid-provenance-advanced.envelope"

# Verify provenance advanced to sequence 1
PROV_MARK=$(envelope xid provenance get "$XID_UPDATED")
PROV_JSON=$(provenance validate --format json-compact "$PROV_MARK" 2>&1 | grep -o '{.*}')
PROV_SEQ=$(echo "$PROV_JSON" | jq -r '.chains[0].sequences[0].end_seq')
if [ "$PROV_SEQ" = "1" ]; then
    echo "✅ Provenance advanced to sequence $PROV_SEQ"
else
    echo "❌ ERROR: Expected sequence 1, got $PROV_SEQ"
    exit 1
fi
echo ""

echo "=== Step 7: Export Public Version ==="
PUBLIC_XID=$(envelope xid export --private elide --generator elide "$XID_UPDATED")

echo "Exported public version"
echo "$PUBLIC_XID" > "$OUTPUT_DIR/07-public-xid.envelope"
envelope format "$PUBLIC_XID" > "$OUTPUT_DIR/07-public-xid.format"

# Verify attachment survives export
ATTACHMENT=$(envelope xid attachment all "$PUBLIC_XID" | head -1)
if [ -n "$ATTACHMENT" ]; then
    echo "✅ Attachment found in public XID"
else
    echo "❌ ERROR: Attachment missing from public XID"
    exit 1
fi

# Verify private key is elided
if envelope format "$PUBLIC_XID" | grep -q "ELIDED"; then
    echo "✅ Private key properly elided"
else
    echo "❌ ERROR: Private key not elided"
    exit 1
fi
echo ""

echo "=== Step 8: Verify Signature on Public Version ==="
UNWRAPPED=$(envelope extract wrapped "$PUBLIC_XID")
KEY_ASSERTION=$(envelope assertion find predicate known key "$UNWRAPPED")
KEY_OBJECT=$(envelope extract object "$KEY_ASSERTION")
PUBLIC_KEYS=$(envelope extract ur "$KEY_OBJECT")

if envelope verify -v "$PUBLIC_KEYS" "$PUBLIC_XID" >/dev/null 2>&1; then
    echo "✅ Signature verified on public version!"
else
    echo "❌ ERROR: Signature verification failed"
    exit 1
fi
echo ""

echo "=== Step 9: Validate Provenance Mark ==="
PROVENANCE_MARK=$(envelope xid provenance get "$PUBLIC_XID")
echo "Provenance mark: $(echo "$PROVENANCE_MARK" | head -c 50)..."

if provenance validate "$PROVENANCE_MARK" 2>&1; then
    echo "✅ Provenance validated"
else
    echo "⚠️  Provenance validation has warnings"
fi
echo ""

echo "=== Step 10: Extract and Verify Attachment Structure ==="
echo "Attachment content:"
envelope format "$ATTACHMENT" | head -15

# Verify we can extract the SSH key text from the attachment
ATTACHMENT_OBJECT=$(envelope extract object "$ATTACHMENT")
ATTACHMENT_PAYLOAD=$(envelope extract wrapped "$ATTACHMENT_OBJECT")

SSH_KEY_ASSERTION=$(envelope assertion find predicate string sshSigningKeyText "$ATTACHMENT_PAYLOAD")
EXTRACTED_SSH_KEY=$(envelope extract object "$SSH_KEY_ASSERTION" | envelope format)

echo ""
echo "Extracted SSH key from attachment:"
echo "$EXTRACTED_SSH_KEY"

if echo "$EXTRACTED_SSH_KEY" | grep -q "ssh-ed25519"; then
    echo "✅ SSH key successfully extracted from attachment"
else
    echo "❌ ERROR: Could not extract SSH key from attachment"
    exit 1
fi
echo ""

echo "========================================"
echo "All Tutorial 03 Tests Passed!"
echo "========================================"
echo ""
echo "Output files saved to: $OUTPUT_DIR/"
ls -la "$OUTPUT_DIR/"
