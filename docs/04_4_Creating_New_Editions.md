# 4.4: Creating New Editions

Views are a great way to practice data minimization. They allow you to
give each viewer a XID that contains the precise data that they should
see without changing the underlying content of your XID.

However, sometimes you want to do that as well. That's where new
editions come in.  And, though you've created a lot of new editions to
date, the ones in this section will be different, because they'll
_remove_ content.

> 🧠 **Related Concepts.** After completing this tutorial, explore
[Data
Minimization](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/concepts/data-minimization.md)
and [Elision
Cryptography](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/concepts/elision-cryptography.md).

## Objectives of this Section

After working through this section, a developer will be able to:

- Remove content from a XID.
- Update content in a XID.

Supporting objectives include the ability to:

- Understand what revocation means.
- Undestand the concept of implicit revocation.
- Learn more techniques for comparing provenance marks.

## Amira's Story: Updating a XID

DevReviewer's endorsement is a problem for Amira. She wants it in her
XID because it improves the reputation of her pseudonymous
identity. But, she doesn't want the information that's
correlatable. Eliding the correlatable statement was just a temporary
fix. It resolves Amira's privacy issue, but it weakens the endorsement
itself because viewers will know that Amira is purposefully hiding
part of it.

A better solution would be either: (1) to entirely remove the
endorsement, if Amira has other endorsement that fit the same need; or
(2) to replace the endorsement with a new, newly signed version that
doesn't contain the problem statement.

## The Power of Revocation

Sometimes an old document includes something that you no longer stand
by. It might contain dangerous information (such as in Amira's story);
it might contain out-of-date information (such as if Amira changed
where the master copy of her XID is); or it might contain something
that's become a problem (such as if you'd received an endorsement from
someone who afterward was kicked out of a community).

Revocation is when you reject a previous claim or other information
that you'd published. You could revoke a credential, an endorsement, a
key, a resolution method, or any other datum.

In Gordian Envelope, revocation is implicit. If a datum is present in
one version of a XID, but absent from later ones, then the datum has
implicitly been revoked. If instead an updated version of information
is available in the later XID, then the previous datum has been
revoked and the new one is now the up-to-date one.

Provenance marks can always be used to verify which edition of a XID
is the up-to-date one.

> 🔥 ***What is the Power of Revocation?** Nothing is forever! Revocation allows
you to say that something in some former version of your XID is no longer
valid, or at the very least, no longer supported by you.

### The Power of Explicit Revocation

Sometimes implicit revocation isn't enough. In this case you can
explicitly revoke something by creating and signing a statement saying
that the old content is no longer valid.
[§2.1](02_1_Creating_Self_Attestations/#step-15-retract-an-attestation)
contains an example of this pattern.

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

We're also going to again use `jq`, so make sure you've downloaded it
from [jqlang.org](https://jqlang.org/), or installed it with Homebrew
or some other package manager, else you won't be able to automate the
checking of provenance marks.

## Part I: Removing XID Objects

Amira keeps getting questions about the information she removed from
DevReviewer's endorsement. Her elision preserved her privacy, but even
with her being transparent about what she removed, she decreased the
value of the endorsement. As such, she decides to create a new edition
of her XID that removes DevReviewer's endorsement entirely.

### Step 1: Find the Object to Remove

Most top-level XID object types have a a `remove` command that allows
you to pass the `envelope` CLI both the object to remove and the base
XID. That means that the first thing to do is to find the object you
want to remove, which follows the same process that you used in the
last section when you were looking for digests.

In this case, you list out all the edges:
```
envelope xid edge all $XID
```
Then you find the edge you want to remove, with DevReviewer's endorsement. This is:
```
ur:envelope/lftpsplrtpsokseyjoihihjpdpihjtiejljpjkihjnihjtjydpiyjpjljndpieihkojpihkoinihktihjpdpeyetiyeeidenidiaeheteneoemiyieenoycfaornlstpsotanshdhdcximprmsaylgfwcyjzzcamzmdrbdetjsrngamnbsfptbwtksihrhzonsahuthydwtboytpsojkjkiaisihjnhsftihjnjojzjlkkihihgmjljzihtpsokscsfdihhsiecxguihiakpjpinjykkcxgdjpjliojphsjnjnihjpoytpsojljkiaisihjnhsftktjljpjejkfgjljptpsojzguinjkjyihjpgujohsiaihjkoycfaorslntpsotanshdhdcxhecefsnnionspljpftktetwymnfmcyecveuotktpwenlhyhdpmpykpchcmzchywzoytpsojsjpihjzhsjyinjljtjkisinjofwhsjkinjktpsoksiaguihiakpjpinjykkcxiajljzjzhsidjljphsjyinjljtcxjohsjpjyjtihjpcxktisjlcxkoihjpiniyinihiecxiajpihieihjtjyinhsjzjkcxjyisjpjlkpioiscxiajljnjninjydpjpihkoihhsjzcxhsjtiecxihjtiajpkkjojyihiecxjkishsjpinjtiooybetpsokoeydyeyendpdyeodpehehgheheofteceydpehdyftdydyoytpsojpihjtiejljpjkihjnihjtjyfxjljtjyihksjytpsokshghfihjpiyinihiecxjojpihkoinjlkpjkcxjkihiakpjpinjykkcxihksjoihjpinihjtiaihdwcxktjljpjeihiecxjyjlioihjyisihjpcxjljtcxjkisjljpjycxjojpjlimihiajycxiyjljpcxguinjkjyihjpgujohsiaihjkoytpsojljoihihjpfejtiejljpjkihjnihjtjytpsoksguhgjpinjyihjkcxjkihiakpjpihdwcxktihjzjzdpjyihjkjyihiecxiajlieihcxktinjyiscxiajzihhsjpcxhsjyjyihjtjyinjljtcxjyjlcxjojpinkohsiakkdpjojpihjkihjpkoinjtiocxjohsjyjyihjpjtjkoytpsojoihjtiejljpjkihjnihjtjyguiajljoihtpsoksfeguihiakpjpinjykkcxhsjpiaisinjyihiajykpjpihdwcxiajpkkjojyjliojphsjoisiniacxinjnjojzihjnihjtjyhsjyinjljtdwcxjojpinkohsiakkcxjohsjyjyihjpjtjkoyadtpsojehsjyjyihjkjyhsjyinjljtoyaxtpsotansghlfaohdfztotdmttbtkeojlgalkiywpdlhkckltcnlnleksaysntyrefegweygmasrlcyksplemghihynhscxnlspkonlhlemksiaadbewfdrieksehvypychmtteurwemktttiaxjegodrvt
```
We'll be storing that as `$DEV_EDGE`

### Step 2: Remove the Object

With the object to delete in hand, you use the appropriate `remove`
command such as `xid edge remove` to do so:

```
REDUCED_XID=$(envelope xid edge remove $DEV_EDGE $XID)
```

If you look at the output of your new `$REDUCED_EDGE`, you'll see that
the DevReviewer edge is *gone*. It's not elided: it was totally
removed in a new edition of your XID.

### Step 3: Publish Your XID

That's it! Removing content from a XID is easy.

As usual, you should make a new public view with an updated provenance mark:

```
REDUCED_XID=$(envelope xid provenance next \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$REDUCED_XID")
PUBLIC_REDUCED_XID=$(envelope xid export --private elide --generator elide "$REDUCED_XID")
```

And of course store everything:

```
echo "$REDUCED_XID" > envelopes/BRadvoc8-xid-s6-private-4-04.envelope
echo "$PUBLIC_REDUCED_XID" > envelopes/BRadvoc8-xid-s6-public-4-04.envelope
```

> 📖 **Do I elide or delete data?** You should elide data in your XID
if it still has a purpose: if you might want to show it to someone at
some time, if you could need it for some future use, or even if you
just want to keep it around for your own reference. You should instead
delete data only if it's no longer accurate, it no longer serves a
purpose, or if it's just cluttering up your XID.

## Part II: Checking for Revocation

SecurityMaintainer sees that BRadvoc8 has submitted a PR to his repo,
and he wants to know a bit about them before he accepts it. He ends up
with two copies of her XID, one with the DevReviewer endorsement and
one without. He needs to know: is it a new endorsement that wasn't
there before or an old endorsement that's been revoked? (The answer
depends on which edition of the XID is newer.)

## Step 4: Check Provenance Marks for Revocation

SecurityMaintainer has two copies of Amira's XID:
```
XID[0]=$(cat envelopes/BRadvoc8-xid-public-3-03.envelope)
XID[1]=$PUBLIC_REDUCED_XID
```

Best practice would be to use `derefenceVia` to go grab the newest
version of the XID, but SecurityMaintainer fails to! Fortunately, he
knows to look at the provenance marks.

```
PM[0]=$(envelope xid provenance get ${XID[0]})
PM[1]=$(envelope xid provenance get ${XID[1]})
```

Checking them tells him that he has two editions of the XID, but not neecessarily which is which:

```
$ provenance validate ${PM[0]} ${PM[1]}
Error: Validation failed with issues:
Total marks: 2
Chains: 1

Chain 1: 61a8fa60
  Warning: No genesis mark found
  3: e1b067a4
  6: 1d75e41b (gap: 4 missing)
```

He could look at each provenance mark, find the one with higher `seq`
and use that. But the following script does the job for him:


```
newseq=0
selectedi=-1
for i in $(seq 0 1)
do
  thisseq=$(provenance validate --warn --format json-compact ${PM[$i]} | jq -r ".chains.[0].sequences.[0].end_seq")
  if (( $thisseq > $newseq )); then
    newseq=$thisseq
    selectedi=$i
  fi
done

if (( $i >> 0 )); then
  echo "✅ Current version of XID is:"
  echo ""
  envelope format ${XID[$i]}
else
  echo "❌ No valid XIDs found"
fi  
```

SecurityMaintainer runs this script and is pointed to the `seq: 6`
version of Amira's XID.

Add this to your tool kit to accurately view the newest XID when
you're handed multiple ones.

## Part III: Replacing XID Objects

Hearing about the problem with her endorsement, DevReviewer creates a
new peer endorsement for Amira, usable as an edge if Amira desires.

Replacing an element in a XID is easy: you remove the old object, just
like you did in Part I, then you add in the new object. As it happens,
Amira published her BRadvoc8 XID in between, but that doesn't have to
happen. An edition with old content followed by a new edition with new
content implicitly revokes the old content just as well as publishing
an edition without the content at all.

## Step 5: Find and Remove Old Content

First you need to find the old content and remove it, per steps 1-2
above. In this case, Amira has alreayd removed the old peer
endorsement.

## Step 6: Prepare the New Content

Next, you must prepare the new content that will be replacing the old
content. In this case, DevReviewer sends Amira a new Gordian Envelope:

```
REVIEWER_SIGNED_EDGE=ur:envelope/lftpsplrtpsokseyjoihihjpdpihjtiejljpjkihjnihjtjydpiyjpjljndpieihkojpihkoinihktihjpdpeeehiaeshsenieehidehhseyihiyesenoycfaornlstpsotanshdhdcximprmsaylgfwcyjzzcamzmdrbdetjsrngamnbsfptbwtksihrhzonsahuthydwtboytpsojkjkiaisihjnhsftihjnjojzjlkkihihgmjljzihtpsokscsfdihhsiecxguihiakpjpinjykkcxgdjpjliojphsjnjnihjpoytpsojljkiaisihjnhsftktjljpjejkfgjljptpsojzguinjkjyihjpgujohsiaihjkoycfaorslntpsotanshdhdcxhecefsnnionspljpftktetwymnfmcyecveuotktpwenlhyhdpmpykpchcmzchywzoytpsojpihjtiejljpjkihjnihjtjyfxjljtjyihksjytpsoksglhfihjpiyinihiecxjojpihkoinjlkpjkcxihksjoihjpinihjtiaihdwcxktjljpjeihiecxjyjlioihjyisihjpcxjljtcxjkisjljpjycxjojpjlimihiajycxiyjljpcxguinjkjyihjpgujohsiaihjkoybetpsokoeydyeyendpdyeedpdyehghdyetfteyecdpehdyftdydyoytpsojsjpihjzhsjyinjljtjkisinjofwhsjkinjktpsoksiaguihiakpjpinjykkcxiajljzjzhsidjljphsjyinjljtcxjohsjpjyjtihjpcxktisjlcxkoihjpiniyinihiecxiajpihieihjtjyinhsjzjkcxjyisjpjlkpioiscxiajljnjninjydpjpihkoihhsjzcxhsjtiecxihjtiajpkkjojyihiecxjkishsjpinjtiooytpsojljoihihjpfejtiejljpjkihjnihjtjytpsoksguhgjpinjyihjkcxjkihiakpjpihdwcxktihjzjzdpjyihjkjyihiecxiajlieihcxktinjyiscxiajzihhsjpcxhsjyjyihjtjyinjljtcxjyjlcxjojpinkohsiakkdpjojpihjkihjpkoinjtiocxjohsjyjyihjpjtjkoytpsojoihjtiejljpjkihjnihjtjyguiajljoihtpsoksfeguihiakpjpinjykkcxhsjpiaisinjyihiajykpjpihdwcxiajpkkjojyjliojphsjoisiniacxinjnjojzihjnihjtjyhsjyinjljtdwcxjojpinkohsiakkcxjohsjyjyihjpjtjkoyadtpsojehsjyjyihjkjyhsjyinjljtoyaxtpsotansghlfaohdfzbzfslnetykknhplpwmhhcmcnwtfrwftogtrdadjtaxbsjkptmsmesbotldcstngyteisfhrntecemkoxtpueinjtmtfdrtvebwvtasbdcxeclafphthtfylfhgrhlabntabgpsmy
```

Amira looks over the new endorsement and see that DevReviewer made one
simple modification: they changed "previous security experience" to
"previence experience." That's what Amira needed!

```
$ envelope format $REVIEWER_SIGNED_EDGE
{
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
```

## Step 7: Insert New Content

Amira inserts the updated peer endorsement into her XID as usual:
```
XID_WITH_NEW_EDGE=$(envelope xid edge add \
    --verify inception \
    $REVIEWER_SIGNED_EDGE $REDUCED_XID)
```

## Step 8: Publish Updated XID

Finally, Amira updates the provenance mark and produces a new public view:

```
XID_WITH_NEW_EDGE=$(envelope xid provenance next \
    --password "$PASSWORD" \
    --sign inception \
    --private encrypt \
    --generator encrypt \
    --encrypt-password "$PASSWORD" \
    "$XID_WITH_NEW_EDGE")
PUBLIC_XID_WITH_NEW_EDGE=$(envelope xid export --private elide --generator elide "$XID_WITH_NEW_EDGE")
```

She'll upload that to GitHub, while we'll save a copy:

```
echo "$XID_WITH_NEW_EDGE" > envelopes/BRadvoc8-xid-s7-private-4-04.envelope
echo "$PUBLIC_XID_WITH_NEW_EDGE" > envelopes/BRadvoc8-xid-s7-public-4-04.envelope
```

#### XID Version Comparison

Over the course of this section, Amira created two more editions of
her XID, as she first removed, then replaced DevReviewer's
endorsement.

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

> ⚠️ **XIDs Are Forever!** Though Amira removed the endorsement with
the possibly correlatable information, the old edition is probably
still out there on the 'net. Revoking content in an old XID doesn't
remove it from the net! Worse, it might draw attention to what you've
changed. Making sure that her current XID has the safer information
was probably the right answer for Amira, but this demonstrates how you
always need to think carefully about what you publish, because in the
internet age, it'll be around forever.

## Summary: Creating New Editions

You have two options when making changes to your XID. As you saw in
[§4.3](04_3_Creating_New_Views.md), you can create different views
with elision, following the principle of [data
minimization](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/concepts/data-minimization.md)
so that each person only sees what they need to see.

However, you can also entirely remove content from your XID (and
possibly replace it as well). This creates an _implicit revocation_:
you're saying that the old information is no longer valid for some
reason. Doing so is easy: you just `remove` the old content (and
optionally use commands you've used before to replace it).

### Additional Files

**Envelopes:** The
[envelopes](https://github.com/BlockchainCommons/XID-Quickstart/tree/main/envelopes)
directory contains data created in this section, including the [seq:
6](BRadvoc8-xid-s6-public-4-05.envelope) and the [seq:
7](BRadvoc8-xid-s7-public-4-05.envelope) versions of Amira's envelope.

**Scripts:** Scripts demonstrating this section are forthcoming.

### Exercises

1. Find the UR: for both an edge and a key.
2. Permanently remove an edge or key from a XID.
3. Add in a new edge or key to replace the old one.
4. Find the newest XID from several different editions.

## What's Next

We'll be returning soon with Chapter Five and keys, but for the moment, this course is at an end.

## Appendix I: Key Terminology

> **Explicit Revocation** - A separate statement of revocation, usually issued as a signed document.
>
> **Implicit Revocation** - A statement of revocation that is implicit in the fact that some data is not in the newest edition of an identity.
>
> **Revocation** - The cancellation of something, here the removal of content from an identity document to say that it's no longer valid, supported, or relevant.


