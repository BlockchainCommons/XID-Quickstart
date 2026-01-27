# Tutorial 07: Encrypted Sharing

Share sensitive credentials with specific trusted individuals using recipient-specific encryption. The previous tutorial showed how to commit without revealing—this tutorial shows how to share secrets with people you trust.

**Time to complete**: ~15-20 minutes
**Difficulty**: Intermediate
**Builds on**: Tutorials 01-06

> **Related Concepts**: After completing this tutorial, explore [Data Minimization](../concepts/data-minimization.md) and [Progressive Trust](../concepts/progressive-trust.md) to deepen your understanding.

## Prerequisites

- Completed Tutorial 05 (Fair Witness Attestations)
- Completed Tutorial 06 (Managing Sensitive Claims)
- The `envelope` CLI tool installed

## What You'll Learn

- How to encrypt attestations for specific recipients
- The difference between elision and encryption
- When encryption is the right choice over commitment

## Building on Tutorial 06

| Tutorial 06 | Tutorial 07 |
|-------------|-------------|
| Committed sensitive claims (elided) | Share secrets with specific trusted people |
| Proved timing without revealing content | Reveal actual content to recipients |
| DevReviewer verified crypto audit claim | DevReviewer receives CivilTrust credential |

**The Bridge**: In Tutorial 06, Amira committed her crypto audit experience and later revealed it to DevReviewer. That built trust. Now DevReviewer is evaluating Amira for a security collaboration and wants to see her most sensitive work. The commit-reveal pattern proves timing—but Amira's CivilTrust work is so sensitive she doesn't even want to commit it publicly. She needs to share it directly with DevReviewer and no one else.

---

## The Problem: Some Secrets Can't Even Be Hinted At

Amira designed the authentication system for CivilTrust, a human rights documentation platform. This is exactly the kind of experience that would prove her security credentials. But there's a problem.

CivilTrust maintains a contributor list. If anyone connects BRadvoc8 to CivilTrust contributions, they can look up the legal names of contributors. In certain jurisdictions, being identified as having worked on human rights technology could endanger Amira.

The commit-reveal pattern from Tutorial 06 won't work here. Even an elided commitment is a publication—it proves she has *some* sensitive security credential. An adversary monitoring her profile might investigate what that commitment hides. For CivilTrust, she needs zero public trace.

The solution is encrypted sharing: encrypt the attestation so only DevReviewer can read it. No public commitment, no hint of existence, just a private message between two people who trust each other.

---

## Part I: Setting Up for Encryption

### Step 0: Verify Dependencies

Ensure you have the required tools installed:

```
envelope --version

│ bc-envelope-cli 0.32.0
```

If not installed, see Tutorial 01 Step 0 for installation instructions.

### Step 1: Establish Identities

```
OUTPUT_DIR="output/xid-tutorial07-$(date +%Y%m%d%H%M%S)"
mkdir -p "$OUTPUT_DIR"

# Amira's XID with provenance tracking
XID=$(envelope generate keypairs --signing ed25519 | \
    envelope xid new --nickname "BRadvoc8" --generator include --sign inception)

UNWRAPPED_XID=$(envelope extract wrapped "$XID")
XID_ID=$(envelope xid id "$UNWRAPPED_XID")

# Generate separate attestation signing keys
ATTESTATION_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
ATTESTATION_PUBKEYS=$(envelope generate pubkeys "$ATTESTATION_PRVKEYS")

echo "Amira's XID: $XID_ID"

│ Amira's XID: c7e764b7
```

### Step 2: DevReviewer Creates Keys for Receiving

DevReviewer needs keys to receive encrypted data. They share their public key with Amira:

```
# DevReviewer generates keypair for receiving encrypted content
DEVREVIEWER_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
DEVREVIEWER_PUBKEYS=$(envelope generate pubkeys "$DEVREVIEWER_PRVKEYS")

echo "DevReviewer's public key ready to receive encrypted data"

│ DevReviewer's public key ready to receive encrypted data
```

In practice, DevReviewer would share their public key through a secure channel—perhaps in their own XIDDoc, or via direct message from their earlier interactions in Tutorial 06.

> :brain: **Key Exchange**: For real-world use, recipients publish their public keys in their XIDDoc. Amira would fetch DevReviewer's XID and extract the encryption key, just as Ben extracted keys for verification in Tutorial 04.

---

## Part II: Creating the Sensitive Attestation

### Step 3: Amira Creates Her CivilTrust Claim

This claim would reveal her legal identity if published:

```
CIVILTRUST_CLAIM=$(envelope subject type string \
  "I designed the authentication system for CivilTrust human rights documentation platform (2024)")

CIVILTRUST_ATTESTATION=$(envelope assertion add pred-obj known isA string "SelfAttestation" "$CIVILTRUST_CLAIM")
CIVILTRUST_ATTESTATION=$(envelope assertion add pred-obj string "attestedBy" string "$XID_ID" "$CIVILTRUST_ATTESTATION")
CIVILTRUST_ATTESTATION=$(envelope assertion add pred-obj string "attestedOn" date "2026-01-21T00:00:00Z" "$CIVILTRUST_ATTESTATION")
CIVILTRUST_ATTESTATION=$(envelope assertion add pred-obj string "privacyRisk" string "Links to legal identity via contributor list" "$CIVILTRUST_ATTESTATION")

# Sign first (proves authenticity)
CIVILTRUST_SIGNED=$(envelope sign --signer "$ATTESTATION_PRVKEYS" "$CIVILTRUST_ATTESTATION")

echo "Attestation (before encryption):"
envelope format "$CIVILTRUST_SIGNED"

│ {
│     "I designed the authentication system for CivilTrust human rights documentation platform (2024)" [
│         isA: "SelfAttestation"
│         "attestedBy": "c7e764b7"
│         "attestedOn": 2026-01-21T00:00:00Z
│         "privacyRisk": "Links to legal identity via contributor list"
│     ]
│ } [
│     'signed': Signature
│ ]
```

The `privacyRisk` field documents why this claim is sensitive—a reminder to herself and a signal to DevReviewer about the trust she's placing in them.

### Step 4: Encrypt for DevReviewer

```
CIVILTRUST_ENCRYPTED=$(envelope encrypt --recipient "$DEVREVIEWER_PUBKEYS" "$CIVILTRUST_SIGNED")

echo "Encrypted attestation (only DevReviewer can decrypt):"
envelope format "$CIVILTRUST_ENCRYPTED"

│ ENCRYPTED [
│     'isA': "SelfAttestation"
│     "attestedBy": "c7e764b7"
│     "attestedOn": 2026-01-21T00:00:00Z
│     "privacyRisk": "Links to legal identity via contributor list"
│     'hasRecipient': SealedMessage
│     'signed': Signature
│ ]
```

The subject (the actual claim text) is now `ENCRYPTED`, but notice the assertions are still visible. This is important: encryption hides the *content* but not the *structure*. Someone intercepting this can see it's a "SelfAttestation" from BRadvoc8 with a privacy risk note, but they can't read what the actual claim says.

> :warning: **Metadata Leakage**: Encryption hides content but not structure. An observer can see this is a "SelfAttestation" with a "privacyRisk" field—they just can't read the actual claim. For maximum privacy, encrypt the entire envelope including assertions.

The `hasRecipient: SealedMessage` indicates someone can decrypt this envelope. It doesn't reveal *who*—that information is sealed inside the encrypted recipient blob.

---

## Part III: DevReviewer Receives and Verifies

### Step 5: DevReviewer Decrypts

```
CIVILTRUST_DECRYPTED=$(envelope decrypt --recipient "$DEVREVIEWER_PRVKEYS" "$CIVILTRUST_ENCRYPTED")

echo "DevReviewer sees after decryption:"
envelope format "$CIVILTRUST_DECRYPTED"

│ {
│     "I designed the authentication system for CivilTrust human rights documentation platform (2024)" [
│         isA: "SelfAttestation"
│         "attestedBy": "c7e764b7"
│         "attestedOn": 2026-01-21T00:00:00Z
│         "privacyRisk": "Links to legal identity via contributor list"
│     ]
│ } [
│     'signed': Signature
│ ]
```

DevReviewer can now read the full claim. They see that Amira designed the authentication system for CivilTrust—significant security work on a real platform.

### Step 6: DevReviewer Verifies the Signature

```
envelope verify --verifier "$ATTESTATION_PUBKEYS" "$CIVILTRUST_DECRYPTED"

│ Signature valid
```

DevReviewer now has what they need: the claim itself (Amira designed CivilTrust authentication), proof of authenticity (the signature matches BRadvoc8's key), and an implicit trust signal—Amira shared information that could harm her if misused.

That last point matters. By sharing this credential, Amira demonstrated that she trusts DevReviewer enough to give them information that could endanger her if misused. This builds the relationship for the peer endorsement that comes next.

### What If Someone Else Intercepts?

```
# Charlie generates his own keys
CHARLIE_PRVKEYS=$(envelope generate prvkeys --signing ed25519)

# Charlie tries to decrypt
envelope decrypt --recipient "$CHARLIE_PRVKEYS" "$CIVILTRUST_ENCRYPTED" 2>&1 || true

│ Error: No matching recipient found
```

Decryption fails cleanly. Charlie can see an encrypted envelope exists and its metadata (that it's a "SelfAttestation" with a privacy risk), but can't read the actual claim text.

---

## Part IV: Elision vs Encryption

Both techniques hide information, but they serve different purposes:

| Aspect | Elision (T06) | Encryption (T07) |
|--------|---------------|------------------|
| **Public trace** | Yes (elided digest visible) | No (completely hidden) |
| **Proves timing** | Yes (commitment exists) | No (no public record) |
| **Who can see** | No one (until revealed) | Specific recipients only |
| **Use case** | "Might need to prove later" | "Only this person should see" |

### Choosing Between Them

Use the **commit-reveal pattern** (T06) when you might need to prove you had a credential at a specific time. The elided commitment is public—it proves timing without revealing content.

Use **encryption** (T07) when even the existence of a credential is sensitive. Amira's crypto audit experience could be committed publicly (the category isn't dangerous). Her CivilTrust work can't—even hinting she has human rights tech credentials could draw unwanted attention.

### Sign-Then-Encrypt

Amira signed her attestation *before* encrypting it. This order matters: signing first proves she authored the content, while encrypting second protects that content during transit.

> :book: **Sign-Then-Encrypt**: Always sign content before encrypting. The recipient can then verify authenticity after decryption. The reverse (encrypt-then-sign) only proves who sealed the box, not who created the contents.

> :brain: **Cryptographic foundations**: Gordian Envelope uses X25519 for key encapsulation and IETF ChaCha20-Poly1305 for symmetric encryption. See the [Envelope Encryption spec](https://developer.blockchaincommons.com/envelope/) for technical details.

---

## Part V: Wrap-Up

### Save Your Work

```
echo "$CIVILTRUST_ENCRYPTED" > "$OUTPUT_DIR/civiltrust-for-devreviewer.envelope"
echo "$XID" > "$OUTPUT_DIR/BRadvoc8-xid.envelope"
echo "$ATTESTATION_PRVKEYS" > "$OUTPUT_DIR/attestation-prvkeys.envelope"

echo "Saved to $OUTPUT_DIR"
ls "$OUTPUT_DIR"

│ Saved to output/xid-tutorial07-20260121120000
│ attestation-prvkeys.envelope
│ BRadvoc8-xid.envelope
│ civiltrust-for-devreviewer.envelope
```

### What You Built

You now have encrypted sharing: the ability to share sensitive credentials with specific trusted individuals without any public trace. DevReviewer can decrypt and verify Amira's CivilTrust claim, but no one else can read the content or even know it exists.

Combined with the commit-reveal pattern from Tutorial 06, Amira has a complete toolkit for managing sensitive credentials:

| Credential | Approach | Why |
|------------|----------|-----|
| Galaxy Project | Public attestation | Already public on GitHub |
| Crypto audit | Commit elided | Valuable but rare skill |
| CivilTrust | Encrypt for DevReviewer | Too dangerous for any public trace |

### What Comes Next

DevReviewer has now verified Amira's sensitive credentials. They've seen her crypto audit experience (revealed from commitment) and her CivilTrust work (decrypted). Combined with her public attestations, DevReviewer has a comprehensive picture of BRadvoc8's capabilities.

This is the foundation for the next step: DevReviewer can now vouch for Amira publicly. When peers endorse your work, claims transform into reputation.

---

## Appendix: Key Terminology

> **Encrypted Sharing**: Sharing secrets with specific trusted people using recipient-specific encryption (distinct from elision, which hides from everyone).
>
> **Sign-Then-Encrypt**: The practice of signing content before encrypting, so the recipient can verify the signature after decryption.
>
> **Trust Signal**: Implicit information conveyed by an action—sharing sensitive data signals trust in the recipient.

---

## Common Questions

### Q: Can I encrypt for multiple recipients at once?

**A:** Yes. Use `--recipient` multiple times: `envelope encrypt --recipient "$ALICE" --recipient "$BOB" "$CONTENT"`. Each recipient can decrypt independently with their own private key. The content is encrypted once with a symmetric key, and that symmetric key is sealed for each recipient separately.

### Q: What if I lose track of who I encrypted something for?

**A:** The envelope shows `'hasRecipient': SealedMessage` for each recipient, but doesn't reveal who they are. Keep your own records of who received what. If you're encrypting for many recipients, consider adding a (non-sensitive) manifest as a separate assertion.

### Q: Should I always encrypt assertions too, or just the subject?

**A:** It depends on your threat model. Basic encryption (shown in this tutorial) hides the subject but leaves assertion predicates visible. For maximum privacy, encrypt the entire envelope including assertions before adding recipient information. The trade-off is that recipients lose structural context.

### Q: Can DevReviewer prove to others that Amira sent this?

**A:** Not cryptographically—the signature proves Amira authored the content, but DevReviewer can't prove they didn't forge the envelope. For transferable proof, Amira would need to sign a statement that includes DevReviewer's identity or use a public commitment. This is by design: encrypted sharing is for private trust, not public proof.

---

## Exercises

1. Create a sensitive attestation and encrypt it for a fictional recipient
2. Try encrypting for multiple recipients:
   ```
   envelope encrypt --recipient "$ALICE_PUBKEYS" --recipient "$BOB_PUBKEYS" "$SIGNED_CLAIM"
   ```
   Each recipient can decrypt independently.
3. Compare `envelope format` output for elided vs encrypted envelopes—what can an observer learn from each?

---

**Previous**: [Managing Sensitive Claims](06-managing-sensitive-claims.md) | **Next**: [Peer Endorsements](08-peer-endorsements.md)
