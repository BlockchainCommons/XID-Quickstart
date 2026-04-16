# 5.1: Generating Operational Keys

To date, we've used a single key to control your XID, the inception
key. Sure, we've added keys for GitHub, for attestations, and for
signing contracts, but that one key was still all that lay between a
XID and the loss of that identifier. Here's where we start to turn
that around.

**Difficulty**: Intermediate
**Builds on**: [Tutorial 09 (Binding Agreements)](09-binding-agreements.md)

> 🧠 **Related Concepts.** After completing this tutorial, explore
[Key Management](../concepts/key-management.md) to understand the full
key hierarchy model.

## Objectives of this Section

After working through this section, a developer will be able to:

- Add operational keys with limited permissions
- Set up multiple devices safely

Supporting objectives include the ability to:

- Understand why single-key identity is risky for active work

## Amira's Story: The Fragility of Single Keys

We've talked a number of times about maintaining hetergeneous
keys. Having different keys for different purposes ensures that if a
key is lost or compromised, the damage is limited.

That's doubly true for your inception key, which controls your entire
XID. And that's especially important for Amira now that she's been
accepted to work on SisterSpaces. If she were to lose her BRadvoc8
XID, she'd be back to square one.

So how does she protect the investment she's made in her pseudonmyous
identity to this point. She follows the [least and necessary design
patterns](https://www.blockchaincommons.com/musings/Least-Necessary/)
which means that she ensures that the keys that she uses every day
have the least permissions necessary for the work she's doing.

That's a three-step process:

1. Create operational keys (§5.1).
2. Adjust her operational keys to just the right (necessary) permissions (§5.2).
3. Backup her inception key separate from her XID (§5.3).

The steps to do so will be the main through-line of this chapter..

## Part 0: Verify Dependencies

Before you get started, you should (as usual) check your `envelope-cli` version:

```
envelope --version

│ bc-envelope-cli 0.34.1
```

Then, reload your XID. 

```
XID=$(cat envelopes/BRadvoc8-xid-s7-private-4-04.envelope)
XID_ID=$(envelope xid id $XID)
PASSWORD="your-password-from-previous-tutorials"
```

## Amira's Challenge: Working Across Devices

Ben sends Amira access to the SecureAuth Library repository. Charlene helps her prepare:

> "You'll be working from different machines. Right now your XID has one key that does everything. If your laptop is compromised, an attacker gets full control of your identity—they could lock you out, revoke your keys, destroy your reputation. Let's fix that."

**The problem**: One key with all permissions = single point of failure.

**The solution**: Add operational keys that can sign but can't manage the identity itself.

### The Power of Key Permissions

Besides supporting different keys, XIDs also support different key
permissions. `xid key add --help` will display instructions on how to
add keys, including information on how to adjust permissions (which
we've just lightly touched upon before):

```
envelope xid key add --help

| Add a key to the XID document
|
| Usage: envelope xid key add [OPTIONS] [KEYS] [ENVELOPE]
|
| ...
|
|       --allow <PRIVILEGE>
|           Grant a specific permission to the key. May be repeated
| 
|           Possible values:
|           - all:      Allow all applicable XID operations
|           - auth:     Operational: Authenticate as the subject (e.g., log into services)
|           - sign:     Operational: Sign digital communications as the subject
|           - encrypt:  Operational: Encrypt messages from the subject
|           - elide:    Operational: Elide data under the subject's control
|           - issue:    Operational: Issue or revoke verifiable credentials on the subject's authority
|           - access:   Operational: Access resources under the subject's control
|           - delegate: Management: Delegate priviledges to third parties
|           - verify:   Management: Verify (update) the XID document
|           - update:   Management: Update service endpoints
|           - transfer: Management: Remove the inception key from the XID document
|           - elect:    Management: Add or remove other verifiers (rotate keys)
|           - burn:     Management: Transition to a new provenance mark chain
|           - revoke:   Management: Revoke the XID entirely
|          
|          [default: all]
```

As shown, key privileges are widely divided into two
types. Operational permissions are what are needed for the use of your
XID, while management permissions are what are needed to update your
XID. The way to protect a XID is ultimately to store away management
(especially inception) keys while using operational keys for your
everyday usage.

## Part I: Understanding Key Permissions

Key permissions can be easily checked using the `xid key` commands.

### Step 1: Listing Keys

The first step in dealing with keys is manipulating them.

You can count the keys in a XID with `envelope xid key count`:
```
envelope xid key count $XID

| 3
```

You can list them with `envelope xid key all`:

```
envelope xid key all $XID

| ur:envelope/lrtpsotansgylftanshflfaohdcxhleosstafpwzesmsaychonvtpfbztyytcmhfmonefluylabzgtcmbbpseycnzcuytansgrhdcxmwaycebgqdrslksogrrnhygmhtdthtctaymkuroxueptgtehvwzosgeyfnlepkfgoycscstpsojziajljtjyjphsiajydpjeihkkhdcxrkhyhsmobkplkbwpeszsplkoadimgwchceemdngssnjpihcfgwjswnjlchcsdmtyoycsfncsfdeeplrsnn
| ur:envelope/lrtpsotansgylftanshflfaohdcxolmystmtwyhhgljscpamingewnkplnpssfmnsnlramdwclkpkswmkstbfgdngdtotansgrhdcxsoeymskoiyrseswelubkspfdhllpmyksrpmkcmwzaoplwdlrfhzoropslpnlcmadoycscstpsoisfwgmhsiekojliaetoycsfncsfghdcxgwlufzhpbzpkdtwnvwpsctkiemtpmhbkdsgwdteehtnyureygeykcmnstecwoehhsektksqz
| ur:envelope/lrtpsotansgylftanshflfaohdcxtyjeuyceehntqzmwtdhfoscmguplcyeoaarhcxghreynrlfleynefnbtiodyesattansgrhdcxntesveuelkhdbnwdutynettbaarnnbspgefsvemohtnezeldcncmueldtkjlfxhdoycscstpsojlhsjyjyihjkjyhsjyinjljtdpjeihkkoycsfncsfdhdcxwtbwwmgshninknjypsoyeyaegaiatdetfgchbsnbehtstkihynpmflaxrnsaesssyaamtkhd
```

If you know what's where in a XID, you can retrieve a specific key with `envelope xid key at`:
```
envelope xid key at 0 $XID

| ur:envelope/lrtpsotansgylftanshflfaohdcxhleosstafpwzesmsaychonvtpfbztyytcmhfmonefluylabzgtcmbbpseycnzcuytansgrhdcxmwaycebgqdrslksogrrnhygmhtdthtctaymkuroxueptgtehvwzosgeyfnlepkfgoycscstpsojziajljtjyjphsiajydpjeihkkhdcxrkhyhsmobkplkbwpeszsplkoadimgwchceemdngssnjpihcfgwjswnjlchcsdmtyoycsfncsfdeeplrsnn
```
Finally, the `envelope xid key find` command can either let you find an inception key:

```
$ envelope xid key find inception $XID
ur:envelope/lstpsotansgylftanshflfaohdcxolmystmtwyhhgljscpamingewnkplnpssfmnsnlramdwclkpkswmkstbfgdngdtotansgrhdcxsoeymskoiyrseswelubkspfdhllpmyksrpmkcmwzaoplwdlrfhzoropslpnlcmadoycscstpsoisfwgmhsiekojliaetoycsfncsfgmdzechws
```

Or a key with a specific name:

```
envelope xid key find name "attestation-key" $XID
```
ur:envelope/lstpsotansgylftanshflfaohdcxtyjeuyceehntqzmwtdhfoscmguplcyeoaarhcxghreynrlfleynefnbtiodyesattansgrhdcxntesveuelkhdbnwdutynettbaarnnbspgefsvemohtnezeldcncmueldtkjlfxhdoycscstpsojlhsjyjyihjkjyhsjyinjljtdpjeihkkoycsfncsfdeymkzopk
```

(And isn't that a lot easier than finding the assertion as we demonstrated in [§4.3](04_3_Creating_New_Views.md)?)

### Step 2: Check Current Key Permissions

A simple `for` loop of the sort used before can list exactly what each key in a XID does:
```
read -a KEYLIST <<< $(envelope xid key all "$XID")
for i in "${KEYLIST[@]}"
  do
    envelope format $i
done
```

This reveals the three keys that we've added over the course of this tutorial: Amira's inception key, and two signing keys, one for attestations and one for contracts:
```
PublicKeys(57f4126d, SigningPublicKey(e15ac4c2, Ed25519PublicKey(a4893d82)), EncapsulationPublicKey(49ad97ce, X25519PublicKey(49ad97ce))) [
    'allow': 'Sign'
    'nickname': "contract-key"
    ELIDED
]
PublicKeys(a9818011, SigningPublicKey(5f1c3d9e, Ed25519PublicKey(b2c16ea3)), EncapsulationPublicKey(96209c0f, X25519PublicKey(96209c0f))) [
    'allow': 'All'
    'nickname': "BRadvoc8"
    ELIDED
]
PublicKeys(6d94a1eb, SigningPublicKey(128ffa82, Ed25519PublicKey(363eab4e)), EncapsulationPublicKey(e46036f9, X25519PublicKey(e46036f9))) [
    'allow': 'Sign'
    'nickname': "attestation-key"
    ELIDED
]
```

Now we know what we're working with!

## Part II: Adding Operational Keys

Two sorts of protection are required for keys. Obviously, they must be
protected from loss. That's going to be the topic of §5.3: how to
ensure that the inception key is always available. However, they also
have to be protected from compromise: someone stealing them and using
them without permission.

That's going to be the topic of this chapter, where we practice the
[least and
necessary](https://www.blockchaincommons.com/musings/Least-Necessary/)
design patterns by creating new keys with limited permissions for
everyday usage, so that if keys are stolen, they're these keys, rather
than the ones that control the XID.

### Step 3: Generate a Laptop Key

To start with, Amira is going to generate a new operational key for
the laptop where she does all of her work for SisterSpaces.

```
LAPTOP_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
LAPTOP_PUBKEYS=$(envelope generate pubkeys "$LAPTOP_PRVKEYS")

echo "✅ Generated laptop operational key"

│ ✅ Generated laptop operational key
```

### Step 4: Add Key with Limited Permissions

The permissions aren't actually in the key, which is just a standard
ed25519 key, but instead in the XID. As we've seen previously, when we
added attestation and contract keys for Amira, when you add a key you
choose the permissions it'll have.

```
XID_WITH_OPERATIONAL_KEY_1=$(envelope xid key add \
    --verify inception \
    --nickname "laptop-key" \
    --allow auth \
    --allow sign \
    --allow encrypt \
    --allow elide \
    --allow issue \
    --allow access \
    --private encrypt \
    --encrypt-password "$PASSWORD" \
    "$LAPTOP_PRVKEYS" \
    "$XID")
```

`envelope format $XID` reveals a key with a much longer list of permissions than the other keys to date:

```
| ✅ Added operational (laptop) key to XID
|
| ...
|
| 'key': PublicKeys(19f38b63, SigningPublicKey(769cfaa0, Ed25519PublicKey(91d00d2e)), EncapsulationPublicKey(66b98378, X25519PublicKey(66b98378))) [
|         {
|             'privateKey': ENCRYPTED [
|                 'hasSecret': EncryptedKey(Argon2id)
|             ]
|         } [
|             'salt': Salt
|         ]
|         'allow': 'Access'
|         'allow': 'Authorize'
|         'allow': 'Elide'
|         'allow': 'Encrypt'
|         'allow': 'Issue'
|         'allow': 'Sign'
|         'nickname': "contract-key"
|    ]
```

### Step 5: Generate a Laptop GitHub Key

Best practice is also to have a different GitHub key for each
device. Because Amira has only been doing SisterSpaces work on her
laptop, the signing key she created in [§3.1](03_1_Creating_Edges.md)
is effectively her laptop SSH signing key.

She might want to adjust her labeling of the key now that she's
thinking about keys on a per-device basis. More importantly, if she
ever does SisterSpaces GitHub work on a different device, she should
create another key for use exclusviely on that device.

### Step 6: Add a Portable Drive Key

At a later date, Amira goes on a trip during a time when she's likely
to need to make some updates to SisterSpaces files using her BRadvoc8
identity. She doesn't want to bring either her inception key or her
fully operational laptop key.

Before the trip, she archives everything, with the plan to only use a
more limited key that she's going to keep on a bootable portable
drive.

As usual, she creates the keys:
```
PORTABLE_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
PORTABLE_PUBKEYS=$(envelope generate pubkeys "$LAPTOP_PRVKEYS")
```

Then adds them to her XID with a different set of permissions. She
opts to remove the `encrypt` permission and the `issue` permission, so
that if her key goes stray when she's on the move, an attacker can't
decrypt her content nor create new credentials. This follows the
least/necessary pattern: she plans to be working on PRs for
SisterSpaces, not these other things
```
XID_WITH_OPERATIONAL_KEY_2=$(envelope xid key add \
    --nickname "portable-key" \
    --allow auth \
    --allow sign \
    --allow elide \
    --allow access \
    --private encrypt \
    --encrypt-password "$PASSWORD" \
    "$PORTABLE_PRVKEYS" \
    "$XID_WITH_OPERATIONAL_KEY_1")

echo "✅ Generated portable operational key"
```

Here's the result:
```
envelope format $XID_WITH_OPERATIONAL_KEY_2

| XID(5f1c3d9e) [
|
| ...
| 
|     'key': PublicKeys(19f38b63, SigningPublicKey(769cfaa0, Ed25519PublicKey(91d00d2e)), EncapsulationPublicKey(66b98378, X25519PublicKey(66b98378))) [
|         {
|             'privateKey': ENCRYPTED [
|                 'hasSecret': EncryptedKey(Argon2id)
|             ]
|         } [
|             'salt': Salt
|         ]
|         'allow': 'Access'
|         'allow': 'Authorize'
|         'allow': 'Elide'
|         'allow': 'Encrypt'
|         'allow': 'Issue'
|         'allow': 'Sign'
|         'nickname': "laptop-key"
|     ]
|     'key': PublicKeys(57f4126d, SigningPublicKey(e15ac4c2, Ed25519PublicKey(a4893d82)), EncapsulationPublicKey(49ad97ce, X25519PublicKey(49ad97ce))) [
|         'allow': 'Sign'
|         'nickname': "contract-key"
|     ]
|     'key': PublicKeys(6d94a1eb, SigningPublicKey(128ffa82, Ed25519PublicKey(363eab4e)), EncapsulationPublicKey(e46036f9, X25519PublicKey(e46036f9))) [
|         'allow': 'Sign'
|         'nickname': "attestation-key"
|     ]
|     'key': PublicKeys(7015dca5, SigningPublicKey(52542a78, Ed25519PublicKey(d4939b2d)), EncapsulationPublicKey(1beeacb5, X25519PublicKey(1beeacb5))) [
|         {
|             'privateKey': ENCRYPTED [
|                 'hasSecret': EncryptedKey(Argon2id)
|             ]
|         } [
|             'salt': Salt
|         ]
|         'allow': 'Access'
|         'allow': 'Authorize'
|         'allow': 'Elide'
|         'allow': 'Sign'
|         'nickname': "portable-key"
|     ]
|     'key': PublicKeys(a9818011, SigningPublicKey(5f1c3d9e, Ed25519PublicKey(b2c16ea3)), EncapsulationPublicKey(96209c0f, X25519PublicKey(96209c0f))) [
|         'allow': 'All'
|         'nickname': "BRadvoc8"
|     ]
|     ...
| ]
```

### Step 7: Review and Store

XID_WITH_KEYS=$(envelope xid provenance next \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$XID_WITH_OPERATIONAL_KEY_2")
echo "✅ Provenance advanced"

PUBLIC_XID_WITH_KEYS=$(envelope xid export --private elide --generator elide "$XID_WITH_KEYS")

echo "$LAPTOP_PRVKEYS" > envelopes/key-laptop-private-5-01.ur
echo "$LAPTOP_PUBKEYS" > envelopes/key-laopt-public-5-01.ur
echo "$PORTABLE_PRVKEYS" > envelopes/key-portable-private-5-01.ur
echo "$PORTABLE_PUBKEYS" > envelopes/key-portable-public-5-01.ur

echo "$PUBLIC_XID_WITH_KEYS" > envelopes/BRadvoc8-xid-public-5-01.envelope
echo "$XID_WITH_KEYS" > envelopes/BRadvoc8-xid-private-5-01.envelope


At this point, Amira can review her XID that now has five keys in it:

[this goes under key structure]



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

[add key strucure]

---

[add: eliding main keys for usage]

[into 5.2]

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
