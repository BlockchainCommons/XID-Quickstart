# Tutorial 04: Managing Sensitive Claims with Elision

Handle credentials that are too risky to publish publicly using commitment patterns and selective disclosure.

* **Time to complete**: ~20-25 minutes
* **Difficulty**: Intermediate
* **Builds on**: Tutorials 01-03

> **Related Concepts**: After completing this tutorial, explore [Progressive Trust](../concepts/progressive-trust.md) and [Self-Attestation](../concepts/self-attestation.md) to deepen your understanding.

## Prerequisites

- Completed [Tutorial 03](03-creating-self-attestations.md) (Fair Witness Attestations)
- The [Gordian Envelope-CLI](https://github.com/BlockchainCommons/bc-envelope-cli-rust) tool (already installed in Tutorial 01)

## What You'll Learn

- How **correlation risk** compounds with each public claim
- Three approaches for handling sensitive information
- How **Inclusion proofs** allow you to commit now and reveal later
- The verifier's workflow for checking revealed claims

## The Problem: Every Claim Narrows the Field

Amira did cryptographic audit work for a fintech startup in 2023-2024. She reviewed authentication implementations, found vulnerabilities, and helped to fix them. It's valuable experience that would strengthen her credibility for security work. But "crypto auditor" is a rare skill. How many people worldwide have done professional cryptographic audits? Maybe a few thousand. Combine that with other public claims, which might include that she's a Galaxy Project contributor, is privacy-focused, and speaks Portuguese, and the intersection might describe only a handful of people.

This is correlation risk. Each claim by itself might be safe. Combined, they create a fingerprint.

> :book: **What is a Correlation Risk?**: Public information can be combined to narrow an anonymity set until it identifies a specific person. Each additional claim shrinks the pool of people who could match. This creates correlation risk.

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

> :warning: **Consider the Correlation Risks Before Making Claims**. Ask "How many people worldwide could truthfully make this exact statement?" If the answer is under 100, combine it with your other public claims and ask again. If the combined answer approaches single digits, that claim needs special handling.

## Part I: About Protecting Your Sensitive Information

Amira has three options for handling the correlation risk of her crypto audit experience.

* **Option 1: Omit Entirely.** Don't mention it at all. If Amira never needs to prove this experience, keeping it private is the safest choice. There's zero correlation risk from information that isn't published. The downside is that she loses the reputation benefit. If crypto audit experience would help her get accepted onto a security project, omitting it means she can't use it.
* **Option 2: Commit Elided.** Create the attestation and sign it, but publish only an opaque commitment (the digest). The commitment proves that Amira had some claim at a specific time, without revealing what the claim says. Later, she can reveal the full attestation to specific people who can verify that it matches the public commitment. This is the "prove I had it all along" pattern. It's useful when you might need to demonstrate timing without revealing content and also tends to give weight to a claim because it didn't come out of nowhere. This is what we'll cover in this Tutorial.
* **Option 3: Encrypt for Recipient.** Create the attestation and encrypt it for a specific person's public key. Only that person can read it. No public trace at all. This is covered in [Tutorial 05](3-creating-self-attestations.md). It's the right choice when a specific trusted person needs to see the claim now, and you don't need to prove timing to anyone else.

| Situation | Approach |
|-----------|----------|
| Never need to prove this | Omit entirely |
| Might need to prove later | Commit elided |
| Specific person needs it now | Encrypt for them |

Amira decides her crypto audit experience fits the middle category. She might need to prove this capability to future collaborators, but she doesn't want to publish it broadly. She'll commit an elided version publicly and reveal the full attestation selectively.

> :brain: **Learn more**: These three approaches are part of the broader concept of [Selective Disclosure](../concepts/selective-disclosure.md), which is the ability to reveal different information to different parties from the same underlying data structure.

## Part II: Creating the Commitment

### Step 0: Verify Dependencies & Reload XID

As usual, check your `envelope-cli` version:
```
envelope --version

│ bc-envelope-cli 0.34.1
```
Then, reload your XID, primarily to have easy access to your XID ID:
```
XID=$(cat envelopes/BRadvoc8-xid-private-02.envelope)
XID_ID=$(envelope xid id $XID)
```
You should then reload your Attestation keys from the last tutorial:
```
ATTESTATION_PRVKEYS=$(cat envelopes/attestation-private-03.ur)
ATTESTATION_PUBKEYS=$(cat envelopes/attestation-public-03.ur)
```
If you instead need to create new ones, see [Tutorial 03](03-creating-self-attestations.md#step-1-create-an-attestation-key) for how to do so, then register your keys in your XID.

### Step 1: Create the Sensitive Attestation

You should create Amira's crypto audit attestation with [fair witness](../concepts/fair-witness.md) precision:

```
AUDIT_CLAIM=$(envelope subject type string \
  "Audited cryptographic implementations for authentication systems (2023-2024)")
AUDIT_CLAIM=$(envelope assertion add pred-obj known isA known 'attestation' "$AUDIT_CLAIM")
AUDIT_CLAIM=$(envelope assertion add pred-obj known source ur $XID_ID "$AUDIT_CLAIM")
AUDIT_CLAIM=$(envelope assertion add pred-obj known target ur $XID_ID "$AUDIT_CLAIM")
AUDIT_CLAIM=$(envelope assertion add pred-obj known 'date' string `date -Iminutes` "$AUDIT_CLAIM")
AUDIT_CLAIM=$(envelope assertion add pred-obj string "skillCategory" string "Security" "$AUDIT_CLAIM")

envelope format "$AUDIT_CLAIM"

| "Audited cryptographic implementations for authentication systems (2023-2024)" [
|     'isA': 'attestation'
|     "skillCategory": "Security"
|     'date': "2026-02-18T15:08-10:00"
|     'source': XID(5f1c3d9e)
|     'target': XID(5f1c3d9e)
| ]
```

Notice that you don't include the company name that Amira worked for or specific details that would make correlation easier. The claim is specific enough to be meaningful but not so detailed that it uniquely identifies her.

### Step 2: Sign the Full Attestation

Next, you follow the normal procedure to wrap and sign the attestation:
```
AUDIT_WRAPPED=$(envelope subject type wrapped "$AUDIT_CLAIM")
AUDIT_SIGNED=$(envelope sign --signer "$ATTESTATION_PRVKEYS" "$AUDIT_WRAPPED")

echo "✅ Full attestation created and signed"
envelope format "$AUDIT_SIGNED"

| ✅ Full attestation created and signed
| {
|     "Audited cryptographic implementations for authentication systems (2023-2024)" [
|         'isA': 'attestation'
|         "skillCategory": "Security"
|         'date': "2026-02-18T15:08-10:00"
|         'source': XID(5f1c3d9e)
|         'target': XID(5f1c3d9e)
|     ]
| } [
|     'signed': Signature(Ed25519)
| ]
```

This is the full attestation that Amira will keep secure and private. But she wants to publicly share the fact that she made this claim, while not revealing exactly what it is; that requires the creation of an elided view.

### Step 3: Create the Elided Commitment

You can now create a view of the attestation with the content removed but the cryptographic structure preserved:

```
AUDIT_DIGEST=$(envelope digest "$AUDIT_SIGNED")
AUDIT_ELIDED=$(envelope elide removing "$AUDIT_DIGEST" "$AUDIT_SIGNED")

echo "✅ Elided commitment created"
echo "Digest: $AUDIT_DIGEST"
envelope format "$AUDIT_ELIDED"

│ ✅ Elided commitment created
│ Digest: ur:digest/hdcxlgahgagmckdrveclotpeaerfynndksjpsphhoywtfeotlgdtwkwdwpmhgsylndlyrndscaah
│ ELIDED
```

The elided version shows nothing, just the word `ELIDED`. But here's the key property: the hash (digest) fo the elided envelope will be identical to the hash of the original envelope, offering proof that their content is identical, even though it can not longer be seen in the elided envelope.

> :brain: **How Do Digests Remain the Same Through Elision?** Gordian Envelope uses Merkle tree-like hashing. Each leaf and each node contributes to the root hash. Eliding content preserves the cryptographic identity because of those hashes. See the [Gordian Envelope specification](https://developer.blockchaincommons.com/envelope/) for technical details.

## Part III: Revealing a Commitment

Six months later, DevReviewer is evaluating Amira for a security collaboration. They've seen her public attestation (about the Galaxy Project) but want to know about her security audit experience. Amira mentions that she has relevant experience but couldn't share details publicly.

### Step 4: Amira Reveals to DevReviewer

Amira sends DevReviewer the full attestation (`$AUDIT_SIGNED`).

DevReviewer already has the elided commitment (from Amira's public profile or an earlier conversation). Now they have the full version too.

DevReviewer's verification of the full attestation will come in two parts: checking that this is the same document as the commitment and verifying the signature.

### Step 5: DevReviewer Verifies the Inclusion Proof

DevReviewer computes the digest of what they received:

```
ELIDED_DIGEST=$(envelope digest "$AUDIT_ELIDED")
RECEIVED_DIGEST=$(envelope digest "$AUDIT_SIGNED")
```

They then compare that to the known commitment digest:
```
echo "Commitment digest: $ELIDED_DIGEST"
echo "Received digest:   $RECEIVED_DIGEST"

if [ "$RECEIVED_DIGEST" = "$ELIDED_DIGEST" ]; then
    echo "✅ Inclusion proof valid: this matches the public commitment"
else
    echo "❌ WARNING: Does not match commitment"
fi

│ Commitment digest: ur:digest/hdcxlgahgagmckdrveclotpeaerfynndksjpsphhoywtfeotlgdtwkwdwpmhgsylndlyrndscaah
│ Received digest:   ur:digest/hdcxlgahgagmckdrveclotpeaerfynndksjpsphhoywtfeotlgdtwkwdwpmhgsylndlyrndscaah
│ ✅ Inclusion proof valid: this matches the public commitment

```

The digests match. This proves the full attestation Amira revealed is the same document she committed to earlier, not something she fabricated after the fact.

> :book: **Why Is It Important that Amira Committed in Advance?** Amira committing and publishing her elided commitment about her security audit work literally shows commitment. Progressive trust is all about establishing and improving levels of trust, and this is a strong signal that Amira can be trusted on this claim (which is otherwise not verifiable). She made the statement some time ago. It's been publicly available on the web for some time, something that might be verifiable by GitHub timestamps or archive.org storage. It's also presumably a part of a relatively small set of claims (or at least a relatively small set of hidden claims). That means that Amira isn't just pulling the claim that she can do security audits out of a hat. It's one of a small number of things she said some time ago, increasing its credibility despite the lack of verification. 

### Step 6: DevReviewer Verifies the Signature

Finally, DevReviewer uses Amira's public attestation key, previously extracted from her public XID, to verify that the attesetation was indeed made by Amira. (See [tutorial 03](03-creating-self-attestations.md#part-iv-ben-again-verifies) for a more complex methodology to check a signature against every public key in a XID.)
```
envelope verify -s --verifier "$ATTESTATION_PUBKEYS" "$AUDIT_SIGNED"

│ (no response means signature is valid.)
```

The signature is valid. Combined with the inclusion proof, DevReviewer has three pieces of information: 

| What DevReviewer Can Verify | What Remains Unproven |
|---------------------|----------------------|
| ✅ Claim matches a public commitment | ❓ Claim is actually true |
| ✅ Claim was published at a previous date | ❓ What other hidden claims say |
| ✅ Claim was not modified | ❓ Whether claim modifies a different hidden claim |
| ✅ BRadvoc8 signed the claim | ❓ Who BRadvoc8 is |

DevReviewer can now read the claim and factor it into their trust decision.

#### A Review of Elision

There's an important limitation to understand for elision. A fully `ELIDED` envelope has no content, no metadata, and no signature visible.

```
envelope format "$AUDIT_ELIDED"

│ ELIDED
```

That means that the envelope's signature can't be verified while it's elided:

```
envelope verify -s --verifier "$ATTESTATION_PUBKEYS" "$AUDIT_ELIDED"

│ Error: could not verify a signature
```

The elided version is just a digest placeholder: it proves something with its digest, but you can't verify its authenticity without the full version. This is by design. The commitment pattern separates timing from content: in the commit phase, you publish the elided version to prove when you made the claim; in the reveal phase, you share the full version with specific people to prove what you claimed; then the recipient verifies the revealed version matches the public commitment.

## Summary: From Correlation to Elision

This tutorial introduced the problem of correlation risk: how claims compound to narrow anonymity sets. The three disclosure approaches (omit, commit, encrypt) give you options for different situations. Commit means creating a sensitive attestation and committed to it publicly without revealing the content. This inclusion proof pattern lets Amira prove she had this credential all along when she chooses to reveal it: she can't be accused of fabricating it after the fact.

### Exercises

1. Identify a skill you have that would be risky to publish publicly. What makes it identifying?
2. Create an elided commitment for a hypothetical sensitive attestation.
3. Walk through the verification steps as if you were DevReviewer receiving a revealed attestation

[need to finish]

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



---

**Previous**: [Fair Witness Attestations](05-fair-witness-attestations.md) | **Next**: [Encrypted Sharing](07-encrypted-sharing.md)
