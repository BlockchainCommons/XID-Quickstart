# 1.1: Creating Your First XID

This section demonstrates how to create a basic XID (eXtensible
IDentifier) that enables pseudonymous contributions while maintaining
security. 

> 🧠 **Related Concepts.** Before or after completing this
tutorial, you may want to read about [XID
Fundamentals](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/concepts/xid.md) and [Gordian Envelope
Basics](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/concepts/gordian-envelope.md) to understand the
theoretical foundations.

## Objectives for this Section

After working through this section, a developer will be able to:

- Create a basic XID for pseudonymous identity
- Create public views of your XID using elision
- Maintain strong cryptographic integrity while sharing selectively
- Verify signature
- Examine provenance marks

Supporting objectives include the ability to:

- Understand what a XID is.
- Know what a pseudonymous identity is.
- Understand XID file organization using secure naming conventions

## Amira's Story: Why Pseudonymous Identity Matters

Amira is a successful software developer working at a prestigious
multinational bank in Boston. With her expertise in distributed
systems security, she earns a comfortable living, but she wants more
purpose in her work. She is considering contributing to social-impact
programs, but she can't do so under her real name. That's because
Amira's position is somewhat vulnerable. She's a South American
programmer working on an H-1B visa, and in modern America that could
be revoked for any sort of activism. She also grew up in a politically
tense region, and her work on social-impact projects could endanger
family members back home. Yet she's deeply motivated to use her skills
to help oppressed people globally. This tension between professional
security and meaningful contribution creates a specific need.

Anonymous submissions could resolve these issues. However, anonymous
contributions lack credibility. Project maintainers need confidence in
the quality and provenance of code, especially for socially important
applications. Amira needs a better solution, one that protects her
identity while allowing her to build a verifiable reputation for her
skills. This would allow her to build trust through the quality of her
work rather than existing credentials and so establish a consistent
presence that can evolve over time.

On the advice of her friend Charlene, Amira investigates RISK, a
network that connects developers with social-impact projects and
protects participants' privacy. It uses a Blockchain Commons
technology called [XIDs](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/concepts/xid.md): these "eXtensible
IDentifiers" enable pseudonymous identity with progressive trust
development. Amira will use RISK to create the "BRadvoc8" (Basic
Rights Advocate) identity. Through RISK, Amira can then connect with
project leaders such as Ben, who runs a women's services non-profit
that Amira wishes to contribute to. This will allow her to safely
collaborate on projects aligned with her values while maintaining
separation between her pseudonymous contributions and her legal
identity, protecting herself from adversaries who might target her or
her family for her work.

> 📖 **What is a Pseudonymous Identity?** A pseudoynmous identity
is an ongoing identity that's intended for continuous usage, but which
links to a name or identifier that doesn't match your real-world name.

### The Power of XIDs

XIDs have a number of advantages over how decentralized identifiers
have evolved in the wider ecosystem, as more fully described in
["Musings of a Trust Architect: How XIDs Demonstrate a True
Self-Sovereign
Identity"](https://www.blockchaincommons.com/musings/XIDs-True-SSI/). Among those advantages are:

* **XIDs are Truly Self-Sovereign.** A XID is autonomous. It's built
on private keys that you control, described in a XID Document that you
can update and elide as you see fit. There's no issuer (other than
yourself), nor is there a central server that a XID might call home
to.
* **XIDs Support Rich Metadata.** They can include structured self
attestations that describe your skills. Others can also make
cryptographically verifiable claims about you through peer
attestation.
* **XIDS Allow Elision.** You can selectively share different
information from your XID with different parties or use progressive
trust to expand what you reveal to an individual over time, all while
keeping other details private by eliding them. XIDs preserve the
cryptographic integrity of the metadata even when portions are
removed.
* **XIDs Maintain a Stable Identity.** That identity remains stable
even if you have multiple keys for different devices and even if you
rotate your keys. If something goes wrong, recovery mechanisms let you
restore access to your identity (and so your reputation, attestation,
and endorsement history).

> 🔥 ***What is the Power of XIDs?** The powers of XIDs include
true self-sovereignty, rich metadata support, holder-based elision,
and ongoing key management.

## Part I: Preparing to Work

Like all of the "Learning from ..." courses, "Learning XIDs from the
Command Line" is intended for hands-on work. By experimenting with
XIDs, or even just following along using the envelope-cli app, you'll
gain a more visceral understanding of the identifiers and how they can
be used.

As always, this requires setup: this section will lead you through the
installation of a few core applications and later sections will
demonstrate how to reload previous work to maintain consistent keys
and XIDs throughout the course.

### Step 0: Setting Up Your Workspace

This tutorial depends on
[`bc-envelope-cli`](https://github.com/BlockchainCommons/bc-envelope-cli-rust),
a Rust-based command-line interface. It can be easily installed using
the `cargo` package management tool:

```
cargo install bc-envelope-cli
```

Though it's only used for a minor element here, you should also
install the Provenance Mark CLI with `cargo`, as it'll also  be referenced
throughout these tutorials:

```
cargo install provenance-mark-cli
```

If you don't have `cargo` installed, see [_The Cargo
Book_](https://doc.rust-lang.org/cargo/getting-started/installation.html)
for easy installation instructions.

> ⚠️ **Your Output Will Differ.** Tutorial examples show output
from the **real published BRadvoc8 XID** at
`github.com/BRadvoc8/BRadvoc8`. When you follow along, your output
will differ. You will have different XID identifiers, different key
identifiers, different provenance marks, and different hashes in your
envelope._This is expected._ Focus on understanding what each step
accomplishes, not matching exact output. Additional differences at
this level will appear in future tutorials.

## Part II: Creating the XID

This first tutorial will take you through the basic steps to create a
XID. It's deliberately simple. Subsequent tutorials, we'll explore
more advanced features including the creation of rich persona
structures.

### Step 1: Create Your XID

The first step in creating Amira's "BRadvoc8" pseudonymous identity is
creating a XID as an anchor. 

> 📖 **What is a XID?** A XID is an eXtensible IDentifier. It's a
Blockchain Commons technology built on Gordian Envelope, which is a
smart document system that provides abilities such as elision and
encryption, as well as other technologies such as Provenance
Marks. XIDs are built to be autonomous cryptographic objects, which
means that they can be used without depending on a central server or
even a reliable communication network. More details are available in
the [XID concepts file](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/concepts/xid.md) and the [envelope concepts
file](../ceoncepts/gordian-envelope.md).

A single `envelope` operation creates a complete XID that contains
both private and public keys:

```
XID_NAME=BRadvoc8
PASSWORD="Amira's strong password"

XID=$(envelope generate keypairs --signing ed25519 │ \
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
2. `envelope xid new` creates a XID based on that Ed25519 keypair. This generates a XID Document (XIDDoc), which can be read as a Gordian Envelope. We'll usually refer to it just as XID.

> 📖 **What is a UR?** A UR is a Uniform Resource, another
Blockchain Commons technology. It provides a standardized,
self-describing way to pass around data such as keys, envelopes, and
XIDs.

Several arguments to the second command affect how the XID is
produced:

1. `--private encrypt` encrypts the private keys, which are stored in the XID Document, with `--encrypt-password` allowing decryption with a password.
2. `--generator encrypt` adds an provenance mark to the XID structure, with its secret also encrypted and decryptable with the password.
3. `--nickname` adds an identity label to the XID structure.
4. `--sign inception` wraps and signs the entire XID, allowing others to verify its authenticity.

> ⚠️ **Private Keys on Board**: Your XID contains your private
keys (encrypted with your password). Though they are encrypted, you
should still be wary of distributing a XID that contains those private
keys. Fortunately, you can elide (remove) that data, as described
below. Obviously, you must also be careful to protect your password.

> 📖 **What is a Wrapped Envelope?** A Gordian Envelope is a
package of informational triplets in the form of
subject-predicate-object. An assertion (the predicate and the object)
always applies to a specific subject. To make an assertion apply to
more information, you wrap the envelope and then apply the assertion
to the wrapped envelope. Signatures are assertions, so for a signature
to apply to an entire envelope (in this case, all of the XID
information), the envelope must be wrapped prior to signing.

> 🧠 **Learn More.** The [Signing and Verification](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/concepts/signing.md) concept doc explains the cryptographic details of many of these elements.

### Step 2: View Your XID Structure

The `envelope format` command can always be used to display a
human-readable version of any Gordian Envelope, including a XID
Document. You can use it to look at Amira's foundational XID:

```
envelope format "$XID"

│ {
│    XID(5f1c3d9e) [
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
      - The `'hasSecret': EncryptedKey(Argon2id)` notation notes that the private keys are encrypted with Argon2id, a modern algorithm designed to resist brute-force attacks.
      - `salt` is a random value that further obscures its subject.
   - The `allow` statement determines what access these keys have to this identity, as described in [key management](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/concepts/key-management.md). By default, keys have total access (`All`).
   - The `nickname` is inside the `PublicKeys` section, not at the top level. That's because a nickname labels a key, not the XID Document. Later keys could have different nicknames while maintaining the same XID identity.
- The `ProvenanceMark(...)` is a "genesis" mark: the first in a chain that tracks this identity's evolution.
   - The encrypted `provenanceGenerator` is the secret that created this mark and will create all future marks when Amira publishes new editions of her XID Document.

> 📖 **What is a Provenance Mark?** A provenance mark is a
forward-commitment hash chain. It will be used to record the evolution
of this identity, showing that each edition is linked to the previous
one (and also, which is the newest edition of the set).

Note that a XID actually includes two keypairs that are bundled together:
- a `Signing` keypair for creating and verifying signatures.
   - Your `SigningPublicKey` is also called your "inception key" because your XID identifier (`XID(5f1c3d9e)`) is the SHA-256 hash of this signing key. Hence the name: it's the key that defines your XID. Your identifier never changes because it's permanently bound to this original key.
- an `Encapsulation` keypair for encryption and decryption.

As shown, the public halves of the keypairs are readable by anyone,
while the private halves are encrypted with your password. This
mirrors how SSH works with `id_rsa` and `id_rsa.pub`, except your XID
bundles both into a single document.

> ⚠️ **The Signing Key Defines the Identity.** The same keypairs always produce the same XID identifier because the identifier is derived from the public key. If you regenerate from the same keys, you get the same identity. If you lose the keys, you lose the identity, just as with SSH.

#### A Review of Envelope Structure

If you are familiar with envelope structure (discussed here) and
envelope format (discussed below), then you can skip ahead to Step 3
and create a public view of Amira's XID. If, however, you are not that
familiar with Gordian Envelope, then read on.

As noted, every envelope has a **subject** (the main thing) and
**assertions** (claims about that thing), which each include a
**predicate** and an **object**. This usually means the subject
predicates the object or the subject has a predicate of the object.

Here's how that structure appears in the sample XID Document:

```
{
   XID(5f1c3d9e) [                         ← SUBJECT
    [
        'key': PublicKeys(...)             ← ASSERTION (predicate: object)
        'provenance': ProvenanceMark(...)  ← ASSERTION (predicate: object)
    ]
}
```

The XID identifier `XID(5f1c3d9e)` is the subject. The assertions make
claims about it: "this XID has these public keys" and "this XID has
this provenance history." Assertions can be added, removed, or hidden
independently, no matter where they are in an envelope document. This
is a key insight for their usage (and in fact you'll be hiding
individual assertions momentarily).

This pattern nests. Look inside the `'key'` assertion:

```
'key': PublicKeys(a9818011...) [   ← SUBJECT of this nested envelope
    'allow': 'All'                 ← ASSERTION about the key
    'privateKey': ENCRYPTED        ← Another ASSERTION
]
```

The `PublicKeys` object is itself a subject with its own
assertions. It `allow`s all access to the XID and it contains an
`ENCRYPTED` `privateKey`. This recursive structure lets you build
arbitrarily rich identity documents, constrained by the specific
requirements of the XID format. In chapter 2, for example, you'll add
new keys, and in chapter 3 you'll use the `edge` assertion to add peer
endorsements.

#### A Review of Envelope Format

Envelope format (output with `envelope format`) displays abbreviated
labels for some data such as `PublicKeys(32de0f2b)` and `ENCRYPTED`
rather than raw cryptographic data. This is intentional: showing
hundreds of bytes of base64 would obscure the structure. Envelope
format also hides complexity: `PublicKeys` actually contains two
separate keys (a signing key and an encapsulation key), `ENCRYPTED`
contains the ciphertext plus Argon2id parameters, and `Salt` contains
random bytes that make each XIDDoc's digest unique. You don't need to
see this detail to work with XIDs, but knowing it's there helps when
things go wrong.

The hex codes in parentheses are digest fragments that let you quickly
identify which key or encrypted blob you're looking at. Each one is a
hash of the data in question. For example, the following shows all the
keys in a XID, with their hashes. (Note that the hash of the
`SigningPublicKey`, `5f1c3d9e`, is the same as your XID! That's
correct: as discussed elsewhere, the XID is the hash of your signing
key!)

```
         'key': PublicKeys(a9818011, SigningPublicKey(5f1c3d9e, Ed25519PublicKey(b2c16ea3)), EncapsulationPublicKey(96209c0f, X25519PublicKey(96209c0f))) [
```

The other thing of particular note is the quoted data. There are two
styles of quotes:

- **Single quotes** (`'key'`, `'nickname'`, `'All'`) designate **Known Values**. These are standardized terms from the [Known Values registry](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2023-002-known-value.md#appendix-a-registry). They can be subjects, predicates (`'allow'`), or objects (`'All'`). These ensure different tools each understand your XID in the same way.
- **Double quotes** (`"BRadvoc8"`, `"github"`) designate **Strings**. This is custom application data you define.

### Step 3: Create a Public View of Your XID with Elision

Amira's XID is not ready for publication yet. You're going to add some
more information in [§1.2](01_2_Making_a_XID_Verifiable.md) before
sending it to Amira's first contact, Ben. But to prepare yourself for
that, you're going to go over the crical step that _would_ be required
to publish a XID: creating a public view.

When you create a shareable public view of a XID, you are engaging in
[data minimization](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/concepts/data-minimization.md). You're creating
a new way to look at the current edition of your XID that only
includes the data that your recipient needs to see. This is "selective
disclosure." Now, there's not a lot of information yet in Amira's XID,
but there's one thing that we don't need to send out: her private
key. Sure, it's encrypted, but sending it out creates an attack
surface and that could be avoided with use of envelope's elision
(removal) feature.

To remove content from a XID requires finding the hash for that
data. Every thing in an envelope has a hash: it's how the envelope is
built and how it maintains signatures (more on that momentarily). Once
you find the right hash, you simply tell the Envelope CLI to remove
the data represented by that particular data. So to remove the private
key you need to first find its hash in your envelope.

> 📖 **What is a View?** A view is a version of a XID that has
been elided in a specific way. The XID itself isn't changed: every
view of the same XID has the same root hash. However, what's visible
will be different from one view to another.

**Find the Private Key Digest:**

In a graphical UI, this whole process might be as simple as clicking
on the private-key assertion in the envelope and hitting the DELETE
key. In the Envelope CLI, it takes digging down through the layers of
the envelope by unwrapping wrapped envelopes and finding assertions
within them.

This requires knowing how the envelope is structured:
```
│ {
│    XID(5f1c3d9e) [
│         'key': PublicKeys(a9818011, SigningPublicKey(5f1c3d9e, Ed25519PublicKey(b2c16ea3)), EncapsulationPublicKey(96209c0f, X25519PublicKey(96209c0f))) [
│             {
│                 'privateKey': ENCRYPTED [
│                     'hasSecret': EncryptedKey(Argon2id)
│                 ]
│             }
│ ...
│   ]
│ }
```

This shows that we need to unwrap the envelope (since it was wrapped
and signed with `--sign inception`), then find the `'key'` assertion,
and then find the `'privateKey'` assertion.

Unwrapping is done with `extract wrapped`.

```
UNWRAPPED_XID=$(envelope extract wrapped "$XID")
```

Then you find the `key` predicate, which is a `known` value, and
extract its `PublicKeys` object:

```
KEY_ASSERTION=$(envelope assertion find predicate known key "$UNWRAPPED_XID")
KEY_OBJECT=$(envelope extract object "$KEY_ASSERTION")
```

Finally, you find the known-value `privateKey` assertion in _that_ and
then record its digest:

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

**Elide Your XID:**

Eliding your private key from your XID to create a public view simply
requires using the `elide` command to remove the data represented by
that digest:

```
PUBLIC_XID=$(envelope elide removing "$PRIVATE_KEY_DIGEST" "$XID")
echo "✅ Created public view by eliding private key"

│ ✅ Created public view by eliding private key
```

Afterward, you can examine this new public view of your XID:

```
envelope format "$PUBLIC_XID"

│ {
│     XID(5f1c3d9e) [
│         'key': PublicKeys(a9818011, SigningPublicKey(5f1c3d9e, Ed25519PublicKey(b2c16ea3)), EncapsulationPublicKey(96209c0f, X25519PublicKey(96209c0f))) [
│             'allow': 'All'
│             'nickname': "BRadvoc8"
│             ELIDED
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

It looks identical except the `privateKey` section is gone, replaced
with `ELIDED`. Also of note is the fact that this formatting implies
that the signature has been preserved, *despite* removing some of the
data in the envelope. That's accurate: this is a purposeful feature of
Gordian Envelope.

#### A Review of Envelope Hashes & Signatures

If you are already comfortable with the structure of Gordian
Envelopes, how they hash data, and how data is signed, skip down to
Part II.  Otherwise, here's the skinny on how that signature is
preserved even after you elided information:

Gordian Envelope is built on hashes. Every subject, every predicate,
every object, and every assertion has a hash. Leaves (such as subject,
predicates, and objects) have hashes of the content of that leaf,
while nodes (such as the top-level of your envelope, assertions,
collections of a subject and assertions, and wrapped content) have
hashes that are built from the hashes of the objects they contain. A
signature is made not across the content of an envelope, but against
the root (or top-level) hash of an envelope.

Here's what a fragment of that looks like, generated with `envelope format --type tree $XID`, which shows abbreviations of all the hashes in an envelope:
```
1da62441 NODE                                                ← ROOT Hash (1da62441)
    34446925 subj WRAPPED                                    ← Wrapped Envelope Hash (34446925)
        bc6369ae cont NODE                                   ← Subject + Assertion(s) Node Hash (bc6369ae)
            2b2d09ab subj XID(5f1c3d9e)                      ← XID Subject Hash (2b2d09ab)
            e0c2825c ASSERTION                               ← Provenance Assertion Hash (e0c2825c)
                c1736fc8 pred 'provenance'
                c38203ae obj NODE
                    53da07ce subj ProvenanceMark(1896ba49)
                    9a0110e6 ELIDED
    ...
    d5625d76 ASSERTION                                        ← Signature Assertion Hash (d5625d76)
        d0e39e78 pred 'signed'
        91ccf7a3 obj Signature(Ed25519)
```
The root node has an (abbreviated) hash of `1da62441`, which is built from the wrapped subject hash of `34446925` and the signature assertion hash of `d5625d76`. The wrapped envelope's hash is built from the node hash of `bc6369ae`, which is built from the XID subject hash of `2b2d09ab` and a string of assertions attached to that subject, the first of which is provenance assertion, which has a hash of `e0c2825c`. Etc.

When data is elided from an envelope, its content is removed, but the hash remains. That means that all of the node hashes above that leaf hash remain the same, including the root hash. Since it's the root hash that is signed, not the full envelope content, the signature remains valid.

The above example shows a new elision, of the secret within the provenance mark assertion. Making a further elision of the entire provenance mark assertion demonstrates that the upper-level hashes remain in place:
```
1da62441 NODE                                                ← ROOT Hash (still 1da62441)
    34446925 subj WRAPPED                                    ← Wrapped Envelope Hash (still 34446925)
        bc6369ae cont NODE                                   ← Subject + Assertion(s) Node Hash (still bc6369ae)
            2b2d09ab subj XID(5f1c3d9e)                      ← XID Subject Hash (2b2d09ab)
            e0c2825c ELIDED                                  ← Elided (Provenance Assertion) Hash (still e0c2825c)
    ...
    d5625d76 ASSERTION                                        ← Signature Assertion Hash (d5625d76)
        d0e39e78 pred 'signed'
        91ccf7a3 obj Signature(Ed25519)

```

> ⚠️ **The Root Hash is Not the ID Identifier.** The root hash
is composed from the hashes of _all_ the data within an envelope. It
changes if you change the document. It's an identifier for all _views_
of a specific _edition_ of your XID Document. In contrast, the XID
identifier is the hash of your inception public key. It never
changes. It's an identifier for all _editions_ of your XID Document
(or if you prefer: it's the identifier for your identity).

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

## Part III: Verifying a XID

One of the powers of a XID is that it can be verified in various ways
(though that doesn't necessarily mean someone is who they say they
are, as is described in "What We Proved" in future sections).

### Step 4: Verify the XID

You also want to test out the verification of your XID, as that'll be
crucial when you actually publish it. There are two ways to do so:

* The signature can be verified.
* The provenance mark can be validated.

A digital signature is verified against a public key. For a XID, that's the public signing key.

After publication, a public key might also be retrieved from a PKI or
other publication site. But for this tutorial, yyou have to dig down
through the envelope to get to it:
```
UNWRAPPED_XID=$(envelope extract wrapped "$XID")
KEY_ASSERTION=$(envelope assertion find predicate known key "$UNWRAPPED_XID")
KEY_OBJECT=$(envelope extract object "$KEY_ASSERTION")
PUBLIC_KEYS=$(envelope extract ur "$KEY_OBJECT")
```
You can then use envelope's `verify` command to verify the signature of the `PUBLIC_XID` against that public key:

```
envelope verify -v "$PUBLIC_KEYS" "$PUBLIC_XID" >/dev/null && echo "✅ Signature verified\!"

│ ✅ Signature verified!
```

This confirms that this XID Document has been signed by the owner of
the public key within the document (in other words, it verifies that
the creator of the XID Document actually owns the key that is
advertising in the document).

If the public key was published, it would confirm that the document
was signed by the owner of that published public key.

When the XID is later published, this verification will also
demonstrate that updates of this XID Document continue to be signed by
this original (inception) key or by a new key that has been authorized
by the inception key, possibly through a chain of authorizations.

### Step 5: Verify the Provenance Mark

The provenance mark can also be verified. To do this, extract the Provenance Mark with the `xid provenance` command:

```
PROVENANCE_MARK=$(envelope xid provenance get "$PUBLIC_XID")
```

Now you can validate the Provenance Mark with the provenance mark CLI:

```
provenance validate "$PROVENANCE_MARK"

│ ✅ (silent success - provenance check passed!)
```

By default, `provenance validate` offers no response if the provenance mark is valid. But you can use `--format json-pretty` to get more information:

```
provenance validate --format json-pretty "$PROVENANCE_MARK"

│ {
│   "marks": [
│
│ "ur:provenance/lfaxhdimhspdzshnfrkbrngrpmkgrodlsklpluntgozcoeisbyvyatbdfytpaxinfdjzidaomdflcywmfewnuejnmugucmrkhdonvdbgwneejthecyuehnsnjphtuednttsfrptsidurgwfxldgelpecmecyjoetieytfrhkgtfdestnnlqzmoaheeemselpbdwnwnsbjnnertpmrdnnbdhtdkpdwfkihgwy"
│   ],
│   "chains": [
│     {
│       "chain_id": "61a8fa603b7ebe4bad7bb82fc5858b9d55fda26811e1070b44d80369486c6202",
│       "has_genesis": true,
│       "marks": [
│
│ "ur:provenance/lfaxhdimhspdzshnfrkbrngrpmkgrodlsklpluntgozcoeisbyvyatbdfytpaxinfdjzidaomdflcywmfewnuejnmugucmrkhdonvdbgwneejthecyuehnsnjphtuednttsfrptsidurgwfxldgelpecmecyjoetieytfrhkgtfdestnnlqzmoaheeemselpbdwnwnsbjnnertpmrdnnbdhtdkpdwfkihgwy"
│       ],
│       "sequences": [
│         {
│           "start_seq": 0,
│           "end_seq": 0,
│           "marks": [
│             {
│               "mark":
│ "ur:provenance/lfaxhdimhspdzshnfrkbrngrpmkgrodlsklpluntgozcoeisbyvyatbdfytpaxinfdjzidaomdflcywmfewnuejnmugucmrkhdonvdbgwneejthecyuehnsnjphtuednttsfrptsidurgwfxldgelpecmecyjoetieytfrhkgtfdestnnlqzmoaheeemselpbdwnwnsbjnnertpmrdnnbdhtdkpdwfkihgwy",
│               "issues": []
│             }
│           ]
│         }
│       ]
│     }
│   ]
│ }
```

This says very little so far, but that's to be expected: the power of
provenance marks is in seeing that multiple published editions of
documents are related—and you haven't even published a single version
of Amira's XID yet! Nonethless, you can see from `has_genesis: true`,
`start_seq: 0`, and `end_seq: 0` that this is the first edition in the
provenance mark chain (the "genesis mark"), with no issues found. This
will become more meaningful in chapter 2 when you produce a second
edition of Amira's XID for publication, and advance the provenance
mark as a result.

Before you close out your verification it's worth noting that all
verification was down with the public view of the XID; no secret
information was needed. This asymmetry is common in cryptography:
Amira creates information with her secrets, and only she can update
that information. But after she distributes her public XID, anyone can
check it.

## Part IV: Storing Your Files

This course will frequently store copies of files for future
usage. But, we're not quite there yet because we'll be finishing up
the initial edition of Amira's XID in the next section.

For now, we're instead going to talk about how Amira might organize
her files for their real-world usage.

### Step 6: Organize Your Files

A XID can be output to a file just be echoing the XID into a file:
```
echo $XID > BRadvoc8-xid.envelope
echo $PUBLIC_XID > BRadvoc8-xid-public.envelope
```

The complete `BRadvoc8-xid.envelope` file contains everything: private
keys (encrypted), public keys, nickname, provenance, and signature. If
you lose this file without a backup, you lose your identity, just like
losing `id_rsa`. Unlike SSH keys, your XID also includes identity
metadata (nickname, permissions, provenance history), making it a
complete, self-contained identity document rather than just raw key
material.

There might be many different public views of your current XID, of
which `BRadvoc8-xid-public.envelope` would be just one, with each view
elided in different ways. Obviously, you'll want to keep your private
key out of all of them, but you might also decide to reveal different
information to different people, as part of selective disclosure.

Formatted outputs can similarly be output:
```
envelope format $XID > BRadvoc8-xid.format
envelope format $PUBLIC_XID > BRadvoc8-xid-public.format
```
For real-world usage, Amira will organize her files in a dedicated directory. The pattern mirrors SSH: `BRadvoc8-xid.envelope` is like `id_rsa` (keep secret), and `BRadvoc8-xid-public.envelope` is like `id_rsa.pub` (safe to share).

```
xid-5f1c3d9e/
├── BRadvoc8-xid.envelope          # Complete XID with encrypted private keys
├── BRadvoc8-xid.format            # Human-readable view
├── BRadvoc8-xid-public.envelope   # Public XID (private keys elided)
└── BRadvoc8-xid-public.format     # Human-readable view
```

Having offered this real-world example, we're going to move over to a
more tutorial-specific format for storing files in the next
tutorial. (For now, make sure you have either your full envelope file
or that envelope still stored in a `$XID` variable as you continue
into the next section.)

## Summary: The Bigger Picture

What Amira created is more than a keypair. She created the BRadvoc8
identity, which is fully under her control. No service provider issued
it and no platform can suspend it. The encrypted XID depends on no
centralized structure. Because it's a self-contained cryptographic
object, the XID can live anywhere: on a USB drive, in email, in cloud
storage, even printed as a QR code. The infrastructure is in the
document itself, not in some external system. This is self-sovereign
identity: Amira owns the keys and the resulting document.

Amira's XID implements pseudonymity rather than anonymity, and that's
exactly what she wants. Anonymous contributions lack credibility;
project maintainers can't trust them. But BRadvoc8 can build
reputation over time through verifiable contributions while protecting
Amira's real-world identity. It's the same model authors use with pen
names: Mark Twain built a reputation while Samuel Clemens stayed
private.

Though you experimented with elision and verification, you haven't
actually published Amira's XID. More on that in the next tutorial!

### Exercises

Try these to solidify your understanding:

- Create your own XID with a pseudonym of your choice.
- Experiment with different passwords.
- Practice creating public views by eliding private keys, then verify the signatures still work on the elided views.
- Save your XID to a file and reload it to confirm nothing was lost.

## What's Next

Since XIDs are autonomous, Amira needs a way to assure people that
they have an up-to-date verison. Doing that (and publishing that XID) is the topic of [§1.2: Making a XID Verifiable](01_2_Making_a_XID_Verifiable.md).

### Example Script

A complete working script implementing this tutorial is available at `../tests/01-your-first-xid-TEST.sh`. Run it to see all steps in action:

```
bash tests/01-your-first-xid-TEST.sh
```

This script will create all the files shown in the File Organization section (below) with proper naming conventions and directory structure.


---

## Appendix I: Common Questions

### Q: What if I lose my XID file?

**A:** If you lose your `BRadvoc8-xid.envelope` file without a backup, **you lose your identity**. This is just like losing your SSH `id_rsa` file. There's no recovery mechanism without a backup, so make sure to store encrypted copies in multiple secure locations.

### Q: Can I use this XID on multiple devices?

**A:** Yes! Copy your `BRadvoc8-xid.envelope` file to other devices. Since the private keys are encrypted, the file is reasonably safe to sync via cloud storage (as long as you have a strong password!). The XID identifier stays the same regardless of which device you're using. 

You can also create device-specific keys and delegate permissions, allowing each device to have its own key while maintaining a single XID identity. More on this in future tutorials.

### Q: What if I need to revoke my keys?

**A:** Unlike with SSH keys, you can revoke a key pair while keeping your XID persistent.

### Q: Why is signing done with Ed25519 instead of Schnorr or other algorithms?

**A:** Ed25519 is the industry standard (SSH, git, Signal) with wide compatibility and excellent security. Advanced users can use other algorithms (`--signing schnorr`, `--signing ecdsa`, `--signing mldsa44`), but Ed25519 is recommended for beginners.

## Appendix II: Key Terminology

> **Assertion** - A predicate-object pair in an envelope, making a claim about the subject (e.g., `'key': PublicKeys(...)`).
>
> **Edition** - A version of a XIDDoc (or other envelope) that is different from previous editions due to the addition, removal, or update of information. An edition may have many views, which selectively elide information from the master document. If an envelope contains a provenance mark, it is incremented when a new edition is created.
>
> **Elision** - Removing data from an envelope while preserving the envelope's root hash, enabling selective disclosure while maintaining cryptographic integrity.
>
> **Envelope** - Gordian Envelope, a smart-document system that supports the deterministic storage of data and its distribution in multiple selectively disclosed views to support data minimization. 
>
> **Envelope Digest** - The root hash of an envelope structure, preserved across elision, enabling signature verification on different views of the same document.
>
> **Inception Key** - The signing public key that defines your XID from the beginning. Your XID identifier is the SHA-256 hash of this key's CBOR representation. The term "inception" emphasizes that this key establishes the identity at its origin.
>
> **Known Value** - Standardized term from the Known Values registry, shown in single quotes. Can be a subject, a predicate, or an object.
>
> **Provenance Generator** - The secret that creates provenance marks. It created your genesis mark and will create all future marks when you publish new XIDDoc editions. Separate from the inception key.
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
> **View** - A version of a specific edition of a XIDDoc (or other envelope) that has been elided in a specific way, to preserve selective disclosure. Despite the elision, signatures remain valid, because they are made across the Root Hash.
> 
> **XID (eXtensible IDentifier)** - The unique identifier for your identity, calculated as the SHA-256 hash of your inception signing public key. Persistent across all document editions because it's bound to that original key.
>
> **XIDDoc (XID Document)** - The envelope document containing an XID and its assertions (keys, provenance, metadata). This is what you create, update, and share.
