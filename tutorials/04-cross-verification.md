# Cross-Verification

In Tutorial 03, Amira added her GitHub account and SSH signing key to her XIDDoc. She *offered* these as attestations—claims about her skills and activities. But claims aren't proof. Ben needs to verify them independently before trusting BRadvoc8 with code contributions.

This tutorial shows how Ben cross-verifies Amira's attestations against external sources. He'll query GitHub's API, check commit signatures, and understand what this evidence actually proves.

**Time to complete: 15-20 minutes**

> **Related Concepts**: This tutorial demonstrates verification from the relying party's perspective. See [Progressive Trust](../concepts/progressive-trust.md) for how trust accumulates through evidence, and [Attestation & Endorsement Model](../concepts/attestation-endorsement-model.md) for understanding what claims vs endorsements prove.

## Prerequisites

- Understanding of Tutorials 01-03
- The [Gordian Envelope-CLI](https://github.com/BlockchainCommons/bc-envelope-cli-rust) tool installed (release 0.32.0 or later)
- `curl` and `jq` for API queries (standard on macOS/Linux)

## What You'll Learn

- How to extract attestations from XID attachments
- How to verify claims against GitHub's API
- How to check Git commit signatures
- How temporal anchors establish when claims became valid
- What cross-verification proves (and its limits)

## The Verification Problem

Ben received a message from someone claiming to be "BRadvoc8":

> "Hey Ben, I'd like to contribute to SisterSpaces. Here's my XID: https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt"

The XID contains a GitHub attachment with an SSH signing key. But anyone could create an XID claiming to be "BRadvoc8" with a random SSH key. Ben needs to verify that the key in the XID is actually registered on GitHub under that account, that commits signed with that key actually exist, and when this relationship was established.

This is cross-verification: checking claims against multiple independent sources until the evidence converges (or reveals inconsistencies).

---

## Part I: Ben Fetches and Inspects

### Step 1: Fetch the XIDDoc

Ben fetches Amira's published XIDDoc:

```
# Ben's perspective - he only has the URL
XID_URL="https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt"

# Fetch the XIDDoc
FETCHED_XID=$(curl -sL "$XID_URL")

echo "Fetched XIDDoc from: $XID_URL"
envelope xid id "$FETCHED_XID"

│ Fetched XIDDoc from: https://github.com/BRadvoc8/BRadvoc8/raw/main/xid.txt
│ ur:xid/hdcxhecefsnnionspljpftktetwymnfmcyecveuotktpwenlhyhdpmpykpchcmzchywzfelovwrf
```

### Step 2: Verify Self-Consistency

Before checking external sources, Ben verifies the XID is internally consistent—signed by its own key:

```
# Extract public keys from the XID itself
UNWRAPPED=$(envelope extract wrapped "$FETCHED_XID")
KEY_ASSERTION=$(envelope assertion find predicate known key "$UNWRAPPED")
KEY_OBJECT=$(envelope extract object "$KEY_ASSERTION")
PUBLIC_KEYS=$(envelope extract ur "$KEY_OBJECT")

# Verify signature
if envelope verify -v "$PUBLIC_KEYS" "$FETCHED_XID" >/dev/null 2>&1; then
    echo "✅ Signature verified - XID is self-consistent"
else
    echo "❌ Signature FAILED - do not trust!"
    exit 1
fi

│ ✅ Signature verified - XID is self-consistent
```

Self-consistency is necessary but not sufficient. It proves the document wasn't tampered with after signing—not that the claims inside are true.

### Step 3: Check Provenance

Ben checks the provenance to understand version history:

```
PROVENANCE_MARK=$(envelope xid provenance get "$FETCHED_XID")
provenance validate --format json-pretty "$PROVENANCE_MARK" | head -20

│ {
│   "chains": [
│     {
│       "chain_id": "...",
│       "has_genesis": false,
│       "sequences": [
│         {
│           "start_seq": 1,
│           "end_seq": 1,
│           "marks": [...]
│         }
│       ]
│     }
│   ]
│ }
```

The output shows `has_genesis: false` because Ben only has the current provenance mark (seq 1), not the original genesis mark (seq 0). The `start_seq: 1, end_seq: 1` confirms this is the second version. The real BRadvoc8 XID is at sequence 1—the basic XID was published first at sequence 0, then the GitHub attestation was added and provenance advanced to sequence 1. Ben doesn't need the genesis mark to verify the current state; he just needs to know this is version 1 of the identity.

---

## Part II: Extract and Verify the GitHub Attestation

### Step 4: Extract the GitHub Attachment

Ben extracts the GitHub account attestation from the XID:

```
# Get all attachments
ATTACHMENT=$(envelope xid attachment all "$FETCHED_XID" | head -1)

echo "Found attachment:"
envelope format "$ATTACHMENT"

│ Found attachment:
│ {
│     "BRadvoc8" [
│         'dereferenceVia': URI(https://api.github.com/users/BRadvoc8)
│         'isA': "GitHubAccount"
│         "createdAt": 2026-01-21T05:34:20Z
│         "sshSigningKey": SigningPublicKey(714b3b69, SSHPublicKey(f733cab9))
│         "sshSigningKeyProof": "BRadvoc8 controls SSH signing key registered on GitHub as of 2026-01-21" [
│             'signed': Signature(SshEd25519)
│         ]
│         "sshSigningKeyText": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiOtuf9hwDBjNXyjvjHMKeLQKyzT8GcH3tLvHNKrXJe"
│         "sshSigningKeysURL": URI(https://api.github.com/users/BRadvoc8/ssh_signing_keys)
│         "updatedAt": 2026-01-21T05:34:20Z
│     ]
│ } [
│     'vendor': "self"
│ ]
```

The attachment contains everything Ben needs for verification: the claimed GitHub username (`"BRadvoc8"`), a `dereferenceVia` URL pointing to the GitHub account itself, the SSH signing key in text format, a proof-of-control signed with that key, an `sshSigningKeysURL` pointing directly to GitHub's signing keys API for verification, and timestamps. Each piece plays a role in the verification chain he's about to build.

### Step 5: Extract the Claimed SSH Key

Ben extracts the SSH public key text that he'll compare against GitHub:

```
# Get the attachment's payload (unwrap the vendor wrapper)
ATTACHMENT_OBJECT=$(envelope extract object "$ATTACHMENT")
ATTACHMENT_PAYLOAD=$(envelope extract wrapped "$ATTACHMENT_OBJECT")

# Find the SSH key text assertion
SSH_KEY_ASSERTION=$(envelope assertion find predicate string sshSigningKeyText "$ATTACHMENT_PAYLOAD")
CLAIMED_SSH_KEY=$(envelope extract object "$SSH_KEY_ASSERTION" | envelope format)

echo "SSH key claimed in XID:"
echo "$CLAIMED_SSH_KEY"

│ SSH key claimed in XID:
│ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiOtuf9hwDBjNXyjvjHMKeLQKyzT8GcH3tLvHNKrXJe"
```

The extraction requires two steps because attachments are wrapped envelopes. The outer layer contains the vendor assertion (`'vendor': "self"`), and the inner wrapped envelope contains the actual payload. First we extract the object (which is itself wrapped), then unwrap to get the payload we can query.

### Step 6: Query GitHub's API

Now Ben queries GitHub to see what signing keys are actually registered:

```
# Extract username from the attachment
USERNAME="BRadvoc8"

# Query GitHub's SSH signing keys API
echo "Querying GitHub API for $USERNAME's signing keys..."
GITHUB_KEYS=$(curl -s "https://api.github.com/users/$USERNAME/ssh_signing_keys")

echo "GitHub API response:"
echo "$GITHUB_KEYS" | jq '.[0] | {key, created_at}'

│ Querying GitHub API for BRadvoc8's signing keys...
│ GitHub API response:
│ {
│   "key": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiOtuf9hwDBjNXyjvjHMKeLQKyzT8GcH3tLvHNKrXJe",
│   "created_at": "2025-05-10T02:15:26Z"
│ }
```

Ben now has two pieces of data: the key claimed in the XID and the key registered on GitHub.

### Step 7: Compare Keys

Ben compares the XID claim against GitHub's registry:

```
# Extract just the key portion from GitHub response
GITHUB_KEY=$(echo "$GITHUB_KEYS" | jq -r '.[0].key')

# Compare (strip quotes from claimed key for comparison)
CLAIMED_KEY=$(echo "$CLAIMED_SSH_KEY" | tr -d '"')

echo "Claimed key: $CLAIMED_KEY"
echo "GitHub key:  $GITHUB_KEY"

if [ "$CLAIMED_KEY" = "$GITHUB_KEY" ]; then
    echo ""
    echo "✅ KEYS MATCH - XID claim matches GitHub registry"
else
    echo ""
    echo "❌ KEYS DO NOT MATCH - attestation is invalid!"
fi

│ Claimed key: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiOtuf9hwDBjNXyjvjHMKeLQKyzT8GcH3tLvHNKrXJe
│ GitHub key:  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiOtuf9hwDBjNXyjvjHMKeLQKyzT8GcH3tLvHNKrXJe
│
│ ✅ KEYS MATCH - XID claim matches GitHub registry
```

The keys match. The XID's claim about BRadvoc8's GitHub signing key is consistent with GitHub's own registry.

---

## Part III: Temporal Anchors

Matching keys prove consistency, but when was this established? Ben examines temporal evidence.

### Step 8: Check GitHub's Timestamp

GitHub records when each signing key was added:

```
GITHUB_CREATED=$(echo "$GITHUB_KEYS" | jq -r '.[0].created_at')
echo "Key registered on GitHub: $GITHUB_CREATED"

│ Key registered on GitHub: 2025-05-10T02:15:26Z
```

This is a temporal anchor from an external source—GitHub's server timestamp when BRadvoc8 registered this key. Ben can trust this more than the XID's internal claims because GitHub is an independent party.

### Step 9: Cross-Reference Provenance

Ben compares the XID's provenance with GitHub's timeline:

```
echo "Timeline analysis:"
echo "  - GitHub key registered: $GITHUB_CREATED"
echo "  - XID provenance: sequence 1"
echo "  - XID attachment created: 2026-01-21 (from createdAt in attachment)"

│ Timeline analysis:
│   - GitHub key registered: 2025-05-10T02:15:26Z
│   - XID provenance: sequence 1 (one update since genesis)
│   - XID attachment created: 2026-01-21 (from createdAt in attachment)
```

The provenance mark doesn't contain a timestamp—only a sequence number. The real BRadvoc8 XID is at sequence 1 (basic XID published at seq 0, then updated with GitHub attestation at seq 1). Combined with GitHub's timestamp showing the SSH key was registered in May 2025, Ben can establish that the SSH key has a longer history than the XID itself—BRadvoc8 was active on GitHub before creating this XID document.

> **Provenance = Ordering**:
>
> The provenance chain proves seq 0 → seq 1 → seq 2, but not when these transitions occurred. Temporal anchors come from external sources: GitHub's API timestamps, commit dates, or inception commits that reference specific points in time.

### Step 10: Check Commit Signatures (Optional)

For stronger evidence, Ben can verify that signed commits actually exist:

```
# Check a recent commit from BRadvoc8
echo "Checking commit signatures..."
COMMIT_URL="https://api.github.com/repos/BRadvoc8/BRadvoc8/commits?per_page=1"
RECENT_COMMIT=$(curl -s "$COMMIT_URL" | jq -r '.[0].sha')

echo "Most recent commit: $RECENT_COMMIT"
echo "Verification status:"
curl -s "https://api.github.com/repos/BRadvoc8/BRadvoc8/commits/$RECENT_COMMIT" | \
    jq '{verified: .commit.verification.verified, reason: .commit.verification.reason}'

│ Checking commit signatures...
│ Most recent commit: abc123...
│ Verification status:
│ {
│   "verified": true,
│   "reason": "valid"
│ }
```

GitHub verified this commit's signature using the registered signing key. This closes the loop: the key in BRadvoc8's XID was used to create actual commits, GitHub independently verified those signatures against its own registry, and all three sources (XID, API, commits) point to the same key. An attacker would need to compromise all three to forge this evidence.

> **Repository Authority: The Deeper Link**
>
> Ben verified that the SSH key in BRadvoc8's XID matches GitHub's registry. But there's an even stronger connection he could check: the repository's **inception commit**.
>
> The BRadvoc8/BRadvoc8 repository was created with an inception commit signed by the same SSH key that appears in the XID. This creates cryptographic proof that whoever controls the XID also controls the publication repository—not just a GitHub account, but the specific location where the XID is published.
>
> Why does this matter? Someone could register "BRadvoc8" on GitHub, add an SSH key, and publish a fake XID. But they couldn't forge the inception commit signature without the original SSH private key. The inception commit is a temporal anchor that proves: "On this date, whoever held this SSH private key created this repository."
>
> Ben isn't checking inception authority in this tutorial—it requires examining the repository's git history rather than the API. But understanding this link completes the trust chain: XID → SSH key → inception commit → repository control. For high-stakes verification, checking the inception commit signature against the XID's SSH key provides the strongest proof of publication authority.
>
> For more on this pattern, see the [Open Integrity](https://github.com/OpenIntegrityProject/core) project, which formalizes repository authority through inception commits.

---

## Part IV: Understanding What's Proven

### The Verification Chain

Ben has now established a chain of evidence:

```
XID Claim                    External Verification
─────────────────────────    ─────────────────────────────────
"BRadvoc8" username    →     GitHub account exists
SSH signing key        →     Key registered on GitHub (May 2025)
dereferenceVia URL     →     Points to correct API endpoint
Signed commits         →     GitHub verifies signatures valid
```

Each link in the chain corroborates the others. An attacker would need to compromise multiple independent systems to forge this evidence.

### What This DOES Prove

Ben can now trust that someone who controls the GitHub account "BRadvoc8" also created this XID—the key binding is cryptographically verified. Commits signed with this key came from the same entity, and the timeline is bounded: the key was registered on GitHub in May 2025, giving Ben a lower bound on how long this identity has existed.

### What This DOESN'T Prove

But Ben should recognize the limits. BRadvoc8 is still pseudonymous—Ben doesn't know who Amira really is, and that's by design. Keys can be compromised, so this verification is a snapshot, not an ongoing guarantee. Most importantly, account ownership doesn't prove coding skill or predict future behavior. Verification establishes *credibility*, not *competence*.

### Ben's Trust Decision

Ben summarizes his verification:

```
echo "=== Verification Summary for BRadvoc8 ==="
echo ""
echo "✅ XID self-consistent (signature valid)"
echo "✅ Provenance chain intact (seq 1)"
echo "✅ SSH signing key matches GitHub registry"
echo "✅ Key registered on GitHub: $GITHUB_CREATED"
echo "✅ Signed commits verified by GitHub"
echo ""
echo "Trust level: CREDIBLE PSEUDONYM"
echo ""
echo "Ben can reasonably trust that:"
echo "  - This XID represents whoever controls the BRadvoc8 GitHub account"
echo "  - Commits signed with this key came from the same entity"
echo "  - The identity has existed since at least May 2025"
echo ""
echo "Ben should still:"
echo "  - Review code quality before merging"
echo "  - Start with low-risk contributions"
echo "  - Build trust incrementally through collaboration"

│ === Verification Summary for BRadvoc8 ===
│
│ ✅ XID self-consistent (signature valid)
│ ✅ Provenance chain intact (seq 1)
│ ✅ SSH signing key matches GitHub registry
│ ✅ Key registered on GitHub: 2025-05-10T02:15:26Z
│ ✅ Signed commits verified by GitHub
│
│ Trust level: CREDIBLE PSEUDONYM
│
│ Ben can reasonably trust that:
│   - This XID represents whoever controls the BRadvoc8 GitHub account
│   - Commits signed with this key came from the same entity
│   - The identity has existed since at least May 2025
│
│ Ben should still:
│   - Review code quality before merging
│   - Start with low-risk contributions
│   - Build trust incrementally through collaboration
```

---

## The Progressive Trust Model

This tutorial demonstrates the assessment phase of progressive trust. Amira *declared* her identity (T01), made it *verifiable* (T02), and *offered* attestations (T03). Ben now *assesses* those attestations through cross-verification.

Trust isn't binary. Ben doesn't fully trust BRadvoc8 after one verification—he has *sufficient* trust to begin collaboration. Each successful interaction builds more trust:

```
T01: Identity exists           → Self-sovereign, but unproven
T02: Identity is verifiable    → Fresh, self-consistent, but no attestations
T03: Attestations offered      → Claims exist, but unverified
T04: Attestations verified     → Credible pseudonym, ready for collaboration
T05: Peer endorsement          → Others vouch for quality (future tutorial)
```

Ben might later *endorse* BRadvoc8 after reviewing good contributions—adding his own attestation to Amira's XID. That endorsement becomes evidence for others, and trust propagates through the network.

## What You Accomplished

Ben verified BRadvoc8's attestations by extracting the GitHub attachment, querying GitHub's API for the registered signing key, comparing the claimed key against the external registry, and checking commit signatures for additional corroboration. He established temporal anchors from independent sources and understood both what this evidence proves and its limitations.

This is the verification side of self-attestation. Amira's claims in T03 are now externally validated—not by a central authority, but by evidence that Ben gathered and evaluated himself.

## Key Terminology

> **Cross-Verification** - Checking claims against multiple independent sources to establish corroboration.
>
> **Temporal Anchor** - External timestamp establishing when something occurred. GitHub's `created_at`, commit dates, and inception commits serve as temporal anchors.
>
> **Verification Chain** - The sequence of checks that link an XID claim to external evidence.
>
> **Credible Pseudonym** - An identity with verified attestations but unknown real-world mapping. Trustworthy for specific purposes, not all purposes.
>
> **Progressive Trust** - Building trust incrementally through verification, collaboration, and endorsement rather than upfront credentialing.

## Exercises

Try these to solidify your understanding:

- Fetch a real XIDDoc (if one is published) and verify its attestations.
- Query GitHub's API directly using `curl` and explore what information is available.
- Create your own GitHub account, register a signing key, and verify the API shows it correctly.
- Think about what additional evidence would strengthen trust beyond what's shown here.

## Example Script

A complete working script implementing this tutorial is available at `tests/04-cross-verification-TEST.sh`. Run it to see all verification steps in action:

```
bash tests/04-cross-verification-TEST.sh
```

This script fetches the real BRadvoc8 XIDDoc, extracts the GitHub attachment, queries GitHub's API, and compares the keys—demonstrating the complete cross-verification workflow.

## What's Next

Ben has established that BRadvoc8 is *credible*—the identity is real, self-consistent, and connected to a verifiable GitHub account. But credibility isn't competence. Ben still doesn't know if BRadvoc8 can actually write good code.

**Tutorial 05: Strategic Self-Attestation** explores what other claims Amira might make about herself—and the risks of making them. Every attestation is a publication that could help correlate her pseudonym with her real identity. Amira must balance demonstrating competence against protecting her privacy:

- What kinds of attestations exist beyond GitHub accounts?
- How does each type create correlation risk?
- Which attestations should be public vs. encrypted for specific people?
- How does she share sensitive claims only with trusted parties like Ben?

The trust model deepens: T03 offered one attestation, T04 verified it. T05 asks *what else* should Amira reveal, and *to whom*?

---

**Previous**: [Offering Self-Attestation](03-offering-self-attestation.md) | **Next**: [Strategic Self-Attestation](05-strategic-self-attestation.md)
