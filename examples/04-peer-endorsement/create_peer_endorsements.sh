#!/bin/bash
# create_peer_endorsements.sh - Script for "Peer Endorsements with XIDs" tutorial

# This will continue on error but print what failed
set +e

# Create output directories
mkdir -p output
mkdir -p endorsers

echo "=== Building BWHacker's Peer Endorsement Network ==="

# Step 1: Creating a Peer Endorsement Model
echo -e "\n1. Creating a peer endorsement model..."

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

# Step 2: Finding or Creating BWHacker's XID
echo -e "\n2. Finding or creating BWHacker's XID..."

# Try to find an existing XID from previous tutorials
if [ -f "../03-profile-xid/output/bwhacker-xid-with-skills.envelope" ]; then
    cp ../03-profile-xid/output/bwhacker-xid-with-skills.envelope output/bwhacker-xid.envelope
    cp ../03-profile-xid/output/bwhacker-key.private output/ 2>/dev/null || true
    cp ../03-profile-xid/output/bwhacker-key.public output/ 2>/dev/null || true
    echo "Found and copied XID from tutorial #3"
elif [ -f "../02-xid-structure/output/enhanced-xid.envelope" ]; then
    cp ../02-xid-structure/output/enhanced-xid.envelope output/bwhacker-xid.envelope
    cp ../02-xid-structure/output/bwhacker-key.private output/ 2>/dev/null || true
    cp ../02-xid-structure/output/bwhacker-key.public output/ 2>/dev/null || true
    echo "Found and copied XID from tutorial #2"
elif [ -f "../01-basic-xid/output/bwhacker-xid.envelope" ]; then
    cp ../01-basic-xid/output/bwhacker-xid.envelope output/
    cp ../01-basic-xid/output/bwhacker-key.private output/ 2>/dev/null || true
    cp ../01-basic-xid/output/bwhacker-key.public output/ 2>/dev/null || true
    echo "Found and copied XID from tutorial #1"
else
    # Create basic XID if needed (simplified version)
    echo "Creating new XID (previous tutorial files not found)..."
    
    envelope generate prvkeys > output/bwhacker-key.private
    PRIVATE_KEYS=$(cat output/bwhacker-key.private)
    PUBLIC_KEYS=$(envelope generate pubkeys "$PRIVATE_KEYS")
    echo "$PUBLIC_KEYS" > output/bwhacker-key.public
    
    # Create basic XID
    XID_DOC=$(envelope xid new --name "BWHacker" "$PUBLIC_KEYS")
    XID_DOC=$(envelope assertion add pred-obj string "domain" string "Distributed Systems & Security" "$XID_DOC")
    XID_DOC=$(envelope assertion add pred-obj string "experienceLevel" string "8 years professional practice" "$XID_DOC")
    
    echo "$XID_DOC" > output/bwhacker-xid.envelope
fi

# Load BWHacker's XID
BWHACKER_XID_DOC=$(cat output/bwhacker-xid.envelope)
BWHACKER_XID=$(envelope xid id "$BWHACKER_XID_DOC")
echo "Using BWHacker's XID: $BWHACKER_XID"

# Step 3: Creating an Endorser's XID
echo -e "\n3. Creating Carlos's XID (security researcher endorser)..."

# Create Carlos's XID key pair
envelope generate prvkeys > endorsers/carlos-key.private
CARLOS_PRIVATE=$(cat endorsers/carlos-key.private)
CARLOS_PUBLIC=$(envelope generate pubkeys "$CARLOS_PRIVATE")
echo "$CARLOS_PUBLIC" > endorsers/carlos-key.public

# Create Carlos's XID
CARLOS_XID=$(envelope xid new --name "Carlos_SecResearcher" "$CARLOS_PUBLIC")

# Add basic information to Carlos's XID
CARLOS_XID=$(envelope assertion add pred-obj string "gitHubUsername" string "ResearchCarlos" "$CARLOS_XID")
CARLOS_XID=$(envelope assertion add pred-obj string "domain" string "Privacy Engineering & Mobile Security" "$CARLOS_XID")
CARLOS_XID=$(envelope assertion add pred-obj string "experienceLevel" string "10 years professional practice" "$CARLOS_XID")
CARLOS_XID=$(envelope assertion add pred-obj string "verifiableProjects" string "Consulted on 12+ privacy-focused mobile apps, security advisor for nonprofits" "$CARLOS_XID")
CARLOS_XID=$(envelope assertion add pred-obj string "affiliationContext" string "Independent privacy consultant, former security lead at domestic violence prevention organization" "$CARLOS_XID")

# Save Carlos's XID
echo "$CARLOS_XID" > endorsers/carlos-xid.envelope

# Display Carlos's XID
echo "Carlos's XID:"
envelope format --type tree "$CARLOS_XID"
CARLOS_XID_ID=$(envelope xid id "$CARLOS_XID")

# Step 4: Creating a Project Collaboration Endorsement
echo -e "\n4. Creating a project collaboration endorsement..."

# Create the collaboration endorsement
COLLABORATION_ENDORSEMENT=$(envelope subject type string "Project Collaboration Endorsement")

# Add the target (who is being endorsed)
COLLABORATION_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementTarget" string "$BWHACKER_XID" "$COLLABORATION_ENDORSEMENT")
COLLABORATION_ENDORSEMENT=$(envelope assertion add pred-obj string "targetAlias" string "BWHacker" "$COLLABORATION_ENDORSEMENT")

# Core collaboration details
COLLABORATION_ENDORSEMENT=$(envelope assertion add pred-obj string "projectName" string "Privacy-First Safety Alert System" "$COLLABORATION_ENDORSEMENT")
COLLABORATION_ENDORSEMENT=$(envelope assertion add pred-obj string "repositoryURL" string "https://github.com/example/privacy-alert-system" "$COLLABORATION_ENDORSEMENT")
COLLABORATION_ENDORSEMENT=$(envelope assertion add pred-obj string "collaborationPeriod" string "2021-03 through 2021-09" "$COLLABORATION_ENDORSEMENT")
COLLABORATION_ENDORSEMENT=$(envelope assertion add pred-obj string "collaborationContext" string "Joint development of privacy-preserving location features for a women's safety app" "$COLLABORATION_ENDORSEMENT")

# Endorsed skills with specific examples
ENDORSED_SKILLS=$(envelope subject type string "Endorsed Skills")
ENDORSED_SKILLS=$(envelope assertion add pred-obj string "locationPrivacy" string "Implemented privacy-preserving location tracking that minimizes data exposure risk" "$ENDORSED_SKILLS")
ENDORSED_SKILLS=$(envelope assertion add pred-obj string "mobileAppSecurity" string "Designed secure offline mode with emergency alert capabilities" "$ENDORSED_SKILLS")
ENDORSED_SKILLS=$(envelope assertion add pred-obj string "userDataProtection" string "Created secure data storage with minimal personal information requirements" "$ENDORSED_SKILLS")
COLLABORATION_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsedSkills" envelope "$ENDORSED_SKILLS" "$COLLABORATION_ENDORSEMENT")

# Proof basis (why this endorsement is credible)
COLLABORATION_ENDORSEMENT=$(envelope assertion add pred-obj string "proofBasis" string "directCollaboration" "$COLLABORATION_ENDORSEMENT")
COLLABORATION_ENDORSEMENT=$(envelope assertion add pred-obj string "contributionEvidence" string "32 co-authored commits on privacy features, joint design of secure location services" "$COLLABORATION_ENDORSEMENT")
COLLABORATION_ENDORSEMENT=$(envelope assertion add pred-obj string "verifiableMetrics" string "Reduced PII collection by 75%, emergency alert latency below 3 seconds" "$COLLABORATION_ENDORSEMENT")

# Endorser context and limitations
COLLABORATION_ENDORSEMENT=$(envelope assertion add pred-obj string "endorserRelationship" string "Technical advisor for nonprofit safety app project" "$COLLABORATION_ENDORSEMENT")
COLLABORATION_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementLimitations" string "Collaboration limited to privacy and security features, no visibility into UI development skills" "$COLLABORATION_ENDORSEMENT")
COLLABORATION_ENDORSEMENT=$(envelope assertion add pred-obj string "endorserContext" string "Privacy consultant with experience in women's safety applications" "$COLLABORATION_ENDORSEMENT")

# Wrap the endorsement before signing
WRAPPED_COLLABORATION=$(envelope subject type wrapped "$COLLABORATION_ENDORSEMENT")

# Sign the wrapped endorsement with Carlos's private key
SIGNED_COLLABORATION=$(envelope sign -s "$CARLOS_PRIVATE" "$WRAPPED_COLLABORATION")

# Add the endorser's XID identifier
SIGNED_COLLABORATION=$(envelope assertion add pred-obj string "endorserXID" string "$CARLOS_XID_ID" "$SIGNED_COLLABORATION")
echo "$SIGNED_COLLABORATION" > output/carlos-collaboration-endorsement.envelope

# Display the signed collaboration endorsement
echo "Signed Project Collaboration Endorsement:"
envelope format --type tree "$SIGNED_COLLABORATION"

# Step 5: Creating a Code Review Endorsement
echo -e "\n5. Creating a code review endorsement from Maya..."

# Create a second endorser: Maya, a senior developer
envelope generate prvkeys > endorsers/maya-key.private
MAYA_PRIVATE=$(cat endorsers/maya-key.private)
MAYA_PUBLIC=$(envelope generate pubkeys "$MAYA_PRIVATE")
echo "$MAYA_PUBLIC" > endorsers/maya-key.public

# Create Maya's XID
MAYA_XID=$(envelope xid new --name "MayaCodeX" "$MAYA_PUBLIC")
MAYA_XID=$(envelope assertion add pred-obj string "gitHubUsername" string "MayaDevX" "$MAYA_XID")
MAYA_XID=$(envelope assertion add pred-obj string "domain" string "Distributed Systems & Performance Engineering" "$MAYA_XID")
MAYA_XID=$(envelope assertion add pred-obj string "experienceLevel" string "15 years professional development" "$MAYA_XID")
MAYA_XID=$(envelope assertion add pred-obj string "affiliationContext" string "Lead Developer at Open Source Foundation" "$MAYA_XID")
echo "$MAYA_XID" > endorsers/maya-xid.envelope
MAYA_XID_ID=$(envelope xid id "$MAYA_XID")

# Create the code review endorsement
CODE_REVIEW=$(envelope subject type string "Code Review Endorsement")

# Add target and relationship context
CODE_REVIEW=$(envelope assertion add pred-obj string "endorsementTarget" string "$BWHACKER_XID" "$CODE_REVIEW")
CODE_REVIEW=$(envelope assertion add pred-obj string "targetAlias" string "BWHacker" "$CODE_REVIEW")
CODE_REVIEW=$(envelope assertion add pred-obj string "relationshipContext" string "Technical reviewer for contribution to open source project" "$CODE_REVIEW")

# Add review details
CODE_REVIEW=$(envelope assertion add pred-obj string "projectName" string "Privacy-Focused Location Services" "$CODE_REVIEW")
CODE_REVIEW=$(envelope assertion add pred-obj string "repositoryURL" string "https://github.com/example/safety-location-privacy" "$CODE_REVIEW")
CODE_REVIEW=$(envelope assertion add pred-obj string "pullRequestURL" string "https://github.com/example/safety-location-privacy/pull/27" "$CODE_REVIEW")
CODE_REVIEW=$(envelope assertion add pred-obj string "reviewDate" string "2022-03-15" "$CODE_REVIEW")
CODE_REVIEW=$(envelope assertion add pred-obj string "codebaseSize" string "Significant contribution: ~3,500 lines of privacy-focused code" "$CODE_REVIEW")

# Technical assessment
TECHNICAL_ASSESSMENT=$(envelope subject type string "Technical Assessment")
TECHNICAL_ASSESSMENT=$(envelope assertion add pred-obj string "algorithmicComplexity" string "Excellent: Optimized location privacy algorithm with minimal battery impact" "$TECHNICAL_ASSESSMENT")
TECHNICAL_ASSESSMENT=$(envelope assertion add pred-obj string "codeQuality" string "Exceptional: Clear structure, well-documented, comprehensive tests" "$TECHNICAL_ASSESSMENT")
TECHNICAL_ASSESSMENT=$(envelope assertion add pred-obj string "securityConsiderations" string "Strong: Robust privacy protections, careful location data handling, secure caching" "$TECHNICAL_ASSESSMENT")
TECHNICAL_ASSESSMENT=$(envelope assertion add pred-obj string "performanceImpact" string "Significant: 70% reduction in location data exposure while maintaining functionality" "$TECHNICAL_ASSESSMENT")
CODE_REVIEW=$(envelope assertion add pred-obj string "assessment" envelope "$TECHNICAL_ASSESSMENT" "$CODE_REVIEW")

# Endorsement context
CODE_REVIEW=$(envelope assertion add pred-obj string "proofBasis" string "codeReview" "$CODE_REVIEW")
CODE_REVIEW=$(envelope assertion add pred-obj string "reviewDepth" string "Comprehensive line-by-line review with performance profiling" "$CODE_REVIEW")
CODE_REVIEW=$(envelope assertion add pred-obj string "endorsementLimitations" string "Assessment limited to this specific contribution and codebase" "$CODE_REVIEW")
CODE_REVIEW=$(envelope assertion add pred-obj string "verifiableEvidence" string "Code review comments and approval in GitHub PR thread" "$CODE_REVIEW")

# Wrap the code review before signing
WRAPPED_CODE_REVIEW=$(envelope subject type wrapped "$CODE_REVIEW")

# Sign the wrapped code review with Maya's key
SIGNED_CODE_REVIEW=$(envelope sign -s "$MAYA_PRIVATE" "$WRAPPED_CODE_REVIEW")

# Add the endorser's XID identifier
SIGNED_CODE_REVIEW=$(envelope assertion add pred-obj string "endorserXID" string "$MAYA_XID_ID" "$SIGNED_CODE_REVIEW")
echo "$SIGNED_CODE_REVIEW" > output/maya-code-review-endorsement.envelope

# Display the signed code review endorsement
echo "Signed Code Review Endorsement:"
envelope format --type tree "$SIGNED_CODE_REVIEW"

# Step 6: Creating a Skill Assessment Endorsement
echo -e "\n6. Creating a skill assessment endorsement from Priya..."

# Create a third endorser: Priya, a cryptography specialist
envelope generate prvkeys > endorsers/priya-key.private
PRIYA_PRIVATE=$(cat endorsers/priya-key.private)
PRIYA_PUBLIC=$(envelope generate pubkeys "$PRIYA_PRIVATE")
echo "$PRIYA_PUBLIC" > endorsers/priya-key.public

# Create Priya's XID
PRIYA_XID=$(envelope xid new --name "PriyaCrypto" "$PRIYA_PUBLIC")
PRIYA_XID=$(envelope assertion add pred-obj string "gitHubUsername" string "PriyaZK" "$PRIYA_XID")
PRIYA_XID=$(envelope assertion add pred-obj string "domain" string "Privacy Engineering & Data Minimization" "$PRIYA_XID")
PRIYA_XID=$(envelope assertion add pred-obj string "credentials" string "PhD in Computer Science, Focus on Privacy-Preserving Computation" "$PRIYA_XID")
PRIYA_XID=$(envelope assertion add pred-obj string "affiliationContext" string "University researcher and privacy advocate for women's safety organizations" "$PRIYA_XID")
echo "$PRIYA_XID" > endorsers/priya-xid.envelope
PRIYA_XID_ID=$(envelope xid id "$PRIYA_XID")

# Create the skill assessment endorsement
SKILL_ASSESSMENT=$(envelope subject type string "Skill Assessment Endorsement")

# Add target and assessment context
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "endorsementTarget" string "$BWHACKER_XID" "$SKILL_ASSESSMENT")
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "targetAlias" string "BWHacker" "$SKILL_ASSESSMENT")
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "skillCategory" string "Privacy-Preserving Location Tracking" "$SKILL_ASSESSMENT")
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "assessmentContext" string "Detailed review of location privacy implementation in women's safety app" "$SKILL_ASSESSMENT")
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "assessmentDate" string "2023-01-10" "$SKILL_ASSESSMENT")

# Technical skill assessment
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "technicalAccuracy" string "Excellent: Implementation correctly balances privacy with safety requirements" "$SKILL_ASSESSMENT")
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "securityConsiderations" string "Strong: Prevents location tracking without compromising emergency features" "$SKILL_ASSESSMENT")
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "innovationLevel" string "High: Novel approach to secure location sharing with minimal metadata leakage" "$SKILL_ASSESSMENT")
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "codeRobustness" string "Excellent: Comprehensive test suite including adversarial scenarios" "$SKILL_ASSESSMENT")

# Skill level assessment
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "proficiencyLevel" string "Expert" "$SKILL_ASSESSMENT")
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "proficiencyJustification" string "Implementation shows deep understanding of privacy engineering principles" "$SKILL_ASSESSMENT")
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "comparativeAssessment" string "Among the most skilled privacy engineers I've worked with in safety applications" "$SKILL_ASSESSMENT")

# Assessment context
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "proofBasis" string "outputEvaluation" "$SKILL_ASSESSMENT")
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "assessmentMethod" string "Source code review, usability testing, and privacy analysis" "$SKILL_ASSESSMENT")
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "endorsementLimitations" string "Assessment focused on location privacy features, not the entire application" "$SKILL_ASSESSMENT")
SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "specificReference" string "https://github.com/example/safety-app/tree/main/location-privacy" "$SKILL_ASSESSMENT")

# Wrap the skill assessment before signing
WRAPPED_SKILL_ASSESSMENT=$(envelope subject type wrapped "$SKILL_ASSESSMENT")

# Sign the wrapped skill assessment with Priya's key
SIGNED_SKILL_ASSESSMENT=$(envelope sign -s "$PRIYA_PRIVATE" "$WRAPPED_SKILL_ASSESSMENT")

# Add the endorser's XID identifier
SIGNED_SKILL_ASSESSMENT=$(envelope assertion add pred-obj string "endorserXID" string "$PRIYA_XID_ID" "$SIGNED_SKILL_ASSESSMENT")
echo "$SIGNED_SKILL_ASSESSMENT" > output/priya-skill-assessment.envelope

# Display the signed skill assessment
echo "Signed Skill Assessment Endorsement:"
envelope format --type tree "$SIGNED_SKILL_ASSESSMENT"

# Step 7: Adding Endorsements to BWHacker's XID
echo -e "\n7. Adding endorsements to BWHacker's XID..."

# Load BWHacker's XID
XID_DOC=$BWHACKER_XID_DOC

# Add the endorsement model
XID_DOC=$(envelope assertion add pred-obj string "peerEndorsementModel" envelope "$ENDORSEMENT_MODEL" "$XID_DOC")

# Add each endorsement
XID_DOC=$(envelope assertion add pred-obj string "peerEndorsement" envelope "$SIGNED_COLLABORATION" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "peerEndorsement" envelope "$SIGNED_CODE_REVIEW" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "peerEndorsement" envelope "$SIGNED_SKILL_ASSESSMENT" "$XID_DOC")

# Save the updated XID
echo "$XID_DOC" > output/bwhacker-xid-with-endorsements.envelope

# Create web of trust diagram
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
  Priya -> BWHacker [label="Skill Verification\nZKP Implementation"];
}' > output/trust-network.dot

echo "Web of Trust created for BWHacker with 3 independent peer endorsements"

# Step 8: Verifying the Endorsements
echo -e "\n8. Verifying all endorsements..."

# Verify Carlos's endorsement signature
echo "Verifying Carlos's project collaboration endorsement..."
if envelope verify -v "$CARLOS_PUBLIC" "$SIGNED_COLLABORATION"; then
    echo "✅ Carlos's project collaboration endorsement verified"
else
    echo "❌ Carlos's endorsement verification failed"
fi

# Verify Maya's endorsement signature
echo "Verifying Maya's code review endorsement..."
if envelope verify -v "$MAYA_PUBLIC" "$SIGNED_CODE_REVIEW"; then
    echo "✅ Maya's code review endorsement verified"
else
    echo "❌ Maya's endorsement verification failed"
fi

# Verify Priya's endorsement signature
echo "Verifying Priya's skill assessment endorsement..."
if envelope verify -v "$PRIYA_PUBLIC" "$SIGNED_SKILL_ASSESSMENT"; then
    echo "✅ Priya's skill assessment endorsement verified"
else
    echo "❌ Priya's endorsement verification failed"
fi

# Step 9: Creating Selective Disclosure Views
echo -e "\n9. Creating selective disclosure views for different contexts..."

# Save all endorsements to individual files for reference
echo "$SIGNED_SKILL_ASSESSMENT" > output/skill-assessment-endorsement.envelope
echo "$SIGNED_COLLABORATION" > output/collaboration-endorsement.envelope
echo "$SIGNED_CODE_REVIEW" > output/code-review-endorsement.envelope

# Create a technical skills view that only includes skill-related endorsements
# This uses proper cryptographic elision to remove other endorsements

# Create a simpler version for the technical skills view
# Create a fresh copy of the XID document
TECHNICAL_VIEW="$XID_DOC"

# Add the skill assessment endorsement
TECHNICAL_VIEW=$(envelope assertion add pred-obj string "peerEndorsement" envelope "$SIGNED_SKILL_ASSESSMENT" "$TECHNICAL_VIEW")
echo "$TECHNICAL_VIEW" > output/skills-endorsement-view.envelope

# Create a collaboration project view using the same approach
COLLABORATION_VIEW="$XID_DOC"

# Add the collaboration endorsement
COLLABORATION_VIEW=$(envelope assertion add pred-obj string "peerEndorsement" envelope "$SIGNED_COLLABORATION" "$COLLABORATION_VIEW")
echo "$COLLABORATION_VIEW" > output/collaboration-endorsement-view.envelope

# Create a code quality view using the same approach
CODE_QUALITY_VIEW="$XID_DOC"

# Add the code review endorsement  
CODE_QUALITY_VIEW=$(envelope assertion add pred-obj string "peerEndorsement" envelope "$SIGNED_CODE_REVIEW" "$CODE_QUALITY_VIEW")
echo "$CODE_QUALITY_VIEW" > output/code-quality-endorsement-view.envelope

# Compare sizes of the different views
echo "Size comparison of different endorsement views:"
echo "Full XID with all endorsements: $(echo "$XID_DOC" | wc -c) bytes"
echo "Technical skills view: $(echo "$TECHNICAL_VIEW" | wc -c) bytes"
echo "Collaboration view: $(echo "$COLLABORATION_VIEW" | wc -c) bytes"
echo "Code quality view: $(echo "$CODE_QUALITY_VIEW" | wc -c) bytes"

# Display a summary of what we've created
echo -e "\nCreated the following view files using cryptographic elision:"
echo "- output/skills-endorsement-view.envelope (Skills assessment view)"
echo "- output/collaboration-endorsement-view.envelope (Project collaboration view)"
echo "- output/code-quality-endorsement-view.envelope (Code review view)"

# Step 10: BWHacker Creating an Endorsement for Someone Else
echo -e "\n10. BWHacker creating an endorsement for someone else..."

# Create another developer to endorse
envelope generate prvkeys > endorsers/dev-key.private
DEV_PRIVATE=$(cat endorsers/dev-key.private)
DEV_PUBLIC=$(envelope generate pubkeys "$DEV_PRIVATE")
echo "$DEV_PUBLIC" > endorsers/dev-key.public

# Create the developer's XID
DEV_XID=$(envelope xid new --name "PrivacyDev" "$DEV_PUBLIC")
DEV_XID=$(envelope assertion add pred-obj string "gitHubUsername" string "PrivacyDev" "$DEV_XID")
DEV_XID=$(envelope assertion add pred-obj string "domain" string "Privacy Engineering & UX Design" "$DEV_XID")
echo "$DEV_XID" > endorsers/dev-xid.envelope
DEV_XID_ID=$(envelope xid id "$DEV_XID")

# BWHacker creates an endorsement
BWHACKER_PRIVATE=$(cat output/bwhacker-key.private 2>/dev/null)
if [ -n "$BWHACKER_PRIVATE" ]; then
    # Create the endorsement
    BW_ENDORSEMENT=$(envelope subject type string "Endorsement: Collaborative Development Work")
    
    # Identify endorser and relationship
    BW_ENDORSEMENT=$(envelope assertion add pred-obj string "endorser" string "BWHacker - Security specialist with 8 years experience" "$BW_ENDORSEMENT")
    BW_ENDORSEMENT=$(envelope assertion add pred-obj string "relationship" string "Collaborated as peers on privacy authentication library for 4 months" "$BW_ENDORSEMENT")
    BW_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementTarget" string "$DEV_XID_ID" "$BW_ENDORSEMENT")
    
    # Add specific observations
    BW_ENDORSEMENT=$(envelope assertion add pred-obj string "projectReference" string "Privacy-First Authentication Library" "$BW_ENDORSEMENT")
    BW_ENDORSEMENT=$(envelope assertion add pred-obj string "observation" string "PrivacyDev demonstrated exceptional skill in cryptographic implementation and API design" "$BW_ENDORSEMENT")
    BW_ENDORSEMENT=$(envelope assertion add pred-obj string "specificContributions" string "Implemented novel zero-knowledge protocol optimization, reduced computational overhead by 40%" "$BW_ENDORSEMENT")
    
    # Fair witness principles
    BW_ENDORSEMENT=$(envelope assertion add pred-obj string "basis" string "Direct collaboration on codebase with code review and pair programming" "$BW_ENDORSEMENT")
    BW_ENDORSEMENT=$(envelope assertion add pred-obj string "observationPeriod" string "January through April 2023" "$BW_ENDORSEMENT")
    BW_ENDORSEMENT=$(envelope assertion add pred-obj string "endorserLimitation" string "Limited exposure to PrivacyDev's frontend work" "$BW_ENDORSEMENT")
    BW_ENDORSEMENT=$(envelope assertion add pred-obj string "potentialBias" string "Shared research interest in privacy-preserving systems" "$BW_ENDORSEMENT")
    
    # Wrap the endorsement before signing
    WRAPPED_BW_ENDORSEMENT=$(envelope subject type wrapped "$BW_ENDORSEMENT")
    
    # Sign the wrapped endorsement
    SIGNED_BW_ENDORSEMENT=$(envelope sign -s "$BWHACKER_PRIVATE" "$WRAPPED_BW_ENDORSEMENT")
    echo "$SIGNED_BW_ENDORSEMENT" > output/bwhacker-endorsement-of-dev.envelope
    
    # Add to PrivacyDev's XID
    DEV_XID_UPDATED=$(envelope assertion add pred-obj string "receivedEndorsement" envelope "$SIGNED_BW_ENDORSEMENT" "$DEV_XID")
    echo "$DEV_XID_UPDATED" > endorsers/dev-xid-with-endorsement.envelope
    
    echo "BWHacker has created an endorsement for PrivacyDev."
    envelope format --type tree "$SIGNED_BW_ENDORSEMENT" | head -15
    echo "..."
else
    echo "BWHacker's private key not found, skipping endorsement creation."
fi

echo -e "\n=== Peer Endorsement Network Complete ==="
echo "BWHacker now has a network of trust with endorsements from 3 independent sources:"
echo "1. Carlos_SecResearcher - Project collaboration endorsement"
echo "2. MayaCodeX - Code review endorsement"
echo "3. PriyaCrypto - Skill assessment endorsement"
echo "These endorsements provide independent verification of BWHacker's capabilities"
echo "while maintaining pseudonymity for all parties involved."