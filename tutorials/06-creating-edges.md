# Tutorial 05: Creating Verifiable Attestations

A fresh, self-consistent XID proves that an identity exists and that you have the most up-to-date version, but not that the holder of the identity has skills worth trusting. One way to attest to skills is to link to an account at a service where the skills are visible (e.g., a programming hub, a writing hub, a Q&A service) and then prove control of that account. That's what Amira will do in this tutorial. She'll link her GitHub account and use her SSH signing key there as evidence that Ben can later verify using the external service.

**Time to complete**: ~15-20 minutes
**Difficulty**: Beginner
**Builds on**: Tutorials 01-02

> :brain: **Related Concepts**: This tutorial covers service-related attestation. For deeper understanding, see [Attestation & Endorsement Model](../concepts/attestation-endorsement-model.md) for the framework of claims and verification, [Fair Witness](../concepts/fair-witness.md) for making trustworthy assertions, and [Pseudonymous Trust Building](../concepts/pseudonymous-trust-building.md) for building reputation while maintaining privacy.

## Prerequisites

- Completed Tutorial 02 (have a published XIDDoc)
- The [Gordian Envelope-CLI](https://github.com/BlockchainCommons/bc-envelope-cli-rust) tool (already installed in Tutorial 01)
- The [Provenance Mark CLI](https://github.com/BlockchainCommons/provenance-mark-cli-rust) tool (already installed in Tutorial 01)
- A GitHub account with SSH signing key configured (or willingness to set one up)

## What You'll Learn

- How to link XIDs to online services
- How SSH signing keys differ from authentication keys
- How proof-of-control establishes temporal claims
- How to advance provenance after making changes
- How to detect stale XIDs with provenance marks
 
## Amira's Story: The Importance of Attestations

In Tutorials 01 and 02, Amira established that BRadvoc8 exists and is verifiable. But existence isn't enough. When Ben considers accepting code contributions from BRadvoc8, he's asking: "Can this person actually deliver quality work?" Proving that usually requires attestations or credentials. An attestation is typically someone saying "I did that" or "I can do that" or "I control that" (a self-attestation) or a third-party saying the same. If the third-party is recognized as someone who certifies attestations, the more official result is a credential.

So how can Amira prove to Ben that she has programming skills? She could seek out third-party attestations by asking others to witness her work or for peers to endorse her. But she doesn't yet have witnesses or peers for her BRadvoc8 identity. She could provide some details of her real-life job, but might threaten her anonymity. (We'll talk about "Fair Witness Attestations" in [Tutorial 05](05-fair-witness-attestations.md), about "Managing Sensitive Claims" in [Tutorial 06](06-managing-sensitive-claims.md), and about "Peer Endorsements" in [Tutorial 08](08-peer-endorsements.md).) That leaves her with things she can say herself, but she knows any self-attestation needs to backed up with proof for it to be meaningful to Ben.

Fortunately, the internet gives Amira a possibility: BRadvoc8 has already created repos of related work at GitHub, so she can link to her account at that service. Then, all she has to do is prove control of the BRadvoc8 GitHub account by showing that she controls the SSH signing key that was used for the cryptographic signature for each GitHub commit there. The result isn't an unverified self-attestation, but instead a verifiable link to an external service that Ben can use to check the evidence himself.

This is the difference between saying "I'm a developer" and showing a commit history. The XID becomes a bridge between Amira's pseudonymous identity and her demonstrable skills.

## Part I: Amira Adds Her GitHub Account

To link Amira's XID with her GitHub account, you will generate an SSH signing key, create a proof that you control it, bundle everything into a GitHub account envelope, link it as a service, and publish the updated XID with an updated provenance mark. When you're done, your XID will contain verifiable claims that Ben can check against external sources.

### Step 0: Verify Dependencies

Ensure you have the required tools:

```
envelope --version
provenance --version

│ bc-envelope-cli 0.33.0
│ provenance-mark-cli 0.6.0
```

If either tool is not installed, see [Tutorial 01 Step 0](01-your-first-xid.md#step-0-setting-up-your-workspace) for installation instructions.

> :warning: **Important: Your Output Will Differ**
>
> Your output will continue to differ, as discussed in Tutorial 01, because these examples use the **real published BRadvoc8 XID** at `github.com/BRadvoc8/BRadvoc8`. New differences that you will see in this Tutorial include:
>
> - Your timestamps and cryptographic digests will differ.
> - Your SSH key fingerprints will be unique.

### Step 1: Load Your XID

Load your XID from Tutorial 02:

```
XID_NAME="BRadvoc8"
PASSWORD="your-password-from-previous-tutorials"

# Load your XID (adjust path as needed)
XID=$(cat xid-*/BRadvoc8-xid.envelope)

echo "✅ Loaded XID: $XID_NAME"
envelope xid id "$XID"

│ ✅ Loaded XID: BRadvoc8
│ ur:xid/hdcxltkttdhsjztodsfygmfzdmvajocftohtrltabzbazmkbsalnhfhywfneaohycfynbejokkda
```

### Step 2: Generate SSH Signing Key

Amira needs an SSH keys specifically for signing Git commits, which is different from her SSH authentication keys and maintained seperately by GitHub. She can generate them with `envelope`, requesting keys of the type `--signing ssh-ed25519`, which is the preferred type for GitHub.

```
SSH_PRVKEYS=$(envelope generate prvkeys --signing ssh-ed25519)
SSH_PUBKEYS=$(envelope generate pubkeys "$SSH_PRVKEYS")
```
She can then `export` those keys to tranform that `UR` format used by envelope into an interoperable SSH format (_not_ raw Ed25519) that is recognized by GitHub:
```
SSH_EXPORT=$(envelope export "$SSH_PUBKEYS")

echo "✅ Generated SSH signing key:"
echo "$SSH_EXPORT"
```

│ ✅ Generated SSH signing key:
│ ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiOtuf9hwDBjNXyjvjHMKeLQKyzT8GcH3tLvHNKrXJe

This is what you would then [upload to GitHub](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account) as an SSH signing key ... but you don't actually have to for these tutorials because we'll test against the [existing BRadvoc8 account](https://github.com/BRadvoc8/BRadvoc8) in the next tutorial when we discuss ["Cross Verification"](04-cross-verification.md).

> :book: **SSH Signing vs SSH Authentication**: GitHub has two separate SSH key registries. Authentication keys (`/users/{user}/keys`) control access to repositories. Signing keys (`/users/{user}/ssh_signing_keys`) verify commit signatures. Amira is adding a signing key. It proves that her commits are authentic, not that she can push to repos.

#### Optional Alternative: Use An Existing Key

In the "story" of these tutorials, Amira created her SSH key at some time in the past, uploaded it to GitHub as a signing key on May 2025, and has been signing commits with it for projects that fall into a similar public-good space as the work that Amira might do for Ben at SisterSpaces. So she needs to access that key and make it available on the command-line for the XID work she's going to do.

If you already have an SSH signing key registered on GitHub, you can import it from your local files instead of generating a new one. The following commands will fill your environmental variables from an existing key (with the file name changed as appropriate):

```
SSH_PRVKEYS=$(cat ~/.ssh/your_signing_key | envelope import)
SSH_PUBKEYS=$(cat ~/.ssh/your_signing_key.pub | envelope import)
SSH_EXPORT=$(cat ~/.ssh/your_signing_key.pub)
```

#### A Review of Key Usage 

Amira now has multiple keys serving different purposes:

| Key | Purpose | Compromise Impact | Location |
|-----|---------|-------------------|----------|
| XID signing key | Signs XID document updates | Identity compromised | XID |
| XID key agreement key | Establishes shared secrets for encryption | Past messages exposed | XID |
| SSH signing key | Signs Git commits | Code authorship forged | Local |

Why separate keys? Compromise containment. Each key serves one purpose, limiting damage from any single compromise. For example, if Amira's SSH key is stolen, an attacker can forge commits, but her XID identity remains intact. She can revoke the compromised SSH key and add a new one without losing her identity or reputation history. 

Even the XID signing key can be rotated if compromised. You can add a new XID signing key and revoke the old one while keeping the same XID identifier. Your identity persists across key changes.

### Step 3: Create Proof-of-Control

You don't just want to add Amira's SSH signing key to her XID. That would not prove that Amira controls the signing key (and therefore the GitHub account where the key is used to sign commits). Amira can prove that she controls the GitHub SSH signing key by creating a signed statement declaring ownership at a declared point in time. This will be the next thing you'll create.

```
CURRENT_DATE=$(date -u +"%Y-%m-%d")
PROOF_STATEMENT=$(envelope subject type string "$XID_NAME controls this SSH key on $CURRENT_DATE")
PROOF=$(envelope sign --signer "$SSH_PRVKEYS" "$PROOF_STATEMENT")

echo "✅ Created proof-of-control"
envelope format "$PROOF"

│ Created proof-of-control
│ "BRadvoc8 controls SSH signing key registered on GitHub as of 2026-01-21" [
│     'signed': Signature(SshEd25519)
│ ]
```

This proof is created as an envelope with a subject (the statement) and an assertion (the signature).  We'll be continuing to build out a larger envelope in the next step before attaching it to the XID. With this proof, Amira definitively demonstrates that she controls the SSH signing key. (She signed with it!) The date isn't verified, but it has been attested to by the holder of the SSH signing key. If you trust the signer, you trust the date; if you don't trust the signer, you don't.

> :book: **How Could You Prove the Time?** The above simply shows that the witness (the signer) attests to a specific time. To actually prove a time requires a trusted third party. One method is to hash a document, put the hash on the blockchain, and then refer to the hash. Another is to use a Time Stamp Authority (TSA) as defined in [RFC 3161](https://www.ietf.org/rfc/rfc3161.txt).

#### Verifying the Proof

Ben can later verify this proof using the public SSH signing key that we will embed in the XID.

```
# Verify the proof signature
if envelope verify -v "$SSH_PUBKEYS" "$PROOF" >/dev/null 2>&1; then
    echo "✅ Proof signature verified - key holder signed this statement"
else
    echo "❌ Proof signature FAILED"
fi

│ ✅ Proof signature verified - key holder signed this statement
```

This confirms the statement was signed by whoever controls the SSH private key. It doesn't prove *who* that is, just that they held the key.

If the proof were tampered with, the signature would no longer verify:

```
TAMPERED_PROOF=$(echo "$PROOF" | sed 's/2026-01-21/2025-01-01/')

if envelope verify -v "$SSH_PUBKEYS" "$TAMPERED_PROOF" >/dev/null 2>&1; then
    echo "✅ Signature verified"
else
    echo "❌ Signature FAILED - tampering detected\!"
fi

│ ❌ Signature FAILED - tampering detected!
```

> :warning: **Temporal Limitation**: Even if the date check were verified, the proof is a snapshot, not an ongoing guarantee. It proves Amira controlled the key when she signed, not that she controls it now or tomorrow. Keys can be compromised. Ben will need to check external sources (GitHub's current registry, recent signed commits) for stronger assurance. Tutorial 04 covers this verification.

### Step 4: Build GitHub Account Payload

You can now assemble a complete envelope with all of the information about Amira's GitHub account, including the `$PROOF` that you earlier created and another pair of self-claimed timestamps. If any of this use of envelope subjects and assertions is unfamiliar, you should consult the [Gordian Envelope concepts document](../concepts/gordian-envelope.md).

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
