#!/bin/bash
#
# 02_1_Creating_Self_Attestations-SCRIPT.sh - Test all code examples from §2.1
#
# Tests all commands from §2.1: Creating Self Attestations, validating
# - Fair witness attestation creation (specific, verifiable claims)
# - Detached attestation structure
# - Attestation verification
# - Attestation lifecycle (superseding and retraction patterns)
#
# Usage: ./02_1_Creating_Self_Attestations-SCRIPT.sh
#
# Exit Codes:
#   0   All tests passed
#   1   Test failure
#

set -e

echo "=== LEARNING XIDS §2.1: Creating Self Attestations CODE TEST ==="
echo ""

# Create output directory
OUTPUT_DIR="output/script-02-1-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUTPUT_DIR"

echo "Step 0: Load Your XID"
echo "====================="

# Create Amira's XID with provenance tracking
XID=$(envelope generate keypairs --signing ed25519 | \
    envelope xid new --nickname "BRadvoc8" --generator include --sign inception)
XID_ID=$(envelope xid id $XID)
PASSWORD="test-password-for-tutorial"

echo ""

echo "Step 1: Create an Attestation Key"
echo "================================="

# Generate separate attestation signing keys (best practice)
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

echo "Step 2: Register Attestation Key in XID"
echo "======================================="

# Add attestation keypair to XID (private key encrypted like inception key)
XID=$(envelope xid key add \
    --nickname "attestation-key" \
    --allow sign \
    --private encrypt \
    --encrypt-password "$PASSWORD" \
    "$ATTESTATION_PRVKEYS" \
    "$XID")

echo ""

echo "Step 3: Advance Your Provenance Mark"
echo "===================================="

# Advance provenance to record the key addition
O_PROV_MARK=$(envelope xid provenance get "$XID")
XID=$(envelope xid provenance next "$XID")
PROV_MARK=$(envelope xid provenance get "$XID")

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
    exit 1
fi

echo ""

echo "Step 4: Export & Store Your Work"
echo "================================"

echo "$ATTESTATION_PRVKEYS" > "$OUTPUT_DIR/00-attestation-private-keys.ur"
echo "✅ Saved Prvkeys to: $OUTPUT_DIR/00-attestation-private-keys.ur"

echo "$ATTESTATION_PUBKEYS" > "$OUTPUT_DIR/00-attestation-public-keys.ur"
echo "✅ Saved Pubkeys to: $OUTPUT_DIR/00-attestation-public-keys.ur"

echo "$XID" > "$OUTPUT_DIR/01-attestation-private-xid.envelope"
envelope format "$XID" > "$OUTPUT_DIR/01-attestation-private-xid.format"
echo "✅ Saved XID to: $OUTPUT_DIR/01-attestation-private-xid.envelope"

PUBLIC_XID=$(envelope xid export --private elide --generator elide "$XID")

echo "$PUBLIC_XID" > "$OUTPUT_DIR/01-attestation-public-xid.envelope"
envelope format "$PUBLIC_XID" > "$OUTPUT_DIR/01-attestation-public-xid.format"
echo "✅ Saved PUBLIC XID to: $OUTPUT_DIR/01-attestation-public-xid.envelope"

echo ""

echo "Step 6: Create the Claim"
echo "========================"

# Create the claim (specific, verifiable)
CLAIM=$(envelope subject type string \
  "Contributed mass spec visualization code to galaxyproject/galaxy (PR #12847, merged 2024)")

echo ""

echo "Step 7: Add Attestation Metadata"
echo "================================"

# Add attestation metadata
ATTESTATION=$(envelope assertion add pred-obj known isA known 'attestation' "$CLAIM")
ATTESTATION=$(envelope assertion add pred-obj known source ur $XID_ID "$ATTESTATION")
ATTESTATION=$(envelope assertion add pred-obj known target ur $XID_ID "$ATTESTATION")
ATTESTATION=$(envelope assertion add pred-obj known 'verifiableAt' uri "https://github.com/galaxyproject/galaxy/pull/12847" "$ATTESTATION")
ATTESTATION=$(envelope assertion add pred-obj known 'date' string `date -Iminutes` "$ATTESTATION")

echo ""

echo "Step 8: Sign the Attestation & Store It"
echo "======================================="

# Sign the attestation
ATTESTATION_WRAPPED=$(envelope subject type wrapped $ATTESTATION)
ATTESTATION_SIGNED=$(envelope sign --signer "$ATTESTATION_PRVKEYS" "$ATTESTATION_WRAPPED")

if [ $ATTESTATION_SIGNED ]
then
    echo "✅ Created Galaxy Project attestation (fair witness: specific, verifiable)"
else
    echo "❌ Signature verification failed"
    exit 1
fi
echo ""

echo "Attestation structure:"
envelope format "$ATTESTATION_SIGNED"
echo ""

echo "$ATTESTATION_SIGNED" > "$OUTPUT_DIR/02-claim-signed.envelope"
envelope format "$ATTESTATION_SIGNED" > "$OUTPUT_DIR/02-claim-signed.format"
echo "✅ attestation Saved to: $OUTPUT_DIR/02-claim-signed.envelope"

echo ""

echo "Step 10: Check the New Provenance Mark"
echo "======================================="

echo "Sequence of New Provenance Mark:"
provenance validate --format json-compact "$PROV_MARK" 2>&1 | grep -o '"end_seq":[0-9]*'
echo ""

echo "Sequence of Original Provenance Mark:"
provenance validate --format json-compact "$O_PROV_MARK" 2>&1 | grep -o '"end_seq":[0-9]*'
echo ""

# Verify provenance advanced
if provenance validate "$O_PROV_MARK" "$PROV_MARK" >/dev/null 2>&1; then
    echo "✅ Provenance advanced and valid"
else
    echo "❌ Provenance marks do not match"
    exit 1
fi
echo ""

echo "Step 11: Check the Claim's Signature"
echo "===================================="

read -a PUBKEY <<< $(envelope xid key all "$PUBLIC_XID")

for i in "${PUBKEY[@]}"
  do
    if envelope verify -v $i $ATTESTATION_SIGNED >/dev/null 2>&1; then
      echo "✅ One of the signatures verified"
      j=1
      echo $i
    fi
done

if [ -z $j ]
then
    echo "❌ No matching signature found"
    exit 1
fi

echo "Step 14: Supersede an Attestation"
echo "================================="

# Create an updated attestation (new accomplishments)
S_ATTESTATION=$(envelope subject type string \
  "Contributed mass spec visualization and data pipeline code to galaxyproject/galaxy (PRs #12847, #14201, #15892, 2024-2026)")
S_ATTESTATION=$(envelope assertion add pred-obj known isA known 'attestation' "$S_ATTESTATION")
S_ATTESTATION=$(envelope assertion add pred-obj known source ur $XID_ID "$S_ATTESTATION")
S_ATTESTATION=$(envelope assertion add pred-obj known target ur $XID_ID "$S_ATTESTATION")
S_ATTESTATION=$(envelope assertion add pred-obj known 'verifiableAt' uri "https://github.com/galaxyproject/galaxy/pulls?q=author:BRadvoc8" "$S_ATTESTATION")
S_ATTESTATION=$(envelope assertion add pred-obj known 'date' string `date -Iminutes` "$S_ATTESTATION")

# Reference the original attestation being superseded
ORIGINAL_DIGEST=$(envelope digest "$ATTESTATION_SIGNED")
S_ATTESTATION=$(envelope assertion add pred-obj string "supersedes" digest "$ORIGINAL_DIGEST" "$S_ATTESTATION")

# Sign
S_WRAPPED_ATTESTATION=$(envelope subject type wrapped $S_ATTESTATION)
S_SIGNED_ATTESTATION=$(envelope sign --signer "$ATTESTATION_PRVKEYS" "$S_WRAPPED_ATTESTATION")

echo "✅ Updated attestation (supersedes original):"
envelope format "$S_SIGNED_ATTESTATION" | head -12

# Verify superseded attestation
for i in "${PUBKEY[@]}"
  do
    if envelope verify -v $i $S_SIGNED_ATTESTATION >/dev/null 2>&1; then
      echo "✅ One of the signatures verified"
      k=1
      echo $i
    fi
done

if [ -z $k ]
then
    echo "❌ No matching signature found"
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

echo "$S_SIGNED_ATTESTATION" > "$OUTPUT_DIR/03-claim-superseded-signed.envelope"
envelope format "$S_SIGNED_ATTESTATION" > "$OUTPUT_DIR/03-claim-superseded-signed.format"
echo "✅ attestation Saved to: $OUTPUT_DIR/03-claim-superseded-signed.envelope"


echo "Step 15: Retract an Attestation"
echo "==============================="

RETRACTION=$(envelope subject type string "RETRACTED: [original claim text]")
RETRACTION=$(envelope assertion add pred-obj known isA string "retraction" "$RETRACTION")
RETRACTION=$(envelope assertion add pred-obj string "retracts" digest "$ORIGINAL_DIGEST" "$RETRACTION")
RETRACTION=$(envelope assertion add pred-obj string "reason" string "Claim was overstated" "$RETRACTION")
RETRACTION=$(envelope subject type wrapped "$RETRACTION")
RETRACTION=$(envelope sign --signer "$ATTESTATION_PRVKEYS" "$RETRACTION")

echo "✅ Created retraction attestation"
echo ""
echo "Retraction structure:"
envelope format "$RETRACTION" | head -10
echo ""

# Verify retraction signature
for i in "${PUBKEY[@]}"
  do
    if envelope verify -v $i $RETRACTION >/dev/null 2>&1; then
      echo "✅ One of the signatures verified"
      l=1
      echo $i
    fi
done

if [ -z $l ]
then
    echo "❌ No matching signature found"
    exit 1
fi

echo ""

echo "$RETRACTION" > "$OUTPUT_DIR/04-claim-retracted-signed.envelope"
envelope format "$RETRACTION" > "$OUTPUT_DIR/04-claim-retracted-signed.format"
echo "✅ attestation Saved to: $OUTPUT_DIR/04-claim-retracted-signed.envelope"

echo "========================================"
echo "All Tutorial §2.1 Tests Passed!"
echo "========================================"
echo ""
echo "Output files saved to: $OUTPUT_DIR/"
ls -la "$OUTPUT_DIR/"
