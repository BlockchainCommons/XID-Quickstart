# Tutorial 06: Managing Sensitive Claims

Handle credentials that are too risky to publish publicly using commitment patterns and selective disclosure.

**Time to complete**: ~20-25 minutes
**Difficulty**: Intermediate
**Builds on**: Tutorials 01-05

> **Related Concepts**: After completing this tutorial, explore [Progressive Trust](../concepts/progressive-trust.md) and [Self-Attestation](../concepts/self-attestation.md) to deepen your understanding.

## Prerequisites

- Completed Tutorial 05 (Fair Witness Attestations)
- The `envelope` CLI tool installed
- Understanding of detached attestations from Tutorial 05

## What You'll Learn

- How **correlation risk** compounds with each public claim
- Three approaches for handling sensitive information
- **Inclusion proofs**: commit now, reveal later
- The verifier's workflow for checking revealed claims

## Building on Tutorial 05

| Tutorial 05 | Tutorial 06 |
|-------------|-------------|
| Created public attestations | Handle sensitive ones |
| Galaxy contribution (safe to share) | Crypto audit (risky to share) |
| Fair witness methodology | Disclosure strategy |

**The Bridge**: Your Galaxy Project attestation is safe to share publicly—it's already on GitHub for anyone to see. But not all your skills pass the newspaper test. What about credentials that could identify you if published?

---

## The Problem: Every Claim Narrows the Field

Amira did cryptographic audit work for a fintech startup in 2023-2024. She reviewed authentication implementations, found vulnerabilities, and helped fix them. It's valuable experience that would strengthen her credibility for security work.

But "crypto auditor" is a rare skill. How many people worldwide have done professional cryptographic audits? Maybe a few thousand. Combine that with her other public claims—Galaxy Project contributor, privacy-focused, speaks Portuguese—and the intersection might describe only a handful of people.

This is correlation risk. Each claim by itself might be safe. Combined, they create a fingerprint.

> :book: **Correlation Risk**: The potential for combining public information to narrow an anonymity set until it identifies a specific person. Each additional claim shrinks the pool of people who could match.

### How Claims Compound

Watch how Amira's anonymity set shrinks:

| Claims Combined | Approximate Population |
|----------------|------------------------|
| "Security professional" | Hundreds of thousands |
| + "8 years experience" | Tens of thousands |
| + "Privacy focus" | Thousands |
| + "Crypto audit experience" | Hundreds |
| + "Galaxy Project contributor" | Maybe dozens |
| + "Based in South America" | Single digits |

That last combination might describe three people in the world. If an adversary knows those facts and sees BRadvoc8's public profile, correlation becomes trivial.

### The Quick Heuristic

> :warning: **Before Publishing**: Ask "How many people worldwide could truthfully make this exact statement?" If the answer is under 100, combine it with your other public claims and ask again. If the combined answer approaches single digits, that claim needs special handling.

---

## Part I: Three Approaches to Sensitive Information

Amira has three options for her crypto audit experience:

### Option 1: Omit Entirely

Don't mention it at all. If she never needs to prove this experience, keeping it private is the safest choice. Zero correlation risk from information that isn't published.

The downside: she loses the reputation benefit. If crypto audit experience would help her get accepted onto a security project, omitting it means she can't use it.

### Option 2: Commit Elided

Create the attestation, sign it, but publish only an opaque commitment (the digest). The commitment proves she had some claim at a specific time, without revealing what the claim says. Later, she can reveal the full attestation to specific people who can verify it matches the public commitment.

This is the "prove I had it all along" pattern. Useful when you might need to demonstrate timing or existence without revealing content.

### Option 3: Encrypt for Recipient

Create the attestation and encrypt it for a specific person's public key. Only that person can read it. No public trace at all.

This is covered in Tutorial 07. It's the right choice when a specific trusted person needs to see the claim now, and you don't need to prove timing to anyone else.

### When to Use Each

| Situation | Approach |
|-----------|----------|
| Never need to prove this | Omit entirely |
| Might need to prove timing later | Commit elided |
| Specific person needs it now | Encrypt for them |

Amira decides her crypto audit experience fits the middle category. She might need to prove this capability to future collaborators, but she doesn't want to publish it broadly. She'll commit an elided version publicly and reveal the full attestation selectively.

> :brain: **Learn more**: These three approaches are part of the broader concept of [Selective Disclosure](../concepts/selective-disclosure.md)—the ability to reveal different information to different parties from the same underlying data structure.

---

## Part II: Creating the Commitment

### Step 0: Verify Dependencies

Ensure you have the required tools installed:

```
envelope --version

│ bc-envelope-cli 0.32.0
```

If not installed, see Tutorial 01 Step 0 for installation instructions.

### Step 1: Set Up Environment

```
OUTPUT_DIR="output/xid-tutorial06-$(date +%Y%m%d%H%M%S)"
mkdir -p "$OUTPUT_DIR"

# Create XID
XID=$(envelope generate keypairs --signing ed25519 | \
    envelope xid new --nickname "BRadvoc8" --generator include --sign inception)

UNWRAPPED_XID=$(envelope extract wrapped "$XID")
XID_ID=$(envelope xid id "$UNWRAPPED_XID")

# Attestation keys
ATTESTATION_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
ATTESTATION_PUBKEYS=$(envelope generate pubkeys "$ATTESTATION_PRVKEYS")

echo "Created XID: $XID_ID"

│ Created XID: c7e764b7
```

### Step 2: Create the Sensitive Attestation

Amira creates her crypto audit attestation with fair witness precision:

```
AUDIT_CLAIM=$(envelope subject type string \
  "I audited cryptographic implementations for authentication systems (2023-2024)")

AUDIT_CLAIM=$(envelope assertion add pred-obj known isA string "SelfAttestation" "$AUDIT_CLAIM")
AUDIT_CLAIM=$(envelope assertion add pred-obj string "attestedBy" string "$XID_ID" "$AUDIT_CLAIM")
AUDIT_CLAIM=$(envelope assertion add pred-obj string "attestedOn" date "2026-01-21T00:00:00Z" "$AUDIT_CLAIM")
AUDIT_CLAIM=$(envelope assertion add pred-obj string "skillCategory" string "Security" "$AUDIT_CLAIM")

envelope format "$AUDIT_CLAIM"

│ "I audited cryptographic implementations for authentication systems (2023-2024)" [
│     isA: "SelfAttestation"
│     "attestedBy": "c7e764b7"
│     "attestedOn": 2026-01-21T00:00:00Z
│     "skillCategory": "Security"
│ ]
```

Notice she doesn't include the company name or specific details that would make correlation easier. The claim is specific enough to be meaningful but not so detailed that it uniquely identifies her.

### Step 3: Sign the Full Attestation

```
AUDIT_SIGNED=$(envelope sign --signer "$ATTESTATION_PRVKEYS" "$AUDIT_CLAIM")

echo "Full attestation created and signed"
envelope format "$AUDIT_SIGNED"

│ Full attestation created and signed
│ {
│     "I audited cryptographic implementations for authentication systems (2023-2024)" [
│         isA: "SelfAttestation"
│         "attestedBy": "c7e764b7"
│         "attestedOn": 2026-01-21T00:00:00Z
│         "skillCategory": "Security"
│     ]
│ } [
│     'signed': Signature
│ ]
```

This is the full attestation. Amira keeps this secure—it's the version she'll reveal selectively.

### Step 4: Create the Elided Commitment

Now she creates a version with the content removed but the cryptographic structure preserved:

```
AUDIT_DIGEST=$(envelope digest "$AUDIT_SIGNED")
AUDIT_ELIDED=$(envelope elide removing "$AUDIT_DIGEST" "$AUDIT_SIGNED")

echo "Elided commitment created"
echo "Digest: $AUDIT_DIGEST"
envelope format "$AUDIT_ELIDED"

│ Elided commitment created
│ Digest: ur:digest/hdcxzmwnbnrt...
│ ELIDED
```

The elided version shows nothing—just `ELIDED`. But here's the key property:

```
FULL_DIGEST=$(envelope digest "$AUDIT_SIGNED")
ELIDED_DIGEST=$(envelope digest "$AUDIT_ELIDED")

echo "Full attestation digest:  $FULL_DIGEST"
echo "Elided version digest:    $ELIDED_DIGEST"

if [ "$FULL_DIGEST" = "$ELIDED_DIGEST" ]; then
    echo "Digests match!"
fi

│ Full attestation digest:  ur:digest/hdcxzmwn...
│ Elided version digest:    ur:digest/hdcxzmwn...
│ Digests match!
```

The digests are identical. This is the foundation of the inclusion proof: the elided version has the same cryptographic identity as the full version, even though the content is hidden.

> :brain: **How this works**: Gordian Envelope uses Merkle tree hashing—each part contributes to the root hash, so eliding content preserves the cryptographic identity. See the [Gordian Envelope specification](https://developer.blockchaincommons.com/envelope/) for technical details.

---

## Part III: The Reveal

Six months later, DevReviewer is evaluating Amira for a security collaboration. They've seen her public attestation (Galaxy Project) but want to know about her security audit experience. Amira mentioned she has relevant experience but couldn't share details publicly.

### Step 5: Amira Reveals to DevReviewer

Amira sends DevReviewer the full attestation:

```
# Amira sends AUDIT_SIGNED to DevReviewer
echo "Amira sends full attestation to DevReviewer"

│ Amira sends full attestation to DevReviewer
```

DevReviewer already has the elided commitment (from Amira's public profile or an earlier conversation). Now they have the full version too.

### Step 6: DevReviewer Verifies the Inclusion Proof

DevReviewer's verification has two parts: checking that this is the same document as the commitment, and verifying the signature.

```
# DevReviewer computes the digest of what they received
RECEIVED_DIGEST=$(envelope digest "$AUDIT_SIGNED")

# Compare to the known commitment digest
echo "Commitment digest: $ELIDED_DIGEST"
echo "Received digest:   $RECEIVED_DIGEST"

if [ "$RECEIVED_DIGEST" = "$ELIDED_DIGEST" ]; then
    echo "Inclusion proof valid: this matches the public commitment"
else
    echo "WARNING: Does not match commitment!"
fi

│ Commitment digest: ur:digest/hdcxzmwn...
│ Received digest:   ur:digest/hdcxzmwn...
│ Inclusion proof valid: this matches the public commitment
```

The digests match. This proves the full attestation Amira revealed is the same document she committed to earlier—not something she fabricated after the fact.

### Step 7: DevReviewer Verifies the Signature

```
envelope verify --verifier "$ATTESTATION_PUBKEYS" "$AUDIT_SIGNED"

│ Signature valid
```

The signature is valid. Combined with the inclusion proof, DevReviewer has three pieces of information: the attestation matches what Amira committed to publicly, BRadvoc8's key signed this content, and the content hasn't been modified since signing. DevReviewer can now read the claim and factor it into their trust decision.

---

## Part IV: What the Elided Version Cannot Do

There's an important limitation to understand. Let's see what the elided version looks like:

```
envelope format "$AUDIT_ELIDED"

│ ELIDED
```

Just `ELIDED`. No content, no metadata, no signature visible. What happens if we try to verify it?

```
envelope verify --verifier "$ATTESTATION_PUBKEYS" "$AUDIT_ELIDED" 2>&1 || true

│ Error: No signature found
```

The verification fails because the elided version has no signature to check. Remember, we elided the *entire* signed envelope, not just the content inside. The elided version is just a digest placeholder—it proves something with this digest exists, but you can't verify its authenticity without the full version.

This is by design. The commitment pattern separates timing from content: in the commit phase, you publish the elided version to prove when you made the claim; in the reveal phase, you share the full version with specific people to prove what you claimed; then the recipient verifies the revealed version matches the public commitment.

You need the full version to verify the signature. The elided version only proves you had *something*—the full version proves what.

---

## Part V: Wrap-Up

### Save Your Work

```
# Save attestation files
echo "$AUDIT_SIGNED" > "$OUTPUT_DIR/audit-attestation-FULL.envelope"
echo "$AUDIT_ELIDED" > "$OUTPUT_DIR/audit-attestation-ELIDED.envelope"
echo "$AUDIT_DIGEST" > "$OUTPUT_DIR/audit-digest.txt"

# Save identity files
echo "$XID" > "$OUTPUT_DIR/BRadvoc8-xid.envelope"
echo "$ATTESTATION_PRVKEYS" > "$OUTPUT_DIR/attestation-prvkeys.envelope"

echo "Saved to $OUTPUT_DIR:"
ls "$OUTPUT_DIR"

│ Saved to output/xid-tutorial06-20260121120000:
│ audit-attestation-ELIDED.envelope
│ audit-attestation-FULL.envelope
│ audit-digest.txt
│ attestation-prvkeys.envelope
│ BRadvoc8-xid.envelope
```

### What You Built

You created a sensitive attestation and committed to it publicly without revealing the content. The inclusion proof pattern lets Amira prove she had this credential all along when she chooses to reveal it—she can't be accused of fabricating it after the fact.

You also understand correlation risk: how claims compound to narrow anonymity sets. The three disclosure approaches (omit, commit, encrypt) give you options for different situations.

### The Remaining Gap

The commit-reveal pattern works for proving timing and existence. But what about claims so sensitive that even a hint of their existence is risky? Amira's CivilTrust work falls into this category—she can't even suggest she has human rights technology experience. That requires direct encrypted sharing with specific trusted people.

---

## Appendix: Key Terminology

> **Correlation Risk**: The potential for combining public information to identify a pseudonym. Claims compound: each one narrows the anonymity set.
>
> **Inclusion Proof**: Demonstrating that a revealed document matches a previously published commitment (same digest).
>
> **Elided Envelope**: An envelope with content removed but cryptographic identity (digest) preserved. Proves existence without revealing content.

### Practical Notes

**When to use commit-reveal**: The pattern makes sense when a claim is too sensitive to publish broadly but you might need to prove timing later. For claims only specific people will ever see, direct encrypted sharing (Tutorial 07) is simpler.

**Public commitment lists**: You might maintain a list of digests in your public profile with category hints (e.g., "Security", "Privacy Engineering"). This tells collaborators you have additional credentials without revealing what they are.

**Refreshing commitments**: If your skills evolve, create new attestations. Old commitments remain valid but can be retired.

---

## Exercises

1. Identify a skill you have that would be risky to publish publicly. What makes it identifying?
2. Create an elided commitment for a hypothetical sensitive attestation
3. Walk through the verification steps as if you were DevReviewer receiving a revealed attestation

---

**Previous**: [Fair Witness Attestations](05-fair-witness-attestations.md) | **Next**: [Encrypted Sharing](07-encrypted-sharing.md)
