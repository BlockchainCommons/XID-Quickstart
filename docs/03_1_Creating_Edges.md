# 3.1: Creating Edges

Data about an identity doesn't have to be placed in your XID itself.
You can alternatively create a new Gordian Envelope, reference your
XID from that envelope, and sign the envelope with your XID's signing
key. The result is additional details for a XID without overfilling
the XID's central data space. This was how a variety of claims were
created in chapter 2.  However, sometimes data needs to be more
centrally stored in the XID itself. There are a variety of methods for
doing so; one of them is by creating "edges" within the XID, which
support attestations within the XID itself.

> :brain: **Related Concepts**: This tutorial covers the creation of
an attestation as an edge. For deeper understanding, see [Attestation
& Endorsement Model](../concepts/attestation-endorsement-model.md) for
the framework of claims and verification, [Fair
Witness](../concepts/fair-witness.md) for making trustworthy
assertions, and [Pseudonymous Trust
Building](../concepts/pseudonymous-trust-building.md) for building
reputation while maintaining privacy.

## Objectives of this Section

After working through this section, a developer will be able to:

- Create self-attestation edges
- Link XIDs to online services

Supporting objectives include the ability to:

- Know different methodologies for linking data to XIDs
- Understand how SSH signing keys differ from authentication keys

## Amira's Story: Verifying Claims

Amira has made a number of claims for the BRadvoc8 identity that are
linked to GitHub. She made a claim about a PR she'd filed in
[§2.1](02_1_Creating_Self_Attestations.md). Then she made claims about
security auditing work and authentication design in
[§2.2](02_2_Managing_Claims_Elision.md) and
[§2.3](02_3_Managing_Claims_Encryption.md). The PR is definitely
linked to her BRadvoc8 account, and though the more sensitive work
doing security audits and designing for CivilTrust isn't (because of
that sensitivity), the BRadvoc8 account does include work that shows
similar (but less correlatable) work on security systems.

Because Amira previously couldn't provide an explicit link to her
GitHub account, all of those claims have enjoyed only a medium level
of trust. There were some other facts to back them up (like the shared
name of the account and XID, the existence of the PR, and the hashed
commitment for the security audit work), but ultimately the claims
remained somewhat nebulous.

DevReviewer is now getting ready to offer Amira a contract for
further, more intensive work on Ben's SisterSpaces project, but they
want one last piece of information to progress their trust of
BRadvoc8: proof of control of the BRadvoc8 GitHub account.

This will be done by creating an "edge", which is a claim that's
created as part of the XID itself, and signing it with a key
registered on the GitHub account.

## The Options for Recording Data in XIDs

As has been written elsewhere: XIDs are precisely structured. Though
Gordian Envelope can accept any type of assertion, XIDs are organized into
specific predicates.

The following table lists a variety of `envelope-cli` commands, the
XID predicate each creates, what it means, and where additional
information can be found.

| Section | Command | Predicate | Description |
|---------|---------|-----------|-------------|
| | `attachment` | `'attachment'` | 📂 Third-party metadata |
| | `delegate` | `'delegate'` | 👌🏽 Permission delegation | 
| §3.1-§3.3 | `edge` | `'edge'` | 🗣️  Attestations |
| §1.2, §2.1 | `key` | `'key'`<br>`'privateKey'` | 🔑 Key pairs |
| §1.3 | `method`<br>`resolution` | `'dereferencevia'` | 🧶 Resolution method |
| | `service` | `'service'` | ☁️  Service delegation |
| §1.2, §2.1 | `provenance` | `'provenance'` | ⛓️  Provenance mark |

Edges will be the topic of this chapter.

## Part 0: Verify Dependencies

As usual, check your `envelope-cli` version:
```
envelope --version

│ bc-envelope-cli 0.34.1
```

Then, reload your XID.
```
XID=$(cat envelopes/BRadvoc8-xid-private-2-01.envelope)
XID_ID=$(envelope xid id $XID)
PASSWORD="your-password-from-previous-tutorials"
```

## Part I: Setting Up a GitHub Account

The first step is one that Amira did a while ago: setting up her
BRadvoc8 GitHub account. She created a signing key for it, uploaded
it, and has since been using that to sign commits, including the
Galaxy Project commit that she references in her claim from
[§2.1](02_1_Creating_Self_Attestations.md).

Here's a review of how all that was done.

### Step 1: Generate SSH Signing Key

Amira needed to create SSH keys for signing her Git commits. These are
different from her SSH authentication keys and maintained seperately
by GitHub. There are a number of methods that can be used to generate
ed25519 SSH keys, but she chose to use the `envelope-cli`, requesting
that it `generate prvkeys` of the type `--signing ssh-ed25519`, which
is the preferred type for GitHub.

```
SSH_PRVKEYS=$(envelope generate prvkeys --signing ssh-ed25519)
```

If you instead have an ed25519 signing key that you've created by
other means, can you alternatively use `envelope-cli` to import it for
usage with XIDs.  Just run `import` on the appropriate file:

```
SSH_PRVKEYS=$(cat ~/.ssh/your_signing_key | envelope import)
```

In either case, you can then create your public keys from your private keys:
```
SSH_PUBKEYS=$(envelope generate pubkeys "$SSH_PRVKEYS")
```

Finally, you can `export` your public keys to tranform th UR format
used by Gordian Envelope into an interoperable SSH format (_not_ raw
Ed25519) that will be recognized by GitHub:

```
SSH_EXPORT=$(envelope export "$SSH_PUBKEYS")

echo "✅ Generated SSH signing key:"
echo "$SSH_EXPORT"
```

│ ✅ Generated SSH signing key:
│ ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiOtuf9hwDBjNXyjvjHMKeLQKyzT8GcH3tLvHNKrXJe

### Step 2: Upload Keys to GitHub

Afterward, Amira uploaded the exported version of the public key [to
GitHub](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)
as an SSH signing key ... but you don't actually have to do this for
these tutorials because we'll test against the [existing BRadvoc8
account](https://github.com/BRadvoc8/BRadvoc8) in [§3.2: Supportig
Cross Verification](03_2_Supporting_Cross_Verification.md).

> 📖 **What is the difference between SSH Signing an SSH
Authentication keys?** GitHub has two separate SSH key
registries. Authentication keys (`/users/{user}/keys`) control access
to repositories. Signing keys (`/users/{user}/ssh_signing_keys`)
verify commit signatures. Amira is adding a signing key. It proves
that her commits are authentic, not that she can push to repos.

#### Key Type Comparison

In keeping with the best practice of
[heterogeneity](https://developer.blockchaincommons.com/architecture/patterns/auth/),
Amira now has three different keys serving three different purposes:

| Key Type | Purpose | Verified Against | Added In |
|----------|---------|------------------|----------|
| 👤 XID inception key | Signs XID document updates | XID itself | §1.2 |
| 🗣️  Attestation key | Signs attestations | XID key list | §2.1 |
| 🖋️  SSH signing key | Signs Git commits | GitHub account | §3.1 |

As mentioned in
[§2.1](2_1_Creating_Self_Attestations.md#key-type-comparison), having
different keys for different purposes decreases the repercussions of
key loss or compromise. Now that we have three keys, we can more
extensively look at the protections that heterogeneity offers:

| Key Type | Location | Compromise Impact |
|----------|---------|------------------|
| 👤 XID inception key | XID (encrypted or elided) | Identity compromised |
| 🗣️  Attestation key | XID (encrypted or elided) | Claims forged |
| 🖋️  SSH signing key | Local files | Commits forged |

This shows the containment enabled by key heterogeneity: if Amira's
SSH key is stolen, an attacker can forge commits and if her
attestation key is stolen, an attacker can forge claims, but in both
cases her XID identity remains intact. In both cases, she could revoke
the compromised key and add a new one without losing her identity or
reputation history.

A new key can even be created to allow changes to the XID! Your
identity persists across key changes.

> 📖 **Why wasn't the SSH signing key added to Amira's XID?**
Previously, we added the attestation key to Amira's XID, but the new
SSH key we're just keeping on-disk (with the public key uploaded to
GitHub). This is a question of philosophy. You can choose to keep your
XID neat and clean, and only use it to store the keys related to the
control and use of that XID and related claims. Or, you can choose to
use your XID to manage your whole "bag of keys", even keys securing
other services (such as GitHub). We've chosen the "simple and clean"
methodology for these tutorials, under the theory that you can choose
to add on from there if you desire. If you decided to add the SSH keys
to your XID, you would follow the methodology of
[§2.1](2_1_Creating_Self_Attestations.md#step-2-register-attestation-key-in-xid)
for registering a new key in your XID, and you would of course
reencrypt all your keys afterward.

## Part II: Adding an Edge to a XID

You now need to create a claim that the XID BRadvoc8 owns the BRadvoc8
GitHub account. This is largely done like the other claims created
starting in [§2.1](02_1_Creating_Self_Attestations.md), except with
two notable changes:

1. The structure of the claim will be slightly different, to accomodate
the fact that it will be _embedded_ instead of _detached_.
2. The claim will be signed by the SSH signing key uploaded to the
GitHub account.

### Step 3: Understand the Edge

Amira's claim that the BRadvoc8 XID owns the BRadvoc8 GitHub account
will be created as an edge, which is a specific XID assertion that
enables the incorporation of an attestation directly into a XID.

> 📖 **What is an edge?** An edge is a link between two XIDs intended
to describe a claim. If the XIDs are the same, a self-attestation is
created, and if the XIDs are different, a peer endorsement is created.

An edge has a subject that must be unique within a XID. It could be a
UUID or credential number used for reference. It might also be
something more descriptive, to make it easier to find a specific edge
within a XID. However, it should not define the claim itself; that
falls to its content.

There are exactly three predicates that must be used in an edge:

1. **`isA`:** either a description of a relationship between the two
XIDs or a description of the claim that the first XID is making about
the second.
2. **`source`:** The XID making the claim.
3. **`target`:** The XID that the claim is about.

You'll note that `isA`, `source`, and `target` were all also used in
the detached claims in [chapter 2](02_0_Claims.md). This was
intentional. These three predicates are *required* for defining
edges. Also including them in detached claims is optional, but helps
those detached claims to be consistent with embedded claims, and so
easier to understand.

Those three assertions are the only ones allowed as descriptions of
the edge subject, which might seem limiting. This is resolved by the
fact that additional envelopes can be linked below each of these
assertions. `target` assertions are where additional information on
the claim is usually placed, while `source` assertions could provide
some (self-reported) details on the person making the claim and `isA`
assertions could better define the claim type.

After a claim has been fully created with this methodology of laying
out these three assertions, then adding sub-envelopes to those
assertions as appropriate, it will then be wrapped and signed before
it is attached to the XID as an edge. All of these specifics are
further described in
[BCR-2026-003](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2026-003-xid-edges.md).

> 📖 **What is a BCR?** BCRs are Blockchain Commons Research papers,
which precisely define Blockchain Commons technologies and
specifications. They are all stored in the [Blockchain Commons
Research
repo](https://github.com/BlockchainCommons/Research?tab=readme-ov-file).

### Step 4: Create Ownership Claim

You can now assemble a complete envelope with all of the ownership
information about Amira's GitHub account. These are the claim details
that will later be added to the `target` of the edge.

But first you should decide what the `isA` for the edge is going to
be. You're not going to embed that yet, but it's good to know since
the `isA` defines the claim's type and the `target` subenvelope will
define the claim's details. The edges BCR suggests using known
ontologies, and for this we're going to use [the FOAF
registry](https://github.com/BlockchainCommons/Research/blob/master/known-value-assignments/markdown/2500_foaf_registry.md).

We're not describing a relationship, but instead making an attestation for what's essentially a
credential ("BRadvoc8 owns this account"). To be precise, we're claiming ownership of an online
account, for which `foaf:OnlineAccount` is appropriate.

```
ISA="foaf:OnlineAccount"
```

We're now ready to create the sub-envelope. Because it's a `target`
envelope, we need to start out with the target's XID:

```
TARGET=$(envelope subject type ur "$XID_ID")
```

We then provide additional details about the `onlineAccount` as assertions that will be added to the target:
```
GH_NAME="BRadvoc8"
TARGET=$(envelope assertion add pred-obj string "foaf:accountName" string "$GH_NAME" "$TARGET")
TARGET=$(envelope assertion add pred-obj string "foaf:accountServiceHomepage" uri "https://github.com/$GH_NAME/$GH_NAME" "$TARGET")
TARGET=$(envelope assertion add pred-obj string "sshSigningKey" ur "$SSH_PUBKEYS" "$TARGET")
TARGET=$(envelope assertion add pred-obj string "sshSigningKeyText" string "$SSH_EXPORT" "$TARGET")
TARGET=$(envelope assertion add pred-obj string "sshSigningKeysURL" uri "https://api.github.com/users/$GH_NAME/ssh_signing_keys" "$TARGET")
TARGET=$(envelope assertion add pred-obj known conformsTo uri "https://github.com" "$TARGET")
TARGET=$(envelope assertion add pred-obj known date string `date -Iminutes` "$TARGET")
TARGET=$(envelope assertion add pred-obj known verifiableAt uri "https://api.github.com/users/$GH_NAME" "$TARGET")

echo "GitHub account credential details:"
envelope format "$TARGET"

│ GitHub account payload:
|
| XID(5f1c3d9e) [
|     "foaf:accountName": "BRadvoc8"
|     "foaf:accountServiceHomepage": URI(https://github.com/BRadvoc8/BRadvoc8)
|     "sshSigningKey": SigningPublicKey(c75b2f19, SSHPublicKey(b3e7a8b0))
|     "sshSigningKeyText": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiOtuf9hwDBjNXyjvjHMKeLQKyzT8GcH3tLvHNKrXJe BRadvoc8@Mac.attlocal.net"
|     "sshSigningKeysURL": URI(https://api.github.com/users/BRadvoc8/ssh_signing_keys)
|     'conformsTo': URI(https://github.com)
|     'date': "2026-03-18T11:55-10:00"
|     'verifiableAt': URI(https://api.github.com/users/BRadvoc8)
| ]
```

This builds the payload step by step. The `subject type` command used
the XID ID, which is required as this envelope is describing the
`target` of the edge.

| `subject` Command | Subject Type | Purpose |
|---------|---------------|---------|
| `string "$XID_ID"` | UR (`"$XID_ID"`) | Sets "XID(5f1c3d9e)" as the envelope subject |

Each `envelope assertion add pred-obj` command then adds one
predicate-object pair as an assertion to that subject.

| `assertion` Command | Predicate Type | Purpose |
|---------|---------------|---------|
| `string  "foaf:accountName" string "..."` | Custom (`"foaf:accountName"`) | The name of the online account |
| `string "foaf:accountServiceHomepage" uri "..."` | Custom (`"foaf:accountServiceHomePage"` | Home URI of the account |
| `string "sshSigningKey" ur "$SSH_PUBKEYS"` | Custom (`"sshSigningKey"`) | The key in structured UR format |
| `string "sshSigningKeyText" string "..."` | Custom (`"sshSigningKeyText"`) | The key in human-readable format |
| `string "sshSigningKeysURL" uri "..."` | Custom (`"sshSigningKeysURL"`) | Where to verify the key is registered |
| `known conformsTo string "https://github.com"` | Known (`'conformsTo'`) | The account conforms to this type |
| `known date "..."` | string (date)| When this attestation was created |
| `known verifiableAt uri "..."` | Known (`'verifiableAt'`) | Where this info can be verified |

This complete package is meant to be a description of the credential
being declared, `isA: foaf:OnlineAccount`.

### Step 5: Create the Edge

You're now ready to create the edge structure, which as discussed in
Step 3 is an envelope with an arbitrary, but unique, ID and the three assertions: `isA`, `source`, and `target`.

```
EDGE=$(envelope subject type string "account-credential-github")
EDGE=$(envelope assertion add pred-obj known isA string "$ISA" "$EDGE")
EDGE=$(envelope assertion add pred-obj known source ur "$XID_ID" "$EDGE")
EDGE=$(envelope assertion add pred-obj known target envelope "$TARGET" "$EDGE")
```

We chose a subject that was descriptive without being declarative,
added in our `$ISA` and used BRadvoc8's `$XID_ID` as both the `source`
and the `target`, just as in the previous chapter, because this is
another self-attestation ... just one that's more verifiable than
before. (The `target` is actually the entire envelope we previously
created, but it leads off with the `$XID_ID`.)

```
echo "GitHub edge details:"
envelope format "$EDGE"

| GitHub edge details:
|
| "account-credential-github" [
|     'isA': "foaf:OnlineAccount"
|     'source': XID(5f1c3d9e)
|     'target': XID(5f1c3d9e) [
|         "foaf:accountName": "BRadvoc8"
|         "foaf:accountServiceHomepage": URI(https://github.com/BRadvoc8/BRadvoc8)
|         "sshSigningKey": SigningPublicKey(c75b2f19, SSHPublicKey(b3e7a8b0))
|         "sshSigningKeyText": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiOtuf9hwDBjNXyjvjHMKeLQKyzT8GcH3tLvHNKrXJe BRadvoc8@Mac.attlocal.net"
|         "sshSigningKeysURL": URI(https://api.github.com/users/BRadvoc8/ssh_signing_keys)
|         'conformsTo': URI(https://github.com)
|         'date': "2026-03-18T11:55-10:00"
|         'verifiableAt': URI(https://api.github.com/users/BRadvoc8)
|     ]
| ]
```

### Step 6: Wrap & Sign the Edge

You can now wrap and sign your edge:
```
WRAPPED_EDGE=$(envelope subject type wrapped $EDGE)
SIGNED_EDGE=$(envelope sign --signer "$SSH_PRVKEYS" "$WRAPPED_EDGE")
```

The big change here is that you signed with the same SSH private key
used for signing on Amira's GitHub account, but as you can see, the
`envelope-cli` allows that with no fuss. This will be what allows proof of control.

Signing is _not_ an optional step. As stated in the [Edges
BCR](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2026-003-xid-edges.md#signing):
"Every edge MUST be wrapped and signed by the claimant (the entity
identified by 'source'). "

### Step 7: Link Your Edge

Now that you've done all the work of creating an edge, linking it to Amira's XID is extremely simple:
```
XID_WITH_EDGE=$(envelope xid edge add \
    --verify inception \
    $SIGNED_EDGE $XID)
```

As in §2.1, we've verified the original inception signature, but we
haven't bother to re-sign yet, because we haven't finalized the new
edition of the XID.


```
echo "XID with GitHub edge:"
envelope format "$XID_WITH_EDGE"

| XID with GitHub edge:
| 
| XID(5f1c3d9e) [
|     'dereferenceVia': URI(https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt)
|     'edge': {
|         "account-credential-github" [
|             'isA': "foaf:OnlineAccount"
|             'source': XID(5f1c3d9e)
|             'target': XID(5f1c3d9e) [
|                 "foaf:accountName": "BRadvoc8"
|                 "foaf:accountServiceHomepage": URI(https://github.com/BRadvoc8/BRadvoc8)
|                 "sshSigningKey": SigningPublicKey(c75b2f19, SSHPublicKey(b3e7a8b0))
|                 "sshSigningKeyText": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiOtuf9hwDBjNXyjvjHMKeLQKyzT8GcH3tLvHNKrXJe BRadvoc8@Mac.attlocal.net"
|                 "sshSigningKeysURL": URI(https://api.github.com/users/BRadvoc8/ssh_signing_keys)
|                 'conformsTo': URI(https://github.com)
|                 'date': "2026-03-18T11:55-10:00"
|                 'verifiableAt': URI(https://api.github.com/users/BRadvoc8)
|             ]
|         ]
|     } [
|         'signed': Signature(SshEd25519)
|     ]
|     ...
| ]
```

Though that XID might look imposing, it was creating using the
standard methodology for envelopes: build from the inside out. So you
constructed a target envelope and attached it to the target, then you
created an edge and attached it to the XID. Each step was clear and
self-contained, but you were able to create a document with dense,
recursive metadata.

### Step 8: Advance Your Provenance Mark

By adding the GitHub edge, you've created a new edition of Amira's
XID. Since you plan to publish it, that means you must update the
provenance mark (and as usual, sign the new XID, which requires
decrypting and re-encrypting everything).

```
XID_WITH_EDGE=$(envelope xid provenance next \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$XID_WITH_EDGE")
echo "✅ Provenance advanced"

| ✅ Provenance advanced
```
### Step 9: Export & Store Your Work

You should also create a public view of the new XID that elides all the
sensitive keys:

```
PUBLIC_XID_WITH_EDGE=$(envelope xid export --private elide --generator elide "$XID_WITH_EDGE")
```

This is what you'll send to DevReviewer for their review, which we'll
see in the next section.

Afterward, you should save your data, particularly since you now have
a third edition of Amira's XID.

```
echo "$PUBLIC_XID_WITH_EDGE" > envelopes/BRadvoc8-xid-public-3-01.envelope
echo "$XID_WITH_EDGE" > envelopes/BRadvoc8-xid-private-3-01.envelope
```

#### XID Version Comparison

You've now created a third XID edition. We'll take a look at the
provenance marks again in the next section, but here's an overview of
what each version contains

| XID Version | New Content | Created In |
|-------------|-------------|------------|
| seq 0 | 👤 Identity | §1.2+§1.3 |
| seq 1 | 🔑 Attestation Key | §2.1 |
| seq 2 | 🗣️ GitHub Edge | §3.1 |

## Summary: The World of Edges

On the surface, the lesson of this tutorial was simple: you can create
embedded attestations by linking them into a XID as an edge, which
defines either a relationship between two XIDs or else an attestation
(or credential) that one XID is making of another. That can be a
self-attestation if the source and target XIDs are the same, as is the
case here.

But when you did deeper, this tutorial opens up a whole new world of
verification, because it used a key that's registered with another
account, which is going to allow cross-verification of that account,
but that's a topic for the [next
section](03_2_Supporting_Cross_Verification.md).

### Additional Files

**Envelopes:** The
[envelopes](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/envelopes)
directory contains the [private XID](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/envelopes/BRadvoc8-xid-private-3-01.envelope) and the [public XID](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/envelopes/BRadvoc8-xid-public-3-01.envelope) created in this section.

**Scripts:** Scripts demonstrating this section are forthcoming.

### Exercises

Try these to solidify your understanding:

- Generate a new SSH signing key.
- Build a target envelope that details an attestation or credential for the target.
- Turn the target envelope into an edge.
- Attach the edge to a XID. (Remember to advance your provenance mark!)

## What's Next

Again, this section allows you to branch off into a few topics. Most
likely you want to see how Amira's new edge can be cross-verified with
GitHub, creating a higher level of trust. You can find that in [§3.2:
Supporting Cross
Verification](03_2_Supporting_Cross_Verification.md). However, you
might want to immediately jump to the next step in attestation: peer
endorsement. That can be found in [§3.3: Creating Peer
Endorsements](03_3_Creating_Peer_Endorsements.md).

## Appendix I: Appendix: Key Terminology

> **BCR** - A Blockchain Research paper, describing a specification or technology.
>
> **Edge** - A link between two XIDs that demonstrates their relationship or includes an attestation made by one about the other.
>
> **SSH Signing Key** - An SSH key used to sign Git commits. Different from authentication keys; GitHub maintains them at `/users/{user}/ssh_signing_keys`.
