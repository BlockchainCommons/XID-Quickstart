# 4.3: Creating New Views

Amira has created multiple versions of her XID, and now feels that
it's fully developed enough that she can do the work that she
wants. But does she need to publish her full XID every time?

> 🧠 **Related Concepts.** After completing this tutorial, explore
[Data Minimization](/concepts/data-minimization.md) and [Elision
Cryptography](../concepts/elision-cryptography.md).

## Objectives of this Section

After working through this section, a developer will be able to:

- Decide what should be elided from a XID.
- Elide content to create distinct views of XID.

Supporting objectives include the ability to:

- Understand how Gordian Envelope manages elision
- Understand the difference between a view and an edition

## Amira's Story: Managing an Identity

Amira's XID has gotten crowded:
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
            "peer-endorsement-from-devreviewer-28f4b6bc18637fd6" [
                'isA': "attestation"
                'source': XID(6ab29708) [
                    "schema:employeeRole": "Head Security Programmer"
                    "schema:worksFor": "SisterSpaces"
                ]
                'target': XID(5f1c3d9e) [
                    "endorsementContext": "Verfied previous security experience, worked together on short project for SisterSpaces"
                    "endorsementScope": "Security architecture, cryptographic implementation, privacy patterns"
                    "peerEndorsement": "Writes secure, well-tested code with clear attention to privacy-preserving patterns"
                    "relationshipBasis": "Security collaboration partner who verified credentials through commit-reveal and encrypted sharing"
                    'date': "2026-03-11T13:52-10:00"
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
        'provenance': ProvenanceMark(93595c6f) [
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

It now includes one `dereferenceVia`, three `edge`s (a GitHub account
link, a peer endorsement, and a project link), three `key`s (an
inception key, an attestation key, and a contract key), and a
provenance mark. Though Amira has decided that she wants all of that
content in her XID, she doesn't necessarily need ever viewer to see
all of that. That's partially a question of privacy, but partially the
fact that she wants each viewer to actually _see_ what's important to
them.

To make changes to what people see, without changing the underlying
XID, Amira can create a new **view** using elision. This is a
different solution from changing the underlying content of a XID to
create a new edition, which will be the topic of the next section.

## The Power of Elision

Elision (or redaction) refers to the reversable removal of content in
a XID (or other Gordian Envelope). It's powerful because it doesn't
change the underlying structure of the Gordian Envelope. Every leaf
and every node in a Gordian Envelope's Merkle-like tree of content
hash a hash. Even when the content is elided, the hash remains. That
means that (1) you can later prove the data was there; and (2) you
don't change the root hash of the envelope, and as a result signatures
of the envelope remain valid.

We've seen the power of elision throughout this course, but especially
whenever we made a public version of an envelope (by eliding key
material) and when we elided an entire envelope of sensitive material
in [§2.2](02_2_Managing_Claims_Elision.md).

> 🔥 ***What is the Power of Elision?** Elision in Gordian Envelopes
(including XIDs) also you to remove content without affecting
authenticating signatures on the envelope. You can also later prove
that the removed content is part of the envelope through an inclusion
proof, where you present the removed content and the elided envelope
and show that the one fits into the other through its hash.

Eliding content from a Gordian Envelope requires using the `envelope
elide removing` command to remove the specific content identified by a
digest. That means that you need to be able to find the digests of
specific leaves and nodes in an envelope. This is primarily done with
the `envelope assertion find` command, which returns either an
assertion with a specific `predicate` or an assertion with a specific
`object`. However, the assertion you're looking for must be a
assertion to the subject that is at the top level of your current
envelope. Sometimes this requires using the `envelope extract` command
to find a subenvelope before you can get to the specific predicate
you're looking for.

The examples in this section will include both eliding high-level
content with the `xid ... all` commands and digging down further to
find a specific element within a subenvelope.

## Part 0: Verify Dependencies

Before you get started, you should (as usual) check your `envelope-cli` version:
```
envelope --version

│ bc-envelope-cli 0.34.1
```

Then, reload your XID. 

```
XID=$(cat envelopes/BRadvoc8-xid-private-4-02.envelope)
XID_ID=$(envelope xid id $XID)
PASSWORD="your-password-from-previous-tutorials"
```

## Part I: Eliding XID Objects

XIDs have a number of top level objects such as keys and edges that
are easy to elide because there are XID commands such as `envelope xid
key all` and `envelope xid edge all` that list out all objects of
these types.

Because of this accessible functionality, it's very easy to elide
objects of these types.

### Step 1: Generate an Object List

Amira has decided that her contract key does not need to be in the
public XID that she gives out in most cases. She'll of course still
send it to people when she's signing contracts, but it doesn't need to
be seen every time she wants to connect with someone.

You can remove the contract key by creating a new view of the `seq: 5`
edition of Amira's XID with the contract key elided.

The first thing to do is to generate a list of keys. This is done with `xid key all`:
```
envelope xid key all $PUBLIC_XID

| ur:envelope/lrtpsotansgylftanshflfaohdcxtyjeuyceehntqzmwtdhfoscmguplcyeoaarhcxghreynrlfleynefnbtiodyesattansgrhdcxntesveuelkhdbnwdutynettbaarnnbspgefsvemohtnezeldcncmueldtkjlfxhdoycscstpsojlhsjyjyihjkjyhsjyinjljtdpjeihkkhdcxeorknnestystpmytlklrfdwmvoeekptasaolcpvabdjedegdgugwhtiagwiainfpoycsfncsfdgrdwhssr
| ur:envelope/lrtpsotansgylftanshflfaohdcxolmystmtwyhhgljscpamingewnkplnpssfmnsnlramdwclkpkswmkstbfgdngdtotansgrhdcxsoeymskoiyrseswelubkspfdhllpmyksrpmkcmwzaoplwdlrfhzoropslpnlcmadoycscstpsoisfwgmhsiekojliaetoycsfncsfghdcxgsttmtbababdytimroflampdjzprlggwfrbzdscnmujycthshysolbcwseoloxfdhfltcxds
| ur:envelope/lrtpsotansgylftanshflfaohdcxhleosstafpwzesmsaychonvtpfbztyytcmhfmonefluylabzgtcmbbpseycnzcuytansgrhdcxmwaycebgqdrslksogrrnhygmhtdthtctaymkuroxueptgtehvwzosgeyfnlepkfghdcxjzwsckiyfygdcyoefdeydlsndswpgwdkkswmimlyspeslbcabeatfthghkhfpypaoycscstpsojziajljtjyjphsiajydpjeihkkoycsfncsfdhtntoeur
```

You can put that in a variable, then turn it into an array for easier access:
```
KEYLIST=$(envelope xid key all $XID)
KEYS=($KEYLIST)
```

This will then allow access as `${KEYS[0]}`, `${KEYS[1]}`, etc.

### Step 2: Choose a Key

You now need to find the key with the `"contract-key"`
nickname. (Hint: it's `${keys[2]}`.) You could easily do this by just
doing an `envelope format` of each of the keys:

```
envelope format ${keys[2]}

| PublicKeys(57f4126d, SigningPublicKey(e15ac4c2, Ed25519PublicKey(a4893d82)), EncapsulationPublicKey(49ad97ce, X25519PublicKey(49ad97ce))) [
|     'allow': 'Sign'
|     'nickname': "contract-key"
|     ELIDED
| ]
```

But you can also automatically look up the key that you want. This is
done with the `assertion find object` command that we'll also be using
to find a particular subenvelope in the next section. As noted
earlier, it can be used to find the assertions under a subject that
you have, so here it could be used to find the `'allow': 'Sign'`
assertion or the `'nickname': "contract-key"` assertion.

Here's what that looks like:
```
envelope assertion find object string "contract-key" ${KEYS[2]}

| ur:envelope/oycscstpsojziajljtjyjphsiajydpjeihkkjoutnlty
```

And here's what it found:
```
envelope format ur:envelope/oycscstpsojziajljtjyjphsiajydpjeihkkjoutnlty

| 'nickname': "contract-key"
```

We can now use a bash `for` to look for the key that returns a non-null
result when we try to `find` the `"contract-key"` and output that:

```
for i in "${KEYS[@]}"
do
  if [[ -n `envelope assertion find object string "contract-key" $i` ]]
  then
    echo $i
  fi
done

| ur:envelope/lrtpsotansgylftanshflfaohdcxhleosstafpwzesmsaychonvtpfbztyytcmhfmonefluylabzgtcmbbpseycnzcuytansgrhdcxmwaycebgqdrslksogrrnhygmhtdthtctaymkuroxueptgtehvwzosgeyfnlepkfglfoycsfplftansfwlrhdghplnbjecwgtmwhstpnsaeiyaxjsvebzguadtoprvoronngldlhllfintiskhdzckggmvyjnrtgukicpmhdiahssmdbgknknvtwfhyrtsrjznsynlupfihptmojyfmdyuowpaycafgfnehfppydmcnbyetresncygetdpllusegsmtgstsienetdrkbzemolbnsogdtaaedsuyollbrphdmhgtrsuyhlkpeyrehddatansfphdcxpavacsswfllernaavopkhgbezcdkfyptldgemygtytdsfrjtpyeekkrplttkfpceoybwtpsotanshptansfwlrhdcxpyetzsdkhnmsjohemutkzmjplatkltwdknjnpeqdwmsorhfebwlnrnttynrsnbglgsftcmpagrzctkkkkegmfdgrkigdbsuyckdytloygslbrkfedrdnkiuorkkthflfaxtansgmgdtnlosfcljtrlzcynsetnksoewelpzmltoybstpsotansgmhdcxgugwrhwseycsdisbvdzewegrecoykensgrhpglfnfgnyimylchhtgewlaoeslkihoycscstpsojziajljtjyjphsiajydpjeihkkoycsfncsfdiyoetyyk

```

For easy access, we can put that in a variable:
```
CONTRACTKEY=$(for i in "${KEYS[@]}"; do   if [[ -n `envelope assertion find object string "contract-key" $i` ]];   then     echo $i;   fi; done)
```

(As it happens, there's also a special command to find a key by name,
which we'll encounter in [§5.1](05_1_Generating_Operational_Keys.md),
but since we're talking about the general practice of elision here, we
wanted to demonstrate a method that could be used for finding
_anything_.)

### Step 3: Digest a Key

Now that you have the key that you want to elide, you can output its digest:
```
CONTRACTKEY_DIGEST=$(envelope digest $CONTRACTKEY)
```

### Step 4: Remove the Content

Finally, you use that digest with `envelope elide remove` to remove it:

```
XID_WO_CONTRACTKEY=$(envelope elide removing $CONTRACTKEY_DIGEST $XID)
```

The result is a new XID with that key removed (except for its digest!), as shown in this look at just the keys:

```
envelope format $XID_WO_CONTRACTKEY
| {
|     XID(5f1c3d9e) [
|         ...
|         'key': ELIDED
|         'key': PublicKeys(6d94a1eb, SigningPublicKey(128ffa82, Ed25519PublicKey(363eab4e)), EncapsulationPublicKey(e46036f9, X25519PublicKey(e46036f9))) [
|             {
|                 'privateKey': ENCRYPTED [
|                     'hasSecret': EncryptedKey(Argon2id)
|                 ]
|             } [
|                 'salt': Salt
|             ]
|             'allow': 'Sign'
|             'nickname': "attestation-key"
|         ]
|         'key': PublicKeys(a9818011, SigningPublicKey(5f1c3d9e, Ed25519PublicKey(b2c16ea3)), EncapsulationPublicKey(96209c0f, X25519PublicKey(96209c0f))) [
|             {
|                 'privateKey': ENCRYPTED [
|                     'hasSecret': EncryptedKey(Argon2id)
|                 ]
|             } [
|                 'salt': Salt
|             ]
|             'allow': 'All'
|             'nickname': "BRadvoc8"
|         ]
|         ...
| } [
|     'signed': Signature(Ed25519)
| ]
```

### Step 5: Create a New Public Edition

You already made a first public view of XID `seq: 5` in
[§4.2](04_2_Publishing_for_Privacy.md)when you did a public export of
the full XID (minus the keys). You're now ready to make a second
public view that has `ELIDED` the contract-key:


```
PUBLIC_XID_WO_CONTRACTKEY=$(envelope xid export --private elide --generator elide "$XID_WO_CONTRACTKEY")
```

As usual, we'll store new copies:

```
echo "$XID_WO_CONTRACTKEY" > envelopes/BRadvoc8-xid-s5v2-private-4-03.envelope
echo "$PUBLIC_XID_WO_CONTRACTKEY" > envelopes/BRadvoc8-xid-s5v2-public-4-03.envelope
```

## Part II: Eliding XID Sub-Objects

Eliding a complete edge or key is simple because `envelope` can
provide lists of top-level XID objects. Sometimes, however, you don't
want to elide a complete top-level object, but instead some aspect of
that object.

This is equally simple with Envelope: you simply find the digest of
that sub-object and elide it. However, _finding_ the digest can be a
little more difficult because you need to dig down until the assertion
you're looking for is just one level down from your main subject.

Amira encounters this when she decides she needs to redact the
`endorsementContext` of DevReviewer's peer endorsement because
DevReviewer's statement that she "Verfied previous security
experience" creates a correlation risk for Amira by revealing that she
had previous security experience.

### Step 6: Find the Edge

Start out by generating a list of edges:
```
envelope xid edge all $XID
```
Then use whatever method you prefer to edge with DevReviewer's peer endorsement.

It's:
```
ur:envelope/lftpsplrtpsokseyjoihihjpdpihjtiejljpjkihjnihjtjydpiyjpjljndpieihkojpihkoinihktihjpdpeyetiyeeidenidiaeheteneoemiyieenoycfaornlstpsotanshdhdcximprmsaylgfwcyjzzcamzmdrbdetjsrngamnbsfptbwtksihrhzonsahuthydwtboytpsojkjkiaisihjnhsftihjnjojzjlkkihihgmjljzihtpsokscsfdihhsiecxguihiakpjpinjykkcxgdjpjliojphsjnjnihjpoytpsojljkiaisihjnhsftktjljpjejkfgjljptpsojzguinjkjyihjpgujohsiaihjkoycfaorslntpsotanshdhdcxhecefsnnionspljpftktetwymnfmcyecveuotktpwenlhyhdpmpykpchcmzchywzoytpsojsjpihjzhsjyinjljtjkisinjofwhsjkinjktpsoksiaguihiakpjpinjykkcxiajljzjzhsidjljphsjyinjljtcxjohsjpjyjtihjpcxktisjlcxkoihjpiniyinihiecxiajpihieihjtjyinhsjzjkcxjyisjpjlkpioiscxiajljnjninjydpjpihkoihhsjzcxhsjtiecxihjtiajpkkjojyihiecxjkishsjpinjtiooybetpsokoeydyeyendpdyeodpehehgheheofteceydpehdyftdydyoytpsojpihjtiejljpjkihjnihjtjyfxjljtjyihksjytpsokshghfihjpiyinihiecxjojpihkoinjlkpjkcxjkihiakpjpinjykkcxihksjoihjpinihjtiaihdwcxktjljpjeihiecxjyjlioihjyisihjpcxjljtcxjkisjljpjycxjojpjlimihiajycxiyjljpcxguinjkjyihjpgujohsiaihjkoytpsojljoihihjpfejtiejljpjkihjnihjtjytpsoksguhgjpinjyihjkcxjkihiakpjpihdwcxktihjzjzdpjyihjkjyihiecxiajlieihcxktinjyiscxiajzihhsjpcxhsjyjyihjtjyinjljtcxjyjlcxjojpinkohsiakkdpjojpihjkihjpkoinjtiocxjohsjyjyihjpjtjkoytpsojoihjtiejljpjkihjnihjtjyguiajljoihtpsoksfeguihiakpjpinjykkcxhsjpiaisinjyihiajykpjpihdwcxiajpkkjojyjliojphsjoisiniacxinjnjojzihjnihjtjyhsjyinjljtdwcxjojpinkohsiakkcxjohsjyjyihjpjtjkoyadtpsojehsjyjyihjkjyhsjyinjljtoyaxtpsotansghlfaohdfztotdmttbtkeojlgalkiywpdlhkckltcnlnleksaysntyrefegweygmasrlcyksplemghihynhscxnlspkonlhlemksiaadbewfdrieksehvypychmtteurwemktttiaxjegodrvt
```
Which we're storing as `$DEV_EDGE`

### Step 7: Extract Objects to Reach the Subject/Assertion Level 

Digging down to find an object in an envelope generally requires two iterative steps:

* `extract` an object from your envelope to create a simple subject/assertion(s) pairing.
* `find` an assertion to dig down to the next level.

You repeat these steps until the assertion you find or the object you
extract is the one you actually want to elide.

In this case, we're working with the following edge that we extracted:
```
{
    "peer-endorsement-from-devreviewer-28f4b6bc18637fd6" [
        'isA': "attestation"
        'source': XID(6ab29708) [
            "schema:employeeRole": "Head Security Programmer"
            "schema:worksFor": "SisterSpaces"
        ]
        'target': XID(5f1c3d9e) [
            "endorsementContext": "Verfied previous security experience, worked together on short project for SisterSpaces"
            "endorsementScope": "Security architecture, cryptographic implementation, privacy patterns"
            "peerEndorsement": "Writes secure, well-tested code with clear attention to privacy-preserving patterns"
            "relationshipBasis": "Security collaboration partner who verified credentials through commit-reveal and encrypted sharing"
            'date': "2026-03-11T13:52-10:00"
        ]
    ]
} [
    'signed': Signature(Ed25519)
]
```

And we want to get down to the `peerEndorsement`, which as shown is a few levels removed.

Here's the process:

1. The edge is signed, which means the entire content of the edge is
wrapped, so we first `extract` the content from the subject wrapping.

```
DEV_UNWRAPPED=$(envelope extract wrapped $DEV_EDGE)

| "peer-endorsement-from-devreviewer-28f4b6bc18637fd6" [
|     'isA': "attestation"
|     'source': XID(6ab29708) [
|         "schema:employeeRole": "Head Security Programmer"
|         "schema:worksFor": "SisterSpaces"
|     ]
|     'target': XID(5f1c3d9e) [
|         "endorsementContext": "Verfied previous security experience, worked together on short project for SisterSpaces"
|         "endorsementScope": "Security architecture, cryptographic implementation, privacy patterns"
|         "peerEndorsement": "Writes secure, well-tested code with clear attention to privacy-preserving patterns"
|         "relationshipBasis": "Security collaboration partner who verified credentials through commit-reveal and encrypted sharing"
|         'date': "2026-03-11T13:52-10:00"
|     ]
| ]
```

2. We need to `find` the `'target'` predicate, because `"endorsementContext"` is under that:

```
DEV_TARGET=$(envelope assertion find predicate known 'target' $DEV_UNWRAPPED)

| 'target': XID(5f1c3d9e) [
|     "endorsementContext": "Verfied previous security experience, worked together on short project for SisterSpaces"
|     "endorsementScope": "Security architecture, cryptographic implementation, privacy patterns"
|     "peerEndorsement": "Writes secure, well-tested code with clear attention to privacy-preserving patterns"
|     "relationshipBasis": "Security collaboration partner who verified credentials through commit-reveal and encrypted sharing"
|     'date': "2026-03-11T13:52-10:00"
| ]
```

3. `'target': XID(5f1c3d9e)` is a full assertion rather than a simple subject. We need to `extract` its object `XID(5f1c3d9e)` so that we have a simple subject/assertion(s) pairing.

```
DEV_TARGET_XID=$(envelope extract object $DEV_TARGET)

| XID(5f1c3d9e) [
|     "endorsementContext": "Verfied previous security experience, worked together on short project for SisterSpaces"
|     "endorsementScope": "Security architecture, cryptographic implementation, privacy patterns"
|     "peerEndorsement": "Writes secure, well-tested code with clear attention to privacy-preserving patterns"
|     "relationshipBasis": "Security collaboration partner who verified credentials through commit-reveal and encrypted sharing"
|     'date': "2026-03-11T13:52-10:00"
| ]
```

4. We can now `find` the `"endorsementContext"`.

```
DEV_EC=$(envelope assertion find predicate string "endorsementContext" $DEV_TARGET_XID)

| "endorsementContext": "Verfied previous security experience, worked together on short project for SisterSpaces"
```

At this point, we could be done, as that's the assertion that Amira
wants to elide, but Amira decides it would be bad practice to just
remove the `"endorsementContext"` as if it were not there. She instead
decides to remove only the object of the assertion, which has the data
that she fears could be correlatable.

5. `extract` the object from the `"endorsementContext"` assertion

```
DEV_EC_OBJECT=$(envelope extract object $DEV_EC)

| "Verfied previous security experience, worked together on short project for SisterSpaces"
```

6. Once you've found the right element of the XID, find its digest.

```
DEV_DIGEST=$(envelope digest $DEV_EC_OBJECT)
```

> ⚠️ **XIDs are Alterable.** We've noted many time that XIDs are
alterable through elision. This example shows that viewers must take
care of that fact. If something is removed they should ask themselves
what it means for what remains. Is an endorsement still valid if some
of the content has been removed? Keeping as much of the endorsement as
possible, perhaps even including the predicates for what's been
removed, can increase the level of trust.

### Step 8: Remove the Sub-Content

For creating her third public view of her `seq: 5` XID, Amira could do
one of two things: she could apply the elision to the original view of
that XID edition or she could apply the elision to the view of the XID
that she's already removed a key from. Both would be valid views: they
don't have to build on each other. In fact, it's likely that many
views of XIDs will run parallel to each other, with different content
extracted from each XID, as appropriate for each audience.

In this case, Amira decides that the removal of the contract key
remains valid while she also removes this potentially correlatable
content, so she stacks them atop each other:

```
XID_V3=$(envelope elide removing $DEV_DIGEST $XID_WO_CONTRACTKEY)
```

Two things are of note here:

1. Amira kept in the predicate, `"endorsementContext"`, even as she removed the context object. That allows people to see what she did and if they find it necessary, to ask her why she removed the context. Amira might even chose to privately reveal the view of the XID that contains the context as part of a cycle of progressive trust.
2. Even though Amira removed part of DevReviewer's endorsement, DevReviewer's signature on the endorsement remains valid because that signature is made across the hash of the endorsement, and the hashes remain unchanged despite elisions.

### Step 9: Create a New Public Edition

Finally, you can make a public version of the double-elided view:

```
PXID_V3=$(envelope xid export --private elide --generator elide "$XID_V3")
```
Here's what the view looks like:
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
            "peer-endorsement-from-devreviewer-28f4b6bc18637fd6" [
                'isA': "attestation"
                'source': XID(6ab29708) [
                    "schema:employeeRole": "Head Security Programmer"
                    "schema:worksFor": "SisterSpaces"
                ]
                'target': XID(5f1c3d9e) [
                    "endorsementContext": ELIDED
                    "endorsementScope": "Security architecture, cryptographic implementation, privacy patterns"
                    "peerEndorsement": "Writes secure, well-tested code with clear attention to privacy-preserving patterns"
                    "relationshipBasis": "Security collaboration partner who verified credentials through commit-reveal and encrypted sharing"
                    'date': "2026-03-11T13:52-10:00"
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
        'key': ELIDED
        'key': PublicKeys(6d94a1eb, SigningPublicKey(128ffa82, Ed25519PublicKey(363eab4e)), EncapsulationPublicKey(e46036f9, X25519PublicKey(e46036f9))) [
            'allow': 'Sign'
            'nickname': "attestation-key"
            ELIDED
        ]
        'key': PublicKeys(a9818011, SigningPublicKey(5f1c3d9e, Ed25519PublicKey(b2c16ea3)), EncapsulationPublicKey(96209c0f, X25519PublicKey(96209c0f))) [
            'allow': 'All'
            'nickname': "BRadvoc8"
            ELIDED
        ]
        'provenance': ProvenanceMark(93595c6f) [
            ELIDED
        ]
    ]
} [
    'signed': Signature(Ed25519)
]
```

You'll notice five things are elided:

1. The entire "contract-key" is elided, per Part I.
2. DevReviewer's "endorsementContext" is elided, per Part II.
3. The two remaining private keys and the provenance mark generator are elided, per the "export" command.

As usual, we'll store new copies:

```
echo "$XID_V3" > envelopes/BRadvoc8-xid-s5v3-private-4-03.envelope
echo "$PXID_V3" > envelopes/BRadvoc8-xid-s5v3-public-4-03.envelope
```

#### XID 📄 `seq: 5` View Comparison

At this point, Amira has made four views of the `seq: 5` edition that
she produced in the last tutorial when she added her contract
commitment edge. They are:

| Description | Notes | Created In |
|-------------|-------------|------------|
| 🔒 Private View | | §4.2 |
| 👁️  Public View | Elided key material | §4.2 |
| 🔑 Simplified View | Elided contract key | §4.3 |
| ❗ Non-Correlatable View | Elided correlatable content | §4.3 |

You'll note that unlike editions, these views are not numbered.
That's because you can make as many views as you want, and they can be
totally disconnected from each. You simply follow the concept of [data
minimization](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/concepts/data-minimization.md)
for each, creating views for any viewer that are appropriate for what
they need to know. The underlying content of your XID doesn't change
(that would be a new edition). All that changes is what can be seen.

## Summary: Creating New Views

Elision can be used for a variety of purposes. It can entirely protect
sensitive data, as discussed in
[§2.2](02_2_Managing_Claims_Elision.md). It can be used to simplify
XIDs if they're growing over complex. However, it can also be used to
create multiple views of a single version of a XID, each appropriate
for a different viewer.

### Additional Files

**Envelopes:** The
[envelopes](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/envelopes)
directory contains numerous data created in this section, including
the public versions of the [keyless
XID](BRadvoc8-xid-s5v2-public-4-03.envelope) and the [less
correlatable
XID](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/envelopes/BRadvoc8-xid-s5v3-public-4-03.envelope)
created in this section.

**Scripts:** The
[scripts](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/scripts)
directory contains
[04_3_Creating_New_Views-SCRIPT.sh](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/scripts/04_3_Creating_New_Views-SCRIPT.sh),
which runs through all the commands in this section. From the command
line, `git clone
https://github.com/BlockchainCommons/XID-Quickstart.git`, then `cd
XID-Quickstart`, then `bash
scripts/04_3_Creating_New_Views-SCRIPT.sh` to test it.


### Exercises

1. Elide an edge or key in a XID.
2. Find an assertion more deeply buried in an edge or XID.
3. Elide only the object of that assertion.
4. Create a different view where you remove only the predicate of that exertion.

## What's Next

Elision is great if you want to maintain the same edition of a XID
and/or ensure that it signatures can be authenticated. But what if you
want to entirely remove content from a XID? [§4.4: Creating New
Editions](04_4_Creating_New_Editions.md) covers that final topic.

## Appendix I: Key Terminology

> **Elision** - Removing data from an envelope while preserving the envelope's root hash, enabling selective disclosure while maintaining cryptographic integrity.
>
> **View** - A version of a specific edition of a XIDDoc (or other envelope) that has been elided in a specific way, to preserve selective disclosure. Despite the elision, signatures remain valid, because they are made across the Root Hash.
