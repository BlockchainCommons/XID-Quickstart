# Tutorial 08: Peer Endorsements

Transform "I say I'm good" into "others agree I'm good" through peer endorsements. Learn to request, give, and verify endorsements that create a web of trust around pseudonymous identities.

**Time to complete**: ~30-35 minutes
**Difficulty**: Intermediate
**Builds on**: Tutorials 01-07

> **Related Concepts**: After completing this tutorial, explore [Web of Trust](../concepts/web-of-trust.md) and [Progressive Trust](../concepts/progressive-trust.md) to deepen your understanding.

## Prerequisites

- Completed Tutorial 05 (Fair Witness Attestations)
- Completed Tutorial 06 (Managing Sensitive Claims)
- Completed Tutorial 07 (Encrypted Sharing)
- The `envelope` CLI tool installed

## What You'll Learn

- The difference between attestations (your claims) and endorsements (others' validation)
- **How to give endorsements** using fair witness methodology
- How to request and verify endorsements cryptographically
- How to build a **web of trust** through multiple independent endorsers
- How **relationship transparency** makes endorsements more valuable

## Building on Tutorial 07

| Tutorial 07 | Tutorial 08 |
|-------------|-------------|
| Shared sensitive credentials with DevReviewer | Get public validation from peers |
| One-to-one trust | Many-to-one trust network |
| Amira proves to specific person | Others vouch for Amira publicly |

**The Bridge**: In Tutorial 07, Amira shared her CivilTrust credential with DevReviewer privately. DevReviewer now has a complete picture: they've verified her crypto audit experience (T06) and seen her sensitive human rights work (T07). But that only proves things to DevReviewer. For broader reputation, Amira needs public endorsements—DevReviewer and others vouching for her openly.

---

## Amira's Challenge: Getting Validated

Amira has self-attestations about her skills, and she's shared sensitive credentials with Ben. But there's a fundamental limitation:

**Self-attestations only prove you MADE the claim—not that it's true.**

Anyone can claim "8 years of security experience." Project managers evaluating contributors need more than claims—they need validation from people who have actually worked with BRadvoc8.

**The solution**: Peer endorsements. When Charlene (who knows Amira's values) and code reviewers (who've seen her work) vouch for her, it transforms unverified claims into validated reputation.

The key distinction is whose keys sign the statement. Attestations are signed with *your* keys—they prove you made the claim. Endorsements are signed with *their* keys—they stake their reputation on you. That's why endorsements carry more weight: the endorser has something to lose if you turn out to be a fraud.

---

## Part I: Giving Good Endorsements

Endorsing someone is a responsibility—Charlene is staking her own reputation on BRadvoc8. Before creating an endorsement, she works through five questions:

1. **What have I actually observed?** She's seen BRadvoc8's commitment to privacy work over two years—that's endorsable. "Probably a great coder" would be speculation.
2. **What's the right scope?** "I endorse everything about BRadvoc8" isn't credible. "I endorse her character and values" is specific and honest.
3. **How do I disclose the relationship?** "Personal friend who introduced her to RISK network" lets evaluators calibrate for potential bias.
4. **What can't I speak to?** She hasn't seen Amira's code. Acknowledging this makes the endorsement more credible, not less.
5. **Would I be embarrassed if wrong?** If BRadvoc8 turns out badly, would this endorsement look foolish? If yes, narrow the scope.

> :book: **Fair Witness Endorsement**: State only what you've personally observed. Specific scope + relationship disclosure + acknowledged limitations = credible endorsement.

Charlene's endorsement will be limited to character and values—that's what she can honestly attest to.

---

## Part II: Creating Endorsements

### Step 0: Verify Dependencies

Ensure you have the required tools installed:

```
envelope --version

│ bc-envelope-cli 0.32.0
```

If not installed, see Tutorial 01 Step 0 for installation instructions.

### Step 1: Set Up Environment

```
OUTPUT_DIR="output/xid-tutorial08-$(date +%Y%m%d%H%M%S)"
mkdir -p "$OUTPUT_DIR"

# Create Amira's XID with provenance tracking
XID=$(envelope generate keypairs --signing ed25519 | \
    envelope xid new --nickname "BRadvoc8" --generator include --sign inception)

UNWRAPPED_XID=$(envelope extract wrapped "$XID")
XID_ID=$(envelope xid id "$UNWRAPPED_XID")

# Generate separate signing keys for Amira's attestations
XID_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
XID_PUBKEYS=$(envelope generate pubkeys "$XID_PRVKEYS")

echo "Created Amira's XID: $XID_ID"

│ Created Amira's XID: ur:xid/hdcxhsktlbjzhspyfzhl...
```

### Step 2: Create Charlene's Identity

Before Charlene can endorse BRadvoc8, she needs her own XID:

```
# Generate Charlene's keys
CHARLENE_PRVKEYS=$(envelope generate keypairs --signing ed25519)
CHARLENE_PUBKEYS=$(envelope generate pubkeys "$CHARLENE_PRVKEYS")

# Create Charlene's XID
CHARLENE_XID=$(envelope xid new --nickname "Charlene" "$CHARLENE_PUBKEYS")
CHARLENE_XID_ID=$(envelope xid id "$CHARLENE_XID")

echo "Charlene's XID created: $CHARLENE_XID_ID"

│ Charlene's XID created: ur:xid/hdcxdimkatoyis...
```

### Step 3: Charlene Creates Her Endorsement

Charlene applies fair witness principles to create a character endorsement:

```
# Create the endorsement subject
ENDORSEMENT=$(envelope subject type string "BRadvoc8 is a thoughtful and committed contributor to privacy work that protects vulnerable communities")

# Add endorsement metadata
ENDORSEMENT=$(envelope assertion add pred-obj known isA string "PeerEndorsement" "$ENDORSEMENT")
ENDORSEMENT=$(envelope assertion add pred-obj string "endorsedBy" string "Charlene" "$ENDORSEMENT")
ENDORSEMENT=$(envelope assertion add pred-obj string "endorsedOn" date "2026-01-21T00:00:00Z" "$ENDORSEMENT")
ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementTarget" string "$XID_ID" "$ENDORSEMENT")

# Add relationship context (critical for credibility)
ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementContext" string "Personal friend, observed values and commitment over 2+ years" "$ENDORSEMENT")
ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementScope" string "Character and values alignment, not technical skills" "$ENDORSEMENT")
ENDORSEMENT=$(envelope assertion add pred-obj string "relationshipBasis" string "Friend who introduced BRadvoc8 to RISK network concept" "$ENDORSEMENT")

# Charlene signs with her private key
CHARLENE_ENDORSEMENT=$(envelope sign --signer "$CHARLENE_PRVKEYS" "$ENDORSEMENT")

echo "Charlene's endorsement:"
envelope format "$CHARLENE_ENDORSEMENT"

│ "BRadvoc8 is a thoughtful and committed contributor to privacy work that protects vulnerable communities" [
│     'isA': "PeerEndorsement"
│     "endorsedBy": "Charlene"
│     "endorsedOn": 2026-01-21T00:00:00Z
│     "endorsementContext": "Personal friend, observed values and commitment over 2+ years"
│     "endorsementScope": "Character and values alignment, not technical skills"
│     "endorsementTarget": "ur:xid/hdcx..."
│     "relationshipBasis": "Friend who introduced BRadvoc8 to RISK network concept"
│     'signed': Signature
│ ]
```

Notice how the `endorsementScope` explicitly states what Charlene is NOT endorsing. This honesty makes the endorsement more credible, not less.

### Why Relationship Transparency Matters

The `relationshipBasis` assertion is one of the most valuable parts of this endorsement. When someone reads "Charlene endorses BRadvoc8," they immediately wonder: How well does Charlene know BRadvoc8? What's her basis for judgment? Is there bias?

Consider two versions of the same endorsement. The weak version says only "I endorse BRadvoc8"—the evaluator doesn't know the relationship basis, can't assess potential bias, and has little reason to trust the statement. The strong version says "I endorse BRadvoc8's character. Relationship: friend for 2+ years, observed commitment to privacy work." Now the evaluator has something to work with: length of relationship, what was actually observed, and honest acknowledgment of the friendship.

Endorsement value comes from context. Without relationship transparency, even strong endorsements lose credibility. A stranger's "great work!" means nothing; a code reviewer's "I merged 8 of her PRs and they were all solid" means everything.

### Step 4: Verify Charlene's Endorsement

```
envelope verify --verifier "$CHARLENE_PUBKEYS" "$CHARLENE_ENDORSEMENT"

│ Signature valid
```

The verified signature proves this endorsement was signed by Charlene and hasn't been modified. But wait—why is this more trustworthy than Amira's self-attestations?

The difference is cost. Charlene is an independent party staking her own reputation on BRadvoc8. If BRadvoc8 turns out to be incompetent or dishonest, Charlene looks bad for vouching. That reputational risk makes her endorsement a costly signal—she wouldn't make it unless she believed it. Self-attestations cost nothing; endorsements cost credibility.

---

## Part III: Technical Endorsements

Character endorsements establish values alignment, but technical endorsements validate actual skills. Let's add endorsements from people who've worked with BRadvoc8's code.

### Step 5: DevReviewer's Endorsement

DevReviewer has worked with BRadvoc8 across Tutorials 06 and 07. They verified her crypto audit experience through the commit-reveal pattern, then received her sensitive CivilTrust credential via encrypted sharing. Now they're ready to endorse her publicly—staking their own reputation on what they've observed:

```
# Create reviewer's identity
REVIEWER_PRVKEYS=$(envelope generate keypairs --signing ed25519)
REVIEWER_PUBKEYS=$(envelope generate pubkeys "$REVIEWER_PRVKEYS")
REVIEWER_XID=$(envelope xid new --nickname "DevReviewer" "$REVIEWER_PUBKEYS")
REVIEWER_XID_ID=$(envelope xid id "$REVIEWER_XID")

# Create technical endorsement
TECH_ENDORSEMENT=$(envelope subject type string "BRadvoc8 writes secure, well-tested code with clear attention to privacy-preserving patterns")

TECH_ENDORSEMENT=$(envelope assertion add pred-obj known isA string "PeerEndorsement" "$TECH_ENDORSEMENT")
TECH_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsedBy" string "DevReviewer" "$TECH_ENDORSEMENT")
TECH_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsedOn" date "2026-01-21T00:00:00Z" "$TECH_ENDORSEMENT")
TECH_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementTarget" string "$XID_ID" "$TECH_ENDORSEMENT")

# Technical context
TECH_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementContext" string "Verified crypto audit experience, reviewed CivilTrust authentication design" "$TECH_ENDORSEMENT")
TECH_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementScope" string "Security architecture, cryptographic implementation, privacy patterns" "$TECH_ENDORSEMENT")
TECH_ENDORSEMENT=$(envelope assertion add pred-obj string "relationshipBasis" string "Security collaboration partner who verified credentials through commit-reveal and encrypted sharing" "$TECH_ENDORSEMENT")

# Sign
TECH_ENDORSEMENT_SIGNED=$(envelope sign --signer "$REVIEWER_PRVKEYS" "$TECH_ENDORSEMENT")

echo "Technical endorsement:"
envelope format "$TECH_ENDORSEMENT_SIGNED"

│ "BRadvoc8 writes secure, well-tested code with clear attention to privacy-preserving patterns" [
│     'isA': "PeerEndorsement"
│     "endorsedBy": "DevReviewer"
│     "endorsedOn": 2026-01-21T00:00:00Z
│     "endorsementContext": "Verified crypto audit experience, reviewed CivilTrust authentication design"
│     "endorsementScope": "Security architecture, cryptographic implementation, privacy patterns"
│     "endorsementTarget": "ur:xid/hdcx..."
│     "relationshipBasis": "Security collaboration partner who verified credentials through commit-reveal and encrypted sharing"
│     'signed': Signature
│ ]
```

### Step 6: Project Maintainer Endorsement

A maintainer who has merged BRadvoc8's contributions can speak to collaboration quality:

```
# Create maintainer's identity
MAINTAINER_PRVKEYS=$(envelope generate keypairs --signing ed25519)
MAINTAINER_PUBKEYS=$(envelope generate pubkeys "$MAINTAINER_PRVKEYS")
MAINTAINER_XID=$(envelope xid new --nickname "SecurityMaintainer" "$MAINTAINER_PUBKEYS")
MAINTAINER_XID_ID=$(envelope xid id "$MAINTAINER_XID")

# Create collaboration endorsement
COLLAB_ENDORSEMENT=$(envelope subject type string "BRadvoc8 is a reliable contributor who delivers high-quality security enhancements and responds constructively to feedback")

COLLAB_ENDORSEMENT=$(envelope assertion add pred-obj known isA string "PeerEndorsement" "$COLLAB_ENDORSEMENT")
COLLAB_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsedBy" string "SecurityMaintainer" "$COLLAB_ENDORSEMENT")
COLLAB_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsedOn" date "2026-01-21T00:00:00Z" "$COLLAB_ENDORSEMENT")
COLLAB_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementTarget" string "$XID_ID" "$COLLAB_ENDORSEMENT")

# Collaboration context
COLLAB_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementContext" string "Collaborated on 3 security features over 6 months" "$COLLAB_ENDORSEMENT")
COLLAB_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementScope" string "Technical skills, collaboration quality, communication" "$COLLAB_ENDORSEMENT")
COLLAB_ENDORSEMENT=$(envelope assertion add pred-obj string "relationshipBasis" string "Project maintainer who merged BRadvoc8's contributions" "$COLLAB_ENDORSEMENT")

# Sign
COLLAB_ENDORSEMENT_SIGNED=$(envelope sign --signer "$MAINTAINER_PRVKEYS" "$COLLAB_ENDORSEMENT")

echo "Collaboration endorsement:"
envelope format "$COLLAB_ENDORSEMENT_SIGNED"

│ "BRadvoc8 is a reliable contributor who delivers high-quality security enhancements and responds constructively to feedback" [
│     'isA': "PeerEndorsement"
│     "endorsedBy": "SecurityMaintainer"
│     "endorsedOn": 2026-01-21T00:00:00Z
│     "endorsementContext": "Collaborated on 3 security features over 6 months"
│     "endorsementScope": "Technical skills, collaboration quality, communication"
│     "endorsementTarget": "ur:xid/hdcx..."
│     "relationshipBasis": "Project maintainer who merged BRadvoc8's contributions"
│     'signed': Signature
│ ]
```

### Step 7: Verify All Endorsements

```
echo "Verifying endorsement chain:"
echo "============================"

echo "1. Charlene (character):"
envelope verify --verifier "$CHARLENE_PUBKEYS" "$CHARLENE_ENDORSEMENT"

echo "2. DevReviewer (technical):"
envelope verify --verifier "$REVIEWER_PUBKEYS" "$TECH_ENDORSEMENT_SIGNED"

echo "3. SecurityMaintainer (collaboration):"
envelope verify --verifier "$MAINTAINER_PUBKEYS" "$COLLAB_ENDORSEMENT_SIGNED"

echo "============================"
echo "All endorsements verified"

│ Verifying endorsement chain:
│ ============================
│ 1. Charlene (character):
│ Signature valid
│ 2. DevReviewer (technical):
│ Signature valid
│ 3. SecurityMaintainer (collaboration):
│ Signature valid
│ ============================
│ All endorsements verified
```

### What If Someone Forges an Endorsement?

What happens if someone creates a fake endorsement claiming Charlene endorsed them?

```
# Attacker creates fake endorsement
FAKE_ENDORSEMENT=$(envelope subject type string "BRadvoc8 is amazing at everything")
FAKE_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsedBy" string "Charlene" "$FAKE_ENDORSEMENT")

# Attacker signs with their own key (not Charlene's)
ATTACKER_PRVKEYS=$(envelope generate prvkeys --signing ed25519)
FAKE_SIGNED=$(envelope sign --signer "$ATTACKER_PRVKEYS" "$FAKE_ENDORSEMENT")

# Verification against Charlene's real public key fails
envelope verify --verifier "$CHARLENE_PUBKEYS" "$FAKE_SIGNED"

│ Error: Signature verification failed
```

The forgery fails because the attacker can't produce a valid signature without Charlene's private key. Anyone can *claim* "endorsedBy: Charlene" in the metadata, but only the cryptographic signature proves authenticity—and that requires Charlene's actual key.

---

## Part IV: Understanding the Web of Trust

BRadvoc8 now has three endorsements from different contexts:

| Endorser | Type | Relationship | Scope |
|----------|------|--------------|-------|
| Charlene | Character | Friend (2+ years) | Values, commitment |
| DevReviewer | Technical | Security collaboration (T06-T07) | Security architecture, crypto |
| SecurityMaintainer | Collaboration | Project maintainer (6 months) | Technical skills, communication |

### Trust Multiplication

| Endorsements | Trust Level | Why |
|--------------|-------------|-----|
| 1 | Weak | Could be a friend doing a favor |
| 3 independent | Moderate | Pattern of validation |
| 3 from different contexts | Strong | Triangulated trust |

### Evaluating Endorser Credibility

Quality matters more than quantity. Three endorsements from unknown people don't equal a strong reputation. Three from established community members with clear context is a strong signal.

> :warning: **Endorsement Quality**: "BRadvoc8 is great!" with no context has low value. "I reviewed 8 of her PRs and they were all high quality" with specific evidence has high value. Reputation is recursive—endorsements are only as valuable as the endorsers' own reputations.

### The Bootstrapping Problem

But wait—how does Ben know that "Charlene" is actually Charlene? He verified the signature matches Charlene's public key, but how does he know that key belongs to a trustworthy person named Charlene?

This is the bootstrapping problem of any trust network. The signature proves the endorsement came from *whoever controls that key*. It doesn't prove that person is who they claim to be. Solutions include: Charlene's XID has its own endorsements from people Ben already trusts; Charlene has a history of public contributions Ben can evaluate; or Ben met Charlene through a channel he trusts (a project, a conference, a mutual contact). Trust has to start somewhere—the web of trust makes it *transferable*, not *automatic*.

> :brain: **Historical context**: The "web of trust" concept originated with PGP in the 1990s. XIDs build on this foundation with modern cryptography and portable documents. See [Web of Trust](../concepts/web-of-trust.md) for how the model has evolved.

### The Discovery Challenge

Related to bootstrapping: how does Ben find BRadvoc8 in the first place? In these tutorials, Amira sends Ben her XID URL directly. But in a larger ecosystem, Ben might want to search for "security contributors who've worked on privacy projects" and discover candidates.

Discovery is an active area of development. Current approaches include:

| Approach | How It Works | Status |
|----------|--------------|--------|
| Direct sharing | Amira sends Ben her XID URL | Works now (T02-T04) |
| Project directories | Maintainers list contributor XIDs | Manual curation |
| Skill registries | Index attestations by `isA` type | Under development |
| Web of trust crawling | Follow endorsement links | Under development |

For now, discovery happens through existing channels: project READMEs, social introductions, conference talks, or forum posts. The XID provides the *verification* infrastructure; discovery tooling will make the ecosystem more navigable as it matures.

> :brain: **Learn more**: Watch the [Blockchain Commons research repository](https://github.com/BlockchainCommons/research) for updates on discovery protocols and tooling.

### Where Do Endorsements Live?

Endorsements need to be published for discovery. Three approaches:

| Approach | How It Works | Trade-off |
|----------|--------------|-----------|
| Amira's XIDDoc | Amira attaches endorsement | Amira controls visibility |
| Charlene's XIDDoc | Charlene lists "I endorsed..." | Proves Charlene's commitment |
| Elided commitment | Charlene publishes `ELIDED`, gives Amira full version | Maximum privacy (see T06) |

The elided approach uses the same commit-reveal pattern from Tutorial 06. Charlene publishes an opaque commitment; Amira reveals the full endorsement when needed and proves it matches the public digest.

### Endorsement Lifecycle

Endorsements are point-in-time statements. Charlene's endorsement reflects what she observed through January 2026. If BRadvoc8's behavior changes, the endorsement doesn't automatically update. Some considerations: endorsements don't expire cryptographically, but evaluators should consider age; if Charlene needs to withdraw an endorsement, she can publish a revocation (a new signed statement superseding the old one); and diversifying endorsers protects against any single endorser becoming unreliable. The web of trust is resilient precisely because it doesn't depend on any single point of validation.

---

## Part V: Updating Your Claims After Endorsement

Endorsements validate your claims. Once validated, you can update your attestations to reflect this stronger standing.

### Step 8: Upgrade an Attestation

Before endorsements, Amira's privacy attestation was a bare claim:

> "I design privacy-preserving systems that protect vulnerable populations"

After SecurityMaintainer endorsed her contributions, she can make a stronger claim:

```
# Create upgraded attestation referencing the endorsement
UPGRADED_CLAIM=$(envelope subject type string "I delivered security enhancements (endorsed by SecurityMaintainer, Jan 2026)")

UPGRADED_ATTESTATION=$(envelope assertion add pred-obj known isA string "SelfAttestation" "$UPGRADED_CLAIM")
UPGRADED_ATTESTATION=$(envelope assertion add pred-obj string "attestedBy" string "BRadvoc8" "$UPGRADED_ATTESTATION")
UPGRADED_ATTESTATION=$(envelope assertion add pred-obj string "attestedOn" date "2026-01-21T00:00:00Z" "$UPGRADED_ATTESTATION")
UPGRADED_ATTESTATION=$(envelope assertion add pred-obj string "validatedBy" string "$MAINTAINER_XID_ID" "$UPGRADED_ATTESTATION")

# Sign the upgraded attestation
UPGRADED_ATTESTATION=$(envelope sign --signer "$XID_PRVKEYS" "$UPGRADED_ATTESTATION")

echo "Upgraded attestation:"
envelope format "$UPGRADED_ATTESTATION"

│ "I delivered security enhancements (endorsed by SecurityMaintainer, Jan 2026)" [
│     'isA': "SelfAttestation"
│     "attestedBy": "BRadvoc8"
│     "attestedOn": 2026-01-21T00:00:00Z
│     "validatedBy": "ur:xid/hdcx..."
│     'signed': Signature
│ ]
```

The new attestation includes a `validatedBy` reference pointing to the endorser's XID. Anyone can verify both the claim and the endorsement.

### Step 9: Advance Provenance

After updating your public attestations, signal the change:

```
# Advance provenance to indicate updated profile
UPDATED_XID=$(envelope xid provenance next "$UNWRAPPED_XID")

echo "Provenance advanced - verifiers will know to fetch latest version"

│ Provenance advanced - verifiers will know to fetch latest version
```

The provenance mark increments to signal that this identity has been updated. Anyone caching an old version will see the provenance mismatch and know to fetch the latest.

> **Pattern**: Raw claim → Demonstrated work → Peer endorsement → Upgraded claim referencing endorsement. Each step strengthens credibility.

---

## Part VI: Wrap-Up

### Save Your Work

```
echo "$CHARLENE_ENDORSEMENT" > "$OUTPUT_DIR/endorsement-charlene.envelope"
echo "$TECH_ENDORSEMENT_SIGNED" > "$OUTPUT_DIR/endorsement-devreviewer.envelope"
echo "$COLLAB_ENDORSEMENT_SIGNED" > "$OUTPUT_DIR/endorsement-maintainer.envelope"

echo "Saved endorsements to $OUTPUT_DIR"
ls "$OUTPUT_DIR"

│ Saved endorsements to output/xid-tutorial08-20260121120000
│ endorsement-charlene.envelope
│ endorsement-devreviewer.envelope
│ endorsement-maintainer.envelope
```

### What Amira Has Built

**Progressive trust layers**:

1. T01: Self-sovereign identity (XID exists)
2. T02: Self-consistent (signature verifies, fresh)
3. T03: Externally linked (GitHub, SSH key)
4. T04: Cross-verified (external accounts confirmed)
5. T05: Fair witness attestations (public, verifiable claims)
6. T06: Sensitive claims managed (commit elided, reveal later)
7. T07: Encrypted sharing (sensitive credentials to trusted recipients)
8. T08: Peer validated (independent endorsements)

The reputation is **portable** (follows her XID), **verifiable** (anyone can check), **privacy-preserving** (no legal identity), and **growing** (can continue building).

---

## Appendix: Key Terminology

> **Peer Endorsement**: A signed statement someone else makes about you, providing independent validation.
>
> **Web of Trust**: Network of interconnected endorsements where trust propagates through relationships.
>
> **Endorsement Scope**: Explicit limitations on what an endorsement covers.
>
> **Relationship Transparency**: Explanation of how endorser knows the endorsed person.

---

## Common Questions

### Q: How many endorsements do I need?

**A:** Quality over quantity. Three strong endorsements from established community members with clear context are worth more than ten vague ones. Focus on endorsements from people with relevant expertise who can speak to specific aspects of your work.

### Q: What if an endorser becomes disreputable?

**A:** Endorsements are point-in-time statements. The endorsement remains cryptographically valid, but evaluators will consider the endorser's current standing. Diversify your endorsers so no single person is critical to your reputation. This resilience is a key benefit of the web of trust.

### Q: Can I endorse others?

**A:** Yes! Apply fair witness methodology: endorse only what you've directly observed, be specific about scope, and disclose your relationship. Your endorsement staking helps build the network—and strengthens your own reputation as a thoughtful evaluator.

### Q: Can I warn others about a bad actor?

**A:** Yes—a signed statement with relationship context and specific evidence is a negative endorsement. Use carefully: false accusations damage your own reputation, and vague warnings ("X is bad") carry little weight. Specific, documented concerns ("I observed X claim credentials they didn't have") are more valuable.

### Q: What if I want to withdraw an endorsement?

**A:** You can publish a revocation—a new signed statement that supersedes the original endorsement. Include a reference to the original's digest and explain why you're withdrawing it. The original endorsement doesn't disappear, but the revocation provides context for evaluators.

---

## Exercises

1. Design an endorsement request for a real collaborator—what would you ask them to endorse, and what context would you provide?
2. Write an endorsement for a fictional peer using fair witness methodology (direct observation, specific scope, relationship disclosure, acknowledged limitations)
3. Evaluate endorsement quality: compare "X is great!" vs "I reviewed X's code for 6 months and merged 12 PRs"—what makes one better?
4. Identify who could provide endorsements for different aspects of your work (technical, collaboration, character)
5. Draft an endorsement you could honestly give someone today, being specific about what you've observed and what you can't speak to

---

**Previous**: [Encrypted Sharing](07-encrypted-sharing.md) | **Next**: [Binding Agreements](09-binding-agreements.md)
