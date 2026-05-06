# 5.4: Backing Up Your SSH Key

Your house burns down. Your identity is safe because you backed up the
management version of your XID with SSKR. But what about those other
keys that you didn't keep in your XID?

> 🧠 **Related Concepts.** After completing this tutorial, explore
[Key
Management](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/concepts/key-management.md)
to understand the full key hierarchy model.

## Objectives of this Section

After working through this section, a developer will be able to:

- Convert SSH keys to URs
- Build meaningful metadata about secrets
- Store SSH keys as SSKR shares

Supporting objectives include the ability to:

- Understand the importance of backing up all keys

## Amira's Story: The Fragility of Detached Keys

Backing up your management XID is a great way to ensure that all of
the most important parts of your XID are protected. But, Amira chose
not to store everything in her XID. She has SSH keys that she uses for
GitHub that she maintained as "detached keys" rather than including
them in her XID.

Why would you do this?

- You might want to keep your XID lean.
- You might not want to constantly elide the SSH keys.
- You might have keys that you want to keep separate from your identity.

But losing those SSH keys could still be a problem. Amira would retain
control of her GitHub account, which would allow her to replace her
SSH keys. But there nonetheless would be a discontinuity where the key
used to sign commits was changed. Given that pseudonymous identity is
all about building trust over time, this would be a step backward.

## Part 0: Verify Dependencies

Before you get started, you should (as usual) check your
`envelope-cli` version:

```
envelope --version

│ bc-envelope-cli 0.34.1
```

... and this is where you'd reload your SSH keys, except we
purposefully didn't save Amira's SSH private keys because they're used
on the actual BRadvoc8 repo!

The following will create a new set of keys that emulate what you (and
Amira) might have sitting on your drive:

```
ssh-keygen -t ed25519 -f envelopes/key-github-signing-keys-5-04
```

(If you don't have `ssh-keygen` installed, you can skip ahead as
noted in Part I.)

## Part I: Converting an SSH File to a UR

The first step to storing your SSH key is to get it into a
standardized (UR) format.

### Step 1: (Three Ways to) Read In Your SSH Key

If you have your SSH key in SSH format, you can read it in with
`envelope import`.

```
SSH_PRVKEYS=$(cat envelopes/key-github-signing-keys-5-04 | envelope import)
```

If you have your SSH key in UR format, you can directly import it into
a variable:

```
SSH_PRVKEYS=$(cat your-envelope-file)
```

If you don't yet have a SSH key for this tutorial, you can create one:

```
SSH_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
```

One way or another, you should have either a `ur:signing-private-key`
or a `ur:crypto-prvkeys` in your `$SSH_PRVKEYS` variable at the end of
this step.

## Part II: Converting a Key into an Envelope

Theoretically, you could just use an SSKR implementation to split your
key. But the best practice is to store any key with metadata that
would aid in its recover at a future time, and that requires
incorporating the key into a Gordian Envelope.

### Step 2: Set Your Key as the Subject

Envelopes (when not heavily specified, as is the case with XIDs), are
quite freeform. We could save a key in any number of places within an
envelope. In this case, we're going to store it as the subject:

```
SSH_ENVELOPE=$(envelope subject type ur $SSH_PRVKEYS)
```

Here's what it looks like

```
$ envelope format $SSH_ENVELOPE

| SigningPrivateKey(7922a221, SSHPrivateKey(5e5df2c6))
```

### Step 3: Add Metadata about the Key

The reason that it's a best practice to store a key in an envelope
rather than as a bare UR is that you can add metadata, which could
help you (or possibly an heir or executor) to figure out what a key is
when they retrieve it.

```
GH_NAME="BRadvoc8"
SSH_ENVELOPE=$(envelope assertion add pred-obj string "keyType" string "signingKey" "$SSH_ENVELOPE")
SSH_ENVELOPE=$(envelope assertion add pred-obj known 'conformsTo' uri "https://github.com" "$SSH_ENVELOPE")
SSH_ENVELOPE=$(envelope assertion add pred-obj known 'verifiableAt' uri "https://api.github.com/users/$GH_NAME" "$SSH_ENVELOPE")
SSH_ENVELOPE=$(envelope assertion add pred-obj string accountName string "$GH_NAME" "$SSH_ENVELOPE")
```

Here's the key with all its metadata:

```
$ envelope format $SSH_ENVELOPE

| SigningPrivateKey(7922a221, SSHPrivateKey(5e5df2c6)) [
|     "accountName": "BRadvoc8"
|     "keyType": "signingKey"
|     'conformsTo': URI(https://github.com)
|     'verifiableAt': URI(https://api.github.com/users/BRadvoc8)
| ]
```

### Step 4: (Optional) Encrypt Your Key

At this point, you could chose to encrypt your key. It's not
technically necessary, because using SSKR to shard an envelope
provides cryptographic protection as well, and adding a key (or
password) on top that just creates a new Single Point of Failure
(SPOF), something that you're trying to avoid by using SSKR to protect
your key.

With that all said, if you choose to encrypt, a simple well-known
password is probably the answer to provide a tiny bit of additional
protection:
```
SSH_ENCRYPTED=$(envelope encrypt --password amira $SSH_ENVELOPE)
```

Note that this only encrypts the SSH key, not the metadata:

```
$ envelope format $SSH_ENCRYPTED

| ENCRYPTED [
|     "accountName": "BRadvoc8"
|     "keyType": "signingKey"
|     'conformsTo': URI(https://github.com)
|     'hasSecret': EncryptedKey(Argon2id)
|     'verifiableAt': URI(https://api.github.com/users/BRadvoc8)
| ]
```

This was the intent, and why Gordian Envelope is powerful: you can
hide secrets while maintaining metadata that helps to identify what
the secret is.

In fact, this same technique of creating metadata can be used to help
the future decryption of the envelope:

```
SSH_ENCRYPTED=$(envelope assertion add pred-obj string "encryptionPasswordhint" string "real first name" "$SSH_ENCRYPTED")
```

That'll show up with the rest of the metadata:
```
$ envelope format $SSH_ENCRYPTED

| ENCRYPTED [
|     "accountName": "BRadvoc8"
|     "encryptionPasswordhint": "real first name"
|     "keyType": "signingKey"
|     'conformsTo': URI(https://github.com)
|     'hasSecret': EncryptedKey(Argon2id)
|     'verifiableAt': URI(https://api.github.com/users/BRadvoc8)
| ]
```

(There still might be amiguity, like "Was the password 'amira' or
"Amira" or maybe even "Better World", but the point of a hint is to
give the user, or some other valid person, enough to figure it out,
even if it takes a few tries.)

## Part II: Creating a Backup

As with any SSKR distribution, you must create a [threshold
scheme](https://github.com/BlockchainCommons/SmartCustody/blob/master/Docs/SSKR-Sharing.md),
determining how many shares you're going make, what the threshold is
for reconstruction, and where to distribute them. But, you probably
already did this when you distributed your XID, and you'll just want
to shard and distribute your SSH key in the same way.

Which means that all is required is to use `envelope` to create your shares.

### Step 5: Split Your Key

This is the same process as in [§5.3](05_3_Backing_up_Inception_Key.md).

```
SHARES=$(envelope sskr split --group "2-of-3" "$SSH_ENCRYPTED")
SHARE_ARRAY=( $SHARES )

echo "✅ Created 3 shares (any 2 can recover):"
echo "  Share 1: ${SHARE_ARRAY[0]:0:50}..."
echo "  Share 2: ${SHARE_ARRAY[1]:0:50}..."
echo "  Share 3: ${SHARE_ARRAY[2]:0:50}..."

✅ Created 3 shares (any 2 can recover):
  Share 1: ur:envelope/lftansfwlrhkaxcmoxmdvldttpdmgtprhtosqd...
  Share 2: ur:envelope/lftansfwlrhkaxcmoxmdvldttpdmgtprhtosqd...
  Share 3: ur:envelope/lftansfwlrhkaxcmoxmdvldttpdmgtprhtosqd...
```

### Step 6: Test Recovery & Distribute

The last step is always to test your recovery:

```
DIGEST_OR=$(envelope digest $SSH_ENCRYPTED)
RECOVERED_12=$(envelope sskr join "${SHARE_ARRAY[0]}" "${SHARE_ARRAY[1]}")
RECOVERED_23=$(envelope sskr join "${SHARE_ARRAY[1]}" "${SHARE_ARRAY[2]}")
RECOVERED_13=$(envelope sskr join "${SHARE_ARRAY[0]}" "${SHARE_ARRAY[2]}")
DIGEST_12=$(envelope digest $RECOVERED_12)
DIGEST_23=$(envelope digest $RECOVERED_23)
DIGEST_13=$(envelope digest $RECOVERED_13)

if [ "$DIGEST_OR" = "$DIGEST_12" -a "$DIGEST_OR" = "$DIGEST_23" -a "$DIGEST_OR" = "$DIGEST_13" ]; then
    echo "✅ All share combinations verified"
else
    echo "❌ Additional recoveries failed - DO NOT proceed"
    exit 1
fi

| ✅ All share combinations verified
```

Then you can distribute.

As in the last chapter, we'll mimic this by storing copies:
```
echo "${SHARE_ARRAY[0]}" > "envelopes/BRadvoc8-sshkey-share1-safety-deposit-5-04.envelope"
echo "${SHARE_ARRAY[1]}" > "envelopes/BRadvoc8-sshkey-share2-charlene-5-04.envelope"
echo "${SHARE_ARRAY[2]}" > "envelopes/BRadvoc8-sshkey-share3-cloud-5-04.envelope"
```

## Summary: Backing Up Your SSH Key

You can also use SSKR to backup other keys that are not included in
your XID. The best practice for doing so is to create an envelope
containing the key and then fill that envelope with metadata that will
help you (or others) to recover the key at a future time.

### Additional Files

**Envelopes:** The
[envelopes](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/envelopes)
directory contains the keys and shares created in this exercise.

**Scripts:** Forthcoming.

### Exercises

These exercises test your understanding of SSKR security properties:

1. Create a SSH key.
2. Turn the SSH key into a UR.
3. Create an envelope containing the SSH key.
4. Think about what metadata would make it easier to use the SSH key in the future, if you had forgotten what it did.
5. Add a bit of metadata to your envelope.
6. Shard your envelope.

## What's Next

We've protected Amira's identity as best as possible, but what if the
worst occurs? We're going to close out this chapter with [§5.5:
Responding to Key Compromise](05_5_Responding_to_Key_Compromise.md).

## Appendix I: Key Terminology

> **Detached Keys**: Keys not stored in a XID.
>
> **Embedded Keys**: Keys stored in a XID.

