# Creating Your First XID

This tutorial introduces Amira, a software developer with a politically sensitive background who wants to contribute to social impact projects without risking her professional position or revealing her identity. By the end, you'll have created a basic XID (eXtensible IDentifier) that enables pseudonymous contributions while maintaining security.

**Time to complete: 10-15 minutes**

> **Related Concepts**: Before or after completing this tutorial, you may want to read about [XID Fundamentals](../concepts/xid.md) and [Gordian Envelope Basics](../concepts/gordian-envelope.md) to understand the theoretical foundations.

## Prerequisites

- Basic terminal/command line familiarity
- The [Gordian Envelope-CLI](https://github.com/BlockchainCommons/bc-envelope-cli-rust) tool installed (release 0.32.0 or later recommended)

## What You'll Learn

- How to create a basic XID for pseudonymous identity
- How to selectively encrypt just your private key (SSH-like model)
- How to create public versions of your XID using elision
- How to verify signatures and examine provenance marks
- How to maintain strong cryptographic integrity while sharing selectively
- How to understand XID file organization using secure naming conventions

## Amira's Story: Why Pseudonymous Identity Matters

Amira is a successful software developer working at a prestigious multinational bank in Boston. With her expertise in distributed systems security, she earns a comfortable living, but she wants more purpose in her work. On the advice of her friend Charlene, Amira discovers RISK, a network that connects developers with social impact projects while protecting participants' privacy.

Given Amira's background in a politically tense region, contributing openly to certain social impact projects could risk her visa status, professional position, or even the safety of family members back home. Yet she's deeply motivated to use her skills to help oppressed people globally. This tension between professional security and meaningful contribution creates a specific need.

However, Amira faces a dilemma: she can't contribute anonymously because anonymous contributions lack credibility. Project maintainers need confidence in the quality and provenance of code, especially for socially important applications. She needs a solution that protects her identity while allowing her to build a verifiable reputation for her skills.

Amira needs a technological solution that lets her share her security expertise without revealing her real identity, build trust through the quality of her work rather than existing credentials, and establish a consistent "BRadvoc8" (Basic Rights Advocate) presence that can evolve over time. She wants to connect with project leaders like Ben from the women's services non-profit while protecting herself from adversaries who might target her for her contributions.

This is where XIDs come in: they enable pseudonymous identity with progressive trust development, allowing Amira to safely collaborate on projects aligned with her values while maintaining separation between her pseudonymous contributions and her legal identity.

## Why XIDs Matter

XIDs provide significant advantages over standard cryptographic keys. Your XID identifier stays the same even when you rotate keys, giving you a stable identity that persists across key changes. You can selectively share different information with different parties—progressive trust—while keeping other details private.

XIDs support rich metadata: structured attestations, endorsements, and claims that describe your skills. Others can make cryptographically verifiable claims about you through peer attestation, and you can link multiple keys for different devices while maintaining a single identity. If something goes wrong, recovery mechanisms let you restore access without losing your reputation history. Most importantly, XIDs preserve cryptographic integrity even when portions are elided—you'll see this in action shortly.

This first tutorial is deliberately simple to get you started with the basics. In subsequent tutorials, we'll explore more advanced features like data minimization and rich persona structures.

## Step 0: Setting Up Your Work Space

This tutorial depends on [`bc-envelope-cli`](https://github.com/BlockchainCommons/bc-envelope-cli-rust), a Rust-based command-line interface.

It can be easily installed using the `cargo` package management tool:
```
cargo install bc-envelope-cli
```

If you don't have `cargo` installed, see [_The Cargo Book_](https://doc.rust-lang.org/cargo/getting-started/installation.html) for easy installation instructions.

## Step 1: Create Your XID

Now that we understand why XIDs are valuable, let's help Amira create her "BRadvoc8" identity.

Like creating an SSH key with `ssh-keygen`, this single operation creates your complete XID with both private and public keys:

```
XID_NAME=BRadvoc8
PASSWORD="Amira's strong password"

XID=$(envelope generate keypairs --signing ed25519 | \
    envelope xid new \
    --private encrypt \
    --encrypt-password "$PASSWORD" \
    --nickname "$XID_NAME" \
    --generator encrypt \
    --sign inception)

echo "Created your XID: $XID_NAME"

│ Created your XID: BRadvoc8
```

That single command did a lot of work. It generated an Ed25519 keypair (the same algorithm SSH, git, and Signal use), encrypted the private key with your password, added a provenance mark establishing the genesis of this identity, and signed the whole thing with your "inception" key so others can verify it's authentic.

The term "inception" refers to the signing public key that defines your XID from its very beginning. Your XID identifier (`XID(c7e764b7)`) is the SHA-256 hash of this inception signing key—the cryptographic foundation of your identity. This is why the identifier never changes: it's permanently bound to that original key.

You now have two keypairs bundled together: a signing keypair for creating and verifying signatures, and an encapsulation keypair for encryption and decryption. The private halves are encrypted with your password; the public halves are readable by anyone. This mirrors how SSH works with `id_rsa` and `id_rsa.pub`, except your XID bundles both into a single document.

> **Security Note**: Your XID contains your private keys (encrypted with your password). This is like your SSH `id_rsa` file - keep your passphrase secure! The same keys will always generate the same XID identifier deterministically.

**View your XID structure:**

```
envelope format "$XID"

│ {
│     XID(c7e764b7) [
│         'key': PublicKeys(88d90933, SigningPublicKey(c5385c8f, Ed25519PublicKey(a1fae6ca)), EncapsulationPublicKey(a20a01e7, X25519PublicKey(a20a01e7))) [
│             {
│                 'privateKey': ENCRYPTED [
│                     'hasSecret': EncryptedKey(Argon2id)
│                 ]
│             } [
│                 'salt': Salt
│             ]
│             'allow': 'All'
│             'nickname': "BRadvoc8"
│         ]
│         'provenance': ProvenanceMark(632330b4) [
│             {
│                 'provenanceGenerator': ENCRYPTED [
│                     'hasSecret': EncryptedKey(Argon2id)
│                 ]
│             } [
│                 'salt': Salt
│             ]
│         ]
│     ]
│ } [
│     'signed': Signature(Ed25519)
│ ]
```

The output reveals the structure of your XIDDoc (XID document). The curly braces `{ }` indicate wrapping, which is required for signing. Inside, you see `XID(c7e764b7)`, Amira's unique identifier derived from her public key. This identifier never changes as long as she uses the same keys.

The `PublicKeys(...)` section contains both public keys (safe to share), while `ENCRYPTED` marks where your private keys are protected. The `'hasSecret': EncryptedKey(Argon2id)` notation tells you Argon2id encryption is protecting your secrets—a modern algorithm designed to resist brute-force attacks.

Notice where the nickname `"BRadvoc8"` appears: it's inside the `PublicKeys` section, not at the top level. The nickname labels the key, not the document. This matters because Amira could later add additional keys with different nicknames while maintaining the same XID identity.

The `ProvenanceMark(...)` is the "genesis" mark—the first in a chain that tracks this identity's evolution. The encrypted provenance generator is the secret that created this mark and will create all future marks when Amira updates her XIDDoc. Finally, `'signed': Signature(Ed25519)` confirms the entire document is cryptographically signed with the inception key.

> **Notice the Quote Styles**:
>
> You see two quote styles in your XIDDoc:
>
> - **Single quotes** (`'key'`, `'nickname'`, `'All'`): **Known values** - standardized terms from the Gordian Envelope specification. These ensure different tools understand your XIDDoc the same way.
> - **Double quotes** (`"BRadvoc8"`, `"github"`): **Strings** - custom application data you define.
>
> **Known values can be predicates OR objects**:
>
> - As predicate: `'nickname': "BRadvoc8"` (known value `'nickname'` points to string `"BRadvoc8"`)
> - As object: `'allow': 'All'` (known value `'allow'` points to known value `'All'`)
>
> This distinction ensures interoperability: tools that understand envelopes correctly interpret known values. In a future tutorial, you'll add custom data using attachments to build BRadvoc8's verifiable attestations.

BRadvoc8 is now a production-ready XID. Her private keys are encrypted, there's a provenance mark establishing when this identity was created, and the whole document is cryptographically signed. The only thing left before sharing it is to remove the private keys—which is what we'll do next.

### Understanding the Envelope Structure

Before going further, you need to understand the pattern that organizes all envelope data. Every envelope has a **subject** (the main thing) and **assertions** (claims about that thing).

```
{
    XID(c7e764b7)          ← THE SUBJECT (the main thing)
    [
        'key': PublicKeys(...)             ← ASSERTION (predicate: object)
        'provenance': ProvenanceMark(...)  ← ASSERTION (predicate: object)
    ]
}
```

Your XID identifier `XID(c7e764b7)` is the subject. The assertions make claims about it: "this XID has these public keys" and "this XID has this provenance history." Each assertion is a predicate-object pair, like a simple sentence: subject has predicate pointing to object.

This pattern nests. Look inside the `'key'` assertion:

```
'key': PublicKeys(88d90933) [     ← Subject of this nested envelope
    'allow': 'All'                 ← Assertion about the key
    'privateKey': ENCRYPTED        ← Another assertion
]
```

The `PublicKeys` object is itself a subject with its own assertions. This recursive structure lets you build arbitrarily rich identity documents. In Tutorial 03, you'll add your GitHub account and SSH keys as attachments—vendor-qualified containers for application-specific data. For now, the key insight is that you can add, remove, or hide any assertion independently—which is exactly what we'll do next with the private keys.

### About the Abbreviated Display

The `envelope format` output shows abbreviated labels like `PublicKeys(32de0f2b)` and `ENCRYPTED` rather than raw cryptographic data. This is intentional—showing hundreds of bytes of base64 would obscure the structure. The hex codes in parentheses are digest fragments that let you quickly identify which key or encrypted blob you're looking at.

The abbreviations hide complexity: `PublicKeys` actually contains two separate keys (a signing key and an encapsulation key), `ENCRYPTED` contains the ciphertext plus Argon2id parameters, and `Salt` contains random bytes that make each XIDDoc's digest unique. You don't need to see this detail to work with XIDs, but knowing it's there helps when things go wrong.

> **Important**: The same keypairs always produce the same XID identifier because it's derived from the public key. If you regenerate from the same keys, you get the same identity. Lose the keys, lose the identity—just like SSH.

## Step 2: Creating a Public Version by Elision

Now Amira wants to create a shareable public version. Instead of creating a new XID, she **elides** (removes) the private key from her XID. This is a key envelope feature: **elision preserves the root hash**.

First, since the XID was automatically wrapped and signed with `--sign inception`, we need to unwrap it to access its assertions:

```
# Unwrap the signed XID to access its assertions
UNWRAPPED_XID=$(envelope extract wrapped "$XID")
```

Now find the digest of the encrypted private key:

```
# Find the key assertion
KEY_ASSERTION=$(envelope assertion find predicate known key "$UNWRAPPED_XID")
KEY_OBJECT=$(envelope extract object "$KEY_ASSERTION")

# Find the private key assertion within the key object
PRIVATE_KEY_ASSERTION=$(envelope assertion find predicate known privateKey "$KEY_OBJECT")
PRIVATE_KEY_DIGEST=$(envelope digest "$PRIVATE_KEY_ASSERTION")

echo "Found private key digest"

│ Found private key digest
```

Now elide the private key to create a public version:

```
PUBLIC_XID=$(envelope elide removing "$PRIVATE_KEY_DIGEST" "$XID")
echo "Created public version by eliding private key"

│ Created public version by eliding private key
```

View the public version:

```
envelope format "$PUBLIC_XID"

│ {
│     XID(c7e764b7) [
│         'key': PublicKeys(32de0f2b) [
│             'allow': 'All'
│             'nickname': "BRadvoc8"
│             ELIDED                      ← Private key removed
│         ]
│         'provenance': ProvenanceMark(632330b4) [
│             {
│                 'provenanceGenerator': ENCRYPTED [
│                     'hasSecret': EncryptedKey(Argon2id)
│                 ]
│             } [
│                 'salt': Salt
│             ]
│         ]
│     ]
│ } [
│     'signed': Signature(Ed25519)
│ ]
```

**Important distinction - XID identifier vs Envelope hash:**

Notice `XID(c7e764b7)` is the same as before. But **this doesn't prove elision preserved the hash!** Here's why:

- **`XID(c7e764b7)`** = XID identifier (derived from the inception public key)
  - Stays the same across ALL versions of this identity
  - Would be the same even if you completely changed the document
  - Identifies the **entity**, not the document version

- **Envelope digest** = Hash of the entire envelope structure
  - Changes when document content changes
  - THIS is what elision preserves
  - THIS is what allows signatures to verify

**Critical:** The XID identifier is persistent (based on inception public key), so seeing it unchanged proves nothing about hash preservation. We need to compare the **envelope digest**.

### Proving Elision Preserves the Envelope Hash

The tutorial claims that elision preserves the root hash. Let's **verify** this claim by comparing the digests:

```
# Get digest of original XID (with encrypted private key)
ORIGINAL_DIGEST=$(envelope digest "$XID")

# Get digest of public XID (without private key)
PUBLIC_DIGEST=$(envelope digest "$PUBLIC_XID")

# Compare them
echo "Original XID digest: $ORIGINAL_DIGEST"
echo "Public XID digest:   $PUBLIC_DIGEST"

if [ "$ORIGINAL_DIGEST" = "$PUBLIC_DIGEST" ]; then
    echo "✅ VERIFIED: Digests are identical - elision preserved the root hash!"
else
    echo "❌ ERROR: Digests differ"
fi

│ Original XID digest: ur:digest/hdcxzswfhsqdfmlujtjnkiylsfwshytlynfzglaeenksjtmweeqzswnebnlumdytfgqdlbgs
│ Public XID digest:   ur:digest/hdcxzswfhsqdfmlujtjnkiylsfwshytlynfzglaeenksjtmweeqzswnebnlumdytfgqdlbgs
│ ✅ VERIFIED: Digests are identical - elision preserved the root hash!
```

The digests are identical. You removed the private key, yet the hash didn't change. How is that possible?

### Why Elision Preserves the Hash

This seems impossible—normally, changing data changes its hash. But envelopes use a Merkle tree structure where each part has its own hash, and those hashes combine into the root hash. The root doesn't hash the content directly; it hashes the hashes.

```
Envelope Root Hash
    ├─ Subject Hash (XID identifier)
    ├─ Assertion 1 Hash ('key' → PublicKeys)
    ├─ Assertion 2 Hash ('provenance' → ProvenanceMark)
    └─ Assertion 3 Hash (nested 'privateKey' → ENCRYPTED)
```

When you elide, you remove the content but keep its hash in the calculation. The `'privateKey': ENCRYPTED` assertion had hash `def456...` before elision. After elision, the marker `ELIDED` still uses that same hash `def456...` in the root calculation. Same inputs, same root hash.

This is the foundation of selective disclosure. Amira signs her complete XIDDoc once, then creates different views by eliding different parts. Every view has the same root hash, so every view passes signature verification. She can show Ben her GitHub attestations while showing the public nothing—all from the same signed document.

> **Remember**: Don't confuse the XID identifier with the envelope digest. The XID identifier (`XID(c7e764b7)`) is the SHA-256 hash of the inception signing public key and never changes across document versions—it identifies Amira. The envelope digest identifies a specific document version and normally changes when you modify content. Elision is special: it's the only way to remove data without changing the digest.

## Step 3: Verification

Now let's verify both the signature and provenance on our XID:

```
# Extract public keys (the XID contains everything needed for verification)
KEY_ASSERTION=$(envelope assertion find predicate known key "$UNWRAPPED_XID")
KEY_OBJECT=$(envelope extract object "$KEY_ASSERTION")
PUBLIC_KEYS=$(envelope extract ur "$KEY_OBJECT")

# Verify the signature
envelope verify -v "$PUBLIC_KEYS" "$PUBLIC_XID" >/dev/null && echo "✅ Signature verified!"

│ ✅ Signature verified!
```

Now verify the provenance mark - notice we can verify from the **public** XID:

```
# Extract the provenance mark from the PUBLIC XID (no secrets needed!)
PROVENANCE_MARK=$(envelope xid provenance get "$PUBLIC_XID")

# Check that it's a valid genesis mark
provenance validate "$PROVENANCE_MARK"

│ ✅ (silent success - provenance check passed!)
```

Want to see what was verified? Get the detailed report:

```
# Show detailed assessment report
provenance validate --format json-pretty "$PROVENANCE_MARK"

│ {
│   "chains": [
│     {
│       "chain_id": "...",
│       "has_genesis": true,
│       "sequences": [
│         {
│           "start_seq": 0,
│           "end_seq": 0,
│           "marks": [
│             {
│               "mark": "ur:provenance/...",
│               "issues": []
│             }
│           ]
│         }
│       ]
│     }
│   ]
│ }
```

Both checks passed using only the public XID—no secrets required. The signature confirms this XIDDoc is authentically from BRadvoc8 (signed by the inception key). The provenance shows `has_genesis: true` and `sequence: 0`, meaning this is the first version in the chain with no issues found.

Notice the asymmetry: verifying signatures and provenance needs only public information, but creating signatures or advancing provenance requires secrets. This is why Amira can share her public XID freely—anyone can verify it, but only she can update it.

> **Remember**: The provenance mark is public, but the generator that advances it is encrypted. In Tutorial 02, you'll see how provenance lets Ben verify he has the current version of BRadvoc8.

## Reviewing the XID Creation Workflow

The single command you ran combined several operations that would otherwise take eight or more steps. Understanding what happened helps when things go wrong.

The `--private encrypt` flag encrypted your private keys with your password, following the SSH model: you can share the file freely because the secrets are protected. The public parts (nickname, public keys, provenance) remain readable to anyone.

The `--generator encrypt` flag encrypted the provenance generator—the secret that creates provenance marks. The generator created the initial "genesis" mark you see now, and will create all subsequent marks when Amira updates her XIDDoc. The mark itself is public (it timestamps when this identity version was created), but the generator must stay secret. Only someone with the generator can advance the provenance chain, proving updates are legitimate.

The `--sign inception` flag signed the entire document with the inception key. This is the sign-then-elide workflow: you sign the complete document (including encrypted private keys), then elide sensitive parts for sharing. Because elision preserves the hash, the signature verifies on both versions.

> **Learn more**: The [Signing and Verification](../concepts/signing.md) concept doc explains the cryptographic details. Tutorial 02 shows how provenance enables freshness verification.

## File Organization

For real-world usage, Amira will organize her files in a dedicated directory. The pattern mirrors SSH: `BRadvoc8-xid.envelope` is like `id_rsa` (keep secret), and `BRadvoc8-xid-public.envelope` is like `id_rsa.pub` (safe to share).

```
xid-20251117/
├── BRadvoc8-xid.envelope          # Complete XID with encrypted private keys
├── BRadvoc8-xid.format            # Human-readable version
├── BRadvoc8-xid-public.envelope   # Public XID (private keys elided)
└── BRadvoc8-xid-public.format     # Human-readable version
```

The `.envelope` files contain the binary serialized format that tools work with. The `.format` files are human-readable versions for inspection. The timestamp-based directory keeps versions organized.

Your complete XID file contains everything: private keys (encrypted), public keys, nickname, provenance, and signature. If you lose this file without a backup, you lose your identity—just like losing `id_rsa`. Unlike SSH keys, your XID also includes identity metadata (nickname, permissions, provenance history), making it a complete, self-contained identity document rather than just raw key material.

## The Bigger Picture

What Amira created is more than a keypair. BRadvoc8's identity is fully under her control—no service provider issued it, no platform can suspend it. This is self-sovereign identity: she owns the keys and the resulting document.

This XID implements pseudonymity rather than anonymity. Anonymous contributions lack credibility; project maintainers can't trust them. But BRadvoc8 can build reputation over time through verifiable contributions while protecting Amira's real-world identity. It's the same model authors use with pen names: Mark Twain built a reputation while Samuel Clemens stayed private.

The encrypted XID can live anywhere—USB drive, email, cloud storage, even printed as a QR code—because it's a self-contained cryptographic object. The infrastructure is in the document itself, not in some external system.

## Common Questions

### Q: Why Ed25519 instead of Schnorr or other algorithms?

**A:** Ed25519 is the industry standard (SSH, git, Signal) with wide compatibility and excellent security. Advanced users can use other algorithms (`--signing schnorr`, `--signing ecdsa`, `--signing mldsa44`), but Ed25519 is recommended for beginners.

### Q: What if I lose my XID file?

**A:** If you lose your `BRadvoc8-xid.envelope` file without a backup, **you lose your identity**. This is just like losing your SSH `id_rsa` file. There's no recovery mechanism without a backup - make sure to store encrypted copies in multiple secure locations.

### Q: Can I use this XID on multiple devices?

**A:** Yes! Copy your `BRadvoc8-xid.envelope` file to other devices. Since the private keys are encrypted, the file is reasonably safe to sync via cloud storage (as long as you have a strong passphrase!).

**Like SSH keys**: You can use the same XID across multiple devices, just like you might copy `id_rsa` to a new machine. The XID identifier stays the same regardless of which device you're using. Unlike SSH keys, you can revoke a key pair while keeping your XID persistent.

**Advanced (Tutorials ??-??)**: You can also create device-specific keys and delegate permissions, allowing each device to have its own key while maintaining a single XID identity.

## Key Terminology

> **XID (eXtensible IDentifier)** - The unique identifier for your identity, calculated as the SHA-256 hash of your inception signing public key. Persistent across all document versions because it's bound to that original key.
>
> **XIDDoc (XID Document)** - The envelope document containing an XID and its assertions (keys, provenance, metadata). This is what you create, update, and share.
>
> **Inception Key** - The signing public key that defines your XID from the beginning. Your XID identifier is the SHA-256 hash of this key's CBOR representation. The term "inception" emphasizes that this key establishes the identity at its origin.
>
> **Provenance Generator** - The secret that creates provenance marks. It created your genesis mark and will create all future marks when you update your XIDDoc. Separate from the inception key.
>
> **Subject** - The main thing an envelope describes; in XIDDocs, this is the XID identifier.
>
> **Assertion** - A predicate-object pair making a claim about the subject (e.g., `'key': PublicKeys(...)`).
>
> **Known Value** - Standardized term from the Gordian Envelope spec, shown in single quotes. Can be a predicate (`'key'`, `'nickname'`) or an object (`'All'`).
>
> **String** - Custom application data, shown in double quotes (`"BRadvoc8"`, `"github"`).
>
> **Elision** - Removing data while preserving the envelope's root hash, enabling selective disclosure with maintained cryptographic integrity.
>
> **Selective Disclosure** - Sharing only the information needed for a specific context. Sign once, create multiple views by eliding different parts, and every view verifies against the same signature.
>
> **Provenance Mark** - Cryptographic marker establishing the sequence position of a document version, forming a verifiable chain of identity evolution. The genesis mark (sequence 0) is the first in the chain. Provides ordering, not timestamps.
>
> **Envelope Digest** - The root hash of an envelope structure; preserved across elision, enabling signature verification on different views of the same document.

## What's Next

BRadvoc8 is now a basic, secure XID, but it has a problem: nobody can verify they have the current version. If she updates her XIDDoc tomorrow, how would Ben know he has stale data?

**Tutorial 02: Making Your XID Verifiable** shows how to solve this. Amira will add a `dereferenceVia` assertion pointing to where her XID is published, then advance the provenance chain. Ben can then fetch the latest version and verify it's fresh.

From there, Tutorial 03 adds attestations (GitHub account, SSH signing key), and Tutorial 04 shows Ben how to cross-verify those claims against external sources. Together, they enable the trust-building that comes in later tutorials.

## Exercises

Try these to solidify your understanding:

- Create your own XID with a pseudonym of your choice.
- Experiment with different passwords.
- Practice creating public versions by eliding private keys, then verify the signatures still work on the elided versions.
- Save your XID to a file and reload it to confirm nothing was lost.

## Example Script

A complete working script implementing this tutorial is available at `tests/01-your-first-xid-TEST.sh`. Run it to see all steps in action:

```
bash tests/01-your-first-xid-TEST.sh
```

This script will create all the files shown in the File Organization section with proper naming conventions and directory structure.

---

**Next Tutorial**: [Making Your XID Verifiable](02-making-your-xid-verifiable.md) - Publish your XID and enable freshness verification.
