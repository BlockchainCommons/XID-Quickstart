# Creating Your First XID

This tutorial introduces Amira, a software developer with a politically sensitive background who wants to contribute to social impact projects without risking her professional position or revealing her identity. By the end, you'll have created a basic XID (eXtensible IDentifier) that enables pseudonymous contributions while maintaining security.

**Time to complete: 10-15 minutes**

> **Related Concepts**: Before or after completing this tutorial, you may want to read about [XID Fundamentals](../concepts/xid.md) and [Gordian Envelope Basics](../concepts/gordian-envelope.md) to understand the theoretical foundations.

## Prerequisites

- Basic terminal/command line familiarity
- The [Gordian Envelope-CLI](https://github.com/BlockchainCommons/bc-envelope-cli-rust) tool installed (release 0.27.0 or later recommended)
- Optional: [bc-dcbor-cli](https://github.com/BlockchainCommons/bc-dcbor-cli) (`dcbor` command) for advanced recovery workflows

## What You'll Learn

- How to create a basic XID for pseudonymous identity
- How to selectively encrypt just your private key (SSH-like model)
- How to create public versions of your XID using elision
- How to verify signatures and inspect provenance marks
- How to maintain strong cryptographic integrity while sharing selectively
- How to understand XID file organization using secure naming conventions

## Amira's Story: Why Pseudonymous Identity Matters

Amira is a successful software developer working at a prestigious multinational bank in Boston. With her expertise in distributed systems security, she earns a comfortable living, but she wants more purpose in her work. On the advice of her friend Charlene, Amira discovers RISK, a network that connects developers with social impact projects while protecting participants' privacy.

Given Amira's background in a politically tense region, contributing openly to certain social impact projects could risk her visa status, professional position, or even the safety of family members back home. Yet she's deeply motivated to use her skills to help oppressed people globally. This tension between professional security and meaningful contribution creates a specific need.

However, Amira faces a dilemma: she can't contribute anonymously because anonymous contributions lack credibility. Project maintainers need confidence in the quality and provenance of code, especially for socially important applications. She needs a solution that protects her identity while allowing her to build a verifiable reputation for her skills.

Amira needs a technological solution that allows her to:

1. Share her valuable security expertise without revealing her real identity
2. Build verifiable trust through the quality of her work, not her existing credentials
3. Establish a consistent "BRadvoc8" (Basic Rights Advocate) digital presence that can evolve and build reputation over time
4. Connect with project leaders like Ben from the women's services non-profit
5. Protect herself from adversaries who might target her for her contributions

This is where XIDs come in: they enable pseudonymous identity with progressive trust development, allowing Amira to safely collaborate on projects aligned with her values while maintaining separation between her pseudonymous contributions and her legal identity.

## Why XIDs Matter

XIDs provide significant advantages that go well beyond standard cryptographic keys:

1. **Stable identity** - XIDs maintain the same identifier even when you rotate keys
2. **Progressive trust** - XIDs let you selectively share different information with different parties
3. **Rich metadata** - XIDs can contain structured attestations, endorsements, and claims
4. **Peer validation** - XIDs enable others to make cryptographically verifiable claims about your identity
5. **Multi-key support** - XIDs can link multiple keys for different devices while maintaining a single identity
6. **Recovery mechanisms** - XIDs support recovery without losing your reputation history
7. **Cryptographic integrity** - XIDs preserve verifiability even when portions are elided

This first tutorial is deliberately simple to get you started with the basics. In subsequent tutorials, we'll explore more advanced capabilities like data minimization and rich persona structures.

## Step 1: Create Your XID

Now that we understand why XIDs are valuable, let's help Amira create her "BRadvoc8" identity.

Like creating an SSH key with `ssh-keygen`, this single operation creates your complete XID with both private and public keys:

👉
```sh
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
```

**What just happened?** This command created your complete, production-ready XID identity:
- **Generated keypairs**: Both private and public keys using modern algorithms
- **Encrypted private keys**: Protected with your password (like `ssh-keygen -N "passphrase"`)
- **Added provenance mark**: Genesis timestamp establishing when this identity was created
- **Signed the document**: Cryptographically signed for authenticity

**Keypairs created:**
- **SigningPrivateKey**: For creating signatures (Ed25519 algorithm)
- **EncapsulationPrivateKey**: For decryption (X25519 algorithm)
- **SigningPublicKey**: For signature verification (Ed25519 algorithm)
- **EncapsulationPublicKey**: For encryption (X25519 algorithm)

**Why Ed25519?**
- **Industry standard**: Same algorithm used by SSH, git, Signal, and modern security tools
- **Fast and secure**: Proven cryptography with excellent performance
- **Future-ready**: Later tutorials can export to SSH format for git commit signing
- **Better compatibility**: More widely supported than specialized signature schemes

> **Security Note**: Your XID contains your private keys (encrypted with your password). This is like your SSH `id_rsa` file - keep it secure! The same keys will always generate the same XID identifier deterministically.

**View your XID structure:**

👉
```sh
envelope format "$XID"
```

🔎
```
{
    XID(c7e764b7) [
        'key': PublicKeys(88d90933, SigningPublicKey(c5385c8f, Ed25519PublicKey(a1fae6ca)), EncapsulationPublicKey(a20a01e7, X25519PublicKey(a20a01e7))) [
            {
                'privateKey': ENCRYPTED [
                    'hasSecret': EncryptedKey(Argon2id)
                ]
            } [
                'salt': Salt
            ]
            'allow': 'All'
            'nickname': "BRadvoc8"
        ]
        'provenance': ProvenanceMark(632330b4) [
            {
                'provenanceGenerator': ENCRYPTED [
                    'hasSecret': EncryptedKey(Argon2id)
                ]
            } [
                'salt': Salt
            ]
        ]
    ]
} [
    'verifiedBy': Signature
]
```

**What you see:**
- **Curly braces** `{ }`: The XID is wrapped (required for signing)
- **XID identifier**: `XID(c7e764b7)` - Amira's unique identifier
- **Public keys**: `PublicKeys(...)` showing Ed25519PublicKey and X25519PublicKey - Safe to share
- **Private keys**: `ENCRYPTED` with `'hasSecret': EncryptedKey(Argon2id)` - Protected by password
- **Salt**: Random value that ensures each XID has a unique structure, preventing privacy leaks from comparing envelopes
- **Nickname**: `"BRadvoc8"` - Human-readable identifier
- **Provenance mark**: `ProvenanceMark(...)` - Establishes document genesis
- **Provenance generator**: Also `ENCRYPTED` - Used to advance the provenance chain (Tutorial 03)
- **Signature**: `'verifiedBy': Signature` - Document is cryptographically signed

The `ENCRYPTED` markers show sensitive data is protected. The `'hasSecret': EncryptedKey(Argon2id)` indicates password-based encryption using the Argon2id algorithm, which provides strong protection against brute-force attacks.

> **🔍 Notice the Predicate Styles**:
>
> You see two types of predicates in your XID:
> - **Single quotes** (`'key'`, `'provenance'`, `'verifiedBy'`): **Known predicates** - standardized names defined by the Gordian Envelope specification. These ensure different tools understand your XID the same way.
> - **Double quotes** (`"nickname"`, `"service"`, `"github"`): **String predicates** - custom names you define for application-specific data.
>
> **When to use each**:
> - Use **known predicates** when there's a standard meaning - the envelope spec defines dozens of these for common needs (`'key'`, `'isA'`, `'verifiedBy'`, `'note'`, etc.)
> - Use **string predicates** for custom data unique to your use case - anything specific to your application
>
> This distinction ensures interoperability: tools that understand envelopes will correctly interpret known predicates, while string predicates give you flexibility for custom data. In Tutorial 02, you'll add custom assertions using string predicates to build BRadvoc8's rich persona.

**You now have a production-ready XID!** It includes:
- ✅ Encrypted private keys
- ✅ Provenance tracking (for document lineage)
- ✅ Cryptographic signature (proving authenticity)
- ✅ Ready to share (after eliding private keys)

### 🔍 Understanding the Envelope Structure: Subject-Assertion-Object Model

Before going further, you need to understand the fundamental pattern that organizes all envelope data. This mental model will guide you through every tutorial and help you build and manipulate your BRadvoc8 identity effectively.

**Every envelope follows a simple but powerful pattern: Subject + Assertions**

Your XID structure breaks down like this:

```
{
    XID(c7e764b7)          ← THE SUBJECT (the main thing)
    [
        'key': PublicKeys(...)             ← ASSERTION 1 (predicate + object)
        'provenance': ProvenanceMark(...)  ← ASSERTION 2 (predicate + object)
    ]
}
```

**The Subject**: The main thing this envelope is about
- In your case: `XID(c7e764b7)` - your identity identifier
- This is what all the assertions describe

**Assertions**: Claims about the subject (predicate-object pairs)
- `'key': PublicKeys(...)` = "this XID **has** these public keys"
- `'provenance': ProvenanceMark(...)` = "this XID **has** this provenance history"

Think of it like natural language:
- **Subject** = "This XID" (the thing we're talking about)
- **Predicate** = "has key", "has provenance" (the relationship)
- **Object** = PublicKeys, ProvenanceMark (the value)

**This pattern repeats at every level**

Even the assertions can have their own assertions! Look at the `'key'` assertion:

```
'key': PublicKeys(88d90933) [     ← Subject of this nested envelope
    'allow': 'All'                 ← Assertion about the key
    'privateKey': ENCRYPTED        ← Another assertion
]
```

The public keys object is itself a subject with assertions about it!

**Why this matters for BRadvoc8**:
- You can **add assertions** to your XID (Tutorial 02: GitHub service, SSH keys)
- You can **remove assertions** via elision (coming up next: removing private keys)
- You can **nest assertions** to create rich structures (Tutorial 02: complex personas)
- Every envelope you encounter follows this same pattern

**The power of this model**: Once you understand subject-assertion-object, you can reason about any envelope structure - from simple XIDs to complex attestations to nested persona data. It's the universal grammar of Gordian Envelopes.

### 🔍 About the Abbreviated Display

Notice that `envelope format` shows abbreviated labels like `PublicKeys(32de0f2b)`, `ENCRYPTED`, and `Salt` rather than the actual data. This is intentional - the formatter recognizes known cryptographic types and displays them concisely for readability.

**What's contained inside these abbreviations:**

**`PublicKeys(32de0f2b)`** contains:
- **SigningPublicKey** - Used to verify signatures (Ed25519 in this case)
- **X25519PublicKey** - Used for encryption key agreement

The display doesn't show these two keys separately, but they're both in there! This is why it's called PublicKeys (plural) - it's a composite containing two cryptographic keys for different purposes.

**`ENCRYPTED`** contains:
- The actual encrypted PrivateKeys data (ciphertext)
- Argon2id key derivation parameters
- Nonce/IV for the encryption

**`Salt`** contains:
- Random bytes (typically 16-32 bytes)
- Makes each XID's envelope digest unique
- Prevents correlation by digest matching

**Why abbreviate?** To keep things readable. Showing full cryptographic data (hundreds of bytes of base64/hex) would obscure the structure. The abbreviated view lets you focus on the **relationships** between components rather than the raw bytes.

**Keypairs and XID Structure**: Your XID contains both `PrivateKeys` and `PublicKeys` that were generated together as keypairs:
- **SigningPrivateKey** - Used to create signatures (Ed25519 algorithm)
- **EncapsulationPrivateKey** - Used for decryption (X25519 algorithm)
- **SigningPublicKey** - Used to verify signatures (Ed25519 algorithm)
- **EncapsulationPublicKey** - Used for encryption (X25519 algorithm)

> **Important**: The same keypairs will always create the same XID structure (deterministic). The XID identifier is derived from the public key, so the same keypairs always produce the same XID identifier.

> **Learn more**: [Key Derivation](concepts/key-derivation.md)

### 🔍 What Just Happened: Understanding Keypairs in XIDs

When you piped keypairs to `envelope xid new`, the CLI embedded your keypairs into the XID structure:

**The Process:**
```
Step 1: Your input
  Keypairs (ur:crypto-prvkeys + ur:crypto-pubkeys)
  ├─ SigningPrivateKey + SigningPublicKey
  └─ EncapsulationPrivateKey + EncapsulationPublicKey

Step 2: CLI creates XID structure
  XID embeds both private and public keys
  ├─ PrivateKeys (encrypted with your password)
  └─ PublicKeys (always readable)

Step 3: Result
  Complete identity document with all cryptographic material
```

**Critical to understand:**

| Aspect | Input Keypairs | Keys in XID |
|--------|---------------|-------------|
| What it is | Matched private+public key pairs | Same keys embedded in XID structure |
| **Contains** | Two keypairs (signing + encryption) | **SigningPrivateKey + EncapsulationPrivateKey + PublicKeys** |
| Purpose | Generate XID | Operational keys for signing/decryption |
| Location | Your input variable | Embedded in XID document |
| Format | UR format (`ur:crypto-prvkeys`) | CBOR envelope format |
| Display | Not shown in tutorial | `PrivateKeys(hash, SigningPrivateKey(...), EncapsulationPrivateKey(...))` |

> **Note**: The `envelope format` display shows algorithm details in version 0.27.0+. In this tutorial, the private keys are encrypted so you see `ENCRYPTED` instead of the actual keys. The public keys are always visible and show both SigningPublicKey and EncapsulationPublicKey (X25519PublicKey).

**Why this matters:** Your XID is your complete identity. The private keys embedded in it are what make it yours - losing the XID file means losing your identity, just like losing an SSH `id_rsa` file.

## Step 2: Creating a Public Version by Elision

Now Amira wants to create a shareable public version. Instead of creating a new XID, she **elides** (removes) the private key from her XID. This is a key envelope feature: **elision preserves the root hash**.

First, since the XID was automatically wrapped and signed with `--sign inception`, we need to unwrap it to access its assertions:

👉
```sh
# Unwrap the signed XID to access its assertions
UNWRAPPED_XID=$(envelope extract wrapped "$XID")
```

Now find the digest of the encrypted private key:

👉
```sh
# Find the key assertion
KEY_ASSERTION=$(envelope assertion find predicate known key "$UNWRAPPED_XID")
KEY_OBJECT=$(envelope extract object "$KEY_ASSERTION")

# Find the private key assertion within the key object
PRIVATE_KEY_ASSERTION=$(envelope assertion find predicate known privateKey "$KEY_OBJECT")
PRIVATE_KEY_DIGEST=$(envelope digest "$PRIVATE_KEY_ASSERTION")

echo "Found private key digest"
```

Now elide the private key to create a public version:

👉
```sh
PUBLIC_XID=$(envelope elide removing "$PRIVATE_KEY_DIGEST" "$XID")
echo "Created public version by eliding private key"
```

View the public version:

👉
```sh
envelope format "$PUBLIC_XID"
```

🔎
```
{
    XID(c7e764b7) [
        'key': PublicKeys(32de0f2b) [
            'allow': 'All'
            'nickname': "BRadvoc8"
            ELIDED                      ← Private key removed
        ]
        'provenance': ProvenanceMark(632330b4) [
            {
                'provenanceGenerator': ENCRYPTED [
                    'hasSecret': EncryptedKey(Argon2id)
                ]
            } [
                'salt': Salt
            ]
        ]
    ]
} [
    'verifiedBy': Signature
]
```

**Important distinction - XID identifier vs Envelope hash:**

Notice `XID(c7e764b7)` is the same as before. But **this doesn't prove elision preserved the hash!** Here's why:

- **`XID(c7e764b7)`** = XID identifier (derived from the public key)
  - Stays the same across ALL versions of this identity
  - Would be the same even if you completely changed the document
  - Identifies the **entity**, not the document version

- **Envelope digest** = Hash of the entire envelope structure
  - Changes when document content changes
  - THIS is what elision preserves
  - THIS is what allows signatures to verify

**Critical:** The XID identifier is persistent (based on public key), so seeing it unchanged proves nothing about hash preservation. We need to compare the **envelope digest**.

### Proving Elision Preserves the Envelope Hash

The tutorial claims that elision preserves the root hash. Let's **verify** this claim by comparing the digests:

👉
```sh
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
```

🔎
```
Original XID digest: ur:digest/hdcxzswfhsqdfmlujtjnkiylsfwshytlynfzglaeenksjtmweeqzswnebnlumdytfgqdlbgs
Public XID digest:   ur:digest/hdcxzswfhsqdfmlujtjnkiylsfwshytlynfzglaeenksjtmweeqzswnebnlumdytfgqdlbgs
✅ VERIFIED: Digests are identical - elision preserved the root hash!
```

**Critical Observation**: The digests are **exactly the same!** This proves that elision doesn't change the envelope hash.

**What this means**:
- The **envelope hash** (digest we just compared) is identical before and after elision
- The signature was created over the **full envelope** (with encrypted private key)
- The signature **verifies on the elided version** (without private key)
- This proves they're the **same cryptographic commitment**, just different views
- You can cryptographically prove properties about data you can't see!

### 🔍 Understanding WHY Elision Preserves the Hash

You just proved something remarkable: you removed data (the private key), yet the envelope digest stayed identical. This seems impossible - how can removing data not change the hash?

**The secret: Merkle tree structure**

Envelopes use a structure similar to Merkle trees where each part has its own hash that combines into parent hashes. Here's how your XID's hash is actually calculated:

```
Envelope Root Hash
    ├─ Subject Hash (XID identifier)
    ├─ Assertion 1 Hash ('key' → PublicKeys)
    ├─ Assertion 2 Hash ('provenance' → ProvenanceMark)
    └─ Assertion 3 Hash (nested 'privateKey' → ENCRYPTED)
```

**How elision works**:

1. **Each assertion is hashed independently**
   - `'key' assertion` → produces hash `abc123...`
   - `'privateKey' assertion` (nested) → produces hash `def456...`
   - etc.

2. **Root hash is calculated FROM these hashes**
   - Root = hash(subject_hash + assertion_hash_1 + assertion_hash_2 + ...)
   - The root doesn't hash the content directly, it hashes the hashes!

3. **When you elide, you remove content but KEEP the hash**
   - Before eliding: `'privateKey': ENCRYPTED` → hash `def456...` used in parent calculation
   - After eliding: `ELIDED` → **still uses hash `def456...`** in parent calculation
   - The actual encrypted data is gone, but its hash remains

4. **Root hash stays the same because the hash inputs are unchanged**
   - Still calculating: hash(subject_hash + hash_1 + hash_2 + hash_3...)
   - The hashes themselves haven't changed, only the content visibility changed

**Visual comparison**:

```
Full version:
    XID [key: PublicKeys, privateKey: ENCRYPTED, ...]
         ↓ (calculate digests)
    Root hash: ur:digest/hdcxzswf...

Elided version:
    XID [key: PublicKeys, ELIDED (hash=def456), ...]
         ↓ (calculate digests using same hashes)
    Root hash: ur:digest/hdcxzswf... ← SAME!
```

The root hash is calculated from the hashes of parts, not the parts themselves. When you elide, you keep the hash of the elided part in the calculation, so the root hash doesn't change.

**Why this is powerful for BRadvoc8**:

- ✅ Sign once (over full data including private keys)
- ✅ Create elided versions (removing sensitive data)
- ✅ Signature verifies on ALL versions (same root hash)
- ✅ **Prove properties without revealing data** - the foundation of selective disclosure
- ✅ Share different views with different people - all cryptographically valid

This Merkle tree property enables all the data minimization you'll do in Tutorial 02. You can create different views of your identity (for Ben, for public) while maintaining cryptographic integrity across all versions. Amira can prove she has a GitHub account to Ben while showing nothing to the public - all from the same signed XID.

> **Technical note**: While similar to Merkle trees used in blockchain, Gordian Envelopes extend the concept to handle arbitrary assertion graphs, not just linear chains. This flexibility enables complex identity structures while preserving the hash-preserving properties of elision.

**Understanding the two different identifiers:**

| Identifier | What it identifies | Changes when... | Purpose |
|------------|-------------------|-----------------|----------|
| **XID identifier** (`XID(c7e764b7)`) | The **entity** (person/thing) | Public key changes | Persistent identity across document versions |
| **Envelope digest** (`ur:digest/hdcx...`) | The **document version** | Content changes | Cryptographic commitment for signatures |

**Key insights:**

**XID identifier** stays the same even if you:
- Change the nickname
- Add/remove assertions
- Elide content
- Update the document in any way (as long as public key is same)
- **It's persistent across ALL document versions**

**Envelope digest** behavior:
- ✅ **Changes** when you add new assertions (normal modification)
- ✅ **Changes** when you remove assertions (normal deletion)
- ✅ **Changes** when you modify existing content
- ⚠️ **Preserved** when you use elision (special property!)

**This is the magic of elision:**
- Normal edits (add/remove assertions) → envelope hash changes
- Elision (remove via `envelope elide`) → envelope hash **preserved**
- This is why signatures verify on elided versions!
- Elision is the ONLY way to remove data without changing the hash

> **Key Envelope Property**: Elision removes data while preserving cryptographic integrity. The root hash remains unchanged, so signatures over the complete document verify on elided versions. This enables data minimization while maintaining verifiability.

**Why this is powerful:**
- Sign once (over full data)
- Create multiple elided versions (removing different sensitive parts)
- All versions have the same root hash
- Signature verifies on ALL versions
- Recipients can verify without seeing the elided data!

## Step 3: Verification

Now let's verify both the signature and provenance on our XID:

👉
```sh
# Extract public keys (the XID contains everything needed for verification)
KEY_ASSERTION=$(envelope assertion find predicate known key "$UNWRAPPED_XID")
KEY_OBJECT=$(envelope extract object "$KEY_ASSERTION")
PUBLIC_KEYS=$(envelope extract ur "$KEY_OBJECT")

# Verify the signature
envelope verify -v "$PUBLIC_KEYS" "$PUBLIC_XID" >/dev/null && echo "✅ Signature verified!"
```

🔎
```
✅ Signature verified!
```

Now verify the provenance mark - notice we can verify from the **public** XID:

👉
```sh
# Extract the provenance mark from the PUBLIC XID (no secrets needed!)
PROVENANCE_MARK=$(envelope xid provenance get "$PUBLIC_XID")

# Verify it's a valid genesis mark
provenance validate "$PROVENANCE_MARK"
```

🔎
```
✅ (silent success - validation passed!)
```

Want to see what was verified? Get the detailed report:

👉
```sh
# Show detailed validation report
provenance validate --format json-pretty "$PROVENANCE_MARK"
```

🔎
```json
{
  "chains": [
    {
      "chain_id": "...",
      "has_genesis": true,
      "sequences": [
        {
          "start_seq": 0,
          "end_seq": 0,
          "marks": [
            {
              "mark": "ur:provenance/...",
              "issues": []
            }
          ]
        }
      ]
    }
  ]
}
```

**What just happened?**
- ✅ **Signature verified** - Confirms this XID is authentically from BRadvoc8
- ✅ **Provenance verified** - Confirms this is a valid genesis mark (sequence 0, no issues)
- Both verifications worked from the **public XID** - no secrets required!

**What requires secrets vs. what's public:**

| Operation | Requires Secrets? | What You Need |
|-----------|------------------|---------------|
| **Verify signature** | ❌ No | Public keys only |
| **Verify provenance** | ❌ No | Provenance mark (public) |
| **Create signature** | ✅ Yes | Private signing key |
| **Advance provenance** | ✅ Yes | Encrypted generator |

**What the verification proves:**
- `has_genesis: true` - This is the first mark in a provenance chain
- `sequence: 0` - Genesis mark (version 1 of this XID)
- `issues: []` - No validation problems detected

> **Key insight**: Just like signature verification only needs public keys, provenance verification only needs the mark itself (which is public). You only need secrets to *create* new signatures or *advance* the provenance mark to the next version.

## What Just Happened? Understanding the Modern XID Workflow

Let's review what we created and why each piece matters:

### Encrypted Private Keys (`--private encrypt`)

When we created the XID, we used `--private encrypt --encrypt-password` to protect the private keys. This is the **SSH-like model**:

- Your XID contains both private and public keys (like `id_rsa` and `id_rsa.pub`)
- Private keys are encrypted with your password (like `ssh-keygen -N "passphrase"`)
- Public parts (nickname, public keys, provenance) remain readable without password
- Only decryption operations require the password

**Why this matters**: You can freely share your XID file or store it in email, cloud storage, or version control - the private keys are protected by encryption.

### Provenance Marks (`--generator encrypt`)

The `'provenance'` section establishes **document genesis** - a timestamped record of when and how this XID was created:

```
'provenance': [
    'continuations': ProvenanceLog [
        {
            'date': 2025-11-17T00:00:00Z
        } [
            'generator': "bc-envelope-cli-rust/0.27.0"
        ]
    ]
]
```

**What this provides:**
- **Timestamp**: When this identity was created (inception date)
- **Generator info**: Which tool created it (useful for compatibility tracking)
- **Version tracking foundation**: As you update your XID in future tutorials, new provenance marks create an auditable history

**Why it's brief here**: Provenance becomes critical in Tutorial 03 when you start advancing your XID with updated information. For now, it's just marking your starting point.

> **Learn more**: Tutorial 03 will show how provenance marks create cryptographic lineage as your identity evolves.

### Auto-Signing (`--sign inception`)

The `'verifiedBy': Signature` proves cryptographic authenticity. When we used `--sign inception`, the CLI:

1. Wrapped your XID (the `{ }` curly braces)
2. Decrypted your private keys using your password
3. Created a signature over the entire document
4. Attached the signature to the envelope

**The sign-then-elide workflow:**
- Sign the complete document (with encrypted private keys)
- Elide the private keys for sharing (public version)
- Signature verifies on BOTH versions (elision preserves the hash!)
- This is how data minimization with verification works

**Why automatic is better**:
- **Best practice from day 1**: Production XIDs should always be signed
- **Simpler workflow**: 2 commands to working XID (vs 8 with manual signing)
- **Proven security model**: Sign-then-elide is the correct pattern

**What about manual signing?** You'll learn the mechanics in Tutorial 02 when we cover building and publishing your identity - where understanding the signing process is more relevant.

> **Learn more**: The [Signing and Verification](../concepts/signing.md) concept doc explains the cryptographic details.

### One-Operation Workflow Summary

Creating a production-ready XID is remarkably simple:

```bash
# Generate Ed25519 keypairs and create signed XID in one operation
XID=$(envelope generate keypairs --signing ed25519 | \
    envelope xid new \
    --private encrypt \
    --encrypt-password "$PASSWORD" \
    --nickname "$NAME" \
    --generator encrypt \
    --sign inception)
```

**What you get:**
- ✅ Complete identity document
- ✅ Encrypted private keys
- ✅ Provenance tracking
- ✅ Cryptographic signature
- ✅ Ready to share (after eliding private keys)
- ✅ Best practices built-in

**Core value preserved**: Tutorial 01 still teaches the critical insight - **elision preserves the root hash**, enabling data minimization with cryptographic integrity. The automated signing just removes mechanical complexity that's better learned in context (Tutorial 02).

## Proper File Organization

For real-world usage, Amira will want to organize her files in a dedicated directory with clear naming conventions. Like SSH keys, she'll have two files:

**SSH Mental Model:**

| SSH | XID | Purpose |
|-----|-----|---------|
| `id_rsa` | `BRadvoc8-xid.envelope` | 🔒 Your complete identity (encrypted private keys) |
| `id_rsa.pub` | `BRadvoc8-xid-public.envelope` | ✅ Public version (safe to share) |

**File structure:**

```
xid-20251117/
├── BRadvoc8-xid.envelope          # 🔒 Your complete XID (like id_rsa)
├── BRadvoc8-xid.format            #    Human-readable version
├── BRadvoc8-xid-public.envelope   # ✅ Public XID (like id_rsa.pub)
└── BRadvoc8-xid-public.format     #    Human-readable version
```

**File naming conventions:**
- `.envelope` extension = Binary serialized format (for tools)
- `.format` extension = Human-readable version (for humans)

**Security levels:**
- 🔒 **KEEP SECRET**: `BRadvoc8-xid.envelope` - Contains your encrypted private keys
- ✅ **SAFE TO SHARE**: `BRadvoc8-xid-public.envelope` - Public keys only (private keys elided)

All files are stored in a timestamp-based directory (e.g., `xid-20251117`) to keep versions organized.

**Your XID is your complete identity - backup it like an SSH key:**
- The `BRadvoc8-xid.envelope` file contains everything: private keys (encrypted), public keys, nickname, provenance, and signature
- If you lose this file, you lose your identity (just like losing `id_rsa`)

**Important**: Unlike traditional SSH keys, your XID includes identity metadata (nickname, permissions, provenance history). This makes it a complete, self-contained identity document - not just raw key material.

## Understanding What Happened

Beyond the technical mechanics covered in the previous sections, there are several deeper insights about what this XID enables:

1. **Self-Sovereign Identity**: BRadvoc8's identity is fully under Amira's control with no central authority. No service provider issued this identifier, and she maintains complete ownership of both the keys and the resulting XID document.
    > **Why this matters**: Unlike traditional identities (email accounts, social profiles) that can be suspended or controlled by providers, BRadvoc8's XID remains under Amira's control regardless of any third party.

2. **Pseudonymity vs. Anonymity**: This XID implements **pseudonymity** rather than anonymity. The identity "BRadvoc8" can build reputation over time through verifiable contributions, while still protecting Amira's real-world identity.
    > **Real-World Analogy**: This is similar to how authors might use pen names (like Mark Twain for Samuel Clemens) - they can build reputation under their pseudonym while keeping their personal identity separate.

3. **Autonomous Storage**: The encrypted XID can be stored anywhere without infrastructure - on a USB drive, in email, printed as a QR code, or cloud storage - because it's a self-contained cryptographic object protected by your password.

4. **Signature and Provenance Verification**: The signature proves authenticity, and the ProvenanceMark confirms this is the first version (inception), establishing the baseline for future provenance chain verification. The timestamp in the provenance is asserted (not cryptographically verified), but the inception mark allows verifying that future updates came after this point.

## Common Questions

### Q: Why Ed25519 instead of Schnorr or other algorithms?

**A:** Ed25519 is the industry standard (SSH, git, Signal) with wide compatibility and excellent security. Advanced users can use other algorithms (`--signing schnorr`, `--signing ecdsa`, `--signing mldsa44`), but Ed25519 is recommended for beginners.

### Q: What if I lose my XID file?

**A:** If you lose your `BRadvoc8-xid.envelope` file without a backup, **you lose your identity**. This is just like losing your SSH `id_rsa` file. There's no recovery mechanism without a backup - make sure to store encrypted copies in multiple secure locations.

### Q: Can I use this XID on multiple devices?

**A:** Yes! Copy your `BRadvoc8-xid.envelope` file to other devices. Since the private keys are encrypted, the file is safe to sync via cloud storage (as long as you have a strong password).

**Like SSH keys**: You can use the same XID across multiple devices, just like you might copy `id_rsa` to a new machine. The XID identifier stays the same regardless of which device you're using.

**Advanced (Tutorial 02-03)**: You can also create device-specific keys and delegate permissions, allowing each device to have its own key while maintaining a single XID identity.

## Key Terminology

> **XID (eXtensible IDentifier)** - A self-contained identity document combining public keys, metadata, provenance, and cryptographic signatures into a single shareable object.
>
> **Subject** - The main thing an envelope describes; in XIDs, this is the XID identifier derived from your public key.
>
> **Assertion** - A predicate-object pair making a claim about the subject (e.g., `'key': PublicKeys(...)`).
>
> **Known Predicate** - Standardized predicate from the Gordian Envelope spec, shown in single quotes (`'key'`, `'verifiedBy'`, `'provenance'`).
>
> **String Predicate** - Custom application-specific predicate, shown in double quotes (`"nickname"`, `"service"`).
>
> **Elision** - Removing data while preserving the envelope's root hash, enabling selective disclosure with maintained cryptographic integrity.
>
> **Provenance Mark** - Cryptographic timestamp establishing when a document was created or updated, forming a verifiable chain of identity evolution.
>
> **Envelope Digest** - The root hash of an envelope structure; preserved across elision, enabling signature verification on different views of the same document.

## What's Next

Amira now has a basic, secure XID - but it's quite simple. In the next tutorial, she'll build her BRadvoc8 persona and make it discoverable so others (like Ben from SisterSpaces) can find and verify her identity. We'll learn how to:

- **Build rich persona structures** - Add GitHub account info, SSH signing keys, and structured metadata
- **Understand key separation** - Why different keys for different purposes (identity vs code signing)
- **Add dereferenceVia assertions** - Tell the world where to find your canonical XID
- **Establish repository authority** - Use Open Integrity inception commits to prove you control a GitHub repo
- **Publish your XID** - Make BRadvoc8 discoverable while maintaining pseudonymity
- **Verify updates** - How others can confirm they have your latest, authentic XID
- **Master manual signing** - Understand the wrap → sign → unwrap workflow (we automated this for simplicity)
- **Advance provenance** - Update your XID and maintain cryptographic lineage

The key insight: You'll make your XID **discoverable** so endorsers can find you, while maintaining control over what information is public. This enables the trust-building that comes in Tutorial 03.

## Exercises

1. Create your own XID with a pseudonym of your choice
2. Experiment with different passwords for protecting your private key
3. Practice creating public versions by eliding the private keys
4. Try signature verification and provenance inspection using your own XID
5. Save and load your XID from files, then verify the signature still works

## Example Script

A complete working script implementing this tutorial is available at `tests/01-your-first-xid-TEST.sh`. Run it to see all steps in action:

```sh
bash tests/01-your-first-xid-TEST.sh
```

This script will create all the files shown in the File Organization section with proper naming conventions and directory structure.

---

**Next Tutorial**: [Building & Publishing Your Identity](02-building-publishing.md) - Build your persona, add discovery mechanisms, and make BRadvoc8 findable while maintaining pseudonymity.
