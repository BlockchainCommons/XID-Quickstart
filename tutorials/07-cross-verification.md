# Tutorial 06: Cross-Verification

In Tutorial 03, Amira added her GitHub account and SSH signing key to her XIDDoc. She *offered* these as attestations—claims about her skills and activities. But claims aren't proof. Ben needs to verify them independently before trusting BRadvoc8 with code contributions.

This tutorial shows how Ben cross-verifies Amira's attestations against external sources. He'll query GitHub's API, check commit signatures, and understand what this evidence actually proves.

**Time to complete**: ~15-20 minutes
**Difficulty**: Intermediate
**Builds on**: Tutorials 01-03

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

> :book: **Cross-Verification**: The process of checking a claim against multiple independent sources. If all sources agree, confidence increases. If sources conflict, the claim is suspect.

---

## Part I: Ben Fetches and Inspects

### Step 0: Verify Dependencies

Ensure you have the required tools:

```
envelope --version
curl --version | head -1
jq --version

│ bc-envelope-cli 0.32.0
│ curl 8.7.1 (x86_64-apple-darwin23.0) ...
│ jq-1.7.1
```

If `envelope` is not installed, see Tutorial 01 Step 0. The `curl` and `jq` tools are standard on macOS and most Linux distributions.

> :warning: **Network Required**: This tutorial queries external APIs (GitHub). Verification will fail if you're offline or if the external services are unavailable. In production, cache API responses and handle network failures gracefully.

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

Ben has established that the XID is self-consistent and has a valid provenance chain. But self-consistency only proves the document wasn't tampered with—not that its claims are true. Now he extracts the GitHub attestation and verifies it against external evidence.

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

The extraction requires multiple steps because attachments are nested envelopes:

| Step | Command | What It Does |
|------|---------|--------------|
| 1 | `envelope extract object "$ATTACHMENT"` | Gets the wrapped payload from the attachment assertion |
| 2 | `envelope extract wrapped "$ATTACHMENT_OBJECT"` | Unwraps to access the inner envelope with assertions |
| 3 | `envelope assertion find predicate string sshSigningKeyText "$ATTACHMENT_PAYLOAD"` | Finds the SSH key assertion by predicate name |
| 4 | `envelope extract object "$SSH_KEY_ASSERTION" \| envelope format` | Extracts and formats the key value |

The outer layer contains the vendor assertion (`'vendor': "self"`), and the inner wrapped envelope contains the actual payload. This nesting is why simple `grep` won't work—you need envelope-aware extraction.

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

> :warning: **API Rate Limits**: GitHub's API allows 60 unauthenticated requests per hour per IP. For automated verification, consider using a GitHub personal access token to increase the limit to 5,000 requests/hour. If you receive a 403 response, wait for the rate limit to reset.

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

#### What If the Keys Don't Match?

What would Ben see if someone created a fake XID with a different key?

```
# Simulate a forged XID with wrong key
FAKE_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFakeKeyThatDoesNotMatchGitHub"

echo "Claimed key: $FAKE_KEY"
echo "GitHub key:  $GITHUB_KEY"

if [ "$FAKE_KEY" = "$GITHUB_KEY" ]; then
    echo "✅ KEYS MATCH"
else
    echo ""
    echo "❌ KEYS DO NOT MATCH - attestation is INVALID!"
    echo "   This XID claims a key not registered on GitHub."
    echo "   Do not trust this identity!"
fi

│ Claimed key: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFakeKeyThatDoesNotMatchGitHub
│ GitHub key:  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiOtuf9hwDBjNXyjvjHMKeLQKyzT8GcH3tLvHNKrXJe
│
│ ❌ KEYS DO NOT MATCH - attestation is INVALID!
│    This XID claims a key not registered on GitHub.
│    Do not trust this identity!
```

This is why cross-verification matters. An attacker can create a self-consistent XID (valid signature), but they can't fake GitHub's registry. The mismatch exposes the forgery.

#### What If No Signing Keys Exist?

Another failure mode: the GitHub account exists but has no registered signing keys.

```
# Simulate account with no signing keys
EMPTY_RESPONSE='[]'

if [ "$(echo "$EMPTY_RESPONSE" | jq 'length')" -eq 0 ]; then
    echo "❌ No signing keys found for this GitHub account!"
    echo "   The XID claims a signing key, but GitHub has none registered."
    echo "   Possible causes:"
    echo "   - Key was removed from GitHub"
    echo "   - Wrong GitHub account"
    echo "   - Fake attestation"
fi

│ ❌ No signing keys found for this GitHub account!
│    The XID claims a signing key, but GitHub has none registered.
│    Possible causes:
│    - Key was removed from GitHub
│    - Wrong GitHub account
│    - Fake attestation
```

Key removal is legitimate (users can delete keys), but it invalidates the attestation. The XID claims a relationship that no longer exists. Ben would need to ask BRadvoc8 to update their XID with a current key.

---

## Part III: Temporal Anchors

Ben has verified the *what*: the SSH key in the XID matches GitHub's registry. But verification also requires *when*. An attacker could create a matching XID today and backdate its claims. Temporal anchors from external sources establish when relationships were actually created.

Matching keys prove consistency, but when was this established? Ben examines temporal evidence.

### Step 8: Check GitHub's Timestamp

GitHub records when each signing key was added:

```
GITHUB_CREATED=$(echo "$GITHUB_KEYS" | jq -r '.[0].created_at')
echo "Key registered on GitHub: $GITHUB_CREATED"

│ Key registered on GitHub: 2025-05-10T02:15:26Z
```

This is a temporal anchor from an external source—GitHub's server timestamp when BRadvoc8 registered this key. Ben can trust this more than the XID's internal claims because GitHub is an independent party.

> :book: **Temporal Anchor**: An external timestamp that establishes when something occurred. Unlike internal claims (which the claimant controls), temporal anchors come from independent parties—GitHub's API, commit dates, blockchain timestamps, or signed inception commits.

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

> :book: **Provenance = Ordering**:
>
> The provenance chain proves seq 0 → seq 1 → seq 2, but not when these transitions occurred. Temporal anchors come from external sources: GitHub's API timestamps, commit dates, or inception commits that reference specific points in time.

#### What If the Timeline Doesn't Add Up?

What would Ben see if someone created a fake XID claiming to have registered a key before they actually did?

```
# Simulate suspicious timeline
FAKE_XID_CREATED="2024-01-01"   # XID claims key was added in 2024
GITHUB_REGISTERED="2025-05-10"  # But GitHub shows key registered in 2025

echo "XID claims key added:    $FAKE_XID_CREATED"
echo "GitHub key registered:   $GITHUB_REGISTERED"
echo ""
echo "⚠️  SUSPICIOUS: XID claims key existed BEFORE GitHub registration!"
echo "   This could indicate:"
echo "   - Backdated claims in the XID"
echo "   - Key was re-registered on GitHub"
echo "   - Requires further investigation"

│ XID claims key added:    2024-01-01
│ GitHub key registered:   2025-05-10
│
│ ⚠️  SUSPICIOUS: XID claims key existed BEFORE GitHub registration!
│    This could indicate:
│    - Backdated claims in the XID
│    - Key was re-registered on GitHub
│    - Requires further investigation
```

Timeline inconsistencies don't automatically mean fraud—keys can be re-registered, accounts recreated—but they warrant closer examination. The legitimate BRadvoc8 XID shows the opposite: the GitHub key (May 2025) predates the XID attestation (January 2026), which is the expected pattern.

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

#### About Repository Authority

*For high-stakes verification, there's an even stronger check Ben could perform. Skip ahead to Part IV if you're ready to move on.*

Ben verified that the SSH key in BRadvoc8's XID matches GitHub's registry. But there's an even stronger connection he could check: the repository's **inception commit**.

The BRadvoc8/BRadvoc8 repository was created with an inception commit signed by the same SSH key that appears in the XID. This creates cryptographic proof that whoever controls the XID also controls the publication repository—not just a GitHub account, but the specific location where the XID is published.

Why does this matter? Someone could register "BRadvoc8" on GitHub, add an SSH key, and publish a fake XID. But they couldn't forge the inception commit signature without the original SSH private key. The inception commit is a temporal anchor that proves: "On this date, whoever held this SSH private key created this repository."

Ben isn't checking inception authority in this tutorial—it requires examining the repository's git history rather than the API. But understanding this link completes the trust chain: XID → SSH key → inception commit → repository control.

> :brain: **Learn more**: The [Open Integrity](https://github.com/OpenIntegrityProject/core) project formalizes repository authority through inception commits.

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

> :warning: **Verification Has Limits**:
>
> BRadvoc8 is still pseudonymous—Ben doesn't know who Amira really is, and that's by design. Keys can be compromised, so this verification is a snapshot, not an ongoing guarantee. Most importantly, account ownership doesn't prove coding skill or predict future behavior. Verification establishes *credibility*, not *competence*.

Ben should recognize these limits and continue building trust through actual collaboration.

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

> :brain: **Learn more**: The [Progressive Trust](../concepts/progressive-trust.md) concept doc explains the full trust hierarchy and how verification, collaboration, and endorsement combine to build meaningful trust.

## What You Accomplished

Ben verified BRadvoc8's attestations by extracting the GitHub attachment, querying GitHub's API for the registered signing key, comparing the claimed key against the external registry, and checking commit signatures for additional corroboration. He established temporal anchors from independent sources and understood both what this evidence proves and its limitations.

This is the verification side of self-attestation. Amira's claims in T03 are now externally validated—not by a central authority, but by evidence that Ben gathered and evaluated himself.

## Appendix: Key Terminology

> **Cross-Verification** - Checking claims against multiple independent sources to establish corroboration.
>
> **Temporal Anchor** - External timestamp establishing when something occurred. GitHub's `created_at`, commit dates, and inception commits serve as temporal anchors.
>
> **Verification Chain** - The sequence of checks that link an XID claim to external evidence.
>
> **Credible Pseudonym** - An identity with verified attestations but unknown real-world mapping. Trustworthy for specific purposes, not all purposes.
>
> **Progressive Trust** - Building trust incrementally through verification, collaboration, and endorsement rather than upfront credentialing.

## Common Questions

### Q: What if the account's signing key changes after verification?

**A:** Verification is a snapshot, not an ongoing guarantee. If BRadvoc8 removes or replaces their SSH key on GitHub, your previous verification no longer reflects the current state. For high-stakes decisions, re-verify before taking action. The provenance mark helps—if it has advanced since your last check, the XID has been updated.

### Q: Can I verify claims against sources other than GitHub?

**A:** Yes. The cross-verification pattern works with any external source that provides independent attestation. GitLab, Bitbucket, and other forges have similar APIs. For non-code sources (domain ownership, social media accounts), you'd adapt the same approach: extract the claim from the XID, query the external source, and compare. The key is finding an authoritative endpoint that the claimant can't easily forge.

### Q: What if GitHub's API is unavailable during verification?

**A:** Network failures are a real concern. In production, cache API responses with timestamps, implement graceful degradation (proceed with warning, not hard failure), and consider multiple verification methods. An XID with both GitHub and GitLab attestations provides redundancy—if one API is down, you can still verify against the other.

### Q: How do I know the endorser (Charlene, DevReviewer) is trustworthy?

**A:** This is the bootstrapping problem. The signature proves the endorsement came from *whoever controls that key*—not that you should trust them. Solutions: check the endorser's own endorsements, look for their public contributions, or rely on a trusted introduction. Trust has to start somewhere; the web of trust makes it transferable, not automatic.

---

## Exercises

Try these to solidify your understanding:

**Verification exercises (Ben's perspective):**

- Fetch the real BRadvoc8 XIDDoc and verify its attestations using the workflow from this tutorial.
- Query GitHub's API directly: `curl https://api.github.com/users/BRadvoc8/ssh_signing_keys | jq`
- Simulate a verification failure by comparing against a fake key and confirm the mismatch is detected.
- Check commit signatures on a repository using `curl https://api.github.com/repos/OWNER/REPO/commits/COMMIT_SHA | jq '.commit.verification'`

**Exploration exercises:**

- Create your own GitHub account, register a signing key, and verify the API shows it correctly.
- Think about what additional evidence would strengthen trust beyond what's shown here.
- Research other external sources that could serve as temporal anchors (Twitter/X posts, blockchain timestamps, etc.).

## Example Script

A complete working script implementing this tutorial is available at `tests/04-cross-verification-TEST.sh`. Run it to see all verification steps in action:

```
bash tests/04-cross-verification-TEST.sh
```

This script fetches the real BRadvoc8 XIDDoc, extracts the GitHub attachment, queries GitHub's API, and compares the keys—demonstrating the complete cross-verification workflow.

## What's Next

Ben has established that BRadvoc8 is *credible*—the identity is real, self-consistent, and connected to a verifiable GitHub account. But credibility isn't competence. Ben still doesn't know if BRadvoc8 can actually write good code.

**Tutorial 05: Fair Witness Attestations** introduces the methodology for making credible claims: specific, factual statements that can be verified against observable evidence. Instead of vague assertions like "I'm a security expert," Amira learns to make claims like "I contributed to Galaxy Project (PR #12847)"—claims that invite verification rather than demand belief.

The tutorial covers detached attestations (separate signed documents that reference your XID) and dedicated attestation keys that Ben can verify against the XID's key list.

---

**Previous**: [Offering Self-Attestation](03-offering-self-attestation.md) | **Next**: [Fair Witness Attestations](05-fair-witness-attestations.md)
