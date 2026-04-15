# Tutorial 10: Multi-Device Identity

Your laptop gets stolen. With a single-key identity, the thief now controls your XID—they can sign as you, lock you out, destroy years of reputation. This tutorial shows how to prevent that by adding operational keys with limited permissions.

**Difficulty**: Intermediate
**Builds on**: [Tutorial 09 (Binding Agreements)](09-binding-agreements.md)

> **Related Concepts**: After completing this tutorial, explore [Key Management](../concepts/key-management.md) to understand the full key hierarchy model.

## Prerequisites

- Completed Tutorial 09 (Binding Agreements)
- The `envelope` CLI tool installed
- Understanding of XID key structure from Tutorial 01

## What You'll Learn

- Why single-key identity is risky for active work
- How to add operational keys with limited permissions
- How to set up multiple devices safely
- How to manage multiple GitHub signing keys
- How to rotate keys when changing devices

## Step 0: Setting Up Your Workspace

Create a working directory for this tutorial:

```
mkdir -p output
```

## Building on Tutorial 09

| Tutorial 09 | Tutorial 10 |
|-------------|-------------|
| Signed binding agreements | Put that identity to active work |
| Identity has legal weight | Protect it while using it |
| Formal commitments | Multi-device collaboration |

**The Bridge**: Amira signed the CLA in Tutorial 09 and is now officially contributing to Ben's SecureAuth Library. She needs to work from her laptop at home and a portable drive when traveling. How does she do this without putting her entire identity at risk?

> **Security Hardening Arc (T10-T12)**: This tutorial begins the security hardening arc. You built a working identity in T01-T09; now you'll protect it from real-world threats: device theft (T10), disaster (T11), and active compromise (T12).

---

## Amira's Challenge: Working Across Devices

Ben sends Amira access to the SecureAuth Library repository. Charlene helps her prepare:

> "You'll be working from different machines. Right now your XID has one key that does everything. If your laptop is compromised, an attacker gets full control of your identity—they could lock you out, revoke your keys, destroy your reputation. Let's fix that."

**The problem**: One key with all permissions = single point of failure.

**The solution**: Add operational keys that can sign but can't manage the identity itself.

---

## Part I: Understanding Key Permissions

### Step 1: Review Current State

```
# Create Amira's XID (simulating state from previous tutorials)
# Note: --generator include is required for provenance advancement later
XID=$(envelope generate keypairs --signing ed25519 | \
    envelope xid new --nickname "BRadvoc8" --generator include --sign inception)

UNWRAPPED_XID=$(envelope extract wrapped "$XID")
XID_ID=$(envelope xid id "$UNWRAPPED_XID")

# Store the inception private keys for later use (extracted from the signed XID)
INCEPTION_PRVKEYS=$(envelope extract wrapped "$XID" | envelope xid key all | head -1)

echo "Amira's XID: $XID_ID"

│ Amira's XID: c7e764b7
```

> :book: **Why --generator include?**
>
> The provenance generator allows creating successive versions of your XID. Without it, you can't advance provenance when rotating keys (Step 11). Always include the generator when creating XIDs you plan to update.

### Step 2: Check Current Key Permissions

```
envelope format "$UNWRAPPED_XID" | grep -A1 "allow"

│             'allow': 'All'
```

That `'All'` permission is the problem. This key can:

> :warning: **Single Point of Failure**
>
> A key with `'All'` permissions can do everything—sign, encrypt, add keys, revoke keys. If compromised, an attacker gains complete control of your identity.

| Permission | What It Allows | Risk If Compromised |
|------------|---------------|---------------------|
| `sign` | Create signatures | Attacker signs as you |
| `encrypt` | Decrypt messages | Attacker reads your messages |
| `auth` | Authenticate identity | Attacker impersonates you |
| `elect` | Add new keys | Attacker adds their own keys |
| `revoke` | Remove keys | Attacker locks you out |

**The insight**: Operational work only needs `sign`. Management operations (`elect`, `revoke`) should require a more protected key.

---

## Part II: Adding an Operational Key

You might think: "I'll just back up my key securely." But backups don't help if your key is actively compromised—the attacker has the same key you do. They can use it before you even know it's stolen. The solution isn't better backups; it's limiting what each key can do.

### Step 3: Generate a Laptop Key

```
# Generate key specifically for laptop use
LAPTOP_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
LAPTOP_PUBKEYS=$(envelope generate pubkeys "$LAPTOP_PRVKEYS")

echo "Generated laptop operational key"

│ Generated laptop operational key
```

### Step 4: Add Key with Limited Permissions

```
# Add to XID with sign-only permission
UPDATED_XID=$(envelope xid key add \
    --allow sign \
    --nickname "laptop-jan2026" \
    "$LAPTOP_PUBKEYS" "$UNWRAPPED_XID")

echo "Key permissions after adding laptop key:"
envelope format "$UPDATED_XID" | grep -B1 -A1 "allow"

│ Key permissions after adding laptop key:
│             'allow': 'All'
│             'nickname': "BRadvoc8"
│ --
│             'allow': 'Sign'
│             'nickname': "laptop-jan2026"
```

Now Amira has two keys:

- **BRadvoc8** (original): `'All'` permissions — can manage identity
- **laptop-jan2026**: `'Sign'` only — can sign, nothing else

> :book: **Operational Key**
>
> A key with limited permissions (typically sign-only) used for daily work. If compromised, the attacker can sign things but cannot take over the identity.

### Step 5: Test the Operational Key

The operational key should be able to sign:

```
# Sign something with the laptop key
TEST_CLAIM=$(envelope subject type string "Test signature from laptop key")
TEST_SIGNED=$(envelope sign --signer "$LAPTOP_PRVKEYS" "$TEST_CLAIM")

# Verify it
envelope verify --verifier "$LAPTOP_PUBKEYS" "$TEST_SIGNED" >/dev/null && echo "✅ Laptop key can sign"

│ ✅ Laptop key can sign
```

But it should NOT be able to authorize identity changes. Let's prove that constraint works:

```
# Generate a rogue key an attacker might try to add
ROGUE_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
ROGUE_PUBKEYS=$(envelope generate pubkeys "$ROGUE_PRVKEYS")

# The attacker CAN modify the XID structure (anyone can modify data)
TAMPERED_XID=$(envelope xid key add --allow sign --nickname "rogue-key" \
    "$ROGUE_PUBKEYS" "$UPDATED_XID")

# But they can only sign the modification with the laptop key
TAMPERED_SIGNED=$(envelope sign --signer "$LAPTOP_PRVKEYS" "$TAMPERED_XID")

# When Ben verifies, he checks: was this signed by a key with 'elect' permission?
# The laptop key only has 'sign' permission, so this modification is UNAUTHORIZED
echo "Tampered XID was signed, but by a key without 'elect' permission"
echo "Verifiers will reject this as an unauthorized identity change"

│ Tampered XID was signed, but by a key without 'elect' permission
│ Verifiers will reject this as an unauthorized identity change
```

This is the protection: an attacker with the laptop key can create modified XIDs, but they can't create *authorized* modifications. Anyone checking the signature will see it wasn't signed by a key with `elect` permission.

> :book: **Permission Enforcement**
>
> Permissions aren't enforced at modification time—anyone can create a modified envelope. They're enforced at verification time. Verifiers check: "Was this change signed by a key that had permission to make it?"

### What If Laptop Key Is Compromised?

| Scenario | With All-Permission Key | With Sign-Only Key |
|----------|------------------------|-------------------|
| Attacker signs things | Yes | Yes |
| Attacker adds their key | Yes | **No** |
| Attacker removes your keys | Yes | **No** |
| You can revoke attacker's access | Maybe (race condition) | **Yes** (you still have inception key) |
| Identity recovery | Difficult | Straightforward |

The operational key limits the blast radius of a compromise.

### Concrete Scenario: Amira's Laptop Is Stolen

Amira leaves her laptop at a coffee shop. Someone takes it.

**Without operational keys**: The thief extracts her all-permission key, adds their own key with `'All'` permissions, then removes Amira's key. By the time Amira realizes what happened, her identity belongs to someone else. Her endorsements from Charlene, her CLA signature, her reputation—all now controlled by a stranger.

**With operational keys**: The thief gets `laptop-jan2026`, which can only sign. They might sign some things before Amira notices, but they cannot add their own keys or remove hers. Amira uses her inception key (stored securely elsewhere) to revoke `laptop-jan2026` and add a new operational key. Her identity remains intact. The damage is contained to a few potentially fraudulent signatures that she can publicly disavow.

---

## Part III: Multiple Devices

### Step 6: Add a Portable Drive Key

Amira also needs to work while traveling, using a bootable portable drive:

```
# Generate key for portable drive
PORTABLE_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
PORTABLE_PUBKEYS=$(envelope generate pubkeys "$PORTABLE_PRVKEYS")

# Add to XID with sign-only permission
UPDATED_XID=$(envelope xid key add \
    --allow sign \
    --nickname "portable-jan2026" \
    "$PORTABLE_PUBKEYS" "$UPDATED_XID")

echo "Keys in XID:"
envelope xid key all "$UPDATED_XID" | wc -l

│ Keys in XID:
│ 3
```

### Step 7: Review Key Structure

```
envelope format "$UPDATED_XID" | grep -E "(nickname|allow)"

│             'allow': 'All'
│             'nickname': "BRadvoc8"
│             'allow': 'Sign'
│             'nickname': "laptop-jan2026"
│             'allow': 'Sign'
│             'nickname': "portable-jan2026"
```

**Amira's key structure now:**

| Key | Permissions | Location | Purpose |
|-----|-------------|----------|---------|
| BRadvoc8 | All | Laptop (for now) | Identity management |
| laptop-jan2026 | Sign | Laptop | Daily work at home |
| portable-jan2026 | Sign | Portable drive | Work while traveling |

---

## Part IV: GitHub Signing Keys

GitHub allows multiple SSH signing keys. Each device should have its own.

### Step 8: Generate SSH Signing Keys Per Device

```
# Generate SSH signing key for laptop
ssh-keygen -t ed25519 -C "BRadvoc8-laptop" -f output/laptop_signing_key -N ""

# Generate SSH signing key for portable drive
ssh-keygen -t ed25519 -C "BRadvoc8-portable" -f output/portable_signing_key -N ""

echo "Generated SSH signing keys for both devices"

│ Generating public/private ed25519 key pair.
│ Your identification has been saved in output/laptop_signing_key
│ Your public key has been saved in output/laptop_signing_key.pub
│ Generating public/private ed25519 key pair.
│ Your identification has been saved in output/portable_signing_key
│ Your public key has been saved in output/portable_signing_key.pub
│ Generated SSH signing keys for both devices
```

### Step 9: Add Both Keys to GitHub

In GitHub Settings → SSH and GPG keys → New SSH key:

1. Add `laptop_signing_key.pub` with title "BRadvoc8-laptop"
2. Add `portable_signing_key.pub` with title "BRadvoc8-portable"
3. Set both as "Signing Key" type

**Why separate keys**: If the portable drive is lost, revoke only that GitHub key. Laptop continues working unaffected.

### Step 10: Link SSH Keys to XID

This step connects your Git identity to your XID identity. Without it, GitHub signatures and XID signatures are two unrelated systems—anyone could claim "BRadvoc8" on GitHub without proving they control the XID.

```
# Create attestation linking SSH key to XID
SSH_ATTESTATION=$(envelope subject type string "I control the SSH signing key BRadvoc8-laptop")
SSH_ATTESTATION=$(envelope assertion add pred-obj string "sshPublicKey" string "$(cat output/laptop_signing_key.pub)" "$SSH_ATTESTATION")
SSH_ATTESTATION=$(envelope assertion add pred-obj string "purpose" string "Git commit signing on laptop" "$SSH_ATTESTATION")

# Sign with the corresponding XID operational key
SSH_ATTESTATION=$(envelope sign --signer "$LAPTOP_PRVKEYS" "$SSH_ATTESTATION")

echo "Linked SSH key to XID operational key"

│ Linked SSH key to XID operational key
```

This creates a verifiable chain: XID → operational key → SSH signing key → Git commits.

Now do the same for the portable key:

```
# Link portable SSH key to portable XID operational key
PORTABLE_SSH_ATTESTATION=$(envelope subject type string "I control the SSH signing key BRadvoc8-portable")
PORTABLE_SSH_ATTESTATION=$(envelope assertion add pred-obj string "sshPublicKey" string "$(cat output/portable_signing_key.pub)" "$PORTABLE_SSH_ATTESTATION")
PORTABLE_SSH_ATTESTATION=$(envelope assertion add pred-obj string "purpose" string "Git commit signing on portable drive" "$PORTABLE_SSH_ATTESTATION")
PORTABLE_SSH_ATTESTATION=$(envelope sign --signer "$PORTABLE_PRVKEYS" "$PORTABLE_SSH_ATTESTATION")

echo "Linked portable SSH key to XID operational key"

│ Linked portable SSH key to XID operational key
```

> :warning: **Match Keys to Keys**
>
> Each SSH key should be linked to its corresponding XID operational key. The laptop SSH key is signed by the laptop operational key. This way, revoking the XID operational key also invalidates its SSH attestation.

---

## Part V: Key Rotation

### Step 11: When Amira Gets a New Laptop

Devices change. Here's the rotation pattern:

```
# 1. Generate key for new laptop
NEW_LAPTOP_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
NEW_LAPTOP_PUBKEYS=$(envelope generate pubkeys "$NEW_LAPTOP_PRVKEYS")

# 2. Add new key (requires inception key with 'elect' permission)
ROTATED_XID=$(envelope xid key add \
    --allow sign \
    --nickname "laptop-feb2026" \
    "$NEW_LAPTOP_PUBKEYS" "$UPDATED_XID")

# 3. Verify new key works
TEST=$(envelope subject type string "Test")
TEST=$(envelope sign --signer "$NEW_LAPTOP_PRVKEYS" "$TEST")
envelope verify --verifier "$NEW_LAPTOP_PUBKEYS" "$TEST" >/dev/null && echo "✅ New key verified"

# 4. Remove old laptop key (requires inception key with 'elect' permission)
ROTATED_XID=$(envelope xid key remove "$LAPTOP_PUBKEYS" "$ROTATED_XID")

# 5. Verify old key is gone
envelope format "$ROTATED_XID" | grep "laptop-jan2026" || echo "✅ Old key removed"

# 6. Advance provenance to record this change
ROTATED_XID=$(envelope xid provenance next "$ROTATED_XID")

echo "Rotated laptop key (provenance advanced)"

│ ✅ New key verified
│ ✅ Old key removed
│ Rotated laptop key (provenance advanced)
```

> :book: **Key Rotation**
>
> Replacing an old key with a new one. Always follow the pattern: add new, verify, remove old, verify removal, advance provenance. Never remove before adding or you risk losing access.

**The pattern**: Add new → verify → remove old → verify removal → advance provenance. The provenance update signals to verifiers that this XID has changed.

### Step 12: Update GitHub Keys and SSH Attestation

When rotating keys, you also need to update the SSH signing key and its attestation:

```
# Generate new SSH signing key for the new laptop
ssh-keygen -t ed25519 -C "BRadvoc8-laptop-new" -f output/new_laptop_signing_key -N ""

# Create new attestation linking SSH key to the NEW XID operational key
NEW_SSH_ATTESTATION=$(envelope subject type string "I control the SSH signing key BRadvoc8-laptop-new")
NEW_SSH_ATTESTATION=$(envelope assertion add pred-obj string "sshPublicKey" string "$(cat output/new_laptop_signing_key.pub)" "$NEW_SSH_ATTESTATION")
NEW_SSH_ATTESTATION=$(envelope assertion add pred-obj string "purpose" string "Git commit signing on laptop" "$NEW_SSH_ATTESTATION")
NEW_SSH_ATTESTATION=$(envelope sign --signer "$NEW_LAPTOP_PRVKEYS" "$NEW_SSH_ATTESTATION")

echo "New SSH attestation created"
echo "Next: In GitHub, remove old laptop SSH key, add new_laptop_signing_key.pub"

│ Generating public/private ed25519 key pair.
│ Your identification has been saved in output/new_laptop_signing_key
│ New SSH attestation created
│ Next: In GitHub, remove old laptop SSH key, add new_laptop_signing_key.pub
```

The old SSH attestation (signed by `laptop-jan2026`) is now orphaned—the key that signed it has been revoked. This is correct: old attestations from revoked keys should no longer be trusted for new operations.

---

## Part VI: Verification and Wrap-Up

### Step 13: Ben Verifies the SSH Chain

When Ben reviews a commit signed by BRadvoc8, he can verify the complete chain:

```
# Ben has: the commit signature, Amira's public XID, and her SSH attestation

# 1. Verify the SSH attestation is signed by an operational key in the XID
echo "Verifying SSH attestation..."
envelope verify --verifier "$LAPTOP_PUBKEYS" "$SSH_ATTESTATION" >/dev/null && \
    echo "✅ SSH attestation signed by laptop operational key"

# 2. Check that the operational key is in Amira's XID with 'sign' permission
envelope format "$UPDATED_XID" | grep -A2 "laptop-jan2026" | grep -q "Sign" && \
    echo "✅ Laptop key has 'Sign' permission in XID"

# 3. The commit signature (verified by GitHub) matches the SSH key in the attestation
echo "✅ Chain verified: XID → operational key → SSH key → commit"

│ Verifying SSH attestation...
│ ✅ SSH attestation signed by laptop operational key
│ ✅ Laptop key has 'Sign' permission in XID
│ ✅ Chain verified: XID → operational key → SSH key → commit
```

This verification proves: the commit was signed by an SSH key that is attested to by an XID operational key that has signing permission. The identity chain is intact.

### Save Your Work

```
OUTPUT_DIR="output/xid-tutorial10-$(date +%Y%m%d%H%M%S)"
mkdir -p "$OUTPUT_DIR"

# Save updated XID
echo "$UPDATED_XID" > "$OUTPUT_DIR/BRadvoc8-xid-multidevice.envelope"

# Save operational keys (in practice, these stay on their respective devices)
echo "$LAPTOP_PRVKEYS" > "$OUTPUT_DIR/laptop-prvkeys.envelope"
echo "$PORTABLE_PRVKEYS" > "$OUTPUT_DIR/portable-prvkeys.envelope"

# Save SSH attestations (these prove the link between XID keys and SSH keys)
echo "$SSH_ATTESTATION" > "$OUTPUT_DIR/laptop-ssh-attestation.envelope"
echo "$PORTABLE_SSH_ATTESTATION" > "$OUTPUT_DIR/portable-ssh-attestation.envelope"

echo "Saved to $OUTPUT_DIR"
ls "$OUTPUT_DIR"

│ Saved to output/xid-tutorial10-20260123120000
│ BRadvoc8-xid-multidevice.envelope
│ laptop-prvkeys.envelope
│ laptop-ssh-attestation.envelope
│ portable-prvkeys.envelope
│ portable-ssh-attestation.envelope
```

> :warning: **Operational Keys Stay on Their Devices**
>
> In practice, you wouldn't save all operational keys in one place. The laptop key stays on the laptop, the portable key stays on the portable drive. Only the inception key (with full permissions) needs secure backup. The SSH attestations can be published—they're signed and contain no secrets.

### What Amira Has Now

**Multi-device setup**:

- Inception key with full permissions (still on laptop—we'll fix this in Tutorial 11)
- Laptop operational key (sign only)
- Portable drive operational key (sign only)
- Per-device GitHub signing keys

**Reduced risk**:

- Compromise of operational key ≠ identity takeover
- Can revoke individual device keys without affecting others
- Identity persists across device changes

### The Gap Charlene Notices

> "This is better—if your laptop is compromised, you don't lose everything. But your inception key is still on your laptop. If that's compromised, the attacker can add their own keys and lock you out. That key should never be on any computer."

---

## Common Questions

**Can I have multiple inception keys?**

No. Each XID has exactly one key with full permissions (the inception key). This is by design—multiple "master" keys would create ambiguity about who controls the identity. If you need backup access, Tutorial 11 shows how to use SSKR to shard the inception key across multiple locations.

**What if I lose my inception key?**

Without the inception key, you cannot add or remove keys from your XID. The identity becomes frozen—existing operational keys keep working, but you can't recover if they're compromised. This is why Tutorial 11 focuses on offline backup. Never keep your inception key only on a device that could be lost or stolen.

**How many operational keys is too many?**

It depends on your threat model. More keys means more flexibility but also more to track. A typical setup might have 2-4 operational keys (primary device, backup device, maybe a hardware token). If you're managing more than 5-6 operational keys, consider whether you really need that many active signing contexts.

**Do old signatures become invalid when I rotate keys?**

No. Signatures made with an old key remain valid—the signature proves the document was signed at a time when that key was authorized. Rotation only affects new signatures. If you want to invalidate old signatures (e.g., after a compromise), you need to publicly disavow them.

---

## Exercises

These exercises test your understanding of the permission model:

1. **Negative permission test**: Try to use an operational key to revoke another key. What happens? Why?

2. **Compromise simulation**: Revoke `laptop-jan2026` using the inception key. Then verify that documents signed with the old laptop key still validate (signatures are historical) but the key is no longer in the XID.

3. **Permission escalation**: Create a key with `sign` and `encrypt` permissions but not `elect`. What can this key do that a sign-only key cannot?

---

## Appendix: Key Terminology

> **Operational Key**: A key with limited permissions (typically sign-only) used for daily work. Compromise is contained.
>
> **Inception Key**: The original key created when the XID was established, typically with full permissions (elect, revoke). Should be highly protected. Also called the "private key base" in technical documentation.
>
> **Key Rotation**: Replacing an old key with a new one. Pattern: add new, verify, remove old.
>
> **Permission Scope**: The specific operations a key is allowed to perform (`sign`, `encrypt`, `elect`, `revoke`, etc.).

> :brain: **Learn more**
>
> The [Key Management](../concepts/key-management.md) concept doc explains the full key hierarchy model and permission system.

---

[Previous: Binding Agreements](09-binding-agreements.md) | [Next: Offline Inception Key](11-offline-inception-key.md)
