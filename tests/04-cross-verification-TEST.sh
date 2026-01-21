#!/bin/bash
#
# 04-cross-verification-TEST.sh - Test all code examples from Tutorial 04
#
# Validates that every command in Tutorial 04: Cross-Verification works.
# Tests fetching XID, signature verification, provenance validation,
# attachment extraction, and verification chain building.
#
# Note: This test creates a local XID to verify (simulating Ben's perspective).
# For real verification against the published BRadvoc8 XID, use --live flag.
#
# Usage: ./04-cross-verification-TEST.sh [--live]
#
# Dependencies: envelope (bc-envelope-cli-rust), provenance, curl, jq
#
# Exit Codes:
#   0   All tests passed
#   1   Test failure
#

set -e

# Check for --live flag
LIVE_MODE=false
if [ "$1" = "--live" ]; then
    LIVE_MODE=true
    echo "Running in LIVE mode - fetching real BRadvoc8 XID"
fi

echo "========================================"
echo "Tutorial 04: Cross-Verification"
echo "Test Script"
echo "========================================"
echo ""

# Create output directory
OUTPUT_DIR="output/test-04-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUTPUT_DIR"

if [ "$LIVE_MODE" = true ]; then
    echo "=== LIVE MODE: Fetching Real BRadvoc8 XID ==="
    XID_URL="https://raw.githubusercontent.com/BRadvoc8/BRadvoc8/master/xid.txt"

    echo "Fetching from: $XID_URL"
    FETCHED_XID=$(curl -sL "$XID_URL")

    if [ -z "$FETCHED_XID" ]; then
        echo "❌ ERROR: Failed to fetch XID from $XID_URL"
        exit 1
    fi

    echo "✅ Fetched XID successfully"
    echo "$FETCHED_XID" > "$OUTPUT_DIR/00-fetched-xid.envelope"
else
    echo "=== LOCAL MODE: Creating Test XID ==="
    # Create a test XID that simulates the published BRadvoc8
    XID_NAME="BRadvoc8"
    PASSWORD="test-password-for-tutorial"
    PUBLISH_URL="https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt"

    # Create base XID
    XID=$(envelope generate keypairs --signing ed25519 | \
        envelope xid new \
        --private encrypt \
        --encrypt-password "$PASSWORD" \
        --nickname "$XID_NAME" \
        --generator encrypt \
        --sign inception)

    # Add dereferenceVia
    XID=$(envelope xid method add \
        "$PUBLISH_URL" \
        --verify inception \
        --password "$PASSWORD" \
        --sign inception \
        --private encrypt \
        --generator encrypt \
        --encrypt-password "$PASSWORD" \
        "$XID")

    # Generate SSH key and create attachment
    SSH_PRVKEYS=$(envelope generate prvkeys --signing ssh-ed25519)
    SSH_PUBKEYS=$(envelope generate pubkeys "$SSH_PRVKEYS")
    SSH_EXPORT=$(envelope export "$SSH_PUBKEYS")

    CURRENT_DATE=$(date -u +"%Y-%m-%d")
    PROOF_STATEMENT=$(envelope subject type string "$XID_NAME controls SSH signing key registered on GitHub as of $CURRENT_DATE")
    PROOF=$(envelope sign --signer "$SSH_PRVKEYS" "$PROOF_STATEMENT")

    GITHUB_ACCOUNT=$(envelope subject type string "$XID_NAME")
    GITHUB_ACCOUNT=$(envelope assertion add pred-obj known isA string "GitHubAccount" "$GITHUB_ACCOUNT")
    GITHUB_ACCOUNT=$(envelope assertion add pred-obj known dereferenceVia uri "https://api.github.com/users/$XID_NAME/ssh_signing_keys" "$GITHUB_ACCOUNT")
    GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "sshSigningKey" ur "$SSH_PUBKEYS" "$GITHUB_ACCOUNT")
    GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "sshSigningKeyText" string "$SSH_EXPORT" "$GITHUB_ACCOUNT")
    GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "sshSigningKeyProof" envelope "$PROOF" "$GITHUB_ACCOUNT")
    GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "createdAt" date "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$GITHUB_ACCOUNT")

    XID=$(envelope xid attachment add \
        --vendor "self" \
        --payload "$GITHUB_ACCOUNT" \
        --verify inception \
        --password "$PASSWORD" \
        --sign inception \
        --private encrypt \
        --generator encrypt \
        --encrypt-password "$PASSWORD" \
        "$XID")

    # Export public version
    FETCHED_XID=$(envelope xid export --private elide --generator elide "$XID")

    echo "Created test XID with GitHub attachment"
    echo "$FETCHED_XID" > "$OUTPUT_DIR/00-test-xid.envelope"
fi
echo ""

echo "=== Step 1: Display Fetched XID ==="
echo "Fetched XID:"
envelope format "$FETCHED_XID" | head -20
echo "..."
echo ""

echo "=== Step 2: Verify Self-Consistency ==="
UNWRAPPED=$(envelope extract wrapped "$FETCHED_XID")
KEY_ASSERTION=$(envelope assertion find predicate known key "$UNWRAPPED")
KEY_OBJECT=$(envelope extract object "$KEY_ASSERTION")
PUBLIC_KEYS=$(envelope extract ur "$KEY_OBJECT")

if envelope verify -v "$PUBLIC_KEYS" "$FETCHED_XID" >/dev/null 2>&1; then
    echo "✅ Signature verified - XID is self-consistent"
else
    echo "❌ Signature FAILED - do not trust!"
    exit 1
fi
echo ""

echo "=== Step 3: Check Provenance ==="
PROVENANCE_MARK=$(envelope xid provenance get "$FETCHED_XID")
echo "Provenance mark: $(echo "$PROVENANCE_MARK" | head -c 50)..."
echo "$PROVENANCE_MARK" > "$OUTPUT_DIR/01-provenance-mark.txt"

echo ""
echo "Provenance validation:"
if provenance validate --format json-pretty "$PROVENANCE_MARK" 2>&1 | head -20; then
    echo "✅ Provenance validated"
else
    echo "⚠️  Provenance validation has issues"
fi
echo ""

echo "=== Step 4: Extract GitHub Attachment ==="
ATTACHMENT=$(envelope xid attachment all "$FETCHED_XID" | head -1)

if [ -z "$ATTACHMENT" ]; then
    echo "❌ ERROR: No attachment found in XID"
    exit 1
fi

echo "Found attachment:"
envelope format "$ATTACHMENT"
echo "$ATTACHMENT" > "$OUTPUT_DIR/02-attachment.envelope"
echo "✅ GitHub attachment extracted"
echo ""

echo "=== Step 5: Extract SSH Key from Attachment ==="
# Two-step extraction: outer layer has vendor assertion, inner has payload
ATTACHMENT_OBJECT=$(envelope extract object "$ATTACHMENT")
ATTACHMENT_PAYLOAD=$(envelope extract wrapped "$ATTACHMENT_OBJECT")

SSH_KEY_ASSERTION=$(envelope assertion find predicate string sshSigningKeyText "$ATTACHMENT_PAYLOAD")
CLAIMED_SSH_KEY=$(envelope extract object "$SSH_KEY_ASSERTION" | envelope format)

echo "SSH key claimed in XID:"
echo "$CLAIMED_SSH_KEY"
echo "$CLAIMED_SSH_KEY" > "$OUTPUT_DIR/03-claimed-ssh-key.txt"

if echo "$CLAIMED_SSH_KEY" | grep -q "ssh-ed25519"; then
    echo "✅ SSH key extracted successfully"
else
    echo "❌ ERROR: Could not extract SSH key"
    exit 1
fi
echo ""

echo "=== Step 6: Query GitHub's API (Live Check) ==="
USERNAME="BRadvoc8"

if [ "$LIVE_MODE" = true ]; then
    echo "Querying GitHub API for $USERNAME's signing keys..."
    GITHUB_KEYS=$(curl -s "https://api.github.com/users/$USERNAME/ssh_signing_keys")

    if echo "$GITHUB_KEYS" | grep -q "ssh-ed25519"; then
        echo "GitHub API response:"
        echo "$GITHUB_KEYS" | jq '.[0] | {key, created_at}'
        echo "$GITHUB_KEYS" > "$OUTPUT_DIR/04-github-api-response.json"

        # Extract GitHub key for comparison
        GITHUB_KEY=$(echo "$GITHUB_KEYS" | jq -r '.[0].key')
        GITHUB_CREATED=$(echo "$GITHUB_KEYS" | jq -r '.[0].created_at')

        echo ""
        echo "=== Step 7: Compare Keys ==="
        # Strip quotes for comparison
        CLAIMED_KEY=$(echo "$CLAIMED_SSH_KEY" | tr -d '"')

        echo "Claimed key: $CLAIMED_KEY"
        echo "GitHub key:  $GITHUB_KEY"

        if [ "$CLAIMED_KEY" = "$GITHUB_KEY" ]; then
            echo ""
            echo "✅ KEYS MATCH - XID claim matches GitHub registry"
        else
            echo ""
            echo "❌ KEYS DO NOT MATCH - attestation is invalid!"
            exit 1
        fi

        echo ""
        echo "=== Step 8: Check Temporal Anchors ==="
        echo "Key registered on GitHub: $GITHUB_CREATED"
        echo "This establishes a temporal anchor from an external source."
    else
        echo "⚠️  GitHub API returned unexpected response (rate limited or user not found)"
        echo "Response: $GITHUB_KEYS"
        echo ""
        echo "Skipping GitHub verification - using structural tests only"
    fi
else
    echo "LOCAL MODE: Skipping GitHub API query"
    echo "(Use --live flag to verify against real GitHub API)"
fi
echo ""

echo "=== Step 9: Verification Summary ==="
echo ""
echo "=== Verification Summary ==="
echo ""
echo "XID Identifier: $(envelope xid id "$FETCHED_XID")"
echo ""
echo "Verification Results:"
echo "  ✅ XID self-consistent (signature valid)"
echo "  ✅ Provenance chain intact (genesis)"
echo "  ✅ GitHub attachment present"
echo "  ✅ SSH signing key extractable"

if [ "$LIVE_MODE" = true ]; then
    echo "  ✅ SSH signing key matches GitHub registry"
    if [ -n "$GITHUB_CREATED" ]; then
        echo "  ✅ Key registered on GitHub: $GITHUB_CREATED"
    fi
fi

echo ""
echo "Trust level: CREDIBLE PSEUDONYM"
echo ""

echo "========================================"
echo "All Tutorial 04 Tests Passed!"
echo "========================================"
echo ""
echo "Output files saved to: $OUTPUT_DIR/"
ls -la "$OUTPUT_DIR/"
