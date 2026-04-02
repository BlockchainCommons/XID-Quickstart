# 3.2: Supporting Cross Verification

In [§3.1](03_1_Creating_Edges.md), Amira added her GitHub account and
SSH signing key to her XID via an edge.This was another
self-attestation, but it was stronger than previous self-attestations
because it could be checked against an independent source (GitHub).
This section demonstrates how DevReviewer cross-verifies Amira's
attestations against that external source, allowing Amira to
demonstrate proof of control.

> 🧠 **Related Concepts**: This tutorial demonstrates verification
from the relying party's perspective. See [Progressive
Trust](../concepts/progressive-trust.md) for how trust accumulates
through evidence, and [Attestation & Endorsement
Model](../concepts/attestation-endorsement-model.md) for understanding
what claims vs endorsements prove.

## Objectives of this Section

After working through this section, a developer will be able to:

- Extract attestations from XID edges.
- Verify claims against GitHub's API.
- Check Git commit signatures.
- Compare multiple provenance marks.

Supporting objectives include the ability to:

- Understand how temporal anchors establish when claims became valid.
- Know what cross-verification proves (and its limits).
- Understand what provenance marks can do (and what they can't).

## DevReviewer's Story: Verifying Claims

DevReviewer asked BRadvoc8 for one last bit of data: proof of control
of the BRadvoc8 GitHub account. Having that will allow DevReviewer to
verify a lot of claims that were previously only lightly supported,
like Amira's work on the Galaxy Project and other PRs that she's
produced.

Amira supported this request by creating an edge on her XID that not
only officially recognized the BRadvoc8 GitHub account as belonging to
the BRadvoc8 XID, but also included a signature from a key registered
with that account. This will allow DevReviewer to engage in
cross-verification to further check BRadvoc8's claims.

So, does BRadvoc8 check out?

> 📖 **What is Cross-Verification?** Cross-verification is the process
of checking a claim against multiple independent sources. If all
sources agree, confidence increases. If sources conflict, the claim is
suspect.

## Part 0: Verify Dependencies

This section requires the installation of `jq`, which will make JSON
content easier to access. You can download it at
[jqlang.org](https://jqlang.org/), but you may also be able to install
it with Homebrew or other package managers.

If you do not install JQ then you'll simpy need to fill in variables
by hand instead of having it automated.

As usual, also check your `envelope-cli` version:
```
envelope --version

│ bc-envelope-cli 0.34.1
```

> ⚠️ **Network Required!** This tutorial queries external APIs
(GitHub). Verification will fail if you're offline or if the external
services are unavailable. In production, cache API responses and
handle network failures gracefully.

## Part I: Inspecting the XID

The cross-verification begins with the retrieval of the XID and a
check of its internal consistency.

### Step 1: Fetch the XIDDoc

For the fullest cross-verification, DevReviewer would retrieve Amira's
most up-to-date edition of their XID from the `dereferenceVia` URL:

```
XID_URL="https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt"
FETCHED_XID=$(curl -sL "$XID_URL")
```

To get the precise version intended for this tutorial, you should
instead retrieve it from the `envelopes` directory, as usual, but this
time we're going to be looking at the public view, as a viewer rather
than an editor:

```
FETCHED_XID=$(cat envelopes/BRadvoc8-xid-public-3-01.envelope)
```

### Step 2: Verify Self-Consistency

Before checking external sources, verify that the XID is internally
consistent and has been signed by its own key.

We learned in [§2.1](02_1_Creating_Self_Attestations.md), one method
for extracting all the keys from a XID and checking them, which we
repeat here:

```
read -d '' -r -a PUBKEY <<< $(envelope xid key all "$FETCHED_XID")
for i in "${PUBKEY[@]}"
  do
    if envelope verify -v $i $FETCHED_XID >/dev/null 2>&1; then
      echo "✅ One of the signatures verified! "
      echo $i
    fi
done

| ✅ One of the signatures verified! 
| ur:envelope/lrtpsotansgylftanshflfaohdcxolmystmtwyhhgljscpamingewnkplnpssfmnsnlramdwclkpkswmkstbfgdngdtotansgrhdcxsoeymskoiyrseswelubkspfdhllpmyksrpmkcmwzaoplwdlrfhzoropslpnlcmadoycscstpsoisfwgmhsiekojliaetoycsfncsfghdcxvdfpnltylrmowtutatkedsgresehiednenuthnveclgthgutprdlynoeuepkmnwtvlbwhndt

```

Self-consistency is necessary but not sufficient. It proves the
document wasn't tampered with after signing, not that the claims
inside are true.

### Step 3: Verify Provenance Consistency

DevReviewer also checks the provenance mark to ensure that it's valid and
to see what edition of the XID they're looking at.

```
PROVENANCE_MARK=$(envelope xid provenance get "$FETCHED_XID")
provenance validate --format json-pretty "$PROVENANCE_MARK"

| Error: Validation failed with issues:
| {
|   "marks": [
|     "ur:provenance/lfaxhdimwpenbadrpkylftpdcysglohkhlwsdwwzfsineodwbgaezowkstehdwsnmtrnrptarooyiybaseldcnfdahehdedkuygrtiescmcxmsrnvtylfhlewegyotayhkfsuramlbpezsaylrcsjyotbysobektlywmprgmmkwspdctlgtodrtsvdbngljzromnfynddpceatkschjltkmslshnuectfnos"
|   ],
|   "chains": [
|     {
|       "chain_id": "61a8fa603b7ebe4bad7bb82fc5858b9d55fda26811e1070b44d80369486c6202",
|       "has_genesis": false,
|       "marks": [
|         "ur:provenance/lfaxhdimwpenbadrpkylftpdcysglohkhlwsdwwzfsineodwbgaezowkstehdwsnmtrnrptarooyiybaseldcnfdahehdedkuygrtiescmcxmsrnvtylfhlewegyotayhkfsuramlbpezsaylrcsjyotbysobektlywmprgmmkwspdctlgtodrtsvdbngljzromnfynddpceatkschjltkmslshnuectfnos"
|       ],
|       "sequences": [
|         {
|           "start_seq": 2,
|           "end_seq": 2,
|           "marks": [
|             {
|               "mark": "ur:provenance/lfaxhdimwpenbadrpkylftpdcysglohkhlwsdwwzfsineodwbgaezowkstehdwsnmtrnrptarooyiybaseldcnfdahehdedkuygrtiescmcxmsrnvtylfhlewegyotayhkfsuramlbpezsaylrcsjyotbysobektlywmprgmmkwspdctlgtodrtsvdbngljzromnfynddpceatkschjltkmslshnuectfnos",
|               "issues": []
|             }
|           ]
|         }
|       ]
|     }
|   ]
| }
```

The output shows `has_genesis: false` because Ben only has the current
provenance mark (seq 2), not the original genesis mark (seq 0). The
`start_seq: 2, end_seq: 2` confirms this is the third edition.

If this utility seems limited, it is: all a singular provenance mark
can tell you is that the provenance mark is valid and what edition it
is. The power of provenance marks comes with the ability to compare
different marks, and we've now got enough to finally make that
meaningful.

### Step 4: Compare Provenance Marks

Provenance marks become more powerful when you have several provenance
marks to compare. In this case, we have coopies of each of the
previous editions of Amira's XID. We can extract a provenance mark
from each of those XIDs:

```
XID_0=$(cat envelopes/BRadvoc8-xid-public-1-03.envelope)
XID_1=$(cat envelopes/BRadvoc8-xid-public-2-01.envelope)
PM_0=$(envelope xid provenance get $XID_0)
PM_1=$(envelope xid provenance get $XID_1)
PM_2=$PROVENANCE_MARK
```

We've numbered the variables for each of the provenance marks for
clarity. This was easy because we knew which edition each provenance
mark corresponded to. But even if you don't, you can figure it out
from the mark itself. As we've seen previously, we just need to
extract the `end_seq` value:

```
$ provenance validate --format json-compact "$PM_0" 2>&1 | grep -o '"end_seq":[0-9]*'
"end_seq":0
$ provenance validate --format json-compact "$PM_1" 2>&1 | grep -o '"end_seq":[0-9]*'
"end_seq":1
$ provenance validate --format json-compact "$PM_2" 2>&1 | grep -o '"end_seq":[0-9]*'
"end_seq":2
```

Just knowing these numbers is important because it will allow you
identify which object of several that you hold is the most
up-to-date. For Amira's XIDs, we could extract all of the provenance
marks, then know that the one that held the `"end_seq": 2` mark was
the newest.

The next power of provenance marks is that it will show that two marks
are from the same chain. Take the following example of a comparison of
the first and third marks. It shows `Total marks: 2`, but `Chains: 1`.

```
$ provenance validate $PM_0 $PM_2
Error: Validation failed with issues:
Total marks: 2
Chains: 1

Chain 1: 61a8fa60
  0: 1896ba49 (genesis mark)
  2: 0f300aba (gap: 1 missing)
```

This also shows which marks we have (`0` and `2`) and which are missing (`1`).

This is probably the most important provenance mark check after simple
validation. It tells you that a newer XID is related to an earlier,
trusted XID that you hold.

Looking at the second two marks yields similar results:
```
$ provenance validate $PM_1 $PM_2
Error: Validation failed with issues:
Total marks: 2
Chains: 1

Chain 1: 61a8fa60
  Warning: No genesis mark found
  1: 1d640bb3
  2: 0f300aba
```

Often that's all you need to know: which object bears the newest mark;
and that multiple objects are from the same chain. That verifies that
the newest mark is not a fake or counterfeit, but belongs to the chain
of an earlier object that you trusted.

However, there are use cases when you want to know that you have every
object in a chain, such as when you're checking revisions. Provenance
marks will tell you this too. The following example gives no response,
which means there was no error:

```
$ provenance validate $PM_0 $PM_1 $PM_2

| ✅ Provenance chain is complete
```

> 🔥 **What is the Power of Provenance Marks?** Provenance marks link
together multiple editions of the same object. They tell you which is
newest and that the objects are part of the same cryptographically
linked chain. In addition, they can tell you if you have all editions
of an object.

#### What if a Provenance Chain is Invalid?

There are two ways that a provenance chain could be invalid: because
you accidentally grouped together multiple editions of different
objects or because someone created a fradulent XID not from the chain
of a previous XID you have.

You can simulate this by creating a new XID and extracting its provenance mark:
```
XID_N=$(envelope generate keypairs --signing ed25519 \
    | envelope xid new \
    --nickname "test_xid" \
    --sign inception)
PM_N=$(envelope xid provenance get $XID_C)
```
When you compare that with Amira's newest edition provenance mark, you'll see that they're from different chains:
```
$ provenance validate $PM_N $PM_2
Error: Validation failed with issues:
Total marks: 2
Chains: 2

Chain 1: 61a8fa60
  Warning: No genesis mark found
  2: 0f300aba

Chain 2: ba3c752b
  0: 95698b96 (genesis mark)
```
As noted above, this is the most important test. Its failure tells you
that either you've made a mistake or you're the target of an attack.

## Part II: Verifying the GitHub Attestation

Now that DevReviewer has verified that BRadvoc8's XID is valid and
that it's properly linked to their previous XIDs, they can assess
whether BRadvoc8 has actually established proof of control of the
BRadvoc8 GitHub account. This is done by extracting and verifying the
edge that makes the claim of GitHub ownership and then checking that
its signature was made by a GitHub key.

### Step 5: Extract the GitHub Attachment

To verify the signature of an edge first requires extracting the edge
from the XID. Extrarcting most of the native XID predicates is pretty
easy, because they're all structured. The `xid edge all` command will
extract every edge from a XID.

```
XID_EDGE=$(envelope xid edge all $FETCHED_XID)
```

If you have multiple edges, you'd need to figure out which one to use
(again, see §4.3), but when you just have one, as is the case here,
the extraction is all that's required.
```
echo "✅ Found edge:"
envelope format "$XID_EDGE"

| ✅ Found edge:
| 
| {
|     "account-credential-github" [
|         'isA': "foaf:OnlineAccount"
|         'source': XID(5f1c3d9e)
|         'target': XID(5f1c3d9e) [
|             "foaf:accountName": "BRadvoc8"
|             "foaf:accountServiceHomepage": URI(https://github.com/BRadvoc8/BRadvoc8)
|             "sshSigningKey": SigningPublicKey(c75b2f19, SSHPublicKey(b3e7a8b0))
|             "sshSigningKeyText": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiOtuf9hwDBjNXyjvjHMKeLQKyzT8GcH3tLvHNKrXJe BRadvoc8@Mac.attlocal.net"
|             "sshSigningKeysURL": URI(https://api.github.com/users/BRadvoc8/ssh_signing_keys)
|             'conformsTo': URI(https://github.com)
|             'date': "2026-03-18T11:55-10:00"
|             'verifiableAt': URI(https://api.github.com/users/BRadvoc8)
|         ]
|     ]
| } [
|     'signed': Signature(SshEd25519)
| ]
```

The edge contains everything DevReviewer needs for verification: the
claimed GitHub username (`"BRadvoc8"`), a
`foaf:accountServiceHomepage` URL pointing to the GitHub account
itself, the SSH signing key in text format, the SSH signing key in UR
format, a timestamp, and a signature from the SSH key itself.  Each
piece plays a role in the verification chain that they're about to build.

### Step 6: Extract the Claimed SSH Key

DevReviewer now needs to extract the SSH public keys (and other
information) that they'll use for the purpose of cross-verification.

[§1.4](01_4_Making_a_XID_Verifiable.md) briefly talked about how to
extract data from a XID. Generally, you need to iteratively cut an
envelope down to the point where you just have a subject and a set of
assertions, and then pull out the assertions that you want. (Again,
more on this in [§4.3](04_3_Creating_New_Views.md).)

To do so here requires stepping down through the envelope three times:
```
UNWRAPPED_EDGE=$(envelope extract wrapped "$XID_EDGE")
EDGE_TARGET=$(envelope assertion find predicate known 'target' "$UNWRAPPED_EDGE")
EDGE_CLAIM=$(envelope extract object $EDGE_TARGET)
```
1. We unwrap the edge.

```
| "account-credential-github" [
|     'isA': "foaf:OnlineAccount"
|     'source': XID(5f1c3d9e)
|     'target': XID(5f1c3d9e) [
|         "foaf:accountName": "BRadvoc8"
| 	...
|     ]
| ]    
```

2. We find the predicate `target`.

```
| 'target': XID(5f1c3d9e) [
|     "foaf:accountName": "BRadvoc8"
|     ...
| ]
```

3. We extract that predicate's object.

```
| XID(5f1c3d9e) [
|     "foaf:accountName": "BRadvoc8"
|     "foaf:accountServiceHomepage": URI(https://github.com/BRadvoc8/BRadvoc8)
|     "sshSigningKey": SigningPublicKey(c75b2f19, SSHPublicKey(b3e7a8b0))
|     "sshSigningKeyText": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiOtuf9hwDBjNXyjvjHMKeLQKyzT8GcH3tLvHNKrXJe BRadvoc8@Mac.attlocal.net"
|     "sshSigningKeysURL": URI(https://api.github.com/users/BRadvoc8/ssh_signing_keys)
|     'conformsTo': URI(https://github.com)
|     'date': "2026-03-18T11:55-10:00"
|     'verifiableAt': URI(https://api.github.com/users/BRadvoc8)
| ]
```

That leaves us with a simple subject `XID(5f1c3d9e)` and its
assertions, and we can at this point use `find` to grab any of those
assertions. We want three of them: the GitHub user name, the UR key,
and the plain text key.

```
USERNAME=$(envelope assertion find predicate string "foaf:accountName" "$EDGE_CLAIM" | envelope extract object | envelope format | tr -d '"')
CLAIMED_KEY_UR=$(envelope assertion find predicate string "sshSigningKey" "$EDGE_CLAIM"  | envelope extract object | envelope extract ur)
CLAIMED_KEY_TEXT=$(envelope assertion find predicate string "sshSigningKeyText" "$EDGE_CLAIM" | envelope extract object | envelope format | tr -d '"')

echo "SSH key claimed $USERNAME GitHub account"
echo "$CLAIMED_KEY_UR"
echo "$CLAIMED_KEY_TEXT"

│ SSH key claimed BRadvoc8 GitHub account
| ur:signing-public-key/tanehsksimjkjkisdpihieeyececehescxfpfpfpfpfxeoglknhsfxehjzhtfygaehglghfeecfpfpfpfpgagwingwjykpiyesisktfyfwimglhdkkimkoimfdgtgrihgsgygrkkknghetfliafdeojygskofdglgrjphdgeihcxfwgmhsiekojliaetfzgthsiadmhsjyjyjzjliahsjzdmjtihjyoxjlkbdw
| ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiOtuf9hwDBjNXyjvjHMKeLQKyzT8GcH3tLvHNKrXJe BRadvoc8@Mac.attlocal.net
```

For all three bits of data, we find the appropriate predicate, extract
its object, and then massage that text as appropriate.

DevReviewer now has the UR and plain text of the public key that
BRadvoc8 claims is the same one they used on GitHub.

### Step 7: Query GitHub's API

One more puzzle piece is required before we can begin verifying: retrieving the public key from GitHub.

```
echo "Querying GitHub API for $USERNAME's signing keys..."
GITHUB_KEYS=$(curl -s "https://api.github.com/users/$USERNAME/ssh_signing_keys")
GITHUB_KEY=$(echo "$GITHUB_KEYS" | jq -r '.[0].key')

echo "GitHub API response:"
echo "$GITHUB_KEYS" | jq '.[0] | {key, created_at}'

| Querying GitHub API for BRadvoc8's signing keys...
|
| GitHub API response:
| $ echo "$GITHUB_KEYS" | jq '.[0] | {key, created_at}'
| {
|   "key": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiOtuf9hwDBjNXyjvjHMKeLQKyzT8GcH3tLvHNKrXJe",
|   "created_at": "2025-05-10T02:15:26.791Z"
| }
```

DevReviewer now has two pieces of data: the key claimed in the XID (in
two different forms) and the key registered on GitHub.

> ⚠️ **API Rate Limits**: GitHub's API allows 60 unauthenticated
requests per hour per IP. For automated verification, consider using a
GitHub personal access token to increase the limit to 5,000
requests/hour. If you receive a 403 response, wait for the rate limit
to reset.

### Step 8: Compare Keys

You can now compare all the keys.

> 📖 **Why do we have the key in two different forms?** The XID's text
key can easily be compared to GitHub's key, while the XID's UR key can
be used to check the edge's signature.

First, does the GitHub key match the plain text version of the public
key included in the XID?

Determining this requires converting the two keys into arraies, so
that we can just check the first two values (the key type and the key)
and not any notes that might be at the end of the key file.


```
GITHUB_KEY_ARRAY=( $GITHUB_KEY )
CLAIMED_KEY_ARRAY=( $CLAIMED_KEY_TEXT )

echo "Claimed text key: ${CLAIMED_KEY_ARRAY[0]} ${CLAIMED_KEY_ARRAY[1]}"
echo "GitHub key:       ${GITHUB_KEY_ARRAY[0]} ${GITHUB_KEY_ARRAY[1]}"

if [ "${CLAIMED_KEY_ARRAY[0]}" = "${GITHUB_KEY_ARRAY[0]}" ] &&
   [ "${CLAIMED_KEY_ARRAY[1]}" = "${GITHUB_KEY_ARRAY[1]}" ]; then
    echo ""
    echo "✅ GITHUB KEY MATCHES - XID claim matches GitHub registry"
else
    echo ""
    echo "❌ KEYS DO NOT MATCH - GitHub and XID Text Key Do Not Match"
fi

| Claimed text key: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiOtuf9hwDBjNXyjvjHMKeLQKyzT8GcH3tLvHNKrXJe
| GitHub key:       ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiOtuf9hwDBjNXyjvjHMKeLQKyzT8GcH3tLvHNKrXJe
|
| ✅ GITHUB KEY MATCHES - XID claim matches GitHub registry
```

Second, does the plain version of the key in the XID match the UR
version of the key in the XID?

```
EXPORTED_KEY_UR=$(envelope export "$CLAIMED_KEY_UR")
EXPORTED_KEY_ARRAY=( $EXPORTED_KEY_UR )

echo ""
echo "Claimed text key: ${CLAIMED_KEY_ARRAY[0]} ${CLAIMED_KEY_ARRAY[1]}"
echo "Claimed UR key:   ${EXPORTED_KEY_ARRAY[0]} ${EXPORTED_KEY_ARRAY[1]}"

if [ "${CLAIMED_KEY_ARRAY[0]}" = "${EXPORTED_KEY_ARRAY[0]}" ] &&
   [ "${CLAIMED_KEY_ARRAY[1]}" = "${EXPORTED_KEY_ARRAY[1]}" ]; then
    echo ""
    echo "✅ KEYS MATCH - Both XID keys match "
else
    echo ""
    echo "❌ KEYS DO NOT MATCH - XID keys do not match "
fi

| Claimed text key: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiOtuf9hwDBjNXyjvjHMKeLQKyzT8GcH3tLvHNKrXJe
| Claimed UR key:   ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiOtuf9hwDBjNXyjvjHMKeLQKyzT8GcH3tLvHNKrXJe
|
| ✅ KEYS MATCH - Both XID keys match 

```

At this point you know:

🔑 GitHub = 🔑 in XID (text) = 🔑 in XID (UR)

But anyone could publish that GitHub key in their XID, so there's one more step.

#### What If the Keys Don't Match?

What would DevReviewer see if someone created a fake XID with a different key?

```
FAKE_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFakeKeyThatDoesNotMatchGitHub"
FAKE_KEY_ARRAY=( $FAKE_KEY )

echo "Fake key:   ${FAKE_KEY_ARRAY[0]} ${FAKE_KEY_ARRAY[1]}"
echo "GitHub key: ${GITHUB_KEY_ARRAY[0]} ${GITHUB_KEY_ARRAY[1]}"

if [ "${FAKE_KEY_ARRAY[0]}" = "${GITHUB_KEY_ARRAY[0]}" ] &&
   [ "${FAKE_KEY_ARRAY[1]}" = "${GITHUB_KEY_ARRAY[1]}" ]; then
    echo ""
    echo "✅ GITHUB KEY MATCHES - XID claim matches GitHub registry"
else
    echo ""
    echo "❌ KEYS DO NOT MATCH - GitHub and XID Text Key Do Not Match"
fi

| Fake key:   ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFakeKeyThatDoesNotMatchGitHub
| GitHub key: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiOtuf9hwDBjNXyjvjHMKeLQKyzT8GcH3tLvHNKrXJe
|
| ❌ KEYS DO NOT MATCH - GitHub and XID Text Key Do Not Match
```

This is why cross-verification matters. An attacker can create a
self-consistent XID (valid signature), but they can't fake GitHub's
registry. The mismatch exposes the forgery.

These scripts would give a similar response if no signing key was
found in GitHub, because the `""` key would not be the same as the key
reported in the XID. So, seeing an error may actually require more
investigation to determine the root cause.

### Step 9: Verify Keys

One last step is required: BRadvoc8 must prove that they actually
control the private key that links to the public key on GitHub.

This is easy. DevReviewer just needs to check that the edge with the
claim was signed with the linked private key:

```
envelope verify --verifier $CLAIMED_KEY_UR -s $XID_EDGE  2>&1 || true

| ✅ (silence means success)
```

We already know that the claimed key UR matches the claimed key text
and that the claimed key text matches the GitHub key. Therefore, this
shows that the controller of the BRadvoc8 XID has the signing key for
the GitHub account.

Is this proof of control? It's pretty close. Technically, Amira hasn't
proven that she controls the account, because she hasn't shown that
she controls the _authentication_ key that allows logins, but she has
shown that she controls the GitHub account's registered signing key,
and at the least that's another strong addition along the path of
progressive trust ... and one that can be strengthened if we can show
that the signing key has been in long usage on the GitHub account.

> 📖 **What is Proof of Control?** You can prove you control an
account or other resource in multiple ways. Commonly you'll be asked
to add content to a a resource (e.g., a specific URL). Alternatively,
as shown here, you can prove that you hold a secret in use by the
resource.

## Part III: Temporal Anchors

DevReviewer has verified the *what*: the SSH key in BRadvoc8's XID
matches GitHub's registry. But verification is strengthened if you can
also show *when*. Just as with the commitment in
[§2.2](02_2_Managing_Claims_Elision.md ), the longer that signing key
has been on the GitHub account, the more likely it is to be
legitimate, and not a latter-day addition.

### Step 10: Check GitHub's Timestamp

GitHub records when each signing key was added:

```
GITHUB_CREATED=$(echo "$GITHUB_KEYS" | jq -r '.[0].created_at')
echo "Key registered on GitHub: $GITHUB_CREATED"

│ Key registered on GitHub: 2025-05-10T02:15:26.791Z
```

This is a temporal anchor from an external source: GitHub's server
timestamped when BRadvoc8 registered their signing key. DevReviewer
can trust this more than a XID's internal claim of dating because
GitHub is an independent party.

> 📖 **What is a Temporal Anchor?** A temporal anchor is an
external timestamp that establishes when something occurred. Unlike
internal claims (which the claimant controls), temporal anchors come
from independent parties: GitHub's API, commit dates, blockchain
timestamps, or signed inception commits.

This strengthens Amira's proof of control, because it shows that she
not only holds the signing key for the GitHub account, but it's been
the signing key for an extended amount of time.

### Step 11: Cross-Reference Provenance

To further verify improve the temporal anchor, DevReviewer can also
compare the GitHub key registration date to the XID edge creation
date.

```
CLAIMED_DATE=$(envelope assertion find predicate known "date" "$EDGE_CLAIM" | envelope extract object | envelope format | tr -d '"')

echo "Timeline analysis:"
echo "  - GitHub key registered: $GITHUB_CREATED"
echo "  - XID edge created:      $CLAIMED_DATE"

│ Timeline analysis:
|   - GitHub key registered: 2025-05-10T02:15:26.791Z
|   - XID edge created:      2026-03-18T11:55-10:00
```

This is a less powerful verification because the XID edge's date was a
self-attestation. Nonetheless, if there was a discrepency (e.g., the
XID edge was created before the GitHub key was registered, despite
being a claim about that key's registration), it would set off red
flags 🚩🚩.

### Step 12: Check Commit Signatures (Optional)

There's one last thing that DevReviewer can do to strengthen the
temporal ancho: they can look at the commits in the BRadvoc8 account.

```
echo "Checking commit signatures..."
COMMIT_URL="https://api.github.com/repos/BRadvoc8/BRadvoc8/commits"
RECENT_COMMIT=$(curl -s "$COMMIT_URL" | jq -r '.[].sha'|head -1)
OLD_COMMIT=$(curl -s "$COMMIT_URL" | jq -r '.[].sha'|tail -1)

echo ""
echo "Most recent commit: $RECENT_COMMIT"
echo "Recent verification status:"
curl -s "https://api.github.com/repos/BRadvoc8/BRadvoc8/commits/$RECENT_COMMIT" | \
    jq '{date: .commit.author.date, verified: .commit.verification.verified, reason: .commit.verification.reason}'
echo ""
echo "Older commit: $OLD_COMMIT"
echo "Old verification status:"
curl -s "https://api.github.com/repos/BRadvoc8/BRadvoc8/commits/$OLD_COMMIT" | \
    jq '{date: .commit.author.date, verified: .commit.verification.verified, reason: .commit.verification.reason}'
    
│ Checking commit signatures...
|
│ Most recent commit: 26bb956f41c36db7f9f912a4744e224024f404a7
| {
|   "date": "2026-01-21T05:36:11Z",
|   "verified": true,
|   "reason": "valid"
| }
|
| Older commit: 1ab31db40e48145c14f19bc735add0d279cdc62d
│ Older verification status:
| {
|   "date": "2025-05-10T01:25:18Z",
|   "verified": true,
|   "reason": "valid"
| }

```

This provides two more pieces of evidence for the progressive trust of the BRadvoc8 XID.

It shows:

1. That the signing key that is held by the owner of the BRadvoc8 XID
has been used to sign commits (as shown by `verified`).
2. That the signing key has been used over a wide scope of time, from
May 2025 to January 2026 (as shown by `date`).

DevReviewer could also skim through BRadvoc8's GitHub account and
check specific PRs, such as that Galaxy Project PR. Every commit or PR
that is related to the type of work that Amira has previously claimed
would strengthen her claims that much more, because of her control of
the signing key tha was used to generate those requests.

> 🧠 **About Open Integrity.** Blockchain Commons also offers a
project called [Open
Integrity](https://github.com/OpenIntegrityProject/core) that
formalizes repository authority through inception commits. An
inception commit signed with the key BRadvoc8 holds would be even
stronger proof of control of the GitHub, but that's a topic for
another chapter.

### Step 13: Assess Your Level of Trust

The various claims made in chapter 2 tended to have a medium level of
trust. Now, that trust level has been upgraded thanks to Amira's
fairly strong proof that she controls the BRadvoc8 GitHub account.

This is courtesy of a chain of evidence, much of which was locked down in this section:

| ⛓️ Evidence | Verification | Section |
|----------|--------------|---------|
| 🔗 derefenceVia URL | URL is on GitHub | §1.4 |
| 🌌 Galaxy PR | PR Exists | §2.1 |
| 👀 Cryptographic Audit Work | Previous Commitment | §2.2 |
| 🔐 Security Work for Civil Trust | Similar PRs | §2.3 |
| 👩🏽‍💻 GitHub Ownership | Account Exists | §3.1 |
| 🔑 Signing Keys | Keys Match Account | §3.1-3.2 |
| 🔑 Signing Keys | BRadvoc8 Has Private Key | §3.1-3.2 |
| 🌌 Galaxy PR | Commit Matches Keys | §3.2 |
| 💾 Other PRs | Commit Matches Keys | §3.2 |
| 🗓️ Dates | Previous Keys & Commits | §3.2 |

As a result, DevReviewer can make a new assessment of BRadvoc8's trust:

| What DevReviewer Can Verify | What Remains Unproven |
|---------------------|----------------------|
| ✅ BRadvoc8 controls GitHub signing key | ❓ Who BRadvoc8 is |
| ✅ GitHub signing key has been used for a year | ❓ BRadvoc8 is original owner of key |
| ✅ Key signed commits related to expertise | ❓ BRadvoc8 wrote the commits |

To a certain extent, each new bit of evidence just exposes what else
has _not_ been proven. But they all continue to progress the trust of
the pseudonymous identity, BRadvoc8. At some point a viewer will
decide the requirements for their threshold of trust have been
met.

For DevReviewer, that threshold of trust has been met now.

## Summary: Supporting Verification

Creating claims is just half the battle. To properly support a
pseudonymous identity requires creating claims that can be
verified. Amira has been thinking about that all along, but the
creation of the GitHub edge really brought it together. Her use of the
GitHub signing key allowed her to (mostly) prove that she controlled
the GitHub account, which in turn supported many of the claims made in
chapter 2.

When you're thinking about claims, think about how you can actually
prove what you're saying, without revealing who you actually are.

### Additional Files

**Envelopes:** There are no envelopes for this section, since it was all about verification.

**Scripts:** Scripts demonstrating this section are forthcoming.

### Exercises

**Verification exercises:**

- Compare two versions of an XID with different provenance sequences.
- Extract the proof-of-control from an attachment and verify its signature.
- Tamper with a proof (change one character) and confirm verification fails.
- Extract the SSH signing key text from an attachment and compare it to GitHub's API response.

Try these to solidify your understanding:

**GitHub exercises:*8

- Fetch the real BRadvoc8 XIDDoc and verify its attestations using the workflow from this tutorial.
- Query GitHub's API directly: `curl https://api.github.com/users/BRadvoc8/ssh_signing_keys | jq`
- Simulate a verification failure by comparing against a fake key and confirm the mismatch is detected.
- Check commit signatures on a repository using `curl https://api.github.com/repos/OWNER/REPO/commits/COMMIT_SHA | jq '.commit.verification'`

**Exploration exercises:**

- Create your own GitHub account, register a signing key, and verify the API shows it correctly.
- Think about what additional evidence would strengthen trust beyond what's shown here.
- Research other external sources that could serve as temporal anchors (Twitter/X posts, blockchain timestamps, etc.).

## What's Next

What else can you put in an edge? How about a peer endorsement that
has different source and target?. That can be found in [§3.3: Creating
Peer Endorsements](03_3_Creating_Peer_Endorsements.md).

## Appendix I: Key Terminology

> **Credible Pseudonym** - An identity with verified attestations but unknown real-world mapping. Trustworthy for specific purposes, not all purposes.
>
> **Cross-Verification** - Checking claims against multiple independent sources to establish corroboration.
>
> **Progressive Trust** - Building trust incrementally through verification, collaboration, and endorsement rather than upfront credentialing.
>
> **Temporal Anchor** - External timestamp establishing when something occurred. GitHub's `created_at`, commit dates, and inception commits serve as temporal anchors.
>
> **Verification Chain** - The sequence of checks that link an XID claim to external evidence.

## Appendix II: Common Questions

### Q: What if the account's signing key changes after verification?

**A:** Verification is a snapshot, not an ongoing guarantee. If
BRadvoc8 removes or replaces their SSH key on GitHub, your previous
verification no longer reflects the current state. For high-stakes
decisions, re-verify before taking action.

### Q: Can I verify claims against sources other than GitHub?

**A:** Yes. The cross-verification pattern works with any external
source that provides independent attestation. GitLab, Bitbucket, and
other forges have similar APIs. For non-code sources (domain
ownership, social media accounts), you'd adapt the same approach:
extract the claim from the XID, query the external source, and
compare. The key is finding an authoritative endpoint that the
claimant can't easily forge.

### Q: What if GitHub's API is unavailable during verification?

**A:** Network failures are a real concern. In production, cache API
responses with timestamps, implement graceful degradation (proceed
with warning, not hard failure), and consider multiple verification
methods. An XID with both GitHub and GitLab attestations provides
redundancy: if one API is down, you can still verify against the other.

