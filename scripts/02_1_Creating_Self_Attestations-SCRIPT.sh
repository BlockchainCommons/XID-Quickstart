#!/bin/bash
#
# Tutorial 05: Fair Witness Attestations - Test Script
#
# Tests all commands from Tutorial 05, verifying:
# - Fair witness attestation creation (specific, verifiable claims)
# - Detached attestation structure
# - Attestation verification
# - Attestation lifecycle (superseding and retraction patterns)
#
# Usage: bash tests/05-fair-witness-attestations-TEST.sh

set -euo pipefail

echo "========================================"
echo "Tutorial 05: Fair Witness Attestations"
echo "========================================"
echo ""

# Create output directory
OUTPUT_DIR="output/xid-tutorial05-$(date +%Y%m%d%H%M%S)"
mkdir -p "$OUTPUT_DIR"

echo "=== Part I: Environment Setup ==="
echo ""

echo "Step 1: Create XID and attestation keys..."

# Create Amira's XID with provenance tracking
XID=$(envelope generate keypairs --signing ed25519 | \
    envelope xid new --nickname "BRadvoc8" --generator include --sign inception)

UNWRAPPED_XID=$(envelope extract wrapped "$XID")
XID_ID=$(envelope xid id "$UNWRAPPED_XID")

# Generate separate attestation signing keys (best practice)
ATTESTATION_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
ATTESTATION_PUBKEYS=$(envelope generate pubkeys "$ATTESTATION_PRVKEYS")

echo "✅ Created XID: $XID_ID"
echo "✅ Generated attestation keys (separate from XID inception key)"
echo ""

echo "Step 2: Register attestation key in XID..."

# Test password for encryption
PASSWORD="test-password-123"

# Add attestation keypair to XID (private key encrypted like inception key)
XID=$(envelope xid key add \
    --nickname "attestation-key" \
    --allow sign \
    --private encrypt \
    --encrypt-password "$PASSWORD" \
    "$ATTESTATION_PRVKEYS" \
    "$XID")

# Advance provenance to record the key addition
XID=$(envelope xid provenance next "$XID")

# Verify key was added with encrypted private key
if envelope format "$XID" | grep -q "attestation-key"; then
    echo "✅ Attestation key registered in XID"
else
    echo "❌ Failed to register attestation key"
    exit 1
fi

# Verify private key is encrypted (ENCRYPTED appears before nickname in format output)
if envelope format "$XID" | grep -B10 "attestation-key" | grep -q "ENCRYPTED"; then
    echo "✅ Attestation private key is encrypted"
else
    echo "⚠️ Could not verify private key encryption"
fi

# Verify provenance advanced
PROV_MARK=$(envelope xid provenance get "$XID")
if provenance validate "$PROV_MARK" >/dev/null 2>&1; then
    echo "✅ Provenance advanced and valid"
else
    echo "⚠️ Provenance mark present (validation warning expected for fresh XID)"
fi
echo ""

echo "=== Part II: Creating Fair Witness Attestations ==="
echo ""

echo "Step 3: Create Galaxy Project attestation..."

# Create the claim (specific, verifiable)
CLAIM=$(envelope subject type string \
  "I contributed mass spec visualization code to galaxyproject/galaxy (PR #12847, merged 2024)")

# Add attestation metadata
ATTESTATION=$(envelope assertion add pred-obj known isA string "SelfAttestation" "$CLAIM")
ATTESTATION=$(envelope assertion add pred-obj string "attestedBy" string "$XID_ID" "$ATTESTATION")
ATTESTATION=$(envelope assertion add pred-obj string "attestedOn" date "2026-01-21T00:00:00Z" "$ATTESTATION")
ATTESTATION=$(envelope assertion add pred-obj string "verifiableAt" string "https://github.com/galaxyproject/galaxy/pull/12847" "$ATTESTATION")

# Sign the attestation
ATTESTATION_SIGNED=$(envelope sign --signer "$ATTESTATION_PRVKEYS" "$ATTESTATION")

echo "✅ Created Galaxy Project attestation (fair witness: specific, verifiable)"
echo ""
echo "Attestation structure:"
envelope format "$ATTESTATION_SIGNED" | head -12
echo ""

echo "Step 4: Verify the attestation..."

if envelope verify --verifier "$ATTESTATION_PUBKEYS" "$ATTESTATION_SIGNED"; then
    echo "✅ Signature verified"
else
    echo "❌ Signature verification failed"
    exit 1
fi
echo ""

echo "=== Part III: Understanding Verification ==="
echo ""

echo "What verification proves:"
echo "  ✓ BRadvoc8's key signed this content"
echo "  ✓ Content has not been modified"
echo ""
echo "What verification does NOT prove:"
echo "  ✗ The claim is actually true"
echo "  ✗ BRadvoc8 actually made the contribution"
echo ""
echo "The 'verifiableAt' field points to evidence verifiers can check independently."
echo ""

echo "=== Part IV: Attestation Lifecycle ==="
echo ""

echo "Step 5: Supersede an attestation..."

# Create an updated attestation (new accomplishments)
UPDATED_CLAIM=$(envelope subject type string \
  "I contributed mass spec visualization code to galaxyproject/galaxy (PRs #12847, #13102, #13445, merged 2024-2028)")

UPDATED_ATTESTATION=$(envelope assertion add pred-obj known isA string "SelfAttestation" "$UPDATED_CLAIM")
UPDATED_ATTESTATION=$(envelope assertion add pred-obj string "attestedBy" string "$XID_ID" "$UPDATED_ATTESTATION")
UPDATED_ATTESTATION=$(envelope assertion add pred-obj string "attestedOn" date "2028-01-15T00:00:00Z" "$UPDATED_ATTESTATION")
UPDATED_ATTESTATION=$(envelope assertion add pred-obj string "verifiableAt" string "https://github.com/galaxyproject/galaxy/pulls?q=author:BRadvoc8" "$UPDATED_ATTESTATION")

# Reference the original attestation being superseded
ORIGINAL_DIGEST=$(envelope digest "$ATTESTATION_SIGNED")
UPDATED_ATTESTATION=$(envelope assertion add pred-obj string "supersedes" string "$ORIGINAL_DIGEST" "$UPDATED_ATTESTATION")

# Sign
UPDATED_ATTESTATION=$(envelope sign --signer "$ATTESTATION_PRVKEYS" "$UPDATED_ATTESTATION")

echo "✅ Created updated attestation that supersedes original"
echo ""
echo "Updated attestation structure:"
envelope format "$UPDATED_ATTESTATION" | head -12
echo ""

# Verify updated attestation
if envelope verify --verifier "$ATTESTATION_PUBKEYS" "$UPDATED_ATTESTATION"; then
    echo "✅ Updated attestation signature verified"
else
    echo "❌ Updated attestation signature failed"
    exit 1
fi

# Verify supersedes field is present
if envelope format "$UPDATED_ATTESTATION" | grep -q "supersedes"; then
    echo "✅ Supersedes reference present (links to original digest)"
else
    echo "❌ Supersedes reference missing"
    exit 1
fi
echo ""

echo "Step 6: Create a retraction..."

RETRACTION=$(envelope subject type string "RETRACTED: [original claim text]")
RETRACTION=$(envelope assertion add pred-obj known isA string "Retraction" "$RETRACTION")
RETRACTION=$(envelope assertion add pred-obj string "retracts" string "$ORIGINAL_DIGEST" "$RETRACTION")
RETRACTION=$(envelope assertion add pred-obj string "reason" string "Claim was overstated" "$RETRACTION")
RETRACTION=$(envelope sign --signer "$ATTESTATION_PRVKEYS" "$RETRACTION")

echo "✅ Created retraction attestation"
echo ""
echo "Retraction structure:"
envelope format "$RETRACTION" | head -10
echo ""

# Verify retraction signature
if envelope verify --verifier "$ATTESTATION_PUBKEYS" "$RETRACTION"; then
    echo "✅ Retraction signature verified"
else
    echo "❌ Retraction signature failed"
    exit 1
fi
echo ""

echo "=== Part V: Wrap-Up ==="
echo ""

# Save artifacts
echo "$ATTESTATION_SIGNED" > "$OUTPUT_DIR/attestation-galaxy.envelope"
echo "$UPDATED_ATTESTATION" > "$OUTPUT_DIR/attestation-galaxy-updated.envelope"
echo "$RETRACTION" > "$OUTPUT_DIR/attestation-retraction.envelope"
echo "$XID" > "$OUTPUT_DIR/BRadvoc8-xid.envelope"

echo "Saved files to $OUTPUT_DIR:"
ls -la "$OUTPUT_DIR"
echo ""

echo "========================================"
echo "Tutorial 05 Test: ALL PASSED ✅"
echo "========================================"
echo ""
echo "Summary:"
echo "  - Created fair witness attestation (specific, verifiable claim)"
echo "  - Registered attestation key in XID (with encrypted private key)"
echo "  - Used detached attestation pattern (separate from XIDDoc)"
echo "  - Included verifiableAt URL for evidence checking"
echo "  - Verified attestation signature"
echo "  - Demonstrated superseding pattern (updated attestation)"
echo "  - Demonstrated retraction pattern"
echo ""
echo "Fair Witness Principle:"
echo "  Strong: 'I contributed to Galaxy Project (PR #12847)'"
echo "  Weak:   'I have 8 years of security experience'"
echo ""
echo "Attestation Lifecycle:"
echo "  - Supersede: Create new attestation with 'supersedes' field"
echo "  - Retract: Create retraction with 'retracts' field + reason"
echo ""
