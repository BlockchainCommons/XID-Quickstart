# 5.5: Responding to Key Compromise

Your operational key is compromised. This tutorial shows how to
detect, revoke, and recover, proving that the key hierarchy developed
in this chapter works when it matters.

> 🧠 **Related Concepts.** After completing this tutorial, explore
[Key
Management](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/concepts/key-management.md)
to understand the full key hierarchy model.

## Objectives of this Section

After working through this section, a developer will be able to:

- Revoke a compromised operational key
- Recover and continue operations
- Disavow fradulent uses of a key

Supporting objectives include the ability to:

- Understand how to detect key compromise
- Recognize How the key hierarchy contains damage

## Amira's Story: A Key Attack

Amira is out of the country. One late afternoon, Charlene starts see
new peer endorsements signed by BRadvoc8's attestation key. She thinks
this is kind of weird, because it's the middle of the night where
Amira is ... but maybe she has jetlag. And the endorsements look
official because they're being published alongside an elided version
of Amira's XID.

But then Amira messages Charlene and lets her friend know that her
laptop was grabbed in a café where she'd been working. Charlene
immediately tells Amira about the endorsements, and Amira verifies
that she didn't even have her laptop when the endorsements were
published. Though Amira's XID always has all of its keys encrypted,
she suspects someone must have spied the password she uses to unlock
it, either through the café's wifi or visiual spying; working in
public always has its dangers!

That means they have complete access to her XID.

### The Power of Hierarchy

Fortunately, Amira is now following the best practice of using an
Operational View of her XID. In particular, she was using the Portable
View of her XID, which only contained her three least powerful keys:
her `attestation-key`, her `contract-key`, and her
`portable-key`. Unfortunately, the attacker can use any of the three
keys to `sign` (as they have been), they can use `auth` permissions to
log in to RISK (which accepts XID logins), and they can access a few
other resources that Amira has permissioned with her XID.

Fortunately, they can't manipulate the XID itself, nor can they even
access the full array of operational capabilities, because Amira
minimized the impact of loss while she was out of the country. (She
now wishes that she'd removed the `attestation-key` and `contract-key`
too, not because they give more permissions, but because they will
need to be rotated.)

**What the Attacker Could Do:**

| Action | Possible? | Why |
|--------|-----------|-----|
| Sign attestations | Yes | attestation-key present |
| Sign contracts | Yes | contract-key present |
| Impersonate temporarily | Yes | `sign` permissions present |
| Login to XID services | Yes |  `auth` permissions present |

**What the Attacker Could Not Do:**

| Action | Possible? | Why |
|--------|-----------|-----|
| Add their own key | No | No `elect` permission |
| Remove Amira's keys | No | No `revoke` permission |
| Lock Amira out | No | Inception key not on device |
| Access SSKR shares | No | Distributed offline |
| Sign commits | No | SSH key separately encrypted |

Though Amira will be able to recover her XID, this is still a big
problem: if Amira doesn't control the problem quickly, the trust she's
carefully created for her pseudonymous identity could be destroyed, as
it's now being used to endorse accounts that are then used for scams.

### How Do You Detect a Compromise?

Charlene was able to detect this compromise because she knew that
Amira was out of town. That meant that she was keeping an extra eye
out, because she recognized Amira was more vulnerable than
usual. Revealing information like that to trusted friends is probably
the best way to make a compromise detectable.

That's because compromise is often detected through behavioral
anomalies, not cryptographic failures. Signatures and authentication
are valid because the attacker has the real keys. So instead you have
to look for unusual commit times, unexpected code changes, activity
during known offline periods, incorrect use of keys, or stakeholder
alerts.

Beyond that, the detection of compromise will depend on how the
digital identifier ecosystem evolves. We should be thinking about
creating ways to notify users when a new endorsement is created with
their signature or when their auth accesses a new site. This type of
notification could be supported by notification links within a XID
itself; we just have to decide they're priorities and specify them.

## Step 0: Setting Up Your Workspace

Before you get started, you should check your `envelope-cli` version:

```
envelope --version

│ bc-envelope-cli 0.34.1
```

We're not loading a XID because Amira doesn't have her XID due to the
theft! All she has at the moment is the (probably compromised)
password that she can use to unlock her XID.

```
PASSWORD="your-password-from-previous-tutorials"
```
## Part I: Reconstructing a Management XID

To recover from a attack on your Operational XID, the first thing you
have to do is reconstruct your Management XID, which gives you the
ability to rotate your keys, so that you can replace compromised keys
with new ones.

This should typically be done as soon as possibly, as the longer
someone has control of your identity, the worse the damage might be.
Amira immediately buys a new laptop and then begins this process.

### Step 1: Collect the Shares

Amira really doesn't want to reconstruct her management XID while out
of country, but she has little choice: the danger of letting her
compromised XID remain in use is worse than the danger of her
Management XID being stolen. (She just won't take it out to a café!)

She needs two shares to reconstruct.  She pulls the first one down
from the cloud:

```
SHARE1=$(cat envelopes/BRadvoc8-xid-share3-cloud-5-03.envelope)
```

She then asks Charlene for her other share.

Charlene actually has to think about this. She had suspected that
Amira's pseudonymous identity was compromised, then she got a message
from Amira confirming. But what if it's a scam? Or the attacker is now
masquerading as Amira?

As a result, Charlene initiates contact with Amira at a known-good
access point (her phone number) and gets verbal confirmation that it's
Amira asking for the share. (This is generally a best practice when
helping someone reconstruct their identity: initiate the contact, talk
to them verbally or by video, and in the age of LLM fraud, also ask
them a few questions that wouldn't be in an AI script.) Afterward,
Charlene and Amira arrange a secure way to get Amira the share.

```
SHARE2=$(cat envelopes/BRadvoc8-xid-share2-charlene-5-03.envelope)
```

### Step 2: Reconstruct the Management XID

Amira can now reconstruct her Management XID with a simple `join` command.

```
XID=$(envelope sskr join $SHARE1 $SHARE2)
XID_ID=$(envelope xid id $XID)
```

### Step 3: Verify the Management XID


Before doing any serious work, Amira needs to make sure her
reconstructed XID is as expected.

She looks it over, and it all seems to be in order:


```
{
    XID(5f1c3d9e) [
        'dereferenceVia': URI(https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt)
        'edge': {
            "account-credential-github" [
                'isA': "foaf:OnlineAccount"
                'source': XID(5f1c3d9e)
                'target': XID(5f1c3d9e) [
                    "foaf:accountName": "BRadvoc8"
                    "foaf:accountServiceHomepage": URI(https://github.com/BRadvoc8/BRadvoc8)
                    "sshSigningKey": SigningPublicKey(c75b2f19, SSHPublicKey(b3e7a8b0))
                    "sshSigningKeyText": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiOtuf9hwDBjNXyjvjHMKeLQKyzT8GcH3tLvHNKrXJe BRadvoc8@Mac.attlocal.net"
                    "sshSigningKeysURL": URI(https://api.github.com/users/BRadvoc8/ssh_signing_keys)
                    'conformsTo': URI(https://github.com)
                    'date': "2026-03-18T11:55-10:00"
                    'verifiableAt': URI(https://api.github.com/users/BRadvoc8)
                ]
            ]
        } [
            'signed': Signature(SshEd25519)
        ]
        'edge': {
            "peer-endorsement-from-devreviewer-41c9a6d1b1a2ef96" [
                'isA': "attestation"
                'source': XID(6ab29708) [
                    "schema:employeeRole": "Head Security Programmer"
                    "schema:worksFor": "SisterSpaces"
                ]
                'target': XID(5f1c3d9e) [
                    "endorsementContext": "Verfied previous experience, worked together on short project for SisterSpaces"
                    "endorsementScope": "Security architecture, cryptographic implementation, privacy patterns"
                    "peerEndorsement": "Writes secure, well-tested code with clear attention to privacy-preserving patterns"
                    "relationshipBasis": "Security collaboration partner who verified credentials through commit-reveal and encrypted sharing"
                    'date': "2026-04-01T08:25-10:00"
                ]
            ]
        } [
            'signed': Signature(Ed25519)
        ]
        'edge': {
            "project-sister-spaces-secureauth" [
                'isA': "foaf:Project"
                'source': XID(5f1c3d9e)
                'target': XID(5f1c3d9e) [
                    "claDigest": Digest(cb26376e)
                    "foaf:Project": "SisterSpaces"
                    'verifiableAt': "https://github.com/SisterSpaces/SecureAuth/CLAs/README.md"
                ]
            ]
        } [
            'signed': Signature(Ed25519)
        ]
        'key': PublicKeys(36b0bca4, SigningPublicKey(6022bc69, Ed25519PublicKey(85517cd9)), EncapsulationPublicKey(cf752e51, X25519PublicKey(cf752e51))) [
            {
                'privateKey': ENCRYPTED [
                    'hasSecret': EncryptedKey(Argon2id)
                ]
            } [
                'salt': Salt
            ]
            'allow': 'Authorize'
            'allow': 'Elide'
            'allow': 'Encrypt'
            'allow': 'Issue'
            'allow': 'Sign'
            'nickname': "laptop-key-v2"
        ]
        'key': PublicKeys(57f4126d, SigningPublicKey(e15ac4c2, Ed25519PublicKey(a4893d82)), EncapsulationPublicKey(49ad97ce, X25519PublicKey(49ad97ce))) [
            {
                'privateKey': ENCRYPTED [
                    'hasSecret': EncryptedKey(Argon2id)
                ]
            } [
                'salt': Salt
            ]
            'allow': 'Sign'
            'nickname': "contract-key"
        ]
        'key': PublicKeys(6d94a1eb, SigningPublicKey(128ffa82, Ed25519PublicKey(363eab4e)), EncapsulationPublicKey(e46036f9, X25519PublicKey(e46036f9))) [
            {
                'privateKey': ENCRYPTED [
                    'hasSecret': EncryptedKey(Argon2id)
                ]
            } [
                'salt': Salt
            ]
            'allow': 'Sign'
            'nickname': "attestation-key"
        ]
        'key': PublicKeys(a9818011, SigningPublicKey(5f1c3d9e, Ed25519PublicKey(b2c16ea3)), EncapsulationPublicKey(96209c0f, X25519PublicKey(96209c0f))) [
            {
                'privateKey': ENCRYPTED [
                    'hasSecret': EncryptedKey(Argon2id)
                ]
            } [
                'salt': Salt
            ]
            'allow': 'All'
            'nickname': "BRadvoc8"
        ]
        'key': PublicKeys(d930b267, SigningPublicKey(5f6630d7, Ed25519PublicKey(d72a49de)), EncapsulationPublicKey(ae36f917, X25519PublicKey(ae36f917))) [
            {
                'privateKey': ENCRYPTED [
                    'hasSecret': EncryptedKey(Argon2id)
                ]
            } [
                'salt': Salt
            ]
            'allow': 'Access'
            'allow': 'Authorize'
            'allow': 'Elide'
            'allow': 'Sign'
            'nickname': "portable-key"
        ]
        'provenance': ProvenanceMark(cdff792b) [
            {
                'provenanceGenerator': ENCRYPTED [
                    'hasSecret': EncryptedKey(Argon2id)
                ]
            } [
                'salt': Salt
            ]
        ]
    ]
} [
    'signed': Signature(Ed25519)
]
```

She double-checks her provenance mark, to make sure it's version 10:

```
provenance validate $(envelope xid provenance get $XID)

| Error: Validation failed with issues:
| Total marks: 1
| Chains: 1
| 
| Chain 1: 61a8fa60
|   Warning: No genesis mark found
|   10: cdff792b
```

Finally, she checks the signature:
```
KEY_INCEPTION=$(envelope xid key find inception --private --password $PASSWORD $XID)
KEY_INCEPTION_PUBLIC=$(envelope generate pubkeys "$KEY_INCEPTION")
envelope verify -v "$KEY_INCEPTION_PUBLIC" "$XID" >/dev/null && echo "✅ Signature verified"

| ✅ Signature verified
```

All looks in order, so Amira can get to work. 

## Part II: Rebuilding a Compromised XID

Amira now needs to update her XID. That means that she needs to rotate
all of her compromised keys: removing the old keys and replacing them
with new ones. When she publishes her new XID, this will offer
implicit revocation of the compromised keys.

### Step 4: Revoke the Compromised Keys

Amira knows that her `attestation-key` and `portable-key` were
compromised, because the `attestation-key` was used to sign fraudulent
endorsements and the `portable-key` was used to access services. She
hasn't seen any use of her `contract-key`, but it was there on her
stolen laptop, so obviously she should rotate it as well.

To start with, she lists out all three keys, for each one recording
the `'key'` assertion, its digest, the private key, and the public
key. (She'll want to hold on to these variables, because some of this
data will be useful for the disavowal, later.)


```
ATTESTATION_ASSERTION=$(envelope xid key find name "attestation-key" "$XID")
ATTESTATION_DIGEST=$(envelope digest "$ATTESTATION_ASSERTION")
ATTESTATION_PRVKEYS=$(envelope xid key find name --private --password "$PASSWORD" "attestation-key" "$XID")
ATTESTATION_PUBKEYS=$(envelope generate pubkeys "$ATTESTATION_PRVKEYS")

CONTRACT_ASSERTION=$(envelope xid key find name "contract-key" "$XID")
CONTRACT_DIGEST=$(envelope digest "$CONTRACT_ASSERTION")
CONTRACT_PRVKEYS=$(envelope xid key find name --private --password "$PASSWORD" "contract-key" "$XID")
CONTRACT_PUBKEYS=$(envelope generate pubkeys "$CONTRACT_PRVKEYS")

PORTABLE_ASSERTION=$(envelope xid key find name "portable-key" "$XID")
PORTABLE_DIGEST=$(envelope digest "$PORTABLE_ASSERTION")
PORTABLE_PRVKEYS=$(envelope xid key find name --private --password "$PASSWORD" "portable-key" "$XID")
PORTABLE_PUBKEYS=$(envelope generate pubkeys "$PORTABLE_PRVKEYS")
```

Now Amira can remove the three keys from her XID using the process
from [§5.2](05_2_Updating_Keys.md).


```
KEYLESS_XID=$(envelope xid key remove "$ATTESTATION_PUBKEYS" "$XID")
KEYLESS_XID=$(envelope xid key remove "$CONTRACT_PUBKEYS" "$KEYLESS_XID")
KEYLESS_XID=$(envelope xid key remove "$PORTABLE_PUBKEYS" "$KEYLESS_XID")
```

Examining her `KEYLESS_XID`, Amira verifies that the only keys left
are her `laptop-key` and her inception key, neither of which was in
the Operational XID that she had on her laptop.

```
envelope format $KEYLESS_XID | grep -e portable-key -e attestation-key -e contract-key || echo "✅ Compromised keys removed"

| ✅ Compromised keys removed
```

> ⚠️ **Signatures Remain Valid.** Removing a key from your XID doesn't
retroactively invalidate signatures made with that key. Those
signatures were valid when made. What revocation does is signal to
verifiers: "Don't trust new signatures from this key." Always publish
your updated XID promptly after revocation.

> 📖 **The Time Window Problem.** Between compromise and new
publication, the attacker could sign anything. Those signatures are
permanently valid. This is why fast detection matters, and why you may
need to publicly disavow signatures from the compromise window.

### Step 5: Replace Compromised Keys

Amira now needs to replace all those keys.

First, she creates the keys and sets a new password for encrypting
everything (since she suspects that was compromised too):

```
NEW_ATTESTATION_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
NEW_PORTABLE_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
NEW_CONTRACT_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
NEW_PASSWORD="new-noncompromised-password"
```

Then she adds her three new keys to her XID, registering the same
permissions as previous. The first time, she decrypts everything from
her old `$PASSWORD`, and from there on she uses her `$NEW_PASSWORD`
for decryption and encryption.

```
REKEYED_XID=$(envelope xid key add \
    --nickname "attestation-key-may2026" \
    --allow sign \
    --private encrypt \
    --password "$PASSWORD" \
    --encrypt-password "$NEW_PASSWORD" \
    "$NEW_ATTESTATION_PRVKEYS" \
    "$KEYLESS_XID")

REKEYED_XID=$(envelope xid key add \
    --nickname "contract-key-may2026" \
    --allow sign \
    --private encrypt \
    --password "$PASSWORD" \
    --encrypt-password "$NEW_PASSWORD" \
    "$NEW_CONTRACT_PRVKEYS" \
    "$REKEYED_XID")

REKEYED_XID=$(envelope xid key add \
    --nickname "portable-key-may2026" \
    --allow auth \
    --allow sign \
    --allow elide \
    --allow access \
    --private encrypt \
    --encrypt-password "$NEW_PASSWORD" \
    "$NEW_PORTABLE_PRVKEYS" \
    "$REKEYED_XID")
```

Finally, she verifies everything went into her updated XID. Sure enough, she has three new entries:

```
envelope format $REKEYED_XID | grep -e '-key-may2026'

|         'nickname': "attestation-key-may2026"
|         'nickname': "portable-key-may2026"
|         'nickname': "contract-key-may2026"
```

### Step 6: Advance Provenance and Re-Publish

It's vitally important to publish a new XID at this point, so that
anyone dereferencing Amira's XID (as they should) will see the updated
XID with the updated keys. This follows the usual pattern.

```
REKEYED_XID=$(envelope xid provenance next \
    --password "$NEW_PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$NEW_PASSWORD" \
    "$REKEYED_XID")
    
PUBLIC_REKEYED_XID=$(envelope xid export --private elide --generator elide "$REKEYED_XID")
```

As soon as the public XID goes onto GitHub, validators will start
seeing the updates.

We'll of course save everything at this point:

```
echo "$NEW_ATTESTATION_PRVKEYS" > envelopes/key-attestationv2-private-5-05.ur
echo "$NEW_CONTRACT_PRVKEYS" > envelopes/key-contractv2-private-5-05.ur
echo "$NEW_PORTABLE_PRVKEYS" > envelopes/key-portablev2-private-5-05.ur
echo "$REKEYED_XID" > envelopes/BRadvoc8-xid-private-5-05.envelope
echo "$PUBLIC_REKEYED_XID" > envelopes/BRadvoc8-xid-public-5-05.envelope
```

### Step 7: Re-Create Operational XID

Though Amira temporarily reconstructed her Management XID, she wants
to maintain security by returning to the use of her Operational XID
... because it's already proven useful once.

After double-checking the copy she just made of her Management XID,
Amira elides her inception key and her laptop key from her Operational XID.

```
INCEPTION_PRVKEYS=$(envelope xid key find inception "$REKEYED_XID")
INCEPTION_DIGEST=$(envelope digest "$INCEPTION_PRVKEYS")
OPERATIONAL_XID=$(envelope elide removing "$INCEPTION_DIGEST" "$REKEYED_XID")

LAPTOP_PRVKEYS=$(envelope xid key find name "laptop-key-v2" "$REKEYED_XID")
LAPTOP_DIGEST=$(envelope digest "$LAPTOP_PRVKEYS")
OPERATIONAL_XID=$(envelope elide removing "$LAPTOP_DIGEST" "$OPERATIONAL_XID")
```

She now once more has an Operational XID that does not include her
inception key (or her laptop key, which she isn't using while out of
country).

```
echo "$OPERATIONAL_XID" > envelopes/BRadvoc8-xid-operational-5-05.envelope
```

### Step 8: Re-Shard Management XID

Creating an Operational XID doesn't do a lot of good if Amira keeps
that full copy of her Management XID on her computer. She can use SSKR
to split it using the same commands she used in
[§5.3](05_3_Backing_up_Inception_Key.md).

```
SHARES=$(envelope sskr split --group "2-of-3" "$OPERATIONAL_XID")
SHARE_ARRAY=( $SHARES )

echo "✅ Created 3 shares (any 2 can recover):"
echo "  Share 1: ${SHARE_ARRAY[0]:0:50}..."
echo "  Share 2: ${SHARE_ARRAY[1]:0:50}..."
echo "  Share 3: ${SHARE_ARRAY[2]:0:50}..."
```

At this point, Amira encrypts one share and puts it in the cloud and
sends the other to Charlene via their newly agreed-upon communication
channel.

She should deliver the third to her safety deposit box, but she can't
right now because she's out-of-country, so she keeps it on her
drive. It should be safe because it's the only share on the device;
even if someone got it, they couldn't do anything without being able
to recover one of the others.

After making very sure that Charlene received her share and that the
others are stored correctly, Amira deletes her copy of the complete
Management XID.

She's now back in a secure state again: her compromised keys are
rotated, her compromised passwords are changed, and she's back to
using her Operational XID.

#### XID Version Comparison

Another day, another XID update.

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
| seq 10 | 💻 Laptop Key Replacment | §5.2 |
| seq 11 | ☣️ Compromised Key Replacement | §5.5 |

Amira is now regularly making three views of each edition: private,
operational, and public.

## Part III: Disavowing False Statements

There's one problem left: what does Amira do with the endorsements
that were signed when her keys were compromised? There's actually no
way to mechanically take them back, because the keys were valid when
they signed, but she can create a disavowal statement with her new,
trusted keys.

This is similar to the discussions of
[retractions](02_1_Creating_Self_Attestations/#step-15-retract-an-attestation)
in §2.1, but at a larger scale.

### Step 9: Create a Disavowal Statement

Amira creates a signed statement disavowing any signatures made during
the compromise window.  She does this using the same standardized
format as an edge, per [§3.1](03_1_Creating_Edges.md), though she
currently is chosing not to put it in her XID. (She could at a latter
time if the problem turns out to be bigger than she currently
realizes).

First she creates the attestation itself, which per the standards for
an edge will become the `target`:

```
DISAVOWAL=$(envelope subject type ur "$XID_ID")
DISAVOWAL=$(envelope assertion add pred-obj string "disavowalStatement" string "Disavowing signatures from three keys on 2026-05-05 and 2026-05-06" "$DISAVOWAL")
DISAVOWAL=$(envelope assertion add pred-obj string "disavowalReason" string "Key compromise: unauthorized access" "$DISAVOWAL")
DISAVOWAL=$(envelope assertion add pred-obj known 'date' string `date -Iminutes` "$DISAVOWAL")
```

Then she lists out each of the keys:

```
KEY1=$(envelope subject type ur "$ATTESTATION_PUBKEYS")
KEY1=$(envelope assertion add pred-obj known 'nickname' string "attestation-key" "$KEY1")
KEY1=$(envelope assertion add pred-obj string "xidKeyDigest" digest "$ATTESTATION_DIGEST" "$KEY1")

KEY2=$(envelope subject type ur "$CONTRACT_PUBKEYS")
KEY2=$(envelope assertion add pred-obj known 'nickname' string "contract-key" "$KEY2")
KEY2=$(envelope assertion add pred-obj string "xidKeyDigest" digest "$CONTRACT_DIGEST" "$KEY2")

KEY3=$(envelope subject type ur "$PORTABLE_PUBKEYS")
KEY3=$(envelope assertion add pred-obj known 'nickname' string "portable-key" "$KEY3")
KEY3=$(envelope assertion add pred-obj string "xidKeyDigest" digest "$PORTABLE_DIGEST" "$KEY3")
```

Using Gordian Envelope's power of recursion, she can then add this key information to the disavowal attestation:

```
DISAVOWAL=$(envelope assertion add pred-obj string "disavowedKey" envelope "$KEY1" "$DISAVOWAL")
DISAVOWAL=$(envelope assertion add pred-obj string "disavowedKey" envelope "$KEY2" "$DISAVOWAL")
DISAVOWAL=$(envelope assertion add pred-obj string "disavowedKey" envelope "$KEY3" "$DISAVOWAL")
```

Finally, she forms this into a standard edge structure, with a unique
subject, as well as an `isA`, a `source`, and a `target`.

```
DISAVOWAL_EDGE=$(envelope subject type string "disavowal-statement-20260505")
DISAVOWAL_EDGE=$(envelope assertion add pred-obj known 'isA' string "signature-disavowal" "$DISAVOWAL_EDGE")
DISAVOWAL_EDGE=$(envelope assertion add pred-obj known 'source' ur "$XID_ID" "$DISAVOWAL_EDGE")
DISAVOWAL_EDGE=$(envelope assertion add pred-obj known 'target' envelope "$DISAVOWAL" "$DISAVOWAL_EDGE")
```

Amira closes things out by wrapping and signing her self-attestation:

```
DISAVOWAL_WRAPPED=$(envelope subject type wrapped "$DISAVOWAL_EDGE")
DISAVOWAL_SIGNED=$(envelope sign --signer "$NEW_ATTESTATION_PRVKEYS" "$DISAVOWAL_WRAPPED")
```

Here's what the final result looks like:

```
envelope format $DISAVOWAL_SIGNED

| {
|     "disavowal-statement-20260505" [
|         'isA': "signature-disavowal"
|         'source': XID(5f1c3d9e)
|         'target': XID(5f1c3d9e) [
|             "disavowalReason": "Key compromise: unauthorized access"
|             "disavowalStatement": "Disavowing signatures from three keys on 2026-05-05 and 2026-05-06"
|             "disavowedKey": PublicKeys(57f4126d, SigningPublicKey(e15ac4c2, Ed25519PublicKey(a4893d82)), EncapsulationPublicKey(49ad97ce, X25519PublicKey(49ad97ce))) [
|                 "xidKeyDigest": Digest(64663f52)
|                 'nickname': "contract-key"
|             ]
|             "disavowedKey": PublicKeys(6d94a1eb, SigningPublicKey(128ffa82, Ed25519PublicKey(363eab4e)), EncapsulationPublicKey(e46036f9, X25519PublicKey(e46036f9))) [
|                 "xidKeyDigest": Digest(aecc4681)
|                 'nickname': "attestation-key"
|             ]
|             "disavowedKey": PublicKeys(d930b267, SigningPublicKey(5f6630d7, Ed25519PublicKey(d72a49de)), EncapsulationPublicKey(ae36f917, X25519PublicKey(ae36f917))) [
|                 "xidKeyDigest": Digest(a25e7a3e)
|                 'nickname': "portable-key"
|             ]
|             'date': "2026-05-06T13:22-10:00"
|         ]
|     ]
| } [
|     'signed': Signature(Ed25519)
| ]
```

Unless Amira decides to add this to her XID as an edge, she can
publish it in her GitHub repo, right next to the XID itself.

## Step 10: Revisit Old Signatures

This isn't necessarily the end of the story. As we've seen, dates are
a problem in attestations because they're usually self-attested. Even
if the attackers made all of their fake endorsements with real dates
set to May 5th and 6th, they might go back and create new endorsements
in the future with older dates.

This means that _anything_ Amira signed using the revoked keys is in
doubt unless it had a third-party timestamp that provably puts it
outside the disavowal window.

Though Amira doesn't need to worry about it while out of town, longer
term she should revisit old signatures she made with these keys, and
either (1) verify they had a third-party timestamp that put them
outside of the revocation window; (2) verify that a provenance mark
placed them before the recovation; or (3) reissue them.

Looking through her previous signatures:

1. The self-attestations that Amira made in [chapter
2](02_0_Claims.md) should probably be redone, though they're less
important because they were made about herself and some of them were
publicly committed to, which created a timestamp.
2. The edges that Amira created in [chapter 3](03_0_Edges.md) are all
fine, because they're in Amira's XID with provenance marks predating
the change of the keys ... but Amira might want to change them anyway
so that their signatures match keys now present in her XID. Otherwise,
the validator has to dig back through her XID to prove the signatures
were valid at the time they were added to the XID. (But an automated validator should take care of that!)
3. The CLA that Amira signed in
[§4.1](04_1_Creating_Binding_Agreements.md) is fine because Ben
created a public commitment of the contract, dating it with a GitHub
commit.
4. Any detached endorsements that Amira made for other people should
be redone, as Amira doesn't know if they've timestamped them in some
way or not.

#### The Power of Key Hierarchy

Amira had to put in a fair amount of work to respond to the compromise
of her operational XID, but ultimately, her security model worked, and
her identity survived.

| Component | Role in Recovery |
|-----------|-----------------|
| Inception key offline | Prevented attacker from taking over identity |
| Operational key limits | Ensured attacker could only sign and auth, not manage |
| SSKR shares | Enabled inception key reconstruction |
| Charlene's share | Permitted recovery through trusted friend |

Without this setup:

- The attacker could add their own key with full permissions.
- The attacker could remove all of Amira's keys.
- All endorsements, attestations, and reputation would be lost.
- Amira would need to start over with a new XID.

The key hierarchy prevented this. Amira lost a few operational keys,
and created some issues with past signatures, but kept her identity.

Some lessons learned include:

- **Preparation matters.** The key hierarchy and SSKR distribution enabled quick recovery.
- **Damage was contained**: The attacker could access and sign things but couldn't branch the identity or destroy Amira's reputation.
- **Web of trust helped**: Charlene's relationship with Amira helped identify the issue and enabled trusted recovery.
- **Identity is resilient**: When properly structured, a compromise is a setback, not a catastrophe.

#### Amira's Recovery Checklist

After a compromise, Amira:

1. ✅ Detected compromise (Charlene's helped.)
2. ✅ Reconstructed inception key from SSKR shares.
3. ✅ Revoked compromised operational keys.
4. ✅ Added new operational keys.
5. ✅ Advanced provenance to signal update.
6. ✅ Published updated XID to `dereferenceVia` locations
7. ✅ Re-split Management XID into new SSKR shares.
8. ✅ Produced new Operational XID without excess keys.
9. ✅ Removed the full Management XID from her drive.
10. ✅ Created and published disavowal statement

## Summary: Responding to Key Compromise

The compromise of your XID is definitely a bad thing. But, if you've
planned ahead, it's not a disaster. The simple use of a password to
protect your keys through encryption may be enough, but it's good to
have a second layer of security on top of that by regularly using an
Operational XID that doesn't contain your management (inception) key,
especially if you're working outside of your home or office.

You'll have to do some work rebuilding your keys and you may need to
rebuild endorsements and attestations afterward, but your identity
will be recoverable.

### Additional Files

**Envelopes:** The
[envelopes](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/envelopes)
directory contains all the keys and updated XIDs from this section,
including the [newest
version](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/envelopes/BRadvoc8-xid-private-5-05.envelope)
of Amira's XID.

**Scripts:** The
[scripts](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/scripts)
directory contains
[05_5_Responding_to_Key_Compromise-SCRIPT.sh](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/scripts/05_5_Responding_to_Key_Compromise-SCRIPT.sh),
which runs through all the commands in this section. From the command
line, `git clone
https://github.com/BlockchainCommons/XID-Quickstart.git`, then `cd
XID-Quickstart`, then `bash
scripts/05_5_Responding_to_Key_Compromise-SCRIPT.sh` to test it.

### Exercises

1. Simulate both laptop and portable drive compromised
simultaneously. Can you still recover with your share distribution
strategy?
2. Write a step-by-step checklist for your own identity, with specific
share locations, contact methods for share holders, and notification
list for stakeholders.
3. Practice the full reconstruction cycle (retrieve shares →
reconstruct → revoke old key → add new key → re-split → redistribute →
disavow). How long does it take? Where are the bottlenecks?
4. Think about what happens if an attacker had a management key. If
both you and the attacker issued a new edition of your XID, how would
people know which was valid?
5. Now consider how the validation problem might be worse if your XID
also contained your GitHub commit (signing) key.

## What's Next

This is currently the end of the course, though we may author new
chapters in the future on `attachments` or other XID features that
require more ecosystem support.

## Appendix I: Key Terminology

> **Damage Containment**: The principle that compromising a low-permission key should not escalate to identity takeover.
>
> **Implicit Revocation**: Removing content that was in previous versions of a XID from a new version.
>
> **Key Revocation**: Removing a compromised key from an XID, preventing future use while maintaining identity continuity.
>
> **Recovery**: The process of regaining control after compromise, enabled by offline inception keys and SSKR shares.

## Appendix II: Common Questions

### Q: What if the attacker already signed something malicious?

**A:** Those signatures are valid: the key was legitimate when it
signed. You can't cryptographically invalidate them. What you can do
is: (1) publicly disavow the signatures with a signed statement from
your inception key, (2) remove the compromised key from your XID so
verifiers know not to trust new signatures, and (3) timestamp when you
detected the compromise.

### Q: What if I can't reach Charlene?

**A:** With 2-of-3 SSKR, you need any two shares. If Charlene is
unavailable, use your safety deposit share plus your cloud backup
share. This is why distributing shares across different contexts
matters: you're not dependent on any single person or location. (But
it would have been a problem for Amira when she was far from her
safety deposit box.)

### How quickly should I respond?

**A:** As fast as possible. Every hour the compromised key remains
"valid" in your published XID is an hour the attacker can sign
things. The reconstruction and revocation process takes minutes. The
bottleneck is usually physical access to shares.

### Should I change my inception key too?

No. The inception key wasn't compromised (it was offline in SSKR
shares).
