# 5.1: Generating Operational Keys

To date, we've used a single key to control your XID, the inception
key. Sure, we've added keys for GitHub, for attestations, and for
signing contracts, but that singular inception key was still all that
lay between a XID and the loss of that identifier. Here's where we
start to turn that around.

> 🧠 **Related Concepts.** After completing this tutorial, explore
[Key Management](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/concepts/key-management.md) to understand the full
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
identity to this point? She follows the [least and necessary design
patterns](https://www.blockchaincommons.com/musings/Least-Necessary/)
which means that she ensures that the keys that she uses every day
have the least permissions necessary for the work she's doing.

That's a three-step process:

1. Create operational keys (§5.1).
2. Adjust her operational keys to just the right (necessary) permissions (§5.2).
3. Backup her inception key separate from her XID (§5.3).

The steps to do so will be the main through-line of this chapter.

### The Power of Key Permissions

Besides supporting different keys, XIDs also support different key
permissions. `xid key add --help` displays instructions on how to add
keys, including information on how to adjust permissions (which we've
just lightly touched upon before):

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

## Part I: Understanding Key Permissions

Key permissions can be easily checked using the `xid key` commands.

### Step 1: Listing Keys

To manage keys first requires understanding how to manipulate
them. The `envelope` command offers a number of ways to do so.

You can count the keys in a XID with `envelope xid key count`:
```
envelope xid key count $XID

| 3
```

You can list them with `envelope xid key all`:

```
envelope xid key all $XID

| ur:envelope/lrtpsotansgylftanshflfaohdcxhleosstafpwzesmsaychonvtpfbztyytcmhfmonefluylabzgtcmbbpseycnzcuytansgrhdcxmwaycebgqdrslksogrrnhygmhtdthtctaymkuroxueptgtehvwzosgeyfnlepkfgoycscstpsojziajljtjyjphsiajydpjeihkklfoycsfplftansfwlrhdghvdfmdrhpglmycecpasseyacpehpkticpclutcthnmsbztppmptkitshsotqdnnfzgalazclfjtpfsgjsieolpyvaglwdgaiakkfgstrnolyagmnekisftpbkuraarfrkolpmnsndjyswdlpfioldlersgtjkgazmdnztlflbgstprhcetehpnbgedyfrnshprsgdswaainlbrfmefloteopdfnvlfnwnjnaohddatansfphdcxpavacsswfllernaavopkhgbezcdkfyptldgemygtytdsfrjtpyeekkrplttkfpceoybwtpsotanshptansfwlrhdcxskehfypyjsrltdbgfpvwbwjnfygdqzrllamevtlulgfzprglehencyndwfftaabdgskorhchfzroyakbsfnbolcldsgddrkgghzmdkpfdikplareaxdecfbkbdbshflfaxtansgmgdgatngyzeplasbtjnbkwtylntimbbislroybstpsotansgmhdcxgugwrhwseycsdisbvdzewegrecoykensgrhpglfnfgnyimylchhtgewlaoeslkihoycsfncsfdcefxdems
| ur:envelope/lrtpsotansgylftanshflfaohdcxolmystmtwyhhgljscpamingewnkplnpssfmnsnlramdwclkpkswmkstbfgdngdtotansgrhdcxsoeymskoiyrseswelubkspfdhllpmyksrpmkcmwzaoplwdlrfhzoropslpnlcmadoycscstpsoisfwgmhsiekojliaetoycsfncsfglfoycsfplftansfwlrhdghztsoynoxlshsrpcfdlkggudpskttvypekpjnhljtpsspfsrneyplhhcwlgfmceiokktlrdltfhvyykaostfrdttbehlpwypkiewfwdpetlkgdngrnegeaemdmuqdrpfesbmehgasdwadrdftcnemueimaxisjeeeghksdwwygskirhcylasataytlymsdasfspgdmnoyiddirkmwhsesbgrysnbwmtdpnsgdhddatansfphdcxdtrortsrldkghddybyfdlrlelepmjsprtiaogykgmeoywlhdlysegywprhjtuessoybwtpsotanshptansfwlrhdcxgrbwfrrdbylgpkgovsuevldpmhonzmenbtmttytefsdplbmthlkgjsnlkewlwmcxgspkfsdrlsytismupmgrcagdfzgdmsgysoaxoxcswladrnrdtnrnbgiewduthflfaxtansgmgdiecxisgdrhrhmhvlmkrdgsjkrtlttortoybstpsotansgmhdcxrkkemtyldezmietdspmenscfcpbkfwykketirdolhpadbgylbeesykgufnjlhllfnbylurzm
| ur:envelope/lrtpsotansgylftanshflfaohdcxtyjeuyceehntqzmwtdhfoscmguplcyeoaarhcxghreynrlfleynefnbtiodyesattansgrhdcxntesveuelkhdbnwdutynettbaarnnbspgefsvemohtnezeldcncmueldtkjlfxhdoycscstpsojlhsjyjyihjkjyhsjyinjljtdpjeihkkoycsfncsfdlfoycsfplftansfwlrhdghsesfgliagewldimenlaebzcfpdlsqztsbsbbroeolfflpeckaegwytlkfdgyynlamnfmahbdtenssgfskpcywpluaefdcxcwidiopamupswpfsldolfssraebnswkipfpktnoxplzcrtdllbndcsseykdlosvatbtnattipegswkvlaaltsbpyoxnyahhkdrcagddtotlpbwvyluhywtenflihhyvtueprbkhddatansfphdcxwyjegooepakobtaxksjlhnfsfdbdhsteynbdvduoztpaoywnkendbzryhhwymstdoybwtpsotanshptansfwlrhdcxuyfxsoqzfxcfsshngopmpkjthndisnfyhysksagltltsnebaluidcxrtfxdibkeegsflldgwurdyjtvejljsfemtcegdmshssnrobdwltewmtptotestistiqzgshflfaxtansgmgdfsjlcxdskpbzswwzswgwfwtockjkynaaoybstpsotansgmhdcxhgatwkkepkgafysffruywegychtbidvejomkhhrlsbidmnftgapehdlbwybemkyttikosest
```

If you know what's where in a XID, you can retrieve a specific key with `envelope xid key at`:
```
envelope xid key at 0 $XID

| ur:envelope/lrtpsotansgylftanshflfaohdcxhleosstafpwzesmsaychonvtpfbztyytcmhfmonefluylabzgtcmbbpseycnzcuytansgrhdcxmwaycebgqdrslksogrrnhygmhtdthtctaymkuroxueptgtehvwzosgeyfnlepkfgoycscstpsojziajljtjyjphsiajydpjeihkklfoycsfplftansfwlrhdghvdfmdrhpglmycecpasseyacpehpkticpclutcthnmsbztppmptkitshsotqdnnfzgalazclfjtpfsgjsieolpyvaglwdgaiakkfgstrnolyagmnekisftpbkuraarfrkolpmnsndjyswdlpfioldlersgtjkgazmdnztlflbgstprhcetehpnbgedyfrnshprsgdswaainlbrfmefloteopdfnvlfnwnjnaohddatansfphdcxpavacsswfllernaavopkhgbezcdkfyptldgemygtytdsfrjtpyeekkrplttkfpceoybwtpsotanshptansfwlrhdcxskehfypyjsrltdbgfpvwbwjnfygdqzrllamevtlulgfzprglehencyndwfftaabdgskorhchfzroyakbsfnbolcldsgddrkgghzmdkpfdikplareaxdecfbkbdbshflfaxtansgmgdgatngyzeplasbtjnbkwtylntimbbislroybstpsotansgmhdcxgugwrhwseycsdisbvdzewegrecoykensgrhpglfnfgnyimylchhtgewlaoeslkihoycsfncsfdcefxdems

```
Finally, the `envelope xid key find` command can either let you find an inception key:

```
envelope xid key find inception $XID

| ur:envelope/lrtpsotansgylftanshflfaohdcxolmystmtwyhhgljscpamingewnkplnpssfmnsnlramdwclkpkswmkstbfgdngdtotansgrhdcxsoeymskoiyrseswelubkspfdhllpmyksrpmkcmwzaoplwdlrfhzoropslpnlcmadoycscstpsoisfwgmhsiekojliaetoycsfncsfglfoycsfplftansfwlrhdghztsoynoxlshsrpcfdlkggudpskttvypekpjnhljtpsspfsrneyplhhcwlgfmceiokktlrdltfhvyykaostfrdttbehlpwypkiewfwdpetlkgdngrnegeaemdmuqdrpfesbmehgasdwadrdftcnemueimaxisjeeeghksdwwygskirhcylasataytlymsdasfspgdmnoyiddirkmwhsesbgrysnbwmtdpnsgdhddatansfphdcxdtrortsrldkghddybyfdlrlelepmjsprtiaogykgmeoywlhdlysegywprhjtuessoybwtpsotanshptansfwlrhdcxgrbwfrrdbylgpkgovsuevldpmhonzmenbtmttytefsdplbmthlkgjsnlkewlwmcxgspkfsdrlsytismupmgrcagdfzgdmsgysoaxoxcswladrnrdtnrnbgiewduthflfaxtansgmgdiecxisgdrhrhmhvlmkrdgsjkrtlttortoybstpsotansgmhdcxrkkemtyldezmietdspmenscfcpbkfwykketirdolhpadbgylbeesykgufnjlhllfnbylurzm
```

Or a key with a specific name:

```
envelope xid key find name "attestation-key" $XID

| ur:envelope/lrtpsotansgylftanshflfaohdcxtyjeuyceehntqzmwtdhfoscmguplcyeoaarhcxghreynrlfleynefnbtiodyesattansgrhdcxntesveuelkhdbnwdutynettbaarnnbspgefsvemohtnezeldcncmueldtkjlfxhdoycscstpsojlhsjyjyihjkjyhsjyinjljtdpjeihkkoycsfncsfdlfoycsfplftansfwlrhdghsesfgliagewldimenlaebzcfpdlsqztsbsbbroeolfflpeckaegwytlkfdgyynlamnfmahbdtenssgfskpcywpluaefdcxcwidiopamupswpfsldolfssraebnswkipfpktnoxplzcrtdllbndcsseykdlosvatbtnattipegswkvlaaltsbpyoxnyahhkdrcagddtotlpbwvyluhywtenflihhyvtueprbkhddatansfphdcxwyjegooepakobtaxksjlhnfsfdbdhsteynbdvduoztpaoywnkendbzryhhwymstdoybwtpsotanshptansfwlrhdcxuyfxsoqzfxcfsshngopmpkjthndisnfyhysksagltltsnebaluidcxrtfxdibkeegsflldgwurdyjtvejljsfemtcegdmshssnrobdwltewmtptotestistiqzgshflfaxtansgmgdfsjlcxdskpbzswwzswgwfwtockjkynaaoybstpsotansgmhdcxhgatwkkepkgafysffruywegychtbidvejomkhhrlsbidmnftgapehdlbwybemkyttikosest
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
PublicKeys(a9818011, SigningPublicKey(5f1c3d9e, Ed25519PublicKey(b2c16ea3)), EncapsulationPublicKey(96209c0f, X25519PublicKey(96209c0f))) [
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
PublicKeys(6d94a1eb, SigningPublicKey(128ffa82, Ed25519PublicKey(363eab4e)), EncapsulationPublicKey(e46036f9, X25519PublicKey(e46036f9))) [
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
```

Now we know what we're working with!

## Part II: Adding Operational Keys

Two sorts of protection are required for keys. Obviously, they must be
protected from loss. That's going to be the topic of
[§5.3](05_3_Backing_up_Inception_Key.md): how to ensure that the
inception key is always available. However, they also have to be
protected from compromise: someone stealing them and using them
without permission.

That's going to be the topic of this chapter, where we practice the
[least and
necessary](https://www.blockchaincommons.com/musings/Least-Necessary/)
design patterns by creating new keys with limited permissions for
everyday usage, so that if keys are stolen, they're these keys, rather
than the ones that control the XID.

### Step 3: Generate a Laptop XID Key

To start with, Amira is going to generate a new operational key for
her XID for the laptop where she does all of her work for
SisterSpaces.

```
LAPTOP_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
LAPTOP_PUBKEYS=$(envelope generate pubkeys "$LAPTOP_PRVKEYS")

echo "✅ Generated laptop operational key"

│ ✅ Generated laptop operational key
```

### Step 4: Add Key with Limited Permissions

The permissions aren't actually in the key, which is just a standard
ed25519 key, but instead in the XID. As we've seen previously, when
you add a key that's when you choose the permissions it'll have.

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

`envelope format` reveals a key with a much longer list of permissions than the other keys to date:

```
envelope format $XID_WITH_OPERATIONAL_KEY_1

| ✅ Added operational (laptop) key to XID
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
|         'allow': 'Access'
|         'allow': 'Authorize'
|         'allow': 'Elide'
|         'allow': 'Encrypt'
|         'allow': 'Issue'
|         'allow': 'Sign'
|         'nickname': "laptop-key"
|     ]
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

### Step 6: Add a Portable Drive XID Key

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

Then she adds them to her XID with a different set of permissions. She
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

Here's A look at her full set of keys afterward:
```
envelope format $XID_WITH_OPERATIONAL_KEY_2

| XID(5f1c3d9e) [
|
| ...
| 
|     'key': PublicKeys(57f4126d, SigningPublicKey(e15ac4c2, Ed25519PublicKey(a4893d82)), EncapsulationPublicKey(49ad97ce, X25519PublicKey(49ad97ce))) [
|         {
|             'privateKey': ENCRYPTED [
|                 'hasSecret': EncryptedKey(Argon2id)
|             ]
|         } [
|             'salt': Salt
|         ]
|         'allow': 'Sign'
|         'nickname': "contract-key"
|     ]
|     'key': PublicKeys(6d94a1eb, SigningPublicKey(128ffa82, Ed25519PublicKey(363eab4e)), EncapsulationPublicKey(e46036f9, X25519PublicKey(e46036f9))) [
|         {
|             'privateKey': ENCRYPTED [
|                 'hasSecret': EncryptedKey(Argon2id)
|             ]
|         } [
|             'salt': Salt
|         ]
|         'allow': 'Sign'
|         'nickname': "attestation-key"
|     ]
|     'key': PublicKeys(a9818011, SigningPublicKey(5f1c3d9e, Ed25519PublicKey(b2c16ea3)), EncapsulationPublicKey(96209c0f, X25519PublicKey(96209c0f))) [
|         {
|             'privateKey': ENCRYPTED [
|                 'hasSecret': EncryptedKey(Argon2id)
|             ]
|         } [
|             'salt': Salt
|         ]
|         'allow': 'All'
|         'nickname': "BRadvoc8"
|     ]
|     'key': PublicKeys(c32d7426, SigningPublicKey(59e9ad4d, Ed25519PublicKey(425b8e15)),|  EncapsulationPublicKey(c2b3746b, X25519PublicKey(c2b3746b))) [
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
|     'key': PublicKeys(d930b267, SigningPublicKey(5f6630d7, Ed25519PublicKey(d72a49de)), EncapsulationPublicKey(ae36f917, X25519PublicKey(ae36f917))) [
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
|     ...
| ]
```

### Step 7: Review and Store

You've now made the full updates to your XID and should store it all away.

As usual, first update your provenance mark:
```

XID_WITH_KEYS=$(envelope xid provenance next \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$XID_WITH_OPERATIONAL_KEY_2")

| echo "✅ Provenance advanced"
```

Then, make a public version:

```
PUBLIC_XID_WITH_KEYS=$(envelope xid export --private elide --generator elide "$XID_WITH_KEYS")
```

Finally, save everything away:
```
echo "$LAPTOP_PRVKEYS" > envelopes/key-laptop-private-5-01.ur
echo "$LAPTOP_PUBKEYS" > envelopes/key-laopt-public-5-01.ur
echo "$PORTABLE_PRVKEYS" > envelopes/key-portable-private-5-01.ur
echo "$PORTABLE_PUBKEYS" > envelopes/key-portable-public-5-01.ur

echo "$PUBLIC_XID_WITH_KEYS" > envelopes/BRadvoc8-xid-public-5-01.envelope
echo "$XID_WITH_KEYS" > envelopes/BRadvoc8-xid-private-5-01.envelope
```

#### Key Type Comparison

At this point, Amira can review her XID that now has five keys in it:

| Key Type | Purpose | Verified Against | Added In |
|----------|---------|------------------|----------|
| 👤 XID inception key | Signs XID document updates | XID itself | §1.3 |
| 🗣️  Attestation key | Signs attestations | XID key list | §2.1 |
| 🖋️  SSH signing key | Signs Git commits | GitHub account | §3.1 |
| 📄️  Contract signing key | Signs contracts | XID key list | §4.1 |
| 💻 Laptop Key | Operational Key | XID key list | §5.1 |
| ⏏️ Portable Key | Limited Operational Key | XID key list | §5.1 |


#### Key Protection Comparison

The following chart shows why having an operational key is safer than
just using an inception key for everything.

| Scenario | With Inception Key | With Operational Key |
|----------|------------------------|-------------------|
| Attacker signs things | Yes | Yes |
| Attacker adds their key | Yes | **No** |
| Attacker removes your keys | Yes | **No** |
| You can revoke attacker's access | Maybe (race condition) | **Yes** (you still have inception key) |
| Identity recovery | Difficult | Straightforward |

The operational key limits the blast radius of a compromise.

The following concrete situation, where Amira leaves her laptop at a
coffee shop and someone takes it demonstrates this:

**With inception key**: The thief extracts Amira's inception key, adds
their own key with `'All'` permissions, then removes Amira's key. By
the time Amira realizes what happened, her identity belongs to someone
else. Her endorsements, her CLA signature, and her reputation
are now all controlled by a stranger.

**With operational keys**: The thief gets `laptop-jan2026`, which can
only engage in operational activities. They might sign some things
before Amira notices, but they cannot add their own keys or remove
hers. Amira uses her inception key (stored securely elsewhere) to
revoke `laptop-jan2026` and add a new operational key. Her identity
remains intact. The damage is contained to a few potentially
fraudulent signatures that she can publicly disavow.

## Part III: Eliding Keys

In order for an operational key to be meaningful, the inception key
must not also be available. Obviously, you don't want to just delete
it, however, or you can't modify your XID either, so you must
undertake a two part process:

1. Store your inception key.
2. Elide your inception key.

### Step 8: Store Your Inception Key

The easiest way to store your inception key is to store the full,
current copy of your XID. Just place it in offline-storage and check
it occasionally to make sure it's still there.

```
cp envelopes/BRadvoc8-xid-private-5-01.envelope OFFLINE-STORAGE
```

Only bring the full XID online when you need to make updates to it.

Alternatively, or in addition, you can choose to just store your inception key.

```
INCEPTION_PRVKEYS=$(envelope xid key find inception $XID_WITH_KEYS)
echo $INCEPTION_PRVKEYS > OFFLINE-STORE/xid-inception-key.envelope
```

You generally want your backups to be more resilient than this for
something as important as an inception key, and we'll talk about how
to manage that in [§5.3](05_3_Backing_up_Inception_Key.md). But for
now, the backup is a fine first step.

### Step 9: Elide Your Inception Key

With a backup copy of your XID (or at least the inception key) made,
you can now safely elide the key from your operational XID.

This is easily done with the new commands from this section that
detailed how to find a specific key and the lessons learned from
[§4.3](04_3_Creating_New_Views.md).
```
INCEPTION_PRVKEYS=$(envelope xid key find inception $XID_WITH_KEYS)
INCEPTION_DIGEST=$(envelope digest $INCEPTION_PRVKEYS)
OPERATIONAL_XID=$(envelope elide removing $INCEPTION_DIGEST $XID_WITH_KEYS)
```

Amira should now use the `$OPERATIONAL_XID` on her laptop while
keeping the original XID in an offline storage. When she goes
traveling, she would additionally elide the `laptop-key`, so that only
the less powerful `portable-key` is available.

echo "$OPERATIONAL_XID" > envelopes/BRadvoc8-xid-operational-5-01.envelope

#### XID 📄 `seq: 8` View Comparison

In this section, Amira produced a new `seq 8` for her XID, but made a
number of views, showing again the power of elision to make
appropriate views of a XID for different purposes.

| Description | Notes | Created In |
|-------------|-------------|------------|
| 🔒 Private View | | §5.1 |
| 👁️  Public View | Elided key material | §5.1 |
| 💻 Operational View | Removed inception key | §5.1 |
| ⏏️ Portable View | Removed two keys | |

## Summary: Generating Operational Keys

You don't need to keep your inception key in your XID, and in fact
doing so is a security threat. The XID keys system supports improved
security by allowing you to create a key with lesser permissions, such
as a key that only has operational permissions. You can then store
copies of your full XID offline and remove the inception key from your
in-use copy.

### Additional Files

**Envelopes:** The
[envelopes](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/envelopes)
directory contains numerous data created in this section, including
the
[private](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/envelopes/BRadvoc8-xid-private-5-01.envelope),
[public](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/envelopes/BRadvoc8-xid-public-5-01.envelope),
and
[operational](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/envelopes/BRadvoc8-xid-operational-5-01.envelope)
views of Amira's new XID.

**Scripts:** Forthcoming.

### Exercises

These exercises test your understanding of the permission model:

1. **Negative permission test**: Try to use an operational key to
revoke another key. What happens? Why?
2. **Compromise simulation**: Revoke the laptop key using the
inception key. Then verify that documents signed with the old laptop
key still validate (signatures are historical) but the key is no
longer in the XID.
3. **Permission escalation**: Create a key with `sign` and `encrypt`
permissions but not `elect`. What can this key do that a sign-only key
cannot?

## What's Next

You've now successfully added and elided keys, but what if you want to
change or rotate keys? That's the top of [§5.2](05_2_Updating_Keys.md).

## Appendix I: Key Terminology

> **Inception Key**: The original key created when the XID was established, typically with full permissions (elect, revoke). Should be highly protected. Also called the "private key base" in technical documentation.
>
> **Permission Scope**: The specific operations a key is allowed to perform (`sign`, `encrypt`, `elect`, `revoke`, etc.).
>
> **Operational Key**: A key with limited permissions (typically sign-only) used for daily work. Compromise is contained.


> :brain: **Learn more.** The [Key Management](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/concepts/key-management.md) concept doc explains the full key hierarchy model and permission system.


## Appendix II: Common Questions

### Q: Can I have multiple inception keys?

**A:** No. Each XID should have exactly one key with full permissions
(the inception key). Multiple "master" keys would create ambiguity
about who controls the identity.

### Q: What if I lose my inception key?

**A:** Without the inception key, you cannot add or remove keys from
your XID. The identity becomes frozen: existing operational keys keep
working, but you can't recover if they're compromised. This is why
[§5.3](05_3_Backing_up_Inception_Key.md) focuses on more robust
offline backup. Never keep your inception key only on a device that
could be lost or stolen.

### Q: How many operational keys is too many?

**A:** It depends on your threat model. More keys means more
flexibility but also more to track. A typical setup might have 2-4
operational keys (primary device, backup device, maybe a hardware
token). If you're managing more than 5-6 operational keys, consider
whether you really need that many active signing contexts.

