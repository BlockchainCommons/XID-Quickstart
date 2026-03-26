# 4.2: Publishing for Privacy

Amira and Ben have a contract that ensures that SisterSpaces will
always be able to use Amira's work. Maybe they're comfortable
publishing that full contract, but maybe they prefer to keep details
to themselves, to maximize the privacy and protection of both
parties. This section explains how they could do so.

> 🧠 **Related Concepts.** After completing this tutorial, explore
[Data Minimization](../concepts/data-minimization.md) and [Elision
Cryptography](../concepts/elision-cryptography.md).

## Objectives of this Section

After working through this section, a developer will be able to:

- Store hashed records of a contract as a commitment.
- Create herd privacy through the publication of numerous hashes.

Supporting objectives include the ability to:

- Understand what a commitment means,
- Understand what herd privacy is.

## Amira's Story: Preserving Privacy

Amira has signed a CLA to allow her work to be used in SisterSpaces'
SecureAuth Library. Most open-source repositories would publish CLAs
like that as part of their repos. But Ben is very aware of privacy
concerns, as many of the women who use his services come from abusive
backgrounds. He extends that to the people working with him.

Because she is standing behind her BRadvoc8 identity, Amira doesn't
have the same concerns as those people working with SisterSpaces
without the benefit of a pseudonymous agreement. In fact, she's eager
to reveal her connection to them to improve the trust for her
identity. But that doesn't mean she wants everyone to know the entire
contents of the contract she signed, or at the least doesn't want the
whole huge text incorporated into her XID.

How can licensing rights be ensured without endangering any of the
participants? The answer is commitments.

## The Power of Commitments

We've seen commitments previously, in
[§2.2](02_2_Managing_Claims_Elision.md). Their use there was simple:
we created a claim; we elided that claim; and then we used the hash of
the claim as proof that the claim existed (and had existed for some
period of time).

At the time we said that the commitment _could_ be published, but we
didn't really say how. This chapter explores that more:

To start with, we offer two major methods to create a commitment:
`shasum` a plain file (which we saw in
[§4.1](04_1_Creating_Binding_Agreements.md)) and `digest` an envelope
(which we use here).

| Hashing Method | App | Section |
|----------------|-----|---------|
| SHASum a File | `shasum` | §4.1 |
| Digest an Envelope | `envelope` | §4.2 |

Each of these digests can also be published in a variety of ways. Ben
incorporated a `shasum` into an envelope in the last section. Here
we're going to see a `digest` incorporated into an envelope and also
discuss how digests can be published in plain (`.md`) files.

| Publication Method | Section |
|--------------------|---------|
| Incorporate into a XID | §4.1, §4.2 |
| In a File | §4.2 |
| As a Long List | §4.2 |

## The Power of Herd Privacy

As noted above, one of the methods of publishing commitments is as
part of a long list. Doing so can create herd privacy. When a long
list of commitments is created, each one blends in with the others. An
observer simply sees a long list of commitments: they can't easily
determine which one belongs to the human rights worker, which to a
student, and which to a retiree. The crowd provides cover.

| Contributors | Observer's Challenge |
|--------------|---------------------|
| 1 | Trivial to identify |
| 10 | Difficult to identify |
| 50 | Needle in haystack |
| 500 | Effectively anonymous |

Even if an attacker discovered a flaw in the methodology that Ben uses
to make commitments, they wouldn't know which hash to try and attack
to prove that BRadvoc8 (or anyone else) is involved. The specifics are lost among the crowd.

## Part 0: Verify Dependencies

Before you get started, you should (as usual) check your `envelope-cli` version:
```
envelope --version

│ bc-envelope-cli 0.34.1
```

Then, reload your XID. We're also going to be using Amira's
attestation key to create a new edge about her work with SisterSpaces,
which will also depend on the CLA she signed.


```
XID=$(cat envelopes/BRadvoc8-xid-private-3-03.envelope)
XID_ID=$(envelope xid id $XID)
PASSWORD="your-password-from-previous-tutorials"
ATTESTATION_PRVKEYS=$(cat envelopes/key-attestation-private-2-01.ur)
CLA=$(cat envelopes/cla-bradvoc8-accepted-4-01.envelope)
```

## Part I: Incorporating a Contract into a XID

Amira is thrilled to talk about her work with SisterSpaces. That's
because Ben's signature on Amira's contract is another step forward in
the progressive trust of BRadvoc8 as a reliable security expert.

On the other hand, she does have some privacy concerns. She knows that
Ben only releases the full CLAs if they're legally necessary to prove
ownership of SisterSpaces code. She wants to respect his privacy and
also doesn't want to clutter up in XID with the full contract.

A commitment of the contract offers a compromise that will meet her
needs to show off the connection but still protect Ben's privacy and
her own XID's accessability.

### Step 1: Create a Contract Edge

To record the contract, Amira will create a new self-attestation edge that
she is working on SisterSpaces.

As with any other edge, she first needs to define the three core elements of the edge: `isA`, `source`, and `target`:
```
ISA="foaf:Project"
SOURCE_XID_ID=$XID_ID
TARGET_XID_ID=$XID_ID
```

To create the commitment of the contract she will use a similar methodology to that of [§2.2](02_2_Managing_Claims_Elision.md).

```
DIGEST_CLA=$(envelope digest "$SIGNED_ACCEPTED_CLA")
```

There, we elided the envelope, leaving only the digest. Here, we're
instead going to incorporate the digest into this claim. If anyone
asks for more info they can ask BRadvoc8 for the full contract, and
she can decide whether it's appropriate to give it out.

The commitment to the conract, as with the rest of the details of the
claim, are placed as a target subenvelope:

```
PROJECT_TARGET=$(envelope subject type ur $TARGET_XID_ID)
PROJECT_TARGET=$(envelope assertion add pred-obj string $ISA string "SisterSpaces" "$PROJECT_TARGET")
PROJECT_TARGET=$(envelope assertion add pred-obj known verifiableAt string "https://github.com/SisterSpaces/SecureAuth/CLAs/" "$PROJECT_TARGET")
PROJECT_TARGET=$(envelope assertion add pred-obj string "claDigest" digest "$DIGEST_CLA" "$PROJECT_TARGET")
```

With those details, you can now put together the contract edge:

```
EDGE=$(envelope subject type string "project-sister-spaces-secureauth")
EDGE=$(envelope assertion add pred-obj known isA string "$ISA" "$EDGE")
EDGE=$(envelope assertion add pred-obj known source ur "$SOURCE_XID_ID" "$EDGE")
EDGE=$(envelope assertion add pred-obj known target envelope "$PROJECT_TARGET" "$EDGE")

echo "SisterSpaces edge details:"
envelope format "$EDGE"

| SisterSpaces edge details:
| 
| "project-sister-spaces-secureauth" [
|     'isA': "foaf:Project"
|     'source': XID(5f1c3d9e)
|     'target': XID(5f1c3d9e) [
|         "claDigest": Digest(0ecac6b7)
|         "foaf:Project": "SisterSpaces"
|         'verifiableAt': "https://github.com/SisterSpaces/SecureAuth/CLAs/"
|     ]
| ]
```

This is a relatively simple edge, but that's because the CLA commitment stands in for the entire CLA!

### Step 2: Publish Your Contract Edge

You can now take the several steps to attach this edge and publish the result.

First, incorporate the edge:
```
WRAPPED_EDGE=$(envelope subject type wrapped "$EDGE")
SIGNED_EDGE=$(envelope sign --signer "$ATTESTATION_PRVKEYS" "$WRAPPED_EDGE")

XID_WITH_CONTRACT_EDGE=$(envelope xid edge add \
    --verify inception \
    $SIGNED_EDGE $XID_WITH_CONTRACT_KEY)
```

Second, advance the provenance mark and produce a public version
```
XID_WITH_CONTRACT_EDGE=$(envelope xid provenance next \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$XID_WITH_CONTRACT_EDGE")
PUBLIC_XID_WITH_CONTRACT_EDGE=$(envelope xid export --private elide --generator elide "$XID_WITH_CONTRACT_EDGE")
```
Third, store everything:

```
echo "$PUBLIC_XID_WITH_CONTRACT_EDGE" > envelopes/BRadvoc8-xid-public-4-02.envelope
echo "$XID_WITH_CONTRACT_EDGE" > envelopes/BRadvoc8-xid-private-4-02.envelope
```
You've now demonstrated how Amira highlights her new connection to SisterSpaces while preserving privacy, but that's just half the story.

#### XID Version Comparison

You've now created a sixth XID edition of Amira's XID.  Here's another overview of what
each version contains

| XID Version | New Content | Created In |
|-------------|-------------|------------|
| seq 0 | 👤 Identity | §1.2+§1.3 |
| seq 1 | 🔑 Attestation Key | §2.1 |
| seq 2 | 🗣️ GitHub Edge | §3.1 |
| seq 3 | 🗣️ Endorsement Edge | §3.3 |
| seq 4 | 🔑 Contract Key | §4.1 |
| seq 5 | 📄 Contract Commitment | §4.2 |

## Part II: Incorporating a Contract into a Commitment List

Ben also needs to publish the CLA, to show everyone that his software
is safe to use, because he has contracts with all the authors. But,
Ben has 50 different people who have worked on SisterSpaces (and
signed CLAs). He doesn't want all of that in his XID (or even in a XID
he created for SisterSpaces). Nor does he want to just publish those
CLAs separately, because of the privacy concerns.

His answer: a commitment list

### Step 3: Computer a Digest

[TBD]

### Step 4: Publish a Commitment List

[TBD]

### Step 5: Check a Commitment

[TBD]

## Summary: XXX

...

### Additional Files

**Envelopes:** The
[envelopes](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/envelopes)
directory contains numerous data created in this section, the most
important of which are Amira's sixth
[private](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/envelopes/BRadvoc8-xid-private-4-02.envelope)
and
[public](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/envelopes/BRadvoc8-xid-public-4-02.envelope)
XIDs as well as the

... Ben's list ...

**Scripts:** Scripts demonstrating this section are forthcoming.

### Exercises

...

## What's Next

Though we've completed Amira's first arc, there's one open question: has
her XID gotten too big? [§4.3: Creating Views and
Viewsion](04_3_Creating_Views_and_Versions.md) talks about how to
clean it up.

## Appendix I: Key Terminology

> **Commitment List**:

> **Herd Privacy**:
