# Tutorial 03: Self Attestations

Build credibility through specific, factual claims that invite verification rather than demand belief.

**Time to complete**: ~15-20 minutes
**Difficulty**: Intermediate
**Builds on**: Tutorials 01-04

> **Related Concepts**: After completing this tutorial, explore [Progressive Trust](../concepts/progressive-trust.md) and [Self-Attestation](../concepts/self-attestation.md) to deepen your understanding.

## Prerequisites

- Completed Tutorial 04 (Cross-Verification)
- The `envelope` CLI tool installed
- Your XID artifacts from previous tutorials

## What You'll Learn

- The **fair witness methodology** for making credible claims
- The difference between **detached** and **embedded** attestations
- How to register **attestation keys** in your XID for signature verification
- How to create attestations that are **publicly verifiable**

## Building on Tutorial 04

| Tutorial 04 | Tutorial 05 |
|-------------|-------------|
| Cross-verified GitHub account | Make broader capability claims |
| Proved control of external accounts | Create signed attestations |
| Ben verified account connections | Ben can verify skill claims |

**The Bridge**: Ben verified your GitHub account connection. But controlling an account doesn't prove competence. Now you'll claim what you can actually do.

---

## The Problem: Claims Without Proof

After Tutorial 04, Ben knows BRadvoc8 is a real identity connected to a GitHub account. What he doesn't know is whether BRadvoc8 can write good code, understand security, or deliver quality work. Amira needs to make claims about her capabilities—but vague claims like "Security expert. 8 years experience." are worthless. Anyone can type them.

Amira needs a different approach: specific claims that point to verifiable evidence.

---

## Part I: About Fair Witness Attestations

*This section explains the concepts behind attestations. If you're ready to start creating one, skip to [Part II](#part-ii-creating-a-detached-attestation).*

> :book: **Fair Witness Methodology**: State only what you can personally verify—specific, factual claims that point to observable evidence rather than opinions or vague assertions.

Compare these two claims:

| Claim | Type | Why |
|-------|------|-----|
| "I'm good at security" | Weak | Opinion, nothing to check |
| "I contributed to Galaxy Project (PR #12847)" | Strong | Verifiable on GitHub |

The strong claim invites validation rather than demanding belief. For pseudonymous contributors who can't flash a diploma, evidence-backed claims ARE your credentials.

> :book: **Detached Attestation**: A signed statement that exists as a separate envelope, referencing your XID but not embedded in your XIDDoc.

**Why detached?** Skill claims work better as separate documents. You can share specific attestations with specific people, revoke them independently, and keep your XIDDoc lean. The attestation references your XID identifier, so verifiers can confirm it came from you.

> :brain: **Learn more**: The [Self-Attestation](../concepts/self-attestation.md) concept doc explains the relationship between self-claims and endorsements.

---

## Part II: Creating a Detached Attestation

Amira contributed to Galaxy Project, an open source bioinformatics platform. Her pull request added mass spectrometry visualization features. This is the kind of specific, verifiable claim that builds real credibility.

### Step 0: Verify Dependencies

Ensure you have the required tools installed:

```
envelope --version
provenance --version

│ bc-envelope-cli 0.32.0
│ provenance-mark-cli 0.6.0
```

If not installed, see Tutorial 01 Step 0 for installation instructions.

### Step 1: Set Up Environment

```
OUTPUT_DIR="output/xid-tutorial05-$(date +%Y%m%d%H%M%S)"
mkdir -p "$OUTPUT_DIR"

# Create a fresh XID with provenance tracking
XID=$(envelope generate keypairs --signing ed25519 | \
    envelope xid new --nickname "BRadvoc8" --generator include --sign inception)

UNWRAPPED_XID=$(envelope extract wrapped "$XID")
XID_ID=$(envelope xid id "$UNWRAPPED_XID")

# Generate separate attestation signing keys
# Best practice: use dedicated keys for attestations, not your XID inception key
ATTESTATION_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
ATTESTATION_PUBKEYS=$(envelope generate pubkeys "$ATTESTATION_PRVKEYS")

echo "Created XID: $XID_ID"

│ Created XID: c7e764b7
```

Why separate attestation keys? Your XID inception key is powerful: it can modify your identity. Using it for routine signing increases exposure risk. Attestation keys can be rotated or revoked without affecting your core identity.

> :warning: **Key Separation**: Never use your XID inception key for routine operations. If an attestation key is compromised, you revoke and replace it. If your inception key is compromised, your entire identity is at risk.

> :book: **Attestation Key**: A dedicated signing key for detached attestations, registered in your XID. Ben verifies attestation signatures by checking if the signing key is in BRadvoc8's XIDDoc (see Appendix for key type comparison).

### Step 2: Register Attestation Key in XID

For Ben to verify attestations came from BRadvoc8, the attestation public key must be in the XID. We also embed the private key (encrypted) so Amira can sign attestations without managing separate key files:

```
# Add attestation keypair to XID (private key encrypted like inception key)
PASSWORD="your-password-from-previous-tutorials"

XID=$(envelope xid key add \
    --nickname "attestation-key" \
    --allow sign \
    --private encrypt \
    --encrypt-password "$PASSWORD" \
    "$ATTESTATION_PRVKEYS" \
    "$XID")

echo "Added attestation key to XID"
envelope format "$XID" | grep -A4 "attestation-key"

│ Added attestation key to XID
│             'nickname': "attestation-key"
│             'allow': 'Sign'
│             'privateKey': ENCRYPTED
```

The CLI derives the public key from the private key automatically. The `--private encrypt` embeds the private key encrypted with your password. The `--allow sign` permission indicates this key can only sign—it cannot modify the XID itself (that requires the inception key).

Now advance provenance to record this change:

```
# Advance provenance to record the key addition
XID=$(envelope xid provenance next "$XID")

echo "Provenance advanced"
PROV_MARK=$(envelope xid provenance get "$XID")
provenance validate --format json-compact "$PROV_MARK" 2>&1 | grep -o '"end_seq":[0-9]*'

│ Provenance advanced
│ "end_seq":1
```

The XID is now at sequence 1: genesis (seq 0) created the identity, this update (seq 1) added the attestation key. Ben can fetch the XID and find the attestation public key to verify signatures.

Export the public version for publication:

```
# Export public XID (elide private keys and generator)
PUBLIC_XID=$(envelope xid export --private elide --generator elide "$XID")

echo "Public XID ready for publication"
envelope format "$PUBLIC_XID" | grep -A1 "attestation-key"

│ Public XID ready for publication
│             'nickname': "attestation-key"
│             'allow': 'Sign'
```

Amira would publish this updated XID at her `dereferenceVia` URL so Ben can fetch it and verify her attestation signatures.

### Step 3: Create the Claim

Start with the claim itself as the envelope subject:

```
CLAIM=$(envelope subject type string \
  "I contributed mass spec visualization code to galaxyproject/galaxy (PR #12847, merged 2024)")

envelope format "$CLAIM"

│ "I contributed mass spec visualization code to galaxyproject/galaxy (PR #12847, merged 2024)"
```

This is just a string. It's not signed, not attributed, not structured. Anyone could create this string.

### Step 4: Add Attestation Metadata

Now add metadata that structures this as a formal attestation:

```
ATTESTATION=$(envelope assertion add pred-obj known isA string "SelfAttestation" "$CLAIM")
ATTESTATION=$(envelope assertion add pred-obj string "attestedBy" string "$XID_ID" "$ATTESTATION")
ATTESTATION=$(envelope assertion add pred-obj string "attestedOn" date "2026-01-21T00:00:00Z" "$ATTESTATION")
ATTESTATION=$(envelope assertion add pred-obj string "verifiableAt" string "https://github.com/galaxyproject/galaxy/pull/12847" "$ATTESTATION")

envelope format "$ATTESTATION"

│ "I contributed mass spec visualization code to galaxyproject/galaxy (PR #12847, merged 2024)" [
│     isA: "SelfAttestation"
│     "attestedBy": "c7e764b7"
│     "attestedOn": 2026-01-21T00:00:00Z
│     "verifiableAt": "https://github.com/galaxyproject/galaxy/pull/12847"
│ ]
```

Each assertion adds a specific piece of metadata:

| Assertion | Predicate | Value | Purpose |
|-----------|-----------|-------|---------|
| 1 | `isA` (known) | `"SelfAttestation"` | Declares this is a self-claim, not an endorsement |
| 2 | `"attestedBy"` | XID identifier | Links claim to your identity |
| 3 | `"attestedOn"` | ISO date | Records when you made the claim |
| 4 | `"verifiableAt"` | URL | Points to evidence for independent verification |

The `isA` assertion marks this as a self-attestation (you claiming something about yourself, as opposed to someone else vouching for you). The `attestedBy` field links to your XID identifier so verifiers know who made the claim. The `attestedOn` timestamp records when you made it. And `verifiableAt` points to the actual evidence: the GitHub PR where anyone can check the code.

> :book: **Self-Attestation**: A claim you make about yourself. Contrast with an *endorsement*, where someone else vouches for you. Self-attestations are starting points; endorsements carry more weight because they come from independent parties.

### Step 5: Sign the Attestation

The attestation is structured but not yet bound to your identity. Anyone could have created it. The signature proves YOU made this claim:

```
ATTESTATION_SIGNED=$(envelope sign --signer "$ATTESTATION_PRVKEYS" "$ATTESTATION")

envelope format "$ATTESTATION_SIGNED"

│ {
│     "I contributed mass spec visualization code to galaxyproject/galaxy (PR #12847, merged 2024)" [
│         isA: "SelfAttestation"
│         "attestedBy": "c7e764b7"
│         "attestedOn": 2026-01-21T00:00:00Z
│         "verifiableAt": "https://github.com/galaxyproject/galaxy/pull/12847"
│     ]
│ } [
│     'signed': Signature
│ ]
```

The signature wraps the entire attestation. If anyone modifies any part (the claim, the date, the URL), the signature becomes invalid.

### Step 6: Verify the Attestation

```
envelope verify --verifier "$ATTESTATION_PUBKEYS" "$ATTESTATION_SIGNED"

│ Signature valid
```

But wait. You signed it. Does that prove the claim is true?

No. Verification confirms that BRadvoc8's key signed this content and that nothing was modified. It says nothing about whether the claim is accurate. Anyone can claim "I contributed to Galaxy Project." The signature proves you MADE the claim, not that you made the contribution.

This distinction matters. Self-attestations are starting points for building trust, not proof of competence. The `verifiableAt` field points to evidence that verifiers can check independently.

---

## Part III: What Makes This Verifiable

Amira created and signed her attestation. Now we switch to Ben's perspective: how does he verify what she claims?

Ben receives Amira's attestation. His verification has two layers: cryptographic and evidential.

**Cryptographic verification**: Ben fetches BRadvoc8's XID, extracts the attestation key, and verifies the signature:

```
# Ben fetches BRadvoc8's published XID
BEN_FETCHED_XID="$PUBLIC_XID"  # In reality, fetched from dereferenceVia URL

# Extract the attestation public key from the XID
ATTESTATION_KEY=$(envelope xid key all "$BEN_FETCHED_XID" | head -1)

# Verify attestation was signed by that key
envelope verify --verifier "$ATTESTATION_KEY" "$ATTESTATION_SIGNED"

│ Signature valid
```

This proves the attestation wasn't tampered with AND came from a key registered in BRadvoc8's XID.

**Evidence verification**: Ben follows the `verifiableAt` URL to GitHub and checks if PR #12847 exists, was merged, and adds mass spec visualization. The attestation points to observable evidence that anyone can independently verify.

Here's the gap: Ben can't prove BRadvoc8 IS the PR author from this attestation alone. What he can see is that BRadvoc8 points to real evidence and invites investigation. Combined with other attestations and eventual peer endorsements, a picture of credibility builds over time.

> :brain: **Learn more**: The [Progressive Trust](../concepts/progressive-trust.md) concept doc explains how self-attestations combine with cross-verification and peer endorsements to build meaningful trust over time.

---

## Part IV: Attestation Lifecycle

Attestations aren't permanent. Claims become stale, projects end, skills evolve. Amira's Galaxy Project contribution from 2024 is factual forever, but her "currently working on" claims need updates.

### Updating vs. Superseding

| Situation | Approach |
|-----------|----------|
| Claim is still true, adding detail | Create new attestation with more info |
| Claim is outdated | Create superseding attestation |
| Claim was wrong | Create retraction attestation |

Attestations are immutable once signed—you can't edit one. Instead, you create a new attestation that references and supersedes the old one.

### Step 7: Supersede an Attestation

Two years later, Amira's Galaxy Project work has expanded:

```
# Create superseding attestation
UPDATED_CLAIM=$(envelope subject type string \
  "I contributed mass spec visualization and data pipeline code to galaxyproject/galaxy (PRs #12847, #14201, #15892, 2024-2026)")

UPDATED_ATTESTATION=$(envelope assertion add pred-obj known isA string "SelfAttestation" "$UPDATED_CLAIM")
UPDATED_ATTESTATION=$(envelope assertion add pred-obj string "attestedBy" string "$XID_ID" "$UPDATED_ATTESTATION")
UPDATED_ATTESTATION=$(envelope assertion add pred-obj string "attestedOn" date "2028-01-15T00:00:00Z" "$UPDATED_ATTESTATION")
UPDATED_ATTESTATION=$(envelope assertion add pred-obj string "verifiableAt" string "https://github.com/galaxyproject/galaxy/pulls?q=author:BRadvoc8" "$UPDATED_ATTESTATION")

# Reference the original attestation being superseded
ORIGINAL_DIGEST=$(envelope digest "$ATTESTATION_SIGNED")
UPDATED_ATTESTATION=$(envelope assertion add pred-obj string "supersedes" string "$ORIGINAL_DIGEST" "$UPDATED_ATTESTATION")

# Sign
UPDATED_ATTESTATION=$(envelope sign --signer "$ATTESTATION_PRVKEYS" "$UPDATED_ATTESTATION")

echo "Updated attestation (supersedes original):"
envelope format "$UPDATED_ATTESTATION" | head -12

│ {
│     "I contributed mass spec visualization and data pipeline code to galaxyproject/galaxy (PRs #12847, #14201, #15892, 2024-2026)" [
│         'isA': "SelfAttestation"
│         "attestedBy": "c7e764b7"
│         "attestedOn": 2028-01-15T00:00:00Z
│         "supersedes": "ur:digest/hdcx..."
│         "verifiableAt": "https://github.com/galaxyproject/galaxy/pulls?q=author:BRadvoc8"
│     ]
│ } [
│     'signed': Signature
│ ]
```

The `supersedes` field links to the original attestation's digest. Verifiers who encounter both can see the relationship: the newer one extends and replaces the older one.

> :book: **Superseding Pattern**: Create a new attestation with a `supersedes` assertion pointing to the original's digest. The original remains valid (the 2024 claim was true then) but the newer attestation reflects current state.

### Retractions

If a claim was incorrect, create a retraction:

```
# Retract an incorrect claim
RETRACTION=$(envelope subject type string "RETRACTED: [original claim text]")
RETRACTION=$(envelope assertion add pred-obj known isA string "Retraction" "$RETRACTION")
RETRACTION=$(envelope assertion add pred-obj string "retracts" string "$ORIGINAL_DIGEST" "$RETRACTION")
RETRACTION=$(envelope assertion add pred-obj string "reason" string "Claim was overstated" "$RETRACTION")
RETRACTION=$(envelope sign --signer "$ATTESTATION_PRVKEYS" "$RETRACTION")
```

Retractions are serious—they indicate an error in judgment. Use sparingly. Most updates are supersessions (extending or refining), not retractions (correcting errors).

---

## Part V: Wrap-Up

Amira has created a fair witness attestation signed with a dedicated attestation key registered in her XID. Ben can verify signatures against her XIDDoc and check evidence at the `verifiableAt` URL.

### Save Your Work

```
echo "$ATTESTATION_SIGNED" > "$OUTPUT_DIR/attestation-galaxy.envelope"
echo "$XID" > "$OUTPUT_DIR/BRadvoc8-xid.envelope"

echo "Saved to $OUTPUT_DIR"
ls "$OUTPUT_DIR"

│ Saved to output/xid-tutorial05-20260121120000
│ attestation-galaxy.envelope
│ BRadvoc8-xid.envelope
```

> :brain: **Key Storage**: Your attestation private key is embedded in the XID document, encrypted with your password (just like the inception key). You don't need a separate key file—when you need to sign attestations, you extract the key from your XID using your password.

### What You Built

You created a fair witness attestation: a specific, factual claim that points to verifiable evidence. The Galaxy Project attestation isn't just a claim; it's a claim with a URL where anyone can check the actual code.

**Trust Assessment**:

| What Ben Can Verify | What Remains Unproven |
|---------------------|----------------------|
| ✅ BRadvoc8 made this claim | ❓ Claim is actually true |
| ✅ Claim wasn't modified (signature valid) | ❓ BRadvoc8 = PR author |
| ✅ Evidence URL exists | ❓ Quality of the contribution |
| ✅ Attestation date recorded | ❓ Real-world identity |

You learned the difference between detached and embedded attestations, and why detached works better for skill claims. And you understand that signatures prove you made the claim, not that the claim is true. The evidence link is what makes verification possible.

### The Limitation

> :warning: **Self-Attestations Have Limited Weight**: Anyone can claim anything. A signed attestation proves you made the claim, not that it's true. Real credibility comes from peer endorsements and verified collaboration history.

Self-attestations are cheap to create. Anyone can claim anything. What's missing is external validation: when peers vouch for you, your claims gain weight. But not all claims should be published publicly—some credentials could reveal your identity if combined with other public information.

---

## Appendix: Key Terminology

> **Attestation Key**: A dedicated signing key for creating detached attestations, registered in your XID. Verified against the XID key list, not an external service.
>
> **Detached Attestation**: A signed statement that exists as a separate envelope, referencing your XID but not embedded in your XIDDoc.
>
> **Embedded Attestation**: An assertion inside your XIDDoc, tightly coupled to your identity.
>
> **Fair Witness Methodology**: Making only factual, specific, verifiable claims rather than opinions or vague assertions.
>
> **Self-Attestation**: A claim you make about yourself, as opposed to an endorsement where someone else vouches for you.
>
> **Superseding**: Creating a new attestation that replaces an older one, linked via the `supersedes` assertion. The original remains valid for its time; the new one reflects current state.

### Key Type Comparison

| Key Type | Purpose | Verified Against | Added In |
|----------|---------|------------------|----------|
| XID inception key | Signs XID document updates | XID itself | T01 |
| SSH signing key | Signs Git commits | GitHub's registry | T03 |
| Attestation key | Signs detached attestations | XID key list | T05 (now) |

---

## Exercises

**Building exercises (Amira's perspective):**

- Create a fair witness attestation for one of your own verifiable contributions (GitHub PR, package, blog post).
- Register a dedicated attestation key in your XID (not your inception key).

**Verification exercises (Ben's perspective):**

- Given an attestation envelope, extract the `verifiableAt` URL and check if the evidence exists.
- Verify the signature using the attestation key from the XID.

**Analysis exercises:**

- Compare a fair witness claim to a vague claim about the same skill: what makes the fair witness version stronger?
- Identify 2-3 public contributions you could attest to with verifiable evidence.

---

**Previous**: [Cross-Verification](04-cross-verification.md) | **Next**: [Managing Sensitive Claims](06-managing-sensitive-claims.md)
