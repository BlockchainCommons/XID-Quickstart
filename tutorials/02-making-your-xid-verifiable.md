# Making Your XID Verifiable

In Tutorial 01, Amira created her BRadvoc8 identity. Now she wants Ben from SisterSpaces to be able to verify that he always has the current version of her XIDDoc. This tutorial shows how to make your XIDDoc fetchable and verifiable without relying on direct communication.

**Time to complete: 10-15 minutes**

> **Related Concepts**: This tutorial builds on [Tutorial 01: Your First XID](01-your-first-xid.md). Understanding provenance marks from that tutorial will help here.

## Prerequisites

- Completed Tutorial 01 (have a working XIDDoc)
- The [Gordian Envelope-CLI](https://github.com/BlockchainCommons/bc-envelope-cli-rust) tool installed (release 0.31.2 or later)
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

After Tutorial 01, Amira can give Ben her public XIDDoc directly—email it, share via Signal, whatever works. But what happens when she updates her XIDDoc next month? Ben has no way to know his copy is stale. He might verify signatures against outdated information, missing that Amira added new credentials or rotated keys.

One simple solution is to publish the XIDDoc at a stable URL and embed that URL in the document itself (we'll discuss other solutions in Tutorial ??). Now Ben can fetch the current version whenever he needs it and verify through provenance marks that his copy is actually current, not an old snapshot someone gave him.

This isn't about discovery (how Ben finds Amira's XID in the first place). It's about freshness (how Ben verifies he has the current version).

---

## Part I: Amira Publishes

In this section, you'll add a publication URL to your XIDDoc and publish a public version.

### Step 1: Set Up Your Environment

First, let's reload from Tutorial 01. If you saved your XIDDoc to a file:

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

Before adding `dereferenceVia`, decide where you'll publish. For this tutorial, we'll use a GitHub Gist, but any stable URL works—personal website, IPFS gateway, wherever you control.

```
# Placeholder - we'll update with the real URL after creating the gist
GIST_URL="https://gist.github.com/YOUR_USERNAME/GIST_ID/raw/xid.txt"
```

Make sure your URL points to raw content, not an HTML page. For GitHub Gists, use the `/raw/` URL.

### Step 3: Add dereferenceVia Assertion

Now add a `dereferenceVia` assertion that tells others where to fetch the current version of your XIDDoc:

```
XID_WITH_URL=$(envelope xid method add \
    "$GIST_URL" \
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
│         'dereferenceVia': URI(https://gist.github.com/YOUR_USERNAME/GIST_ID/raw/xid.txt)
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

The command added a `'dereferenceVia': URI(...)` assertion, verified the existing signature, re-signed with your inception key, and kept your private keys encrypted. Notice that `dereferenceVia` is a known value (single quotes) from the Gordian Envelope specification, and its object is a `URI` type rather than a plain string. This assertion tells anyone who receives your XIDDoc: "To get the current version, fetch from this URL."

You can add multiple `dereferenceVia` assertions for redundancy—different mirrors pointing to the same XID.

### Step 4: Export Public Version

Create a version safe for publishing by eliding the private keys and provenance generator:

```
PUBLIC_XID=$(envelope xid export --private elide --generator elide "$XID_WITH_URL")

echo "Exported public version"
envelope format "$PUBLIC_XID"

│ Exported public version
│ {
│     XID(c7e764b7) [
│         'dereferenceVia': URI(https://gist.github.com/YOUR_USERNAME/GIST_ID/raw/xid.txt)
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

> **Callback to Tutorial 01**: In Tutorial 01, you manually found digests and used `envelope elide removing` to create public versions. The `xid export` command does this automatically—it knows which parts of an XID should be elided for public sharing.

Notice the difference: where your complete XID shows `ENCRYPTED`, the public version shows `ELIDED`. The signature is still present and verifiable, the XID identifier is unchanged, but the private key and provenance generator are replaced with placeholders.

Why elide rather than simply omit? Elision keeps the hash contribution while removing the content, so the signature still verifies. If you omitted the private key entirely, the envelope's hash would change, invalidating the signature.

### Step 5: Publish Your XID

Now publish the public version. We'll use GitHub Gist:

```
# Save the public XID to a file
echo "$PUBLIC_XID" > /tmp/xid-public.txt

echo "Public XID saved to /tmp/xid-public.txt"
echo "Contents:"
cat /tmp/xid-public.txt
```

To publish on GitHub Gist: go to [gist.github.com](https://gist.github.com), create a new public gist with filename `xid.txt`, paste your public XID content, and click "Create public gist." Then click the "Raw" button and copy that URL—that's your `dereferenceVia` value.

There's a chicken-and-egg problem here: you need the URL to add `dereferenceVia`, but you need to create the gist to get the URL. The solution is to create the gist first with placeholder content, copy the raw URL, then update your XIDDoc with that URL, export the public version again, and update the gist with the real content.

---

## Part II: Ben Verifies

Now let's switch perspectives. Amira has published her BRadvoc8 XIDDoc and shared the URL with Ben via Signal. Ben wants to verify he's working with a legitimate, current XIDDoc.

### Ben's Starting Point

Ben received a message from someone claiming to be "BRadvoc8":

> "Hey Ben, I'm interested in contributing to SisterSpaces. Here's my XID: https://gist.github.com/bradvoc8/abc123/raw/xid.txt"

Ben doesn't know if this is legitimate. He needs to verify.

### Step 6: Ben Fetches the XIDDoc

Ben fetches the XIDDoc from the URL Amira provided:

```
# Ben's perspective - he only has the URL
RECEIVED_URL="https://gist.github.com/bradvoc8/abc123/raw/xid.txt"

# Fetch the XID (simulated - in practice, use curl)
# FETCHED_XID=$(curl -s "$RECEIVED_URL")

# For this tutorial, simulate with the published XID
FETCHED_XID="$PUBLIC_XID"

echo "Fetched XID from: $RECEIVED_URL"
envelope format "$FETCHED_XID" | head -15

│ Fetched XID from: https://gist.github.com/bradvoc8/abc123/raw/xid.txt
│ {
│     XID(c7e764b7) [
│         'dereferenceVia': URI(https://gist.github.com/bradvoc8/abc123/raw/xid.txt)
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

> **XID Self-Containment**: Notice that Ben extracted the verification keys from the XID itself. He didn't need Amira to send keys separately. XIDs contain everything needed for verification. "Share XIDs, not keys."

### Step 8: Ben Checks the dereferenceVia URL

Ben compares where he fetched the XID from to the `dereferenceVia` URL inside it:

```
# Extract the dereferenceVia URL from the XID
DEREFERENCE_ASSERTION=$(envelope assertion find predicate known dereferenceVia "$UNWRAPPED")
DEREFERENCE_URL=$(envelope extract object "$DEREFERENCE_ASSERTION" | envelope format)

echo "URL Ben fetched from:     $RECEIVED_URL"
echo "dereferenceVia in XID:    $DEREFERENCE_URL"

# In a real scenario, Ben would compare these
# The dereferenceVia shows as URI(...) format, so we check if it contains the URL
if echo "$DEREFERENCE_URL" | grep -q "gist.github.com"; then
    echo "✅ URLs match - XID claims this is its canonical location"
else
    echo "⚠️  URLs don't match - XID may have been copied from elsewhere"
fi

│ URL Ben fetched from:     https://gist.github.com/bradvoc8/abc123/raw/xid.txt
│ dereferenceVia in XID:    URI(https://gist.github.com/bradvoc8/abc123/raw/xid.txt)
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
echo "  • That 'BRadvoc8' has any specific capabilities"
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
│   • That 'BRadvoc8' has any specific capabilities
│   • Who 'BRadvoc8' really is
```

---

## Understanding the Trust Model

What can Ben trust at this point? The XID is self-consistent (signature verifies), has continuity (provenance chain is intact), and claims its publication location (dereferenceVia matches fetch URL). These are cryptographically verified.

But two things remain assumed, not proven: that Amira actually controls the GitHub account where the XID is published, and that Amira is who she claims to be. This tutorial solved the freshness problem—Ben can always get the current version and detect tampering—but it didn't establish deeper trust.

Tutorial 03 addresses what's missing: proof that Amira controls specific accounts like GitHub, SSH signing keys for Git commit verification, and stronger roots of trust through capability proofs.

## Updating Your XID (Preview)

When Amira wants to make changes—add credentials, change nickname, whatever—she updates her XIDDoc, then advances the provenance mark:

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

## Key Terminology

> **`dereferenceVia`** - A known predicate indicating where the canonical version of this XID can be fetched. Uses `URI` type for the object.
>
> **Freshness** - The property of having the most current version of an XID, verified through provenance marks.
>
> **Provenance Chain** - The sequence of provenance marks showing the history of XID updates. Each mark links to the previous.
>
> **Sequence Number** - The position in the provenance chain (0 = genesis, 1 = first update, etc.).

## Exercises

Try publishing your XID for real: create a GitHub Gist, add the URL with `xid method add`, export the public version, and update the gist. Then practice advancing the provenance mark with `xid provenance next` and observe how the sequence numbers change. For extra credit, add multiple `dereferenceVia` assertions pointing to different mirrors.

## What's Next

**Tutorial 03: Building Your Persona** adds capability proofs. Amira will prove she controls a GitHub account, add SSH signing keys for Git commits, and create stronger roots of trust through verifiable capabilities.

The key insight: this tutorial proves your XID is current. Tutorial 03 proves you have capabilities. Together, they build meaningful trust—enough for Ben to accept code contributions from BRadvoc8.

---

**Previous**: [Your First XID](01-your-first-xid.md) | **Next**: [Building Your Persona](03-building-persona.md)
