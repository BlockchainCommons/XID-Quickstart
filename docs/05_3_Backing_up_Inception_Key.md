# 5.3: Backing Up Your Inception Key

Your house burns down. Your laptop, your backup drive, and your phone
are all gone. If your inception key was only on those devices, your
identity is gone too. No one can help you recover it. This tutorial
shows how to prevent that catastrophe using SSKR (Sharded Secret Key
Reconstruction) and also discusses the power of an offline inception
key.

> 🧠 **Related Concepts.** After completing this tutorial, explore
[Key
Management](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/concepts/key-management.md)
to understand the full key hierarchy model.

## Objectives of this Section

After working through this section, a developer will be able to:

- Create SSKR backup shares
- Distribute shares safely

Supporting objectives include the ability to:

- Understand why inception keys need special protection

## Amira's Story: The Fragility of Identity

Amira is thrilled that she's now protecting her BRadvoc8 identity from
compromise by mainly using the operational version of her XID. But,
it's made her feel more paranoid about the inception key, since it's
now only in a single backup.

You might think: "I'll just make copies of my inception key and store
them in different places." But copies create copies of the risk: if
any copy is stolen, your identity is compromised.

Amira needs a more robust way to protect the backup of her full
XID. That's where SSKR comes in.

### The Power of SSKR

SSKR (Sharded Secret Key Reconstruction) splits a secret into multiple
shares using Shamir's Secret Sharing. 

- Any single share reveals nothing about the original.
- A threshold number of shares can reconstructs the original.

Common schemes for SSKR include 2-of-3, 3-of-5, 2-of-2, which
designate how many keys (a "threshold") are necessary to reconstruct a
key out of the total set.

> :book: **What is a threshold scheme?** A threshold scheme allows you
to recover original data from some subset of shares of that data.  A
"2-of-3" scheme means you create 3 shares and need only 2 to
recover. You can lose 1 share and still reconstruct your
key. Meanwhile, an attacker who steals 1 share learns nothing.

SSKR solves the two major problems with keys. It defeats the
single-point-of-compromise (SPOC) and the
single-point-of-failure. That is, it does as long as you create a
rational threshold scheme: a 1-of-1 scheme clearly does nothing, and a
2-of-2 scheme just multiplies the threat unless you redunantly backup
your shares. But a scheme like 2-of-3 or 3-of-5 can allow you to
reconstruct a key even if you lose some of your SSKR shares!

## Part 0: Verify Dependencies

Before you get started, you should (as usual) check your `envelope-cli` version:

```
envelope --version

│ bc-envelope-cli 0.34.1
```

Then, reload your XID. 

```
XID=$(cat envelopes/BRadvoc8-xid-s10-private-5-02.envelope)
XID_ID=$(envelope xid id $XID)
PASSWORD="your-password-from-previous-tutorials"
```

## Part I: Creating a Backup

SSKR is built into envelope, making it easy to back up your keys and
your full XIDs.

### Step 1: Design Your Threshold Scheme

The most important part of using SSKR may be figuring out your
threshold scheme. You need to decide:

1. How many shares to create.
2. How many shares will be necessary to reconstruct (the "threshold").
3. Where and how the shares will be store.

These decisions are all interrelated: you'll often decide how many
shares to create based on how many secure locations you have. It's
often good to have a threshold of 60% or 70% of that, so that you can
afford to lose a share or maybe more, but there you have to consider
how widely separated the shares are: you don't want to create a
situation where it's easy to combine enough shares to reconstruct your
secret and steal your XID!

Ultimately you want to think about context: how can you separate your
shares geographically (so that they're not all threatened by the same
physical disaster) and socially (so they're not easy to collect).

Amira decides that she can manage three different secure locations
that are geographically and socially distinct. This will allow her to
create a 2-of-3 SSKR share where she can lose one share and still
reconstruct her XID.

You also need to decide if you're creating a fully offline inception
key. In this model, you don't keep a singular copy of your inception
key (or rather your full, management XID, which contains your
inception key). Instead, whenever you need to manage your XID, you
reconstruct from your SSKR shares to do so. It's important to think
about this now, because having an offline inception key probably means
that you need to make it a little less cumbersome to reconstruct, and
that might affect where your shares are located and ultimately what
your threshold scheme is.

| Share | Location | Rationale |
|-------|----------|-----------|
| Share 1 | Safety deposit box | Secure, requires physical access |
| Share 2 | Charlene (trusted friend) | Geographic distribution, in-person recovery |
| Share 3 | Encrypted cloud backup | Accessible remotely if needed |

This distribution is robust because:

- Geographic distribution protects against local disasters
- No single location compromise reveals the key
- Charlene can help with in-person recovery
- 2-of-3 means losing one share is survivable

["Designing SSKR Sharing
Scenarios"](https://github.com/BlockchainCommons/SmartCustody/blob/master/Docs/SSKR-Sharing.md)
offers much more extensive discussions on planning out a robust SSKR
threshold scheme.

> 📖 **Are they shares or shards?** The most proper usage when talking
about SSKR is use "shard" as a verb and "share" as a noun. That is,
you "shard" a secret (a seed, a key, or in this case a XID) and that
produces "shares".

> 📖 **Is it reconstruct, recover, or restore?** Reconstruct is the
most precise verb to use when you're talking about gathering together
SSKR shares and using them to bring the original secret back into
existence. Recover is a more general verb for bringing back something
that's lost and restore is usually used as a verb for resurrecting
something from backup.

> 📖 **Is it SSKR or Shamir's Secret Sharing?** Shamir's Secret
Sharing is a general algorithm. SSKR is Blockchain Commons' specific
implementation of that algorithm, which also allows for multi-level
thresholds (e.g., the ability to reconstruct from a threshold of
groups each of which have a threshold of users).

### Step 2: Create Backup Shares

The command `envelope sskr split` allows you to shard any Gordian
Envelope, including a XID into a number of shares. You just give it
the `--group` flag, which allows you to define a threshold scheme.

```
SHARES=$(envelope sskr split --group "2-of-3" "$XID")
SHARE_ARRAY=( $SHARES )

echo "✅ Created 3 shares (any 2 can recover):"
echo "  Share 1: ${SHARE_ARRAY[0]:0:50}..."
echo "  Share 2: ${SHARE_ARRAY[1]:0:50}..."
echo "  Share 3: ${SHARE_ARRAY[2]:0:50}..."

| ✅ Created 3 shares (any 2 can recover):
|   Share 1: ur:envelope/lftansfwlrhkbwhyhpfscfleytrfmssgtdfwjn...
|   Share 2: ur:envelope/lftansfwlrhkbwhyhpfscfleytrfmssgtdfwjn...
|   Share 3: ur:envelope/lftansfwlrhkbwhyhpfscfleytrfmssgtdfwjn...
```

Each share is a complete envelope containing a fragment of the
full XID.

### Step 3: Prove One Share Is Useless

The `sskr join` command is used to reconstruct a Gordian Envelope from
shares. Trying it with just one share suggests that having a single
share is useless.

```
envelope sskr join "${SHARE_ARRAY[0]}" 2>&1 || echo "❌ Cannot recover with 1 share (as expected)"

| Error: invalid SSKR shares
| ❌ Cannot recover with 1 share (as expected)
```

This is the key security property: an attacker who stole one share of
Amira's SSKR from Charlene's house would learn nothing about your
inception key.

### Step 4: Test Recovery Before Distribution

Before you distribute your SSKR shares, you should always test them to
make sure that they really do allow you to reconstruct your XID (or
whatever other Gordian Envelope you sharded).

Based on the threshold scheme we designed for Amira, `envelope` should
be able to reconstruct the XID from any two out of three shares:

```
RECOVERED=$(envelope sskr join "${SHARE_ARRAY[1]}" "${SHARE_ARRAY[2]}")
```

The mere fact that the recovery works without errors is a good
sign. You could also use `envelope format` to look at it to see that
everything is there as expected.

One programmatic way to test your reconstruction is to compare the digest
of your original and recovered XID:

```
ORIGINAL_DIGEST=$(envelope digest "$XID")
RECOVERED_DIGEST=$(envelope digest "$RECOVERED")

if [ "$ORIGINAL_DIGEST" = "$RECOVERED_DIGEST" ]; then
    echo "✅ Recovery test passed (shares 1+2)"
else
    echo "❌ Recovery failed - DO NOT proceed"
    exit 1
fi
```

You should repeat this on all the combinations of two shares (1+2,2+3, and 1+3):
```
RECOVERED_23=$(envelope sskr join "${SHARE_ARRAY[1]}" "${SHARE_ARRAY[2]}")
RECOVERED_13=$(envelope sskr join "${SHARE_ARRAY[0]}" "${SHARE_ARRAY[2]}")
DIGEST_23=$(envelope digest $RECOVERED_23)
DIGEST_13=$(envelope digest $RECOVERED_13)

if [ "$ORIGINAL_DIGEST" = "$RECOVERED_DIGEST" -a "$ORIGINAL_DIGEST" = "$DIGEST_23" -a "$ORIGINAL_DIGEST" = "$DIGEST_13" ]; then
    echo "✅ All share combinations verified"
else
    echo "❌ Additional recoveries failed - DO NOT proceed"
    exit 1
fi

│ ✅ Recovery test passed (shares 1+2)
│ ✅ All share combinations verified
```

> ⚠️ **Test Before You Trust.** Always test recovery before
distributing shares or deleting the original. If something went wrong
during splitting, you want to know now—not when your house burns down.

## Part III: Distributing Shares

Since you've already planned your threshold scheme and sharded your
XID, distributing the shares is simple.

### Step 6: Save Shares

Obviously, command-line variables won't do the trick, you need to output your shares to files. Here, we've going to put them in our standard directory:

```
echo "${SHARE_ARRAY[0]}" > "envelopes/BRadvoc8-xid-share1-safety-deposit-5-03.envelope"
echo "${SHARE_ARRAY[1]}" > "envelopes/BRadvoc8-xid-share2-charlene-5-03.envelope"
echo "${SHARE_ARRAY[2]}" > "envelopes/BRadvoc8-xid-share3-cloud-5-03.envelope"
```

In practice, you might then do something like:

- Print share1, store in safety deposit box
- Give share2 to Charlene in person
- Encrypt share3, upload to cloud storage

> ⚠️ **Defense in Depth.** Even though each share alone reveals
> nothing, encrypt share3 before uploading to cloud storage. If SSKR
> ever had a vulnerability, your encrypted share would still be
> protected.

### Step 7: Take Your Management XID Offline

This would be the point where you could take your management XID (with
the inception key) offline with assurance, as was first suggested in
[§5.1](05_1_Generating_Operational_Keys.md). For the best security,
you don't even keep a copy yourself, you just reconstruct your XID
from the cloud and your safety deposit box shares if you ever want to
make changes.

#### How Much is Too Much?

[#SmartCustody](https://www.smartcustody.com/) lists many threats to
keys, one of which is "Process Fatigue": if a security process is too
complex, the user will give up on it, and so they'll lose the security.

Consider that when you're deciding what to do with your management
XID, with the inception key. You _definitely_ want to shard it and
store it remotely, because that protects against loss. But maybe you
decide that it's too much nuisance to reconstruct it every time you
want to manage your XID. In that case you might keep copies of the
shares locally, but offline, or you might keep the full XID locally
but offline, both allowing easy access while still providing
protection against compromise.

You need to find the security scenario that fits you: maximizing
protection against loss and against compromise, while still keeping
things simple enough that you're willing to go through the process,
and not abandon it entirely.

## Part IV: Reconstructing Your XID

At some point in the future, Amira decides she needs to make updates
to her XID. She does so by reconstructing the XID with the

### Step 8: Reconstruct Your Management XID

Reconstructing your XID at this point is easy: you've already done it
while testing! You just need to gather your shares (whichever two are
easiest to access), then use `envelope sskr join`. 

```
RECOVERED_13=$(envelope sskr join "${SHARE_ARRAY[0]}" "${SHARE_ARRAY[2]}")
```

### Step 9: Perform Management Operation

At this point, you can conduct new management operations, such as
adding a key for a new device.

### Step 10: Re-split & Go Offline Again

Here's the important step: afterward you need to make sure that go
through all of the usual rigamarole (advancing your provenance mark
and making a public version), but you should also go through the
security steps that you now use to keep your key safe:

1. Reshard your XID.
2. Redistribute the shares & make sure all sites remove the old shares.
3. Create a new operational XID by removing the inception key.

#### Key Type Comparison

The crucial change you've made here is that you've changed where the
inception key is in your bag of keys:

| Key Type | Purpose | Verified Against | Added In |
|----------|---------|------------------|----------|
| 👤 XID inception key | Signs XID document updates | SSKR Shares | §1.3,§5.1,§5.3 |
| 🗣️  Attestation key | Signs attestations | XID key list | §2.1 |
| 🖋️  SSH signing key | Signs Git commits | GitHub account | §3.1 |
| 📄️  Contract signing key | Signs contracts | XID key list | §4.1 |
| 💻 Laptop Key | Operational Key | XID key list | §5.1 |
| ⏏️ Portable Key | Limited Operational Key | XID key list | §5.1 |

This has created a hierarchy of keys:

- Inception key: Offline, split into 2-of-3 SSKR shares
- Operational keys: On devices, operation-only permissions

## Summary: Backing Up Your Inception Key

[§5.1](05_1_Generating_Operational_Keys.md) laid out the model of
removing your inception key from your XID as using an operational key
for day-to-day usage. But, you want to make sure your inception key is
safe. One of the best ways to do so is to maintain your off-line copy
of your inception key with SSKR, which allows you to shard it into
shares.

### Additional Files

**Envelopes:** The
[envelopes](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/envelopes)
directory contains the shares created in this exercise, if you want to
sample putting them back together.

**Scripts:** Forthcoming.

### Exercises

These exercises test your understanding of SSKR security properties:

1. Design a share distribution strategy for your own life. Consider:
trusted people, geographic diversity, accessibility during
emergencies, and what happens if relationships change.
2.Create a 3-of-5 scheme. Verify that 2 shares fail to recover but any
3 succeed. How many combinations are there?
3.Practice the complete cycle: split → distribute → reconstruct → add
a new key → re-split → redistribute. Time yourself: this is your
"identity recovery time."

## What's Next

We've protected Amira's identity as best as possible, but what is the
worst occurs? We're going to close out this chapter with [§5.4:
Responding to Key Compromise](05_4_Responding_to_Key_Compromise.md).

## Appendix I: Key Terminology

> **Key Hierarchy**: The structure of keys with different permission levels: inception keys control the identity, operational keys perform daily tasks.
>
> **Offline Inception Key**: An inception key that exists only in distributed SSKR shares, never on an active computer.
>
> **Reconstruct:** Rebuilding a secret from shares using SSKR.
>
> **Shard**: The act of splitting up a secret using SSKR.
>
> **Share**: A portion of a secret, split up by SSKR.
>
> **SSKR**: Sharded Secret Key Reconstruction, which supports splitting a secret into shares where a threshold can reconstruct it. It's built on the Shamir's Secret Sharing algorithm, with additional ability to reconstruct from a threshold of groups.
>
> **Threshold Scheme**: The number of shares required for reconstruction (e.g., 2-of-3 means any 2 of 3 shares can recover the secret).
>

> 🧠 **Learn More.** The [SSKR specification](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2020-011-sskr.md) explains the cryptographic details of Shamir's Secret Sharing and how SSKR extends it.

## Appendix II: Common Questions

### Q: Why not just encrypt the inception key and store copies?

**A:** Copies create copies of the risk. If you store encrypted copies
in three places and any one is breached (and the attacker cracks the
encryption), your identity is compromised. With SSKR, breaching one
location reveals nothing. That's mathematically nothing, not "hard to decrypt"
nothing.

### Q: What if Charlene loses her share?

**A:** With 2-of-3, you can still recover using shares 1 and 3 (safety
deposit + cloud). You should then create new shares and give Charlene
a replacement. The old shares are now useless since you've re-split.

### Q: What if I need to revoke a key while traveling?

**A:** This is the tradeoff of offline inception keys: emergency management
requires physical access to shares. If you travel frequently, consider
keeping one share in a location you can access remotely (like an
encrypted cloud backup) while ensuring the combination still requires
physical presence for at least one share.

### Q: Can I use 3-of-5 instead of 2-of-3?

**A:** Yes. 3-of-5 is more resilient (you can lose 2 shares) but
requires coordinating more locations. Choose based on your threat
model: how likely is loss vs. how likely is theft? More shares protect
against loss; higher thresholds protect against theft. See ["Designing
SSKR Share
Scenarios"](https://github.com/BlockchainCommons/SmartCustody/blob/master/Docs/SSKR-Sharing.md)
for more on different threshold scenarios.
