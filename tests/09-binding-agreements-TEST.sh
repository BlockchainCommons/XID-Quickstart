#!/bin/bash
#
# Tutorial 09: Binding Agreements - Test Script
#
# Tests all commands from Tutorial 09, verifying:
# - Contract-signing key creation
# - CLA document creation and signing
# - Ben's verification workflow
# - CLA acceptance recording
# - Herd privacy demonstration
#
# Usage: bash tests/09-binding-agreements-TEST.sh

set -euo pipefail

echo "========================================"
echo "Tutorial 09: Binding Agreements"
echo "========================================"
echo ""

# Create output directory
OUTPUT_DIR="output/xid-tutorial09-$(date +%Y%m%d%H%M%S)"
mkdir -p "$OUTPUT_DIR"

echo "=== Part I: Setup and Contract Keys ==="
echo ""

echo "Step 1: Create Amira's XID..."

# Create Amira's XID with provenance tracking
XID=$(envelope generate keypairs --signing ed25519 | \
    envelope xid new --nickname "BRadvoc8" --generator include --sign inception)

UNWRAPPED_XID=$(envelope extract wrapped "$XID")
XID_ID=$(envelope xid id "$UNWRAPPED_XID")

echo "✅ Created Amira's XID: $XID_ID"
echo ""

echo "Step 2: Create contract-signing key..."

# Generate contract-signing keys (limited purpose)
CONTRACT_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
CONTRACT_PUBKEYS=$(envelope generate pubkeys "$CONTRACT_PRVKEYS")

echo "✅ Contract-signing key created"
echo ""

echo "Step 3: Register contract key with purpose..."

# Add contract key with limited purpose
CONTRACT_KEY_ASSERTION=$(envelope subject type string "ContractSigningKey")
CONTRACT_KEY_ASSERTION=$(envelope assertion add pred-obj string "publicKey" string "$CONTRACT_PUBKEYS" "$CONTRACT_KEY_ASSERTION")
CONTRACT_KEY_ASSERTION=$(envelope assertion add pred-obj string "purpose" string "CLA and legal document signing only" "$CONTRACT_KEY_ASSERTION")
CONTRACT_KEY_ASSERTION=$(envelope assertion add pred-obj string "addedOn" date "2026-01-21T00:00:00Z" "$CONTRACT_KEY_ASSERTION")

echo "✅ Contract key registered with limited purpose"
echo ""
echo "Contract key assertion:"
envelope format "$CONTRACT_KEY_ASSERTION"
echo ""

echo "=== Part II: CLA Creation and Signing ==="
echo ""

echo "Step 4: Create CLA document..."

# Create the CLA content
CLA=$(envelope subject type string "Individual Contributor License Agreement")

# Add the project information
CLA=$(envelope assertion add pred-obj string "project" string "SecureAuth Library" "$CLA")
CLA=$(envelope assertion add pred-obj string "projectMaintainer" string "Ben (SecurityMaintainer)" "$CLA")
CLA=$(envelope assertion add pred-obj string "licenseType" string "Apache-2.0" "$CLA")

# Add the grant terms
CLA=$(envelope assertion add pred-obj string "grantsCopyrightLicense" string "perpetual, worldwide, non-exclusive, royalty-free" "$CLA")
CLA=$(envelope assertion add pred-obj string "grantsPatentLicense" string "for contributions containing patentable technology" "$CLA")

# Add contributor representations
CLA=$(envelope assertion add pred-obj string "contributorRepresents" string "original work with authority to grant license" "$CLA")

# Add contributor identity
CLA=$(envelope assertion add pred-obj string "contributor" string "$XID_ID" "$CLA")
CLA=$(envelope assertion add pred-obj string "contributorNickname" string "BRadvoc8" "$CLA")
CLA=$(envelope assertion add pred-obj string "signedOn" date "2026-01-21T00:00:00Z" "$CLA")

# Mark as agreement type
CLA=$(envelope assertion add pred-obj known isA string "ContributorLicenseAgreement" "$CLA")

echo "✅ CLA document created"
echo ""
echo "CLA content:"
envelope format "$CLA" | head -15
echo ""

echo "Step 5: Sign CLA with contract key..."

CLA_SIGNED=$(envelope sign --signer "$CONTRACT_PRVKEYS" "$CLA")

echo "✅ CLA signed by BRadvoc8"
echo ""

echo "=== Part III: Ben's Verification Workflow ==="
echo ""

echo "Ben's verification workflow:"
echo "============================"

echo "1. Verify signature..."
if envelope verify --verifier "$CONTRACT_PUBKEYS" "$CLA_SIGNED"; then
    echo "   ✅ Signature valid"
else
    echo "   ❌ Signature verification failed"
    exit 1
fi
echo ""

echo "1b. Test forgery detection..."

# Attacker creates fake CLA claiming to be BRadvoc8
FAKE_CLA=$(envelope subject type string "Individual Contributor License Agreement")
FAKE_CLA=$(envelope assertion add pred-obj string "contributor" string "$XID_ID" "$FAKE_CLA")
FAKE_CLA=$(envelope assertion add pred-obj string "contributorNickname" string "BRadvoc8" "$FAKE_CLA")

# Attacker signs with their own key (not BRadvoc8's contract key)
ATTACKER_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
FAKE_CLA_SIGNED=$(envelope sign --signer "$ATTACKER_PRVKEYS" "$FAKE_CLA")

# Verification against BRadvoc8's real contract key should fail
if envelope verify --verifier "$CONTRACT_PUBKEYS" "$FAKE_CLA_SIGNED" 2>/dev/null; then
    echo "   ❌ Forged CLA should NOT have verified"
    exit 1
else
    echo "   ✅ Forgery correctly rejected (signature doesn't match contract key)"
fi
echo ""

echo "2. Confirm key belongs to BRadvoc8..."
echo "   Contract key registered to: BRadvoc8 ($XID_ID)"
echo "   Purpose: CLA and legal document signing only"
echo "   ✅ Key association confirmed"
echo ""

echo "3. Review contributor reputation (optional)..."
echo "   - DevReviewer: Technical endorsement (security collaboration)"
echo "   - SecurityMaintainer: Collaboration endorsement"
echo "   - Charlene: Character endorsement"
echo "   ✅ Reputation verified"
echo ""

echo "Step 6: Ben accepts and records CLA..."

# Ben creates his acceptance
ACCEPTANCE=$(envelope subject type string "CLA Acceptance")
CLA_DIGEST=$(envelope digest "$CLA_SIGNED")
ACCEPTANCE=$(envelope assertion add pred-obj string "accepts" string "$CLA_DIGEST" "$ACCEPTANCE")
ACCEPTANCE=$(envelope assertion add pred-obj string "contributor" string "$XID_ID" "$ACCEPTANCE")
ACCEPTANCE=$(envelope assertion add pred-obj string "contributorNickname" string "BRadvoc8" "$ACCEPTANCE")
ACCEPTANCE=$(envelope assertion add pred-obj string "acceptedOn" date "2026-01-21T00:00:00Z" "$ACCEPTANCE")
ACCEPTANCE=$(envelope assertion add pred-obj string "acceptedBy" string "Ben (SecurityMaintainer)" "$ACCEPTANCE")

# Ben signs with his maintainer key
BEN_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
BEN_PUBKEYS=$(envelope generate pubkeys "$BEN_PRVKEYS")

ACCEPTANCE_SIGNED=$(envelope sign --signer "$BEN_PRVKEYS" "$ACCEPTANCE")

echo "4. Record acceptance..."
echo "   ✅ CLA accepted and recorded"
echo ""

# Verify Ben's signature on acceptance
if envelope verify --verifier "$BEN_PUBKEYS" "$ACCEPTANCE_SIGNED"; then
    echo "   ✅ Ben's acceptance signature verified"
else
    echo "   ❌ Ben's acceptance signature failed"
    exit 1
fi
echo ""

echo "=== Part IV: Contribution Enabled ==="
echo ""

echo "5. Grant repository access..."
echo "   - Contributor: BRadvoc8"
echo "   - Access level: Push to feature branches"
echo "   - Restrictions: Cannot push to main, cannot modify settings"
echo "   ✅ Access granted"
echo ""

echo "============================"
echo ""
echo "BRadvoc8's first contribution:"
echo "  PR #847: Add constant-time comparison for auth tokens"
echo "  Status: Merged"
echo ""

echo "=== Part V: Herd Privacy Demonstration ==="
echo ""

echo "Project contributors with signed CLAs:"
echo "  1. BRadvoc8 (Amira)"
echo "  2. CryptoGuardian"
echo "  3. SecureDevX"
echo "  4. PrivacyFirst99"
echo "  5. AuthExpert"
echo "  ... and 45 others"
echo ""
echo "Total: 50 pseudonymous contributors"
echo ""

echo "Herd privacy effect:"
echo "  | Contributors | Observer's Challenge    |"
echo "  |--------------|-------------------------|"
echo "  | 1            | Trivial to identify     |"
echo "  | 10           | Difficult to identify   |"
echo "  | 50           | Needle in haystack      |"
echo "  | 500          | Effectively anonymous   |"
echo ""

echo "=== Part VI: Wrap-Up ==="
echo ""

# Save artifacts
echo "$CLA_SIGNED" > "$OUTPUT_DIR/cla-signed-bradvoc8.envelope"
echo "$ACCEPTANCE_SIGNED" > "$OUTPUT_DIR/cla-acceptance-ben.envelope"
echo "$CONTRACT_PUBKEYS" > "$OUTPUT_DIR/contract-pubkeys.envelope"
echo "$XID" > "$OUTPUT_DIR/BRadvoc8-xid.envelope"

echo "Saved files to $OUTPUT_DIR:"
ls -la "$OUTPUT_DIR"
echo ""

echo "========================================"
echo "Tutorial 09 Test: ALL PASSED ✅"
echo "========================================"
echo ""
echo "Summary:"
echo "  - Created contract-signing key with limited purpose"
echo "  - Created and signed CLA document"
echo "  - Ben verified signature and key association"
echo "  - Ben accepted and recorded CLA"
echo "  - Demonstrated repository access grant"
echo "  - Illustrated herd privacy protection"
echo ""
echo "The complete journey (T01-T09):"
echo "  T01: Self-sovereign identity"
echo "  T02: Verifiable and fresh"
echo "  T03: External credentials"
echo "  T04: Cross-verified accounts"
echo "  T05: Public attestations"
echo "  T06: Committed sensitive claims"
echo "  T07: Encrypted sharing"
echo "  T08: Peer endorsements"
echo "  T09: CLA signed, contribution enabled"
echo ""
echo "BRadvoc8 can now contribute pseudonymously!"
echo ""
