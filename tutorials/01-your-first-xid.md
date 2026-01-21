# Creating Your First XID

This tutorial demonstrates how to create a basic XID (eXtensible IDentifier) that enables pseudonymous contributions while maintaining security. It does so through the story of [Amira](https://w3c-ccg.github.io/amira/), a software developer with a politically sensitive background who wants to contribute to social impact projects without risking her professional position or revealing her identity.

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

Amira is a successful software developer working at a prestigious multinational bank in Boston. With her expertise in distributed systems security, she earns a comfortable living, but she wants more purpose in her work. She is considering contributing to social-impact programs, but she can't do so under her real name. That's because Amira's position is somewhat vulnerable. She's working on an H-1B visa, and in modern America, that could be revoked for any sort of activism. She also grew up in a politically tense region, and her work on social-impact projects could endanger family members back home. Yet she's deeply motivated to use her skills to help oppressed people globally. This tension between professional security and meaningful contribution creates a specific need.

Anonymous submissions could resolve these issues, and Amira already has a pseuodnymous identity: "BRadvoc8" (Basic Rights Advocate). However, anonymous contributions lack credibility. Project maintainers need confidence in the quality and provenance of code, especially for socially important applications. Amira needs a better solution, one that protects her identity while allowing her to build a verifiable reputation for her skills. This would allow her to build trust through the quality of her work rather than existing credentials and so establish a consistent presence that can evolve over time. 

On the advice of her friend Charlene, Amira investigates RISK, a network that connects developers with social-impact projects and protects participants' privacy. It uses a Blockchain Commons technology called [XIDs](../concepts/xid.md): they enable pseudonymous identity with progressive trust development, allowing Amira to safely collaborate on projects aligned with her values while maintaining separation between her pseudonymous contributions and her legal identity, protecting herself from adversaries who might target her or her family for her contributions. Through RISK, Amira can connect with project leaders such as Ben, who runs a women's services non-profit that Amira wishes to contribute to.

## Why XIDs Matter

XIDs provide significant advantages over standard cryptographic keys because they create a single stable identity, even if you have multiple keys for different devices and even if you rotate your keys. If something goes wrong, recovery mechanisms let you restore access to your identity (and so your reputation history).

XIDs support rich metadata: structured attestations, endorsements, and claims that describe your skills. Others can also make cryptographically verifiable claims about you through peer attestation. You can then selectively share different information with different parties, or use progressive trust to expand what you reveal to an individual over time, all while keeping other details private by eliding it. XIDs preserve the cryptographic integrity of the metadata even when portions are elided.

## Step 0: Setting Up Your Work Space

This tutorial depends on [`bc-envelope-cli`](https://github.com/BlockchainCommons/bc-envelope-cli-rust), a Rust-based command-line interface.

It can be easily installed using the `cargo` package management tool:
```
cargo install bc-envelope-cli
```

If you don't have `cargo` installed, see [_The Cargo Book_](https://doc.rust-lang.org/cargo/getting-started/installation.html) for easy installation instructions.

## Step 1: Create Your XID

Now that we understand why XIDs are valuable, let's help Amira create her "BRadvoc8" identity. This first tutorial is deliberately simple to get you started with the basics. In subsequent tutorials, we'll explore more advanced features like data minimization and rich persona structures.

A single `envelope` operation creates a complete XID that contains both private and public keys:

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

if [ $XID ]
then
  echo "Created your XID: $XID_NAME"
else
  echo "Error in XID creation"
fi

│ Created your XID: BRadvoc8
```

This command runs the `envelope` command twice.

1. It uses `envelope generate keypairs` to generate an Ed25519 keypair (the same algorithm SSH, git, and Signal use). This generates two URs, containing the private and public keys, respectively.
2. It uses `envelope xid new` to create a XID based on that Ed25519 keypair. This generates a XID Document (XIDDoc), which can be read as a Gordian Envelope.

Several arguments to the second command affect how the XID Document is produced:

1. Your private key is kept in your XID structure, but `--private encrypt` encrypts it, with `--encrypt-password` allowing its decryption with a password.
2. A set `--nickname` is added to the XID structure.
3. A provenance mark is added to the XID structure with `--generator encrypt`.
4. The entire XID is "wrapped" and then signed with your inception key thanks to `--sign inception`, which allows others to verify its authenticity.

> :warning: **Security Note**: Your XID contains your private keys (encrypted with your password). Though they are encrypted, you should still be leary of distributing a XID file that contains those private keys. Fortunately, you can elide (remove) that data, as described below. Obviously, you must also be careful to protect your password.

A XID builds on several other Blockchain Commons technologies, primarily [Gordian Envelope](../concepts/gordian-envelope.md) and Provenance Marks.

> :book: ***What is a provenance mark?*** A provenance mark is a forward-commitment hash chain. It will be used to record the evolution of this identity, showing that each version is linked to the previous one (and also, which is the newest version of a set).

> :book: **What is a wrapped envelope?** A Gordian Envelope is a package of informational triplets in the form of subject-predicate-object. An assertion (the predicate and the object) always apply to a specific subject. To make an assertion apply to more information, you wrap the envelope, and then apply the assertion to the wrapped envelope. Signatures are assertions, so for a signature to apply to an entire envelope (in this case, all of the XID information), it must be wrapped prior to signing.
 
### View your XID structure

The `envelope format` command can always be used to display a human-readable version of a Gordian Envelope, including a XID Document.

```
envelope format "$XID"

│ {
│     XID(c7e764b7) [
│         'key': PublicKeys(88d90933, SigningPublicKey(c7e764b7, Ed25519PublicKey(a1fae6ca)), EncapsulationPublicKey(a20a01e7, X25519PublicKey(a20a01e7))) [
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

Here's what all the sections mean:

- The curly braces `{ }` indicate wrapping, which is required for signing.
   - The signature occurs at the end under `signed`, with the `[ ]` indicating that it's an assertion on the `{ }` wrapped envelope. It confirms the entire document is cryptographically signed with the inception key.
-  `XID(c7e764b7)` is Amira's unique identifier, derived from her public key. This identifier never changes.
- The `PublicKeys(...)` section contains two public keys and is safe to share.
   - The `privateKey` section has been `ENCRYPTED`, indicating that the private keys are protected.
      -  The `'hasSecret': EncryptedKey(Argon2id)` notation indicates that the private keys are encrypted with Argon2id, a modern algorithm designed to resist brute-force attacks.
      - `salt` is a random value that further obscures its subject. It's applied to the wrapped `{ }` section including the privatekey (and also used later for the provenance mark.
   - The `allow` statement determines what access these keys have to this identity, as described in [key management](../concepts/key-management.md). By default, keys have total access (`All`).
   - The `nickname` is inside the `PublicKeys` section, not at the top level. That's because a nickname labels a key, not the XID Document. Later aeys could have different nicknames while maintaining the same XID identity.
- The `ProvenanceMark(...)` is a "genesis" mark: the first in a chain that tracks this identity's evolution.
   - The encrypted `provenanceGenerator` is the secret that created this mark and will create all future marks when Amira updates her XIDDoc. 

Note that a XID actually includes two keypairs that are bundled together: 
- a `Signing` keypair for creating and verifying signatures.
- an `Encapsulation` keypair for encryption and decryption.

Your inception key is the `SigningPublicKey`. This is the key that defines your XID. Your XID identifier (`XID(c7e764b7)`) is the SHA-256 hash of this inception signing key. This is the cryptographic foundation of your identity. This is why the identifier never changes: it's permanently bound to that original key, which is why that's called the inception key.

As shown, the public halves of the keypair are readable by anyone, while the private halves are encrypted with your password; the public halves are readable by anyone. This mirrors how SSH works with `id_rsa` and `id_rsa.pub`, except your XID bundles both into a single document.

#### A Review of Envelope Structure

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

#### A Review of Envelope Format

If you're familar 

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
