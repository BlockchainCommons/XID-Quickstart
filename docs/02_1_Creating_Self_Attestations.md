# 2.1: Creating Self Attestations

This section demonstrates how to build credibility through specific,
factual claims that invite verification rather than demand belief.

> **🧠 Related Concepts.** After completing this tutorial, explore
[Progressive Trust](../concepts/progressive-trust.md) and
[Self-Attestation](../concepts/self-attestation.md) to deepen your
understanding.

## Objectives for this Section

After working through this section, a developer will be able to:

- Register attestation keys in a XID for signature verification
- Create attestations that are publicly verifiable.
- Advance a provenance mark.

Supporting objectives include the ability to:

- Understand how to use **fair witness methodology** to make credible claims
- Know the difference between **detached** and **embedded** attestations.

## Amira's Story: Claims Without Proof

Following Chapter 1, Ben has a verified copy of BRadvoc8's XID. But
it's just a collection of keys attached to a nickname. Can BRadvoc8
write good code, understand security, and deliver quality work? These
are the questions that Ben needs answered before he decides to bring
BRadvoc8 into the SisterSpace project.

To reveal more about her skill set, Amira must create attestations
about them. Since Amira is bootstrapping the BRadvoc8 identity on her
own, they need to be self-attestations: things that she says about
herself (or rather, about her identity) that reveal her
capabilities. The problem is that a vague claim like "Security expert
with 8 years experience" is worthless. Anyone can type that.

> :book: **What is a self attestation?**: As the name suggestion, a
self attestation is a claim that you make about yourself. It's
contrasted with an *endorsement*, where someone else vouches for
you. Self-attestations are starting points; endorsements carry more
weight because they come from independent parties.

Amira needs a different approach: specific claims that point to
verifiable evidence.

## The Power of Fair Witness Attestations

Not all attestations are created equal. Some are vague and hard to pin
down, while others are so specific that they can be proven with
appropriate references. Compare these two attestations:

| Claim | Quality | Support |
|-------|------|-----|
| "I'm good at security" | Weak | Opinion, nothing to check |
| "I contributed to Galaxy Project (PR #12847)" | Strong | Verifiable on GitHub |

The strong claim invites validation rather than demanding belief. For
pseudonymous contributors who can't flash a diploma, evidence-backed
attestations ARE your credentials.  When you are making
self-attestations, it is therefore best to both create attestations
that are verifiable and then provide the methodology for verifying.

["Fair witness claims"](../concepts/fair-witness.md) are a
particularly strong type of attestation. The person making the
attestation does their best to report without interpretation,
assumption, or bias (as best they can!).

> :book: **What is the Fair Witness Methodology?**: The Fair Witness
methodology is derived from Robert E. Heinlein's _Stranger in a
Strange Land_ (1961). A Fair Witness makes a claim of what they
directly observed, avoiding interpretation, assumption, or (as much as
possible) bias. If it's meaningful, a fair witness claim also should
include context describing the methodology of the observation, its
limitations, and any bias built into.

Saying someone was good at security would be an interpretation, so
that would fail the fair witness test, but instead reporting a
contribution is a simple statement of fact, as long as you don't adorn
it by saying something like, "I made a _crucial_ contribution to the
Galaxy Project."

> :fire: **What is the Power of Fair Witness Attestations?** Fair
witness attestations do their best to report without bias. This makes
them more verifiable, and verifiability is what's important in the
world of pseudonymous claims.

## Part I: Adding an Attestation Key

Amira contributed to Galaxy Project, an open source bioinformatics
platform. Her pull request added mass spectrometry visualization
features. This is the kind of specific, verifiable claim that builds
real credibility. You're going to build an attestation about that
claim, but first you need to create a secure way to make attestations.

### Step 0: Verify Dependencies & Reload XID

Before you get started, ensure you have the required tools installed:

```
envelope --version
provenance --version

│ bc-envelope-cli 0.34.1
│ provenance-mark-cli 0.7.0
```

If not installed, see
[§1.1](01_1_Your_First_XID.md#step-0-setting-up-your-workspace) for
installation instructions.

You'll also want to reload your XID. The following assumes use of the [`envelopes`](envelopes) directory that was described in the last tutorial.
```
XID=$(cat envelopes/BRadvoc8-xid-private-02.envelope)
XID_ID=$(envelope xid id $XID)
```

### Step 1: Create an Attestation Key

Every attestation, even a self-attestation should be signed. Viewers
have to know who is behind a claim and that the claim hasn't been
changed since that person agreed to it. You could sign attestations
with the signing key of your XID. However, that's your XID inception
key, and it's powerful: it can modify your identity. Using it for
routine signing increases exposure risk. For that reason, you want to
create new attestation keys that can be rotated or revoked without
affecting your core identity.

```
ATTESTATION_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
ATTESTATION_PUBKEYS=$(envelope generate pubkeys "$ATTESTATION_PRVKEYS")
```

> :book: **What are Attestation Keys?**: Attestation keys are
  dedicated signing key for making attestations.

### Step 2: Register Attestation Key in XID

For Ben to verify attestations came from BRadvoc8, the attestation public key must be in the XID. You also should embed the private key (encrypted) so that Amira can sign attestations without managing separate key files. This is done with the `xid key add` command, which is very similar yo the `xid resolution add` function that you used in the last tutorial.

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

echo "✅ Added attestation key to XID"
```

The `envelope-cli` programs derives the public key from the private key automatically. With the `--private encrypt`, `--password`, and `--encrypt-password` commands, the private XID is first decrypted, then re-encrypted. You also add a new `nickname` to clarify what the key is for, and tthen here's one new argument:

1. `--allow sign` is a permission statement indicates this key can only sign, it cannot modify the XID itself. (That requires the inception key.)

> :warning: **XID Functions Only!** If you're familiar with Gordian Envelope, you'll know that you can freely add assertions to an envelope. Though XID is built on envelope, it's intended to be a much more structured format, with all content always in carefully structured places such as `derferenceVia`, `key`, `provenance`, and other subjects that you'll meet in future tutorials. You should always expect to use `envelope xid` commands when working with the core XID structure (though you may place less structured content under certain key words, such as in the `edge` that we'll meet in the Tutorial 06).

### Step 3: Advance Your Provenance Mark

You're going to need to publish this XID so that Ben can check Amira's self-attestation against her new signature. Whenever you publish a new edition of a XID (meaning that you've changed the underlying content, not just changing the view by eliding existing data differently), you should also advance the provenance mark. This will allow viewers who have multiple copies of a XID to determine which one is newest.

Advancing the provenance mark is done with the simple `provenance next` command, which as usual must decrypt and reencrypt your content:
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

### Step 4: Export & Save Your XID

Afterward, you should follow the usual procedure to create a public version of the XID and store it.
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
You should also store standalone copies of your new keys to make it easier to access them in the future:
```
echo $ATTESTATION_PRVKEYS > envelopes/attestation-private-03.ur
echo $ATTESTATION_PUBKEYS > envelopes/attestation-public-03.ur
``` 

### Step 5: Review Your Work

You now have multiple keys and multiple XIDs for Amira. Here's a look
at each of them.

#### Key Type Comparison

It is a best practice to have different keys for different
purposes. This improves privacy and decreases the repercussions of key
loss or compromise. The traditional problem with this approach has
been figuring out how to handle a "bag of keys." XIDs offer the
answer: they can be used to manage a whole set of keys, and the keys
can be encrypted with a password for protection on your own storage
and elided for near-total protection when a XID is shared.

So far, Amira has two keys:

| Key Type | Purpose | Verified Against | Added In |
|----------|---------|------------------|----------|
| 👤 XID inception key | Signs XID document updates | XID itself | §1.1 |
| 🔑 Attestation key | Signs attestations | XID key list | §2.1 |


#### XID Version Comparison

Here's a look at our two XID versions created to date:

| XID Version | New Content | Created In |
| seq 0 | 👤 Identity | §1.1+§1.2 |
| seq 1 | 🔑 Attestation Key | §2.1 |

## Part II: Creating a Detached Attestation

With an attestation key in hand, and linked to Amira's XID, you're now ready to create an attestation for Amira. But the question is whether to create an embedded attestation (which would be placed directly in Amira's XID) or a detached attestation (which would be available as a separate Gordian Envelope but linked to Amira's XID by the use of the attestation signature key). 

* It's best to **embed** attestations if they're relatively permanent, widely applicable, and core to the definition of the identity.
* It's best to create **detached** attestations if they're ephemeral, if they're only relevant to specific people and if they're not core to an identity.

This isn't a question of privacy: you can always choose to elide and encrypt attestations that you don't want to receive wide attention, even if they're in your XID. (In fact that's the topic of the next two tutorials.) It's instead a question of keeping the XID lean enough that someone can reasonably look over it without being lost in irrelevent details.

> :book: **What is a Detached Attestation?**: When an attestation is detached, it appears as a signed statement that exists as a separate envelope, referencing your XID but not embedded in your XIDDoc.

In this case, a single PR is a pretty small detail, and not necessarily something that Amira will be talking about in a year or two when she (hopefully) has major design work on SisterSpaces to point to. So you'll create it as a detached attestation.

### Step 6: Create the Claim

Start with the claim itself as the envelope subject. Freeform attestation of this type are created with the standard `envelope` commands rather than the more constrained `envelope xid` commands. That's because they're either going to be separate from a XID (as a detached attestation) or they're going to be attached to a XID at a specific, defined point, such as `attachment` or `edge` (which we'll meet in chapter 3).

```
CLAIM=$(envelope subject type string \
  "Contributed mass spec visualization code to galaxyproject/galaxy (PR #12847, merged 2024)")

envelope format "$CLAIM"

│ "Contributed mass spec visualization code to galaxyproject/galaxy (PR #12847, merged 2024)"
```

This is just a string. It's not signed, attributed, or structured. Anyone could create this string.

### Step 7: Add Attestation Metadata

Now add metadata that structures this as a formal attestation.

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

Each assertion within the claim is a standardized known value that reveals a specific piece of metadata:

| Assertion | Known Value | Value | Purpose |
|-----------|-----------|-------|---------|
| 1 | `'isA'` | `'attestation'` | Declares this is an attestation |
| 2 | `'date'` | ISO 8601 | Claims when attestation was constructed |
| 3 | `'source'` | XID ID | Says who is making the attestation |
| 4 | `'target'` | XID ID | Says who the attestation is about |
| 5 | `"verifiableAt"` | URI | Points to evidence for independent verification |

> :warning: **Dates are Unreliable!**  The date is actually another unverifiable claim: it could be set to whatever the attestation creator wants to. Nonetheless, it has use because a good faith creator will date claims correctly, making it see easy to which claims are newer in case of a superseding claim being issued.
  
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

The signature covers the entire attestation. If anyone modifies any part (the claim, the source, the target, the date, the verification location), the signature becomes invalid.

## Part III: Verifying a New Claim

Switching once more to Ben's perspective, the updated XID and the claim now need to be verified

### Step 9: Check the New XID

Amira might send Ben her updated XID, leading him to dereference it, or she might cut out the middle man by just telling him she has a new version of her XID online with a claim. She also sends him the attestation.

```
BEN_FETCHED_XID="$UPDATED_PUBLIC_XID" # Actually, he downloads it
```

At this point, Ben would check the XID to make sure that it has
continuity with the previous version. One way to do so is to check
that it's still signed with the same private key as before. Ben uses
the same process as in th eprevious chapter to do so and know that
that BRadvoc8 has likely created the new XID.

### Step 10: Check the New Provenance Mark

Ben can also look at the updated provenance mark, and this is where things get more interesting:
```
UPDATED_PROV_MARK=$(envelope xid provenance get "$BEN_FETCHED_XID")
provenance validate --format json-compact "$UPDATED_PROV_MARK" 2>&1 | grep -o '"end_seq":[0-9]*'

│ "end_seq":1
```

The XID's provenance mark is now at sequence 1: genesis (seq 0)
created the identity and this update (seq 1) added the attestation
key.

If Ben still has a copy of the original XID around, he can comparethat one's provenance mark:
```
PROV_MARK=$(envelope xid provenance get "$XID")
provenance validate --format json-compact "$PROV_MARK" 2>&1 | grep -o '"end_seq":[0-9]*'

| "end_seq":0
```
He now knows that the XID he most recently received has a higher
sequence number than the previous one, which means that it's newer
... as long as their part of the same provenance mark chain.

He can prove that last fact by validating both provenance marks together:
```
provenance validate $PROV_MARK $UPDATED_PROV_MARK

│ ✅ (silent success - part of the same chain)
```
He now knows that they're both part of the same chain and there are no
other problems.

### Step 11: Check the Claim's Signature

The XID has been validated but what about the claim? Is it really
related to Amira's XID? To determine that, Ben first needs to extract
all of the pubkeys from BRadvoc8's XID using `xid key all`, as he
doesn't know which was used for signing:

```
read -d '' -r -a PUBKEY <<< $(envelope xid key all "$BEN_FETCHED_XID")
```

This is somewhat arcane BASH-ing. If he preferred, Ben could just output `envelope xid key all` to his screen, and then copy each one to a variable by hand and check each of those by hand  with `envelope verify -v`.

But by having them in an array, Ben can do a quick check to see if any of the signatures verified (tossing out failures, because they're totally OK: only one key needs to be matched):
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

Now Ben knows that the claim was signed by BRadvoc8's XID. But, this
says nothing about whether the claim is accurate. Anyone can claim "I
contributed to Galaxy Project." The signature proves you MADE the
claim, not that you made the contribution. This distinction
matters. Self attestations are starting points for building trust, not
proof of competence. The `verifiableAt` field points to evidence that
verifiers can check independently.

### Step 12: Ben Checks the Claim

Ben follows the `verifiableAt` URL to GitHub and verifies that PR #12847 exists, was merged, and adds mass spec visualization. He also sees that it was created by a GitHub account with the name of "BRadvoc8". This is all very suggestive and provides some verification for Amira's claim.

However, there is still a gap: Ben can't prove that BRadvoc8, the controller of the XID, is the same person as BRadvoc8, the owner of the GitHub account. If the XID could show proof of control of the GitHub again, that would almost entirely verify the claim. We'll get back to that in [Tutorial 06](06-creating-edges.md). For now, Ben has a medium level of trust. If this claim were combined with other attestations and eventual peer endorsements, a picture of credibility could build over time.

> :brain: **Learn more**: The [Progressive Trust](../concepts/progressive-trust.md) concept doc explains how self-attestations combine with cross-verification and peer endorsements to build meaningful trust over time.

### Step 13: Assess Your Level of Trust

At this point, Ben can once more lay out what he knows:

| What Ben Can Verify | What Remains Unproven |
|---------------------|----------------------|
| ✅ BRadvoc8 made this claim<br>✅ Claim wasn't modified (signature valid) | ❓ Claim is actually true |
| ✅ Attestation date recorded | ❓ Date is actually corect |
| ✅ Evidence URL exists | ❓ BRadvoc8 is PR author<br❓ Quality of the contribution |
| ✅ BRadvoc8 is more detailed |❓ Who BRadvoc8 is |

## Part V: Managing the Attestation Lifecycle

Attestations aren't permanent. Claims become stale, projects end, and
ultimately skills evolve. Amira's Galaxy Project contribution from
2024 is factual forever, but if she added more PRs over time, she
might want that to be recorded in her attestation. However, you can
never actually change an existing attestation: once a claim is signed,
it's immutable. Instead, you have three possibilities: you can create
new attestations, supersede attestations, or retract attestations.

| Situation | Approach |
|-----------|----------|
| Claim is still true | Create new attestation on related topic |
| Claim is outdated | Create superseding attestation |
| Claim was wrong | Create retraction attestation |

Creating a totally new attestation follows the same procedure as above. Our suggested best practices for superseding and revoking involve creating totally new attestations that clearly denote their relationship to the previous ones.

### Step 14: Supersede an Attestation

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

But you don't want to just create a new attestation that expands on the first, you want to also reference the original attestation being superseded, which can be done by referencing its digest (hash):
```
ORIGINAL_DIGEST=$(envelope digest "$ATTESTATION_SIGNED")
S_ATTESTATION=$(envelope assertion add pred-obj string "supersedes" digest "$ORIGINAL_DIGEST" "$S_ATTESTATION")
```

This ensures that viewers can understand the relationship between the two attestation.

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

> :book: **What is a Superseding Attestation?**: A superseding attestation is a new attestation with a `supersedes` assertion that points to a previous attestation's digest. The original remains valid, but the newer attestation reflects the current state.

### Step 15: Retract an Attestation

If an attestation instead needed to be retracted, our best practive suggests a pattern as follows:
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

> :book: **What is a Retracting Attestation?**: A superseding attestation is a Gordian Envelope that references a previous attestation and states both that it's been retracted and why.

## Summary: The World of Attestations

This tutorial talked a lot about claims, or attestations, including revealing many sorts:

* **Detached Attestation.** Creating an attestation separted from your XID, but linked by a signature.
* **Embedded Attestation.** Incorporating an attestation into a XID.
* **Endorsement.** Making a claim about someone else.
* **Fair Witness Attestation.** Reporting without interpretation or known bias.
* **Retracting Attestation.** Invalidating a prior attestation
* **Self Attestation.** Making a claim about yourself.
* **Superseding Attestation.** Updating a prior attestation.

This tutorial focused on a detached fair-witness self attestation. Embedded attestations and endorsements will follow starting in [Tutorial 06](06-creating-edges.md).

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

## What's Next

BRadvoc8 is now an identity with an initial claim about skills, but that's opened a bit of a Pandora's box. The next two tutorials will seek to close by showing how to elide sensitive claims in [§2.2: Managing Sensitive Claims with Elision](02_2_Managing_Claims_Elision.md) and [§2.3: Managing Sensitive Claims with Encryption](02_3_Managing_Claims_Encryption.md).

### Example Script

A complete working script implementing this tutorial is available at `../tests/03-creating-self-attestations.sh`.

--

## Appendix I: Key Terminology

> **Attestation Key**: A dedicated signing key for creating detached attestations, registered in your XID. Verified against the XID key list, not an external service.
>
> **Fair Witness Methodology**: Making only factual, specific, verifiable claims rather than opinions or vague assertions.

Also see the various attestation definitions in the **Summary**.
