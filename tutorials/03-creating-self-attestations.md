# Tutorial 03: Creating Self Attestations

Build credibility through specific, factual claims that invite verification rather than demand belief.

**Time to complete**: ~15-20 minutes
**Difficulty**: Intermediate
**Builds on**: Tutorials 01-02

> **Related Concepts**: After completing this tutorial, explore [Progressive Trust](../concepts/progressive-trust.md) and [Self-Attestation](../concepts/self-attestation.md) to deepen your understanding.

## Prerequisites

- Completed Tutorial 02 (Making Your XID Verifiable)
- The `envelope` CLI tool installed
- Your XID artifacts from previous tutorials

## What You'll Learn

- The **fair witness methodology** for making credible claims
- How to register **attestation keys** in your XID for signature verification
- How to create attestations that are **publicly verifiable**
- How to advance your provenance mark
- The difference between **detached** and **embedded** attestations

## The Problem: Claims Without Proof

After Tutorial 02, Ben has a verified copy of BRadvoc8's XID. But it's just a collection of keys attached to a nickname. Can BRadvoc8 write good code, understand security, and deliver quality work? These are the questions that Ben needs answered before he decides to bring BRadvoc8 into the SisterSpace project.

To reveal more about her skill set, Amira must create attestations about them. Since Amira is bootstrapping the BRadvoc8 on her own, they need to be self-attestations: things that she says about herself (or rather, her identity) that reveal her capabilities. The problem is that a vague claim like "Security expert with 8 years experience" is worthless. Anyone can type that.

> :book: **What is a Self Attestation?**: As the name suggestion, a self attestation is a claim that you make about yourself. It's contrasted with an *endorsement*, where someone else vouches for you. Self-attestations are starting points; endorsements carry more weight because they come from independent parties.

Amira needs a different approach: specific claims that point to verifiable evidence.

## Part I: About Fair Witness Attestations

*This section explains the concepts behind attestations. If you're ready to start creating one, skip to [Part II](#part-ii-adding-an-attestation-key).*

Amira has to make a self-attestation. But, not all attestations are created equal. Some are vague and hard to pin down, while others are so specific that they can be proven with other references. Compare these two attestations:

| Claim | Quality | Support |
|-------|------|-----|
| "I'm good at security" | Weak | Opinion, nothing to check |
| "I contributed to Galaxy Project (PR #12847)" | Strong | Verifiable on GitHub |

The strong claim invites validation rather than demanding belief. For pseudonymous contributors who can't flash a diploma, evidence-backed attestations ARE your credentials.

When Amira is making self-attestations, she will therefore do her best to both create attestations that are verifiable and then provide the methodology for verifying.

To be more precise, Amira will make ["fair witness claims."](../concepts/fair-witness.md). She will report without interpretation, assumption, or bias, as best she can. Saying someone was good at security would be an interpretation, so that would fail the fair witness test, but instead reporting a contribution is a simple statement of fact, as long as she doesn't adorn it by saying something like, "I made a crucial contribution to the Galaxy Project."

> :book: **What is the Fair Witness Methodology?**: The Fair Witness methodology is derived from Robert E. Heinlein's _Stranger in a Strange Land_ (1961). A Fair Witness makes a claim of what they directly observed, avoiding interpretation, assumption, or (as much as possible) bias. If it's meaningful, a fair witness claim also should include context describing the methodology of the observation, its limitations, and any bias built into.

## Part II: Adding an Attestation Key

Amira contributed to Galaxy Project, an open source bioinformatics platform. Her pull request added mass spectrometry visualization features. This is the kind of specific, verifiable claim that builds real credibility. You're going to build an attestation about that claim, but first you need to create a secure way to make attestations.

### Step 0: Verify Dependencies & Reload XID

Ensure you have the required tools installed:

```
envelope --version
provenance --version

│ bc-envelope-cli 0.34.1
│ provenance-mark-cli 0.7.0
```

If not installed, see [Tutorial 01 Step 0](01-your-first-xid.md#step-0-setting-up-your-workspace) for installation instructions.

You'll also want to reload your XID. The following assumes use of the [`envelopes`](envelopes) directory we created in the last tutorial.
```
XID=$(cat envelopes/BRadvoc8-xid-private-02.envelope)
XID_ID=$(envelope xid id $XID)
```

### Step 1: Create an Attestation Key

Every attestation, even a self-attestation should be signed. Viewers have to know who is behind a claim and that the claim hasn't been changed since that person agreed to it. You could sign attestations with the signing key of your XID. However, that's your XID inception key, and it's powerful: it can modify your identity. Using it for routine signing increases exposure risk. For that reason you want to create new attestation keys that can be rotated or revoked without affecting your core identity. 
```
ATTESTATION_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
ATTESTATION_PUBKEYS=$(envelope generate pubkeys "$ATTESTATION_PRVKEYS")
```

> :book: **What Are Attestation Key?**: Attestation keys are dedicated signing key for making attestations that are registered in your XID to link them to your core identity.

### Step 2: Register Attestation Key in XID

For Ben to verify attestations came from BRadvoc8, the attestation public key must be in the XID. You also should embed the private key (encrypted) so Amira can sign attestations without managing separate key files. This is done with the `xid key add`, which is very similar yo the `xid resolution add` function that you used in the last tutorial.

> :warning: **XID FUNCTIONS ONLY!** If you're familiar with Gordian Envelope, you'll know that you can freely add assertions to the envelope. Though XID is built on envelope, it's intended to be a much more structured format, with all content always in carefully structured places such as `derferenceVia`, `key`, `provenance`, and other subjects that you'll meet in future tutorials. You should always expect to use `envelope xid` commands when working with the core XID structure (though you may place less structured content under certain subjects, such as the `edge` that we'll meet in the next chapter).

```
PASSWORD="your-password-from-previous-tutorials"
UPDATED_XID=$(envelope xid key add \
    --nickname "attestation-key" \
    --allow sign \
    --password "$PASSWORD" \
    --private encrypt \
    --encrypt-password "$PASSWORD" \
    "$ATTESTATION_PRVKEYS" \
    "$XID")

echo "Added attestation key to XID"
```

The CLI derives the public key from the private key automatically. With the `--private encrypt`, `--password`, and `--encrypt-password` commands, the private XID is first decrypted, then re-encrypted. You add a new `nickname` to clarify what the key is for, and there's also one new argument:

1. `--allow sign` is a permission statement indicates this key can only sign, it cannot modify the XID itself. (That requires the inception key.)

#### Key Type Comparison

It is a best practice to have different keys for different purposes. This improves privacy and decreases the repercussions of key loss or compromise. The traditional threat has been figuring out how to handle a "bag of keys." XIDs offer the answer: they can be used to manage a whole set of keys, and the keys can be encrypted with a password for protection on your own storage and elided for near-total protection when a XID is shared.

So far, Amira has two keys:

| Key Type | Purpose | Verified Against | Added In |
|----------|---------|------------------|----------|
| XID inception key | Signs XID document updates | XID itself | T01 |
| Attestation key | Signs detached attestations | XID key list | T03 |

### Step 3: Advance Your Provenance Mark

You're going to need to publish this XID so that Ben can check Amira's self-attestation against her new signature. Whenever you publish a new edition of a XID (meaning that you've changed the underlying content, not just changing the view by eliding existing data differently), you should also advance the provenance mark. This will allow viewers who have multiple copies of a XID to determine which one is newest.

Advancing the provenance mark is done with the simple `provenance next` command, which as usual must decrypt and recrypt your content:
```
UPDATED_XID=$(envelope xid provenance next \
    --password "$PASSWORD" \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$UPDATED_XID")
echo "✅ Provenance advanced"

| ✅ Provenance advanced
```

You can see what your XID looks like after all that work:
```
envelope format $UPDATED_XID

| XID(5f1c3d9e) [
|     'dereferenceVia': URI(https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt)
|     'key': PublicKeys(21914050, SigningPublicKey(04c9adb6, Ed25519PublicKey(09f7c306)), EncapsulationPublicKey(1b076286, X25519PublicKey(1b076286))) [
|         {
|             'privateKey': ENCRYPTED [
|                 'hasSecret': EncryptedKey(Argon2id)
|             ]
|         } [
|             'salt': Salt
|         ]
|         'allow': 'Sign'
|         'nickname': "attestation-key"
|     ]
|     'key': PublicKeys(a9818011, SigningPublicKey(5f1c3d9e, Ed25519PublicKey(b2c16ea3)), EncapsulationPublicKey(96209c0f, X25519PublicKey(96209c0f))) [
|         {
|             'privateKey': ENCRYPTED [
|                 'hasSecret': EncryptedKey(Argon2id)
|             ]
|         } [
|             'salt': Salt
|         ]
|         'allow': 'All'
|         'nickname': "BRadvoc8"
|     ]
|     'provenance': ProvenanceMark(f6baa8c6) [
|         {
|             'provenanceGenerator': ENCRYPTED [
|                 'hasSecret': EncryptedKey(Argon2id)
|             ]
|         } [
|             'salt': Salt
|         ]
|     ]
| ]
```

### Step 4: Check Your Provenance Mark

You can again check your provenance mark by extracting it and using the `provenance` CLI:
```
UPDATED_PROV_MARK=$(envelope xid provenance get "$UPDATED_XID")
provenance validate --format json-compact "$UPDATED_PROV_MARK" 2>&1 | grep -o '"end_seq":[0-9]*'

│ "end_seq":1
```

The XID is now at sequence 1: genesis (seq 0) created the identity, this update (seq 1) added the attestation key.

You can also compare to the provenance mark for the unchanged XID.
```
PROV_MARK=$(envelope xid provenance get "$XID")
provenance validate --format json-compact "$PROV_MARK" 2>&1 | grep -o '"end_seq":[0-9]*'
```
By running these commands on each XID, a viewer can determine their precise sequence.

Finally, validating both provenance marks together verifies they're part of the same chain, and that there aren't other problems:
```
provenance validate $PROV_MARK $UPDATED_PROV_MARK

│ ✅ (silent success - part of the same chain)
```

### Step 5: Export & Save Your XID

Finally, you can follow the usual procedure to create a public version of the XID and store it.
```
UPDATED_PUBLIC_XID=$(envelope xid export --private elide --generator elide "$UPDATED_XID")

echo "✅ Public XID ready for publication"

│ ✅ Public XID ready for publication
```

Amira would publish this updated XID at her `dereferenceVia` URL so Ben can fetch it and verify her attestation signatures.

You'll store it alongside your previous iteration (with the genesis provenance mark):
```
echo "$UPDATED_PUBLIC_XID" > envelopes/BRadvoc8-xid-public-03.envelope
echo "$UPDATED_XID" > envelopes/BRadvoc8-xid-private-03.envelope
```

## Part III: Creating a Detached Attestation

With an attestation key in hand, and linked to your XID, you're now ready to create an attestation for Amira. But the question is whether to create an embedded attestation (which would be placed directly in Amira's XID) or a detached attestation (which would be available as a separate Gordian Envelope, but linked to Amira's XID by the use of the attestation signature key). 

It's best to embed attestations if they're relatively permanent, widely applicable, and core to the definition of the identity.

It's best to create detached attestations if they're ephemeral, if they're only relevant to specific people, and if they're not core to an identity.

This isn't a question of privacy: you can always choose to elide attestations that you don't want to receive wide attention, even if they're in your XID. It's instead a question of keeping the XID lean enough that someone can reasonably look over it without being lost in irrelevent details.

> :book: **What is a Detached Attestation?**: When an attestation is detached, it appears as a signed statement that exists as a separate envelope, referencing your XID but not embedded in your XIDDoc.

In this case, a single PR is a pretty small detail, and not necessarily something that Amira will be talking about in a year or two when she (hopefully) has major design work on SisterSpaces to point to. So you'll create it as a detached attestation.

### Step 6: Create the Claim

Start with the claim itself as the envelope subject. Freeform attestation of this type are created with the standard `envelope` commands rather than the more constrained `envelope xid` commands. That's because they're either going to be separate from a XID (a detached attestation) or they're going to be attached to a XID at a specific, defined point, such as `attachment` or `edge` (which we'll meet in future chapters). 

```
CLAIM=$(envelope subject type string \
  "Contributed mass spec visualization code to galaxyproject/galaxy (PR #12847, merged 2024)")

envelope format "$CLAIM"

│ "Contributed mass spec visualization code to galaxyproject/galaxy (PR #12847, merged 2024)"
```

This is just a string. It's not signed, not attributed, not structured. Anyone could create this string.

### Step 7: Add Attestation Metadata

Now add metadata that structures this as a formal attestation. F

```
ATTESTATION=$(envelope assertion add pred-obj known isA known 'attestation' "$CLAIM")
ATTESTATION=$(envelope assertion add pred-obj known source ur $XID_ID "$ATTESTATION")
ATTESTATION=$(envelope assertion add pred-obj known target ur $XID_ID "$ATTESTATION")
ATTESTATION=$(envelope assertion add pred-obj known 'verifiableAt' uri "https://github.com/galaxyproject/galaxy/pull/12847" "$ATTESTATION")
ATTESTATION=$(envelope assertion add pred-obj known 'date' string `date -Iminutes` "$ATTESTATION")
envelope format "$ATTESTATION"

"Contributed mass spec visualization code to galaxyproject/galaxy (PR #12847, merged 2024)" [
    'isA': 'attestation'
    'date': "2025-10-18T19:27-10:00"
    'source': XID(5f1c3d9e)
    'target': XID(5f1c3d9e)
    'verifiableAt': URI(https://github.com/galaxyproject/galaxy/pull/12847)
]
```

Each assertion within the claim is a standardize known value that reveals a specific piece of metadata:

| Assertion | Known Value | Value | Purpose |
|-----------|-----------|-------|---------|
| 1 | `'isA'` | `'attestation'` | Declares this is an attestation |
| 2 | `'date'` | ISO 8601 | Claims when claim was constructed |
| 2 | `'source'` | XID ID | Says who is making the claim |
| 3 | `'target'` | XID ID | Says who the claim is about |
| 4 | `"verifiableAt"` | URI | Points to evidence for independent verification |

> :warning: **Dates Are Unreliable!**  The date is actually another unverifiable claim: it could be set to whatever the attestation creator wanted to. Nonetheless, it has use because a good faith creator will date claims correctly, making it easy to which claims are newer in case of a superseding claim being issued.
  
### Step 8: Sign the Attestation

You're now ready to wrap the attestation and sign it with the private key that you created specifically for this purpose. The signature proves that the signer made this claim:

```
ATTESTATION_WRAPPED=$(envelope subject type wrapped $ATTESTATION)
ATTESTATION_SIGNED=$(envelope sign --signer "$ATTESTATION_PRVKEYS" "$ATTESTATION_WRAPPED")

envelope format "$ATTESTATION_SIGNED"

| {
|     "Contributed mass spec visualization code to galaxyproject/galaxy (PR #12847, merged 2024)" [
|         'isA': 'attestation'
|         'date': "2025-10-18T19:27-10:00"
|         'source': XID(5f1c3d9e)
|         'target': XID(5f1c3d9e)
|         'verifiableAt': URI(https://github.com/galaxyproject/galaxy/pull/12847)
|     ]
| } [
|     'signed': Signature(Ed25519)
| ]
```

The signature covers the entire attestation. If anyone modifies any part (the claim, the source, the target, ther verification location), the signature becomes invalid.

## Part IV: Ben Again Verifies

Switching once more to Ben's perspective, the updated XID now needs to be verified.

### Step 9: Ben Checks the Signature

Amira might send Ben her updated XID, leading him to dereference it, or she might cut out the middle man by just telling him she has a new version of her XID online with a claim. She also sends him the attestation.

```
BEN_FETCHED_XID="$UPDATED_PUBLIC_XID"
BEN_FETCHED_XID_ID=$(envelope xid id $BEN_FETCHED_XID)
```
Ben first needs to extract all of the pubkeys from BRadvoc8's XID using `xid key all`, as he doesn't know which was used for signing:
```
read -d '' -r -a PUBKEY <<< $(envelope xid key all "$BEN_FETCHED_XID")
```
This is somewhat arcane BASH-ing. If he preferred, he could just output `envelope xid key all` to his screen, and then copy each one to a variable by hand.

But by having them in an array, he can do a quick check to see if any of the signatures verified (throwing out failures, because they're totally OK: only one key needs to be matched):
```
for i in "${PUBKEY[@]}"
  do
    if envelope verify -v $i $ATTESTATION_SIGNED >/dev/null 2>&1; then
      echo "✅ One of the signatures verified! "
      echo $i
    fi
done
```
The result:
```
| ✅ One of the signatures verified! 
| ur:envelope/lrtpsotansgylftanshflfaohdcxuydpdtjntyecmogmvdeydyksttleeeeerdptrtjyzcmoaoimtokigreonltshnoltansgrhdcxjzptmodkhtsgzmkbdpdweesngdeeoxktwncfehmndegtamswplclpfbsptroaagaoycscstpsojlhsjyjyihjkjyhsjyinjljtdpjeihkkoycsfncsfdhdcxwewljefsbzmklsvasbgakpbdbkcfmohhynjzkksrtdhhsktkfepfbezmhlbsjlntessabskb
```

So now Ben knows the claim was signed by BRadvoc8's XID. But, this says nothing about whether the claim is accurate. Anyone can claim "I contributed to Galaxy Project." The signature proves you MADE the claim, not that you made the contribution. This distinction matters. Self attestations are starting points for building trust, not proof of competence. The `verifiableAt` field points to evidence that verifiers can check independently.

### Step 10: Ben Checks the Claim

Ben follows the `verifiableAt` URL to GitHub and verifies that PR #12847 exists, was merged, and adds mass spec visualization. He also sees that it was created by a GitHub account with the name of "BRadvoc8". This is all very suggestive and provides some verification for Amira's claim.

However, there is still a gap: Ben can't prove that BRadvoc8, the controller of the XID, is the same person as BRadvoc8, the owner of the GitHub account. If the XID could show proof of control of the GitHub again, that would almost entirely verify the claim. For now, Ben has a medium level of trust. If this claim were combined with other attestations and eventual peer endorsements, a picture of credibility could build over time.

> :brain: **Learn more**: The [Progressive Trust](../concepts/progressive-trust.md) concept doc explains how self-attestations combine with cross-verification and peer endorsements to build meaningful trust over time.

At this point, Ben can once more lay out what he knows:

| What Ben Can Verify | What Remains Unproven |
|---------------------|----------------------|
| ✅ BRadvoc8 made this claim | ❓ Claim is actually true |
| ✅ Claim wasn't modified (signature valid) | 
| ✅ Evidence URL exists | ❓ Quality of the contribution<br>❓ BRadvoc8 = PR author |
| ✅ Attestation date recorded | ❓ Date is actually corect |
| ✅ BRadvoc8 is more detailed |❓ Who BRadvoc8 is |

## Part V: Managing the Attestation Lifecycle

Attestations aren't permanent. Claims become stale, projects end, skills evolve. Amira's Galaxy Project contribution from 2024 is factual forever, but if she added more PRs over time, she might want that to be recorded in her attestation.

However, you cannever actually change an existing attestation: once a claim is signed, it's immutable. Instead, you have three possibilities: you can create new attestations, supersede attestations, or retract attestations.

| Situation | Approach |
|-----------|----------|
| Claim is still true | Create new attestation with more info |
| Claim is outdated | Create superseding attestation |
| Claim was wrong | Create retraction attestation |

Creating a totally new attestation follows the same procedure as above. Our suggested best practices for superseding involve creating totally new attestations that clearly denote their relationship to the previous ones.

### Step 11: Supersede an Attestation

Two years later, Amira's Galaxy Project work has expanded. This means the old claim is outdated, requiring a new one that supersedes it.

```
S_ATTESTATION=$(envelope subject type string \
  "Contributed mass spec visualization and data pipeline code to galaxyproject/galaxy (PRs #12847, #14201, #15892, 2024-2026)")
S_ATTESTATION=$(envelope assertion add pred-obj known isA known 'attestation' "$S_ATTESTATION")
S_ATTESTATION=$(envelope assertion add pred-obj known source ur $XID_ID "$S_ATTESTATION")
S_ATTESTATION=$(envelope assertion add pred-obj known target ur $XID_ID "$S_ATTESTATION")
S_ATTESTATION=$(envelope assertion add pred-obj known 'verifiableAt' uri "https://github.com/galaxyproject/galaxy/pulls?q=author:BRadvoc8" "$S_ATTESTATION")
S_ATTESTATION=$(envelope assertion add pred-obj known 'date' string `date -Iminutes` "$S_ATTESTATION")
```

It's also helpful to reference the original attestation being superseded, which can be done by referencing its digest (hash):
```
ORIGINAL_DIGEST=$(envelope digest "$ATTESTATION_SIGNED")
S_ATTESTATION=$(envelope assertion add pred-obj string "supersedes" digest "$ORIGINAL_DIGEST" "$S_ATTESTATION")
```

You would now wrap & sign the attestation as usual:
```
S_WRAPPED_ATTESTATION=$(envelope subject type wrapped $S_ATTESTATION)
S_SIGNED_ATTESTATION=$(envelope sign --signer "$ATTESTATION_PRVKEYS" "$S_WRAPPED_ATTESTATION")

echo "✅ Updated attestation (supersedes original):"
envelope format "$S_SIGNED_ATTESTATION" | head -12

| ✅ Updated attestation (supersedes original):
| {
|     "Contributed mass spec visualization and data pipeline code to galaxyproject/galaxy (PRs #12847, #14201, #15892, 2024-2026)" [
|         'isA': 'attestation'
|         "supersedes": Digest(40993e58)
|         'date': "2026-02-18T13:14-10:00"
|         'source': XID(5f1c3d9e)
|         'target': XID(5f1c3d9e)
|         'verifiableAt': URI(https://github.com/galaxyproject/galaxy/pulls?q=author:BRadvoc8)
|     ]
| } [
|     'signed': Signature(Ed25519)
| ]
```

> :book: **What is a Superseding Attestation**: A superseding attestation is a new attestation with a `supersedes` assertion that points to a previous attestation's digest. The original remains valid, but the newer attestation reflects the current state.

### Step 12: Retract an Attestation

If an attestation instead needed to be retracted, it would follow a pattern as follows:
```
RETRACTION=$(envelope subject type string "RETRACTED: [original claim text]")
RETRACTION=$(envelope assertion add pred-obj known isA string "retraction" "$RETRACTION")
RETRACTION=$(envelope assertion add pred-obj string "retracts" digest "$ORIGINAL_DIGEST" "$RETRACTION")
RETRACTION=$(envelope assertion add pred-obj string "reason" string "Claim was overstated" "$RETRACTION")
RETRACTION=$(envelope subject type wrapped "$RETRACTION")
RETRACTION=$(envelope sign --signer "$ATTESTATION_PRVKEYS" "$RETRACTION")
```
The result would look like this:
```
envelope format $RETRACTION

| {
|     "RETRACTED: [original claim text]" [
|         'isA': "retraction"
|         "reason": "Claim was overstated"
|         "retracts": Digest(40993e58)
|     ]
| } [
|     'signed': Signature(Ed25519)
| ]
```

Retractions are serious: they indicate an error in judgment. Use them sparingly. Most updates are supersessions (extending or refining), not retractions (correcting errors). Amira definteily won't be retracting anything at this point!

## Summary: The World of Attestations

This tutorial revealed a lot about claims, or attestations, including revealing many sorts:

* **Detached Attestation.** Creating an attestation separted from your XID, but linked by a signature.
* **Embedded Attestation.** Incorporating an attestation into a XID.
* **Endorsement.** Making a claim about someone else.
* **Fair Witness Attestation.** Reporting without interpretation or known bias.
* **Revoking Attestation.** Invalidating a prior attestation
* **Self Attestation.** Making a claim about yourself.
* **Superseding Attestation.** Updating a prior attestation.

This tutorial focused on a detached fair-witness self attestation. Embedded attestations and endorsements will follow in future tutorials.

Crucially, this tutorial also showed how to create a _validated attestation_: the Galaxy Project attestation isn't just a claim, it's a claim with a URL where anyone can check the actual code. But could it have been stronger? That's also a topic for the future.

### Exercises

**Building exercises (Amira's perspective):**

- Create a fair witness attestation for one of your own verifiable contributions (GitHub PR, package, blog post).
- Register a new dedicated attestation key in your XID.

**Verification exercises (Ben's perspective):**

- Given an attestation envelope, extract the `verifiableAt` URL and check if the evidence exists.
- Verify the signature using the attestation key from the XID.

**Analysis exercises:**

- Compare a fair witness claim to a vague claim about the same skill: what makes the fair witness version stronger?
- Identify 2-3 public contributions you could attest to with verifiable evidence.
  
## Appendix I: Key Terminology

> **Attestation Key**: A dedicated signing key for creating detached attestations, registered in your XID. Verified against the XID key list, not an external service.
>
> **Fair Witness Methodology**: Making only factual, specific, verifiable claims rather than opinions or vague assertions.

Also see the various attestation definitions in the **Summary**.

## What's Next

BRadvoc8 is not an identity with a first claim about skills, but that's opened a bit of a Pandora's box. The next three tutorials will seek to close it.

* **Tutorial 04: Managing Sensitive Claims with Elision** will discuss how claims can quickly become sensitive, and how elision can protect them.
* **Tutorial 05: Managing Sensitive Claims with Encrypt** will reveal encryption as an alternative form of protection.
* **Tutorial 06: Creating Edges** will finally address the problem of the GitHub account ownership and show how to attach claims directly to your XID.

**Previous**: [Making Your XID Verifiable](02-making-your-xid-verifiable.md) | **Next**: [Managing Sensitive Claims with Elision](04-managing-claims-elision.md)           

