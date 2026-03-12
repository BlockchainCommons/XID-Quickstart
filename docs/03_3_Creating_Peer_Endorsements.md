# 3.3: Creating Peer Endorsements

Self-attestations can go a long way, particularly if they can be
verified. But the trust of a pseudonymous identity can truly be built
through the endorsements of peers, who are effectively passing on some
of their own reputation when they attest to your skills or abilities.

> **Related Concepts**: After completing this tutorial, explore the
[Attestation & Endorsement
Model](../concepts/attestation-endorsement-model.md) and [Progressive
Trust](../concepts/progressive-trust.md) to deepen your understanding.

## Objectives of this Section

After working through this section, a developer will be able to:

- Give endorsements using the fair witness methodology
- Build a web of trust through multiple independent endorsers
- Create peer endorsements using detached and embedded methodologies

Supporting objectives include the ability to:

- Know the difference between attestations (your claims) and endorsements (others' validation)
- Understand how relationship transparency makes endorsements more valuable

## Amira's Challenge: Getting Validated

Amira has made self attestations about her skills and done her best to
support validation of those attestations through links to proof of
work. But, there are limits to this: deeper trust requires
attestations from other members, to create a web of trust among its
members.

To accomplish this, Amira needs peer endorsements. Her friend
Charlene, who introduced Amira to the RISK network in the first place
is a great first endorsement. But now Amira has also done an initial
project with DevReviewer, and getting a peer endorsement from her
would be even more valuable, because she's active on SisterSpaces and
in other social-design categories that Amira is interested in.

The key distinction between Amira's self attestations and Charlene and
DevReviewer's peer endorsements is whose keys sign the
statement. Attestations are signed with *your* keys: they prove you
made the claim. Endorsements are signed with *their* keys: they stake
their reputation on you. That's why endorsements carry more weight:
the endorser has something to lose if you turn out to be a fraud.

## The Power of Fair Witness Endorsements

The best endorsements follow the same model as the best
self-attestations. As described in
[§2.1](02_1_Creating_Self_Attestations/#the-power-of-fair-witness-attestations),
fair-witness attestations are made as much as possible without bias or
interpretation.

To create a proper fair-witness attestation for Amira, Charlene would ask herself five questions:

1. **What have I actually observed?** She's seen BRadvoc8's commitment
to privacy work over two years—that's endorsable. "Probably a great
coder" would be speculation.
2. **What's the right scope?** "I endorse everything about BRadvoc8"
isn't credible. "I endorse her character and values" is specific and
honest.
3. **How do I disclose the relationship?** "Personal friend who
introduced her to RISK network" lets evaluators calibrate for
potential bias.
4. **What can't I speak to?** Charlene hasn't seen Amira's
code. Acknowledging this makes the endorsement more credible, not
less.
5. **Would I be embarrassed if wrong?** If BRadvoc8 turns out badly,
would this endorsement look foolish? If yes, Charlene should narrow the scope.

As a result, Charlene's endorsement will be limited to character and values: that's what she can honestly attest to.

## Part I: Creating Detached Peer Endorsements

Because Charlene's peer endorsement is limited to character and value,
it's a fairly light attestation that Amira expects she'll only need as
she bootstraps up her pseudonymous BRadvoc8 identity. For that reason,
she'll be creating it as a detached endorsement.

As for the rest, that all falls on Charlene: this part is from her
point of view, as she creates an endorsement for Amira (or rather for
BRadvoc8).

### Step 0: Verify Dependencies

As usual, check your `envelope-cli` version:
```
envelope --version

│ bc-envelope-cli 0.34.1
```

Then, reload your XID.
```
XID=$(cat envelopes/BRadvoc8-xid-private-3-01.envelope)
XID_ID=$(envelope xid id $XID)
PASSWORD="your-password-from-previous-tutorials"
```

### Step 1: Create Charlene's Identity

Before Charlene can endorse BRadvoc8, she needs her own XID:

```
CHARLENE_PASSWORD="charlenes-own-password"
CHARLENE_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
CHARLENE_PUBKEYS=$(envelope generate pubkeys "$CHARLENE_PRVKEYS")
CHARLENE_XID=$(echo $CHARLENE_PRVKEYS | \
    envelope xid new \
    --private encrypt \
    --encrypt-password "$CHARLENE_PASSWORD" \
    --nickname "Charlene" \
    --generator encrypt \
    --sign inception)
CHARLENE_XID_ID=$(envelope xid id "$CHARLENE_XID")

echo "✅ Charlene's XID created: $CHARLENE_XID_ID"

│ ✅ Charlene's XID created: ur:xid/hdcxincngsnehykswzsfwsrstocwproevwssuybnknhgryflswknwmfenlesrodsfewnmsroserl
```

Best practice at this point would be for Charlene to also great a
seperate endorsement key and add that to her XID as described in
[§2.1](02_1_Creating_Self_Attestations/#step-1-create-an-attestation-key),
but we're going to keep it simple by not doing so.

### Step 2: Charlene Creates Her Endorsement

Charlene applies fair witness principles to create a character endorsement:

```
CHARLENE_CLAIM=$(envelope subject type string "BRadvoc8 is a thoughtful and committed contributor to privacy work that protects vulnerable communities")
```

She then fills it in the same edge-inspired format used earlier for self-attestations:
```
CHARLENE_ENDORSEMENT=$(envelope assertion add pred-obj known isA known 'attestation' "$CHARLENE_CLAIM")
CHARLENE_ENDORSEMENT=$(envelope assertion add pred-obj known source ur $CHARLENE_XID_ID "$CHARLENE_ENDORSEMENT")
CHARLENE_ENDORSEMENT=$(envelope assertion add pred-obj known target ur $XID_ID "$CHARLENE_ENDORSEMENT")
CHARLENE_ENDORSEMENT=$(envelope assertion add pred-obj known 'date' string `date -Iminutes` "$CHARLENE_ENDORSEMENT")
```

Charlene also adds some context to help set aside any bias possible in the claim by revealing its full context using fair witness methodologies::
```
CHARLENE_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementContext" string "Personal friend, observed values and commitment over 2+ years" "$CHARLENE_ENDORSEMENT")
CHARLENE_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementScope" string "Character and values alignment, not technical skills" "$CHARLENE_ENDORSEMENT")
CHARLENE_ENDORSEMENT=$(envelope assertion add pred-obj string "relationshipBasis" string "Friend who introduced BRadvoc8 to RISK network concept" "$CHARLENE_ENDORSEMENT")
```
Finally, Charlene must wrap and sign her endorsement:
```
CHARLENE_WRAPPED_ENDORSEMENT=$(envelope subject type wrapped "$CHARLENE_ENDORSEMENT")
CHARLENE_SIGNED_ENDORSEMENT=$(envelope sign --signer "$CHARLENE_PRVKEYS" "$CHARLENE_WRAPPED_ENDORSEMENT")

echo "Charlene's endorsement:"
envelope format "$CHARLENE_SIGNED_ENDORSEMENT"

| Charlene's endorsement:
| {
|     "BRadvoc8 is a thoughtful and committed contributor to privacy work that protects vulnerable communities" [
|         'isA': 'attestation'
|         "endorsementContext": "Personal friend, observed values and commitment over 2+ years"
|         "endorsementScope": "Character and values alignment, not technical skills"
|         "relationshipBasis": "Friend who introduced BRadvoc8 to RISK network concept"
|         'date': "2026-03-11T12:00-10:00"
|         'source': XID(69234c9f)
|         'target': XID(5f1c3d9e)
|     ]
| } [
|     'signed': Signature(Ed25519)
| ]
```

Notice how the `endorsementScope` explicitly states what Charlene is
_not_ endorsing.

### Why Relationship Transparency Matters

The `relationshipBasis` assertion is one of the most valuable parts of
this endorsement. When someone reads "Charlene endorses BRadvoc8,"
they immediately wonder: How well does Charlene know BRadvoc8? What's
her basis for judgment? Is there bias?

Consider two versions of the same endorsement. The weak version says
only "I endorse BRadvoc8"; the evaluator doesn't know the relationship
basis, can't assess potential bias, and has little reason to trust the
statement. The strong version says "I endorse BRadvoc8's
character. Relationship: friend for 2+ years, observed commitment to
privacy work." Now the evaluator has something to work with: length of
relationship, what was actually observed, and honest acknowledgment of
the friendship.

Endorsement value comes from context. Without relationship
transparency, even strong endorsements lose credibility. A stranger's
"great work!" means nothing; a code reviewer's "I merged 8 of her PRs
and they were all solid" means everything.

## Step 3: Publish Endorsement

Now Charlene can either publicly release her endorsement or pass it on
to Amira to do with as she pleases.

When Amira distributes the endorsement herself, it'd be ideal for her
to be able to just publish the endorsement, but that creates a
Discovery Challenge, as there's not yet any methodology for finding
XIDs (but having them reliable listed as `source` and `target` in
edges and other endorsements is a great start).

## Step 4: Store Charlene's Info

```
echo "$CHARLENE_PRVKEYS" > envelopes/key-charlene-private-3-03.envelope
echo "$CHARLENE_PUBKEYS" > envelopes/key-charlene-public-3-03.envelope
echo "$CHARLENE_XID" > envelopes/Charlene-xid-private-3-03.envelope
echo "$CHARLENE_SIGNED_ENDORSEMENT" > envelopes/claim-charlene-3-03.envelope
```

## Part II: Creating Embedded Peer Endorsements

The introduction of edges in [§3.1: Creating
Edges](03_1_Creating_Edges.md) offers the possibility of attaching
endorsements directly to a XID as a link between the two participants
in the endorsement. This might be appropriate for technical
endorsements, which validate actual skills, which will go to the heart
of the work that Amira hopes to do in the RISK network.

Just as Part I was from Charlene's point of view, Part II is from
DevReviewer's point of view.

### Step 5: Create DevReviewer's Identity

Thanks to Amira proving her BRadvoc8 identity to DevReviewer over the
course of §2.2-§3.2, DevReviewer took her on to work on a first, small
project. Afterward, Amira asked DevReviewer to write a peer
endorsement that she could place in her XID as an embedded peer
endorsement. DevReviewer agreed.

This requires also creating DevReviewer's identity.

You could generate DevReviewer's identity from scratch, but the
following instead uses the keys aren't generated for DevReviewer in
§2.3. (This is done for simplicity of the secondary characters in
these tutorials; in real-life, Amira might have indeed grabbed the
pubkeys from DevReviewer's XID to encrypt the material in §2.3, but
she might have alternatively have used keys that DevReviewer
specifically published that were intended only for encryption of
content sent to them.)

```
REVIEWER_PRVKEYS=$(cat envelopes/key-devreviewer-private-2-03.ur)
REVIEWER_PUBKEYS=$(cat envelopes/key-devreviewer-public-2-03.ur)
REVIEWER_PASSWORD="devreviewers-own-password"
REVIEWER_XID=$(echo $REVIEWER_PRVKEYS | \
    envelope xid new \
    --private encrypt \
    --encrypt-password "$REVIEWER_PASSWORD" \
    --nickname "Charlene" \
    --generator encrypt \
    --sign inception)
REVIEWER_XID_ID=$(envelope xid id "$REVIEWER_XID")
```

### Step 6: Prepare Data for Edge Creation

As detailed in
[§3.1](03_1_Creating_Edges/#step-3-understand-the-edge), creating an
attestation for use in an edge requires slightly different
organization than a detached endorsement.

First, it requires defining three predicates that will be used in the
top-level of the edge:

```
ISA="attestation"
SOURCE_XID_ID=$REVIEWER_XID_ID
TARGET_XID_ID=$XID_ID
```

### Step 7: Create Technical Endorsement

Now an endorsement can be created with the `$TARGET_XID_ID` as the
subject and all the details of the attestation under that. The basics are simple:


```
REVIEWER_TARGET=$(envelope subject type ur $TARGET_XID_ID)
REVIEWER_TARGET=$(envelope assertion add pred-obj string "peerEndorsement" string "Writes secure, well-tested code with clear attention to privacy-preserving patterns" $REVIEWER_TARGET)
REVIEWER_TARGET=$(envelope assertion add pred-obj known 'date' string `date -Iminutes` "$REVIEWER_TARGET")
```

But once more, adding context including the relationship basis can add considerably to the value of the endorsement:
```
REVIEWER_TARGET=$(envelope assertion add pred-obj string "endorsementContext" string "Verfied previous security experience, worked together on short project for SisterSpaces" "$REVIEWER_TARGET")
REVIEWER_TARGET=$(envelope assertion add pred-obj string "endorsementScope" string "Security architecture, cryptographic implementation, privacy patterns" "$REVIEWER_TARGET")
REVIEWER_TARGET=$(envelope assertion add pred-obj string "relationshipBasis" string "Security collaboration partner who verified credentials through commit-reveal and encrypted sharing" "$REVIEWER_TARGET")
```

### Step 8: Enhance Endorser Information

Assertions can always be added to any part of an envelope. That means
that DevReviewer can choose to add more information on who _they_
are. This is a self-attestation (since it'll ultimately be signed only
by DevReviewer), but it can add credibility to a peer endorsement.

To do so, requires creating an envelope with the subject of
DevReviewers XID ID (since it'll ultimately be substituted for the
`source` of the endorsement):
```
REVIEWER_SOURCE=$(envelope subject type ur $REVIEWER_XID_ID)
```
They then can add whatever details they want:
```
REVIEWER_SOURCE=$(envelope assertion add pred-obj string "schema:worksFor" string "SisterSpaces" $REVIEWER_SOURCE)
REVIEWER_SOURCE=$(envelope assertion add pred-obj string "schema:employeeRole" string "Head Security Programmer" $REVIEWER_SOURCE)
```

The [`schema`
ontologies](https://github.com/BlockchainCommons/Research/blob/master/known-value-assignments/markdown/10000_schema_registry.md)
are very rich and support deeply recursive descriptions, but DevReviewer keeps it simple.

### Step 9: Create Your Edge

With all of the puzzle pieces in place (an `$ISA`, an envelope for the
`source`, and an envelope for the `target`), DevReviewer can now
create an edge. The only other thing needed is a subject which must be
unique. Obviously, DevReviewer doesn't know what BRadvoc8 will have in
their XID, but by adding an Apparently Random Identifier (ARID) on to
a description, they can produce something that SHOULD be unique
```
REVIEWER_ARID=$(envelope generate arid -x | cut -c 1-16)
REVIEWER_SUBJECT=peer-endorsement-from-devreviewer-$REVIEWER_ARID
REVIEWER_EDGE=$(envelope subject type string $REVIEWER_SUBJECT)
REVIEWER_EDGE=$(envelope assertion add pred-obj known isA string "$ISA" "$REVIEWER_EDGE")
REVIEWER_EDGE=$(envelope assertion add pred-obj known source envelope "$REVIEWER_SOURCE" "$REVIEWER_EDGE")
REVIEWER_EDGE=$(envelope assertion add pred-obj known target envelope "$REVIEWER_TARGET" "$REVIEWER_EDGE")
```
As is required, the edge now must be wrapped and signed:
```
REVIEWER_WRAPPED_EDGE=$(envelope subject type wrapped $REVIEWER_EDGE)
REVIEWER_SIGNED_EDGE=$(envelope sign --signer "$REVIEWER_PRVKEYS" "$REVIEWER_WRAPPED_EDGE")
```

### Step 10: Transmit Your Edge

DevReviewer can now send their edge to Amira. it looks like this:
```
echo "DevReviewer's endorsement:"
envelope format $REVIEWER_SIGNED_EDGE

| DevReviewer's endorsement:
|
| {
|     "peer-endorsement-from-devreviewer-28f4b6bc18637fd6" [
|         'isA': "attestation"
|         'source': XID(6ab29708) [
|             "schema:employeeRole": "Head Security Programmer"
|             "schema:worksFor": "SisterSpaces"
|         ]
|         'target': XID(5f1c3d9e) [
|             "endorsementContext": "Verfied previous security experience, worked together on short project for SisterSpaces"
|             "endorsementScope": "Security architecture, cryptographic implementation, privacy patterns"
|             "peerEndorsement": "Writes secure, well-tested code with clear attention to privacy-preserving patterns"
|             "relationshipBasis": "Security collaboration partner who verified credentials through commit-reveal and encrypted sharing"
|             'date': "2026-03-11T13:52-10:00"
|         ]
|     ]
| } [
|     'signed': Signature(Ed25519)
| ]
```
At this point, DevReviewer's peer endorsement is essentially a
detached attestation that happens to be organized into a very specific
format. But because of that formatting (a unique subject with three
assertions, for `isA`, `source`, and `target`), Amira can choose to
add it to the BRadvoc8 XID _if she wants to_.

That's how self-sovereign identity works. You can't control what other
people say about you, but you can choose what's part of your identity
as you present it.

> 🔥 **What is the Power of Self-Sovereign identity?** Self-sovereign
identity means that you control everything within a membrane in your
identity ecosystem. Though you can't control what other people say
about the identity, you control what is directly associated with the
identity itself: you get to see it all and you get to control it.

## Step 11: Store DevReviewer's Info

You should also store DevReviewer's info:
```
echo "$REVIEWER_PRVKEYS" > envelopes/key-devreviewer-private-3-03.envelope
echo "$REVIEWER_PUBKEYS" > envelopes/key-devreviewer-public-3-03.envelope
echo "$REVIEWER_XID" > envelopes/DevReviewer-xid-private-3-03.envelope
echo "$REVIEWER_SIGNED_EDGE" > envelopes/claim-devreviewer-3-03.envelope
```

(We did make copies of the keys previously used in §2.3! They're just
the same, but we figure having them together will make verification of
the endorsement easier.)

## Part III: Embedding Peer Endorsements

Once Amira has received DevReviewer's endorsement, they can decide
whether to add it to their XID, maintain it as a detached endorsement
that they give out separately, or drop it entirely.

## Step 12: Embed DevReviewer's Peer Endorsement

If DevReviewer had not given Amira a peer endorsement in the precise
format for an edge, it could not be attached as an edge. But because
they did, it can be attached with a simple command, provided that Amira feels
it's core to her XID and it's how she wants to present herself:
```
XID_WITH_EDGE=$(envelope xid edge add $REVIEWER_SIGNED_EDGE $XID)
```

As usual, after creating a new version of her XID (with either added
or removed content), Amira should advance its provenance mark.
```
XID_WITH_EDGE=$(envelope xid provenance next \
    --password "$PASSWORD" \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$XID_WITH_EDGE")
echo "✅ Provenance advanced"
```
Here's Amira's complete XID at this point:
```
echo "Amira's v4 XID:"
envelope format $XID_WITH_EDGE

| Amira's v4 XID:
|
| XID(5f1c3d9e) [
|     'dereferenceVia': URI(https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt)
|     'edge': {
|         "account-credential-github" [
|             'isA': "foaf:OnlineAccount"
|             'source': XID(5f1c3d9e)
|             'target': XID(5f1c3d9e) [
|                 "foaf:accountName": "BRadvoc8"
|                 "foaf:accountServiceHomepage": URI(https://github.com/BRadvoc8/BRadvoc8)
|                 "sshSigningKey": SigningPublicKey(c75b2f19, SSHPublicKey(b3e7a8b0))
|                 "sshSigningKeyText": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiOtuf9hwDBjNXyjvjHMKeLQKyzT8GcH3tLvHNKrXJe BRadvoc8@Mac.attlocal.net"
|                 "sshSigningKeysURL": URI(https://api.github.com/users/BRadvoc8/ssh_signing_keys)
|                 'conformsTo': URI(https://github.com)
|                 'date': "2026-03-11T09:21-10:00"
|                 'verifiableAt': URI(https://api.github.com/users/BRadvoc8)
|             ]
|         ]
|     } [
|         'signed': Signature(SshEd25519)
|     ]
|     'edge': {
|         "peer-endorsement-from-devreviewer-28f4b6bc18637fd6" [
|             'isA': "attestation"
|             'source': XID(6ab29708) [
|                 "schema:employeeRole": "Head Security Programmer"
|                 "schema:worksFor": "SisterSpaces"
|             ]
|             'target': XID(5f1c3d9e) [
|                 "endorsementContext": "Verfied previous security experience, worked together on short project for SisterSpaces"
|                 "endorsementScope": "Security architecture, cryptographic implementation, privacy patterns"
|                 "peerEndorsement": "Writes secure, well-tested code with clear attention to privacy-preserving patterns"
|                 "relationshipBasis": "Security collaboration partner who verified credentials through commit-reveal and encrypted sharing"
|                 'date': "2026-03-11T13:52-10:00"
|             ]
|         ]
|     } [
|         'signed': Signature(Ed25519)
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
|     'provenance': ProvenanceMark(16be4cbd) [
|         {
|             'provenanceGenerator': ENCRYPTED [
|                 'hasSecret': EncryptedKey(Argon2id)
|             ]
|         } [
|             'salt': Salt
|         ]
|     ]
| ]
```

### Step 13: Export & Store Your Work

As usual, yYou should create a public view of the new XID that elides all the
sensitive keys:

```
PUBLIC_XID_WITH_EDGE=$(envelope xid export --private elide --generator elide "$XID_WITH_EDGE")
```

Afterward, you should save your data, including the
fourth version of Amira's XID.

```
echo "$PUBLIC_XID_WITH_EDGE" > envelopes/BRadvoc8-xid-public-3-03.envelope
echo "$XID_WITH_EDGE" > envelopes/BRadvoc8-xid-private-3-03.envelope
```

#### XID Version Comparison

You've now created a third XID version. You take a look at the provenance marks again in the next section, but here's an overview of what each versionc ontains

| XID Version | New Content | Created In |
|-------------|-------------|------------|
| seq 0 | 👤 Identity | §1.2+§1.3 |
| seq 1 | 🔑 Attestation Key | §2.1 |
| seq 2 | 🗣️ GitHub Edge | §3.1 |
| seq 3 | 🗣️ Endorsement Edge | §3.3 |

## Part IV: Creating a Web of Trust

[Progressive Trust](../concepts/progressive-trust.md) is created over time in two ways:

1. By revealing more information to inviduals over time, such as with Amira revealed a commitment to DevReviewer in [§2.2](02_2_Managing_Claims_Elision.md) and sent encrypted data to DevReviewer in [§2.3](02_3_Managing_Claims_Encryption.md).
2. By building a web of trust that incorporates endorsements from many peers, who are themselves endorsed by other peers.

Though Amira has successfully improved the trust of BRadvoc8 through
the addition of a new detached endorsement from Charlene and a new
embedded endorsement from DevReviewer, it's just part of a process.

### Step 14: Collect More Endorsements

Over time, Amira will collect more endorsements that she might store separately or attach to her XID.

Without going through the rigamarole of creating the endorsement, the
following is a third attestation that Amira collects from the
maintainer of a repo that she contributed to.

```
| SecurityMaintainer's endorsement:
| {
|     "BRadvoc8 is a reliable contributor who delivers high-quality security enhancements and responds constructively to feedback" [
|         'isA': 'attestation'
|         "endorsementContext": "Collaborated on 3 security features over 6 months"
|         "endorsementScope": "Technical skills, collaboration quality, communication"
|         "relationshipBasis": "Project maintainer who merged BRadvoc8's contributions"
|         'date': "2026-09-17T07:31-07:00"
|         'source': XID(6c0523fc)
|         'target': XID(5f1c3d9e)
|     ]
| } [
|     'signed': Signature(Ed25519)
| ]

```

> 📖 **Do I have to write endorsements in this format?** You've
doubtless noted that all of endorsements have rigidly used
`endorsementContext`, `endorsementScope`, and
`relationshipBasis`. Obviously, you can use whatever format you want
when writing attestations. What we present here is simply a suggestion
for best practice—and the best practice these specific predicates, but
instead the practice of using a fair witness methodology to accurately
and impartially report the context and potential bias of an endorsement.

### Step 15: Verify All Endorsements

Whenever other viewers are looking over the endorsements, they'll want to verify them.

For a detached endorsement like Charlene's, this is easy. They
discover Charlene's XID or retrieve her public key from somewhere
else, such as a PKI, then they verify it against the endorsement

Once another user has Charlene's endorsement, and has acquired her
pubkeys from her XID, they can verify her signature:

```
envelope verify -s --verifier "$CHARLENE_PUBKEYS" "$CHARLENE_SIGNED_ENDORSEMENT"

│ Signature valid (silence means success)
```

The verified signature proves this endorsement was signed by Charlene
and hasn't been modified. But why is this more trustworthy than
Amira's self-attestations?

The difference is cost. Charlene is an independent party staking her
own reputation on BRadvoc8. If BRadvoc8 turns out to be incompetent or
dishonest, Charlene looks bad for vouching. That reputational risk
makes her endorsement a costly signal, one that goes up in value the
more that Charlene's own XID has been used and is trusted.

Self-attestations cost nothing; endorsements cost credibility.

Verifying an embedded endorsement requires extracting it, then
checking the signature. This was demonstrated in
[§3.2](03_2_Supporting_Cross_Verification.md).

[EXAMPLE TBD after writing §3.2]

#### What If Someone Forges an Endorsement?

What happens if someone creates a fake endorsement, for example claiming Charlene endorsed them?

```
FAKE_CLAIM=$(envelope subject type string "BRadvoc8 is amazing at everything")
FAKE_ENDORSEMENT=$(envelope assertion add pred-obj known isA known 'attestation' "$FAKE_CLAIM")
FAKE_ENDORSEMENT=$(envelope assertion add pred-obj known source ur $CHARLENE_XID_ID "$FAKE_ENDORSEMENT")
FAKE_ENDORSEMENT=$(envelope assertion add pred-obj known target ur $XID_ID "$FAKE_ENDORSEMENT")
FAKE_ENDORSEMENT=$(envelope assertion add pred-obj known 'date' string `date -Iminutes` "$FAKE_ENDORSEMENT")
FAKE_WRAPPED=$(envelope subject type wrapped $FAKE_ENDORSEMENT)
ATTACKER_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
FAKE_SIGNED=$(envelope sign --signer "$ATTACKER_PRVKEYS" "$FAKE_WRAPPED")
```

The forgery fails because the attacker can't produce a valid signature
without Charlene's private key. Anyone can *claim* they are endorsed
by `source': XID(69234c9f)` in the metadata, but only the
cryptographic signature proves authenticity and that requires
Charlene's actual key.

```
envelope verify --verifier "$REVIEWER_PUBKEYS" "$FAKE_SIGNED"

│ Error: could not verify a signature
```

### Step 16: Develop a Web of Trust

BRadvoc8 now has three endorsements from different contexts:

| Endorser | Type | Relationship | Scope |
|----------|------|--------------|-------|
| Charlene | Character | Friend (2+ years) | Values, commitment |
| DevReviewer | Technical | Security collaboration (short project) | Security architecture, crypto |
| SecurityMaintainer | Collaboration | Project maintainer (6 months) | Technical skills, communication |

Trust multiplies as endorsements increase, especially when they have different contexts:

| Endorsements | Trust Level | Why |
|--------------|-------------|-----|
| 1 | Weak | Could be a friend doing a favor |
| 3 independent | Moderate | Pattern of validation |
| 3 from different contexts | Strong | Triangulated trust |

However, qulity matters more than quantity. Three endorsements from
unknown people don't equal a strong reputation. Three from established
community members with clear context is a strong signal.

This is a web of trust!

> ⚠️ **Endorsement Quality**: The quality of an endorsement
comes in two parts. First, based on what the endorsement
says. "BRadvoc8 is great!" with no context has low value, but "I
reviewed 8 of her PRs and they were all high quality" with specific
evidence has high value. Second, based on who the endorser
is. Reputation is recursive: endorsements are only as valuable as the
endorsers' own reputations.

#### The Problems of the Web of Trust

The Web of Trust is not perfect. We've been talking about it since the
release of [PGP](https://en.wikipedia.org/wiki/Pretty_Good_Privacy) in
1991. A decades worth of [Rebooting the Web of Trust
events](https://www.weboftrust.info/events/) offered answers to some
of the problems, but not all. Here's some of the biggest issues you need to think about:

**The XID Discovery Challenge:** How do you find XIDs in the first place?
Amira messaged hers to Ben (and later DevReviewer) in these tutorials,
but how does someone else find Charlene's XID and DevReviewer's XID,
which are mentioned in Amira's new peer endorsements?

This is an active area of development. For now, discovery happens
through existing channels: project READMEs, social introductions,
conference talks, or forum posts. The XID provides the *verification*
infrastructure; discovery tooling will make the ecosystem more
navigable as it matures.  Other approaches include:

| Approach | How It Works | Status |
|----------|--------------|--------|
| Direct sharing | Amira sends her XID or her publication URL | Works now |
| Project directories | Maintainers list contributor XIDs | Manual curation |
| Skill registries | Attestations are indexed by `isA` type | Under development |
| Web of trust crawling | Endorsement links can be followed | Under development |

**The Endorsement Publication Challenge:** Much the same question
exists for what to do with the endorsements themselves. There are a
number of possibilities, all of which have been previously
considered. Many of these are orthgonal (e.g., a endorsement could be
deatached and encrypted or embedded and elided).

| Approach | How It Works | Section |
|----------|--------------|---------|
| Detached Endorsement | Endorsement stored separately | §2.1 |
| Elided Endorsement | Endorsement redacted except for digest | §2.2 |
| Embedded Endorsement | Endorsement stored in XID | §3.1 |
| Encrypted Endorsement | Encorsement encrypted | §2.3 |

A lot of this is from the point of view of the endorsee, but the
endorser could also maintain signed lists of endorsements that they've
made (or signed lists of commitments to those endorsements!).

**The Bootstrapping Problem:** Finally, you must ask how you know that
an endorser had creditability.  How does someone kknow that "Charlene"
is actually Charlene? You can verify that their signature matches
Charlene's public key, but how do you know that key belongs to a
trustworthy person named Charlene?

This is the bootstrapping problem of any trust network. The signature
proves the endorsement came from *whoever controls that key*. It
doesn't prove that person is who they claim to be. For that you have to see what endorsements Charlene has, and what endorsements they have ... throughout the web until you're satisfied.

### Step 17: Consider the Endorsement Lifecycle

Just as with all sorts of attestations, endorsements are point-in-time
statements. Charlene's endorsement reflects what she observed through
January 2026. Like all attestations, peer endorsements can grow stale,
and so their age should be considered: if BRadvoc8's behavior changes,
the endorsement doesn't automatically update.

Managing the attestation lifecycle, discussed in
[§2.1](02_1_Creating_Self_Attestations/#part-v-managing-the-attestation-lifecycle)
is at least as important for peer endorsements as it is for
self-attestations.

## Summary: Progressive Trust Layers

At this point, Amira has built a succession of progress trust layers:

1. [§1.2](01_2_Your_First_XID.md): Self-sovereign identity (XID exists)
2. [§1.3](01_3_Making_a_XID_Verifiable.md): Self-consistent (signature verifies, fresh)
3. [§2.1](02_1_Creating_Self_Attestations.md): Fair-witness claims (public, verifiable claims)
4. [§2.2](02_2_Managing_Claims_Elision.md): Sensitive claims managed (commit elided, reveal later)
5. [§2.3](02_3_Managing_Claims_Encryption.md) More sensitive claims managed (encrypted, sent to trusted parties)
6. [§3.1](03_1_Creating_Edges.md): Externally linked (GitHub, SSH key)
7. [§3.2](03_2_Supporting_Cross_Verification.md) Cross-verified (external accounts confirmed)
8. [§3.3](03_3_Creating_Peer_Endorsements.md): Peer validated (independent endorsements)

Her reputation is **portable** (follows her XID), **verifiable**
(anyone can check), **privacy-preserving** (no legal identity), and
**growing** (can continue building).

### Additional Files

**Envelopes:** The
[envelopes](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/envelopes)
directory contains the plethora of information created for this
sections, mostly importantly included BRadvoc8's newest [private
XID](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/envelopes/BRadvoc8-xid-private-3-01.envelope)
and [ublic
XID](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/envelopes/BRadvoc8-xid-public-3-01.envelope).

**Scripts:** Scripts demonstrating this section are forthcoming.

### Exercises

1. Design an endorsement request for a real collaborator. What would
you ask them to endorse, and what context would you provide?
2. Write an endorsement for a fictional peer using fair witness methodology (direct observation, specific scope, relationship disclosure, acknowledged limitations).
3. Evaluate endorsement quality: compare "X is great!" vs "I reviewed
X's code for 6 months and merged 12 PRs". What makes one better?
4. Identify who could provide endorsements for different aspects of your work (technical, collaboration, character).
5. Draft an endorsement you could honestly give someone today, being
specific about what you've observed and what you can't speak to.

## What's Next

Future topics are being considered for this course, but at the moment this is the end.

## Appendix I: Key Terminology

> **Endorsement Scope**: Explicit limitations on what an endorsement covers.
>
> **Peer Endorsement**: A signed statement someone else makes about you, providing independent validation.
>
> **Relationship Transparency**: Explanation of how endorser knows the endorsed person.
>
> **Web of Trust**: Network of interconnected endorsements where trust propagates through relationships.

## Appendix II: Common Questions

### Q: How many endorsements do I need?

**A:** Quality over quantity. Three strong endorsements from
established community members with clear context are worth more than
ten vague ones. Focus on endorsements from people with relevant
expertise who can speak to specific aspects of your work.

### Q: What if an endorser becomes disreputable?

**A:** Endorsements are point-in-time statements. The endorsement
remains cryptographically valid, but evaluators will consider the
endorser's current standing. Diversify your endorsers so no single
person is critical to your reputation. This resilience is a key
benefit of the web of trust.

### Q: Can I endorse others?

**A:** Yes! Apply fair witness methodology: endorse only what you've
directly observed, be specific about scope, and disclose your
relationship. Your endorsement staking helps build the network and
strengthens your own reputation as a thoughtful evaluator.

### Q: Can I warn others about a bad actor?

**A:** Yes: a signed statement with relationship context and specific
evidence is a negative endorsement. Use carefully: false accusations
damage your own reputation, and vague warnings ("X is bad") carry
little weight. Specific, documented concerns ("I observed X claim
credentials they didn't have") are more valuable.

### Q: What if I want to withdraw an endorsement?

**A:** You can publish a revocation as described in
[§2.1](02_1_Creating_Self_Attestations.md): a new signed statement
that supersedes the original endorsement. Include a reference to the
original's digest and explain why you're withdrawing it. The original
endorsement doesn't disappear, but the revocation provides context for
evaluators.

---

---

**Previous**: [Encrypted Sharing](07-encrypted-sharing.md) | **Next**: [Binding Agreements](09-binding-agreements.md)

DEFN

Character endorsement

Technical endorsement
