# Making Your XID Verifiable

In Tutorial 01, Amira created her BRadvoc8 identity. Now she wants Ben from SisterSpaces to be able to verify that he always has the current version of her XIDDoc. This tutorial shows how to make your XIDDoc fetchable and verifiable without relying on direct communication.

**Time to complete**: ~10-15 minutes
**Difficulty**: Beginner
**Builds on**: Tutorial 01

> **Related Concepts**: This tutorial introduces verification and freshness. To understand the underlying principles, see [Progressive Trust](../concepts/progressive-trust.md) for how trust builds incrementally, and [Data Minimization](../concepts/data-minimization.md) for controlling what you disclose when publishing.

## Prerequisites

- Completed Tutorial 01 (have a working XIDDoc)
- The [Gordian Envelope-CLI](https://github.com/BlockchainCommons/bc-envelope-cli-rust) tool installed (release 0.32.0 or later)
- A GitHub account (for publishing - can use any public URL)

## What You'll Learn

**Part I - Amira publishes:**
- How to add a `dereferenceVia` assertion pointing to where your XIDDoc can be fetched
- How to export a public version suitable for publishing

**Part II - Ben verifies:**
- How to verify an XID's signature (self-consistency)
- How to check `dereferenceVia` matches the fetch URL
- How to check provenance marks for freshness
- What trust level this establishes (and what it doesn't)

## The Freshness Problem

After Tutorial 01, Amira can give Ben her public XIDDoc directly—email it, share via Signal, whatever works. But what happens when she updates her XIDDoc next month? Ben has no way to know his copy is stale. He might verify signatures against outdated information, missing that Amira added new attestations or rotated keys.

One simple solution is to publish the XIDDoc at a stable URL and embed that URL in the document itself (we'll discuss other solutions in a future tutorial). Now Ben can fetch the current version whenever he needs it and verify through provenance marks that his copy is actually current, not an old snapshot someone gave him.

This isn't about discovery (how Ben finds Amira's XID in the first place). It's about freshness (how Ben verifies he has the current version).

---

## Part I: Amira Publishes

You'll add a publication URL to your XIDDoc and publish a public version.

### Step 0: Verify Dependencies

Ensure you have the required tools from Tutorial 01:

```
envelope --version
provenance --version

│ bc-envelope-cli 0.32.0
│ provenance-mark-cli 0.6.0
```

If not installed, see Tutorial 01 Step 0 for installation instructions.

### Step 1: Load Your XID

Load your XIDDoc from Tutorial 01. If you saved it to a file:

```
XID_NAME="BRadvoc8"
PASSWORD="your-password-from-tutorial-01"

# If you saved to file:
XID=$(cat xid-*/BRadvoc8-xid.envelope)

# Or recreate for this tutorial:
XID=$(envelope generate keypairs --signing ed25519 | \
    envelope xid new \
    --private encrypt \
    --encrypt-password "$PASSWORD" \
    --nickname "$XID_NAME" \
    --generator encrypt \
    --sign inception)

echo "Loaded XID: $XID_NAME"
envelope format "$XID" | head -10

│ Loaded XID: BRadvoc8
│ {
│     XID(c7e764b7) [
│         'key': PublicKeys(...) [
│             ...
│             'nickname': "BRadvoc8"
│         ]
│         'provenance': ProvenanceMark(632330b4) [
│             ...
```

### Step 2: Choose Your Publication URL

Before adding `dereferenceVia`, decide where you'll publish. For this tutorial, we'll use a GitHub repository, but any stable URL works—personal website, IPFS gateway, wherever you control.

```
# Your publication URL - we'll use a GitHub repository
PUBLISH_URL="https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt"
```

> :warning: **Raw Content Required**: Your URL must point to raw content, not an HTML page. For GitHub repositories, use the `/raw/` URL path. If verifiers fetch an HTML page instead of the actual XID data, verification will fail.

### Step 3: Add dereferenceVia Assertion

Now add a `dereferenceVia` assertion that tells others where to fetch the current version of your XIDDoc:

```
XID_WITH_URL=$(envelope xid resolution add \
    "$PUBLISH_URL" \
    --verify inception \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$XID")

echo "Added dereferenceVia"
envelope format "$XID_WITH_URL" | head -20

│ Added dereferenceVia
│ {
│     XID(c7e764b7) [
│         'dereferenceVia': URI(https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt)
│         'key': PublicKeys(...) [
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
│             ...
│         ]
│     ]
│ } [
│     'signed': Signature(Ed25519)
│ ]
```

This command does several things at once:

1. `xid resolution add "$PUBLISH_URL"` adds a `dereferenceVia` assertion with your URL
2. `--verify inception` checks the existing signature before modifying
3. `--password "$PASSWORD"` decrypts secrets needed for signing
4. `--sign inception` re-signs the updated document
5. `--private encrypt` and `--generator encrypt` keep secrets encrypted
6. `--encrypt-password "$PASSWORD"` sets the encryption password

The result: a `'dereferenceVia': URI(...)` assertion was added, the signature was verified and refreshed, and private keys stayed encrypted. Notice that `dereferenceVia` is a known value (single quotes) from the Gordian Envelope specification, and its object is a `URI` type rather than a plain string. This assertion tells anyone who receives your XIDDoc: "To get the current version, fetch from this URL."

You can add multiple `dereferenceVia` assertions for redundancy by running the command again with a different URL. For example, you might point to both a GitHub raw URL and a personal domain, so if one source becomes unavailable, verifiers can still fetch your current XIDDoc from the other.

### Step 4: Export Public Version

Create a version safe for publishing by eliding the private keys and provenance generator:

```
PUBLIC_XID=$(envelope xid export --private elide --generator elide "$XID_WITH_URL")

echo "Exported public version"
envelope format "$PUBLIC_XID"

│ Exported public version
│ {
│     XID(c7e764b7) [
│         'dereferenceVia': URI(https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt)
│         'key': PublicKeys(...) [
│             'allow': 'All'
│             'nickname': "BRadvoc8"
│             ELIDED
│         ]
│         'provenance': ProvenanceMark(632330b4) [
│             ELIDED
│         ]
│     ]
│ } [
│     'signed': Signature(Ed25519)
│ ]
```

> :book: **Callback to Tutorial 01**: In Tutorial 01, you manually found digests and used `envelope elide removing` to create public versions. The `xid export` command does this automatically—it knows which parts of an XID should be elided for public sharing.

Notice the difference: where your complete XID shows `ENCRYPTED`, the public version shows `ELIDED`. The signature is still present and verifiable, the XID identifier is unchanged, but the private key and provenance generator are replaced with placeholders.

Why elide rather than simply omit? Elision keeps the hash contribution while removing the content, so the signature still verifies. If you omitted the private key entirely, the envelope's hash would change, invalidating the signature.

### Step 5: Publish Your XID

Now publish the public version. We'll use a GitHub repository:

```
# Save the public XID to a file
echo "$PUBLIC_XID" > /tmp/xid-public.txt

echo "Public XID saved to /tmp/xid-public.txt"
echo "Contents:"
cat /tmp/xid-public.txt
```

To publish on GitHub: create a repository named after your XID (e.g., `BRadvoc8/BRadvoc8`), add a file named `xid.txt`, and commit your public XID content. The raw URL follows a predictable pattern: `https://github.com/USERNAME/REPO/raw/main/xid.txt`.

> :warning: **Chicken-and-Egg**: You need the URL to add `dereferenceVia`, but you need to create the repo to get the URL. The solution: GitHub URLs are predictable. Decide your repo name first, construct the URL, add it to your XID, then create the repo with that content. If you change the URL later, you must re-sign and republish.

---

## Part II: Ben Verifies

**Perspective shift**: You've been Amira, creating and publishing your XID. Now you're Ben—someone who received an XID URL and needs to verify it before trusting the sender.

This matters because anyone can publish anything. Ben received a message claiming to be "BRadvoc8," but how does he know the message is legitimate? How does he know he has the current version, not a stale copy? The verification workflow answers these questions without requiring direct contact with Amira.

### Ben's Starting Point

Ben received a message from someone claiming to be "BRadvoc8":

> "Hey Ben, I'm interested in contributing to SisterSpaces. Here's my XID: https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt"

Ben doesn't know if this is legitimate. He needs to verify.

### Step 6: Ben Fetches the XIDDoc

Ben fetches the XIDDoc from the URL Amira provided:

```
# Ben's perspective - he only has the URL
RECEIVED_URL="https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt"

# Fetch the XIDDoc (simulated - in practice, use curl)
# FETCHED_XID=$(curl -s "$RECEIVED_URL")

# For this tutorial, simulate with the published XID
FETCHED_XID="$PUBLIC_XID"

echo "Fetched XIDDoc from: $RECEIVED_URL"
envelope format "$FETCHED_XID" | head -15

│ Fetched XIDDoc from: https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt
│ {
│     XID(c7e764b7) [
│         'dereferenceVia': URI(https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt)
│         'key': PublicKeys(...) [
│             'allow': 'All'
│             'nickname': "BRadvoc8"
│             ELIDED
│         ]
│         'provenance': ProvenanceMark(632330b4) [
│             ELIDED
│         ]
│     ]
│ } [
│     'signed': Signature(Ed25519)
│ ]
```

Ben now has an XIDDoc. But can he trust it?

### Step 7: Ben Verifies the Signature

First, Ben checks if the XID is self-consistent - signed by its own key:

```
# Extract the public keys from the XID itself
UNWRAPPED=$(envelope extract wrapped "$FETCHED_XID")
KEY_ASSERTION=$(envelope assertion find predicate known key "$UNWRAPPED")
KEY_OBJECT=$(envelope extract object "$KEY_ASSERTION")
PUBLIC_KEYS=$(envelope extract ur "$KEY_OBJECT")

# Verify the signature
if envelope verify -v "$PUBLIC_KEYS" "$FETCHED_XID" >/dev/null 2>&1; then
    echo "✅ Signature verified - XID is self-consistent"
else
    echo "❌ Signature FAILED - XID may be tampered!"
    exit 1
fi

│ ✅ Signature verified - XID is self-consistent
```

The signature verified, which means the document is signed by its own inception key and no tampering occurred after signing. The signature covers the entire document, so any modification would fail verification.

> :book: **XID Self-Containment**: Notice that Ben extracted the verification keys from the XID itself. He didn't need Amira to send keys separately. XIDs contain everything needed for verification. "Share XIDs, not keys."

#### What If the XID Was Tampered?

What happens if an attacker intercepts and modifies the XID before Ben receives it?

```
# Simulate tampering - an attacker changes the nickname
TAMPERED_XID=$(echo "$FETCHED_XID" | sed 's/BRadvoc8/Imposter/')

# Ben tries to verify the tampered version
if envelope verify -v "$PUBLIC_KEYS" "$TAMPERED_XID" >/dev/null 2>&1; then
    echo "✅ Signature verified"
else
    echo "❌ Signature FAILED - tampering detected!"
fi

│ ❌ Signature FAILED - tampering detected!
```

Any modification—even a single character—invalidates the signature. The cryptographic hash of the tampered document no longer matches what was signed. This is why signature verification is Ben's first check: it catches any tampering that occurred after Amira signed the document.

> :brain: **Learn more**: The [Signing and Verification](../concepts/signing-verification.md) concept doc explains how envelope signatures work and why elision preserves signature validity.

### Step 8: Ben Checks the dereferenceVia URL

Ben compares where he fetched the XIDDoc from to the `dereferenceVia` URL inside it:

```
# Extract the dereferenceVia URL from the XID
DEREFERENCE_ASSERTION=$(envelope assertion find predicate known dereferenceVia "$UNWRAPPED")
DEREFERENCE_URL=$(envelope extract object "$DEREFERENCE_ASSERTION" | envelope format)

echo "URL Ben fetched from:     $RECEIVED_URL"
echo "dereferenceVia in XID:    $DEREFERENCE_URL"

# In a real scenario, Ben would compare these
# The dereferenceVia shows as URI(...) format, so we check if it contains the URL
if echo "$DEREFERENCE_URL" | grep -q "github.com/BRadvoc8"; then
    echo "✅ URLs match - XID claims this is its canonical location"
else
    echo "⚠️  URLs don't match - XID may have been copied from elsewhere"
fi

│ URL Ben fetched from:     https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt
│ dereferenceVia in XID:    URI(https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt)
│ ✅ URLs match - XID claims this is its canonical location
```

If the URLs match, the document "knows" where it's published—the document and its location agree. If someone copied it to a different location, the `dereferenceVia` would still point to the original, tipping Ben off that he might not be fetching from the canonical source.

### Step 9: Ben Checks Provenance

Now Ben checks the provenance mark to understand its history:

```
# Extract and check the provenance mark
PROVENANCE_MARK=$(envelope xid provenance get "$FETCHED_XID")

echo "Checking provenance mark..."
provenance validate "$PROVENANCE_MARK" && echo "✅ Provenance chain intact"

# Get detailed information
echo ""
echo "Provenance details:"
provenance validate --format json-pretty "$PROVENANCE_MARK"

│ Checking provenance mark...
│ ✅ Provenance chain intact
│
│ Provenance details:
│ {
│   "chains": [
│     {
│       "chain_id": "632330b4...",
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

The output tells Ben this chain has a valid starting point (`has_genesis: true`), this is the original version with no updates yet (`start_seq: 0, end_seq: 0`), and there are no problems found (`issues: []`). If Amira had made updates, the sequence numbers would be higher and Ben could verify the chain of updates is unbroken.

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

### Step 10: Ben's Verification Summary

Ben can now summarize what he knows:

```
echo "=== Ben's Verification Summary ==="
echo ""
echo "XID Identifier: $(envelope xid id "$FETCHED_XID")"
echo "Nickname: BRadvoc8"
echo ""
echo "Verification Results:"
echo "  ✅ Signature: Valid (self-signed)"
echo "  ✅ dereferenceVia: Matches fetch URL"
echo "  ✅ Provenance: Valid genesis mark (version 0)"
echo ""
echo "Trust Assessment:"
echo "  • This XID is self-consistent"
echo "  • It claims this URL as its canonical location"
echo "  • It has a valid provenance chain"
echo ""
echo "  ⚠️  NOT YET VERIFIED:"
echo "  • That 'BRadvoc8' controls this GitHub account"
echo "  • That 'BRadvoc8' has any real-world skills"
echo "  • Who 'BRadvoc8' really is"

│ === Ben's Verification Summary ===
│
│ XID Identifier: c7e764b7...
│ Nickname: BRadvoc8
│
│ Verification Results:
│   ✅ Signature: Valid (self-signed)
│   ✅ dereferenceVia: Matches fetch URL
│   ✅ Provenance: Valid genesis mark (version 0)
│
│ Trust Assessment:
│   • This XID is self-consistent
│   • It claims this URL as its canonical location
│   • It has a valid provenance chain
│
│   ⚠️  NOT YET VERIFIED:
│   • That 'BRadvoc8' controls this GitHub account
│   • That 'BRadvoc8' has any real-world skills
│   • Who 'BRadvoc8' really is
```

---

### About the Trust Model

*If you're ready to move on, skip to "Updating Your XID". Otherwise, read on to understand what Ben can and cannot trust at this point.*

What can Ben trust? Three things are cryptographically verified: the XID is self-consistent (signature verifies), it has continuity (provenance chain is intact), and it claims its publication location (dereferenceVia matches fetch URL).

But two things remain assumed, not proven: that Amira actually controls the GitHub account where the XID is published, and that Amira is who she claims to be. This tutorial solved the freshness problem—Ben can always get the current version and detect tampering—but it didn't establish deeper trust.

Tutorial 03 addresses what's missing: attestations that connect BRadvoc8 to real-world systems. Amira will add her GitHub account and SSH signing key as verifiable claims that Ben can cross-verify in Tutorial 04.

> :brain: **Learn more**: The [Progressive Trust](../concepts/progressive-trust.md) concept doc explores the full trust hierarchy and how verification layers combine.

## Updating Your XID (Preview)

When Amira wants to make changes—add attestations, change nickname, whatever—she updates her XIDDoc, then advances the provenance mark:

```
UPDATED_XID=$(envelope xid provenance next \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$XID_WITH_CHANGES")
```

Then she exports the new public version and publishes it to the same URL. When Ben fetches it, he sees the same XID identifier (the identity persists), a higher sequence number (so he knows this is newer), and a valid provenance chain (proving the updates are legitimate, not forged).

## What You Accomplished

BRadvoc8 now has a stable publication URL, provenance tracking for freshness verification, and cryptographic integrity through self-signing. The freshness problem is solved: Ben can fetch current versions without waiting for Amira to send updates, verify he has the latest copy, and detect if someone gives him stale data.

## Appendix: Key Terminology

> **`dereferenceVia`** - A known predicate indicating where the canonical version of this XID can be fetched. Uses `URI` type for the object.
>
> **Self-Consistency** - An XID is self-consistent when its signature verifies against its own embedded public key. Proves the document wasn't tampered with after signing, but not that the claims inside are true.
>
> **Freshness** - The property of having the most current version of an XID, verified through provenance marks.
>
> **Provenance Chain** - The sequence of provenance marks showing the history of XID updates. Each mark links to the previous.
>
> **Sequence Number** - The position in the provenance chain (0 = genesis, 1 = first update, etc.).

## Exercises

Try these to solidify your understanding:

**Publishing exercises (Amira's perspective):**

- Publish your XID for real: create a GitHub repository, add the URL with `xid resolution add`, export the public version, and commit it.
- Add multiple `dereferenceVia` assertions pointing to different mirrors (e.g., GitHub and a personal domain).
- Practice advancing the provenance mark with `xid provenance next` and observe how the sequence numbers change.

**Verification exercises (Ben's perspective):**

- Download someone else's published XIDDoc and run the full verification workflow: signature, dereferenceVia match, and provenance check.
- Deliberately tamper with a copy (change a character) and verify that signature verification fails.
- Compare two versions of the same XID with different sequence numbers to see how freshness detection works.

## Example Script

A complete working script implementing this tutorial is available at `tests/02-making-xid-verifiable-TEST.sh`. Run it to see all steps in action:

```
bash tests/02-making-xid-verifiable-TEST.sh
```

This script tests both Amira's publication workflow and Ben's verification workflow.

## What's Next

**Tutorial 03: Offering Self-Attestation** adds verifiable claims. Amira will link her GitHub account and SSH signing key as attestations about her real-world activities.

**Tutorial 04: Cross-Verification** shows Ben's perspective. He'll verify Amira's attestations against external sources like GitHub's API and signed commits.

The key insight: this tutorial proves your XID is current. Tutorial 03 offers attestations, and Tutorial 04 shows how to verify them. Together, they build meaningful trust—enough for Ben to accept code contributions from BRadvoc8.

---

**Previous**: [Your First XID](01-your-first-xid.md) | **Next**: [Offering Self-Attestation](03-offering-self-attestation.md)
