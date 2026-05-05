# Tutorial 12: Compromise Response

Your operational key is compromised. Someone is signing commits as you. This tutorial shows how to detect, revoke, and recover—proving that the key hierarchy from Tutorials 10-11 actually works when it matters.

**Difficulty**: Intermediate
**Builds on**: [Tutorial 11 (Offline Inception Key)](11-offline-inception-key.md)

> **Related Concepts**: After completing this tutorial, explore [Key Management](../concepts/key-management.md) for the complete security model.

## Prerequisites

- Completed Tutorial 11 (Offline Inception Key)
- Understanding of inception vs operational keys
- Understanding of SSKR share recovery

## What You'll Learn

- How to detect key compromise
- How to revoke a compromised operational key
- Why the key hierarchy contains damage
- How to recover and continue operations

## Step 0: Setting Up Your Workspace

Create a working directory for this tutorial:

```
mkdir -p output
```

## Building on Tutorial 11

| Tutorial 11 | Tutorial 12 |
|-------------|-------------|
| Inception key goes offline | Inception key enables recovery |
| SSKR shares distributed | SSKR shares used for reconstruction |
| Operational keys for daily work | Compromised operational key revoked |

**The Bridge**: Amira returns from traveling. Charlene messages urgently: "Did you push a commit to SecureAuth Library yesterday? It looks suspicious." Amira didn't. Someone else did, using her operational key.

---

## Part I: The Compromise Scenario

### Understanding What Happened

While Amira was away, her laptop credentials were compromised. The attacker:

- Accessed her operational key (sign-only permissions)
- Signed commits to the SecureAuth Library repository
- Attempted to appear as BRadvoc8

### How Was It Detected?

Charlene noticed something odd in the commit log:

```
git log --show-signature -1

│ commit 8a3f2b1c...
│ gpg: Signature made Sun Jan 19 03:42:17 2026 UTC
│ gpg: using ED25519 key BRadvoc8-laptop
│ gpg: Good signature from "BRadvoc8" [ultimate]
│
│ Author: BRadvoc8 <bradvoc8@example.com>
│ Date:   Sun Jan 19 03:42:17 2026 +0000
│
│     Update auth module with backdoor logging
```

The signature is valid—the attacker had the real key. But Charlene knows Amira was traveling without internet access on that date. The commit content also looks suspicious. She alerts Amira immediately.

> :book: **Detection Methods**
>
> Compromise is often detected through behavioral anomalies, not cryptographic failures. The signatures are valid because the attacker has the real key. Look for: unusual commit times, unexpected code changes, activity during known offline periods, or stakeholder alerts.

### What the Attacker COULD Do

| Action | Possible? | Why |
|--------|-----------|-----|
| Sign commits | Yes | Had operational key with sign permission |
| Sign attestations | Yes | Same key, same permission |
| Impersonate temporarily | Yes | Until detected and revoked |

### What the Attacker COULD NOT Do

| Action | Possible? | Why |
|--------|-----------|-----|
| Add their own key | No | No `elect` permission |
| Remove Amira's keys | No | No `revoke` permission |
| Lock Amira out | No | Inception key not on device |
| Access SSKR shares | No | Distributed offline |

**The key hierarchy contained the damage.** The attacker could sign things but couldn't take over Amira's identity.

> :book: **Damage Containment**
>
> This is the payoff from Tutorials 10-11. By limiting what each key can do and keeping the inception key offline, a compromise becomes a setback rather than a catastrophe.

---

## Part II: Understanding SSKR Protection

But wait—if the operational key is compromised, why can't we just revoke it? Why do we need to involve SSKR at all?

### What SSKR Actually Protects

SSKR shares protect the **inception key**, not operational keys. The inception key is created when the XID is born and split into shares. Operational keys are added later and exist only on devices.

| Component | Where It Lives | SSKR Protected? |
|-----------|---------------|-----------------|
| Inception key | SSKR shares (offline) | Yes |
| Operational keys | Devices | No |

When an operational key is compromised, you don't "revoke" it from the shares—it was never there. Instead, you reconstruct the inception key (which has `elect` and `revoke` permissions) and use it to remove the compromised key and add a replacement.

> :warning: **Why Reconstruction Is Required**
>
> Only keys with `elect` permission can add new keys. Only keys with `revoke` permission can remove keys. The compromised operational key has neither—it can only sign. That's the protection, but it also means recovery requires the inception key.

### Step 1: Set Up Scenario

For this tutorial, we'll simulate the scenario:

```
# Create Amira's XID with inception key
XID=$(envelope generate keypairs --signing ed25519 | \
    envelope xid new --nickname "BRadvoc8" --generator include --sign inception)

UNWRAPPED_XID=$(envelope extract wrapped "$XID")

# Create SSKR shares of inception key (before adding operational keys)
SHARES=$(envelope sskr split --group "2-of-3" "$XID")

SHARE1=$(echo "$SHARES" | awk '{print $1}')
SHARE2=$(echo "$SHARES" | awk '{print $2}')

# Add operational key to device (NOT in shares)
COMPROMISED_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
COMPROMISED_PUBKEYS=$(envelope generate pubkeys "$COMPROMISED_PRVKEYS")

DEVICE_XID=$(envelope xid key add \
    --allow sign \
    --nickname "laptop-compromised" \
    "$COMPROMISED_PUBKEYS" "$UNWRAPPED_XID")

echo "Setup complete:"
echo "  - SSKR shares contain: inception key only"
echo "  - Device has: XID with inception + operational keys"

│ Setup complete:
│   - SSKR shares contain: inception key only
│   - Device has: XID with inception + operational keys
```

This simulates what Amira had before the compromise: SSKR shares created when the XID was born (containing only the inception key), and an operational key added later to her laptop.

### Step 2: Reconstruct Inception Key

Amira contacts Charlene for her share and retrieves her share from the safety deposit box:

```
# Reconstruct from shares (Amira + Charlene)
RECOVERED=$(envelope sskr join "$SHARE1" "$SHARE2")

echo "Inception key reconstructed for recovery operations"

│ Inception key reconstructed for recovery operations
```

The reconstructed XID has only the inception key—exactly what was in the shares at creation. The compromised operational key was never in the shares, so there's nothing to "revoke" from them. But now Amira has the inception key, which has the permissions to fix this.

---

## Part III: Recovery

### Step 3: Revoke the Compromised Key

First, Amira removes the compromised key from her XID. This requires the inception key (which has `revoke` permission):

```
# Extract the reconstructed XID (contains inception key)
RECOVERED_UNWRAPPED=$(envelope extract wrapped "$RECOVERED")

# The compromised key needs to be removed from the CURRENT device XID
# (which has both inception and compromised operational keys)
CLEANED_XID=$(envelope xid key remove "$COMPROMISED_PUBKEYS" "$DEVICE_XID")

# Verify the compromised key is gone
envelope format "$CLEANED_XID" | grep "laptop-compromised" || echo "✅ Compromised key removed"

│ ✅ Compromised key removed
```

> :warning: **Revocation Is Public**
>
> Removing a key from your XID doesn't retroactively invalidate signatures made with that key. Those signatures were valid when made. What revocation does is signal to verifiers: "Don't trust new signatures from this key." Always publish your updated XID promptly after revocation.

Let's prove both parts of this. First, historical signatures from the compromised key are still cryptographically valid:

```
# Create something the attacker signed before revocation
MALICIOUS_COMMIT=$(envelope subject type string "Backdoor commit message")
MALICIOUS_SIGNED=$(envelope sign --signer "$COMPROMISED_PRVKEYS" "$MALICIOUS_COMMIT")

# The signature is still mathematically valid
envelope verify --verifier "$COMPROMISED_PUBKEYS" "$MALICIOUS_SIGNED" >/dev/null && \
    echo "⚠️  Historical signature still valid (expected - signatures don't expire)"

│ ⚠️  Historical signature still valid (expected - signatures don't expire)
```

But the compromised key is no longer in the XID—verifiers checking "is this key authorized?" will see it's gone:

```
# Check if compromised key is still in the XID
envelope format "$CLEANED_XID" | grep -q "laptop-compromised" && \
    echo "❌ Key still present" || echo "✅ Key removed from XID"

│ ✅ Key removed from XID
```

> :book: **The Time Window Problem**
>
> Between compromise and detection, the attacker could sign anything. Those signatures are permanently valid. This is why fast detection matters, and why you may need to publicly disavow signatures from the compromise window.

### Step 4: Add New Operational Key

Now Amira sets up a new device with a fresh operational key:

```
# Generate key for new device
NEW_DEVICE_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
NEW_DEVICE_PUBKEYS=$(envelope generate pubkeys "$NEW_DEVICE_PRVKEYS")

# Add to cleaned XID
RECOVERED_XID=$(envelope xid key add \
    --allow sign \
    --nickname "new-device-2026" \
    "$NEW_DEVICE_PUBKEYS" "$CLEANED_XID")

echo "New operational key added"
envelope format "$RECOVERED_XID" | grep -E "(nickname|allow)"

│ New operational key added
│             'allow': 'All'
│             'nickname': "BRadvoc8"
│             'allow': 'Sign'
│             'nickname': "new-device-2026"
```

Notice: the compromised `laptop-compromised` key is gone, replaced by `new-device-2026`.

### Step 5: Advance Provenance and Re-split

After any identity change, advance provenance and re-split:

```
# Advance provenance to signal this is a new version
RECOVERED_XID=$(envelope xid provenance next "$RECOVERED_XID")

# Sign with inception key (required for identity changes)
RECOVERED_XID_WRAPPED=$(envelope sign --signer "$RECOVERED" "$RECOVERED_XID")

# Create new SSKR shares
NEW_SHARES=$(envelope sskr split --group "2-of-3" "$RECOVERED_XID_WRAPPED")

echo "Recovery complete:"
echo "  - Provenance advanced (signals update to verifiers)"
echo "  - New SSKR shares created"
echo "  - Redistribute to: safety deposit, Charlene, cloud backup"

│ Recovery complete:
│   - Provenance advanced (signals update to verifiers)
│   - New SSKR shares created
│   - Redistribute to: safety deposit, Charlene, cloud backup
```

> :book: **Why Advance Provenance?**
>
> The provenance sequence number tells verifiers "this is version N of this identity." After a compromise, you want verifiers to know there's a new version—so they fetch your updated XID with the revoked key removed.

### Step 6: Publish Updated XID

The revocation only protects Amira if verifiers see it. She publishes immediately:

```
# Export public version (elide private keys and generator)
PUBLIC_XID=$(envelope xid export --private elide --generator elide "$RECOVERED_XID_WRAPPED")

# In practice: push to your dereferenceVia location
echo "Publishing updated XID to:"
echo "  - https://github.com/BRadvoc8/xid/raw/main/bradvoc8.xid"
echo "  - https://bradvoc8.example.com/.well-known/xid"

# Save for this tutorial
echo "$PUBLIC_XID" > "output/bradvoc8-public-revoked.xid"
echo "✅ Updated XID ready for publication"

│ Publishing updated XID to:
│   - https://github.com/BRadvoc8/xid/raw/main/bradvoc8.xid
│   - https://bradvoc8.example.com/.well-known/xid
│ ✅ Updated XID ready for publication
```

> :warning: **Publish Immediately**
>
> Every minute between revocation and publication is a minute the attacker's signatures look legitimate. Push your updated XID as soon as possible.

### Step 7: Create Disavowal Statement

Amira creates a signed statement disavowing signatures from the compromise window:

```
# Create disavowal statement
DISAVOWAL=$(envelope subject type string "Disavowal Statement")
DISAVOWAL=$(envelope assertion add pred-obj string "disavows" string "All signatures from key 'laptop-compromised' between 2026-01-15 and 2026-01-20" "$DISAVOWAL")
DISAVOWAL=$(envelope assertion add pred-obj string "reason" string "Key compromise - unauthorized access" "$DISAVOWAL")
DISAVOWAL=$(envelope assertion add pred-obj string "issuedBy" string "BRadvoc8" "$DISAVOWAL")
DISAVOWAL=$(envelope assertion add pred-obj string "issuedOn" date "2026-01-20T00:00:00Z" "$DISAVOWAL")

# Sign with inception key (highest authority)
DISAVOWAL_SIGNED=$(envelope sign --signer "$RECOVERED" "$DISAVOWAL")

echo "Disavowal statement created:"
envelope format "$DISAVOWAL_SIGNED"

│ Disavowal statement created:
│ {
│     "Disavowal Statement" [
│         "disavows": "All signatures from key 'laptop-compromised' between 2026-01-15 and 2026-01-20"
│         "issuedBy": "BRadvoc8"
│         "issuedOn": 2026-01-20T00:00:00Z
│         "reason": "Key compromise - unauthorized access"
│     ]
│ } [
│     'signed': Signature
│ ]
```

This statement, signed by the inception key, publicly declares which signatures should not be trusted. Amira can publish it alongside her updated XID.

### Step 8: Ben Verifies Recovery

Ben fetches Amira's updated XID and verifies the recovery:

```
# Ben fetches the updated XID (simulated)
FETCHED_XID="$PUBLIC_XID"

# 1. Check provenance advanced (new version)
echo "Ben's verification:"
echo "1. Checking provenance..."
envelope format "$FETCHED_XID" | grep -q "ProvenanceMark" && echo "   ✅ Provenance present"

# 2. Verify compromised key is gone
echo "2. Checking compromised key removed..."
envelope format "$FETCHED_XID" | grep -q "laptop-compromised" && \
    echo "   ❌ Compromised key still present!" || echo "   ✅ Compromised key removed"

# 3. Verify new operational key present
echo "3. Checking new key added..."
envelope format "$FETCHED_XID" | grep -q "new-device-2026" && echo "   ✅ New operational key present"

# 4. Verify signature (inception key signed the update)
echo "4. Verifying signature..."
envelope verify "$FETCHED_XID" >/dev/null 2>&1 && echo "   ✅ Signature valid"

│ Ben's verification:
│ 1. Checking provenance...
│    ✅ Provenance present
│ 2. Checking compromised key removed...
│    ✅ Compromised key removed
│ 3. Checking new key added...
│    ✅ New operational key present
│ 4. Verifying signature...
│    ✅ Signature valid
```

Ben can now trust new signatures from `new-device-2026` but knows to be suspicious of any signatures from `laptop-compromised` dated after 2026-01-15.

---

## Part IV: Why Identity Survived

### The Security Model Worked

| Component | Role in Recovery |
|-----------|-----------------|
| Inception key offline | Attacker couldn't take over identity |
| SSKR shares | Enabled inception key reconstruction |
| Operational key limits | Attacker could only sign, not manage |
| Charlene's share | Trusted friend enabled recovery |

### What Would Have Happened Without This Setup

If Amira's inception key had been on the compromised laptop:

- Attacker could add their own key with full permissions
- Attacker could remove all of Amira's keys
- **Identity takeover**—Amira locked out completely
- All endorsements, attestations, and reputation lost
- Would need to start over with a new XID

**The key hierarchy prevented this.** Amira lost an operational key but kept her identity.

> :brain: **Learn more**
>
> The [Key Management](../concepts/key-management.md) concept doc explains the full permission model and why this hierarchy provides defense in depth.

---

## Part V: Wrap-Up

### Save Recovery Artifacts

```
OUTPUT_DIR="output/xid-tutorial12-$(date +%Y%m%d%H%M%S)"
mkdir -p "$OUTPUT_DIR"

# Save private artifacts (keep secure)
echo "$NEW_DEVICE_PRVKEYS" > "$OUTPUT_DIR/new-device-key.envelope"
echo "$RECOVERED_XID_WRAPPED" > "$OUTPUT_DIR/recovered-xid.envelope"

# Save public artifacts (can be published)
echo "$PUBLIC_XID" > "$OUTPUT_DIR/bradvoc8-public.xid"
echo "$DISAVOWAL_SIGNED" > "$OUTPUT_DIR/disavowal-statement.envelope"

echo "Saved to $OUTPUT_DIR"
ls "$OUTPUT_DIR"

│ Saved to output/xid-tutorial12-20260126120000
│ bradvoc8-public.xid
│ disavowal-statement.envelope
│ new-device-key.envelope
│ recovered-xid.envelope
```

### Amira's Recovery Checklist

After a compromise, Amira:

1. ✅ Detected compromise (Charlene's alert about suspicious commit)
2. ✅ Reconstructed inception key from SSKR shares
3. ✅ Revoked compromised operational key
4. ✅ Verified historical signatures still valid but key removed
5. ✅ Added new operational key for replacement device
6. ✅ Advanced provenance to signal update
7. ✅ Re-split inception key into new SSKR shares
8. ✅ Published updated XID to dereferenceVia locations
9. ✅ Created and published disavowal statement
10. ✅ Ben verified the recovery

**External steps** (also completed):

- Revoke old GitHub signing key, add new one
- Notify stakeholders (Ben, project maintainers)
- Review and flag suspicious commits from compromise window
- Update any service-specific credentials

### What Amira Learned

**Preparation matters**: The key hierarchy and SSKR distribution—set up in T10-T11—enabled quick recovery.

**Damage was contained**: The attacker could sign things but couldn't lock Amira out or destroy her reputation.

**Web of trust helped**: Charlene's relationship with Amira enabled trusted recovery. Ben's monitoring detected the problem.

**Identity is resilient**: When properly structured, a compromise is a setback, not a catastrophe.

### Charlene's Verdict

> "You just survived a real attack. The attacker had your key, used it, and you still came out on top. Your identity is intact, your reputation preserved, and you're back to work with a clean setup. This is what we built in T10 and T11—and now you've proven it works."

---

## Common Questions

**What if the attacker already signed something malicious?**

Those signatures are valid—the key was legitimate when it signed. You can't cryptographically invalidate them. What you can do: (1) publicly disavow the signatures with a signed statement from your inception key, (2) remove the compromised key so verifiers know not to trust new signatures, and (3) publish timestamps showing when you detected the compromise.

**What if I can't reach Charlene?**

With 2-of-3 SSKR, you need any two shares. If Charlene is unavailable, use your safety deposit share plus your cloud backup share. This is why distributing shares across different contexts matters—you're not dependent on any single person or location.

**How quickly should I respond?**

As fast as possible. Every hour the compromised key remains "valid" in your published XID is an hour the attacker can sign things. The reconstruction and revocation process takes minutes. The bottleneck is usually physical access to shares.

**Should I change my inception key too?**

No. The inception key wasn't compromised (it was offline in SSKR shares). Changing it would mean creating a new XID and losing your reputation history. The whole point of the key hierarchy is that operational key compromise doesn't require identity restart.

---

## Exercises

These exercises test your incident response readiness:

1. **Dual compromise**: Simulate both laptop and portable drive compromised simultaneously. Can you still recover with your share distribution strategy?

2. **Response runbook**: Write a step-by-step checklist for your own identity, with specific share locations, contact methods for share holders, and notification list for stakeholders.

3. **Time trial**: Practice the full reconstruction cycle (retrieve shares → reconstruct → revoke → add new key → re-split → redistribute). How long does it take? Where are the bottlenecks?

---

## Appendix: Key Terminology

> **Key Revocation**: Removing a compromised key from an XID, preventing future use while maintaining identity continuity.
>
> **Damage Containment**: The principle that compromising a low-permission key should not escalate to identity takeover.
>
> **Recovery**: The process of regaining control after compromise—enabled by offline inception keys and SSKR shares.
>
> **Inception Key**: The original key with full permissions (`elect`, `revoke`). Should be offline in SSKR shares.

---

## Security Hardening Arc Complete

You've completed the security hardening arc (T10-T12):

| Tutorial | What You Built |
|----------|----------------|
| T10: Multi-Device Identity | Operational keys limit compromise damage |
| T11: Offline Inception Key | Inception key survives device loss |
| T12: Compromise Response | Recovery process when things go wrong |

Amira's identity survived a real attack because she structured her keys properly. The attacker got her operational key but couldn't take over her identity, and she recovered without losing her reputation.

**What's Next**: [Tutorial 20: Gordian Clubs](20-gordian-clubs.md) covers secure group communication—how multiple people can share secrets and make collective decisions.

---

[Previous: Offline Inception Key](11-offline-inception-key.md) | [Next: Gordian Clubs](20-gordian-clubs.md)
