# 4.2: Publishing Commitments for Privacy

Amira and Ben have a contract that ensures that SisterSpaces will
always be able to use Amira's work. Maybe they're comfortable
publishing that full contract, but maybe they prefer to keep details
to themselves, to maximize the privacy and protection of both
parties. This section explains how they could do so.

> 🧠 **Related Concepts.** After completing this tutorial, explore
[Data Minimization](../concepts/data-minimization.md) and [Elision
Cryptography](../concepts/elision-cryptography.md).

## Objectives of this Section

After working through this section, a developer will be able to:

- Store hashed records of a contract as a commitment.
- Create herd privacy through the publication of numerous hashes.

Supporting objectives include the ability to:

- Understand what a commitment means.
- Understand what herd privacy is.

## Amira's Story: Preserving Privacy

Amira has signed a CLA to allow her work to be used in SisterSpaces'
SecureAuth Library. Most open-source repositories would publish CLAs
like that as part of their repos. But Ben is very aware of privacy
concerns, as many of the women who use his services come from abusive
backgrounds. He extends those privacy concerns to the people working
with him.

Because she is standing behind her BRadvoc8 identity, Amira doesn't
have the same concerns as people who are working with SisterSpaces
without the benefit of a pseudonymous identity. In fact, she's eager
to reveal her connection to them, to improve the trust for her
identity. But that doesn't mean she wants everyone to know the entire
contents of the contract she signed, or at the least doesn't want the
whole huge text incorporated into her XID.

How can licensing rights be ensured without endangering any of the
participants? The answer is commitments.

## The Power of Commitments

We've seen commitments previously, in
[§2.2](02_2_Managing_Claims_Elision.md). Their use there was simple:
we created a claim; we entirely elided that claim; and then we used
the hash of the claim as proof that the claim existed (and had existed
for some period of time).

At the time we said that the commitment _could_ be published, but we
didn't really say how. This chapter explores that more:

To start with, we offer two major methods to create a commitment:
`shasum` a plain file (which we saw in
[§4.1](04_1_Creating_Binding_Agreements.md)) and `digest` an envelope
(which we use here, and which currently defaults to sha-256).

| Hashing Method | App | Section |
|----------------|-----|---------|
| SHASum a File | `shasum` | §4.1 |
| Digest an Envelope | `envelope` | §4.2 |

Each of these digests can also be published in a variety of ways. Ben
incorporated a `shasum` into an envelope in the last section. Here
we're going to see a `digest` incorporated into an envelope and also
discuss how digests can be published in plain (`.md`) files.

| Publication Method | Section |
|--------------------|---------|
| Incorporate into a XID | §4.1, §4.2 |
| Publish as a File | §4.2 |
| Publish in a Long List | §4.2 |

## The Power of Herd Privacy

As noted above, one of the methods of publishing commitments is as
part of a long list. Doing so can create herd privacy. When a long
list of commitments is created, each one blends in with the others. An
observer simply sees a long list of commitments: they can't easily
determine which one belongs to the human rights worker, which to a
student, and which to a retiree. The crowd provides cover.

| Contributors | Observer's Challenge |
|--------------|---------------------|
| 1 | Trivial to identify |
| 10 | Difficult to identify |
| 50 | Needle in haystack |
| 500 | Effectively anonymous |

Even if an attacker discovered a flaw in the methodology that Ben uses
to make commitments, they wouldn't know which hash to try and attack
to prove that BRadvoc8 (or anyone else) is involved. The specifics are
lost among the crowd.

## Part 0: Verify Dependencies

Before you get started, you should (as usual) check your `envelope-cli` version:
```
envelope --version

│ bc-envelope-cli 0.34.1
```

Then, reload your XID. We're also going to be using Amira's
attestation key to create a new edge about her work with SisterSpaces,
which will also depend on the CLA she signed.

```
XID=$(cat envelopes/BRadvoc8-xid-private-4-01.envelope)
XID_ID=$(envelope xid id $XID)
PASSWORD="your-password-from-previous-tutorials"
ATTESTATION_PRVKEYS=$(cat envelopes/key-attestation-private-2-01.ur)
SIGNED_ACCEPTED_CLA=$(cat envelopes/cla-bradvoc8-accepted-4-01.envelope)
```


## Part I: Incorporating a Contract into a XID

Amira is thrilled to talk about her work with SisterSpaces. That's
because Ben's signature on Amira's contract is another step forward in
the progressive trust of BRadvoc8 as a reliable security expert.

On the other hand, she does have some privacy concerns. She knows that
Ben only releases the full CLAs if they're legally necessary to prove
ownership of SisterSpaces code. She wants to respect his privacy and
also doesn't want to clutter up in XID with the full contract.

A commitment of the contract offers a compromise that will meet her
needs to show off the connection but still protect Ben's privacy and
her own XID's accessability.

### Step 1: Create a Contract Edge

To record the contract, Amira will create a new self-attestation edge
that she is working on SisterSpaces.

As with any other edge, she first needs to define the three core
elements of the edge: `isA`, `source`, and `target`:

```
ISA="foaf:Project"
SOURCE_XID_ID=$XID_ID
TARGET_XID_ID=$XID_ID
```

To create the commitment of the contract she will use a similar
methodology to that of [§2.2](02_2_Managing_Claims_Elision.md): she
creates a digest of the CLA envelope.

```
DIGEST_CLA=$(envelope digest "$SIGNED_ACCEPTED_CLA")
```

However, there's a difference: in
[§2.2](02_2_Managing_Claims_Elision.md), we elided the envelope,
leaving only the digest. How we published that commitment was
hand-waved.  Here, we're going to offer a first method to do so: by
incorporating the digest into a claim that will be added to an
envelope as an edge. If anyone asks for more info they can ask
BRadvoc8 for the full contract, and she can decide whether it's
appropriate to give it out.

The commitment to the contract, as with the rest of the details of the
claim, are placed as a target subenvelope:

```
PROJECT_TARGET=$(envelope subject type ur $TARGET_XID_ID)
PROJECT_TARGET=$(envelope assertion add pred-obj string $ISA string "SisterSpaces" "$PROJECT_TARGET")
PROJECT_TARGET=$(envelope assertion add pred-obj known verifiableAt string "https://github.com/SisterSpaces/SecureAuth/CLAs/README.md" "$PROJECT_TARGET")
PROJECT_TARGET=$(envelope assertion add pred-obj string "claDigest" digest "$DIGEST_CLA" "$PROJECT_TARGET")
```

With those details, you can now put together the contract edge:

```
EDGE=$(envelope subject type string "project-sister-spaces-secureauth")
EDGE=$(envelope assertion add pred-obj known isA string "$ISA" "$EDGE")
EDGE=$(envelope assertion add pred-obj known source ur "$SOURCE_XID_ID" "$EDGE")
EDGE=$(envelope assertion add pred-obj known target envelope "$PROJECT_TARGET" "$EDGE")

echo "SisterSpaces edge details:"
envelope format "$EDGE"

| SisterSpaces edge details:
| 
| "project-sister-spaces-secureauth" [
|     'isA': "foaf:Project"
|     'source': XID(5f1c3d9e)
|     'target': XID(5f1c3d9e) [
|         "claDigest": Digest(cb26376e)
|         "foaf:Project": "SisterSpaces"
|         'verifiableAt': "https://github.com/SisterSpaces/SecureAuth/CLAs/README.md"
|     ]
| ]
```

This is a relatively simple edge, but that's because the CLA commitment stands in for the entire CLA!

### Step 2: Publish Your Contract Edge

You can now take the several steps to attach this edge and publish the result.

First, incorporate the edge:
```
WRAPPED_EDGE=$(envelope subject type wrapped "$EDGE")
SIGNED_EDGE=$(envelope sign --signer "$ATTESTATION_PRVKEYS" "$WRAPPED_EDGE")

XID_WITH_CONTRACT_EDGE=$(envelope xid edge add \
    --verify inception \
    $SIGNED_EDGE $XID_WITH_CONTRACT_KEY)
```

Second, advance the provenance mark, sign your envelope, and produce a public version:

```
XID_WITH_CONTRACT_EDGE=$(envelope xid provenance next \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$XID_WITH_CONTRACT_EDGE")
PUBLIC_XID_WITH_CONTRACT_EDGE=$(envelope xid export --private elide --generator elide "$XID_WITH_CONTRACT_EDGE")
```
Third, store everything:

```
echo "$PUBLIC_XID_WITH_CONTRACT_EDGE" > envelopes/BRadvoc8-xid-public-4-02.envelope
echo "$XID_WITH_CONTRACT_EDGE" > envelopes/BRadvoc8-xid-private-4-02.envelope
```

You've demonstrated how Amira highlights her new connection to
SisterSpaces while preserving privacy, but that's just half the story.

#### XID Version Comparison

You've now created a sixth XID edition of Amira's XID.  Here's another
overview of what each version contains

| XID Version | New Content | Created In |
|-------------|-------------|------------|
| seq 0 | 👤 Identity | §1.3+§1.4 |
| seq 1 | 🔑 Attestation Key | §2.1 |
| seq 2 | 🗣️ GitHub Edge | §3.1 |
| seq 3 | 🗣️ Endorsement Edge | §3.3 |
| seq 4 | 🔑 Contract Key | §4.1 |
| seq 5 | 📄 Contract Commitment | §4.2 |

## Part II: Incorporating a Contract into a Commitment List

Ben also needs to publish the CLA, to show everyone that his software
is safe to use, because he has contracts with all the authors. But,
Ben has 50 different people who have worked on SisterSpaces and signed
CLAs. He doesn't want all of that in his XID (or even in a XID he
created for SisterSpaces). Nor does he want to just publish those CLAs
separately, because of the privacy concerns.

His answer: a commitment list

### Step 3: Compute the Digests

Ben maintains a directory on his local encrypted drive of all of the
CLAs for SisterSpaces. Whenever he adds a CLA he runs a script that
regenerates a README.

```
cd private-cla-directory

echo "# CLA Commitment List" > README.md
echo "" >> README.md
echo "This is a list of commitments for CLAs guaranteeing rights to work done for SisterSpaces. CLAs are published as envelope-cli digest hashes to preserve privacy. Original CLAs are held by the Project Manager (currently Ben) and can be privately produced if necessary. This list is a living example of the power of herd privacy." >> README.md
echo "" >> README.md

for cla in *.envelope
do
  envelope digest $(cat $cla) >> README.md
done
```

This produces a file like the following:
```
# CLA Commitment List

This is a list of commitments for CLAs guaranteeing rights to work
done for SisterSpaces. CLAs are published as envelope-cli digest
hashes to preserve privacy. Original CLAs are held by the Project
Manager (currently Ben) and can be privately produced if
necessary.This list is a living example of the power of herd privacy.

ur:digest/hdcxnydmgooejsgwjywfnbaxotlgaotibdbzynroutlebgditsfrroreisihptytndmtlkhyidfs
ur:digest/hdcxcaoldkfpisoesfoxdnatamwyytasdwsbuomnkicxlbaavehsfzksmdinrogachhnsolbpahg
ur:digest/hdcxvwpkrfmokeonsalojefseovliertiykoimzcjkdwkswktiisdloskngokoiakistwnwlhfot
ur:digest/hdcxzewtfzfxrdndktdpeocwnnttbdoloxeyskyninhtpazehsgsynfpfwgrlbbgdskosefddktp
ur:digest/hdcxlkdtieyafsbkhdftbdgmztfxmoflgmpmlghladmkutfymundfmdrnbaeatspctclynkgsnen
ur:digest/hdcxhgfdesknwdrdmusgbspsbdgmjpflfwdafhhybgytdwcklskohpbtdkeskgrfvwaolycesnyn
ur:digest/hdcxayptgsktmssbhdsnfpetnsrppmsttlahlrtnaeyndloyvawsdmcxdesokgeomknnwfjklpnl
ur:digest/hdcxcaoldkfpisoesfoxdnatamwyytasdwsbuomnkicxlbaavehsfzksmdinrogachhnsolbpahg
ur:digest/hdcxvwpkrfmokeonsalojefseovliertiykoimzcjkdwkswktiisdloskngokoiakistwnwlhfot
ur:digest/hdcxzewtfzfxrdndktdpeocwnnttbdoloxeyskyninhtpazehsgsynfpfwgrlbbgdskosefddktp
ur:digest/hdcxlkdtieyafsbkhdftbdgmztfxmoflgmpmlghladmkutfymundfmdrnbaeatspctclynkgsnen
ur:digest/hdcxhgfdesknwdrdmusgbspsbdgmjpflfwdafhhybgytdwcklskohpbtdkeskgrfvwaolycesnyn
ur:digest/hdcxayptgsktmssbhdsnfpetnsrppmsttlahlrtnaeyndloyvawsdmcxdesokgeomknnwfjklpnl
ur:digest/hdcxinmerocyjzgrmhskpshyrfsnuthhpsjoswbyiyttstldaxytlsiefdcfytdebyhhgwzevwtl
ur:digest/hdcxsbdsemjtwlrtvwfdetmwenlujndlsbethljzkpnbmsgmchaajolsgekbpypmtijevolukglt
ur:digest/hdcxswjzwzjzzopawmieytwpjtgwlsoyfrhlntsghldsrnpstswsknehwsrltpeyonfriouooykp
ur:digest/hdcxhsimvekidtktvdvtahbwwdongttiidykimmwhntpadihasjsssmhynstqdrykijesoskvslg
ur:digest/hdcxwyflkitaplesgamojnjohhimjlfyqdlyuorsjyhprdrycmtoahgwvtfzlgamzcenbnnsfwhl
ur:digest/hdcxhlesrpmsfhkbfdcsdszmbemwtlotjynbqdcxmuisbsldktjsinzostwekbtohhsegapyiome
ur:digest/hdcxchrdpkuraaeedpmynscxihbttdhtmdrdndrtvsmdzetonyeosstngmtidaguzefngmmkjltk
ur:digest/hdcxftcmvyetfycslpwnlfswsngsamsndnaekizsmtwyglkepaplnbceltretbamoemtwpsedtrn
ur:digest/hdcxwyflkitaplesgamojnjohhimjlfyqdlyuorsjyhprdrycmtoahgwvtfzlgamzcenbnnsfwhl
ur:digest/hdcxmhmslyjlgrsespryvtfsaxceadyknntnveglrnfrbeossrknmodidahptygsrfcemerowzge
ur:digest/hdcxyarhehpdfyaynndassgtfxmwwpoydpglhtlkuylfnbhlrntybaynwnzokiosswctrsencmim
```

### Step 4: Publish a Commitment List

Once Ben generates his `README.md` file, he distributes it to the
`CLA` directories of all his project repos. The long list of
commitments guarantees herd privacy, but simultaneously promises that
the CLAs are available if they're needed to adjudicate a legal matter.

### Step 5: Check a Commitment

If that legal adjudication was ever required, Ben could supply the
appropriate CLA, for example Amira's, and the recipient could derive a digest from it:

```
BR_CLA_DIGEST=$(envelope digest $(cat cla-bradvoc8-accepted-4-01.envelope))
```

Afterward, they could verify that the digest had been in the published README file:
```
if grep -q $BR_CLA_DIGEST README.md; then
  echo "✅ CLA commitment was in README.md"
else
  echo "❌ CLA was not properly commited to"
fi

| ✅ CLA commitment was in README.md
```

Obviously, having the required CLA is the important part, but the fact
that Ben previously published it improves his own level of trust,
because when he has to reveal a CLA, he also proves that he stands
behind what he says in his commitments.

## Summary: Publishing Commitments for Privacy

In [§2.2](02_2_Managing_Claims_Elision.md), you learned how to make
commitments by creating an elided envelope. This section introduced a
second method, where you just store the digest and also proposed two
methods for publishing that commitment:

1. As part of a claim in an envelope.
2. As part of a long list protected by herd privacy.

These methodologies extend the power of commitments, providing more
ways than ever to improve the trust level of a pseudonymous
identifier.

### Additional Files

**Envelopes:** The
[envelopes](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/envelopes)
directory contains numerous data created in this section, the most
important of which are Amira's sixth
[private](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/envelopes/BRadvoc8-xid-private-4-02.envelope)
and
[public](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/envelopes/BRadvoc8-xid-public-4-02.envelope)
XIDs as well as [Ben's README](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/envelopes/cla-readme-4-02.md).


**Scripts:** Scripts demonstrating this section are forthcoming.

### Exercises

1. Commit to the contents of a file using `shasum`.
2. Commit to the contents of an envelope using the `digest` command.
3. Create an edge that records a commitment.
4. Dump a large set of commitments into a file and see how that helps to hide each individual commitment.

## What's Next

Though we've completed Amira's first arc, there's one open question:
has her XID gotten too big? [§4.3: Creating New Views](04_3_Creating_New_Views.md)
talks about how to
clean it up.

## Appendix I: Key Terminology

> **Commitment List**: A list of commitments, also offered with commentary or identification.

> **Herd Privacy**: A method for protecting the privacy of any
individual content by "hiding" it amidst a set of similarly looking
content.
