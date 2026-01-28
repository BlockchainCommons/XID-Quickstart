# Creating Your First XID

This tutorial demonstrates how to create a basic XID (eXtensible IDentifier) that enables pseudonymous contributions while maintaining security. It does so through the story of [Amira](https://w3c-ccg.github.io/amira/), a software developer with a politically sensitive background who wants to contribute to social impact projects without risking her professional position or revealing her identity.

**Time to complete**: ~10-15 minutes
**Difficulty**: Beginner

> **Related Concepts**: Before or after completing this tutorial, you may want to read about [XID Fundamentals](../concepts/xid.md) and [Gordian Envelope Basics](../concepts/gordian-envelope.md) to understand the theoretical foundations.

## Prerequisites

- Basic terminal/command line familiarity
- The [Gordian Envelope CLI](https://github.com/BlockchainCommons/bc-envelope-cli-rust) tool installed (release 0.32.0 or later recommended)
- The [Provenance Mark CLI](https://github.com/BlockchainCommons/provenance-mark-cli-rust) (release 0.6.0 or later recommended)

## What You'll Learn

- How to create a basic XID for pseudonymous identity
- How to selectively encrypt just your private key (SSH-like model)
- How to create public views of your XID using elision
- How to verify signatures and examine provenance marks
- How to maintain strong cryptographic integrity while sharing selectively
- How to understand XID file organization using secure naming conventions

## Amira's Story: Why Pseudonymous Identity Matters

Amira is a successful software developer working at a prestigious multinational bank in Boston. With her expertise in distributed systems security, she earns a comfortable living, but she wants more purpose in her work. She is considering contributing to social-impact programs, but she can't do so under her real name. That's because Amira's position is somewhat vulnerable. She's working on an H-1B visa, and in modern America, that could be revoked for any sort of activism. She also grew up in a politically tense region, and her work on social-impact projects could endanger family members back home. Yet she's deeply motivated to use her skills to help oppressed people globally. This tension between professional security and meaningful contribution creates a specific need.

Anonymous submissions could resolve these issues, and Amira already has a pseudonymous identity: "BRadvoc8" (Basic Rights Advocate). However, anonymous contributions lack credibility. Project maintainers need confidence in the quality and provenance of code, especially for socially important applications. Amira needs a better solution, one that protects her identity while allowing her to build a verifiable reputation for her skills. This would allow her to build trust through the quality of her work rather than existing credentials and so establish a consistent presence that can evolve over time.

On the advice of her friend Charlene, Amira investigates RISK, a network that connects developers with social-impact projects and protects participants' privacy. It uses a Blockchain Commons technology called [XIDs](../concepts/xid.md): these "eXtensible IDentifiers" enable pseudonymous identity with progressive trust development, allowing Amira to safely collaborate on projects aligned with her values while maintaining separation between her pseudonymous contributions and her legal identity, protecting herself from adversaries who might target her or her family for her contributions. Through RISK, Amira can connect with project leaders such as Ben, who runs a women's services non-profit that Amira wishes to contribute to.

## Why XIDs Matter

XIDs provide significant advantages over standard cryptographic keys because they create a single stable identity, even if you have multiple keys for different devices and even if you rotate your keys. If something goes wrong, recovery mechanisms let you restore access to your identity (and so your reputation history).

XIDs support rich metadata, which can include structured attestations, endorsements, and claims that describe your skills. Others can also make cryptographically verifiable claims about you through peer attestation. You can then selectively share different information with different parties, or use progressive trust to expand what you reveal to an individual over time, all while keeping other details private by eliding it. XIDs preserve the cryptographic integrity of the metadata even when portions are elided.

## Step 0: Setting Up Your Workspace

This tutorial depends on [`bc-envelope-cli`](https://github.com/BlockchainCommons/bc-envelope-cli-rust), a Rust-based command-line interface. It can be easily installed using the `cargo` package management tool:

```
cargo install bc-envelope-cli
```

Though it's only used for a minor element here, you should also install the Provenance Mark CLI with `cargo` as it'll be referenced throughout these tutorials:

```
cargo install provenance-mark-cli
```

If you don't have `cargo` installed, see [_The Cargo Book_](https://doc.rust-lang.org/cargo/getting-started/installation.html) for easy installation instructions.

## Step 1: Creating Your XID

Now that you understand why XIDs are valuable, you're ready to help Amira create her "BRadvoc8" identity. This first tutorial is deliberately simple to get you started with the basics. In subsequent tutorials, we'll explore more advanced features including the creation of rich persona structures.

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
  echo "✅ Created your XID: $XID_NAME"
else
  echo "❌ Error in XID creation"
fi

│ ✅ Created your XID: BRadvoc8
```

This command runs the `envelope` CLI twice:

1. `envelope generate keypairs` creates an Ed25519 keypair (the same algorithm SSH, git, and Signal use). This generates two URs, containing the private and public keys, respectively.
2. `envelope xid new` creates a XID based on that Ed25519 keypair. This generates a XID Document (XIDDoc), which can be read as a Gordian Envelope.

Several arguments to the second command affect how the XID Document is produced:

1. `--private encrypt` encrypts the private keys, which are stored in the XID Document, with `--encrypt-password` allowing decryption with a password.
2. `--nickname` adds an identity label to the XID structure.
3. `--generator encrypt` adds an provenance mark to the XID structure, with its secret being encrypted.
4. `--sign inception` wraps and signs the entire XID, allowing others to verify its authenticity.

> :warning: **Private Keys On Board**: Your XID contains your private keys (encrypted with your password). Though they are encrypted, you should still be wary of distributing a XID file that contains those private keys. Fortunately, you can elide (remove) that data, as described below. Obviously, you must also be careful to protect your password.

A XID builds on several other Blockchain Commons technologies, primarily [Gordian Envelope](../concepts/gordian-envelope.md) and Provenance Marks.

> :book: **What is a provenance mark?** A provenance mark is a forward-commitment hash chain. It will be used to record the evolution of this identity, showing that each edition is linked to the previous one (and also, which is the newest edition of a set).

> :book: **What is a wrapped envelope?** A Gordian Envelope is a package of informational triplets in the form of subject-predicate-object. An assertion (the predicate and the object) always applies to a specific subject. To make an assertion apply to more information, you wrap the envelope, and then apply the assertion to the wrapped envelope. Signatures are assertions, so for a signature to apply to an entire envelope (in this case, all of the XID information), the envelope must be wrapped prior to signing.

> :brain: **Learn more**: The [Signing and Verification](../concepts/signing.md) concept doc explains the cryptographic details of many of these elements.

### View Your XID Structure

The `envelope format` command can always be used to display a human-readable version of a Gordian Envelope, including a XID Document:

```
envelope format "$XID"

│ {
|    XID(5f1c3d9e) [
│         'key': PublicKeys(a9818011, SigningPublicKey(5f1c3d9e, Ed25519PublicKey(b2c16ea3)), EncapsulationPublicKey(96209c0f, X25519PublicKey(96209c0f))) [
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
│         'provenance': ProvenanceMark(1896ba49) [
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

Here's what the individual parts of that "formatting" mean:

- The curly braces `{ }` indicate wrapping, which is required for signing.
   - The signature occurs at the end under `signed`, with the `[ ]` indicating that it's an assertion on the `{ }` wrapped envelope. It confirms the entire document is cryptographically signed with the inception key.
- `XID(5f1c3d9e)` is Amira's unique identifier, derived from her public key. This identifier never changes.
- The `PublicKeys(...)` section contains two public keys and is safe to share.
   - The `privateKey` section has been `ENCRYPTED`, indicating that the private keys are protected.
      - The `'hasSecret': EncryptedKey(Argon2id)` notation indicates that the private keys are encrypted with Argon2id, a modern algorithm designed to resist brute-force attacks.
      - `salt` is a random value that further obscures its subject.
   - The `allow` statement determines what access these keys have to this identity, as described in [key management](../concepts/key-management.md). By default, keys have total access (`All`).
   - The `nickname` is inside the `PublicKeys` section, not at the top level. That's because a nickname labels a key, not the XID Document. Later keys could have different nicknames while maintaining the same XID identity.
- The `ProvenanceMark(...)` is a "genesis" mark: the first in a chain that tracks this identity's evolution.
   - The encrypted `provenanceGenerator` is the secret that created this mark and will create all future marks when Amira updates her XID Document.

Note that a XID actually includes two keypairs that are bundled together:
- a `Signing` keypair for creating and verifying signatures.
- an `Encapsulation` keypair for encryption and decryption.

As shown, the public halves of the keypairs are readable by anyone, while the private halves are encrypted with your password. This mirrors how SSH works with `id_rsa` and `id_rsa.pub`, except your XID bundles both into a single document.

Your `SigningPublicKey` is also called your "inception key" because your XID identifier (`XID(5f1c3d9e)`) is the SHA-256 hash of this signing key. Hence the name: it's the key that defines your XID. Your identifier never changes because it's permanently bound to this original key.

> :warning: **The Signing Key Defines the Identity**: The same keypairs always produce the same XID identifier because it's derived from the public key. If you regenerate from the same keys, you get the same identity. If you lose the keys, you lose the identity, just as with SSH.

#### A Review of Envelope Structure

If you are familiar with envelope structure (discussed here) and envelope format (discussed below), then you can skip ahead to Step 2 and create a public view of Amira's XID. If, however, you are not that familiar with Gordian Envelope, then read on.

As noted, every envelope has a **subject** (the main thing) and **assertions** (claims about that thing), which each include a **predicate** and an **object**. This usually means the subject predicates the object or the subject has a predicate of the object.

Here's how that structure appears in the sample XID Document:

```
{
   XID(5f1c3d9e) [
    [
        'key': PublicKeys(...)             ← ASSERTION (predicate: object)
        'provenance': ProvenanceMark(...)  ← ASSERTION (predicate: object)
    ]
}
```

The XID identifier `XID(5f1c3d9e)` is the subject. The assertions make claims about it: "this XID has these public keys" and "this XID has this provenance history." Assertions can be added, removed, or hidden independently, no matter where they are in an envelope document. This is a key insight for their usage (and in fact you'll be hiding individual assertions momentarily).

This pattern nests. Look inside the `'key'` assertion:

```
'key': PublicKeys(a9818011...) [     ← Subject of this nested envelope
    'allow': 'All'                 ← Assertion about the key
    'privateKey': ENCRYPTED        ← Another assertion
]
```

The `PublicKeys` object is itself a subject with its own assertions. It `allow`s all access to the XID and it contains an `ENCRYPTED` `privateKey`. This recursive structure lets you build arbitrarily rich identity documents. In Tutorial 03, you'll add your GitHub account and SSH keys as `attachments—vendor-qualified` containers for application-specific data.

#### A Review of Envelope Format

Envelope format shows you abbreviated labels for some data such as `PublicKeys(32de0f2b)` and `ENCRYPTED` rather than raw cryptographic data. This is intentional: showing hundreds of bytes of base64 would obscure the structure. Envelope format also hides complexity: `PublicKeys` actually contains two separate keys (a signing key and an encapsulation key), `ENCRYPTED` contains the ciphertext plus Argon2id parameters, and `Salt` contains random bytes that make each XIDDoc's digest unique. You don't need to see this detail to work with XIDs, but knowing it's there helps when things go wrong.

The hex codes in parentheses are digest fragments that let you quickly identify which key or encrypted blob you're looking at. Each one is a hash of the data in question. For example, the following shows all the keys in a XID, with their hashes. Note that the hash of the `SigningPublicKey`, `5f1c3d9e`, is the same as your XID! That's correct: as discussed elsewhere, the XID is the hash of your signing key!

```
         'key': PublicKeys(a9818011, SigningPublicKey(5f1c3d9e, Ed25519PublicKey(b2c16ea3)), EncapsulationPublicKey(96209c0f, X25519PublicKey(96209c0f))) [
```

The other thing of particular note is the quoted data. There are two styles of quotes:

- **Single quotes** (`'key'`, `'nickname'`, `'All'`) designate **Known values**. These are standardized terms from the Gordian Envelope specification. They can be subjects, predicates (`'allow'`), or objects (`'All'`). These ensure different tools understand your XIDDoc the same way.
- **Double quotes** (`"BRadvoc8"`, `"github"`) designate **Strings**. This is custom application data you define.

## Step 2: Creating a Public View of Your XID with Elision

Amira's XID is not ready for publication yet. You're going to add some more information in Tutorial 02 before sending it to Amira's first contact, Ben. But to prepare yourself for that you're going to go over the steps that _would_ be required to publish a XID: first, creating a public view; and second verifying it.

When you create a shareable public view of a XID, you are engaging in [data minimization](../concepts/data-minimization.md). You're creating a new look at the current edition of your XID that only includes the data that your recipient needs to see. This is "selective disclosure." Now, there's not a lot of information yet in Amira's XID, but there's one thing that we don't need to send out: her private key. Sure, it's encrypted, but sending it out creates an attack surface and that could be avoided with use of envelope's elision (removal) feature.

To remove content from a XID requires finding the hash for that data. Every thing in an envelope has a hash: it's how the envelope is built and how it maintains signatures (more on that momentarily). Once she finds the right hash, you simply tell the Envelope CLI to remove that. So to remove the private key you need to first find its hash in your envelope.

### Finding the Private Key Digest

In a graphical UI, this whole process might be as simple as clicking on the private-key assertion in the envelope and hitting the DELETE key. In the Envelope CLI, it takes digging down through the layers of the envelope by unwrapping wrapped envelopes and finding assertions within them.

This requires knowing how the envelope is structured:
```
│ {
|    XID(5f1c3d9e) [
│         'key': PublicKeys(a9818011, SigningPublicKey(5f1c3d9e, Ed25519PublicKey(b2c16ea3)), EncapsulationPublicKey(96209c0f, X25519PublicKey(96209c0f))) [
│             {
│                 'privateKey': ENCRYPTED [
│                     'hasSecret': EncryptedKey(Argon2id)
│                 ]
│             }
| ...
|   ]
| }
```

This shows that we need to unwrap the envelope (since it was wrapped and signed with `--sign inception`), then find the `'key'` assertion, then find the `'privateKey'` assertion.

Unwrapping is done `extract wrapped`.

```
UNWRAPPED_XID=$(envelope extract wrapped "$XID")
```

Then you find the `key` predicate, which is a `known` value, and extract its `PublicKeys` object:

```
KEY_ASSERTION=$(envelope assertion find predicate known key "$UNWRAPPED_XID")
KEY_OBJECT=$(envelope extract object "$KEY_ASSERTION")
```

Finally, you find the `privateKey` assertion in _that_ and then record its digest:

```
PRIVATE_KEY_ASSERTION=$(envelope assertion find predicate known privateKey "$KEY_OBJECT")
PRIVATE_KEY_DIGEST=$(envelope digest "$PRIVATE_KEY_ASSERTION")

if [ $PRIVATE_KEY_DIGEST ]
then
  echo "✅ Found private key digest"
else
  echo "❌ Error in private key retrieval"
fi

│ ✅ Found private key digest
```

### Eliding Your XID

Eliding your private key from your XID to create a public view simply requires using the `elide` command to remove the data represented by that digest:

```
PUBLIC_XID=$(envelope elide removing "$PRIVATE_KEY_DIGEST" "$XID")
echo "Created public view by eliding private key"

│ Created public view by eliding private key
```

Afterward, you can view this new public view of your XID:

```
envelope format "$PUBLIC_XID"

| {
|     XID(5f1c3d9e) [
|         'key': PublicKeys(a9818011, SigningPublicKey(5f1c3d9e, Ed25519PublicKey(b2c16ea3)), EncapsulationPublicKey(96209c0f, X25519PublicKey(96209c0f))) [
|             'allow': 'All'
|             'nickname': "BRadvoc8"
|             ELIDED
|         ]
|         'provenance': ProvenanceMark(1896ba49) [
|             {
|                 'provenanceGenerator': ENCRYPTED [
|                     'hasSecret': EncryptedKey(Argon2id)
|                 ]
|             } [
|                 'salt': Salt
|             ]
|         ]
|     ]
| } [
|     'signed': Signature(Ed25519)
| ]
```

This formatting implies that the signature has been preserved, *despite* removing some of the data in the envelope. That's accurate: his is a purposeful feature of Gordian Envelope.

#### A Review of Envelope Hashes & Signatures

If you are already comfortable with the structure of Gordian Envelopes, how they hash data, and how data is signed, skip down to Step 3. Otherwise, read on.

Otherwise, here's the skinny on how that signature is preserved even after we elided information:

Gordian Envelope is built on hashes. Every subject, every predicate, every object, and every assertion has a hash. Leaves (such as subject, predicates, and objects) have hashes of the content of the leaf, while nodes (such as assertions, collections of assertions, and wrapped content) have hashes that are built from the hashes of the objects they contain. A signature is made not across the content of an envelope, but against the root (or top-level) hash of an envelope.

When data is elided from an envelope, its content is removed, but the hash remains. That means that all of the node hashes above that leaf hash remain the same, including the root hash. Since it's the root hash that is signed, not the full envelope content, the signature remains valid.

> :warning: **The Root Hash is Not the ID Identifier.** The root hash is composed from the hashes of _all_ the data within an envelope. It changes if you change the document. It's an identifier for all views of a specific edition of your XID Document. In contrast, the XID identifier is the hash of your inception public key. It never changes. It's an identifier for your identity. 

You can verify your root hash does not change after you elide data with the `envelope digest` command:

```
ORIGINAL_DIGEST=$(envelope digest "$XID")
PUBLIC_DIGEST=$(envelope digest "$PUBLIC_XID")

echo "Original XID digest: $ORIGINAL_DIGEST"
echo "Public XID digest:   $PUBLIC_DIGEST"

if [ "$ORIGINAL_DIGEST" = "$PUBLIC_DIGEST" ]; then
    echo "✅ VERIFIED: Digests are identical - elision preserved the root hash\!"
else
    echo "❌ ERROR: Digests differ"
fi

│ Original XID digest: ur:digest/hdcxcaoldkfpisoesfoxdnatamwyytasdwsbuomnkicxlbaavehsfzksmdinrogachhnsolbpahg
│ Public XID digest:   ur:digest/hdcxcaoldkfpisoesfoxdnatamwyytasdwsbuomnkicxlbaavehsfzksmdinrogachhnsolbpahg
│ ✅ VERIFIED: Digests are identical - elision preserved the root hash!
```

The digests are identical. You removed the private key, yet the hash didn't change. 

## Step 3: Verifying a XID

You also want to test out the verification of your XID, as that'll be crucial when you actually publish it. There are two ways to do so:

* The signature can be verified.
* The provenance mark can be validated.

A digital signature is verified against a public key. For a XID, that's the public signing key. Again, you have to dig down through the envelope to get to it:
```
UNWRAPPED_XID=$(envelope extract wrapped "$XID")
KEY_ASSERTION=$(envelope assertion find predicate known key "$UNWRAPPED_XID")
KEY_OBJECT=$(envelope extract object "$KEY_ASSERTION")
PUBLIC_KEYS=$(envelope extract ur "$KEY_OBJECT")
```
You can then use envelope's `verify` command to verify the signature of the `PUBLIC_XID` versus that public key:

```
envelope verify -v "$PUBLIC_KEYS" "$PUBLIC_XID" >/dev/null && echo "✅ Signature verified\!"

│ ✅ Signature verified!
```

This confirms that this XID Document has been signed by the owner of the public key within the document. After publication, a public key might also be retrieved from a PKI or other publication site. Verifying against that key (or just checking that key against the key in the XID) would confirm that the document was signed by the owner of the published public key. Following publication of this XID, this verification will also demonstrate that updates of this XID Document continue to be signed by this original (inception) key or by a new key that has been authorized by the inception key, possibly through a chain of authorizations.

The provenance mark can also be verified. To do this, extract the Provenance Mark with the `xid provenance` command:

```
PROVENANCE_MARK=$(envelope xid provenance get "$PUBLIC_XID")
```

Next, you can test the validation of the Provenance Mark with the provenance mark CLI:

```
provenance validate "$PROVENANCE_MARK"

│ ✅ (silent success - provenance check passed!)
```

By default, `provenance validate` offers no response if the provenance mark is valid. But you can use `--format json-pretty` to get more information:

```
provenance validate --format json-pretty "$PROVENANCE_MARK"

| {
|   "marks": [
|
| "ur:provenance/lfaxhdimhspdzshnfrkbrngrpmkgrodlsklpluntgozcoeisbyvyatbdfytpaxinfdjzidaomdflcywmfewnuejnmugucmrkhdonvdbgwneejthecyuehnsnjphtuednttsfrptsidurgwfxldgelpecmecyjoetieytfrhkgtfdestnnlqzmoaheeemselpbdwnwnsbjnnertpmrdnnbdhtdkpdwfkihgwy"
|   ],
|   "chains": [
|     {
|       "chain_id": "61a8fa603b7ebe4bad7bb82fc5858b9d55fda26811e1070b44d80369486c6202",
|       "has_genesis": true,
|       "marks": [
|
| "ur:provenance/lfaxhdimhspdzshnfrkbrngrpmkgrodlsklpluntgozcoeisbyvyatbdfytpaxinfdjzidaomdflcywmfewnuejnmugucmrkhdonvdbgwneejthecyuehnsnjphtuednttsfrptsidurgwfxldgelpecmecyjoetieytfrhkgtfdestnnlqzmoaheeemselpbdwnwnsbjnnertpmrdnnbdhtdkpdwfkihgwy"
|       ],
|       "sequences": [
|         {
|           "start_seq": 0,
|           "end_seq": 0,
|           "marks": [
|             {
|               "mark":
| "ur:provenance/lfaxhdimhspdzshnfrkbrngrpmkgrodlsklpluntgozcoeisbyvyatbdfytpaxinfdjzidaomdflcywmfewnuejnmugucmrkhdonvdbgwneejthecyuehnsnjphtuednttsfrptsidurgwfxldgelpecmecyjoetieytfrhkgtfdestnnlqzmoaheeemselpbdwnwnsbjnnertpmrdnnbdhtdkpdwfkihgwy",
|               "issues": []
|             }
|           ]
|         }
|       ]
|     }
|   ]
| }
```

This says very little so far, but that's to be expected: the power of provenance marks is in seeing that multiple published editions of documents are related—and you haven't even published a single version of Amira's XID yet! Nonethless, you can see from`has_genesis: true`, `start_seq: 0` and `end_seq: 0` that this is the first edition in the provenance mark chain (the "genesis mark"), with no issues found. This will become more meaningful in tutorial 03 when you produce a second edition of Amira's XID for publication, and advance the provenance mark as a result.

Before you close out your verification it's worth noting that all verification was down with the public view of the XID; no secret information was needed. This asymmetry is common in cryptography: Amira creates information with her secrets, and only she can update that information. But after she distributes her public XID, anyone can check it.

## Step 4: Organizing Your Files

For real-world usage, Amira will organize her files in a dedicated directory. The pattern mirrors SSH: `BRadvoc8-xid.envelope` is like `id_rsa` (keep secret), and `BRadvoc8-xid-public.envelope` is like `id_rsa.pub` (safe to share).

```
xid-20251117/
├── BRadvoc8-xid.envelope          # Complete XID with encrypted private keys
├── BRadvoc8-xid.format            # Human-readable view
├── BRadvoc8-xid-public.envelope   # Public XID (private keys elided)
└── BRadvoc8-xid-public.format     # Human-readable view
```

Your complete XID file contains everything: private keys (encrypted), public keys, nickname, provenance, and signature. If you lose this file without a backup, you lose your identity, just like losing `id_rsa`. Unlike SSH keys, your XID also includes identity metadata (nickname, permissions, provenance history), making it a complete, self-contained identity document rather than just raw key material.

You might then have many public different views of your current XID, each elided in different ways. Obviously, you'll want to keep your private key out of all of them, but you might also decide to reveal different information to different people, as part of selective disclosure.

## Summary: The Bigger Picture

What Amira created is more than a keypair. She created the BRadvoc8 identity, which is fully under her control. No service provider issued it, and no platform can suspend it. The encrypted XID depends on no centralized structure. Because it's a self-contained cryptographic object, the XID can live anywhere: on a USB drive, in email, in cloud storage, even printed as a QR code. The infrastructure is in the document itself, not in some external system. This is self-sovereign identity: Amira owns the keys and the resulting document. 

Amira's XID implements pseudonymity rather than anonymity, and that's exactly what she wants. Anonymous contributions lack credibility; project maintainers can't trust them. But BRadvoc8 can build reputation over time through verifiable contributions while protecting Amira's real-world identity. It's the same model authors use with pen names: Mark Twain built a reputation while Samuel Clemens stayed private.

Though you experimented with elision and verification, you haven't actually published Amira's XID. More on that in the next tutorial!

### Example Script

A complete working script implementing this tutorial is available at `tests/01-your-first-xid-TEST.sh`. Run it to see all steps in action:

```
bash tests/01-your-first-xid-TEST.sh
```

This script will create all the files shown in the File Organization section (below) with proper naming conventions and directory structure.

### Exercises

Try these to solidify your understanding:

- Create your own XID with a pseudonym of your choice.
- Experiment with different passwords.
- Practice creating public views by eliding private keys, then verify the signatures still work on the elided views.
- Save your XID to a file and reload it to confirm nothing was lost.

## What's Next

BRadvoc8 is now a basic, secure XID, but it has a problem: nobody can verify they have the current edition. If Amira updates her XID Document tomorrow, how would Ben know he has stale data?

**Tutorial 02: Making Your XID Verifiable** shows how to solve this. Amira will add a `dereferenceVia` assertion pointing to where her XID is published. Ben can then fetch the latest edition and verify it's fresh.

From there, Tutorial 03 adds attestations (GitHub account, SSH signing key), and Tutorial 04 shows Ben how to cross-verify those claims against external sources. Together, they enable the trust-building that comes in later tutorials.

**Next Tutorial**: [Making Your XID Verifiable](02-making-your-xid-verifiable.md) - Publish your XID and enable freshness verification.

## Appendix I: Common Questions

### Q: What if I lose my XID file?

**A:** If you lose your `BRadvoc8-xid.envelope` file without a backup, **you lose your identity**. This is just like losing your SSH `id_rsa` file. There's no recovery mechanism without a backup - make sure to store encrypted copies in multiple secure locations.

### Q: Can I use this XID on multiple devices?

**A:** Yes! Copy your `BRadvoc8-xid.envelope` file to other devices. Since the private keys are encrypted, the file is reasonably safe to sync via cloud storage (as long as you have a strong passphrase!). The XID identifier stays the same regardless of which device you're using. 

You can also create device-specific keys and delegate permissions, allowing each device to have its own key while maintaining a single XID identity. More on this in future tutorials.

### Q: What if I need to revoke my keys?

**A:** Unlike with SSH keys, you can revoke a key pair while keeping your XID persistent.

### Q: Why is signing done with Ed25519 instead of Schnorr or other algorithms?

**A:** Ed25519 is the industry standard (SSH, git, Signal) with wide compatibility and excellent security. Advanced users can use other algorithms (`--signing schnorr`, `--signing ecdsa`, `--signing mldsa44`), but Ed25519 is recommended for beginners.

## Appendix II: Key Terminology

> **Assertion** - A predicate-object pair making a claim about the subject (e.g., `'key': PublicKeys(...)`).
>
> **Edition** - A version of a XIDDoc (or other envelope) that is different from previous editions due to the addition, removal, or update of information. An edition may have many views, which selectively elide information from the master document. If an envelope contains a provenance mark, it is incremented when a new edition is created.
>
> **Elision** - Removing data while preserving the envelope's root hash, enabling selective disclosure with maintained cryptographic integrity.
>
> **Envelope** - Gordian Envelope, a smart-document system that supports the deterministic storage of data and its distribution in multiple selectively disclosed views to support data minimization. 
>
> **Envelope Digest** - The root hash of an envelope structure, preserved across elision, enabling signature verification on different views of the same document.
>
> **Inception Key** - The signing public key that defines your XID from the beginning. Your XID identifier is the SHA-256 hash of this key's CBOR representation. The term "inception" emphasizes that this key establishes the identity at its origin.
>
> **Known Value** - Standardized term from the Gordian Envelope spec, shown in single quotes. Can be a subject, a predicate, or an object.
>
> **Provenance Generator** - The secret that creates provenance marks. It created your genesis mark and will create all future marks when you update your XIDDoc. Separate from the inception key.
>
> **Provenance Mark** - Cryptographic marker establishing the sequence position of a document edition, forming a verifiable chain of identity evolution. The genesis mark (sequence 0) is the first in the chain. Provides ordering, not timestamps.
>
> **Root Hash** — The unique identifier for a specific edition of an envelope, calculated based on all the data in the envelope. Persistent across all views of an edition, but not across multiple editions of an envelope.
>
> **Selective Disclosure** - Sharing only the information needed for a specific context. Sign once, create multiple views by eliding different parts, and every view verifies against the same signature.
>
> **String** - Custom application data, shown in double quotes (`"BRadvoc8"`, `"github"`).
>
> **Subject** - The main thing an envelope describes; in XIDDocs, this is the XID identifier.
>
> **View** - A version of an edition of a XIDDoc (or other envelope) that has been elided in a specific way, to preserve selective disclosure.
> 
> **XID (eXtensible IDentifier)** - The unique identifier for your identity, calculated as the SHA-256 hash of your inception signing public key. Persistent across all document editions because it's bound to that original key.
>
> **XIDDoc (XID Document)** - The envelope document containing an XID and its assertions (keys, provenance, metadata). This is what you create, update, and share.

---

**Next Tutorial**: [Making Your XID Verifiable](02-making-your-xid-verifiable.md) - Publish your XID and enable freshness verification.
