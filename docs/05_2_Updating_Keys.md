# 5.2: Updating Keys

Keys aren't forever. They may need to be rotated due to loss or
compromise. And in the world of XIDs, you can also change the
permissions associated with a key.

> 🧠 **Related Concepts.** After completing this tutorial, explore
[Key
Management](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/concepts/key-management.md)
to understand the full key hierarchy model.

## Objectives of this Section

After working through this section, a developer will be able to:

- Change key permissions
- Remove keys from or add keys to a XID

Supporting objectives include the ability to:

- Understand what key rotation is
- Understand the limitations of changing keys

## Amira's Story: The Ephemerality of Keys

Keys are ultimately ephemeral. That's been one of the traditional
problems with digital identifiers: they tend to get lost as keys
fail. Any serious digital identifier therefore needs to address this
issue: how can an identifier remain static even with the expected
turnover of keys? It's especially important to Amira, who has just
spent four chapters building the reputation of her BRadvoc8 digital
identifier.

Fortunately, XIDs have her back. They're built to allow both a
transition of keys over time and also a transition of key
permissions. This chapter describes some easy key manipulation, where
Amira modifies and rotates some of the operational keys that she
created in [§5.1](05_1_Generating_Operational_Keys.md).

## Part 0: Verify Dependencies

Before you get started, you should (as usual) check your `envelope-cli` version:

```
envelope --version

│ bc-envelope-cli 0.34.1
```

Then, reload your XID. 

```
XID=$(cat envelopes/BRadvoc8-xid-private-5-01.envelope)
XID_ID=$(envelope xid id $XID)
PASSWORD="your-password-from-previous-tutorials"
```

### Part I: Changing Key Permissions

Amira realizes that she overpowered her laptop key. She doesn't need
it to have `access` permission because she's never designated any
resources to be under her XID's control. Though this seems irrelevent
at the moment, the [least and
necessary](https://www.blockchaincommons.com/musings/Least-Necessary/)
design pattern says to remove permissions from keys if they're not
needed.

Changing a key's permissions is very simple: it requires finding the
key to change and modifying the permission on it.

### Step 1: Find the Key to Change

As we saw in [§5.1](05_1_Generating_Operational_Keys.md), it's trivial
to extract a key from a XID: you just use `envelope xid key find`:
```
LAPTOP_PRVKEYS=$(envelope xid key find name --private --password "$PASSWORD" "laptop-key" $XID)
```

As it happens, changing is done using the pubkeys, so you'll need to
generate those once you extract the private keys:

```
LAPTOP_PUBKEYS=$(envelope generate pubkeys $LAPTOP_PRVKEYS)
```

### Step 2: Update the Key

You then use `envelope xid key update` with the pubkey of the pair you
want to change, and give it a new list of permissions:

```
XID_WITH_UPDATED_KEY=$(envelope xid key update \
    --verify inception \
    --nickname "laptop-key" \
    --allow auth \
    --allow sign \
    --allow encrypt \
    --allow elide \
    --allow issue \
    --private encrypt \
    --encrypt-password "$PASSWORD" \
    "$LAPTOP_PUBKEYS" \
    "$XID")
```

If you look at the XID afterward, you'll see that it's properly updated: there's ony one version of the `laptop-key` and it now has the permissions without `access`:

```
envelope format $XID_WITH_UPDATED_KEY

| XID(5f1c3d9e) [
|
| ...
|
|     'key': PublicKeys(c32d7426, SigningPublicKey(59e9ad4d, Ed25519PublicKey(425b8e15)), EncapsulationPublicKey(c2b3746b, X25519PublicKey(c2b3746b))) [
|         {
|             'privateKey': ENCRYPTED [
|                 'hasSecret': EncryptedKey(Argon2id)
|             ]
|         } [
|             'salt': Salt
|         ]
|         'allow': 'Authorize'
|         'allow': 'Elide'
|         'allow': 'Encrypt'
|         'allow': 'Issue'
|         'allow': 'Sign'
|         'nickname': "laptop-key"
|     ]
| ...
| ]
```
#### What If Someone Tries to Change Keys without the Inception Key?

The whole point of [§5.1](05_1_Generating_Operational_Keys.md) was
that removing your inception key from your XID would keep it safe
because people couldn't manipulate the keys.

We can now prove that fact by instead trying to do this work with the
operational view of the XID that we created in the last chapter:

```
OP_XID=$(cat envelopes/BRadvoc8-xid-operational-5-01.envelope)
```

We exactly duplicate the previous command, except with the operational
XID, and without verifying the inception key (because it isn't there):

```
envelope xid key update \
    --nickname "laptop-key" \
    --allow auth \
    --allow sign \
    --allow encrypt \
    --allow elide \
    --allow issue \
    --private encrypt \
    --encrypt-password "$PASSWORD" \
    "$LAPTOP_PUBKEYS" \
    "$OP_XID"

| Error: envelope parsing error
| 
| Caused by:
|     the envelope's subject is not a leaf
```

It doesn't work! Granted, the error message is unintuitive, but the
fact remains that our creation of an operational version of the XID
has secured our identity. (We just need to remember to always
unarchive the original version of the XID when we want to make
changes.)

### Step 3: Update & Store

It's more important than ever to update your XID at this point. That's
because the implicit revocation that occurs when you release a new
edition of your XID is the only way for people to know that you've
changed permissions on your key.

Until that point, the old version of your XID could still be used,
with all the old permissions. (And yes, that could still be the case
_after_ you update, but best practice is to always to dereference a
XID and check the newest version. Hopefully any services you're
working with does so!)

```
XID_WITH_UPDATED_KEY=$(envelope xid provenance next \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$XID_WITH_UPDATED_KEY")

PUBLIC_XID_WITH_UPDATED_KEY=$(envelope xid export --private elide --generator elide "$XID_WITH_UPDATED_KEY")
```

And of course store everything:

```
echo "$XID_WITH_UPDATED_KEY" > envelopes/BRadvoc8-xid-s9-private-5-02.envelope
echo "$PUBLIC_XID_WITH_UPDATED_KEY" > envelopes/BRadvoc8-xid-s9-public-5-02.envelope
```
    
## Part II: Rotating a Key

Changing a key's permissions is one side of the equation, but you
might also need to change the key itself. This could happen because
your previous key was compromised or lost or for some other reason.

In Amira's case, she gets a new laptop, and she decides it's a good
time to change her keys because that'll help her identify which laptop
was used for various activities. (It's always best practice to link
specific keys to specific devices like this, exactly for the reason of
identification.)

## Step 4: Generate a New Key

Adding a key to your XID always starts with its generation:

```
NEW_LAPTOP_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
NEW_LAPTOP_PUBKEYS=$(envelope generate pubkeys "$NEW_LAPTOP_PRVKEYS")
```

## Step 5: Add the New Key to Your XID

You can then add the key to Amira's XID with appropriate permissions:

```
XID_WITH_ROTATED_KEY=$(envelope xid key add \
    --verify inception \
    --nickname "laptop-key-v2" \
    --allow auth \
    --allow sign \
    --allow encrypt \
    --allow elide \
    --allow issue \
    --private encrypt \
    --encrypt-password "$PASSWORD" \
    "$NEW_LAPTOP_PRVKEYS" \
    "$XID_WITH_UPDATED_KEY")
```

## Step 6: Remove the Old Key from Your XID

Before you remove the old key from your XID, you should make sure you
have a full backup of the XID, in case there's a problem and you need
to revert.

Afterward, you need to find the key you want to remove, which is just
the same as when you found a key to change its permissions:

```
LAPTOP_PRVKEYS=$(envelope xid key find name --private --password "$PASSWORD" "laptop-key" $XID_WITH_ROTATED_KEY)
LAPTOP_PUBKEYS=$(envelope generate pubkeys $LAPTOP_PRVKEYS)
```

Then you remove it with the `envelope xid key remove` command:

```
FULLY_ROTATED_XID=$(envelope xid key remove "$LAPTOP_PUBKEYS" "$XID_WITH_ROTATED_KEY")
```

You at this point can verify that your old key was removed:

```
envelope format "$FULLY_ROTATED_XID" | grep -v "laptop-key-v2" | grep "laptop-key" || echo "✅ Old key removed"

| ✅ Old key removed
```

## Step 7: Verify Your XID Works

At this point, you should engage in the operational work that you
normally do with your XID, and verify that it still works. If there
was a problem, you'd need to step back to that backup copy you made of
your XID.

Generally, this procedure should be followed for any key rotation:

1. Generate new key
2. Add new key to XID
3. Find old key
4. Remove old key from XID
5. Verify old key was removed from XID
6. Verify XID still has needed permissions

## Step 8: Rotate Other Keys

It's best practice to link your GitHub SSH signing keys to individual
devices too, so you can always see what device a commit came from. The
process of linking a key to GitHub was described in
[§3.1](03_1_Creating_Edges/#step-1-generate-ssh-signing-key) and would
require rebuilding your GitHub edge, with
[§4.4](04_4_Creating_New_Editions/#part-iii-replacing-xid-objects)
demonstrating how to do so.

You might also want to link other keys such as attestation keys and
contract keys to specific machines. They could be rotated using the
exact same process described here.

We're going to leave the rest of Amira's keys the same, rather than
redundantly doing all of that work, but be aware that in the real
world it might be worthwhile to update them to maintain your security.

## Step 9: Update & Store (Again)

Just as with the permission update for your key, it's very important
to get this XID with the rotated key out to the public. Until you do,
that old key remains valid.

Here's the standard commands for doing so:
```
FULLY_ROTATED_XID=$(envelope xid provenance next \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$FULLY_ROTATED_XID")

PUBLIC_FULLY_ROTATED_XID=$(envelope xid export --private elide --generator elide "$FULLY_ROTATED_XID")
```

We're of course going to end by making some final stores:

```
echo "$NEW_LAPTOP_PRVKEYS" > envelopes/key-laptopv2-private-5-02.ur
echo "$NEW_LAPTOP_PUBKEYS" > envelopes/key-laptopv2-public-5-02.ur
echo "$FULLY_ROTATED_XID" > envelopes/BRadvoc8-xid-s10-private-5-02.envelope
echo "$PUBLIC_FULLY_ROTATED_XID" > envelopes/BRadvoc8-xid-s10-public-5-02.envelope
```

#### XID Version Comparison

XIDs will continue to grow and change over time. That's why provenance
marks are so important: out of this set of not-quite a dozen XIDs,
they reveal which one is the current one.

| XID Version | New Content | Created In |
|-------------|-------------|------------|
| seq 0 | 👤 Identity | §1.3+§1.4 |
| seq 1 | 🔑 Attestation Key | §2.1 |
| seq 2 | 🗣️ GitHub Edge | §3.1 |
| seq 3 | 🗣️ Endorsement Edge | §3.3 |
| seq 4 | 🔑 Contract Key | §4.1 |
| seq 5 | 📄 Contract Commitment | §4.2 |
| seq 6 | ❌ Endorsement Removal | §4.4 |
| seq 7 | 🗣️ Endorsement Replacement | §4.4 |
| seq 8 | 💻 Operational Keys | §5.1 |
| seq 9 | 💻 Laptop Key Change | §5.2 |
| seq 10 | 💻 Laptop Key Replacmeent | §5.2 |

## Summary: Updating Keys

XID keys can be updated in two ways: their permissions can be changed
and the key can be rotated. In both cases, it's important that your
XIDs contain a `dereferenceVia`, so that people always know where to
get the newest version of your XID, and that you publish an updated
XID promptly. Those are what's required to ensure that everyone knows
that your old keys have been changed. (Even then, changing the keys
isn't a guarante that everyone will respect that; you're depending on
the larger ecosystem following the same rules, but that's true of most
key rotations.)

### Additional Files

**Envelopes:** The
[envelopes](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/envelopes)
directory contains all the keys and updated XIDs from this section,
including the [newest
version](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/envelopes/BRadvoc8-xid-s10-private-5-02.envelope)
of Amira's XID.

**Scripts:** Forthcoming.

### Exercises

These exercises test your understanding of the permission model:

1. Change the permissions on a key in your XID.
2. Try to change permissions using an operational version of a XID.
3. Rotate a key in your XID.

## What's Next

In §5.1, we said you should backup your XID. [§5.3: Backing Up Your
Inception Key](05_3_Backing_up_Inception_Key.md) talks about how to do
so in a robust, resilient way.

## Appendix I: Key Terminology

> **Key Rotation** - Replacing an out-of-date key (possibly one that's been lost or compromised) with a new key.

> :brain: **Learn more.** The [Key Management](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/concepts/key-management.md) concept doc explains the full key hierarchy model and permission system.

## Appendix II: Common Questions

### Q: Do old signatures become invalid when I rotate keys?

**A:** No. Signatures made with an old key remain valid. The signature
proves the document was signed at a time when that key was
authorized. Rotation only affects new signatures. If you want to
invalidate old signatures (e.g., after a compromise), you need to
publicly disavow them.
