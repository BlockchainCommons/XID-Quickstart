# 2.2: Managing Sensitive Claims with Elision

This sections describes how to handle credentials that are too risky
to publish publicly using commitment patterns and selective
disclosure.

> **🧠 Related Concepts.** After completing this tutorial, explore
[Progressive Trust](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/concepts/progressive-trust.md) and
[Self-Attestation](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/concepts/attestation-endorsement-model.md) to deepen your
understanding.

## Objectives for this Section

After working through this section, a developer will be able to:

- Make a commitment.
- Verify a commitment against a revealed claim.

Supporting objectives include the ability to:

- Understand how correlation risk compounds with each public claim.
- Differentiate between three approaches for handling sensitive information.
- Undestand how inclusion proofs allow you to commit now and reveal later.

## Amira's Story: Every Claim Narrows the Field

Amira did cryptographic audit work for a fintech startup in 2023-2024. She reviewed authentication implementations, found vulnerabilities, and helped to fix them. It's valuable experience that would strengthen her credibility for security work. But "crypto auditor" is a rare skill. How many people worldwide have done professional cryptographic audits? Maybe a few thousand. Combine that with other public claims, which might include that she's a Galaxy Project contributor, is privacy-focused, and speaks Portuguese, and the intersection might describe only a handful of people.

This is correlation risk. Each claim by itself might be safe. Combined, they create a fingerprint.

> 📖 **What is a Correlation Risk?** Public information can be combined to narrow an anonymity set until it identifies a specific person. Each additional claim shrinks the pool of people who could match. This creates correlation risk.

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

> ⚠️ **Consider the Correlation Risks Before Making Claims.** Ask "How many people worldwide could truthfully make this exact statement?" If the answer is under 100, combine it with your other public claims and ask again. If the combined answer approaches single digits, that claim needs special handling.

## The Possibilities of Protecting Sensitive Data

Amira has three options for handling the correlation risk of her crypto audit experience.

* **Option 1: Omit Entirely.** Don't mention it at all. If Amira never needs to prove this experience, keeping it private is the safest choice. There's zero correlation risk from information that isn't published. The downside is that she loses the reputation benefit. If crypto audit experience would help her get accepted onto a security project, omitting it means she can't use it.
* **Option 2: Commit Elided.** Create the attestation and sign it, but publish only an opaque commitment (the digest). The commitment proves that Amira had some claim at a specific time, without revealing what the claim says. Later, she can reveal the full attestation to specific people who can verify that it matches the public commitment. This is the "prove I had it all along" pattern. It's useful when you might need to demonstrate timing without revealing content and also tends to give weight to a claim because it didn't come out of nowhere. This is what we'll cover in this Tutorial.
* **Option 3: Encrypt for Recipient.** Create the attestation and encrypt it for a specific person's public key. Only that person can read it. No public trace at all. This is covered in [Tutorial §2.3](02_3_Managing_Claims_Encryption.md). It's the right choice when a specific trusted person needs to see the claim now, and you don't need to prove timing to anyone else.

| Situation | Approach |
|-----------|----------|
| Never need to prove this | Omit entirely |
| Might need to prove later | Commit elided |
| Specific person needs it now | Encrypt for them |

Amira decides her crypto audit experience fits the middle category. She might need to prove this capability to future collaborators, but she doesn't want to publish it broadly. She'll commit an elided version publicly and reveal the full attestation selectively.

> 🧠 **Learn more**: These three approaches are part of the broader concept of [Selective Disclosure](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/concepts/data-minimization.md), which is the ability to reveal different information to different parties from the same underlying data structure.

## Part I: Creating a Commitment

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
If you instead need to create new ones, see [§2.2](02_1_Creating_Self_Attestations.md#step-1-create-an-attestation-key) for how to do so, then register your keys in your XID.

### Step 1: Create the Sensitive Attestation

You should create Amira's crypto audit attestation with [fair witness](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/concepts/fair-witness.md) precision:

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

The elided version shows nothing, just the word `ELIDED`. But here's the key property: the hash (digest) of the elided envelope will be identical to the hash of the original envelope, offering proof that their content is identical, even though it can not longer be seen in the elided envelope.

This commitment could be published in a variety of ways. Amira might
have a set of self-attestations available on her GitHub, some of which
are elided and some of which are not. Or, she might maintain a public
commitment list. This is typically a list of digests in a public
profile with category hints (e.g., "Security", "Privacy
Engineering"). This tells collaborators that she has additional
credentials without revealing what they are.

> 📖 **What is a Commitment?** A commitment is literally a
promise. Cryptographically, a commitment is a promise that you have
recorded a certain value. All you reveal is a hash of that value,
which is the cryptographic commitment. Since (probabalistically) each
recorded value only leads to one hash, when you reveal the original
value and it hashes correctly, your commitment has been fulfilled.

## Part II: Revealing a Commitment

Amira set up her audit commitment when she created her BRadvoc8
identity, so that she could work with Ben. But the whole point of
commitments is that they sit around, gaining trust as they do, and
tend to be revealed later. That's the case here.  Six months later,
Amira has approached DevReviewer for a security collaboration.

### Step 4: Highlight the Commitment

DevReviewer has seen Amir'as public attestation (about the Galaxy
Project) but want to know about her security audit experience. Amira
mentions that she has relevant experience but couldn't share details
publicly. She points to the commitment.

DevReviewer looks at the commitment, which is stored on GitHub, and
uses its (more trustworthy) datestamping to verify it was commited to
GitHub about six months ago, and it's one of just a few public
commitments of that sort.

### Step 5: Reveal the Unelided Claim

Amira next sends DevReviewer the full attestation (`$AUDIT_SIGNED`)
via a secure message system. DevReviewer now has both versions.

## Part III: Verifying the Commitment

We now switch to DevReviewer's point of view. Their verification of
the full attestation will come in two parts: checking that this is the
same document as the commitment (which is very similar to the process
of checking an inclusion proof) and verifying the signature.

> 📖 **What is an Inclusion Proof?** An inclusion proof typically
reveals that a piece of data is part of a larger data set without
revealing the entirety of the larger data set. For example, you could
a claim was in a partially elided Gordian Envelope just by knowing a
hash of the claim that was still visible in the envelope. Verifying a
commitment of this sort isn't quite the same thing since here we're
checking that a piece of data matches another piece of data that isn't
entirely revealed. But the theory and the procedure are largely the
same.

### Step 6: Test the Commitment

DevReviewer computes the digest of what they received:

```
ELIDED_DIGEST=$(envelope digest "$AUDIT_ELIDED") # Downloaded from GitHub
RECEIVED_DIGEST=$(envelope digest "$AUDIT_SIGNED") # Received from Amira
```
They then compare these two digests, the commited digest (downloaded
from GitHub) and the digest on the fully visible claim (received from
Amira).
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

> 📖 **Why Is It Important that Amira Committed in Advance?** Amira committing and publishing her elided commitment about her security audit work literally shows commitment. Progressive trust is all about establishing and improving levels of trust, and this is a strong signal that Amira can be trusted on this claim (which is otherwise not verifiable). She made the statement some time ago. It's been publicly available on the web for some time, something that might be verifiable by GitHub timestamps or archive.org storage. It's also presumably a part of a relatively small set of claims (or at least a relatively small set of hidden claims). That means that Amira isn't just pulling the claim that she can do security audits out of a hat. It's one of a small number of things she said some time ago, increasing its credibility despite the lack of verification. 

### Step 7: Verify the Signature

Finally, DevReviewer uses Amira's public attestation key, previously extracted from her public XID, to verify that the attesetation was indeed made by Amira. (See [§2.1](02_1_Creating_Self_Attestations.md#step-11-check-the-claims-signature) for a more complex methodology to check a signature against every public key in a XID.)
```
envelope verify -s --verifier "$ATTESTATION_PUBKEYS" "$AUDIT_SIGNED"

│ (no response means signature is valid.)
```

The signature is valid.

### Step 8: Assess Your Level of Trust

Combining the valid signature with the verified commitment,
DevReviewer has three pieces of information:

| What DevReviewer Can Verify | What Remains Unproven |
|---------------------|----------------------|
| ✅ Claim matches a public commitment | ❓ Claim is actually true |
| ✅ Claim was published at a previous date | ❓ What other hidden claims say |
| ✅ Claim was not modified | ❓ Whether claim varies a different hidden claim |
| ✅ BRadvoc8 signed the claim | ❓ Who BRadvoc8 is |

DevReviewer can now read the claim and factor it into their trust decision.

#### A Review of Envelope Elision

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

## Part IV: Managing the Commitment Lifecycle

This doesn't have to be the end of the life cycle of a commitment.

### Step 9: Supersede a Commitment

If Amira's skills evolve, of if she joins other projects, she can
create new commitments, just as she managed the
[lifecycle](02_1_Creating_Self_Assertions.md#part-v-managing-the-attestation-lifecycle)
of her visible attestations. Old commitments remain valid but can be
retired.

## Summary: From Correlation to Elision

This tutorial introduced the problem of correlation risk: how claims compound to narrow anonymity sets. The three disclosure approaches (omit, commit, encrypt) give you options for different situations. Commit means creating a sensitive attestation and committed to it publicly without revealing the content. This inclusion proof pattern lets Amira prove she had this credential all along when she chooses to reveal it: she can't be accused of fabricating it after the fact.

### Exercises

1. Identify a skill you have that would be risky to publish publicly. What makes it identifying?
2. Create an elided commitment for a hypothetical sensitive attestation.
3. Walk through the verification steps as if you were DevReviewer receiving a revealed attestation

## What's Next

The commit-reveal pattern works for proving timing and existence. But what about claims so sensitive that even a hint of their existence is risky? That's the topic [§2.3: Managing Sensitive Claims with Encryption](02_3_Managing_Claims_Encryption.md).

--

## Appendix I: Key Terminology

> **Commitment**: A digest that commits to certain content that is being elided or otherwise withheld.
> 
> **Correlation Risk**: The potential for combining public information to identify a pseudonym. Claims compound: each one narrows the anonymity set.
>
> **Elided Envelope**: An envelope with content removed but cryptographic identity (digest) preserved. Proves existence without revealing content.
>
> **Inclusion Proof**: A demonstration that a revealed document is found in a larger document that has not been entirely revealed.
