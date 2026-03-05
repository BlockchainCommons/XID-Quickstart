#!/bin/bash
#
# 01_3_Making_a_XID_Verifiable-SCRIPT.sh - Test all code examples from §1.3
#
# Validates that every command in §1.3: Making a XID Verifiable
# works correctly. Tests dereferenceVia, XID export, signature verification,
# provenance validation, and Ben's verification workflow.
#
# Usage: ./01_3_Making_a_XID_Verifiable-SCRIPT.sh
#
# Dependencies: envelope (bc-envelope-cli-rust), provenance
#
# Exit Codes:
#   0   All tests passed
#   1   Test failure
#

set -e

echo "=== LEARNING XIDS §1.3: Making a XID Verifiable"
echo ""

# Configuration
XID_NAME="BRadvoc8"
PASSWORD="test-password-for-tutorial"
PUBLISH_URL="https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt"

# Create output directory
OUTPUT_DIR="output/test-01-2-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUTPUT_DIR"

echo "Step 1: Load Your XID"
echo "====================="

XID=$(envelope generate keypairs --signing ed25519 | \
    envelope xid new \
    --private encrypt \
    --encrypt-password "$PASSWORD" \
    --nickname "$XID_NAME" \
    --generator encrypt \
    --sign inception)
echo "✅ Loaded XID: $XID_NAME"

if [ $XID ]
then
  echo "✅ Created your XID: $XID_NAME"
else
  echo "❌ Error in XID creation"
  exit 1;
fi
echo ""

echo "$XID" > "$OUTPUT_DIR/01-initial-xid.envelope"
envelope format "$XID" > "$OUTPUT_DIR/01-initial-xid.format"
echo "✅ Saved to: $OUTPUT_DIR/01-initial-xid.envelope"

echo ""
echo "Created XID:"
envelope format "$XID"
echo ""

echo "Step 2: Choose Your Publication URL"
echo "==================================="

echo "Publication URL: $PUBLISH_URL"
echo " "

echo "Step 3: Add dereferenceVia Assertion"
echo "===================================="

XID_WITH_URL=$(envelope xid resolution add \
    "$PUBLISH_URL" \
    --verify inception \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$XID")

echo "✅ Added dereferenceVia: $PUBLISH_URL"
echo "$XID_WITH_URL" > "$OUTPUT_DIR/02-xid-with-url.envelope"
envelope format "$XID_WITH_URL" > "$OUTPUT_DIR/02-xid-with-url.format"

# Verify the assertion was added
if envelope format "$XID_WITH_URL" | grep -q "dereferenceVia"; then
    echo "✅ dereferenceVia assertion found"
else
    echo "❌ ERROR: dereferenceVia assertion not found"
    exit 1
fi
echo ""

echo "Step 4: Export Public View"
echo "=========================="

PUBLIC_XID=$(envelope xid export --private elide --generator elide "$XID_WITH_URL")

echo "✅ Exported public version"
echo "$PUBLIC_XID" > "$OUTPUT_DIR/03-public-xid.envelope"
envelope format "$PUBLIC_XID" > "$OUTPUT_DIR/03-public-xid.format"

# Verify private key is elided, not encrypted
if envelope format "$PUBLIC_XID" | grep -q "ELIDED"; then
    echo "✅ Private key properly elided"
else
    echo "❌ ERROR: Private key not elided"
    exit 1
fi

# Verify signature is still present
if envelope format "$PUBLIC_XID" | grep -q "'signed': Signature"; then
    echo "✅ Signature present"
else
    echo "❌ ERROR: Signature missing"
    exit 1
fi
echo ""

echo "CHANGING TO BEN'S POINT OF VIEW"
echo ""

echo "Step 7: Fetch the XID"
echo "====================="

RECEIVED_URL="https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt"
CURL_URL=`echo $RECEIVED_URL | sed 's/\/\/github.com\//\/\/raw.githubusercontent.com\//; s/\/raw\//\//'`
FETCHED_XID=$(curl -H 'Accept: application/vnd.github.v3.raw' $CURL_URL | head -1)

echo ""
echo "Retrieved XID (not the same as the one you created):"
envelope format $FETCHED_XID
echo ""

echo "Step 8: Recheck the dereferenceVia URL"
echo "======================================"

UNWRAPPED=$(envelope extract wrapped "$FETCHED_XID")
DEREFERENCE_ASSERTION=$(envelope assertion find predicate known dereferenceVia "$UNWRAPPED")
DEREFERENCE_URL=$(envelope extract object "$DEREFERENCE_ASSERTION" | envelope format | sed 's/.*URI(\(.*\))/\1/')

echo "URL Ben fetched from:     $RECEIVED_URL"
echo "dereferenceVia in XID:    $DEREFERENCE_URL"

if [ "$RECEIVED_URL" = "$DEREFERENCE_URL" ]; then
    echo "✅ URLs match - XID claims this is its canonical location"
else
    echo "⚠️  URLs don't match - XID may have been copied from elsewhere"
    exit 1;
fi
echo ""

echo "Step 9: Verify the Signature & Provenance"
echo "========================================="

UNWRAPPED=$(envelope extract wrapped "$FETCHED_XID")
KEY_ASSERTION=$(envelope assertion find predicate known key "$UNWRAPPED")
KEY_OBJECT=$(envelope extract object "$KEY_ASSERTION")
PUBLIC_KEYS=$(envelope extract ur "$KEY_OBJECT")

if envelope verify -v "$PUBLIC_KEYS" "$FETCHED_XID" >/dev/null 2>&1; then
    echo "✅ Signature verified - XID is self-consistent"
else
    echo "❌ Signature FAILED - XID may be tampered\!"
    exit 1
fi

echo ""

PROVENANCE_MARK=$(envelope xid provenance get "$FETCHED_XID")

echo "Checking provenance mark..."
provenance validate "$PROVENANCE_MARK" && echo "✅ Provenance chain intact"

echo ""

echo "========================================"
echo "All Tutorial 02 Tests Passed!"
echo "========================================"
echo ""
echo "Output files saved to: $OUTPUT_DIR/"
ls -la "$OUTPUT_DIR/"
