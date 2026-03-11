# 3.1: Creating Edges

A lot of data can be created adjacent to a XID. You make a new Gordian
Envelope, you reference your XID, and you sign with your XID's signing
key. But sometimes data needs to be more centrally stored in the XID
itself. XIDs offer a variety of ways to do so, including Edges, which
allow the creation of attestations within the XID itself.

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


- How to link XIDs to online services
- How SSH signing keys differ from authentication keys
- How proof-of-control establishes temporal claims
- How to advance provenance after making changes
- How to detect stale XIDs with provenance marks

Supporting objectives include the ability to:

## Amira's Story: Verifying Claims

Amira has made a number of claims for the BRadvoc8 account that are
linked to GitHub. She made a claim about a PR she'd filed in
[§2.1](02_1_Creating_Self_Attestations.md). Then she made claims about
security auditing work and authentication design in
[§2.2](02_2_Managing_Claims_Elision.md) and
[§2.3](02_3_Managing_Claims_Encryption.md). The PR is definitely
linked to her BRadvoc8 account, and though the more sensitive work
doing security audits and working for CivilTrust isn't (because of
that sensitivity), the BRadvoc8 account does include work that shows
similar (but less correlatable) work on security systems.

Because Amira couldn't provide an explicit link to her GitHub account,
all of those claims have only enjoyed a medium level of trust. There
were some other facts to back them up (like the shared name of the
account and XID, the fact that the PR existed, the fact that Amira had
made a commitment to the security audit work), but ultimately the
claims remained somewhat nebulous.

DevReviewer is now getting ready to offer Amira a contract to work on
Ben's SisterSpaces project, but they want one last piece of
information to progress their trust of BRadvoc8: proof of control of
the BRadvoc8 GitHub account.

This will be done by creating an "edge", which is a claim that's
created as part of the XID itself, and signing it with a key
registered on the GitHub account.

## The Options for Recording Data in XIDs

As has been written elsewhere: XIDs are precisely structured. Where
envelopes can accept any type of assertion, XIDs are organized into
specific predicates.

The following table lists a variety of `envelope` commands, the
predicate it creates, what it means, and where additional information
can be found.

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

## Part I: Setting Up a GitHub Account

The first step is one that Amira did a while ago: setting up her
BRadvoc8 GitHub account. She created a signing key for it, uploaded
it, and has since been using that to sign commits, including the
Galaxy Project commit that she references in her claim from
[§2.1](02_1_Creating_Self_Attestations.md).

Here's a review of how all that was done.

### Step 0: Verify Dependencies

As usual, check your `envelope-cli` version:
```
envelope --version

│ bc-envelope-cli 0.34.1
```

Then, reload your XID.
```
XID=$(cat envelopes/BRadvoc8-xid-private-2-01.envelope)
XID_ID=$(envelope xid id $XID)
```

### Step 1: Generate SSH Signing Key

Amira needed SSH keys specifically for signing Git commits. These are
different from her SSH authentication keys and maintained seperately
by GitHub. Since she knew she'd eventually want to use them in
conjunction with a XID, she generate them with `envelope`, requesting
keys of the type `--signing ssh-ed25519`, which is the preferred type
for GitHub.

```
SSH_PRVKEYS=$(envelope generate prvkeys --signing ssh-ed25519)
```

If you instead have an ed25519 signing key that you've created from
other means, you can instead import it (substituting the name of your
file that contains the public key):
```
SSH_PRVKEYS=$(cat ~/.ssh/your_signing_key | envelope import)
```

In either case, you can then create your public keys from your private keys:
```
SSH_PUBKEYS=$(envelope generate pubkeys "$SSH_PRVKEYS")
```

Finally, you can `export` your public keys to tranform th UR format
used by envelope into an interoperable SSH format (_not_ raw Ed25519)
that was recognized by GitHub:

```
SSH_EXPORT=$(envelope export "$SSH_PUBKEYS")

echo "✅ Generated SSH signing key:"
echo "$SSH_EXPORT"
```

│ ✅ Generated SSH signing key:
│ ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiOtuf9hwDBjNXyjvjHMKeLQKyzT8GcH3tLvHNKrXJe

### Step 2: Upload Keys to GitHub

This is what you would the exported version of the key [to
GitHub](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)
as an SSH signing key ... but you don't actually have to for these
tutorials because we'll test against the [existing BRadvoc8
account](https://github.com/BRadvoc8/BRadvoc8) in [§3.2: Supportig
Cross Verification](03_2_Supporting_Cross_Verification.md).

> :book: **SSH Signing vs SSH Authentication**: GitHub has two
separate SSH key registries. Authentication keys
(`/users/{user}/keys`) control access to repositories. Signing keys
(`/users/{user}/ssh_signing_keys`) verify commit signatures. Amira is
adding a signing key. It proves that her commits are authentic, not
that she can push to repos.

#### Key Type Comparison

In keeping with the best practice of
[heterogeneity](https://developer.blockchaincommons.com/architecture/patterns/auth/),
Amira now has three different keys serving different purposes:

| Key Type | Purpose | Verified Against | Added In |
|----------|---------|------------------|----------|
| 👤 XID inception key | Signs XID document updates | XID itself | §1.2 |
| 🗣️  Attestation key | Signs attestations | XID key list | §2.1 |
| 🖋️  SSH signing key | Signs Git Commits | GitHub account | §3.1 |

As mentioned in
[§2.1](2_1_Creating_Self_Attestations.md#key-type-comparison), having
different keys for different purposes decreases the repercussions of
key loss or compromise. Here's a look at how that's the case:

| Key Type | Location | Compromise Impact |
|----------|---------|------------------|
| 👤 XID inception key | XID (encrypted or elided) | Identity compromised |
| 🗣️  Attestation key | XID (encrypted or elided) | Claims forged |
| 🖋️  SSH signing key | Local files | Commits forged |

This shows the containment enabled by key heterogeneity: if Amira's
SSH key is stolen, an attacker can forge commits, but her XID identity
remains intact. She could then revoke the compromised SSH key and add
a new one without losing her identity or reputation history.

A new key can even be created to allow changes to the XID! Your
identity persists across key changes.

> 📖 **Why wasn't the SSH signing key added to Amira's XID?** This is
a question of philosophy. You can choose to keep your XID neat and
clean, and only use it to store the keys related to the control and
use of that XID. Or, you could choose to use your XID to manage your
whole "bag of keys", even keys securing other services (such as
GitHub). We've chosen the "simple and clean" methodology for these
tutorials, under the theory that you can choose to add from there if
you wanted. If you decided to add the SSH keys to your XID, you would
follow the methodology of
[§2.1](2_1_Creating_Self_Attestations.md#step-2-register-attestation-key-in-xid)
for registering a new key in your XID, and you would of course
reencrypt all your keys afterward.

## Part II: Creating an Ownership Claim

You now need to create a claim that the XID BRadvoc8 owns the BRadvoc8
GitHub account. This is largely done like the other claims created
starting in [§2.1](02_1_Creating_Self_Attestations.md), except with
two notable changes:

1. The structure of the claim will be slightly different to accomodate
the fact that it will be _embedded_ instead of _detached_.
2. The claim will be signed by the SSH signing key uploaded to the
GitHub account.

### Step 3: Understand the Edge

Amira's claim that the BRadvoc8 XID owns the BRadvoc8 GitHub account
will be done as an edge, which is a specific XID assertion that
enables the incorporation of an attestation directly into a XID.

An edge has a subject that must be unique within a XID. It could be a
UUID or credential number used for reference. It might also be
something more descriptive, to make it easier to find a specific edge
within a XID. However, it should not define the claim itself; that
falls to its content.

There are three predicates that must be used in an edge:

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

> 📖 **What is an edge?** An edge is a link between two XIDs intended
to allow the creation of a claim. If both XIDs are the same, a
self-attestation is create, and if both XIDs are different, a peer
endorsement is created.

Those three assertions are the only ones allowed as descriptions of
the edge subject, which might seem limiting. This is resolved by the
fact that additional envelopes can be linked to each of these
assertions. `target` assertions are where additional information on
the claim is usually placed, while `source` assertions could provide
some (self-reported) details on the person making the claim and `isA`
assertions could better define the claim type.

### Step 4: Create Ownership Claim

You can now assemble a complete envelope with all of the ownership
information about Amira's GitHub account. These are the claim details
that will later be added to the `target` of the edge.

[[ETH]]


```
GITHUB_ACCOUNT=$(envelope subject type string "$XID_NAME")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj known isA string "GitHubAccount" "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj known conformsTo string "https://github.com" "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj known dereferenceVia uri "https://api.github.com/users/$XID_NAME" "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "sshSigningKeysURL" uri "https://api.github.com/users/$XID_NAME/ssh_signing_keys" "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "sshSigningKey" ur "$SSH_PUBKEYS" "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "sshSigningKeyText" string "$SSH_EXPORT" "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "sshSigningKeyProof" envelope "$PROOF" "$GITHUB_ACCOUNT")
CURRENT_TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "createdAt" date "$CURRENT_TIMESTAMP" "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "updatedAt" date "$CURRENT_TIMESTAMP" "$GITHUB_ACCOUNT")

echo "GitHub account payload:"
envelope format "$GITHUB_ACCOUNT"

│ GitHub account payload:
| "BRadvoc8" [
|    'isA': "GitHubAccount"
|    "createdAt": 2026-01-21T05:34:20Z
|    "sshSigningKey": SigningPublicKey(714b3b69, SSHPublicKey(f733cab9))
|    "sshSigningKeyProof": "BRadvoc8 controls this SSH key on 2026-02-04" [
|        'signed': Signature(SshEd25519)
|    ]
|    "sshSigningKeyText": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiOtuf9hwDBjNXyjvjHMKeLQKyzT8GcH3tLvHNKrXJe"
|    "sshSigningKeysURL": URI(https://api.github.com/users/BRadvoc8/ssh_signing_keys)
|    "updatedAt": 2026-01-21T05:34:20Z
|    'conformsTo': "https://github.com"
|    'dereferenceVia': URI(https://api.github.com/users/BRadvoc8)
]
```

This builds the payload step by step. The `subject type` command describes the name of the GitHub account (which happens to be the same as the `$XID_NAME` we've defined, but that doesn't have to be the case).

| `subject` Command | Subject Type | Purpose |
|---------|---------------|---------|
| `string "$XID_NAME"` | String (`"$XID_NAME"`) | Sets "BRadvoc8" as the envelope subject |

Each `envelope assertion add pred-obj` command then adds one predicate-object pair as an assertion to that subject.

| `assertion` Command | Predicate Type | Purpose |
|---------|---------------|---------|
| `known isA string "GitHubAccount"` | Known (`'isA'`) | Declares what this envelope represents |
| `known conformsTo string "https://github.com"` | Known (`'conformsTo'`) | [Standard](https://www.dublincore.org/specifications/dublin-core/dcmi-terms/#conformsTo) for the resource |
| `known dereferenceVia uri "..."` | Known (`'dereferenceVia'`) | Points to authoritative source |
| `string "sshSigningKeysURL" uri "..."` | Custom (`"sshSigningKeysURL"`) | Where to verify the key is registered |
| `string "sshSigningKey" ur "$SSH_PUBKEYS"` | Custom (`"sshSigningKey"`) | The key in structured UR format |
| `string "sshSigningKeyText" string "..."` | Custom (`"sshSigningKeyText"`) | The key in human-readable format |
| `string "sshSigningKeyProof" envelope "$PROOF"` | Custom (`"sshSigningKeyProof"`) | Embeds the signed proof-of-control |
| `string "createdAt" date "..."` | Custom (`"createdAt"`) | When this attestation was created |
| `string "updatedAt" date "..."` | Custom (`"updatedAt"`) | When this attestation was last modified |

In all we have: the account name as subject, a type marker (`isA: "GitHubAccount"`), a verification URL (`dereferenceVia` pointing to GitHub's API), the public key in both structured (`ur`) and text formats, the proof-of-control, and those additional timestamps.

* The *`dereferenceVia`* URL points to the GitHub account itself (not the signing keys) because `isA` declares this is a "GitHubAccount". In envelope design, `dereferenceVia` must point to the authoritative source of whatever the subject claims to be: the type and the dereference target must match semantically. If someone fetches the `dereferenceVia` URL expecting a GitHub account, they should get account information, not a list of SSH keys. This `dereferenceVia` URI is particularly important: it will tell Ben exactly where to check and whether this key is actually registered on GitHub. That verification happens in Tutorial 04.
* The *`conformsTo` known value is drawn from the [Dublin Core](https://www.dublincore.org/specifications/dublin-core/dcmi-terms/#conformsTo). Ideally, it should be a description of how the GitHub resource is commonly defined, but here we just point to the URL that all GitHub accounts conform to.
* The *signing keys endpoint* is in a custom predicate (`sshSigningKeysURL`) since it's verification data *about* the account, not the account itself. This is the flexibility that attachments provide: you define whatever predicates your domain needs. We use `known` predicates (`isA`, `dereferenceVia`) for standard envelope semantics (depicted by single quotes in output) and `string` predicates for domain-specific data like `sshSigningKey` and `sshSigningKeysURL` (depicted by double quotes in output).
   * Though they're attachment-specific, the `sshSigning*` prefix—related fields should share naming patterns.
* Both *`createdAt`* and *`updatedAt`* are included even though they're identical now. When Amira later updates this attestation (perhaps rotating her SSH key), `createdAt` stays fixed while `updatedAt` changes. This lets Ben distinguish "how long has this claim existed?" from "when was it last verified?"

### Step 5: Add Service to XID

Now add this payload as an attachment to your XID:

```
XID_WITH_SERVICE=$(envelope xid service add \
    --vendor "self" \
    --payload "$GITHUB_ACCOUNT" \
    --verify inception \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$XID")

echo "Added GitHub account attachment"
envelope format "$XID_WITH_ATTACHMENT" | head -30

│ Added GitHub account attachment
│ {
│     XID(5f1c3d9e) [
│         'attachment': {
│             "BRadvoc8" [
│                 'dereferenceVia': URI(https://api.github.com/users/BRadvoc8)
│                 'isA': "GitHubAccount"
│                 ...
│             ]
│         } [
│             'vendor': "self"
│         ]
│         'dereferenceVia': URI(https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt)
│         'key': PublicKeys(a9818011, ...) [
│             ...
│         ]
│         'provenance': ProvenanceMark(3618aad3) [
│             ...
│         ]
│     ]
│ } [
│     'signed': Signature(Ed25519)
│ ]
```

The flags mirror what you used in previous tutorials: `--verify inception` checks the existing signature before modifying, `--sign inception` re-signs after adding the attachment, and the encryption flags protect your private keys and provenance generator.

Notice the attachment appears with `'vendor': "self"` marking who defined this payload format.

### Step 6: Advance Provenance Mark

When you modify a published XID, you advance the provenance sequence to signal a new version:

```
XID_UPDATED=$(envelope xid provenance next \
    --verify inception \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --password "$PASSWORD" \
    --encrypt-password "$PASSWORD" \
    "$XID_WITH_ATTACHMENT")

echo "Advanced provenance"
PROV_MARK=$(envelope xid provenance get "$XID_UPDATED")
provenance validate --format json-compact "$PROV_MARK" 2>&1 | grep -o '{.*}' | jq -r '.chains[0].sequences[0].end_seq'

│ Advanced provenance
│ 1
```

The real BRadvoc8 XID demonstrates this workflow with two commits:

- **Commit 1 (seq 0)**: Basic XID with dereferenceVia—the verifiable identity from Tutorial 02
- **Commit 2 (seq 1)**: Added GitHub attestation—the enhanced identity from this tutorial

This mirrors a realistic workflow. You publish your basic XID first (establishing your identity), then update it with attestations as you build credentials. Each update advances the sequence, creating an auditable history.

The sequence number tells Ben which version he has. If Ben fetches seq 0 but the URL now shows seq 1, he knows an update happened and can re-fetch. Tutorial 04 covers how Ben verifies the provenance sequence he receives.

> :book: **Provenance = Ordering, Not Timestamps**:
>
> The provenance mark establishes position in a chain starting from genesis. It doesn't prove *when* this happened—just the order. Temporal information comes from external sources: GitHub's server timestamps, signed commits, Ben's own fetch time. Tutorial 04 explores these temporal anchors.

> :brain: **Learn more**: The [Provenance Marks](../concepts/provenance-marks.md) concept doc explains the cryptographic chain structure and how sequence numbers provide ordering guarantees.

### Step 7: Export and Verify

Create the public version and verify the attachment is accessible:

```
# Export public version
PUBLIC_XID=$(envelope xid export --private elide --generator elide "$XID_UPDATED")

echo "Exported public XID"

# Verify attachment is present
ATTACHMENT=$(envelope xid attachment all "$PUBLIC_XID" | head -1)
if [ -n "$ATTACHMENT" ]; then
    echo "✅ Attachment found in public XID"
    echo ""
    echo "Attachment content:"
    envelope format "$ATTACHMENT" | head -15
else
    echo "❌ Attachment missing!"
fi

│ Exported public XID
│ ✅ Attachment found in public XID
│
│ Attachment content:
│ {
│     "BRadvoc8" [
│         'dereferenceVia': URI(https://api.github.com/users/BRadvoc8)
│         'isA': "GitHubAccount"
│         "createdAt": 2026-01-21T05:34:20Z
│         "sshSigningKeysURL": URI(https://api.github.com/users/BRadvoc8/ssh_signing_keys)
│         "sshSigningKey": SigningPublicKey(714b3b69, SSHPublicKey(f733cab9))
│         ...
│     ]
│ } [
│     'vendor': "self"
│ ]
```

The attachment survives export—it's part of the public XID that Ben will fetch.

### Step 8: Publish Updated XID

Update your publication location with the new version. If you're using a GitHub repository (as BRadvoc8 does), this means committing and pushing:

```
# Save the public XID to your repository
echo "$PUBLIC_XID" > /path/to/your-repo/xid.txt

# Commit with a signed commit (using the same SSH signing key)
cd /path/to/your-repo
git add xid.txt
git commit -S -s -m "Add XID with GitHub attestation"
git push

│ [main abc1234] Add XID with GitHub attestation
│  1 file changed, 1 insertion(+)
```

The signed commit (`-S`) creates another temporal anchor: GitHub will record when this commit was pushed and verify its signature against your registered signing key. This connects your XID publication to your GitHub identity.

> :warning: **Signed Commits Matter**:
>
> The `-S` flag signs the commit with your SSH signing key. This creates verifiable evidence that the same key in your XID attestation was used to publish the XID itself. If Ben sees your SSH key in the XID *and* sees that key signing commits to the XID repository, that's stronger evidence than either alone. Without `-S`, you're just claiming to own a key without demonstrating you can use it.

After pushing, the XID is live at your `dereferenceVia` URL. Anyone who fetches it can verify the attestation independently—which is exactly what Ben does in Tutorial 04.

---

## What You Accomplished

BRadvoc8 now has verifiable attestations:

- **GitHub account attachment** with SSH signing key
- **Proof-of-control** demonstrating key ownership at creation time
- **Verification pointer** (`dereferenceVia`) to GitHub's API
- **Signed commit** creating a temporal anchor on GitHub

### Trust Assessment

What can be verified now (without external checks):

| Check | Status | What It Proves |
|-------|--------|----------------|
| XID signature | ✅ Verifiable | Document integrity, self-consistency |
| Provenance chain | ✅ Verifiable | Update ordering, version history |
| Proof-of-control signature | ✅ Verifiable | Key holder signed the claim |
| Attachment structure | ✅ Verifiable | Data is well-formed |

What requires external verification (Tutorial 04):

| Check | Status | What It Would Prove |
|-------|--------|---------------------|
| SSH key on GitHub | ⏳ Not yet checked | Key is actually registered |
| Signed commits | ⏳ Not yet checked | Key is actively used |
| GitHub account exists | ⏳ Not yet checked | Account is real |

This is a *self-attestation*—Amira claiming she controls a GitHub account and SSH key. Ben has the information he needs to check these claims, but the checking happens in Tutorial 04.

The trust model is now richer: Tutorial 01 established that BRadvoc8 exists, Tutorial 02 made that existence verifiable and fresh, and now Tutorial 03 offers attestations that connect BRadvoc8 to real-world systems.

> :brain: **Making Stronger Claims**: This tutorial covers *account linkage*—proving you control a GitHub account. For making *skill and capability claims* that are more credible, see [Tutorial 05: Fair Witness Attestations](05-fair-witness-attestations.md), which teaches the methodology of specific, verifiable, evidence-backed claims.

## Appendix: Key Terminology

> **Attachment** - A vendor-qualified container for application-specific data in an XID. Uses `--vendor` to indicate who defined the format.
>
> **Self-Attestation** - A claim you make about yourself. Verifiable through external sources, but not independently trusted.
>
> **SSH Signing Key** - An SSH key used to sign Git commits. Different from authentication keys; GitHub maintains them at `/users/{user}/ssh_signing_keys`.
>
> **Proof-of-Control** - A signed statement proving key possession at a point in time. Temporal snapshot, not ongoing guarantee.
>
> **Provenance Sequence** - The version number in a provenance chain. Sequence 0 is genesis, sequence 1 is first update, etc. Provides ordering, not timestamps.

## Exercises

Try these to solidify your understanding:

**Building exercises (Amira's perspective):**

- Generate a new SSH signing key and create a proof-of-control for it.
- Build an attachment payload with different assertion types (try adding a website or email claim).
- Register your SSH signing key on GitHub and verify it appears in the API at `https://api.github.com/users/YOUR_USERNAME/ssh_signing_keys`.
- Practice the full workflow: add attachment, advance provenance, export public version.

**Verification exercises (Ben's perspective):**

- Extract the proof-of-control from an attachment and verify its signature.
- Tamper with a proof (change one character) and confirm verification fails.
- Compare two versions of an XID with different provenance sequences.
- Extract the SSH signing key text from an attachment and compare it to GitHub's API response.

## Example Scripts

A complete working script implementing this tutorial is available at `tests/03-offering-self-attestation-TEST.sh`. Run it to see all steps in action:

```
bash tests/03-offering-self-attestation-TEST.sh
```

This script creates a GitHub account attachment with SSH signing key and proof-of-control, demonstrating the complete self-attestation workflow.

The real BRadvoc8 XID uses separate scripts for each phase:

- `scripts/create-bradvoc8-xid-basic.sh` - Creates seq 0 XID (Tutorial 02 output)
- `scripts/create-bradvoc8-xid-attachment.sh` - Loads seq 0, adds attestation, advances to seq 1

## What's Next

Amira has *offered* her attestations. But claims without verification are just assertions. Ben needs to *check* whether the SSH key in her XID actually matches what's registered on GitHub, whether signed commits use the same key, and what temporal anchors tell him about when these claims became valid.

**Tutorial 04: Cross-Verification** shows Ben's perspective. He'll fetch Amira's updated XIDDoc, extract the GitHub attachment, query the GitHub API, verify commit signatures, and understand what this chain of evidence actually proves—and what it doesn't.

---

**Previous**: [Making Your XID Verifiable](02-making-your-xid-verifiable.md) | **Next**: [Cross-Verification](04-cross-verification.md)

===

This was in 02, but this is the first tutorial where we actually have a second edition XID, so something like it should go here instead

#### Detecting Stale Copies

What if someone gave Ben an old copy of the XID instead of the current one? He can compare provenance marks to detect this:

```
# Ben has two versions - one from a friend, one freshly fetched
# Compare their sequence numbers

# Simulate: OLD_MARK from friend's copy (sequence 0)
# Simulate: NEW_MARK from fresh fetch (sequence 1 after an update)

OLD_SEQ=0   # From stale copy
NEW_SEQ=1   # From fresh fetch

echo "Copy from friend:  sequence $OLD_SEQ"
echo "Fresh from URL:    sequence $NEW_SEQ"

if [ "$NEW_SEQ" -gt "$OLD_SEQ" ]; then
    echo "⚠️  Friend's copy is STALE - use the fresh version!"
fi

│ Copy from friend:  sequence 0
│ Fresh from URL:    sequence 1
│ ⚠️  Friend's copy is STALE - use the fresh version!
```

Higher sequence number means newer version. Ben should always fetch from `dereferenceVia` to ensure he has the current XIDDoc, especially before making trust decisions.

> :brain: **Learn more**: The [Provenance Marks](../concepts/provenance-marks.md) concept doc explains the cryptographic chain structure and how it prevents history falsification.
>
---

Add this in:

### Key Type Comparison

| Key Type | Purpose | Verified Against | Added In |
|----------|---------|------------------|----------|
| XID inception key | Signs XID document updates | XID itself | T01 |
| SSH signing key | Signs Git commits | GitHub's registry | T03 |
| Attestation key | Signs detached attestations | XID key list | T05 (now) |

--

THIS IS MY WORKING EDGES EXAMPLES:

--

NEW CODING

ATTESTATION_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
ATTESTATION_PUBKEYS=$(envelope generate pubkeys "$ATTESTATION_PRVKEYS")


AT_XID=$(envelope generate keypairs --signing ed25519 | \
    envelope xid new --nickname "BRadvoc8" --generator include --sign inception) 

XID=$(cat BRadvoc8-xid-public-seq0.envelope)
PASSWORD=$(cat BRadvoc8-xid.password)

CLAIM=$(envelope subject \
  type string \
  "Contributed mass spec visualization code to galaxyproject/galaxy (PR #12847, merged 2024)")
CLAIM=$(envelope assertion add pred-obj \
  known 'verifiableAt' \
  uri "https://github.com/galaxyproject/galaxy/pull/12847" "$CLAIM")

  XID_ID=$(envelope xid id $XID)
TARGET=$(envelope subject type ur "$XID_ID")
TARGET=$(envelope assertion add pred-obj known 'attestation' envelope $CLAIM $TARGET)

EDGE=$(envelope subject type string "coding-experience-1")
EDGE=$(envelope assertion add pred-obj known isA string "foaf:pastProject" "$EDGE")
EDGE=$(envelope assertion add pred-obj known source ur "$XID_ID" "$EDGE")
EDGE=$(envelope assertion add pred-obj known target envelope "$TARGET" "$EDGE")
WRAPPED_EDGE=$(envelope subject type wrapped $EDGE)
SIGNED_EDGE=$(envelope sign --signer "$ATTESTATION_PRVKEYS" "$WRAPPED_EDGE")


XID_WITH_EDGE=$(envelope xid edge add $SIGNED_EDGE $XID)      
