# Public Participation Profiles

## Expected Learning Outcomes
By the end of this document, you will:
- Understand why pseudonymous contributors engage in public interest projects
- Know how to build structured participation profiles that balance privacy and trust
- Learn how to assess the risk-reward trade-offs of different disclosure levels
- Understand how to progressively build trust through structured participation profiles
- See how XIDs enable participation in meaningful projects while preserving privacy

## Introduction to Public Participation Profiles

Public participation profiles enable contributors to engage in projects aligned with their values while maintaining control over their personal information. These profiles are essential for individuals who need to balance meaningful contribution with privacy protection.

For many individuals like Amira, participating in projects creates a fundamental tension:

- **Privacy Needs**: Protection from surveillance, discrimination, retaliation, or unwanted exposure
- **Contribution Desires**: Meaningful participation in projects aligned with their values and skills

Public participation profiles resolve this tension by creating structured, verifiable digital representations that allow contributors to share what's necessary for trust while protecting what needs to remain private.

## The Risk-Reward Calculus of Participation

Pseudonymous contributors must carefully weigh the risks and rewards of participation:

### Risk Assessment Factors

1. **Association Risk**: Could this information link to legal identity?
2. **Uniqueness Risk**: How distinctive is this skill or experience?
3. **Correlation Risk**: Could multiple disclosures be combined to identify me?
4. **Temporal Risk**: Does this reveal a timeline that could be connected to me?
5. **Network Risk**: Does this expose connections to known associates?

### Benefit Assessment Factors

1. **Trust Threshold**: What's the minimum needed for the desired role?
2. **Impact Potential**: How significant is the potential contribution?
3. **Value Alignment**: How important is this project to personal values?
4. **Community Quality**: Will the community respect privacy boundaries?
5. **Trust Transferability**: Can trust built here transfer to other contexts?

The risk-reward calculus determines what information to include in a public participation profile, following the principle of **proportional disclosure**: higher-value projects justify higher (but still minimal) disclosure.

## Core Components of Participation Profiles

XIDs provide an ideal foundation for building participation profiles that balance privacy and trust:

### 1. Stable Pseudonymous Identifier

The foundation of a participation profile is a stable, cryptographically-verifiable identifier that doesn't reveal real-world identity:

```sh
# Create a stable pseudonymous identifier
PROFILE_XID=$(envelope xid new --name "BWHacker" "$PUBLIC_KEY")
```

The XID provides:
- Cryptographic verification of control (via private key)
- Consistent identity across interactions
- No inherent connection to real-world identity

### 2. Self-Attestations of Technical Capability

Self-attestations establish baseline skills and experience without requiring identity disclosure:

```sh
# Add technical capability self-attestations
PROFILE_XID=$(envelope assertion add pred-obj string "domain" string "Distributed Systems & Security" "$PROFILE_XID")
PROFILE_XID=$(envelope assertion add pred-obj string "experienceLevel" string "8 years professional development" "$PROFILE_XID")
PROFILE_XID=$(envelope assertion add pred-obj string "coreSkills" string "Cryptographic protocols, distributed consensus, mobile security" "$PROFILE_XID")
```

Effective self-attestations:
- Focus on relevant skills, not chronological history
- Provide specific technical domains rather than job titles
- Express experience in years rather than dates
- Highlight distinctive capabilities without uniquely identifying details

### 3. Verifiable Evidence Commitments

Evidence commitments allow contributors to prove capabilities without revealing sensitive information:

```sh
# Create evidence commitment
PROJECT_SUMMARY="Designed privacy-preserving location system for safety applications"
SUMMARY_HASH=$(echo "$PROJECT_SUMMARY" | envelope digest sha256)
PROFILE_XID=$(envelope assertion add pred-obj string "evidenceCommitment" digest "$SUMMARY_HASH" "$PROFILE_XID")
```

Evidence commitments enable:
- Cryptographic verification that evidence existed at a certain time
- Selective disclosure to specific parties
- Verification without public exposure
- Progressive trust development

### 4. Value and Purpose Statements

Value statements establish alignment without revealing personal background:

```sh
# Add value and purpose assertions
PROFILE_XID=$(envelope assertion add pred-obj string "purpose" string "Contributing to privacy-preserving systems that protect vulnerable populations" "$PROFILE_XID")
PROFILE_XID=$(envelope assertion add pred-obj string "values" string "Privacy as a human right, user agency, ethical data use" "$PROFILE_XID")
```

Effective value statements:
- Focus on universal principles rather than specific circumstances
- Connect to project goals rather than personal background
- Demonstrate alignment without revealing motivations
- Show commitment to ethical practices

### 5. Peer Attestations and Endorsements

Peer attestations provide independent verification while preserving pseudonymity:

```sh
# Add peer attestation from another pseudonymous contributor
PROFILE_XID=$(envelope assertion add pred-obj string "peerAttestation" envelope "$SIGNED_ENDORSEMENT" "$PROFILE_XID")
```

Effective peer attestations:
- Come from other trusted community members
- Verify specific skills or contributions
- Provide context about collaborative relationship
- Include cryptographic signatures for verification

## The Participation Profile Lifecycle

Public participation profiles evolve over time through a structured lifecycle:

### Phase 1: Initial Participation

Start with minimal disclosure focusing on:
- Basic pseudonymous identifier
- General skill areas
- Commitment to project values
- Small initial contributions

This phase establishes basic presence with minimal privacy risk.

### Phase 2: Contribution Validation

Build trust through validated contributions:
- Specific technical skills with evidence
- Work samples that can be evaluated on merit
- Challenge solutions relevant to the project
- Test implementations of project features

This phase demonstrates capabilities without revealing background.

### Phase 3: Reputation Development

Strengthen trust through peer relationships:
- Targeted endorsements from community members
- Collaboration attestations showing teamwork
- Consistent contribution patterns
- Deepening engagement within safe boundaries

This phase establishes community trust while maintaining privacy.

### Phase 4: Role Expansion

Take on greater responsibility based on earned trust:
- Leadership in specific domain areas
- Mentorship of newer contributors
- Component ownership or maintenance
- Expanded decision-making authority

This phase leverages established trust for greater impact.

## Balancing Disclosure Across Project Types

Different projects require different levels of trust and disclosure:

### Documentation Projects

- **Minimal disclosure needed**: Basic pseudonymous identity and writing skills
- **Focus on**: Quality of writing and accuracy of content
- **Trust signals**: Clarity, completeness, and accuracy of contributions

### Application Development

- **Moderate disclosure needed**: Technical skills and collaboration abilities
- **Focus on**: Code quality, testing practices, design approach
- **Trust signals**: Pull request quality, test coverage, code reviews

### Security-Critical Projects

- **Significant trust required**: Security expertise and ethical commitment
- **Focus on**: Security knowledge, threat modeling ability, ethics
- **Trust signals**: Security-focused contributions, vulnerability handling

### Governance Participation

- **Highest trust requirements**: Long-term commitment and values alignment
- **Focus on**: Project values, decision-making approach, conflict resolution
- **Trust signals**: Consistent demonstration of project values, contribution history

## Using XIDs for Participation Profiles

XIDs provide ideal infrastructure for participation profiles through:

### 1. Cryptographic Verifiability

XIDs use public key cryptography to verify control without revealing identity:

```sh
# Verify contribution signature
envelope verify -v "$PUBLIC_KEY" "$SIGNED_CONTRIBUTION"
```

### 2. Selective Disclosure

Gordian Envelopes enable context-specific views of the same profile:

```sh
# Create context-specific view for a technical collaboration
TECHNICAL_VIEW=$(envelope elide assertion predicate string "purpose" "$PROFILE_XID" 1)
```

### 3. Progressive Trust Building

XIDs support the gradual addition of attestations and endorsements:

```sh
# Add new peer attestation after successful collaboration
UPDATED_PROFILE=$(envelope assertion add pred-obj string "peerAttestation" envelope "$NEW_ENDORSEMENT" "$PROFILE_XID")
```

### 4. Revocable Credentials

XIDs support credential revocation if circumstances change:

```sh
# Update status of a credential
REVOCATION_STATUS=$(envelope subject type string "CredentialStatus")
REVOCATION_STATUS=$(envelope assertion add pred-obj string "status" string "revoked" "$REVOCATION_STATUS")
REVOCATION_STATUS=$(envelope assertion add pred-obj string "revocationDate" string "2023-11-30" "$REVOCATION_STATUS")
```

### 5. Trust Networks

XIDs enable networks of verified relationships between pseudonymous identities:

```sh
# Establish trust relationship between pseudonyms
TRUST_ASSERTION=$(envelope subject type string "TrustRelationship")
TRUST_ASSERTION=$(envelope assertion add pred-obj string "trusts" string "$TARGET_XID" "$TRUST_ASSERTION")
TRUST_ASSERTION=$(envelope assertion add pred-obj string "context" string "Code Review" "$TRUST_ASSERTION")
TRUST_ASSERTION=$(envelope assertion add pred-obj string "trustLevel" string "0.8" "$TRUST_ASSERTION")
```

## Practical Examples of Participation Profiles

### Technical Skills Profile

```
"BWHacker" [
   "name": "BWHacker"
   "publicKeys": ur:crypto-pubkeys/hdcxtbsrldcnldkplgsrtemwollopfhfaxuydaotptpdhtaadahtsaxlsdsdsaeaeae
   "domain": "Privacy-Preserving Mobile Development"
   "experienceLevel": "8 years development experience"
   "technicalSkills": "Cryptography implementation, secure mobile architecture, privacy-preserving design"
   "projectExamples": "Offline-capable authorization system, secure location sharing, encrypted messaging"
   "contributionFocus": "Mobile security, data minimization, user protection features"
]
```

### Collaboration Focus Profile

```
"BWHacker" [
   "name": "BWHacker"
   "publicKeys": ur:crypto-pubkeys/hdcxtbsrldcnldkplgsrtemwollopfhfaxuydaotptpdhtaadahtsaxlsdsdsaeaeae
   "collaborationStyle": "Responsive communication, clear technical writing, constructive code review"
   "documentationSkills": "API documentation, security guidelines, user guides"
   "peerEndorsement": "CharlieOne" [
      "endorsementContext": "Collaborated on privacy features for mobile application"
      "observation": "Excellent technical communication and reliable delivery"
      "basis": "Direct collaboration on shared codebase over 3 months"
      SIGNATURE
   ]
]
```

### Public Interest Focus Profile

```
"BWHacker" [
   "name": "BWHacker"
   "publicKeys": ur:crypto-pubkeys/hdcxtbsrldcnldkplgsrtemwollopfhfaxuydaotptpdhtaadahtsaxlsdsdsaeaeae
   "purpose": "Building technology that protects vulnerable users"
   "values": "Privacy as a human right, user agency, harm prevention"
   "ethicalPrinciples": "Data minimization, informed consent, secure defaults"
   "contributionFocus": "Women's safety applications, privacy-preserving location sharing"
   "impactGoals": "Reduce technology-facilitated abuse, increase safety for at-risk populations"
]
```

## Best Practices for Participation Profiles

1. **Start Minimal**: Begin with the least amount of disclosure needed for initial contribution
2. **Focus on Evidence**: Emphasize verifiable work rather than credentials or background
3. **Collect Targeted Endorsements**: Gather attestations specific to relevant skills and contexts
4. **Use Elision Strategically**: Create context-appropriate views for different interactions
5. **Update Progressively**: Add information gradually as trust develops
6. **Maintain Context Separation**: Use different profiles for different domains if necessary
7. **Document Boundaries**: Clearly communicate what information you will and won't share
8. **Establish Verification Methods**: Define how others can verify your contributions
9. **Build Consistent Patterns**: Establish recognizable work patterns without revealing identity
10. **Consider Recovery Options**: Plan for key management and profile recovery

## Check Your Understanding

1. Why might someone like Amira need a public participation profile rather than using their real identity?
2. What are the key components that make a participation profile both privacy-preserving and trust-building?
3. How does the proportional risk approach help determine appropriate disclosure levels?
4. What role do peer attestations play in strengthening pseudonymous participation profiles?
5. How do XIDs and Gordian Envelopes technically enable participation profiles?

## Next Steps

- See practical implementation examples in [Public Participation Profile Examples](public-participation-profile-examples.md)
- Apply these concepts in [Tutorial 1: Your First XID](../tutorials/01-your-first-xid.md)
- Learn about [Fair Witness Approach](fair-witness-approach.md) for making credible attestations
- Explore [Progressive Trust Life Cycle](progressive-trust-lifecycle.md) for a structured approach to disclosure
- Try creating different profile views with [Tutorial 3: Self-Attestation with XIDs](../tutorials/03-self-attestation-with-xids.md)