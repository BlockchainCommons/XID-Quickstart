# 2.3: Managing Sensitive Claims with Elision

This section continues the topic of sharing sensitive data. Where the
previous section demonstrated committing without revealing, this shows
how to share sensitive credentials with specific trusted individuals
using recipient-specific encryption.

> **🧠 Related Concepts.** After completing this tutorial, explore
[Data
Minimization](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/concepts/data-minimization.md)
and [Progressive
Trust](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/concepts/progressive-trust.md)
to deepen your understanding.

## Objectives of this Section

After working through this section, a developer will be able to:

- Encrypt attestations for specific recipients.

Supporting objectives include the ability to:

- Undestand the difference between elision and encryption.
- Know when encryption is the right choice over commitment.

## Amira's Story: Some Secrets Can't Even Be Hinted At

DevReviewer now has two credentials for BRadvoc8: a specific PR for the Galaxy Project and more general information about audit experience. The last speaks to Amira's security experience, but DevReviewer wants something more. Amira can provide that: she designed the authentication system for CivilTrust, a human
rights documentation platform. It's exactly the kind of experience
that would prove her security credentials sufficiently for
DevReviewer. But there's a problem.

CivilTrust maintains a contributor list. If anyone connects BRadvoc8
to CivilTrust contributions, they could link the BRadvoc8 identity to Amira's real name! That could endanger Amira and her family back home.

The commit-reveal pattern from [§2.2](02_2_Managing_Claims_Elision.md)
won't work here. Even an elided commitment is a publication: it proves
she has *some* sensitive security credential. An adversary monitoring
her profile might investigate what that commitment hides. For
CivilTrust, Amira needs zero public trace.

The solution is encrypted sharing: encrypt the attestation so only
DevReviewer can read it. No public commitment, no hint of existence,
just a private message between two people who trust each other.

## The Possibilities of Protecting Sensitive Data
### Encryption vs. Elision

[§2.2](02_2_Managing_Claims_Elision.md) highlighted three options for
hiding sensitive data: omission, elision, and encryption. It then
demonstrated elision, while this section follows up with encryption.

Both techniques hide information, but they serve different purposes:

| Aspect | Elision (§2.2) | Encryption (§2.3) |
|--------|---------------|------------------|
| **Public trace** | Yes (elided digest visible) | No (completely hidden) |
| **Proves timing** | Yes (commitment exists) | No (no public record) |
| **Who can see** | No one (until revealed) | Specific recipients only |
| **Use case** | "Might need to prove later" | "Only this person should see" |

Use the **commit-reveal pattern** (§2.2) when you might need to prove
you had a credential at a specific time. The elided commitment is
public: it proves timing without revealing content.

Use **encryption** (§2.3) when even the existence of a credential is
sensitive. Amira's crypto audit experience could be committed publicly
(the category isn't dangerous). Her CivilTrust work can't: even
hinting she has human rights tech credentials could draw unwanted
attention.

## Part I: Setting Up for Encryption

Setting up requires you making sure you have your variables in order
and DevReviewer sharing a public key.

### Step 0: Verify Dependencies

As usual, check your `envelope-cli` version:
```
envelope --version

│ bc-envelope-cli 0.34.1
```

Then, reload your XID and out Attestation keys:
```
XID=$(cat envelopes/BRadvoc8-xid-private-2-01.envelope)
XID_ID=$(envelope xid id $XID)
ATTESTATION_PRVKEYS=$(cat envelopes/key-attestation-private-2-01.ur)
ATTESTATION_PUBKEYS=$(cat envelopes/key-attestation-public-2-01.ur)
```

### Step 1: Create Keys for Receiving

DevReviewer needs keys to receive encrypted data. They create a
keypair and share their public key with Amira:

```
# DevReviewer generates keypair for receiving encrypted content
DEVREVIEWER_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
DEVREVIEWER_PUBKEYS=$(envelope generate pubkeys "$DEVREVIEWER_PRVKEYS")

echo "✅ DevReviewer's public key ready to receive encrypted data"

│ ✅ DevReviewer's public key ready to receive encrypted data
```

In the real world, DevReviewer would share their public key through a
secure channel: perhaps in their own XID, or via direct message from
their earlier interactions in [§2.2](02_2_Managing_Claims_Elision.md).

## Part II: Creating the Sensitive Attestation

You can now create a new claim for Amira and encrypt it using
DevReviewer's public key.

### Step 2: Create the CivilTrust Claim

The claim you're creating for Amira would reveal her legal identity if
published. As usual, you must wrap and sign it after creation.

```
CIVILTRUST_CLAIM=$(envelope subject type string \
  "Designed the authentication system for CivilTrust human rights documentation platform (2024)")

CIVILTRUST_ATTESTATION=$(envelope assertion add pred-obj known isA known 'attestation' "$CIVILTRUST_CLAIM")
CIVILTRUST_ATTESTATION=$(envelope assertion add pred-obj known source ur $XID_ID "$CIVILTRUST_ATTESTATION")
CIVILTRUST_ATTESTATION=$(envelope assertion add pred-obj known target ur $XID_ID "$CIVILTRUST_ATTESTATION")
CIVILTRUST_ATTESTATION=$(envelope assertion add pred-obj known 'date' string `date -Iminutes` "$CIVILTRUST_ATTESTATION")
CIVILTRUST_ATTESTATION=$(envelope assertion add pred-obj string "privacyRisk" string "Links to legal identity via contributor list" "$CIVILTRUST_ATTESTATION")
CIVILTRUST_ATTESTATION_WRAPPED=$(envelope subject type wrapped $CIVILTRUST_ATTESTATION)
CIVILTRUST_ATTESTATION_SIGNED=$(envelope sign --signer "$ATTESTATION_PRVKEYS" "$CIVILTRUST_ATTESTATION_WRAPPED")

echo "Attestation (before encryption):"
envelope format "$CIVILTRUST_ATTESTATION_SIGNED"

| Attestation (before encryption):
| {
|     "Designed the authentication system for CivilTrust human rights documentation platform (2024)" [
|         'isA': 'attestation'
|         "privacyRisk": "Links to legal identity via contributor list"
|         'date': "2026-03-03T15:15-10:00"
|         'source': XID(5f1c3d9e)
|         'target': XID(5f1c3d9e)
|     ]
| } [
|     'signed': Signature(Ed25519)
| ]
```

The `privacyRisk` field documents why this claim is sensitive. It's a
reminder for Amira and a signal to DevReviewer about the trust she's
placing in them.

### Step 3: Encrypt for DevReviewer

Gordian Envelope includes a simple routine that will encrypt the
subject of an envelope: `envelope encrypt`. This can be done with any
envelope, including a XID. Using key pairs, you will typically encrypt
with someone public key, which will allow them to decrypt with their
private key.


```
CIVILTRUST_ATTESTATION_ENCRYPTED=$(envelope encrypt --recipient "$DEVREVIEWER_PUBKEYS" "$CIVILTRUST_ATTESTATION_SIGNED")

echo "✅ Encrypted attestation (only DevReviewer can decrypt):"
envelope format "$CIVILTRUST_ATTESTATION_ENCRYPTED"

| ✅ Encrypted attestation (only DevReviewer can decrypt):"
| ENCRYPTED [
|     'hasRecipient': SealedMessage
|     'signed': Signature(Ed25519)
| ]
```

Because the envelope was wrapped prior to signing, the subject is the
entire attestation, including the claim and metadata. This is usually
the desired response, but if you wanted to only encrypt the claim, you
would so prior to wrapping and signing.

The `hasRecipient: SealedMessage` indicates someone can decrypt this
envelope. It doesn't reveal *who*: that information is sealed inside
the encrypted recipient blob.

> 🧠 **Cryptographic Foundations.** Gordian Envelope's encryption is
done by default with ChaCha20-Poly1305. In this the symmetric key
for that encryption is then "sealed" with the recipient's public
key. In contrast, signing is by default done with Ed25519.

### Step 4: Review Your Work & Store It

You now have encrypted sharing: the ability to share sensitive
credentials with specific trusted individuals without any public
trace. DevReviewer can decrypt and verify Amira's CivilTrust claim,
but no one else can read the content or even know it exists.

#### Credential Approach Comparison

Combined with the public attestation in §2.1 and commit-reveal pattern
from §2.2, Amira has a complete toolkit for managing credentials of
various sensitivities.

| Credential | Approach | Why | Added In |
|------------|----------|-----|----------|
| Galaxy Project | 📢 Public attestation | Already public on GitHub | §2.1 |
| Crypto audit | ✂️  Commit elided | Valuable but rare skill | §2.2 |
| CivilTrust | 🔐 Encrypt for DevReviewer | Too dangerous for any public trace | §2.3 |

#### Store It

As usual, we're going to save everything for future reference.
```
echo $CIVILTRUST_ATTESTATION_SIGNED > envelopes/claim-2-03.envelope
echo $CIVILTRUST_ATTESTATION_ENCRYPTED > envelopes/claim-encrypted-2-03.envelope
echo $DEVREVIEWER_PUBKEYS > envelopes/key-devreviewer-public-2-03.ur
echo $DEVREVIEWER_PRVKEYS > envelopes/key-devreviewer-private-2-03.ur
```

## Part III: Receiving & Verifying an Encrypted Claim

You've done your work for Amira. Now the point of view shifts once
more to DevReviewer, who will unlock the XID they've been handed.

### Step 5: Decrypt the Envelope

```
CIVILTRUST_ATTESTATION_DECRYPTED=$(envelope decrypt --recipient "$DEVREVIEWER_PRVKEYS" "$CIVILTRUST_ATTESTATION_ENCRYPTED")

echo "DevReviewer sees after decryption:"
envelope format "$CIVILTRUST_ATTESTATION_DECRYPTED"

| {
|     "Designed the authentication system for CivilTrust human rights documentation platform (2024)" [
|         'isA': 'attestation'
|         "privacyRisk": "Links to legal identity via contributor list"
|         'date': "2026-03-03T15:15-10:00"
|         'source': XID(5f1c3d9e)
|         'target': XID(5f1c3d9e)
|     ]
| } [
|     'hasRecipient': SealedMessage
|     'signed': Signature(Ed25519)
| ]
```

DevReviewer can now read the full claim. They see that Amira designed
the authentication system for CivilTrust, which wassignificant security work on
a real platform.

### Step 6: Verify the Signature

Finally, DevReviewer can match the signature of the attestation against Amira's public key.

```
envelope verify -s --verifier "$ATTESTATION_PUBKEYS" "$CIVILTRUST_ATTESTATION_DECRYPTED"
echo "✅ No response means signature is valid"


│ ✅ No response means signature is valid
```

DevReviewer now has what they need: the claim itself (Amira designed
CivilTrust authentication), proof of authenticity (the signature
matches BRadvoc8's key), and an implicit trust signal (Amira shared
information that could harm her if misused).

That last point matters. By sharing this credential, Amira
demonstrated that she trusts DevReviewer enough to give them
information that could endanger her if misused. This builds their
relationship and progresses trust, which will eventually be sufficient
for DevReviewer to offer Amira a peer endorsement.

#### What If Someone Else Intercepts?

An adversary, Charlie, could try and decrypt Amira's message with his own keys:
```
CHARLIE_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
envelope decrypt --recipient "$CHARLIE_PRVKEYS" "$CIVILTRUST_ATTESTATION_ENCRYPTED" 2>&1 || true

│ Error: unknown recipient
```

But the decryption fails. Charlie can see an encrypted envelope exists
as well as limited metadata (that it's encrypted with a public key and
signed with a different key), but he can't read the actual claim text.

### Step 7: Assess Your Level of Trust

As usual, DevReviewer can determine a level of trust based on this
newest attestation.

| What DevReviewer Can Verify | What Remains Unproven |
|---------------------|----------------------|
| ✅ Claim made an encrypted claim | ❓ Claim is actually true |
| ✅ BRadvoc8 signed the claim | ❓ What else BRadvoc8 claims |
| ✅ Who BRadvoc8 might be | ❓ Who BRadvoc8 is |
 
Perversely, though this claim could show a higher level of trust
between BRadvoc8 and DevReviewer (because BRadvoc8 says they revealed
sensitive information), the actual trust level of the data may be
lower, because it wasn't something that BRadvoc8 committed to in
advance. The verification level for the claim also remains
intermediate: DevReviewer can look up the project, just like they looked up that Galaxy PR, but there isn't (yet) a specific link to the
BRadvoc8 account.

That problem has been lingering, and it'll be the reason for Amira to
finally add a bit more information to her BRadvoc8 XID, proof that she
controls the GitHub account she referenced in §1.3, but that'll be the
topic of the next chapter.

## Summary: From Elision to Encryption

Elision offered a way to commit to a fact and then later reveal
it. Encryption serves a very different use case, when you don't want
to publicly commit to a fact, but you do want to selectively reveal
it.

## Exercises

1. Create a sensitive attestation and encrypt it for a fictional recipient
2. Try encrypting for multiple recipients:
   ```
   envelope encrypt --recipient "$ALICE_PUBKEYS" --recipient "$BOB_PUBKEYS" "$SIGNED_CLAIM"
   ```
   Each recipient can decrypt independently.
3. Compare `envelope format` output for elided vs encrypted envelopes: what can an observer learn from each?

## What's Next

That closes out the discussion of self-attestations. These were all
claims that were important enough to tell people about, but either
small enough or private enough that we didn't want to include them in
the XID itself. But what about those claims that _should_ go in a XID?
[Chapter Three; Creating Edges](03_0_Edges.md) describes how to do so.

## Appendix I: Key Terminology

> **Encrypted Sharing**: Sharing secrets with specific trusted people using recipient-specific encryption (distinct from elision, which hides from everyone).
>
> **Sign-Then-Encrypt**: The practice of signing content before encrypting, so the recipient can verify the signature after decryption.
>
> **Trust Signal**: Implicit information conveyed by an action—sharing sensitive data signals trust in the recipient.

## Appendix II Common Questions

### Q: Can I encrypt for multiple recipients at once?

**A:** Yes. Use `--recipient` multiple times: `envelope encrypt
--recipient "$ALICE" --recipient "$BOB" "$CONTENT"`.  The content is
encrypted once with a symmetric key, and that symmetric key is sealed
for each recipient separately.  Each recipient can decrypt
independently with their own private key.

### Q: What if I lose track of who I encrypted something for?

**A:** The envelope shows `'hasRecipient': SealedMessage` for each
recipient, but doesn't reveal who they are. Keep your own records of
who received what. If you're encrypting for many recipients, consider
adding a (non-sensitive) manifest as a separate assertion.

### Q: Should I rewrap and encrypt the signature too?

**A:** It depends on your threat model. Basic encryption (shown in
this tutorial) hides almost everything because of the wrapping that
occurs prior to the signaing. But it does reveal the signature, and an
attacker could figure out the identity of the signer if they had their
public key.  visible. For maximum privacy, rewrap the entire envelope
after signing and prior to encrypting The trade-off is that recipients
lose the information about who signed the envelope.

### Q: Can DevReviewer prove to others that Amira sent this?

**A:** Not cryptographically: the signature proves Amira authored the
content, but DevReviewer can't prove where it came from or that it was
purposefully sent to them. For transferable proof, Amira would need
to sign a statement that includes DevReviewer's identity or use a
public commitment. This is by design: encrypted sharing is for private
trust, not public proof.
