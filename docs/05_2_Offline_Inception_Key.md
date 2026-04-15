# Tutorial 11: Offline Inception Key

Your house burns down. Your laptop, your backup drive, your phone—all gone. If your inception key was only on those devices, your identity is gone too. No one can help you recover it. This tutorial shows how to prevent that catastrophe using SSKR (Sharded Secret Key Reconstruction).

**Difficulty**: Intermediate
**Builds on**: [Tutorial 10 (Multi-Device Identity)](10-multi-device-identity.md)

> **Related Concepts**: After completing this tutorial, explore [Key Management](../concepts/key-management.md) for the full key hierarchy model.

## Prerequisites

- Completed Tutorial 10 (Multi-Device Identity)
- The `envelope` CLI tool installed
- Understanding of operational vs inception keys from Tutorial 10

## What You'll Learn

- Why inception keys need special protection
- How to create SSKR backup shares
- How to distribute shares safely
- How to test recovery before going offline
- How to take your inception key offline

## Step 0: Setting Up Your Workspace

Create a working directory for this tutorial:

```
mkdir -p output
```

## Building on Tutorial 10

| Tutorial 10 | Tutorial 11 |
|-------------|-------------|
| Added operational keys | Protect the inception key |
| Multiple devices working | Inception key goes offline |
| Compromise contained to device | Inception key survives disasters |

**The Bridge**: At the end of Tutorial 10, Charlene noticed a gap: Amira's operational keys limit compromise damage, but her inception key is still on her laptop. "That key should never be on any computer," Charlene warned. This tutorial addresses that gap—taking the inception key offline while keeping it recoverable.

---

## Part I: Key Hierarchy Concept

### Why Inception Keys Are Different

Not all keys are equal. Understanding the hierarchy is essential:

| Key Type | Permissions | Risk If Compromised | Should Be |
|----------|-------------|---------------------|-----------|
| Inception | elect, revoke, all | Identity takeover | Offline |
| Operational | sign only | Attacker can sign | On devices |
| Per-service | varies | Service-specific damage | Service-controlled |

**The principle**: The key that controls your identity should have the minimum possible exposure.

> :book: **Inception Key**
>
> The original key created when your XID was established. It has full permissions (`elect`, `revoke`) and controls who can manage your identity. Also called the "private key base" in technical documentation.

### Step 1: Review Current State

```
# Create Amira's XID with inception key and operational keys
XID=$(envelope generate keypairs --signing ed25519 | \
    envelope xid new --nickname "BRadvoc8" --generator include --sign inception)

UNWRAPPED_XID=$(envelope extract wrapped "$XID")
XID_ID=$(envelope xid id "$UNWRAPPED_XID")

# Add an operational key
LAPTOP_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
LAPTOP_PUBKEYS=$(envelope generate pubkeys "$LAPTOP_PRVKEYS")

UPDATED_XID=$(envelope xid key add \
    --allow sign \
    --nickname "laptop-2026" \
    "$LAPTOP_PUBKEYS" "$UNWRAPPED_XID")

echo "XID: $XID_ID"
echo "Inception key: 'All' permissions (currently on device)"
echo "Laptop key: 'Sign' only"

│ XID: c7e764b7
│ Inception key: 'All' permissions (currently on device)
│ Laptop key: 'Sign' only
```

Right now, the inception key exists in two places:

1. Inside the XID envelope (encrypted with password)
2. Potentially in memory while Amira is using it

If her laptop is compromised while the XID is loaded, an attacker could extract the inception key. And if her laptop is destroyed, the inception key is gone forever.

> :warning: **Two Threats, One Solution**
>
> Your inception key faces two threats: theft (someone copies it) and loss (it's destroyed). SSKR solves both—shares distributed across locations survive theft of any single location AND destruction of any single location.

---

## Part II: SSKR Backup

You might think: "I'll just make copies of my inception key and store them in different places." But copies create copies of the risk—if any copy is stolen, your identity is compromised. SSKR is different: each share alone is useless.

### What Is SSKR?

SSKR (Sharded Secret Key Reconstruction) splits a secret into multiple shares using Shamir's Secret Sharing. Key properties:

- Any single share reveals nothing about the original
- A threshold number of shares reconstructs the original
- Common schemes: 2-of-3, 3-of-5, 2-of-2

> :book: **Threshold Scheme**
>
> A "2-of-3" scheme means you create 3 shares and need any 2 to recover. You can lose 1 share and still recover. An attacker who steals 1 share learns nothing.

### Step 2: Create Backup Shares

```
# Split the XID into 2-of-3 shares
SHARES=$(envelope sskr split --group "2-of-3" "$XID")

# Parse into individual shares (space-separated output)
SHARE1=$(echo "$SHARES" | awk '{print $1}')
SHARE2=$(echo "$SHARES" | awk '{print $2}')
SHARE3=$(echo "$SHARES" | awk '{print $3}')

echo "Created 3 shares (any 2 can recover):"
echo "  Share 1: ${SHARE1:0:50}..."
echo "  Share 2: ${SHARE2:0:50}..."
echo "  Share 3: ${SHARE3:0:50}..."

│ Created 3 shares (any 2 can recover):
│   Share 1: ur:envelope/lftpsplftpsotansgshdcxuestrkbzce...
│   Share 2: ur:envelope/lftpsplftpsotansgshdcxidolotkpve...
│   Share 3: ur:envelope/lftpsplftpsotansgshdcxjnsapyjlbt...
```

Each share is a complete envelope containing a fragment of the secret. The threshold (2-of-3) means:

- Any 2 shares can reconstruct the original
- 1 share alone reveals nothing
- Losing 1 share still allows recovery

### Step 3: Prove One Share Is Useless

Before trusting SSKR, let's prove that a single share really reveals nothing:

```
# Try to recover with only one share (should fail)
envelope sskr join "$SHARE1" 2>&1 || echo "❌ Cannot recover with 1 share (as expected)"

│ ❌ Cannot recover with 1 share (as expected)
```

This is the key security property: an attacker who steals one share from Charlene's house learns nothing about your inception key.

### Step 4: Test Recovery Before Distribution

> :warning: **Test Before You Trust**
>
> Always test recovery before distributing shares or deleting the original. If something went wrong during splitting, you want to know now—not when your house burns down.

```
# Test recovery with shares 1 and 2
RECOVERED=$(envelope sskr join "$SHARE1" "$SHARE2")

# Verify it matches the original
ORIGINAL_DIGEST=$(envelope digest "$XID")
RECOVERED_DIGEST=$(envelope digest "$RECOVERED")

if [ "$ORIGINAL_DIGEST" = "$RECOVERED_DIGEST" ]; then
    echo "✅ Recovery test passed (shares 1+2)"
else
    echo "❌ Recovery failed - DO NOT proceed"
    exit 1
fi

# Test other combinations
RECOVERED_23=$(envelope sskr join "$SHARE2" "$SHARE3")
RECOVERED_13=$(envelope sskr join "$SHARE1" "$SHARE3")

echo "✅ All share combinations verified"

│ ✅ Recovery test passed (shares 1+2)
│ ✅ All share combinations verified
```

---

## Part III: Distributing Shares

### Step 5: Plan Share Distribution

Amira distributes her shares across different contexts:

| Share | Location | Rationale |
|-------|----------|-----------|
| Share 1 | Safety deposit box | Secure, requires physical access |
| Share 2 | Charlene (trusted friend) | Geographic distribution, in-person recovery |
| Share 3 | Encrypted cloud backup | Accessible remotely if needed |

**Why this distribution**:

- No single location compromise reveals the key
- Charlene can help with in-person recovery
- Geographic distribution protects against local disasters
- 2-of-3 means losing one share is survivable

### Step 6: Save Shares

```
OUTPUT_DIR="output/xid-tutorial11-$(date +%Y%m%d%H%M%S)"
mkdir -p "$OUTPUT_DIR"

# Save shares (in practice, distribute to different locations)
echo "$SHARE1" > "$OUTPUT_DIR/share1-safety-deposit.txt"
echo "$SHARE2" > "$OUTPUT_DIR/share2-charlene.txt"
echo "$SHARE3" > "$OUTPUT_DIR/share3-cloud-encrypted.txt"

echo "Shares saved to $OUTPUT_DIR"
echo "In practice:"
echo "  - Print share1, store in safety deposit box"
echo "  - Give share2 to Charlene in person"
echo "  - Encrypt share3, upload to cloud storage"

│ Shares saved to output/xid-tutorial11-20260123120000
│ In practice:
│   - Print share1, store in safety deposit box
│   - Give share2 to Charlene in person
│   - Encrypt share3, upload to cloud storage
```

> :warning: **Defense in Depth**
>
> Even though each share alone reveals nothing, encrypt share3 before uploading to cloud storage. If SSKR ever had a vulnerability, your encrypted share would still be protected.

---

## Part IV: Going Offline

### Step 7: Verify Operational Keys Work

Before taking the inception key offline, confirm operational keys work:

```
# Sign something with the laptop operational key
TEST=$(envelope subject type string "Test from operational key")
TEST_SIGNED=$(envelope sign --signer "$LAPTOP_PRVKEYS" "$TEST")

envelope verify --verifier "$LAPTOP_PUBKEYS" "$TEST_SIGNED" >/dev/null && echo "✅ Operational key works for signing"

│ ✅ Operational key works for signing
```

### Step 8: Delete Inception Key from Device

> :warning: **Point of No Return**
>
> Once you delete the inception key from your device, it exists only in distributed SSKR shares. Make absolutely sure you've tested recovery and distributed shares before proceeding.

```
# In practice, you would:
# 1. Securely delete the XID file containing the inception key
# 2. Clear any backups that contain it
# 3. The inception key now exists only in SSKR shares

echo "Inception key deletion steps:"
echo "  1. rm -P \$HOME/.xid/BRadvoc8-inception.envelope  # Secure delete"
echo "  2. Clear from any backup systems"
echo "  3. Inception key now exists only in distributed shares"

# For this tutorial, we simulate by clearing the variable
unset XID
echo "✅ Inception key removed from device (simulated)"

│ Inception key deletion steps:
│   1. rm -P $HOME/.xid/BRadvoc8-inception.envelope  # Secure delete
│   2. Clear from any backup systems
│   3. Inception key now exists only in distributed shares
│ ✅ Inception key removed from device (simulated)
```

### What Amira Can Now Do

| Operation | Can Do? | How |
|-----------|---------|-----|
| Sign attestations | Yes | Laptop operational key |
| Sign endorsements | Yes | Laptop operational key |
| Encrypt messages | Yes | If operational key has encrypt permission |
| Add new device | No | Needs inception key reconstruction |
| Revoke compromised key | No | Needs inception key reconstruction |
| Rotate keys | No | Needs inception key reconstruction |

**Most daily operations work without the inception key.** Identity management requires reconstruction.

---

## Part V: Reconstruction (When Needed)

### Step 9: Reconstruct Inception Key

When Amira needs to add a new device or revoke a key:

```
# Amira retrieves share1 from safety deposit box
# Amira contacts Charlene for share2
# (She doesn't need share3)

# Reconstruct the inception key
RECONSTRUCTED=$(envelope sskr join "$SHARE1" "$SHARE2")

echo "Inception key reconstructed for identity management"
envelope format "$RECONSTRUCTED" | head -5

│ Inception key reconstructed for identity management
│ {
│     XID(c7e764b7) [
│         'key': PublicKeys [...]
│         ...
```

### Step 10: Perform Management Operation

```
# Example: Add a key for a new device
NEW_DEVICE_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
NEW_DEVICE_PUBKEYS=$(envelope generate pubkeys "$NEW_DEVICE_PRVKEYS")

RECONSTRUCTED_UNWRAPPED=$(envelope extract wrapped "$RECONSTRUCTED")
UPDATED=$(envelope xid key add \
    --allow sign \
    --nickname "new-device-2026" \
    "$NEW_DEVICE_PUBKEYS" "$RECONSTRUCTED_UNWRAPPED")

# Advance provenance to record this change
UPDATED=$(envelope xid provenance next "$UPDATED")

echo "✅ New device key added"

│ ✅ New device key added
```

### Step 11: Re-split and Go Offline Again

After any management operation, re-split and go offline:

```
# Re-wrap and sign the updated XID with inception key
# (The inception key is inside RECONSTRUCTED, accessed via --sign inception)
UPDATED_XID=$(envelope sign --signer "$RECONSTRUCTED" "$UPDATED")

# Create new SSKR shares
NEW_SHARES=$(envelope sskr split --group "2-of-3" "$UPDATED_XID")
NEW_SHARE1=$(echo "$NEW_SHARES" | awk '{print $1}')
NEW_SHARE2=$(echo "$NEW_SHARES" | awk '{print $2}')
NEW_SHARE3=$(echo "$NEW_SHARES" | awk '{print $3}')

# Redistribute shares
echo "New shares created - redistribute to:"
echo "  - Safety deposit box (replace old share1)"
echo "  - Charlene (replace old share2)"
echo "  - Cloud backup (replace old share3)"

# Delete reconstructed inception key from device
unset RECONSTRUCTED UPDATED_XID
echo "✅ Inception key offline again"

│ New shares created - redistribute to:
│   - Safety deposit box (replace old share1)
│   - Charlene (replace old share2)
│   - Cloud backup (replace old share3)
│ ✅ Inception key offline again
```

> :warning: **Replace Old Shares**
>
> After updating your XID, the old shares reconstruct the old version. Replace all distributed shares with the new ones, or you'll reconstruct outdated information.

---

## Part VI: Wrap-Up

### Save Your Work

```
# Save operational keys (these stay on devices)
echo "$LAPTOP_PRVKEYS" > "$OUTPUT_DIR/laptop-operational-key.envelope"

echo "Saved to $OUTPUT_DIR"
ls "$OUTPUT_DIR"

│ Saved to output/xid-tutorial11-20260123120000
│ laptop-operational-key.envelope
│ share1-safety-deposit.txt
│ share2-charlene.txt
│ share3-cloud-encrypted.txt
```

### What Amira Has Now

**Key hierarchy secured**:

- Inception key: Offline, split into 2-of-3 SSKR shares
- Operational keys: On devices, sign-only permissions
- Recovery path: Charlene + safety deposit (or any 2 shares)

**The security model**: Even if Amira's laptop is completely compromised, the attacker:

- Can sign things with operational key ✓
- Cannot add their own keys ✗
- Cannot lock Amira out ✗
- Cannot access SSKR shares ✗

Amira retains control because her inception key was never on the compromised device.

### The Scenario Charlene Celebrates

> "If someone compromises your laptop now, they get your operational key. They can sign things as you. But they can't lock you out, they can't add their keys, and they can't stop you from revoking their access. Your identity survives. And if your house burns down, you call me, we get your share from the bank, and you're back in business."

---

## Common Questions

**Why not just encrypt the inception key and store copies?**

Copies create copies of the risk. If you store encrypted copies in three places and any one is breached (and the attacker cracks the encryption), your identity is compromised. With SSKR, breaching one location reveals nothing—mathematically nothing, not "hard to decrypt" nothing.

**What if Charlene loses her share?**

With 2-of-3, you can still recover using shares 1 and 3 (safety deposit + cloud). You should then create new shares and give Charlene a replacement. The old shares are now useless since you've re-split.

**What if I need to revoke a key while traveling?**

This is the tradeoff of offline inception keys: emergency management requires physical access to shares. If you travel frequently, consider keeping one share in a location you can access remotely (like an encrypted cloud backup) while ensuring the combination still requires physical presence for at least one share.

**Can I use 3-of-5 instead of 2-of-3?**

Yes. 3-of-5 is more resilient (can lose 2 shares) but requires coordinating more locations. Choose based on your threat model: how likely is loss vs. how likely is theft? More shares protect against loss; higher thresholds protect against theft.

---

## Exercises

These exercises test your understanding of SSKR security properties:

1. **Threshold exploration**: Create a 3-of-5 scheme. Verify that 2 shares fail to recover but any 3 succeed. How many combinations can recover?

2. **Distribution planning**: Design a share distribution strategy for your own life. Consider: trusted people, geographic diversity, accessibility during emergencies, and what happens if relationships change.

3. **Full lifecycle**: Practice the complete cycle: split → distribute → reconstruct → add a new key → re-split → redistribute. Time yourself—this is your "identity recovery time."

---

## Appendix: Key Terminology

> **Key Hierarchy**: The structure of keys with different permission levels—inception keys control the identity, operational keys perform daily tasks.
>
> **SSKR**: Sharded Secret Key Reconstruction—splitting a secret into shares where a threshold can reconstruct it.
>
> **Threshold Scheme**: The number of shares required for reconstruction (e.g., 2-of-3 means any 2 of 3 shares can recover the secret).
>
> **Offline Inception Key**: An inception key that exists only in distributed SSKR shares, never on an active computer.

> :brain: **Learn more**
>
> The [SSKR specification](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2020-011-sskr.md) explains the cryptographic details of Shamir's Secret Sharing and how SSKR extends it.

---

## What If Compromise Happens?

Charlene's celebration assumes Amira detects compromise and responds in time. But what if an attacker actually uses the stolen operational key? Can Amira really recover?

Tutorial 12 proves this setup works under fire—walking through detection, revocation, and recovery when compromise actually occurs.

---

[Previous: Multi-Device Identity](10-multi-device-identity.md) | [Next: Compromise Response](12-compromise-response.md)
