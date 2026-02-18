# Making Your XID Verifiable

This tutorial demonstrates how to maintain a XID's freshness without direct communication through the use of a publication URL and provenance marks. It does so through the continuation of Amira's story. In Tutorial 01, Amira created her BRadvoc8 identity. Now she wants to publish it and for Ben from SisterSpaces to be able to verify that he always has the current version of her XIDDoc.

**Time to complete**: ~10-15 minutes
**Difficulty**: Beginner
**Builds on**: Tutorial 01

> :brain: **Related Concepts**: This tutorial introduces verification and freshness. To understand the underlying principles, see [Progressive Trust](../concepts/progressive-trust.md) for how trust builds incrementally, and [Data Minimization](../concepts/data-minimization.md) for controlling what you disclose when publishing.

## Prerequisites

- Completed [Tutorial 01](01-your-first-xid.md) (have a working XIDDoc)
- The [Gordian Envelope-CLI](https://github.com/BlockchainCommons/bc-envelope-cli-rust) tool (already installed in Tutorial 01)
- The [Provenance Mark CLI](https://github.com/BlockchainCommons/provenance-mark-cli-rust) tool (already installed in Tutorial 01)
- A GitHub account (for publishing, but can use any public URL)

## What You'll Learn

**Part I - Amira publishes:**
- How to add a `dereferenceVia` assertion pointing to where your XIDDoc can be fetched
- How to publish your XIDDoc

**Part II - Ben verifies:**
- How to check `dereferenceVia` matches the fetch URL
- What trust level this & signature checking establishes (and what it doesn't)

## Amira's Story: The Freshness Problem

After Tutorial 01, Amira can give Ben her public XIDDoc directly. She can email it, share it via Signal, or do whatever else works. But what happens when she updates her XIDDoc next month? Ben has no way to know his copy is stale. He might verify signatures against outdated information, not knowing that Amira added new attestations or rotated keys.

One simple solution is to publish the XIDDoc at a stable URL and embed that URL in the document itself. (We'll discuss other solutions in a future tutorial.) Now Ben can fetch the current version whenever he needs it and verify through the URL and/or provenance marks that his copy is actually current, not an old snapshot someone gave him.

This isn't about discovery (how Ben finds Amira's XID in the first place). It's about freshness (how Ben verifies he has the current version).

## Part I: Amira Publishes

You'll add a publication URL to your XIDDoc and publish a public version.

### Step 0: Verify Dependencies

Before you start, ensure that you have the required CLI tools from Tutorial 01:

```
envelope --version
provenance --version

│ bc-envelope-cli 0.34.1
| provenance-mark-cli 0.7.0
```

If either tool is not installed, see [Tutorial 01 Step 0](01-your-first-xid.md#step-0-setting-up-your-workspace) for installation instructions.

### Step 1: Load Your XID

To reload your XID, first be sure to recreate your environmental variables:
```
XID_NAME="BRadvoc8"
PASSWORD="Amira's strong password"
```
If you saved your XID to a file, you can now load it:
```
XID=$(cat xid-*/BRadvoc8-xid.envelope)
```
Else, recreate it for this tutorial:
```
XID=$(envelope generate keypairs --signing ed25519 | \
    envelope xid new \
    --private encrypt \
    --encrypt-password "$PASSWORD" \
    --nickname "$XID_NAME" \
    --generator encrypt \
    --sign inception)
echo "✅ Loaded XID: $XID_NAME"
```

Afterward, you can check that it loaded correctly with `envelope format`:
```
envelope format "$XID" | head -10

│ {
│     XID(5f1c3d9e) [
│         'key': PublicKeys(a9818011, SigningPublicKey(5f1c3d9e, Ed25519PublicKey(b2c16ea3)), EncapsulationPublicKey(96209c0f, X25519PublicKey(96209c0f))) [
│             {
│                 'privateKey': ENCRYPTED [
│                     'hasSecret': EncryptedKey(Argon2id)
│                 ]
│             } [
│                 'salt': Salt
│             ]
│ ...
```

### Step 2: Choose Your Publication URL

You now must decide where to publish Amira's XID.  For this tutorial, we'll use a GitHub repository, but any stable URL website or IPFS gateway will work, just be sure that it's something that you personally control, since one of the advantages of your XID is that it's self-sovereign (meaning that it's controlled by you).

```
PUBLISH_URL="https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt"
```

> :warning: **Raw Content Required**: Your URL must point to raw content, not an HTML page.  If verifiers fetch an HTML page instead of the actual XID data, verification will fail. For GitHub repositories, use the `/raw/` URL path for web access or the `raw.githubusercontent.com` site name for curl access (see below).

### Step 3: Add dereferenceVia Assertion

You now need to link your publication URL to your XID. This is done by adding a `dereferenceVia` URL, which says how to "resolve" the XID.
Passing the original `$XID` to the `xid resolution add` command will do this:

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
```
This command uses the following new arguments:

1. The `$PUBLISH_URL` is of course required by `xid resolution add`.
2. `--verify inception` says to verify that the signature of the original `$XID` was made with its inception key.
3. `--password "$PASSWORD"` decrypts the previously encrypted information with the `$PASSWORD`.

You want the new, updated XID to have the same protections as the original, so you also repeat the various encryption and signature commands as part of the creation for your updated XID:

1. `--private encrypt` to encrypt the private key.
2. `--generate encrypt` to encrypt the provenance mark generate.
3. `--encrypt-password` to use the `$PASSWORD` in future decryption.
4. `--sign` to sign the new document.

Note that you didn't have to repeat commands like `--nickname`. That's because the whole previous XID Document was read in. You just had to redo the encryption and signing at the end.

Whenever you make one or more updates to a XID in preparation for publication of a new edition, you should ask: "Has the previous version of the XID been published?" If the answer is "yes" then you should update the provenance mark, to take advantage of its ability to order editions of a XIDDoc (and so tell recipients which one is the most up to date). In this case, you never published the previous version of the XIDDoc, so there's no need to update. When this one is published it'll be the first (sequence 0) edition.

You can use `envelope format` to see what your updated XID looks like:
```
envelope format "$XID_WITH_URL"

│ Added dereferenceVia
│ {
│     XID(5f1c3d9e) [
│         'dereferenceVia': URI(https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt)
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

The metadata of the new XID Document should be identical to the original. The signature was verified then refreshed, while private keys and the provenance mark generator were re-encrypted. 

Notice that `dereferenceVia` is a known value (single quotes) from the Known Values registry, and its object is a `URI` type rather than a plain string. This assertion tells anyone who receives your XID Document: "To get the current version, fetch from this URL." You can add multiple `dereferenceVia` assertions for redundancy by running the command again with a different URL. For example, you might point to both a GitHub raw URL and a personal domain, so if one source becomes unavailable, verifiers can still fetch your current XID Document from the other.

### Step 4: Export Public View

You now want to elide the private keys in the XID, to create a view of this edition that is safe for publication. In Tutorial 01, you manually found digests and used `envelope elide removing` to create a public view. We used that demonstration to show how elision works. However, there's a simpler command that optionally elides the private keys and/or  the provenance mark generator: `xid export`. That's what you'll want to use most of the time (when you're not learning about elision!):

```
PUBLIC_XID=$(envelope xid export --private elide --generator elide "$XID_WITH_URL")

echo "✅ Exported public version"
envelope format "$PUBLIC_XID"

│ ✅ Exported public version
│ {
│     XID(5f1c3d9e) [
│         'dereferenceVia': URI(https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt)
│         'key': PublicKeys(a9818011, SigningPublicKey(5f1c3d9e, Ed25519PublicKey(b2c16ea3)), EncapsulationPublicKey(96209c0f, X25519PublicKey(96209c0f))) [
│             'allow': 'All'
│             'nickname': "BRadvoc8"
│             ELIDED
│         ]
│         'provenance': ProvenanceMark(1896ba49) [
│             ELIDED
│         ]
│     ]
│ } [
│     'signed': Signature(Ed25519)
│ ]
```

As usual, this removes the content you want to hide, but maintains the hashes, so that the root hash and the signature remain the same.

### Step 5: Publish Your XID

You should now save the public view to a file.

```
mkdir envelopes
echo "$PUBLIC_XID" > envelopes/BRadvoc8-xid-public-02.envelope

echo "✅ Public XID saved to envelopes/BRadvoc8-xid-public-02.envelope"
echo "Contents:"
cat envelopes/BRadvoc8-xid-public-02.envelope
```

To upload this file to GitHub, create a repository named after your XID (e.g., `BRadvoc8/BRadvoc8`), add a file named `xid.txt`, and commit your public XID content. The raw URL follows a predictable pattern, `https://github.com/USERNAME/REPO/raw/main/xid.txt`, which should be what you recorded in `dereferenceVia`.

Publish literally means "to make public", so this is (at last) the publication of your XID. You've locked down the content as shown in this XIDDoc as the first edition. If you make changes (as you do starting in Tutorial 03), at that point you will update the provenance mark before you republish, so that recipients can figure out which edition is the newest. 

Note that publication doesn't only mean uploading something to a public-facing website. Just emailing a XIDDoc to someone is publication, because bits are infinitely copyable: you have no idea how far that single emailed edition will spread.

Obviously, you should make a copy of your private XID informationt too, only for your own storage:

```
mkdir envelopes
echo "$XID_WITH_URL" > envelopes/BRadvoc8-xid-private-02.envelope

echo "✅ PRIVATE XID saved to envelopes/BRadvoc8-xid-private-02.envelope
echo "Contents:"
cat envelopes/BRadvoc8-xid-private-02.envelope
```

> :note: **STORING FOR THE TUTORIAL.** In the previous tutorial, we showed how a user would typically store files by using a `xid-20251117` directory. With this lesson we've completed the creation of our first published XID. To commemorate that, we've created a new [`envelopes`](envelopes) directory that is solely for the use of this tutorial. We'll save a copy at the end of each tutorial, so that you can always reload old envelopes for perusal, or to use in a future tutorial. 

## Ben's Story: A Perspective Shift

Though this is Amira's story, she is trying to join a larger ecosystem of socially conscious programmers and the organizations they support. That's where Ben comes into the story. He runs SisterSpaces, a womens' services nonprofit. Ben received a message from someone claiming to be "BRadvoc8":

> "Hey Ben, I'm interested in contributing to SisterSpaces. Here's my XID: https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt"

Ben doesn't know if this is legitimate. He needs to verify. How does he do so? How does he know he has the current version of Amira's XID, not a stale copy? The verification workflow answers these questions without requiring direct contact with Amira.

## Part II: Ben Verifies

Ben has been mailed the XID Document and will test it via a variety of means.

### Step 6: Ben Fetches the XIDDoc

First, Ben fetches the current version of the XID Document from the `dereferenceVia` found in the version that he was mailed.

He could just input the URL into his browser and then cut and paste the file, but the following instead allows him to retrieve the dereferenced XIDDoc using the command line.
```
RECEIVED_URL="https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt"
CURL_URL=`echo $RECEIVED_URL | sed 's/\/\/github.com\//\/\/raw.githubusercontent.com\//; s/\/raw\//\//'`
FETCHED_XID=$(curl -H 'Accept: application/vnd.github.v3.raw' $CURL_URL | head -1)
```

> :warning: **Variable URLs**: The `dereferenceVia` indicated that Ben should retrieve the current XIDDoc from `https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt`. That's a standard GitHub URL for retrieving raw files using a browser. However, it doesn't work with `curl`, which instead requires an equivalent URL. Replace the `github.com` site name with `raw.githubusercontent.com` and drop the `/raw/` directory to instead retrieve from the command line.

You may notice that the `FETCHED_URL` command only retrieves the first line of the dereference URL, with `head -1`. That is purposeful for this tutorial, but not general best practice, which would be to instead read the last line of the file, with `tail -1`. Here's the reason: a file can contain multiple copies of an envelope, each a UR stored on a seperate line. Optimally, these lines will be arranged in chronological order, with the oldest envelope at the top and the newest at the bottom. That's what we're depending on in this tutorial: that the first line of the file will contain the first edition of the envelope, which is the example we're discussing here. We'll be continuing to step down through the GitHub file for additional editions in future tutorials. 

We can depend on this ordering in this tutorial because we're preparing the files for use. You can't depend on it when you're dereferencing an arbitrary XID that's been sent to you, but that's fine. XIDs have provenance marks, and the provenance marks will tell you which version is the newest. That's their whole purpose!

Ben will of course want to review the XID that he retrieved:
```
envelope format "$FETCHED_XID" | head -15

│ ✅ Fetched XIDDoc from: https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt
│ {
│     XID(5f1c3d9e) [
│         'dereferenceVia': URI(https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt)
│         'key': PublicKeys(a9818011, SigningPublicKey(5f1c3d9e, Ed25519PublicKey(b2c16ea3)), EncapsulationPublicKey(96209c0f, X25519PublicKey(96209c0f))) [
│             'allow': 'All'
│             'nickname': "BRadvoc8"
│             ELIDED
│         ]
│         'provenance': ProvenanceMark(1896ba49) [
│             ELIDED
│         ]
│     ]
│ } [
│     'signed': Signature(Ed25519)
│ ]
```

Retrieving a XID in this way is a crucial step because anyone could pass around a XID Document, and more so, anyone could pass around a very old XID Document that has old, inaccurate information. By including a `dereferenceVia` that refers to a URL that she controls, Amira has ensured that if someone receives her XID Document, they should then go to the URL to pick up a current version, which Ben does.

Ben now suspects he has the current version of XIDDoc.

### Step 7: Ben Checks the dereferenceVia URL

Since Ben has dereferenced the XID that Amira mailed him, to access an up-to-date version of the document, he has the most up-to-date version, right? Not necessarily! It's possible that the URL is no longer Amira's primary publication location, and there's actually a newer version elsewhere! To verify this isn't the case, Ben should check the `dereferenceVia` one more time, looking at the new document that he downloaded. He does this by extracting the `dereferenceVia` from this fetched and unwrapped XID, and comparing it to the URL that he used to lookup the XID.

```
UNWRAPPED=$(envelope extract wrapped "$FETCHED_XID")
DEREFERENCE_ASSERTION=$(envelope assertion find predicate known dereferenceVia "$UNWRAPPED")
DEREFERENCE_URL=$(envelope extract object "$DEREFERENCE_ASSERTION" | envelope format | sed 's/.*URI(\(.*\))/\1/')

echo "URL Ben fetched from:     $RECEIVED_URL"
echo "dereferenceVia in XID:    $DEREFERENCE_URL"

if [ "$RECEIVED_URL" = "$DEREFERENCE_URL" ]; then
    echo "✅ URLs match - XID claims this is its canonical location"
else
    echo "⚠️  URLs don't match - XID may have been copied from elsewhere"
fi

│ URL Ben fetched from:     https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt
│ dereferenceVia in XID:    URI(https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt)
│ ✅ URLs match - XID claims this is its canonical location
```

If the URLs match, Ben is even more certain that he has the most up-to-date XIDDoc. If they don't, then Ben should look at the `dereferenceVia` in the new XIDDoc that he retrieved and follow it to the URL that _it_ points to, repeating steps 6-7 until he actually gets a XIDDoc that matches its own `dereferenceVia`. (Usually these additional steps wont' be required at all, but they should definitely be part of a verifier checklist.)

Barring some weird issue like a circular set of dereferences, or a dead URL, Ben should now have a XIDDoc that is the newest version. But can he trust it?

### Step 8: Ben Verifies the Signature & Provenance

Ben will now repeat the steps from [Tutorial 01](01-your-first-xid.md#step-3-verifying-a-xid), verifying the signature and the provenance mark.

```
UNWRAPPED=$(envelope extract wrapped "$FETCHED_XID")
KEY_ASSERTION=$(envelope assertion find predicate known key "$UNWRAPPED")
KEY_OBJECT=$(envelope extract object "$KEY_ASSERTION")
PUBLIC_KEYS=$(envelope extract ur "$KEY_OBJECT")

if envelope verify -v "$PUBLIC_KEYS" "$FETCHED_XID" >/dev/null 2>&1; then
    echo "✅ Signature verified - XID is self-consistent"
else
    echo "❌ Signature FAILED - XID may be tampered\!"
    exit 1
fi

PROVENANCE_MARK=$(envelope xid provenance get "$FETCHED_XID")

echo "Checking provenance mark..."
provenance validate "$PROVENANCE_MARK" && echo "✅ Provenance chain intact"

│ ✅ Signature verified - XID is self-consistent
| ✅ Provenance chain intact
```

We could also examine details of the provenance mark with `provenance validate --format json-pretty "$PROVENANCE_MARK"`, but since this is Amira's first edition, it'll look the same as it did in Tutorial 01. The more interesting test would come if Ben had multiple, different copies of the XIDDoc and needed to determine which was stale and which fresh, but that's a topic for a future Tutorial.

#### What If the XID Was Tampered with?

What happens if an attacker intercepts and modifies the XID before Ben receives it? The following change simulates tampering by removing the last character from the $FETCHED_XID variable. A more sophisticated attacker would use a UR playground to change the content of the envelope, but the results would be the same.

```
TAMPERED_XID=${FETCHED_XID::-1}
```

In either case, the verification would fail because any modification, even a single character, invalidates the signature: the cryptographic hash of the tampered document no longer matches what was signed.

```
if envelope verify -v "$PUBLIC_KEYS" "$TAMPERED_XID" >/dev/null 2>&1; then
    echo "✅ Signature verified"
else
    echo "❌ Signature FAILED - tampering detected\!"
fi

│ ❌ Signature FAILED - tampering detected!
```

This is why signature verification is an important check: it catches any tampering that occurred after Amira signed the document.

> :brain: **Learn more**: The [Signing and Verification](../concepts/signing-verification.md) concept doc explains how envelope signatures work and why elision preserves signature validity.

### Step 9: Ben Assesses What He Has Learned

Although Ben has run a few tests, he still has limited information about the BRadvoc8 identity. So what can he trust?

Three things have been cryptographically verified:

* The XID was signed by someone holding the private signing key referenced in the XID.
   * _This means that the XID is self-consistent_.
* The XID hasn't been tampered with since it was signed.
   * _This means that the XID is what the signer signed-off on (but not that the content is necessarily true)._
*  The provenance mark verifies, without any errors highlighting gaps.
   * _This means that the provenance chain is complete; to be precise, detailed data shows that the XID is a first edition._
 
One thing is very likely verified:

* The XID is the most up-to-date edition of the identifier.
   * _There still is the possibility that Amira made a newer XID without updating the `dereferenceVia` site, but Ben did enough due dilligence to demonstrate that it's unlikely that he has an out-of-date version of the XID._
 
But a few other things are just assumed, without proof:

* Amira has control of the GitHub account.
   * _Though Amira's XID being on the GitHub account is suggestive, more would need to be done to prove she owned it._
* Amira is who she says she is.
   * _A pseudonymous identity can never provide absolute proof of who someone is, but attestations and cross-verifications can offer increasingly strong evidence._
 
The next two tutorials will concentrate on showing how a XID can better support these assumptions.

> :brain: **Learn more**: The [Progressive Trust](../concepts/progressive-trust.md) concept doc explores the full trust hierarchy and how verification layers combine.

Ben can now summarize what he knows:

```
echo "=== Ben's Verification Summary ==="
echo ""
echo "XID Identifier: $(envelope xid id "$FETCHED_XID")"
echo "Nickname: BRadvoc8"
echo ""
echo "Verification Results:"
echo "  ✅ Signature: Valid (self-consistent XID, no tampering)"
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
│ XID Identifier: 5f1c3d9e...
│ Nickname: BRadvoc8
│
│ Verification Results:
│   ✅ Signature: Valid (self-consistent XID, no tampering)
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

## Summary: What You Accomplished

BRadvoc8 now has a stable publication URL, provenance tracking for edition verification, and cryptographic integrity through self-signing. The freshness problem is also solved: Ben can fetch current versions without waiting for Amira to send updates, verify that he has the latest copy, and detect if someone gives him stale data.

### Example Script

A complete working script implementing this tutorial is available at `tests/02-making-xid-verifiable-TEST.sh`. Run it to see all steps in action:

```
bash tests/02-making-xid-verifiable-TEST.sh
```

This script tests both Amira's publication workflow and Ben's verification workflow.

### Exercises

Try these to solidify your understanding:

**Publishing exercises (Amira's perspective):**

- Publish your XID for real: create a GitHub repository, add the URL with `xid resolution add`, export the public version, and commit it.
- Add multiple `dereferenceVia` assertions pointing to different mirrors (e.g., GitHub and a personal domain).

**Verification exercises (Ben's perspective):**

- Download someone else's published XIDDoc and run the full verification workflow: signature, dereferenceVia match, and provenance check.
- Deliberately tamper with a copy (change a character) and verify that signature verification fails.

## What's Next

**Tutorial 03: Offering Self-Attestation** adds verifiable claims. Amira will link her GitHub account and SSH signing key as attestations about her real-world activities.

**Tutorial 04: Cross-Verification** shows Ben's perspective. He'll verify Amira's attestations against external sources like GitHub's API and signed commits.

Together with this tutorial's proof that a XID is current, the next two additions will build meaningful trust: enough for Ben to accept code contributions from BRadvoc8.

[ **Next Tutorial:** [Offering Self-Attestation](03-creating-self-attestations.md) | **Previous Tutorial**: [Your First XID](01-your-first-xid.md) ]


## Appendix I: Key Terminology

> **`dereferenceVia`** - A known predicate indicating where the canonical version of this XID can be fetched. Uses `URI` type for the object.
>
> **Freshness** - The property of having the most current version of an XID, verified through publication URLs and provenance marks.
>
> **Provenance Chain** - The sequence of provenance marks showing the history of XID updates. Each mark links to the previous.
>
> **Self-Consistency** - An XID is self-consistent when its signature verifies against its own embedded public key. This proves the document wasn't tampered with after signing, but not that the claims inside are true.
>
> **Sequence Number** - The position in the provenance chain (0 = genesis, 1 = first update, etc.).
