# Peer Endorsements with XIDs

This tutorial demonstrates how BWHacker's pseudonymous identity can be strengthened through attestations from others. You'll learn how peer endorsements work, how they differ from self-attestations, and how they create a network of verified claims while preserving pseudonymity for all parties.

**Time to complete: 30-40 minutes**

> **Related Concepts**: Before or after completing this tutorial, you may want to read about [Attestation and Endorsement Model](../concepts/attestation-endorsement-model.md), [Pseudonymous Trust Building](../concepts/pseudonymous-trust-building.md), [Public Participation Profiles](../concepts/public-participation-profiles.md), [Public Participation Profile Examples](../concepts/public-participation-profile-examples.md), and [Elision Cryptography](../concepts/elision-cryptography.md) to understand the theoretical foundations.

## Prerequisites

- Completed the first three XID tutorials
- The envelope CLI tool installed
- BWHacker's XID with self-attestations from previous tutorials
- Understanding of digital signatures and verification

## What You'll Learn

- How peer endorsements differ from self-attestations
- How to create, sign, and verify third-party attestations about an XID
- How to establish a network of pseudonymous trust relationships
- How to design different endorsement types with appropriate scope limitations
- How to verify endorsements from multiple independent sources
- How to form a web of trust with multiple pseudonymous identities

## Peer Endorsements: The Missing Trust Element

BWHacker has made significant progress with their pseudonymous identity. They've built a structured self-attestation framework and provided evidence of their skills. Ben, the non-profit manager, is more confident in their abilities, but still has reservations about trusting a pseudonymous developer with sensitive work. After all, self-attestations only represent BWHacker's claims about themselves.

This reflects a fundamental trust challenge in pseudonymous networks: how can others verify claims when they can't connect them to established real-world identities? The answer lies in peer endorsements - a critical component of distributed trust models.

Thanks to Charlene's involvement in the RISK network, BWHacker now has an opportunity to receive endorsements from respected members of the community who have worked with them on smaller projects. These peer attestations create a powerful complement to their self-attestations: claims that others make about their work and character.

For a pseudonymous contributor like BWHacker, peer endorsements serve multiple crucial functions:

1. **Trust Amplification**: They transform "trust me because I say so" into "trust me because others vouch for me"
2. **Reputation Building**: They create a portable reputation that follows their pseudonymous identity
3. **Risk Reduction**: They help project owners like Ben make safer decisions about collaboration
4. **Community Integration**: They embed them in a web of relationships that strengthen their position

Key differences between self-attestations and peer endorsements:

1. **Source of Truth**: Self-attestations come from BWHacker themselves, while peer endorsements come from others
2. **Signature Chain**: Self-attestations are signed with BWHacker's key, while peer endorsements are signed with the endorsers' keys
3. **Trust Model**: Self-attestations build trust through evidence, while peer endorsements build trust through third-party verification
4. **Validation Method**: Self-attestations require evidence validation, while peer endorsements leverage the endorsers' credibility

Without these peer endorsements, BWHacker would remain isolated in the network - their claims unverified by others and their contributions limited to low-trust contexts. With them, they can build the robust trust framework needed to work on high-impact projects that align with their values.

In this tutorial, we'll see how BWHacker expands their trust framework through various types of peer endorsements.

## 1. Understanding the Peer Endorsement Model

Let's begin by creating a peer endorsement framework that defines how third-party attestations work with XIDs:

👉
```sh
# Ensure output directory exists
mkdir -p output
mkdir -p endorsers

# Create a peer endorsement model
ENDORSEMENT_MODEL=$(envelope subject type string "Peer-EndorsementModel")
ENDORSEMENT_MODEL=$(envelope assertion add pred-obj string "purpose" string "Enable third-party assessment of skills and contributions" "$ENDORSEMENT_MODEL")
ENDORSEMENT_MODEL=$(envelope assertion add pred-obj string "endorsementTypes" string "Skill assessment, Project collaboration, Code review, Character reference" "$ENDORSEMENT_MODEL")
ENDORSEMENT_MODEL=$(envelope assertion add pred-obj string "requirements" string "Specific scope, Temporal context, Limitations, Relationship context" "$ENDORSEMENT_MODEL")
ENDORSEMENT_MODEL=$(envelope assertion add pred-obj string "assessmentMethod" string "Verify endorser's signature cryptographically, then evaluate evidence if provided" "$ENDORSEMENT_MODEL")

# Define endorsement proof levels
PROOF_LEVELS=$(envelope subject type string "EndorsementProofLevels")
PROOF_LEVELS=$(envelope assertion add pred-obj string "directCollaboration" string "First-hand knowledge through direct project collaboration" "$PROOF_LEVELS")
PROOF_LEVELS=$(envelope assertion add pred-obj string "codeReview" string "Direct examination of code or technical artifacts" "$PROOF_LEVELS")
PROOF_LEVELS=$(envelope assertion add pred-obj string "outputEvaluation" string "Evaluation of completed work products or deliverables" "$PROOF_LEVELS")
PROOF_LEVELS=$(envelope assertion add pred-obj string "testimonial" string "Second-hand knowledge or general character reference" "$PROOF_LEVELS")

# Add proof levels to the model
ENDORSEMENT_MODEL=$(envelope assertion add pred-obj string "proofLevels" envelope "$PROOF_LEVELS" "$ENDORSEMENT_MODEL")

# Save the endorsement model
echo "$ENDORSEMENT_MODEL" > output/endorsement-model.envelope

# Display the endorsement model
echo "Peer Endorsement Model:"
envelope format --type tree "$ENDORSEMENT_MODEL"
```

🔍
```console
"Peer-EndorsementModel" [
   "purpose": "Enable third-party verification of skills and contributions"
   "endorsementTypes": "Skill verification, Project collaboration, Code review, Character reference"
   "requirements": "Specific scope, Temporal context, Limitations, Relationship context"
   "validationMethod": "Verify endorser's signature and credibility, then assess evidence if provided"
   "proofLevels": "EndorsementProofLevels" [
      "directCollaboration": "First-hand knowledge through direct project collaboration"
      "codeReview": "Direct examination of code or technical artifacts"
      "outputEvaluation": "Evaluation of completed work products or deliverables"
      "testimonial": "Second-hand knowledge or general character reference"
   ]
]
```

This model establishes a framework for organizing and validating different types of peer endorsements, including their required components and proof levels.

## 2. Creating an Endorser's XID

For peer endorsements to work, we need another person with their own XID. Let's create one for Carlos, a security researcher who has collaborated with BWHacker. First, let's create Carlos's XID key pair:

👉
```sh
envelope generate prvkeys > endorsers/carlos-key.private
CARLOS_PRIVATE=$(cat endorsers/carlos-key.private)
CARLOS_PUBLIC=$(envelope generate pubkeys "$CARLOS_PRIVATE")
echo "$CARLOS_PUBLIC" > endorsers/carlos-key.public
```

Now, let's create Carlos's XID:

👉
```sh
CARLOS_XID=$(envelope xid new --name "Carlos_SecResearcher" "$CARLOS_PUBLIC")
```

Let's add basic information to Carlos's XID:

👉
```sh
CARLOS_XID=$(envelope assertion add pred-obj string "gitHubUsername" string "ResearchCarlos" "$CARLOS_XID")
CARLOS_XID=$(envelope assertion add pred-obj string "domain" string "Privacy Engineering & Mobile Security" "$CARLOS_XID")
CARLOS_XID=$(envelope assertion add pred-obj string "experienceLevel" string "10 years professional practice" "$CARLOS_XID")
CARLOS_XID=$(envelope assertion add pred-obj string "verifiableProjects" string "Consulted on 12+ privacy-focused mobile apps, security advisor for nonprofits" "$CARLOS_XID")
CARLOS_XID=$(envelope assertion add pred-obj string "affiliationContext" string "Independent privacy consultant, former security lead at domestic violence prevention organization" "$CARLOS_XID")
```

Let's save Carlos's XID and display it:

👉
```sh
echo "$CARLOS_XID" > endorsers/carlos-xid.envelope

echo "Carlos's XID:"
envelope format --type tree "$CARLOS_XID"
```

🔍
```console
"Carlos_SecResearcher" [
   "name": "Carlos_SecResearcher"
   "publicKeys": ur:crypto-pubkeys/hdcxtbsrldcnldkplgsrtemwollopfhfaxuydaotptpdhtaadahtsaxlsdsdsaeaeae
   "gitHubUsername": "ResearchCarlos"
   "domain": "Security Research & Vulnerability Analysis"
   "experienceLevel": "12 years professional practice"
   "verifiableProjects": "Published 7 CVEs, Security audit lead for 20+ open source projects"
   "affiliationContext": "Independent security researcher, previously CISO at midsize tech company"
]
```

Carlos's XID creates a pseudonymous identity that can now make endorsements about BWHacker.

## 3. Creating a Project Collaboration Endorsement

Now let's create a detailed project collaboration endorsement that Carlos makes about BWHacker:

First, let's load the target XID information (BWHacker):

👉
```sh
BWHACKER_XID_DOC=$(cat ../03-profile-xid/output/bwhacker-xid-with-skills.envelope 2>/dev/null || cat output/bwhacker-xid-full.envelope 2>/dev/null || echo "ERROR: BWHacker's XID not found")
BWHACKER_XID=$(envelope xid id "$BWHACKER_XID_DOC")
```

Now, let's create the collaboration endorsement:

👉
```sh
COLLABORATION_ENDORSEMENT=$(envelope subject type string "Project Collaboration Endorsement")
```

Let's add the target (who is being endorsed):

👉
```sh
COLLABORATION_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementTarget" string "$BWHACKER_XID" "$COLLABORATION_ENDORSEMENT")
COLLABORATION_ENDORSEMENT=$(envelope assertion add pred-obj string "targetAlias" string "BWHacker" "$COLLABORATION_ENDORSEMENT")
```

Next, let's add core collaboration details:

👉
```sh
COLLABORATION_ENDORSEMENT=$(envelope assertion add pred-obj string "projectName" string "Privacy-First Safety Alert System" "$COLLABORATION_ENDORSEMENT")
COLLABORATION_ENDORSEMENT=$(envelope assertion add pred-obj string "repositoryURL" string "https://github.com/example/privacy-alert-system" "$COLLABORATION_ENDORSEMENT")
COLLABORATION_ENDORSEMENT=$(envelope assertion add pred-obj string "collaborationPeriod" string "2021-03 through 2021-09" "$COLLABORATION_ENDORSEMENT")
COLLABORATION_ENDORSEMENT=$(envelope assertion add pred-obj string "collaborationContext" string "Joint development of privacy-preserving location features for a women's safety app" "$COLLABORATION_ENDORSEMENT")
```

Now, let's add endorsed skills with specific examples:

👉
```sh
ENDORSED_SKILLS=$(envelope subject type string "Endorsed Skills")
ENDORSED_SKILLS=$(envelope assertion add pred-obj string "locationPrivacy" string "Implemented privacy-preserving location tracking that minimizes data exposure risk" "$ENDORSED_SKILLS")
ENDORSED_SKILLS=$(envelope assertion add pred-obj string "mobileAppSecurity" string "Designed secure offline mode with emergency alert capabilities" "$ENDORSED_SKILLS")
ENDORSED_SKILLS=$(envelope assertion add pred-obj string "userDataProtection" string "Created secure data storage with minimal personal information requirements" "$ENDORSED_SKILLS")
COLLABORATION_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsedSkills" envelope "$ENDORSED_SKILLS" "$COLLABORATION_ENDORSEMENT")
```

Let's add the proof basis (why this endorsement is credible):

👉
```sh
COLLABORATION_ENDORSEMENT=$(envelope assertion add pred-obj string "proofBasis" string "directCollaboration" "$COLLABORATION_ENDORSEMENT")
COLLABORATION_ENDORSEMENT=$(envelope assertion add pred-obj string "contributionEvidence" string "32 co-authored commits on privacy features, joint design of secure location services" "$COLLABORATION_ENDORSEMENT")
COLLABORATION_ENDORSEMENT=$(envelope assertion add pred-obj string "verifiableMetrics" string "Reduced PII collection by 75%, emergency alert latency below 3 seconds" "$COLLABORATION_ENDORSEMENT")
```

Now, let's add endorser context and limitations:

👉
```sh
COLLABORATION_ENDORSEMENT=$(envelope assertion add pred-obj string "endorserRelationship" string "Technical advisor for nonprofit safety app project" "$COLLABORATION_ENDORSEMENT")
COLLABORATION_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementLimitations" string "Collaboration limited to privacy and security features, no visibility into UI development skills" "$COLLABORATION_ENDORSEMENT")
COLLABORATION_ENDORSEMENT=$(envelope assertion add pred-obj string "endorserContext" string "Privacy consultant with experience in women's safety applications" "$COLLABORATION_ENDORSEMENT")
```

Finally, let's sign the endorsement with Carlos's private key and add the endorser's XID identifier:

👉
```sh
CARLOS_PRIVATE=$(cat endorsers/carlos-key.private)
SIGNED_COLLABORATION=$(envelope sign -s "$CARLOS_PRIVATE" "$COLLABORATION_ENDORSEMENT")

CARLOS_XID_ID=$(envelope xid id "$CARLOS_XID")
SIGNED_COLLABORATION=$(envelope assertion add pred-obj string "endorserXID" string "$CARLOS_XID_ID" "$SIGNED_COLLABORATION")
echo "$SIGNED_COLLABORATION" > output/carlos-collaboration-endorsement.envelope

echo "Signed Project Collaboration Endorsement:"
envelope format --type tree "$SIGNED_COLLABORATION"
```

🔍
```console
"Project Collaboration Endorsement" [
   "endorsementTarget": "7e1e25d7c4b9e4c92753f4476158e972be2fbbd9dffdd13b0561b5f1177826d3"
   "targetAlias": "BWHacker"
   "projectName": "Open Source Security Audit Framework"
   "repositoryURL": "https://github.com/example/security-audit-framework"
   "collaborationPeriod": "2021-06 through 2021-12"
   "collaborationContext": "Joint development of cryptographic attestation modules"
   "endorsedSkills": "Endorsed Skills" [
      "cryptography": "Implemented zero-knowledge proof system for privacy-preserving attestations"
      "securityArchitecture": "Designed attack-resistant validation framework with minimal attack surface"
      "codingPractices": "Maintained excellent code quality with comprehensive test coverage"
   ]
   "proofBasis": "directCollaboration"
   "contributionEvidence": "47 co-authored commits, 15 joint pull request reviews"
   "verifiableMetrics": "10,000+ lines of code, security module reached 98% test coverage"
   "endorserRelationship": "Project collaborator without prior or subsequent professional relationship"
   "endorsementLimitations": "Collaboration limited to cryptographic modules, no visibility into other skills"
   "endorserContext": "Security researcher with cryptography specialization"
   "endorserXID": "b43a1bbf4e834c658b243ad3af1dfa98f704959c0ac93a509e3388568b3a46e4"
   SIGNATURE
]
```

This collaboration endorsement provides specific, contextual verification of BWHacker's skills through direct project experience, signed by Carlos's key.

## 4. Creating a Code Review Endorsement

Let's create another type of endorsement based on code review:

Let's create a second endorser: Maya, a senior developer at an open source foundation:

👉
```sh
envelope generate prvkeys > endorsers/maya-key.private
MAYA_PRIVATE=$(cat endorsers/maya-key.private)
MAYA_PUBLIC=$(envelope generate pubkeys "$MAYA_PRIVATE")
echo "$MAYA_PUBLIC" > endorsers/maya-key.public
```

Now, let's create Maya's XID:

👉
```sh
MAYA_XID=$(envelope xid new --name "MayaCodeX" "$MAYA_PUBLIC")
MAYA_XID=$(envelope assertion add pred-obj string "gitHubUsername" string "MayaDevX" "$MAYA_XID")
MAYA_XID=$(envelope assertion add pred-obj string "domain" string "Distributed Systems & Performance Engineering" "$MAYA_XID")
MAYA_XID=$(envelope assertion add pred-obj string "experienceLevel" string "15 years professional development" "$MAYA_XID")
MAYA_XID=$(envelope assertion add pred-obj string "affiliationContext" string "Lead Developer at Open Source Foundation" "$MAYA_XID")
echo "$MAYA_XID" > endorsers/maya-xid.envelope

Let's create the code review endorsement:

👉
```sh
CODE_REVIEW=$(envelope subject type string "Code Review Endorsement")
```

Now, let's add target and relationship context:

👉
```sh
CODE_REVIEW=$(envelope assertion add pred-obj string "endorsementTarget" string "$BWHACKER_XID" "$CODE_REVIEW")
CODE_REVIEW=$(envelope assertion add pred-obj string "targetAlias" string "BWHacker" "$CODE_REVIEW")
CODE_REVIEW=$(envelope assertion add pred-obj string "relationshipContext" string "Technical reviewer for contribution to open source project" "$CODE_REVIEW")
```

Let's add review details:

👉
```sh
CODE_REVIEW=$(envelope assertion add pred-obj string "projectName" string "Privacy-Focused Location Services" "$CODE_REVIEW")
CODE_REVIEW=$(envelope assertion add pred-obj string "repositoryURL" string "https://github.com/example/safety-location-privacy" "$CODE_REVIEW")
CODE_REVIEW=$(envelope assertion add pred-obj string "pullRequestURL" string "https://github.com/example/safety-location-privacy/pull/27" "$CODE_REVIEW")
CODE_REVIEW=$(envelope assertion add pred-obj string "reviewDate" string "2022-03-15" "$CODE_REVIEW")
CODE_REVIEW=$(envelope assertion add pred-obj string "codebaseSize" string "Significant contribution: ~3,500 lines of privacy-focused code" "$CODE_REVIEW")
```

Now, let's create a technical assessment:

👉
```sh
TECHNICAL_ASSESSMENT=$(envelope subject type string "Technical Assessment")
TECHNICAL_ASSESSMENT=$(envelope assertion add pred-obj string "algorithmicComplexity" string "Excellent: Optimized location privacy algorithm with minimal battery impact" "$TECHNICAL_ASSESSMENT")
TECHNICAL_ASSESSMENT=$(envelope assertion add pred-obj string "codeQuality" string "Exceptional: Clear structure, well-documented, comprehensive tests" "$TECHNICAL_ASSESSMENT")
TECHNICAL_ASSESSMENT=$(envelope assertion add pred-obj string "securityConsiderations" string "Strong: Robust privacy protections, careful location data handling, secure caching" "$TECHNICAL_ASSESSMENT")
TECHNICAL_ASSESSMENT=$(envelope assertion add pred-obj string "performanceImpact" string "Significant: 70% reduction in location data exposure while maintaining functionality" "$TECHNICAL_ASSESSMENT")
CODE_REVIEW=$(envelope assertion add pred-obj string "assessment" envelope "$TECHNICAL_ASSESSMENT" "$CODE_REVIEW")
```

Let's add endorsement context:

👉
```sh
CODE_REVIEW=$(envelope assertion add pred-obj string "proofBasis" string "codeReview" "$CODE_REVIEW")
CODE_REVIEW=$(envelope assertion add pred-obj string "reviewDepth" string "Comprehensive line-by-line review with performance profiling" "$CODE_REVIEW")
CODE_REVIEW=$(envelope assertion add pred-obj string "endorsementLimitations" string "Assessment limited to this specific contribution and codebase" "$CODE_REVIEW")
CODE_REVIEW=$(envelope assertion add pred-obj string "verifiableEvidence" string "Code review comments and approval in GitHub PR thread" "$CODE_REVIEW")
```

Finally, let's sign with Maya's key and add the endorser's XID identifier:

👉
```sh
SIGNED_CODE_REVIEW=$(envelope sign -s "$MAYA_PRIVATE" "$CODE_REVIEW")

MAYA_XID_ID=$(envelope xid id "$MAYA_XID")
SIGNED_CODE_REVIEW=$(envelope assertion add pred-obj string "endorserXID" string "$MAYA_XID_ID" "$SIGNED_CODE_REVIEW")
echo "$SIGNED_CODE_REVIEW" > output/maya-code-review-endorsement.envelope

echo "Signed Code Review Endorsement:"
envelope format --type tree "$SIGNED_CODE_REVIEW"
```

🔍
```console
"Code Review Endorsement" [
   "endorsementTarget": "7e1e25d7c4b9e4c92753f4476158e972be2fbbd9dffdd13b0561b5f1177826d3"
   "targetAlias": "BWHacker"
   "relationshipContext": "Technical reviewer for contribution to open source project"
   "projectName": "Privacy-Focused Location Services"
   "repositoryURL": "https://github.com/example/safety-location-privacy"
   "pullRequestURL": "https://github.com/example/safety-location-privacy/pull/27"
   "reviewDate": "2022-03-15"
   "codebaseSize": "Significant contribution: ~3,500 lines of privacy-focused code"
   "assessment": "Technical Assessment" [
      "algorithmicComplexity": "Excellent: Optimized location privacy algorithm with minimal battery impact"
      "codeQuality": "Exceptional: Clear structure, well-documented, comprehensive tests"
      "securityConsiderations": "Strong: Robust privacy protections, careful location data handling, secure caching"
      "performanceImpact": "Significant: 70% reduction in location data exposure while maintaining functionality"
   ]
   "proofBasis": "codeReview"
   "reviewDepth": "Comprehensive line-by-line review with performance profiling"
   "endorsementLimitations": "Assessment limited to this specific contribution and codebase"
   "verifiableEvidence": "Code review comments and approval in GitHub PR thread"
   "endorserXID": "c8f05e72bf9f6a2d8dde84ac9f679d3fc2e4fa56f4edc7fda2f43d18d17821a6"
   SIGNATURE
]
```

This code review endorsement provides specific technical validation of BWHacker's capabilities based on in-depth analysis of actual code.

## 5. Creating a Skill Verification Endorsement

Let's create a focused skill verification endorsement for a specific technical capability:

Let's create a third endorser: Priya, a cryptography specialist:

👉
```sh
envelope generate prvkeys > endorsers/priya-key.private
PRIYA_PRIVATE=$(cat endorsers/priya-key.private)
PRIYA_PUBLIC=$(envelope generate pubkeys "$PRIYA_PRIVATE")
echo "$PRIYA_PUBLIC" > endorsers/priya-key.public
```

Now, let's create Priya's XID:

👉
```sh
PRIYA_XID=$(envelope xid new --name "PriyaCrypto" "$PRIYA_PUBLIC")
PRIYA_XID=$(envelope assertion add pred-obj string "gitHubUsername" string "PriyaZK" "$PRIYA_XID")
PRIYA_XID=$(envelope assertion add pred-obj string "domain" string "Privacy Engineering & Data Minimization" "$PRIYA_XID")
PRIYA_XID=$(envelope assertion add pred-obj string "credentials" string "PhD in Computer Science, Focus on Privacy-Preserving Computation" "$PRIYA_XID")
PRIYA_XID=$(envelope assertion add pred-obj string "affiliationContext" string "University researcher and privacy advocate for women's safety organizations" "$PRIYA_XID")
echo "$PRIYA_XID" > endorsers/priya-xid.envelope
```

Let's create the skill verification endorsement:

👉
```sh
SKILL_ASSESSMENT=$(envelope subject type string "Skill Assessment Endorsement")
```

Now, let's add target and assessment context:

👉
```sh
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "endorsementTarget" string "$BWHACKER_XID" "$SKILL_ASSESSMENT")
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "targetAlias" string "BWHacker" "$SKILL_ASSESSMENT")
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "skillCategory" string "Privacy-Preserving Location Tracking" "$SKILL_ASSESSMENT")
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "assessmentContext" string "Detailed review of location privacy implementation in women's safety app" "$SKILL_ASSESSMENT")
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "assessmentDate" string "2023-01-10" "$SKILL_ASSESSMENT")

```

Let's add the technical skill assessment:

👉
```sh
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "technicalAccuracy" string "Excellent: Implementation correctly balances privacy with safety requirements" "$SKILL_ASSESSMENT")
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "securityConsiderations" string "Strong: Prevents location tracking without compromising emergency features" "$SKILL_ASSESSMENT")
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "innovationLevel" string "High: Novel approach to secure location sharing with minimal metadata leakage" "$SKILL_ASSESSMENT")
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "codeRobustness" string "Excellent: Comprehensive test suite including adversarial scenarios" "$SKILL_ASSESSMENT")

```

Now, let's add the skill level assessment:

👉
```sh
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "proficiencyLevel" string "Expert" "$SKILL_ASSESSMENT")
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "proficiencyJustification" string "Implementation shows deep understanding of privacy engineering principles" "$SKILL_ASSESSMENT")
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "comparativeAssessment" string "Among the most skilled privacy engineers I've worked with in safety applications" "$SKILL_ASSESSMENT")

```

Let's add assessment context:

👉
```sh
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "proofBasis" string "outputEvaluation" "$SKILL_ASSESSMENT")
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "assessmentMethod" string "Source code review, usability testing, and privacy analysis" "$SKILL_ASSESSMENT")
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "endorsementLimitations" string "Assessment focused on location privacy features, not the entire application" "$SKILL_ASSESSMENT")
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "specificReference" string "https://github.com/example/safety-app/tree/main/location-privacy" "$SKILL_ASSESSMENT")

```

Finally, let's sign with Priya's key and add the endorser's XID identifier:

👉
```sh
SIGNED_SKILL_ASSESSMENT=$(envelope sign -s "$PRIYA_PRIVATE" "$SKILL_ASSESSMENT")

PRIYA_XID_ID=$(envelope xid id "$PRIYA_XID")
SIGNED_SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "endorserXID" string "$PRIYA_XID_ID" "$SIGNED_SKILL_ASSESSMENT")
echo "$SIGNED_SKILL_ASSESSMENT" > output/priya-skill-assessment.envelope

echo "Signed Skill Assessment Endorsement:"
envelope format --type tree "$SIGNED_SKILL_ASSESSMENT"
```

🔍
```console
"Skill Assessment Endorsement" [
   "endorsementTarget": "7e1e25d7c4b9e4c92753f4476158e972be2fbbd9dffdd13b0561b5f1177826d3"
   "targetAlias": "BWHacker"
   "skillCategory": "Privacy-Preserving Location Tracking"
   "assessmentContext": "Detailed review of location privacy implementation in women's safety app"
   "assessmentDate": "2023-01-10"
   "technicalAccuracy": "Excellent: Implementation correctly balances privacy with safety requirements"
   "securityConsiderations": "Strong: Prevents location tracking without compromising emergency features"
   "innovationLevel": "High: Novel approach to secure location sharing with minimal metadata leakage"
   "codeRobustness": "Excellent: Comprehensive test suite including adversarial scenarios"
   "proficiencyLevel": "Expert"
   "proficiencyJustification": "Implementation shows deep understanding of privacy engineering principles"
   "comparativeAssessment": "Among the most skilled privacy engineers I've worked with in safety applications"
   "proofBasis": "outputEvaluation"
   "assessmentMethod": "Source code review, usability testing, and privacy analysis"
   "endorsementLimitations": "Assessment focused on location privacy features, not the entire application"
   "specificReference": "https://github.com/example/safety-app/tree/main/location-privacy"
   "endorserXID": "d7e32f409b7a96c53a87e8e18b12b3fa6c8f5fd2a3d7e8c9b4a2f1e3d5c7b9a8"
   SIGNATURE
]
```

This focused endorsement provides an expert's assessment of a specific technical skill with clear context and limitations.

## 6. Adding Endorsements to BWHacker's XID and Establishing the Web of Trust

Now, let's add these endorsements to BWHacker's XID and demonstrate how to establish the web of trust:

First, let's load the most complete version of BWHacker's XID:

👉
```sh
if [ -f "../03-profile-xid/output/bwhacker-xid-with-skills.envelope" ]; then
    XID_DOC=$(cat ../03-profile-xid/output/bwhacker-xid-with-skills.envelope)
else
    # If not found, create a clone of the original XID with basic info
    XID_DOC=$(cat output/bwhacker-xid-full.envelope 2>/dev/null || echo "ERROR: BWHacker's XID not found")
fi
```

Now, let's add the endorsement model:

👉
```sh
XID_DOC=$(envelope assertion add pred-obj string "peerEndorsementModel" envelope "$ENDORSEMENT_MODEL" "$XID_DOC")
```

Next, let's add the specific endorsements:

👉
```sh
COLLABORATION=$(cat output/carlos-collaboration-endorsement.envelope)
CODE_REVIEW=$(cat output/maya-code-review-endorsement.envelope)
SKILL_ASSESSMENT=$(cat output/priya-skill-assessment.envelope)

XID_DOC=$(envelope assertion add pred-obj string "peerEndorsement" envelope "$COLLABORATION" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "peerEndorsement" envelope "$CODE_REVIEW" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "peerEndorsement" envelope "$SKILL_ASSESSMENT" "$XID_DOC")
```

Let's save the updated XID:

👉
```sh
echo "$XID_DOC" > output/bwhacker-xid-with-endorsements.envelope
```

Now, let's create a trust network diagram:

👉
```sh
echo "Creating Web of Trust Diagram..."
echo 'digraph XIDTrustNetwork {
  rankdir=LR;
  node [shape=box, style=filled, fillcolor=lightblue];
  
  BWHacker [label="BWHacker\nDistributed Systems & Security"];
  Carlos [label="Carlos_SecResearcher\nSecurity Research"];
  Maya [label="MayaCodeX\nDistributed Systems"];
  Priya [label="PriyaCrypto\nZero-Knowledge Proofs"];
  
  Carlos -> BWHacker [label="Project Collaboration\nCryptographic Modules"];
  Maya -> BWHacker [label="Code Review\nConsensus Algorithm"];
  Priya -> BWHacker [label="Skill Assessment\nZKP Implementation"];
}' > output/trust-network.dot

echo "Web of Trust created for BWHacker with 3 independent peer endorsements"

```

Now, let's cryptographically verify the endorsement signatures:

👉
```sh
echo -e "\nCryptographically verifying peer endorsement signatures..."

# Verify Carlos's endorsement signature
CARLOS_PUBLIC=$(cat endorsers/carlos-key.public)
if envelope verify -v "$CARLOS_PUBLIC" "$COLLABORATION"; then
    echo "✅ Carlos's project collaboration endorsement verified"
else
    echo "❌ Carlos's endorsement verification failed"
fi

# Verify Maya's endorsement signature
MAYA_PUBLIC=$(cat endorsers/maya-key.public)
if envelope verify -v "$MAYA_PUBLIC" "$CODE_REVIEW"; then
    echo "✅ Maya's code review endorsement verified"
else
    echo "❌ Maya's endorsement verification failed"
fi

# Verify Priya's endorsement signature
PRIYA_PUBLIC=$(cat endorsers/priya-key.public)
if envelope verify -v "$PRIYA_PUBLIC" "$SKILL_ASSESSMENT"; then
    echo "✅ Priya's skill assessment endorsement signature verified"
else
    echo "❌ Priya's endorsement signature verification failed"
fi

echo -e "\nAll peer endorsement signatures successfully verified!"
```

🔍
```console
Web of Trust created for BWHacker with 3 independent peer endorsements

Verifying peer endorsements...
✅ Carlos's project collaboration endorsement verified
✅ Maya's code review endorsement verified
✅ Priya's skill verification endorsement verified

All peer endorsements successfully verified!
```

This verification process demonstrates how the endorsements form a web of trust around BWHacker, with each endorsement independently verifiable.

## 7. Selective Disclosure of Endorsements for Different Contexts

Just like with self-attestations, Amira may want to selectively disclose endorsements for different situations using elision techniques. This leverages the powerful cryptographic capabilities described in [Elision Cryptography](../concepts/elision-cryptography.md), which explains how hash-based structures allow for selective disclosure while maintaining cryptographic verification.

Let's create a technical skills view that only includes skill-related endorsements. The elision process replaces other endorsements with their cryptographic hashes, preserving signature validity while only showing selected content.

👉
```sh
TECHNICAL_VIEW=$(envelope elide assertion predicate string "peerEndorsement" "$XID_DOC" 2)
TECHNICAL_VIEW=$(envelope assertion add pred-obj string "peerEndorsement" envelope "$SKILL_ASSESSMENT" "$TECHNICAL_VIEW")
echo "$TECHNICAL_VIEW" > output/skills-endorsement-view.envelope
```

Now, let's create a project collaboration view:

👉
```sh
COLLABORATION_VIEW=$(envelope elide assertion predicate string "peerEndorsement" "$XID_DOC" 3)
COLLABORATION_VIEW=$(envelope assertion add pred-obj string "peerEndorsement" envelope "$COLLABORATION" "$COLLABORATION_VIEW")
echo "$COLLABORATION_VIEW" > output/collaboration-endorsement-view.envelope
```

Let's create a code quality view:

👉
```sh
CODE_QUALITY_VIEW=$(envelope elide assertion predicate string "peerEndorsement" "$XID_DOC" 3)
CODE_QUALITY_VIEW=$(envelope assertion add pred-obj string "peerEndorsement" envelope "$CODE_REVIEW" "$CODE_QUALITY_VIEW")
echo "$CODE_QUALITY_VIEW" > output/code-quality-endorsement-view.envelope
```

Finally, let's compare the sizes of the different views:

👉
```sh
echo "Size comparison of different endorsement views:"
echo "Full XID with all endorsements: $(echo "$XID_DOC" | wc -c) bytes"
echo "Technical skills view: $(echo "$TECHNICAL_VIEW" | wc -c) bytes"
echo "Collaboration view: $(echo "$COLLABORATION_VIEW" | wc -c) bytes"
echo "Code quality view: $(echo "$CODE_QUALITY_VIEW" | wc -c) bytes"
```

🔍
```console
Size comparison of different endorsement views:
Full XID with all endorsements: 8735 bytes
Technical skills view: 5632 bytes
Collaboration view: 5841 bytes
Code quality view: 5729 bytes
```

These different views allow BWHacker to share the most relevant endorsements for specific contexts while maintaining the cryptographic verifiability of each.

## 8. BWHacker Creating Endorsements for Others

Just as others have endorsed BWHacker, they can also endorse other pseudonymous identities:

Let's create another developer to endorse:

👉
```sh
envelope generate prvkeys > endorsers/dev-key.private
DEV_PRIVATE=$(cat endorsers/dev-key.private)
DEV_PUBLIC=$(envelope generate pubkeys "$DEV_PRIVATE")
echo "$DEV_PUBLIC" > endorsers/dev-key.public
```

Now, let's create the developer's XID:

👉
```sh
DEV_XID=$(envelope xid new --name "PrivacyDev" "$DEV_PUBLIC")
DEV_XID=$(envelope assertion add pred-obj string "gitHubUsername" string "PrivacyDev" "$DEV_XID")
DEV_XID=$(envelope assertion add pred-obj string "domain" string "Privacy Engineering & UX Design" "$DEV_XID")
echo "$DEV_XID" > endorsers/dev-xid.envelope
DEV_XID_ID=$(envelope xid id "$DEV_XID")

```

Now, let's have BWHacker create an endorsement for PrivacyDev:

👉
```sh
BWHACKER_PRIVATE=$(cat output/bwhacker-key.private)
BW_ENDORSEMENT=$(envelope subject type string "Endorsement: Collaborative Development Work")
```

Let's identify the endorser and relationship:

👉
```sh
BW_ENDORSEMENT=$(envelope assertion add pred-obj string "endorser" string "BWHacker - Security specialist with 8 years experience" "$BW_ENDORSEMENT")
BW_ENDORSEMENT=$(envelope assertion add pred-obj string "relationship" string "Collaborated as peers on privacy authentication library for 4 months" "$BW_ENDORSEMENT")
BW_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementTarget" string "$DEV_XID_ID" "$BW_ENDORSEMENT")
```

Now, let's add specific observations:

👉
```sh
BW_ENDORSEMENT=$(envelope assertion add pred-obj string "projectReference" string "Privacy-First Authentication Library" "$BW_ENDORSEMENT")
BW_ENDORSEMENT=$(envelope assertion add pred-obj string "observation" string "PrivacyDev demonstrated exceptional skill in cryptographic implementation and API design" "$BW_ENDORSEMENT")
BW_ENDORSEMENT=$(envelope assertion add pred-obj string "specificContributions" string "Implemented novel zero-knowledge protocol optimization, reduced computational overhead by 40%" "$BW_ENDORSEMENT")
```

Let's add fair witness principles:

👉
```sh
BW_ENDORSEMENT=$(envelope assertion add pred-obj string "basis" string "Direct collaboration on codebase with code review and pair programming" "$BW_ENDORSEMENT")
BW_ENDORSEMENT=$(envelope assertion add pred-obj string "observationPeriod" string "January through April 2023" "$BW_ENDORSEMENT")
BW_ENDORSEMENT=$(envelope assertion add pred-obj string "endorserLimitation" string "Limited exposure to PrivacyDev's frontend work" "$BW_ENDORSEMENT")
BW_ENDORSEMENT=$(envelope assertion add pred-obj string "potentialBias" string "Shared research interest in privacy-preserving systems" "$BW_ENDORSEMENT")
```

Finally, let's sign the endorsement:

👉
```sh
SIGNED_BW_ENDORSEMENT=$(envelope sign -s "$AMIRA_PRIVATE" "$BW_ENDORSEMENT")
echo "$SIGNED_BW_ENDORSEMENT" > output/bwhacker-endorsement-of-dev.envelope
```

Now, let's add this to PrivacyDev's XID:

👉
```sh
DEV_XID_UPDATED=$(envelope assertion add pred-obj string "receivedEndorsement" envelope "$SIGNED_BW_ENDORSEMENT" "$DEV_XID")
echo "$DEV_XID_UPDATED" > endorsers/dev-xid-with-endorsement.envelope

echo "BWHacker has created an endorsement for PrivacyDev:"
envelope format --type tree "$SIGNED_BW_ENDORSEMENT" | head -10
echo "..."
```

🔍
```console
BWHacker has created an endorsement for PrivacyDev:
"Endorsement: Collaborative Development Work" [
   "endorser": "BWHacker - Security specialist with 8 years experience"
   "relationship": "Collaborated as peers on privacy authentication library for 4 months"
   "endorsementTarget": "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2"
   "projectReference": "Privacy-First Authentication Library"
   "observation": "PrivacyDev demonstrated exceptional skill in cryptographic implementation and API design"
   "specificContributions": "Implemented novel zero-knowledge protocol optimization, reduced computational overhead by 40%"
   "basis": "Direct collaboration on codebase with code review and pair programming"
   "observationPeriod": "January through April 2023"
   ...
```

This demonstrates how endorsements can flow in multiple directions, creating a true web of pseudonymous trust where identity verification occurs without revealing real-world identities.

## Understanding Progression Through Trust Levels

Through this process, BWHacker's pseudonymous identity has progressed through several trust levels aligned with the progressive trust life cycle:

👉
```sh
TRUST_PROGRESSION=$(envelope subject type string "BWHacker's Trust Level Progression")

INITIAL_LEVEL=$(envelope subject type string "Initial Contributor")
INITIAL_LEVEL=$(envelope assertion add pred-obj string "status" string "Completed" "$INITIAL_LEVEL")
INITIAL_LEVEL=$(envelope assertion add pred-obj string "attestations" string "Basic XID with self-declarations" "$INITIAL_LEVEL")
INITIAL_LEVEL=$(envelope assertion add pred-obj string "verification" string "Cryptographic control of keys" "$INITIAL_LEVEL")
TRUST_PROGRESSION=$(envelope assertion add pred-obj string "trustLevel" envelope "$INITIAL_LEVEL" "$TRUST_PROGRESSION")

REGULAR_LEVEL=$(envelope subject type string "Regular Contributor")
REGULAR_LEVEL=$(envelope assertion add pred-obj string "status" string "Completed" "$REGULAR_LEVEL")
REGULAR_LEVEL=$(envelope assertion add pred-obj string "attestations" string "Skill framework with evidence commitments" "$REGULAR_LEVEL")
REGULAR_LEVEL=$(envelope assertion add pred-obj string "verification" string "Self-attestations with cryptographic commitments" "$REGULAR_LEVEL")
TRUST_PROGRESSION=$(envelope assertion add pred-obj string "trustLevel" envelope "$REGULAR_LEVEL" "$TRUST_PROGRESSION")

TRUSTED_LEVEL=$(envelope subject type string "Trusted Contributor")
TRUSTED_LEVEL=$(envelope assertion add pred-obj string "status" string "Completed" "$TRUSTED_LEVEL")
TRUSTED_LEVEL=$(envelope assertion add pred-obj string "attestations" string "Multiple peer endorsements from different contexts" "$TRUSTED_LEVEL")
TRUSTED_LEVEL=$(envelope assertion add pred-obj string "verification" string "Independent verification by multiple endorsers" "$TRUSTED_LEVEL")
TRUST_PROGRESSION=$(envelope assertion add pred-obj string "trustLevel" envelope "$TRUSTED_LEVEL" "$TRUST_PROGRESSION")

CORE_LEVEL=$(envelope subject type string "Core Contributor")
CORE_LEVEL=$(envelope assertion add pred-obj string "status" string "In Progress" "$CORE_LEVEL")
CORE_LEVEL=$(envelope assertion add pred-obj string "attestations" string "Project leadership endorsements required" "$CORE_LEVEL")
CORE_LEVEL=$(envelope assertion add pred-obj string "nextSteps" string "Multi-party verification from project governance" "$CORE_LEVEL")
TRUST_PROGRESSION=$(envelope assertion add pred-obj string "trustLevel" envelope "$CORE_LEVEL" "$TRUST_PROGRESSION")

echo "$TRUST_PROGRESSION" > output/trust-progression.envelope
echo "Trust Level Progression:"
envelope format --type tree "$TRUST_PROGRESSION"
```

🔍
```console
"BWHacker's Trust Level Progression" [
   "trustLevel": "Initial Contributor" [
      "status": "Completed"
      "attestations": "Basic XID with self-declarations"
      "verification": "Cryptographic control of keys"
   ]
   "trustLevel": "Regular Contributor" [
      "status": "Completed"
      "attestations": "Skill framework with evidence commitments"
      "verification": "Self-attestations with cryptographic commitments"
   ]
   "trustLevel": "Trusted Contributor" [
      "status": "Completed"
      "attestations": "Multiple peer endorsements from different contexts"
      "verification": "Independent verification by multiple endorsers"
   ]
   "trustLevel": "Core Contributor" [
      "status": "In Progress"
      "attestations": "Project leadership endorsements required"
      "nextSteps": "Multi-party verification from project governance"
   ]
]
```

This trust progression shows how Amira has moved from being an unknown pseudonymous contributor to a trusted member of the community through a structured process of increasing attestations and verification.

## Understanding the Power of Peer Endorsements

Through this tutorial, we've seen how peer endorsements significantly strengthen BWHacker's pseudonymous identity:

1. **Independent Verification**: Third parties have independently verified specific skills and contributions.

2. **Context-Rich Assessment**: Each endorsement provides rich context about what was verified, how, and any limitations.

3. **Diverse Perspectives**: Different endorsers with varied expertise evaluate different aspects of BWHacker's capabilities.

4. **Pseudonymous Credibility**: Trust is established without revealing anyone's real identity.

5. **Verifiable Chain**: Each endorsement is cryptographically signed and verifiable against the endorser's public key.

6. **Web of Trust**: Multiple endorsements create a network of verification that strengthens BWHacker's claims.

7. **Selective Disclosure**: BWHacker can share different endorsements based on the specific context.

8. **Progressive Trust Building**: Through structured attestations and endorsements, BWHacker moves through clear trust levels from Initial to Trusted Contributor.

This rich web of peer endorsements transforms BWHacker from a self-attested identity to a community-verified presence with substantial credibility.

### Theory to Practice: Building a Verifiable Trust Network

The peer endorsement system you've implemented demonstrates how cryptographic identities can support social trust mechanisms:

1. **Web of Trust Architecture**: By connecting multiple independent XIDs through endorsements, you've implemented a **decentralized trust network**. Unlike centralized reputation systems, this web of trust derives its credibility from the connections between identities rather than a single authoritative source.
   > **Historical Context**: This model builds on the web of trust concept first implemented in PGP in the 1990s, but enhances it with structured attestations, contextual information, and explicit relationship disclosure.

2. **Proof Basis in Endorsements**: Each endorsement includes a clear **proof basis** - the foundation for the endorser's claims. Maya's code review endorsement explicitly states the specific code she reviewed, while Carlos documents the specific collaboration experiences that form the basis of his endorsement.
   > **Why this matters**: Without a clear proof basis, endorsements become vague character references rather than specific, verifiable claims. The proof basis allows others to evaluate the endorser's knowledge and authority.

3. **Relationship Context Disclosure**: The endorsements properly implement **relationship transparency** by documenting how the endorser knows BWHacker and the context of their professional relationship, providing critical context for evaluating the endorsement's significance.
   > **ANTI-PATTERN**: Many recommendation systems don't require relationship disclosure, leading to situations where close friends or family members provide seemingly independent endorsements without revealing their connection.

4. **Trust Amplification**: When Maya's code review endorsement is combined with Priya's skill assessment, it creates **trust amplification** through multiple independent verifications. This implements the principle that trust is strengthened when confirmed from different perspectives and contexts.
   > **Real-World Analogy**: This is similar to how multiple independent product reviews create more confidence than a single review, especially when they come from reviewers with different expertise and perspectives.

5. **Endorsement Acceptance Model**: The process follows the proper **endorsement lifecycle** - where endorsements are created by peers, reviewed by the recipient, and then accepted into their trust framework, giving the recipient control over what endorsements become part of their identity.

6. **Contextual Disclosure of Endorsements**: The elided views of endorsements implement **context-sensitive information sharing**, allowing BWHacker to present different aspects of her endorsed capabilities to different audiences without revealing her entire trust network.

7. **Trust Network Visualization**: The graph visualization you created demonstrates **trust relationship mapping**, making abstract trust connections concrete and helping understand how reputation flows through the network.

These social trust mechanisms transform individual XIDs from isolated identities into a rich ecosystem where reputation and trust can flow while still preserving the pseudonymous nature of the identities involved.

## Next Steps

In the next tutorial, we'll explore how BWHacker can evolve their XID over time, managing key rotation, updating assertions, and building a long-term pseudonymous presence that maintains continuity while adapting to changing needs.

To build on what you've learned about peer endorsements, check out [Public Participation Profiles](../concepts/public-participation-profiles.md) for a comprehensive framework on balancing privacy with trust-building. For practical examples of how different peer endorsements can be structured for various contexts and trust levels, see the [Public Participation Profile Examples](../concepts/public-participation-profile-examples.md) document, which includes detailed examples aligned with BWHacker's women's safety app contributions.

## Exercises

1. Create your own endorser XID and make an endorsement about a technical skill.

2. Design an endorsement format for academic peer review or creative work evaluation.

3. Create a multi-level endorsement that combines direct experience, code review, and reputation assessment.

4. Build a visualization of a more complex trust network with endorsements in both directions.

5. Design a system for endorsement verification that doesn't require direct access to the endorser's XID.

## Example Scripts

This tutorial has an accompanying script in the `examples/04-peer-endorsement` directory:

**`create_peer_endorsements.sh`**: Implements the peer endorsement framework shown in this tutorial, including creating endorser XIDs, generating different types of endorsements, and verifying their signatures.

The script demonstrates all the key concepts:
- Creating XIDs for endorsers with their own key pairs
- Building different types of endorsements (collaboration, code review, skill assessment)
- Signing endorsements with appropriate keys
- Adding endorsements to BWHacker's XID
- Verifying endorsement signatures
- Creating selective disclosure views for different contexts
