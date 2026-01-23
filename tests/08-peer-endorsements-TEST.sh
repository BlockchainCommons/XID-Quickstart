#!/bin/bash
#
# Tutorial 08: Peer Endorsements - Test Script
#
# Tests all commands from Tutorial 08, verifying:
# - Personal endorsement creation (Charlene)
# - Technical endorsement creation (DevReviewer)
# - Collaboration endorsement creation (SecurityMaintainer)
# - Endorsement verification chain
# - Web of trust concepts
#
# Usage: bash tests/08-peer-endorsements-TEST.sh

set -euo pipefail

echo "========================================"
echo "Tutorial 08: Peer Endorsements"
echo "========================================"
echo ""

# Create output directory
OUTPUT_DIR="output/xid-tutorial08-$(date +%Y%m%d%H%M%S)"
mkdir -p "$OUTPUT_DIR"

echo "=== Part I: Personal Endorsement from Charlene ==="
echo ""

echo "Step 1: Set up environment..."

# Create Amira's XID using the piped keypairs pattern (with provenance for later update)
XID=$(envelope generate keypairs --signing ed25519 | \
    envelope xid new --nickname "BRadvoc8" --generator include --sign inception)

UNWRAPPED_XID=$(envelope extract wrapped "$XID")
XID_ID=$(envelope xid id "$UNWRAPPED_XID")

echo "✅ Created Amira's XID: $XID_ID"
echo ""

echo "Step 2: Create Charlene's identity..."

CHARLENE_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
CHARLENE_PUBKEYS=$(envelope generate pubkeys "$CHARLENE_PRVKEYS")

CHARLENE_XID=$(envelope xid new --nickname "Charlene" "$CHARLENE_PUBKEYS")
CHARLENE_XID_ID=$(envelope xid id "$CHARLENE_XID")

echo "✅ Created Charlene's XID: $CHARLENE_XID_ID"
echo ""

echo "Step 3: Charlene creates her endorsement..."

# Create the endorsement subject
ENDORSEMENT=$(envelope subject type string "BRadvoc8 is a thoughtful and committed contributor to privacy work that protects vulnerable communities")

# Add endorsement metadata
ENDORSEMENT=$(envelope assertion add pred-obj known isA string "PeerEndorsement" "$ENDORSEMENT")
ENDORSEMENT=$(envelope assertion add pred-obj string "endorsedBy" string "Charlene" "$ENDORSEMENT")
ENDORSEMENT=$(envelope assertion add pred-obj string "endorsedOn" date "2026-01-21T00:00:00Z" "$ENDORSEMENT")
ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementTarget" string "$XID_ID" "$ENDORSEMENT")

# Add relationship context
ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementContext" string "Personal friend, observed values and commitment over 2+ years" "$ENDORSEMENT")
ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementScope" string "Character and values alignment, not technical skills" "$ENDORSEMENT")
ENDORSEMENT=$(envelope assertion add pred-obj string "relationshipBasis" string "Friend who introduced BRadvoc8 to RISK network concept" "$ENDORSEMENT")

# Charlene signs with her private key
CHARLENE_ENDORSEMENT=$(envelope sign --signer "$CHARLENE_PRVKEYS" "$ENDORSEMENT")

echo "$CHARLENE_ENDORSEMENT" > "$OUTPUT_DIR/endorsement-charlene.envelope"
echo "✅ Created Charlene's character endorsement"
envelope format "$CHARLENE_ENDORSEMENT" | head -12
echo ""

echo "Step 4: Verify Charlene's endorsement..."

if envelope verify --verifier "$CHARLENE_PUBKEYS" "$CHARLENE_ENDORSEMENT"; then
    echo "✅ Charlene's endorsement verified"
else
    echo "❌ Charlene's endorsement verification failed"
    exit 1
fi
echo ""

echo "=== Part II: Technical Endorsements ==="
echo ""

echo "Step 5: Create DevReviewer's endorsement..."

REVIEWER_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
REVIEWER_PUBKEYS=$(envelope generate pubkeys "$REVIEWER_PRVKEYS")
REVIEWER_XID=$(envelope xid new --nickname "DevReviewer" "$REVIEWER_PUBKEYS")
REVIEWER_XID_ID=$(envelope xid id "$REVIEWER_XID")

# Create technical endorsement
TECH_ENDORSEMENT=$(envelope subject type string "BRadvoc8 writes secure, well-tested code with clear attention to privacy-preserving patterns")

TECH_ENDORSEMENT=$(envelope assertion add pred-obj known isA string "PeerEndorsement" "$TECH_ENDORSEMENT")
TECH_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsedBy" string "DevReviewer" "$TECH_ENDORSEMENT")
TECH_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsedOn" date "2026-01-21T00:00:00Z" "$TECH_ENDORSEMENT")
TECH_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementTarget" string "$XID_ID" "$TECH_ENDORSEMENT")

# Technical context (DevReviewer relationship from T06-T07)
TECH_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementContext" string "Verified crypto audit experience, reviewed CivilTrust authentication design" "$TECH_ENDORSEMENT")
TECH_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementScope" string "Security architecture, cryptographic implementation, privacy patterns" "$TECH_ENDORSEMENT")
TECH_ENDORSEMENT=$(envelope assertion add pred-obj string "relationshipBasis" string "Security collaboration partner who verified credentials through commit-reveal and encrypted sharing" "$TECH_ENDORSEMENT")

# Sign
TECH_ENDORSEMENT_SIGNED=$(envelope sign --signer "$REVIEWER_PRVKEYS" "$TECH_ENDORSEMENT")

echo "$TECH_ENDORSEMENT_SIGNED" > "$OUTPUT_DIR/endorsement-devreviewer.envelope"
echo "✅ Created DevReviewer's technical endorsement"
echo ""

echo "Step 6: Create SecurityMaintainer's endorsement..."

MAINTAINER_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
MAINTAINER_PUBKEYS=$(envelope generate pubkeys "$MAINTAINER_PRVKEYS")
MAINTAINER_XID=$(envelope xid new --nickname "SecurityMaintainer" "$MAINTAINER_PUBKEYS")
MAINTAINER_XID_ID=$(envelope xid id "$MAINTAINER_XID")

# Create collaboration endorsement
COLLAB_ENDORSEMENT=$(envelope subject type string "BRadvoc8 is a reliable contributor who delivers high-quality security enhancements and responds constructively to feedback")

COLLAB_ENDORSEMENT=$(envelope assertion add pred-obj known isA string "PeerEndorsement" "$COLLAB_ENDORSEMENT")
COLLAB_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsedBy" string "SecurityMaintainer" "$COLLAB_ENDORSEMENT")
COLLAB_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsedOn" date "2026-01-21T00:00:00Z" "$COLLAB_ENDORSEMENT")
COLLAB_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementTarget" string "$XID_ID" "$COLLAB_ENDORSEMENT")

# Collaboration context
COLLAB_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementContext" string "Collaborated on 3 security features over 6 months" "$COLLAB_ENDORSEMENT")
COLLAB_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementScope" string "Technical skills, collaboration quality, communication" "$COLLAB_ENDORSEMENT")
COLLAB_ENDORSEMENT=$(envelope assertion add pred-obj string "relationshipBasis" string "Project maintainer who merged BRadvoc8's contributions" "$COLLAB_ENDORSEMENT")

# Sign
COLLAB_ENDORSEMENT_SIGNED=$(envelope sign --signer "$MAINTAINER_PRVKEYS" "$COLLAB_ENDORSEMENT")

echo "$COLLAB_ENDORSEMENT_SIGNED" > "$OUTPUT_DIR/endorsement-maintainer.envelope"
echo "✅ Created SecurityMaintainer's collaboration endorsement"
echo ""

echo "=== Part III: Verify Endorsement Chain ==="
echo ""

echo "Verifying all endorsements:"
echo "============================"

echo "1. Charlene (character):"
if envelope verify --verifier "$CHARLENE_PUBKEYS" "$CHARLENE_ENDORSEMENT"; then
    echo "   ✅ Signature valid"
else
    echo "   ❌ Verification failed"
    exit 1
fi

echo "2. DevReviewer (technical):"
if envelope verify --verifier "$REVIEWER_PUBKEYS" "$TECH_ENDORSEMENT_SIGNED"; then
    echo "   ✅ Signature valid"
else
    echo "   ❌ Verification failed"
    exit 1
fi

echo "3. SecurityMaintainer (collaboration):"
if envelope verify --verifier "$MAINTAINER_PUBKEYS" "$COLLAB_ENDORSEMENT_SIGNED"; then
    echo "   ✅ Signature valid"
else
    echo "   ❌ Verification failed"
    exit 1
fi

echo "============================"
echo "✅ All endorsements verified"
echo ""

echo "Step 7b: Test forgery detection..."

# Attacker creates fake endorsement claiming to be from Charlene
FAKE_ENDORSEMENT=$(envelope subject type string "BRadvoc8 is amazing at everything")
FAKE_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsedBy" string "Charlene" "$FAKE_ENDORSEMENT")

# Attacker signs with their own key (not Charlene's)
ATTACKER_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
FAKE_SIGNED=$(envelope sign --signer "$ATTACKER_PRVKEYS" "$FAKE_ENDORSEMENT")

# Verification against Charlene's real public key should fail
if envelope verify --verifier "$CHARLENE_PUBKEYS" "$FAKE_SIGNED" 2>/dev/null; then
    echo "❌ Forgery should NOT have verified"
    exit 1
else
    echo "✅ Forgery correctly rejected (signature doesn't match Charlene's key)"
fi
echo ""

echo "Step 7c: Test elided endorsement with inclusion proof..."

# Charlene fully elides endorsement before publishing (just shows ELIDED)
ENDORSEMENT_DIGEST=$(envelope digest "$CHARLENE_ENDORSEMENT")
ELIDED_ENDORSEMENT=$(envelope elide removing "$ENDORSEMENT_DIGEST" "$CHARLENE_ENDORSEMENT")

# Verify full and elided have same digest (inclusion proof)
FULL_DIGEST=$(envelope digest "$CHARLENE_ENDORSEMENT")
ELIDED_DIGEST=$(envelope digest "$ELIDED_ENDORSEMENT")

if [ "$FULL_DIGEST" = "$ELIDED_DIGEST" ]; then
    echo "✅ Inclusion proof: full endorsement matches elided digest"
else
    echo "❌ Digests should match for inclusion proof"
    exit 1
fi

# Verify signature on FULL version (not elided - elided has no content to verify)
if envelope verify --verifier "$CHARLENE_PUBKEYS" "$CHARLENE_ENDORSEMENT"; then
    echo "✅ Signature verifies on full endorsement"
else
    echo "❌ Signature should verify on full endorsement"
    exit 1
fi
echo ""

echo "=== Part IV: Web of Trust Summary ==="
echo ""

echo "Endorsement diversity:"
echo "  | Endorser           | Type          | Relationship               |"
echo "  |--------------------|---------------|----------------------------|"
echo "  | Charlene           | Character     | Friend (2+ years)          |"
echo "  | DevReviewer        | Technical     | Security collab (T06-T07)  |"
echo "  | SecurityMaintainer | Collaboration | Maintainer (6 months)      |"
echo ""

echo "Trust multiplication:"
echo "  1 endorsement         = Weak (could be a favor)"
echo "  3 independent         = Moderate (pattern)"
echo "  3 different contexts  = Strong (triangulated)"
echo ""

echo "=== Part VI: Updating Attestations After Endorsement ==="
echo ""

echo "Step 8: Upgrade attestation with endorsement reference..."

# Create upgraded attestation referencing the SecurityMaintainer endorsement
UPGRADED_CLAIM=$(envelope subject type string "I delivered security enhancements (endorsed by SecurityMaintainer, Jan 2026)")
UPGRADED_ATTESTATION=$(envelope assertion add pred-obj known isA string "SelfAttestation" "$UPGRADED_CLAIM")
UPGRADED_ATTESTATION=$(envelope assertion add pred-obj string "attestedBy" string "BRadvoc8" "$UPGRADED_ATTESTATION")
UPGRADED_ATTESTATION=$(envelope assertion add pred-obj string "attestedOn" date "2026-01-21T00:00:00Z" "$UPGRADED_ATTESTATION")
UPGRADED_ATTESTATION=$(envelope assertion add pred-obj string "validatedBy" string "$MAINTAINER_XID_ID" "$UPGRADED_ATTESTATION")

# Sign with Amira's keys (need to extract from XID or use generated keys)
AMIRA_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
UPGRADED_ATTESTATION=$(envelope sign --signer "$AMIRA_PRVKEYS" "$UPGRADED_ATTESTATION")

echo "$UPGRADED_ATTESTATION" > "$OUTPUT_DIR/attestation-upgraded.envelope"
echo "✅ Created upgraded attestation with endorsement reference"
echo ""

echo "Step 9: Advance provenance..."

# Advance provenance to signal updated profile
UPDATED_XID=$(envelope xid provenance next "$UNWRAPPED_XID")
echo "✅ Provenance advanced to signal updated profile"
echo ""

echo "=== Part VII: Wrap-Up ==="
echo ""

# Save Amira's XID (private keys embedded, encrypted if using --private encrypt)
echo "$XID" > "$OUTPUT_DIR/BRadvoc8-xid.envelope"

# Save endorser XIDs
echo "$CHARLENE_XID" > "$OUTPUT_DIR/charlene-xid.envelope"
echo "$REVIEWER_XID" > "$OUTPUT_DIR/devreviewer-xid.envelope"
echo "$MAINTAINER_XID" > "$OUTPUT_DIR/maintainer-xid.envelope"

echo "Saved files to $OUTPUT_DIR:"
ls -la "$OUTPUT_DIR"
echo ""

echo "========================================"
echo "Tutorial 08 Test: ALL PASSED ✅"
echo "========================================"
echo ""
echo "Summary:"
echo "  - Created 3 endorsers with their own XIDs"
echo "  - Created 3 endorsements (character, technical, collaboration)"
echo "  - Verified all endorsement signatures"
echo "  - Detected forged endorsement (wrong key)"
echo "  - Demonstrated elided endorsement with inclusion proof"
echo "  - Demonstrated web of trust concepts"
echo "  - Upgraded attestation with endorsement reference"
echo "  - Advanced provenance after changes"
echo ""
