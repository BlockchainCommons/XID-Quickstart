# Tutorial 09: Binding Agreements

Sign a binding agreement pseudonymously to contribute to open source projects. This is the culmination of your identity journey—from anonymous person to trusted contributor.

**Time to complete**: ~25-30 minutes
**Difficulty**: Intermediate
**Builds on**: Tutorials 01-08

> **Related Concepts**: After completing this tutorial, explore [Progressive Trust](../concepts/progressive-trust.md) and [Herd Privacy](../concepts/herd-privacy.md) to deepen your understanding.

## Prerequisites

- Completed Tutorial 08 (Peer Endorsements)
- The `envelope` CLI tool installed
- Understanding of detached attestations and signatures

## What You'll Learn

- Why CLAs require a different approach than attestations
- How to create **contract-signing keys** with limited permissions
- The structure of a pseudonymous CLA
- **Ben's verification workflow** for accepting contributions
- How **herd privacy** protects pseudonymous contributors

## Building on Tutorial 08

| Tutorial 08 | Tutorial 09 |
|-------------|-------------|
| Others vouch for Amira | Amira makes binding commitments |
| Endorsements (third-party) | Agreements (bilateral) |
| Reputation established | Contribution enabled |

**The Bridge**: In Tutorial 08, Amira received endorsements from Charlene, DevReviewer, and SecurityMaintainer. She now has a verifiable identity, demonstrated skills, and peer validation. But endorsements aren't contributions. To actually contribute to Ben's open source project, Amira needs to sign a Contributor License Agreement—pseudonymously but bindingly.

---

## Part I: Understanding CLAs

### Why CLAs Are Different

A CLA is structurally different from what we've built so far:

| Type | Who Signs | Obligations |
|------|-----------|-------------|
| Self-attestation | You | One-way claim about yourself |
| Peer endorsement | Someone else | One-way claim about you |
| CLA | Both parties | Bilateral—you grant rights, maintainer accepts |

Attestations and endorsements are unilateral statements. A CLA is a contract: Amira offers to grant certain rights, Ben accepts the offer. Both parties have obligations. This bilateral nature requires more careful handling.

> :book: **Contributor License Agreement (CLA)**: A bilateral contract where contributors grant projects license to use their contributions under open source terms. Unlike attestations (one-way claims), CLAs create mutual obligations.

### What a CLA Typically Grants

| Provision | What It Means |
|-----------|---------------|
| Copyright license | Perpetual, worldwide, non-exclusive license to use your contributions |
| Patent license | License to any patented technology in your contributions |
| Authority representation | You have the legal right to grant these licenses |
| Original work representation | Your contributions are original (or properly attributed) |

Amira reads these terms carefully. She understands what she's agreeing to before signing.

---

## Part II: Contract-Signing Keys

### Step 0: Verify Dependencies

Ensure you have the required tools installed:

```
envelope --version

│ bc-envelope-cli 0.32.0
```

If not installed, see Tutorial 01 Step 0 for installation instructions.

### Step 1: Set Up Environment

```
OUTPUT_DIR="output/xid-tutorial09-$(date +%Y%m%d%H%M%S)"
mkdir -p "$OUTPUT_DIR"

# Create Amira's XID with provenance tracking
XID=$(envelope generate keypairs --signing ed25519 | \
    envelope xid new --nickname "BRadvoc8" --generator include --sign inception)

UNWRAPPED_XID=$(envelope extract wrapped "$XID")
XID_ID=$(envelope xid id "$UNWRAPPED_XID")

echo "Amira's XID: $XID_ID"

│ Amira's XID: ur:xid/hdcxhsktlbjzhspyfzhl...
```

### Step 2: Create a Purpose-Specific Contract Key

For signing contracts, Amira creates a key with limited permissions. This follows the principle of least authority: her identity key can do anything, but her contract key can only sign.

```
# Generate contract-signing keys
CONTRACT_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
CONTRACT_PUBKEYS=$(envelope generate pubkeys "$CONTRACT_PRVKEYS")

echo "Contract-signing key created (limited to signing only)"

│ Contract-signing key created (limited to signing only)
```

Why a separate key? If the contract key were somehow compromised, the damage is limited to signatures. An attacker couldn't use it to modify Amira's XID, revoke other keys, or perform identity management operations.

> :book: **Principle of Least Authority**: Grant only the minimum permissions needed for a specific purpose. This limits the blast radius of any compromise—a leaked contract key can't affect identity management.

### Step 3: Register the Contract Key with Purpose

Amira adds the contract key to her XID with explicit purpose limitation:

```
# Add contract key with limited purpose
CONTRACT_KEY_ASSERTION=$(envelope subject type string "ContractSigningKey")
CONTRACT_KEY_ASSERTION=$(envelope assertion add pred-obj string "publicKey" string "$CONTRACT_PUBKEYS" "$CONTRACT_KEY_ASSERTION")
CONTRACT_KEY_ASSERTION=$(envelope assertion add pred-obj string "purpose" string "CLA and legal document signing only" "$CONTRACT_KEY_ASSERTION")
CONTRACT_KEY_ASSERTION=$(envelope assertion add pred-obj string "addedOn" date "2026-01-21T00:00:00Z" "$CONTRACT_KEY_ASSERTION")

echo "Contract key registered with limited purpose"
envelope format "$CONTRACT_KEY_ASSERTION"

│ "ContractSigningKey" [
│     "addedOn": 2026-01-21T00:00:00Z
│     "publicKey": "ur:pubkeys/hdcx..."
│     "purpose": "CLA and legal document signing only"
│ ]
```

Anyone verifying Amira's CLA signature can see that this key was designated specifically for contract signing. The purpose limitation is part of the public record.

> :brain: **Key management patterns**: This purpose-specific key is one example of key hierarchies. For more complex setups with master keys and operational keys, see [Tutorial 10: Multi-Device Identity](10-multi-device-identity.md).

---

## Part III: Signing the CLA

### Step 4: Create the CLA Document

Ben's project uses a standard Individual CLA. Amira creates an envelope containing the agreement terms and her acceptance:

```
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

echo "CLA document created:"
envelope format "$CLA"

│ "Individual Contributor License Agreement" [
│     'isA': "ContributorLicenseAgreement"
│     "contributor": "ur:xid/hdcx..."
│     "contributorNickname": "BRadvoc8"
│     "contributorRepresents": "original work with authority to grant license"
│     "grantsCopyrightLicense": "perpetual, worldwide, non-exclusive, royalty-free"
│     "grantsPatentLicense": "for contributions containing patentable technology"
│     "licenseType": "Apache-2.0"
│     "project": "SecureAuth Library"
│     "projectMaintainer": "Ben (SecurityMaintainer)"
│     "signedOn": 2026-01-21T00:00:00Z
│ ]
```

### Step 5: Sign with Contract Key

Amira signs the CLA with her contract-signing key:

```
CLA_SIGNED=$(envelope sign --signer "$CONTRACT_PRVKEYS" "$CLA")

echo "CLA signed by BRadvoc8:"
envelope format "$CLA_SIGNED"

│ {
│     "Individual Contributor License Agreement" [
│         'isA': "ContributorLicenseAgreement"
│         "contributor": "ur:xid/hdcx..."
│         "contributorNickname": "BRadvoc8"
│         "contributorRepresents": "original work with authority to grant license"
│         "grantsCopyrightLicense": "perpetual, worldwide, non-exclusive, royalty-free"
│         "grantsPatentLicense": "for contributions containing patentable technology"
│         "licenseType": "Apache-2.0"
│         "project": "SecureAuth Library"
│         "projectMaintainer": "Ben (SecurityMaintainer)"
│         "signedOn": 2026-01-21T00:00:00Z
│     ]
│ } [
│     'signed': Signature
│ ]
```

The signed CLA is now a binding commitment from BRadvoc8 to grant the specified licenses for any contributions to the SecureAuth Library project.

---

## Part IV: Ben's Verification Workflow

### Step 6: Ben Receives and Verifies

Ben receives Amira's signed CLA. His verification workflow has several steps:

```
# Ben verifies the signature
echo "Ben's verification workflow:"
echo "============================"

echo "1. Verify signature..."
envelope verify --verifier "$CONTRACT_PUBKEYS" "$CLA_SIGNED"

│ 1. Verify signature...
│ Signature valid
```

### What If Someone Forges a CLA?

What happens if an attacker creates a fake CLA claiming to be from BRadvoc8?

```
# Attacker creates fake CLA
FAKE_CLA=$(envelope subject type string "Individual Contributor License Agreement")
FAKE_CLA=$(envelope assertion add pred-obj string "contributor" string "$XID_ID" "$FAKE_CLA")
FAKE_CLA=$(envelope assertion add pred-obj string "contributorNickname" string "BRadvoc8" "$FAKE_CLA")

# Attacker signs with their own key (not BRadvoc8's contract key)
ATTACKER_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
FAKE_CLA_SIGNED=$(envelope sign --signer "$ATTACKER_PRVKEYS" "$FAKE_CLA")

# Ben tries to verify against BRadvoc8's known contract key
envelope verify --verifier "$CONTRACT_PUBKEYS" "$FAKE_CLA_SIGNED" 2>&1 || true

│ Error: Signature verification failed
```

The forgery fails because the attacker can't produce a valid signature without BRadvoc8's private contract key. Anyone can *claim* to be BRadvoc8 in the CLA metadata, but only the cryptographic signature proves authenticity—and that requires Amira's actual key.

Ben also confirms the contract key is registered in BRadvoc8's XID (checking purpose: "CLA and legal document signing only") and optionally reviews the endorsements from DevReviewer, SecurityMaintainer, and Charlene accumulated in Tutorial 08.

### Step 7: Ben Accepts and Records

Satisfied with the verification, Ben accepts the CLA and records it:

```
# Ben creates his acceptance
ACCEPTANCE=$(envelope subject type string "CLA Acceptance")
ACCEPTANCE=$(envelope assertion add pred-obj string "accepts" string "$(envelope digest "$CLA_SIGNED")" "$ACCEPTANCE")
ACCEPTANCE=$(envelope assertion add pred-obj string "contributor" string "$XID_ID" "$ACCEPTANCE")
ACCEPTANCE=$(envelope assertion add pred-obj string "contributorNickname" string "BRadvoc8" "$ACCEPTANCE")
ACCEPTANCE=$(envelope assertion add pred-obj string "acceptedOn" date "2026-01-21T00:00:00Z" "$ACCEPTANCE")
ACCEPTANCE=$(envelope assertion add pred-obj string "acceptedBy" string "Ben (SecurityMaintainer)" "$ACCEPTANCE")

# Ben signs with his maintainer key
BEN_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
BEN_PUBKEYS=$(envelope generate pubkeys "$BEN_PRVKEYS")

ACCEPTANCE_SIGNED=$(envelope sign --signer "$BEN_PRVKEYS" "$ACCEPTANCE")

echo "4. Record acceptance..."
echo "   CLA accepted and recorded"
envelope format "$ACCEPTANCE_SIGNED"

│ 4. Record acceptance...
│    CLA accepted and recorded
│ {
│     "CLA Acceptance" [
│         "acceptedBy": "Ben (SecurityMaintainer)"
│         "acceptedOn": 2026-01-21T00:00:00Z
│         "accepts": "ur:digest/hdcx..."
│         "contributor": "ur:xid/hdcx..."
│         "contributorNickname": "BRadvoc8"
│     ]
│ } [
│     'signed': Signature
│ ]
```

Ben stores the signed CLA in his project repository alongside his acceptance. Both documents are now part of the project's legal record.

With the CLA accepted, Ben grants BRadvoc8 limited repository access: push to feature branches, but not main. The access is tied to the pseudonymous identity that signed the CLA. Amira submits her first pull request—PR #847: Add constant-time comparison for auth tokens—and it's merged. The journey from anonymous person to trusted contributor is complete.

---

## Part V: Herd Privacy

### Why Multiple Contributors Matter

Amira isn't the only pseudonymous contributor. Ben's project has 50 contributors with signed CLAs: BRadvoc8, CryptoGuardian, SecureDevX, PrivacyFirst99, AuthExpert, and 45 others.

This is herd privacy in action. When a project has many contributors, each pseudonymous signature blends with the others. Observers see 50 pseudonyms. They can't easily determine which one is the human rights worker, which is the student, which is the retiree. The crowd provides cover.

> :book: **Herd Privacy**: Protection gained when many pseudonymous identities operate together, making any individual harder to identify. The larger the herd, the stronger the privacy.

### The Privacy Properties

| Contributors | Observer's Challenge |
|--------------|---------------------|
| 1 | Trivial to identify |
| 10 | Difficult to identify |
| 50 | Needle in haystack |
| 500 | Effectively anonymous |

Amira's contribution to SecureAuth Library is one of many. Her pseudonym blends into the community. Even if someone suspected "a human rights worker contributes to this project," they'd have 50 candidates to investigate.

> :brain: **Learn more**: Herd privacy is a foundational concept in privacy-preserving systems. See [Herd Privacy](../concepts/herd-privacy.md) for the theory and [Progressive Trust](../concepts/progressive-trust.md) for how it relates to trust building.

---

## Part VI: Wrap-Up

### Save Your Work

```
echo "$CLA_SIGNED" > "$OUTPUT_DIR/cla-signed-bradvoc8.envelope"
echo "$ACCEPTANCE_SIGNED" > "$OUTPUT_DIR/cla-acceptance-ben.envelope"
echo "$CONTRACT_PUBKEYS" > "$OUTPUT_DIR/contract-pubkeys.envelope"
echo "$XID" > "$OUTPUT_DIR/BRadvoc8-xid.envelope"

echo "Saved to $OUTPUT_DIR:"
ls "$OUTPUT_DIR"

│ Saved to output/xid-tutorial09-20260121120000:
│ BRadvoc8-xid.envelope
│ cla-acceptance-ben.envelope
│ cla-signed-bradvoc8.envelope
│ contract-pubkeys.envelope
```

### First Arc Complete: Anonymous → Contributor

Through nine tutorials, Amira built complete pseudonymous infrastructure: a self-sovereign identity (T01), made verifiable and fresh (T02), linked to external credentials (T03-04), demonstrated through public and private attestations (T05-07), validated by peer endorsements (T08), and finally enabled for contribution through a signed CLA (T09).

BRadvoc8 can now do advocacy work that sustains her, blending into a community of contributors who all operate pseudonymously.

**This completes the first arc**: from anonymous person to trusted contributor. Amira has everything she needs to participate in open source projects while protecting her real-world identity.

| Arc | Tutorials | Outcome |
|-----|-----------|---------|
| **Identity → Contribution** | T01-T09 | ✅ Can contribute pseudonymously |
| **Security Hardening** | T10-T12 | Protect identity from compromise |
| **Advanced Collaboration** | T13+ | Group communication, clubs |

The remaining tutorials (T10+) cover **advanced security topics**: multi-device key management, offline master keys, and compromise recovery. These are important for long-term identity protection but not required to start contributing.

---

## Appendix: Key Terminology

> **Contract-Signing Key**: A purpose-limited key designated for signing legal documents, following the principle of least authority.
>
> **Bilateral Agreement**: A contract where both parties have obligations, unlike unilateral attestations or endorsements.

See inline `:book:` callouts for definitions of CLA, Principle of Least Authority, and Herd Privacy.

---

## Common Questions

### Q: Is a pseudonymous CLA legally binding?

**A:** Yes, in most jurisdictions. What matters legally is that the signer intended to be bound and had capacity to contract. The signature doesn't need to be a legal name—it needs to be attributable to a specific entity making a commitment. Cryptographic signatures from a persistent pseudonymous identity satisfy this requirement.

### Q: What if my employer owns my contributions?

**A:** The CLA includes a representation that you have authority to grant the license. If your employment agreement assigns your work to your employer, you may need employer approval before contributing. This applies equally to pseudonymous and real-name contributors.

> :warning: **Employment Agreements**: Many tech employment contracts include IP assignment clauses. Review your agreement before contributing—the CLA representation of authority is legally binding.

### Q: Can access be revoked? What if I stop contributing?

**A:** Repository access and the CLA license are separate. Ben can revoke access if you violate project policies, but your existing contributions remain licensed. Conversely, you can stop contributing anytime—the CLA covers past contributions, not future obligations.

### Q: Why not just use a real name?

**A:** For Amira, revealing her real name could endanger her. For others, it might affect employment, invite harassment, or simply be unnecessary. Pseudonymous contribution lets people participate based on the quality of their work, not their real-world identity.

---

## Exercises

1. Create a CLA for a fictional project you maintain, specifying what license terms you'd require
2. Design a key hierarchy with separate keys for: identity management, attestation signing, and contract signing
3. Research how major open source projects (Apache, Linux Foundation) handle CLAs—what terms do they include?

---

## What's Next

**You can start contributing now.** T01-T09 provides everything needed for pseudonymous open source contribution.

**For enhanced security** (recommended for high-value identities):

- **[Tutorial 10: Multi-Device Identity](10-multi-device-identity.md)** — Add operational keys so device compromise doesn't mean identity loss
- **[Tutorial 11: Offline Master Key](11-offline-master-key.md)** — Move your master key offline using SSKR backup
- **[Tutorial 12: Compromise Response](12-compromise-response.md)** — Recover from key compromise while preserving your identity

**For group collaboration**:

- **[Tutorial 13: Gordian Clubs](13-gordian-clubs.md)** — Secure group communication and shared secrets
