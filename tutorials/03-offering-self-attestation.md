# Offering Self-Attestation

In Tutorial 02, Amira made her BRadvoc8 XIDDoc verifiable by publishing it at a stable URL. Ben can now fetch the current version and verify it's fresh. But there's still a gap: Ben doesn't know if BRadvoc8 can actually do anything useful. A fresh, self-consistent XID proves the identity exists—not that it has skills worth trusting.

This tutorial shows how Amira adds attestations to her XID—verifiable claims about her activities. She'll link her GitHub account and SSH signing key, creating evidence that Ben can later verify against external sources.

**Time to complete: 15-20 minutes**

> **Related Concepts**: This tutorial covers self-attestation. For deeper understanding, see [Attestation & Endorsement Model](../concepts/attestation-endorsement-model.md) for the framework of claims and verification, [Fair Witness](../concepts/fair-witness.md) for making trustworthy assertions, and [Pseudonymous Trust Building](../concepts/pseudonymous-trust-building.md) for building reputation while maintaining privacy.

## Prerequisites

- Completed Tutorial 02 (have a published XIDDoc)
- The [Gordian Envelope-CLI](https://github.com/BlockchainCommons/bc-envelope-cli-rust) tool installed (release 0.32.0 or later)
- A GitHub account with SSH signing key configured (or willingness to set one up)

## What You'll Learn

- How attachments differ from raw assertions in XIDs
- How to add vendor-qualified payloads to your XIDDoc
- How SSH signing keys differ from authentication keys
- How proof-of-control establishes temporal claims
- How to advance provenance after making changes

## Why Credentials Matter

In Tutorials 01 and 02, Amira established that BRadvoc8 exists and is verifiable. But existence isn't enough. When Ben considers accepting code contributions from BRadvoc8, he's asking: "Can this person actually deliver quality work?"

Amira needs to connect her XID to real-world evidence of her skills. Her GitHub account shows her contributions. Her SSH signing key lets her sign commits cryptographically, proving each commit came from BRadvoc8. These aren't just claims—they're verifiable links to external systems where Ben can check the evidence himself.

This is the difference between saying "I'm a developer" and showing a commit history. The XID becomes a bridge between Amira's pseudonymous identity and her demonstrable skills.

---

## Part I: Understanding Attachments

Before adding attestations, you need to understand how XIDs handle structured data.

### Attachments vs Raw Assertions

In Tutorial 01, you saw assertions like `'key': PublicKeys(...)` and `'provenance': ProvenanceMark(...)`. These are *known* assertions—standardized parts of the XID specification that tools understand.

You might think you can add arbitrary assertions the same way:

```
# This WON'T work for XIDs:
envelope assertion add pred-obj string "github" string "BRadvoc8" "$XID"
```

But XIDs have structure. The XID layer provides specific operations (`xid key add`, `xid resolution add`, `xid attachment add`) rather than raw assertion manipulation. This ensures XIDDocs remain well-formed and interoperable.

For custom data like GitHub accounts, XIDs use **attachments**—vendor-qualified containers for application-specific payloads:

```
envelope xid attachment add \
    --vendor "self" \
    --payload "$GITHUB_ACCOUNT" \
    ...
```

The `--vendor` qualifier indicates who defined this attachment format. Using `"self"` means Amira defined it for her own use. Organizations might use domain names (`"com.example"`) for their custom formats.

### Why Attachments?

Attachments solve several problems. They namespace custom data so different applications don't collide. They keep the XID core clean—your identity isn't cluttered with application-specific details. And they're explicitly optional: tools that don't understand an attachment can safely ignore it while still processing the XID.

Most importantly, attachments allow **arbitrary predicates**. The XID core has a fixed schema—you use specific commands like `xid key add` and `xid resolution add` for standard fields. But inside an attachment payload, you define your own structure with whatever predicates make sense for your domain. GitHub accounts need `sshSigningKey` and `sshSigningKeysURL`; a professional certification might need `issuer`, `expirationDate`, and `credentialID`. Attachments are where domain-specific schemas live.

Think of attachments as labeled boxes you attach to your identity. The labels tell others what's inside and who packed it. Ben might understand `vendor: "self"` GitHub attachments but ignore `vendor: "com.example"` attachments he doesn't recognize.

---

## Part II: Amira Adds Her GitHub Account

Now let's add Amira's GitHub account as an attachment.

> ⚠️ **Important: Your Output Will Differ**
>
> From this point forward, tutorial examples show output from the **real published BRadvoc8 XID** at `github.com/BRadvoc8/BRadvoc8`. When you follow along with your own XID:
>
> - Your XID identifier (e.g., `XID(c8eb0124)`) will be different
> - Your timestamps and cryptographic digests will differ
> - Your SSH key fingerprints will be unique
>
> **This is expected.** The structure and workflow remain the same—only the specific values change. Focus on understanding what each step accomplishes, not matching exact output.

### Step 1: Set Up Your Environment

Load your XID from Tutorial 02:

```
XID_NAME="BRadvoc8"
PASSWORD="your-password-from-previous-tutorials"

# Load your XID (adjust path as needed)
XID=$(cat xid-*/BRadvoc8-xid.envelope)

echo "Loaded XID: $XID_NAME"
envelope xid id "$XID"

│ Loaded XID: BRadvoc8
│ ur:xid/hdcxltkttdhsjztodsfygmfzdmvajocftohtrltabzbazmkbsalnhfhywfneaohycfynbejokkda
```

### Step 2: Generate an SSH Signing Key

Amira needs an SSH key specifically for signing Git commits. This is different from SSH authentication keys—GitHub maintains them separately.

```
# Generate SSH signing keypair (Ed25519 via SSH format)
SSH_PRVKEYS=$(envelope generate prvkeys --signing ssh-ed25519)
SSH_PUBKEYS=$(envelope generate pubkeys "$SSH_PRVKEYS")

# Export the public key in standard SSH format
SSH_EXPORT=$(envelope export "$SSH_PUBKEYS")

echo "Generated SSH signing key:"
echo "$SSH_EXPORT"

│ Generated SSH signing key:
│ ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiOtuf9hwDBjNXyjvjHMKeLQKyzT8GcH3tLvHNKrXJe
```

> **SSH Signing vs Authentication**:
>
> GitHub has two separate SSH key registries. Authentication keys (`/users/{user}/keys`) control access to repositories. Signing keys (`/users/{user}/ssh_signing_keys`) verify commit signatures. Amira is adding a signing key—it proves her commits are authentic, not that she can push to repos.

The `envelope generate prvkeys --signing ssh-ed25519` command creates keys in SSH format rather than raw Ed25519. This matters because Git's signature verification expects SSH-formatted keys.

> **Using an Existing SSH Key**:
>
> If you already have an SSH signing key registered on GitHub, you can import it instead of generating a new one:
>
> ```
> SSH_PRVKEYS=$(cat ~/.ssh/your_signing_key | envelope import)
> SSH_PUBKEYS=$(cat ~/.ssh/your_signing_key.pub | envelope import)
> SSH_EXPORT=$(cat ~/.ssh/your_signing_key.pub)
> ```
>
> The real BRadvoc8 XID uses an existing key that was registered on GitHub in May 2025.

> **Key Separation**:
>
> Amira now has multiple keys serving different purposes:
>
> | Key | Purpose | Compromise Impact |
> |-----|---------|-------------------|
> | XID signing key | Signs XID document updates | Identity compromised |
> | XID key agreement key | Establishes shared secrets for encryption | Past messages exposed |
> | SSH signing key | Signs Git commits | Code authorship forged |
>
> Why separate keys? Compromise containment. If Amira's SSH key is stolen, an attacker can forge commits—but her XID identity remains intact. She can revoke the compromised SSH key and add a new one without losing her identity or reputation history. Each key serves one purpose, limiting damage from any single compromise.
>
> Even the XID signing key can be rotated if compromised—you can add a new signing key and revoke the old one while keeping the same XID identifier. Your identity persists across key changes.

### Step 3: Create a Proof-of-Control

Before adding the key to her XID, Amira creates a proof that she controls it. This is a signed statement declaring ownership at a specific point in time:

```
# Get current date
CURRENT_DATE=$(date -u +"%Y-%m-%d")

# Create and sign a proof-of-control statement
PROOF_STATEMENT=$(envelope subject type string "$XID_NAME controls this SSH key on $CURRENT_DATE")
PROOF=$(envelope sign --signer "$SSH_PRVKEYS" "$PROOF_STATEMENT")

echo "Created proof-of-control"
envelope format "$PROOF"

│ Created proof-of-control
│ "BRadvoc8 controls SSH signing key registered on GitHub as of 2026-01-21" [
│     'signed': Signature(SshEd25519)
│ ]
```

This proof demonstrates that whoever holds the SSH private key signed a statement claiming association with BRadvoc8 on this date.

> **Temporal Limitation**:
>
> This proof is a snapshot, not an ongoing guarantee. It proves Amira controlled the key when she signed—it doesn't prove she controls it now, or that she'll control it tomorrow. Keys can be compromised. Ben will need to check external sources (GitHub's current registry, recent signed commits) for stronger assurance. Tutorial 04 covers this verification.

### Step 4: Build the GitHub Account Payload

Now assemble the attachment payload—all the information about Amira's GitHub presence:

```
# Build the GitHub account structure
GITHUB_ACCOUNT=$(envelope subject type string "$XID_NAME")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj known isA string "GitHubAccount" "$GITHUB_ACCOUNT")
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
│ "BRadvoc8" [
│     'dereferenceVia': URI(https://api.github.com/users/BRadvoc8)
│     'isA': "GitHubAccount"
│     "createdAt": 2026-01-21T05:34:20Z
│     "sshSigningKeysURL": URI(https://api.github.com/users/BRadvoc8/ssh_signing_keys)
│     "sshSigningKey": SigningPublicKey(714b3b69, SSHPublicKey(f733cab9))
│     "sshSigningKeyProof": "BRadvoc8 controls SSH signing key registered on GitHub as of 2026-01-21" [
│         'signed': Signature(SshEd25519)
│     ]
│     "sshSigningKeyText": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiOtuf9hwDBjNXyjvjHMKeLQKyzT8GcH3tLvHNKrXJe"
│     "updatedAt": 2026-01-21T05:34:20Z
│ ]
```

> **Why This Structure?**
>
> The `dereferenceVia` URL points to the GitHub account itself (not the signing keys) because `isA` declares this is a "GitHubAccount". In envelope design, `dereferenceVia` must point to the authoritative source of whatever the subject claims to be—the type and the dereference target must match semantically. If someone fetches the `dereferenceVia` URL expecting a GitHub account, they should get account information, not a list of SSH keys.
>
> The signing keys endpoint goes in a custom predicate (`sshSigningKeysURL`) since it's verification data *about* the account, not the account itself. This is the flexibility attachments provide—you define whatever predicates your domain needs. We use `known` predicates (`isA`, `dereferenceVia`) for standard envelope semantics and `string` predicates for domain-specific data like `sshSigningKey` and `sshSigningKeysURL`. Notice the consistent `sshSigning*` prefix—related fields should share naming patterns.
>
> Both `createdAt` and `updatedAt` are included even though they're identical now. When Amira later updates this attestation (perhaps rotating her SSH key), `createdAt` stays fixed while `updatedAt` changes. This lets Ben distinguish "how long has this claim existed?" from "when was it last verified?"

Notice what we included: the account name as subject, a type marker (`isA: "GitHubAccount"`), a verification URL (`dereferenceVia` pointing to GitHub's API), the public key in both structured (`ur`) and text formats, the proof-of-control, and timestamps.

The `dereferenceVia` URI is particularly important—it tells Ben exactly where to check whether this key is actually registered on GitHub. That verification happens in Tutorial 04.

### Step 5: Add the Attachment to Your XID

Now add this payload as an attachment to your XID:

```
XID_WITH_ATTACHMENT=$(envelope xid attachment add \
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

### Step 6: Advance Provenance

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

> **Provenance = Ordering, Not Timestamps**:
>
> The provenance mark establishes position in a chain starting from genesis. It doesn't prove *when* this happened—just the order. Temporal information comes from external sources: GitHub's server timestamps, signed commits, Ben's own fetch time. Tutorial 04 explores these temporal anchors.

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

### Step 8: Publish the Updated XID

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

After pushing, the XID is live at your `dereferenceVia` URL. Anyone who fetches it can verify the attestation independently—which is exactly what Ben does in Tutorial 04.

---

## What You Accomplished

BRadvoc8 now has verifiable attestations:

- **GitHub account attachment** with SSH signing key
- **Proof-of-control** demonstrating key ownership at creation time
- **Verification pointer** (`dereferenceVia`) to GitHub's API
- **Signed commit** creating a temporal anchor on GitHub

This is a *self-attestation*—Amira claiming she controls a GitHub account and SSH key. It's not yet *verified*. Ben has the information he needs to check these claims, but the checking happens in Tutorial 04.

The trust model is now richer: Tutorial 01 established that BRadvoc8 exists, Tutorial 02 made that existence verifiable and fresh, and now Tutorial 03 offers attestations that connect BRadvoc8 to real-world systems.

## Key Terminology

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

- Generate a new SSH signing key and create a proof-of-control for it.
- Build an attachment payload with different assertion types (try adding a website or email).
- Register your SSH signing key on GitHub and verify it appears in the API.
- Practice the full workflow: add attachment, advance provenance, export public version.

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
