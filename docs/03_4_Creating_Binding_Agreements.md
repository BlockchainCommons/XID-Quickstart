# 3.4: Creating Binding Agreements

In order to contribute to a project, open-source developers should
sign binding agreements allowing use of their code.  This is the
culmination of an identity journey from pseudonymous phantom to
trusted contributor.

> 🧠 **Related Concepts.** After completing this tutorial, explore
[Progressive Trust](../concepts/progressive-trust.md).

## Objectives of this Section

After working through this section, a developer will be able to:

- Create contract-signing keys with limited permissions.
- Create a verification workflow for accepting contributions.
- Store hashed records of a contract as a commitment.

Supporting objectives include the ability to:

- Understand what a CLA is.
- Know the structure of a pseudonymous CLA.
- Understand why CLAs require a different approach than attestations.

## Amira's Story: Giving Permission

Amira has made a minor contribution to a project for
SisterSpaces. DevReviewer likes the PR and just as importantly is
convinced now that BRadvoc8 is someone with the right credentials to
do positive work on the project in a bigger role.

DevReviewer tells Ben that he needs to paper BRadvoc8's contributions
with a Contributor License Agreement, or CLA, so that SisterSpaces has
clear right to the code. Afterward, they'll be able to merge Amira's
work.

Amira will support this by pseudonymously (but legally) signing the
CLA, then both parties will record it.

## The Power of CLAs

The Web of Trust is all about edges: who interacts with whom in what way. To date, we've investigated unilateral edges: you say something about yourself ↩️ or you say something about someone else ➡️️. A CLA offers a third model for Web of Trust interaction: you and someone else make an agreement ↔️.

| Type | Who Signs | Obligations |
|------|-----------|-------------|
| ↩️  Self-attestation | You | One-way claim about yourself |
| ➡️ Peer endorsement | Someone else | One-way claim about someone else |
| ↔️. CLA | Both parties | Bilateral agreement between two parties |

The bilateral nature of contracts such as CLAs requires more careful
handling.

> 📖 **What is a Contributor License Agreement (CLA)?** A CLA is a
bilateral contract where contributors grant projects license to use
their contributions under open source terms. Unlike attestations
(one-way claims), CLAs create mutual obligations.

### What a CLA Typically Grants

A CLA usually contains the following terms:

| Provision | What It Means |
|-----------|---------------|
| Authority representation | You have the legal right to grant these licenses |
| Copyright license | You grant perpetual, worldwide, non-exclusive license to use your contributions |
| Patent license | You grant license to any patented technology in your contributions |
| Original work representation | Your contributions are original (or properly attributed) |

Amira reads these terms carefully. She understands what she's agreeing to before signing.

## Part 0: Verify Dependencies

Before you get started, you should (as usual) check your `envelope-cli` version:
```
envelope --version

│ bc-envelope-cli 0.34.1
```

Then, reload your XID.
```
XID=$(cat envelopes/BRadvoc8-xid-private-3-03.envelope)
XID_ID=$(envelope xid id $XID)
PASSWORD="your-password-from-previous-tutorials"
ATTESTATION_PRVKEYS=$(cat envelopes/key-attestation-private-2-01.ur)
```

## Part I: Preparing for a CLA

Key heterogeneity remains a best practice. As a result, if Amira is
going to sign contracts, she should do so with a specific contract
signing key. This follows the same methodology as creating an
attestation key in
[§2.1](02_1_Creating_Self_Attestations/#part-i-adding-an-attestation-key).

### Step 1: Create a Purpose-Specific Contract Key

For signing contracts, Amira creates a key with limited
permissions. This follows the principle of least authority: her
identity key can do anything, but her contract key can only sign.

```
# Generate contract-signing keys
CONTRACT_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
CONTRACT_PUBKEYS=$(envelope generate pubkeys "$CONTRACT_PRVKEYS")

echo "✅ Contract-signing key created (limited to signing only)"

│ ✅ Contract-signing key created (limited to signing only)
```

As we wrote previously: creating separate keys for separate purposes
limited the exposure if any key is compromise. Though it might usually
be difficult to manage a "bag of keys," XIDs make it easy because you
can register your keys there.

### Step 2: Register Contract Key in XID

```
XID_WITH_CONTRACT_KEY=$(envelope xid key add \
    --verify inception \
    --nickname "contract-key" \
    --allow sign \
    --private encrypt \
    --encrypt-password "$PASSWORD" \
    "$CONTRACT_PRVKEYS" \
    "$XID")

echo "✅ Added attestation key to XID"
```

#### Key Type Comparison

This of course expands the set of keys that Amira has in use

| Key Type | Purpose | Verified Against | Added In |
|----------|---------|------------------|----------|
| 👤 XID inception key | Signs XID document updates | XID itself | §1.2 |
| 🗣️  Attestation key | Signs attestations | XID key list | §2.1 |
| 🖋️  SSH signing key | Signs Git commits | GitHub account | §3.1 |
| 📄️  Contract signing key | Signs contracts | XID key list | §3.4 |

### Step 3: Publish New XID

We're going to produce two versions of Amira's XID over the course of
this section: one with her new contract key and one with a commitment
about her CLA. Though we could short-hand and just produce one at the
end, this is how it work work in the real-world: Amira would release a
new edition of her XID with her new key, sign something with that key,
and then only incorporate the later content into her XID (if she
decided to).

The three steps of publishing a XID have gotten pretty standard:

1. Advance the provenance mark & sign the full XID.

```
XID_WITH_CONTRACT_KEY=$(envelope xid provenance next \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$XID_WITH_CONTRACT_KEY")
echo "✅ Provenance advanced"

| ✅ Provenance advanced
```

2. Create a public view.

```
PUBLIC_XID_WITH_CONTRACT_KEY=$(envelope xid export --private elide --generator elide "$XID_WITH_CONTRACT_KEY")
```

3. Store local copies.

```
echo "$PUBLIC_XID_WITH_CONTRACT_KEY" > envelopes/BRadvoc8-xid-public-3-04a.envelope
echo "$XID_WITH_CONTRACT_KEY" > envelopes/BRadvoc8-xid-private-3-04a.envelope
echo "$CONTRACT_PRVKEYS" > envelopes/key-contract-private-3-04.ur
echo "$CONTRACT_PUBKEYS" > envelopes/key-contract-public-3-04.ur
```

## Part II: Preparing a CLA

Meanwhile, Ben is preparing the CLA itself. 

### Step 4: Create Ben's Identity

Obviously, Ben has a XID like everyone else. Much as with Charlene's
XID in §3.3, we're going to short-hand its creation. In real-life, Ben
would have a much more complex XID, and using best practices, he'd
have a contract-signing key, just like Amira does. But, we're going to
keep things simple and just create and use a single inception key.

```
BEN_PASSWORD="bens-own-password"
BEN_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
BEN_PUBKEYS=$(envelope generate pubkeys "$BEN_PRVKEYS")
BEN_XID=$(echo $BEN_PRVKEYS | \
    envelope xid new \
    --private encrypt \
    --encrypt-password "$BEN_PASSWORD" \
    --nickname "Ben (SisterSpaces)" \
    --generator encrypt \
    --sign inception)
BEN_XID_ID=$(envelope xid id "$BEN_XID")

echo "✅ Ben's XID created: $BEN_XID_ID"
```

You should of course save a copy of this:

```
echo "$BEN_XID" > envelopes/Ben-xid-private-3-04.envelope
```

### Step 5: Create the CLA Document

Though CLAs today are often signed as text files with GPG, Gordian
Envelope offers better integration of the whole signing process, which
is why Ben uses it. 

Ben's projects uses a standard Individual CLA, which he generates from
a shell script for each individual contributor. It's based on the
Apache 2.0 license. Ben keeps a local copy of the license and has also
created a hash of it.
```
curl -q https://www.apache.org/licenses/LICENSE-2.0.txt > envelopes/license-apache-3-04.txt
shasum -a 256 envelopes/license-apache-3-04.txt > envelopes/license-apache-3-04-hash.txt
```

Ben's CLA includes a subenvelope with a clear definition of a
license. (Remember, envelopes are usually built from the inside out.)

```
read hash filename < envelopes/license-apache-3-04-hash.txt 
LICENSE=$(envelope subject type string "Apache-2.0")
LICENSE=$(envelope assertion add pred-obj known 'dereferenceVia' string "https://www.apache.org/licenses/LICENSE-2.0.txt" $LICENSE)
LICENSE=$(envelope assertion add pred-obj known 'date' string "2004-01-00T00:00-00:00" $LICENSE)
LICENSE=$(envelope assertion add pred-obj string 'contractHash' string $hash $LICENSE)
```

He also creates subenvelopes to provide details on both himself and BRadvoc8:

```
PM=$(envelope subject type ur $BEN_XID_ID)
PM=$(envelope assertion add pred-obj known 'nickname' string "Ben (SisterSpaces)" $PM)
CONTRIBUTOR=$(envelope subject type ur $XID_ID)
CONTRIBUTOR=$(envelope assertion add pred-obj known 'nickname' string "BRadvoc8" $CONTRIBUTOR)
```

The CLA itself defines one of the modules for SisterSpaces:

```
CLA=$(envelope subject type string "Individual Contributor License Agreement")
CLA=$(envelope assertion add pred-obj string "project" string "SisterSpaces SecureAuth Library" "$CLA")
```

It includes the grants and represtations typical for a CLA:
```
CLA=$(envelope assertion add pred-obj known isA string "ContributorLicenseAgreement" "$CLA")
CLA=$(envelope assertion add pred-obj string "grantsCopyrightLicense" string "perpetual, worldwide, non-exclusive, royalty-free" "$CLA")
CLA=$(envelope assertion add pred-obj string "grantsPatentLicense" string "for contributions containing patentable technology" "$CLA")
CLA=$(envelope assertion add pred-obj string "contributorRepresents" string "original work with authority to grant license" "$CLA")
```

It also incorporates the subenvelopes that Ben's script creates:
```
CLA=$(envelope assertion add pred-obj string "licenseType" envelope "$LICENSE" "$CLA")
CLA=$(envelope assertion add pred-obj string "projectManager" envelope "$PM" "$CLA")
CLA=$(envelope assertion add pred-obj string "contributor" envelope "$CONTRIBUTOR" "$CLA")
```

Finally, to prepare it for signing, Ben always wraps the envelope:
```
echo "✅ CLA document created:"
envelope format "$CLA"

| ✅ CLA document created:
|
| "Individual Contributor License Agreement" [
|     'isA': "ContributorLicenseAgreement"
|     "contributor": XID(5f1c3d9e) [
|         'nickname': "BRadvoc8"
|     ]
|     "contributorRepresents": "original work with authority to grant license"
|     "grantsCopyrightLicense": "perpetual, worldwide, non-exclusive, royalty-free"
|     "grantsPatentLicense": "for contributions containing patentable technology"
|     "licenseType": "Apache-2.0" [
|         "contractHash": "cfc7749b96f63bd31c3c42b5c471bf756814053e847c10f3eb003417bc523d30"
|         'date': "2004-01-00T00:00-00:00"
|         'dereferenceVia': "https://www.apache.org/licenses/LICENSE-2.0.txt"
|     ]
|     "project": "SisterSpaces SecureAuth Library"
|     "projectManager": XID(59be46b6) [
|         'nickname': "Ben (SisterSpaces)"
|     ]
| ]
``

## Part III: Signing a CLA

For Amira, signing the contract is a simple application of her new contract key.

### Step 6: Sign with Contract Key

Amira signs the CLA with her contract-signing key by first dating it
(the date isn't verifiable, but it will be assured by BRadvoc8's
signature) then wrapping it, then signing it.


```
CLA_WITH_DATE=$(envelope assertion add pred-obj known 'date' string `date -Iminutes` "$CLA")
WRAPPED_CLA=$(envelope subject type wrapped $CLA_WITH_DATE)
SIGNED_CLA=$(envelope sign --signer "$CONTRACT_PRVKEYS" "$WRAPPED_CLA")
```
The signed CLA is now a binding commitment from BRadvoc8 to grant the
specified licenses for any contributions to the SecureAuth Library
project.

> 📖 **How do you date a signature?** Dating a signature isn't as easy
as you think. There are several methods:
>
> (1) you can date the content before you wrap and sign it. This may
be undesirable in some situationss, if the content should not be
changed (e.g., if it's already been hashed for a commitment, or if a
date just mdudles the content). Otherwise, it's a great solution, as
it ensures the date is part of what's signed, and so part of a claim
that the sigger is making.
>
>
> (2) You can date the content after wrapping and signing. This is
very clean-looking as the date and signature are sitting right next to
each other, as they would be a paper document. But it's also
misleading because it makes it look like the signer has agreed to the
date, when in actuality *anyone* could have added the date after the
signer signed.
>
> (3) You can wrap, sign, date, wrap, and sign again. This
"double-signing" pattern is complex, and results in twice as many
signatures, but it keeps the original document clean while
simultaneously locking in the date as assured by the signer.

## Part IV: Verifying a CLA

Maintaing a standard workflow for a CLA ensures the maintenance of
rights necessary to support open software.

### Step 7: Verify CLA

To verify Amira's CLA, Ben walks through several steps:

1. Retrieve newest version of XID (per [§1.3](01_3_Making_a_XID_Verifiable.md)

```
FETCHED_XID=$PUBLIC_XID_WITH_CONTRACT_KEY
```

2. Check signature of XID

```
read -d '' -r -a PUBKEY <<< $(envelope xid key all "$FETCHED_XID")
for i in "${PUBKEY[@]}"
  do
    if envelope verify -v $i $SIGNED_CLA >/dev/null 2>&1; then
      echo "✅ One of the signatures verified! "
      echo $i
    fi
done
```

3. Review contributor reputation (optional)

If a PR came in over the transom, Ben might spend time trying to
verify the reputation of the contributor. In this case, DevReviewer
has already done the work for him.

### Step 8: Accept and Record

Satisfied with the verification, Ben accepts the CLA and records it.

4. Add acceptance to envelope

He could do this as a separate acceptance envelope, but he chooses to
add the acceptance to the envelope as another layer of an onion. He
does so by wrapping Amira's copy of the envelope, adding his
acceptance, and wrapping and signing that.

```
WRAPPED_SIGNED_CLA=$(envelope subject type wrapped "$SIGNED_CLA")
ACCEPTED_CLA=$(envelope assertion add pred-obj string "acceptedBy" ur $BEN_XID_ID "$WRAPPED_SIGNED_CLA")
ACCEPTED_CLA=$(envelope assertion add pred-obj known 'date' string `date -Iminutes` "$ACCEPTED_CLA")
WRAPPED_ACCEPTED_CLA=$(envelope subject type wrapped "$ACCEPTED_CLA")
SIGNED_ACCEPTED_CLA=$(envelope sign --signer "$BEN_PRVKEYS" "$WRAPPED_ACCEPTED_CLA")

echo "✅ CLA accepted"
envelope format $SIGNED_ACCEPTED_CLA

| ✅ CLA accepted
| 
| {
|     {
|         {
|             "Individual Contributor License Agreement" [
|                 'isA': "ContributorLicenseAgreement"
|                 "contributor": XID(5f1c3d9e) [
|                     'nickname': "BRadvoc8"
|                 ]
|                 "contributorRepresents": "original work with authority to grant license"
|                 "grantsCopyrightLicense": "perpetual, worldwide, non-exclusive, royalty-free"
|                 "grantsPatentLicense": "for contributions containing patentable technology"
|                 "licenseType": "Apache-2.0" [
|                     "contractHash": "cfc7749b96f63bd31c3c42b5c471bf756814053e847c10f3eb003417bc523d30"
|                     'date': "2004-01-00T00:00-00:00"
|                     'dereferenceVia': "https://www.apache.org/licenses/LICENSE-2.0.txt"
|                 ]
|                 "project": "SisterSpaces SecureAuth Library"
|                 "projectManager": XID(59be46b6) [
|                     'nickname': "Ben (SisterSpaces)"
|                 ]
|                 'date': "2026-03-25T11:14-10:00"
|             ]
|         } [
|             'signed': Signature(Ed25519)
|         ]
|     } [
|         "acceptedBy": XID(59be46b6)
|         'date': "2026-03-25T11:46-10:00"
|     ]
| } [
|     'signed': Signature(Ed25519)
| ]
```

The final steps are bureaucratic:

5. Upload signed CLA to repo

In this case, we're going to store both versions of the CLA in our `envelopes` directory

```
echo "$SIGNED_CLA" > envelopes/cla-bradvoc8-signed-3-04.envelope
echo "$SIGNED_ACCEPTED_CLA" > envelopes/cla-bradvoc8-accepted-3-04.envelope
```

6. Update permissions

Ben stores the doubly-signed CLA in his project repository, making it
part of the project's legal record.

With the CLA accepted, Ben grants BRadvoc8 limited repository access:
push to feature branches, but not main. He can do so confidently
because DevReviewer explained to him her cross-verification of the
BRadvoc8 GitHub account and the BRadvoc8 XID. He also gives BRadvoc8
the OK to merge Amira's PR (and to do so in the future at her own
perogative).

## Part V: Publishing a Contract

Ben's signature on Amira's contract is another step forward in the
progressive trust of BRadvoc8 as a reliable security expert. She'd
love to add this to her pseudonymous identity record.

### Step 9: Create a Contract Edge

To record the contract, Amira will create a new self-attestation that
she is working on SisterSpaces.

As with any other edge, she first needs to define the three core elements of the edge: `isA`, `source`, and `target`:
```
ISA="foaf:Project"
SOURCE_XID_ID=$XID_ID
TARGET_XID_ID=$XID_ID
```

Amira wants to be able to reference the contract, since it's signed by
Ben as the project manager of SisterSpaces, but she doesn't want to
include the whole contract in her XID. She can meet her needs instead
by including a commitment to the contract in her XID.

[§2.2](02_2_Managing_Claims_Elision.md) demonstrated the methodology
for making a commitment to an envelope:
```
DIGEST_CLA=$(envelope digest "$SIGNED_ACCEPTED_CLA")
```

There, we elided the envelope, leaving only the digest. Here, we're
instead going to incorporate the digest into this claim. If anyone
asks for more info they can ask BRadvoc8 for the full contract or they
can just look it up.

The latter info, as with the rest of the details of the claim, are placed as a target subenvelope:

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

This is a relatively simple edge, but that's because the digest stands in for the entire CLA!

### Step 10: Publish Your Contract Edge

You can now take the several steps to attach this edge and publish the result.

First, incorporate the edge:
```
WRAPPED_EDGE=$(envelope subject type wrapped "$EDGE")
SIGNED_EDGE=$(envelope sign --signer "$ATTESTATION_PRVKEYS" "$WRAPPED_EDGE")

XID_WITH_CONTRACT_EDGE=$(envelope xid edge add \
    --verify inception \
    $SIGNED_EDGE $XID_WITH_CONTRACT_KEY)
```

Then, advance the provenance mark and produce a public version
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
Finally, store everything:

```
echo "$PUBLIC_XID_WITH_CONTRACT_EDGE" > envelopes/BRadvoc8-xid-public-3-04b.envelope
echo "$XID_WITH_CONTRACT_EDGE" > envelopes/BRadvoc8-xid-private-3-04b.envelope
```

#### XID Version Comparison

You've now created a fifth and sixth XID edition.  Here's another overview of what
each version contains

| XID Version | New Content | Created In |
|-------------|-------------|------------|
| seq 0 | 👤 Identity | §1.2+§1.3 |
| seq 1 | 🔑 Attestation Key | §2.1 |
| seq 2 | 🗣️ GitHub Edge | §3.1 |
| seq 3 | 🗣️ Endorsement Edge | §3.3 |
| seq 4 | 🔑 Contract Key | §3.4 |
| seq 5 || 📄️  Contract scommitment | §3.4 |


## Summary: First Arc Complete

In [§3.3](03_3_Creating_Peer_Endorsements.md), Amira put a capstone on
her progressive trust journey when she acquired peer endorsements for
her BRadvoc8 pseudonymous identity. Here, in §3.4 that paid out with
her work being accepted for uses in SisterSpaces.

This completes the first arc of Amira's story, from anonymous person
to trusted contributor. Amira now has everything she needs to
participate in open source projects while protecting her real-world
identity.

Future arcs will cover advanced topics such as security hardening and advanced collaboration.

### Additional Files

**Envelopes:** The
[envelopes](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/envelopes)
directory contains numerous data created in this section, the most
important of which are Amira's final
[private](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/envelopes/BRadvoc8-xid-private-3-04b.envelope)
and
[public](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/envelopes/BRadvoc8-xid-public-3-04b.envelope)
XIDs as well as the [accepted
CLA](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/envelopes/cla-bradvoc8-accepted-3-04.envelope).

**Scripts:** Scripts demonstrating this section are forthcoming.

### Exercises

1. Create a CLA for a fictional project you maintain, specifying what license terms you'd require.
2. Design a key hierarchy with separate keys for: identity management, attestation signing, and contract signing.
3. Research how major open source projects (Apache, Linux Foundation) handle CLAs. What terms do they include?

## What's Next

Though we've complete Amira's first arc, there's an open question: has
her XID gotten too big? [§3.5: Creating Views and
Viewsion](03_5_Creating_Views_and_Versions.md) talks about how to
clean it up.

## Appendix I: Key Terminology

> **Contract-Signing Key**: A purpose-limited key designated for signing legal documents, following the principle of least authority.
>
> **Bilateral Agreement**: A contract where both parties have obligations, unlike unilateral attestations or endorsements.

## Appendix II: Common Questions

### Q: Is a pseudonymous CLA legally binding?

**A:** Yes, in most jurisdictions. What matters legally is that the
signer intended to be bound and had capacity to contract. The
signature doesn't need to be a legal name, it needs to be attributable
to a specific entity making a commitment. Cryptographic signatures
from a persistent pseudonymous identity satisfy this requirement.

### Q: What if my employer owns my contributions?

**A:** The CLA includes a representation that you have authority to
grant the license. If your employment agreement assigns your work to
your employer, you may need employer approval before
contributing. This applies equally to pseudonymous and real-name
contributors.

> ⚠️ **Employment Agreements**: Many tech employment contracts
include IP assignment clauses. Review your agreement before
contributing: the CLA representation of authority is legally binding.

### Q: Can access be revoked? What if I stop contributing?

**A:** Repository access and the CLA license are separate. A repo
owner can revoke access if you violate project policies, but your
existing contributions remain licensed. Conversely, you can stop
contributing anytime: the CLA covers past contributions, not future
obligations.

### Q: Why not just use a real name?

**A:** For Amira, revealing her real name could endanger her or her
family. For others, it might affect employment, invite harassment, or
simply be unnecessary. Pseudonymous contribution lets people
participate based on the quality of their work, not their real-world
identity.

