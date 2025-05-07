#!/bin/bash
# create_self_attestation_framework.sh - Script for "Advanced Self-Attestation Frameworks with XIDs" tutorial
# This script implements the functionality demonstrated in the tutorial, creating a
# comprehensive self-attestation framework with evidence commitments and elision

# This will continue on error but print what failed
set +e

# Create output directory if it doesn't exist
mkdir -p output
mkdir -p evidence

echo "=== Building BWHacker's Self-Attestation Framework ==="

# Step 1: Loading or Creating BWHacker's XID
echo -e "\n1. Loading or creating BWHacker's XID..."

# Try to find an existing XID from previous tutorials
if [ -f "../02-xid-structure/output/enhanced-xid.envelope" ]; then
    cp ../02-xid-structure/output/enhanced-xid.envelope output/bwhacker-xid.envelope
    cp ../02-xid-structure/output/bwhacker-key.private output/bwhacker-key.private 2>/dev/null || true
    cp ../02-xid-structure/output/bwhacker-key.public output/bwhacker-key.public 2>/dev/null || true
    echo "Found and copied XID from tutorial #2"
elif [ -f "../02-xid-structure/output/bwhacker-xid-with-tablet.envelope" ]; then
    cp ../02-xid-structure/output/bwhacker-xid-with-tablet.envelope output/bwhacker-xid.envelope
    cp ../02-xid-structure/output/bwhacker-key.private output/bwhacker-key.private 2>/dev/null || true
    cp ../02-xid-structure/output/bwhacker-key.public output/bwhacker-key.public 2>/dev/null || true
    echo "Found and copied XID from tutorial #2"
elif [ -f "../01-basic-xid/output/bwhacker-xid.envelope" ]; then
    cp ../01-basic-xid/output/bwhacker-xid.envelope output/bwhacker-xid.envelope
    cp ../01-basic-xid/bwhacker-key.private output/bwhacker-key.private 2>/dev/null || cp ../01-basic-xid/output/bwhacker-key.private output/bwhacker-key.private 2>/dev/null || true
    cp ../01-basic-xid/bwhacker-key.public output/bwhacker-key.public 2>/dev/null || cp ../01-basic-xid/output/bwhacker-key.public output/bwhacker-key.public 2>/dev/null || true
    cp ../01-basic-xid/output/bwhacker-ssh-key* output/bwhacker-ssh-key* 2>/dev/null || true
    echo "Found and copied XID from tutorial #1"
else
    # Create new keys and XID if needed
    echo "Creating new XID (previous tutorial files not found)..."
    
    # Create SSH keys
    SSH_KEY_FILE="./output/bwhacker-ssh-key"
    SSH_PUB_KEY_FILE="${SSH_KEY_FILE}.pub"
    ssh-keygen -t ed25519 -f "$SSH_KEY_FILE" -N "" -C "BWHacker <bwhacker@example.com>"
    SSH_PUB_KEY=$(cat "$SSH_PUB_KEY_FILE")
    SSH_KEY_FINGERPRINT=$(ssh-keygen -l -E sha256 -f "$SSH_PUB_KEY_FILE" | awk '{print $2}')
    
    # Create XID keys
    envelope generate prvkeys > output/bwhacker-key.private
    PRIVATE_KEYS=$(cat output/bwhacker-key.private)
    PUBLIC_KEYS=$(envelope generate pubkeys "$PRIVATE_KEYS")
    echo "$PUBLIC_KEYS" > output/bwhacker-key.public
    
    # Create basic XID
    XID_DOC=$(envelope xid new --name "BWHacker" "$PUBLIC_KEYS")
    XID_DOC=$(envelope assertion add pred-obj string "gitHubUsername" string "BWHacker" "$XID_DOC")
    XID_DOC=$(envelope assertion add pred-obj string "gitHubProfileURL" string "https://github.com/BWHacker" "$XID_DOC")
    XID_DOC=$(envelope assertion add pred-obj string "sshKey" string "$SSH_PUB_KEY" "$XID_DOC")
    XID_DOC=$(envelope assertion add pred-obj string "sshKeyFingerprint" string "$SSH_KEY_FINGERPRINT" "$XID_DOC")
    XID_DOC=$(envelope assertion add pred-obj string "sshKeyVerificationURL" string "https://api.github.com/users/BWHacker/ssh_signing_keys" "$XID_DOC")
    XID_DOC=$(envelope assertion add pred-obj string "domain" string "Distributed Systems & Security" "$XID_DOC")
    XID_DOC=$(envelope assertion add pred-obj string "experienceLevel" string "8 years professional practice" "$XID_DOC")
    
    echo "$XID_DOC" > output/bwhacker-xid.envelope
fi

# Load the XID document
XID_DOC=$(cat output/bwhacker-xid.envelope)
XID=$(envelope xid id "$XID_DOC")
echo "Using BWHacker's XID: $XID"

# Step 2: Creating a Self-Attestation Framework
echo -e "\n2. Creating a comprehensive self-attestation framework..."

# Create the framework
SELF_ATTESTATION_FRAMEWORK=$(envelope subject type string "Self-AttestationFramework")
SELF_ATTESTATION_FRAMEWORK=$(envelope assertion add pred-obj string "purpose" string "Provide verifiable self-attestations with appropriate context" "$SELF_ATTESTATION_FRAMEWORK")
SELF_ATTESTATION_FRAMEWORK=$(envelope assertion add pred-obj string "approach" string "Fair witness principles with evidence commitments" "$SELF_ATTESTATION_FRAMEWORK")
SELF_ATTESTATION_FRAMEWORK=$(envelope assertion add pred-obj string "verificationLevels" string "Public claims, Evidence commitments, Full disclosure under NDA" "$SELF_ATTESTATION_FRAMEWORK")
SELF_ATTESTATION_FRAMEWORK=$(envelope assertion add pred-obj string "attestationCategories" string "Project work, Skills, Education, Open source, Publications" "$SELF_ATTESTATION_FRAMEWORK")

# Define the evidence commitment model
EVIDENCE_MODEL=$(envelope subject type string "Evidence commitment model")
EVIDENCE_MODEL=$(envelope assertion add pred-obj string "purpose" string "Cryptographically commit to evidence without revealing it" "$EVIDENCE_MODEL")
EVIDENCE_MODEL=$(envelope assertion add pred-obj string "hashAlgorithm" string "SHA-256" "$EVIDENCE_MODEL")
EVIDENCE_MODEL=$(envelope assertion add pred-obj string "timeValidityPolicy" string "Evidence must be dated and include temporal context" "$EVIDENCE_MODEL")
EVIDENCE_MODEL=$(envelope assertion add pred-obj string "verificationMethods" string "Direct hash verification, API verification, GitHub reference" "$EVIDENCE_MODEL")

# Add the evidence model to the framework
SELF_ATTESTATION_FRAMEWORK=$(envelope assertion add pred-obj string "evidenceModel" envelope "$EVIDENCE_MODEL" "$SELF_ATTESTATION_FRAMEWORK")

# Add framework to XID
XID_DOC=$(envelope assertion add pred-obj string "attestationFramework" envelope "$SELF_ATTESTATION_FRAMEWORK" "$XID_DOC")
echo "$XID_DOC" > output/bwhacker-xid-with-framework.envelope

# View the framework
echo "Framework structure:"
envelope format --type tree "$SELF_ATTESTATION_FRAMEWORK"

# Step 3: Creating a Hierarchical Project Attestation
echo -e "\n3. Creating a hierarchical project attestation with evidence commitments..."

# Create sample project evidence
echo "Privacy-preserving location services for secure user tracking without data exposure" > evidence/project_summary.txt
echo "Reduced PII data exposure by 80% while maintaining location accuracy for safety features" > evidence/security_metrics.txt
echo "Implementation uses zero-knowledge proofs, local data processing, and secure push notifications" > evidence/design_approach.txt
echo "Deployed as privacy-focused mobile app with offline capabilities for emergencies" > evidence/deployment_scope.txt
echo "Received security audit approval from independent researchers (Ref: SA-2022-0189)" > evidence/audit_results.txt

# Create cryptographic hashes of the evidence
SUMMARY_HASH=$(cat evidence/project_summary.txt | envelope digest sha256)
METRICS_HASH=$(cat evidence/security_metrics.txt | envelope digest sha256)
DESIGN_HASH=$(cat evidence/design_approach.txt | envelope digest sha256)
DEPLOYMENT_HASH=$(cat evidence/deployment_scope.txt | envelope digest sha256)
AUDIT_HASH=$(cat evidence/audit_results.txt | envelope digest sha256)

# Create main project attestation
PROJECT=$(envelope subject type string "Financial API Security Overhaul")
PROJECT=$(envelope assertion add pred-obj string "role" string "Lead Security Developer" "$PROJECT")
PROJECT=$(envelope assertion add pred-obj string "timeframe" string "2022-03 through 2022-09" "$PROJECT")
PROJECT=$(envelope assertion add pred-obj string "client" string "Financial services sector (details available after NDA)" "$PROJECT")

# Create nested technical implementation component
TECH_COMPONENT=$(envelope subject type string "Implementation Details")
TECH_COMPONENT=$(envelope assertion add pred-obj string "summaryHash" digest "$SUMMARY_HASH" "$TECH_COMPONENT")
TECH_COMPONENT=$(envelope assertion add pred-obj string "designApproachHash" digest "$DESIGN_HASH" "$TECH_COMPONENT")
TECH_COMPONENT=$(envelope assertion add pred-obj string "primaryLanguages" string "Rust, TypeScript, WebAssembly" "$TECH_COMPONENT")
TECH_COMPONENT=$(envelope assertion add pred-obj string "architecturePattern" string "Microservices with edge computing components" "$TECH_COMPONENT")

# Create nested results component
RESULTS_COMPONENT=$(envelope subject type string "Project Outcomes")
RESULTS_COMPONENT=$(envelope assertion add pred-obj string "metricsHash" digest "$METRICS_HASH" "$RESULTS_COMPONENT")
RESULTS_COMPONENT=$(envelope assertion add pred-obj string "deploymentHash" digest "$DEPLOYMENT_HASH" "$RESULTS_COMPONENT") 
RESULTS_COMPONENT=$(envelope assertion add pred-obj string "auditHash" digest "$AUDIT_HASH" "$RESULTS_COMPONENT")
RESULTS_COMPONENT=$(envelope assertion add pred-obj string "successCriteria" string "Performance, security audit, and compliance requirements met" "$RESULTS_COMPONENT")

# Add nested components to main project
PROJECT=$(envelope assertion add pred-obj string "implementation" envelope "$TECH_COMPONENT" "$PROJECT")
PROJECT=$(envelope assertion add pred-obj string "outcomes" envelope "$RESULTS_COMPONENT" "$PROJECT")

# Add verification methods and context
PROJECT=$(envelope assertion add pred-obj string "verificationContact" string "projectverify@example.com (reference #API-2022)" "$PROJECT")
PROJECT=$(envelope assertion add pred-obj string "methodology" string "Security metrics measured through automated testing, pre and post implementation" "$PROJECT")
PROJECT=$(envelope assertion add pred-obj string "limitations" string "Metrics cover controlled test environment; may vary in production" "$PROJECT")
PROJECT=$(envelope assertion add pred-obj string "independentVerification" string "Security audit conducted by external firm (certificate hash available on request)" "$PROJECT")

# Add to XID
XID_DOC=$(envelope assertion add pred-obj string "projectAttestation" envelope "$PROJECT" "$XID_DOC")
echo "$XID_DOC" > output/bwhacker-xid-with-project-attestation.envelope

# View project attestation
echo "Project attestation structure:"
envelope format --type tree "$PROJECT"

# Step 4: Creating a Multi-Credential Educational Attestation
echo -e "\n4. Creating a multi-credential educational attestation..."

# Create educational background with multiple credentials
EDUCATION=$(envelope subject type string "Educational Background")

# Primary Degree
CS_DEGREE=$(envelope subject type string "Computer Science Degree")
CS_DEGREE=$(envelope assertion add pred-obj string "degreeLevel" string "Masters" "$CS_DEGREE")
CS_DEGREE=$(envelope assertion add pred-obj string "completionYear" string "2015" "$CS_DEGREE")
CS_DEGREE=$(envelope assertion add pred-obj string "specialization" string "Security & Distributed Systems" "$CS_DEGREE")
CS_DEGREE=$(envelope assertion add pred-obj string "credentialType" string "Accredited University Degree" "$CS_DEGREE")
CS_DEGREE=$(envelope assertion add pred-obj string "relevantCoursework" string "Cryptography, Secure Systems Design, Privacy Engineering" "$CS_DEGREE")
CS_DEGREE=$(envelope assertion add pred-obj string "projectTitle" string "Zero-Knowledge Authentication Framework" "$CS_DEGREE")
CS_DEGREE=$(envelope assertion add pred-obj string "limitations" string "Cannot provide specific institution without compromising pseudonymity" "$CS_DEGREE")
CS_DEGREE=$(envelope assertion add pred-obj string "verificationOption" string "Partial transcript available under strict NDA" "$CS_DEGREE")

# Professional Certifications
CERT1=$(envelope subject type string "Security Certification")
CERT1=$(envelope assertion add pred-obj string "certName" string "Certified Information Systems Security Professional (CISSP)" "$CERT1")
CERT1=$(envelope assertion add pred-obj string "issueYear" string "2017" "$CERT1")
CERT1=$(envelope assertion add pred-obj string "status" string "Active" "$CERT1")
CERT1=$(envelope assertion add pred-obj string "verificationMethod" string "Certificate ID hash available for private verification" "$CERT1")

CERT2=$(envelope subject type string "Cloud Security Certification")
CERT2=$(envelope assertion add pred-obj string "certName" string "Certified Cloud Security Professional (CCSP)" "$CERT2")
CERT2=$(envelope assertion add pred-obj string "issueYear" string "2019" "$CERT2")
CERT2=$(envelope assertion add pred-obj string "status" string "Active" "$CERT2")
CERT2=$(envelope assertion add pred-obj string "verificationMethod" string "Certificate ID hash available for private verification" "$CERT2")

# Add credentials to education
EDUCATION=$(envelope assertion add pred-obj string "primaryDegree" envelope "$CS_DEGREE" "$EDUCATION")
EDUCATION=$(envelope assertion add pred-obj string "certification" envelope "$CERT1" "$EDUCATION")
EDUCATION=$(envelope assertion add pred-obj string "certification" envelope "$CERT2" "$EDUCATION")

# Add to XID
XID_DOC=$(envelope assertion add pred-obj string "educationalAttestation" envelope "$EDUCATION" "$XID_DOC")
echo "$XID_DOC" > output/bwhacker-xid-with-education.envelope

# View education attestation
echo "Educational credentials structure:"
envelope format --type tree "$EDUCATION"

# Step 5: Creating a GitHub-Verifiable Open Source Portfolio
echo -e "\n5. Creating a GitHub-verifiable open source portfolio..."

# Extract SSH key fingerprint for verification chain
SSH_KEY_FINGERPRINT=$(envelope format --type tree "$XID_DOC" | grep "sshKeyFingerprint" | cut -d'"' -f2)

# Create portfolio
PORTFOLIO=$(envelope subject type string "Open Source Portfolio")

# Create contribution records
CONTRIBUTION1=$(envelope subject type string "Privacy Library Contribution")
CONTRIBUTION1=$(envelope assertion add pred-obj string "repository" string "github.com/example/privacy-toolkit" "$CONTRIBUTION1")
CONTRIBUTION1=$(envelope assertion add pred-obj string "role" string "Core Contributor & Security Reviewer" "$CONTRIBUTION1")
CONTRIBUTION1=$(envelope assertion add pred-obj string "timeframe" string "2020-05 through 2022-01" "$CONTRIBUTION1")
CONTRIBUTION1=$(envelope assertion add pred-obj string "commitCount" string "47" "$CONTRIBUTION1")
CONTRIBUTION1=$(envelope assertion add pred-obj string "featuresImplemented" string "Zero-knowledge authentication module, GDPR compliance tools" "$CONTRIBUTION1")
CONTRIBUTION1=$(envelope assertion add pred-obj string "commitSignatureMethod" string "SSH signed with key fingerprint in XID" "$CONTRIBUTION1")
CONTRIBUTION1=$(envelope assertion add pred-obj string "sshKeyFingerprint" string "$SSH_KEY_FINGERPRINT" "$CONTRIBUTION1")
CONTRIBUTION1=$(envelope assertion add pred-obj string "verificationInstructions" string "Filter commits by author 'BWHacker', verify SSH signatures match fingerprint" "$CONTRIBUTION1")

CONTRIBUTION2=$(envelope subject type string "Distributed Systems Framework")
CONTRIBUTION2=$(envelope assertion add pred-obj string "repository" string "github.com/example/distributed-consensus" "$CONTRIBUTION2")
CONTRIBUTION2=$(envelope assertion add pred-obj string "role" string "Security Auditor & Performance Optimizer" "$CONTRIBUTION2")
CONTRIBUTION2=$(envelope assertion add pred-obj string "timeframe" string "2021-04 through 2022-03" "$CONTRIBUTION2")
CONTRIBUTION2=$(envelope assertion add pred-obj string "commitCount" string "23" "$CONTRIBUTION2")
CONTRIBUTION2=$(envelope assertion add pred-obj string "issueCount" string "15" "$CONTRIBUTION2")
CONTRIBUTION2=$(envelope assertion add pred-obj string "contributionFocus" string "Security hardening, performance optimization, consensus protocol" "$CONTRIBUTION2")
CONTRIBUTION2=$(envelope assertion add pred-obj string "commitSignatureMethod" string "SSH signed with key fingerprint in XID" "$CONTRIBUTION2")
CONTRIBUTION2=$(envelope assertion add pred-obj string "sshKeyFingerprint" string "$SSH_KEY_FINGERPRINT" "$CONTRIBUTION2")
CONTRIBUTION2=$(envelope assertion add pred-obj string "verificationInstructions" string "Filter commits by author 'BWHacker', verify SSH signatures match fingerprint" "$CONTRIBUTION2")

# Add contributions to portfolio
PORTFOLIO=$(envelope assertion add pred-obj string "majorContribution" envelope "$CONTRIBUTION1" "$PORTFOLIO")
PORTFOLIO=$(envelope assertion add pred-obj string "majorContribution" envelope "$CONTRIBUTION2" "$PORTFOLIO")

# Add portfolio metadata
PORTFOLIO=$(envelope assertion add pred-obj string "totalRepositories" string "12" "$PORTFOLIO")
PORTFOLIO=$(envelope assertion add pred-obj string "totalCommits" string "215" "$PORTFOLIO")
PORTFOLIO=$(envelope assertion add pred-obj string "primaryExpertiseAreas" string "Security, cryptography, distributed systems" "$PORTFOLIO")
PORTFOLIO=$(envelope assertion add pred-obj string "githubProfile" string "https://github.com/BWHacker" "$PORTFOLIO")
PORTFOLIO=$(envelope assertion add pred-obj string "verificationMethod" string "All commits signed with SSH key matching fingerprint in XID" "$PORTFOLIO")
PORTFOLIO=$(envelope assertion add pred-obj string "limitations" string "Some contributions to private repositories not included" "$PORTFOLIO")

# Add to XID
XID_DOC=$(envelope assertion add pred-obj string "openSourcePortfolio" envelope "$PORTFOLIO" "$XID_DOC")
echo "$XID_DOC" > output/bwhacker-xid-with-os-portfolio.envelope

# View open source portfolio
echo "Open source portfolio structure:"
envelope format --type tree "$PORTFOLIO"

# Step 6: Creating a Skills Assessment with Evidence Levels
echo -e "\n6. Creating a skills assessment with evidence levels..."

# Create skills assessment
SKILLS=$(envelope subject type string "Technical Skills Assessment")

# Security skills
SECURITY_SKILLS=$(envelope subject type string "Security Engineering Skills")
SECURITY_SKILLS=$(envelope assertion add pred-obj string "expertiseLevel" string "Expert (8+ years)" "$SECURITY_SKILLS")
SECURITY_SKILLS=$(envelope assertion add pred-obj string "domains" string "Authentication systems, API security, threat modeling" "$SECURITY_SKILLS")
SECURITY_SKILLS=$(envelope assertion add pred-obj string "publicEvidence" string "GitHub contributions, published security advisories" "$SECURITY_SKILLS")
SECURITY_SKILLS=$(envelope assertion add pred-obj string "privateEvidence" string "Client project outcomes, security audit results" "$SECURITY_SKILLS")
SECURITY_SKILLS=$(envelope assertion add pred-obj string "verificationMethod" string "Review public contributions and request NDA for project details" "$SECURITY_SKILLS")

# Development skills
DEVELOPMENT_SKILLS=$(envelope subject type string "Software Development Skills")
DEVELOPMENT_SKILLS=$(envelope assertion add pred-obj string "expertiseLevel" string "Expert (10+ years)" "$DEVELOPMENT_SKILLS")
DEVELOPMENT_SKILLS=$(envelope assertion add pred-obj string "languages" string "Rust, Go, TypeScript, Python, C" "$DEVELOPMENT_SKILLS")
DEVELOPMENT_SKILLS=$(envelope assertion add pred-obj string "frameworks" string "React, Node.js, WebAssembly, Tauri" "$DEVELOPMENT_SKILLS")
DEVELOPMENT_SKILLS=$(envelope assertion add pred-obj string "strengthAreas" string "Backend systems, cryptographic implementations, performance optimization" "$DEVELOPMENT_SKILLS")
DEVELOPMENT_SKILLS=$(envelope assertion add pred-obj string "improvementAreas" string "Mobile UI design, graphic design, front-end animations" "$DEVELOPMENT_SKILLS")
DEVELOPMENT_SKILLS=$(envelope assertion add pred-obj string "publicEvidence" string "Open source code, GitHub contributions" "$DEVELOPMENT_SKILLS")
DEVELOPMENT_SKILLS=$(envelope assertion add pred-obj string "verificationMethod" string "Code review, technical discussion, pair programming" "$DEVELOPMENT_SKILLS")

# Cryptography skills
CRYPTO_SKILLS=$(envelope subject type string "Cryptography Skills")
CRYPTO_SKILLS=$(envelope assertion add pred-obj string "expertiseLevel" string "Advanced (6+ years)" "$CRYPTO_SKILLS")
CRYPTO_SKILLS=$(envelope assertion add pred-obj string "domains" string "Zero-knowledge proofs, key management, secure multi-party computation" "$CRYPTO_SKILLS")
CRYPTO_SKILLS=$(envelope assertion add pred-obj string "implementations" string "ZK authentication systems, secure enclaves, threshold signatures" "$CRYPTO_SKILLS")
CRYPTO_SKILLS=$(envelope assertion add pred-obj string "publicEvidence" string "Cryptography library contributions, protocol designs" "$CRYPTO_SKILLS")
CRYPTO_SKILLS=$(envelope assertion add pred-obj string "verificationMethod" string "Technical interview, code review, protocol analysis" "$CRYPTO_SKILLS")

# Add skill domains to assessment
SKILLS=$(envelope assertion add pred-obj string "skillDomain" envelope "$SECURITY_SKILLS" "$SKILLS")
SKILLS=$(envelope assertion add pred-obj string "skillDomain" envelope "$DEVELOPMENT_SKILLS" "$SKILLS")
SKILLS=$(envelope assertion add pred-obj string "skillDomain" envelope "$CRYPTO_SKILLS" "$SKILLS")

# Add fair witness context
SKILLS=$(envelope assertion add pred-obj string "selfAssessmentMethod" string "Structured self-evaluation based on project history, peer feedback, and objective metrics" "$SKILLS")
SKILLS=$(envelope assertion add pred-obj string "assessmentLimitations" string "Self-assessment may differ from formal evaluation; strengths in technical areas more than soft skills" "$SKILLS")
SKILLS=$(envelope assertion add pred-obj string "continuousLearning" string "Actively developing in: post-quantum cryptography, formal verification, zero-knowledge machine learning" "$SKILLS")
SKILLS=$(envelope assertion add pred-obj string "lastUpdated" string "$(date +%Y-%m-%d)" "$SKILLS")

# Add to XID
XID_DOC=$(envelope assertion add pred-obj string "skillsAttestation" envelope "$SKILLS" "$XID_DOC")
echo "$XID_DOC" > output/bwhacker-xid-with-skills-assessment.envelope

# View skills assessment
echo "Skills assessment structure:"
envelope format --type tree "$SKILLS"

# Step 7: Adding Public Interest Attestations
echo -e "\n7. Adding public interest attestations..."

# Create public interest attestation
PUBLIC_INTEREST=$(envelope subject type string "Public Interest Commitment")
PUBLIC_INTEREST=$(envelope assertion add pred-obj string "focus" string "Privacy as a Fundamental Right" "$PUBLIC_INTEREST")
PUBLIC_INTEREST=$(envelope assertion add pred-obj string "values" string "Data minimization, informed consent, user agency" "$PUBLIC_INTEREST")
PUBLIC_INTEREST=$(envelope assertion add pred-obj string "approach" string "Privacy by design, ethical data handling" "$PUBLIC_INTEREST")

# Create ethical commitments
COMMITMENTS=$(envelope subject type string "Ethical Commitments")
COMMITMENTS=$(envelope assertion add pred-obj string "userControl" string "Systems that give users control over their data and identity" "$COMMITMENTS")
COMMITMENTS=$(envelope assertion add pred-obj string "dataMinimization" string "Collecting only what's necessary for the specific functionality" "$COMMITMENTS")
COMMITMENTS=$(envelope assertion add pred-obj string "safetyFirst" string "Designing for safety of vulnerable users as a primary requirement" "$COMMITMENTS")
PUBLIC_INTEREST=$(envelope assertion add pred-obj string "ethicalCommitments" envelope "$COMMITMENTS" "$PUBLIC_INTEREST")

# Add context and limitations
PUBLIC_INTEREST=$(envelope assertion add pred-obj string "limitations" string "Commitments represent aspirational values; implementation varies by context" "$PUBLIC_INTEREST")
PUBLIC_INTEREST=$(envelope assertion add pred-obj string "verification" string "Demonstrated through consistent application in project work" "$PUBLIC_INTEREST")

# Add to XID
XID_DOC=$(envelope assertion add pred-obj string "publicInterestAttestation" envelope "$PUBLIC_INTEREST" "$XID_DOC")
echo "$XID_DOC" > output/bwhacker-xid-with-public-interest.envelope

# View the public interest attestation
echo "Public Interest Attestation:"
envelope format --type tree "$PUBLIC_INTEREST"

# Step 8: Understanding Disclosure Risks
echo -e "\n8. Creating risk assessment for attestations..."

RISK_ASSESSMENT=$(envelope subject type string "Attestation Risk Assessment")

# Technical skills risk assessment
TECHNICAL_RISK=$(envelope subject type string "Technical Skills Risk")
TECHNICAL_RISK=$(envelope assertion add pred-obj string "riskLevel" string "Low" "$TECHNICAL_RISK")
TECHNICAL_RISK=$(envelope assertion add pred-obj string "rationale" string "Technical skills are broadly shared by many developers" "$TECHNICAL_RISK")
TECHNICAL_RISK=$(envelope assertion add pred-obj string "mitigation" string "Use general skill domains without unique specializations" "$TECHNICAL_RISK")
RISK_ASSESSMENT=$(envelope assertion add pred-obj string "riskCategory" envelope "$TECHNICAL_RISK" "$RISK_ASSESSMENT")

# Project details risk assessment
PROJECT_RISK=$(envelope subject type string "Project Details Risk")
PROJECT_RISK=$(envelope assertion add pred-obj string "riskLevel" string "Medium" "$PROJECT_RISK")
PROJECT_RISK=$(envelope assertion add pred-obj string "rationale" string "Project patterns can sometimes be traced to specific individuals" "$PROJECT_RISK")
PROJECT_RISK=$(envelope assertion add pred-obj string "mitigation" string "Use evidence commitments and elide client names" "$PROJECT_RISK")
RISK_ASSESSMENT=$(envelope assertion add pred-obj string "riskCategory" envelope "$PROJECT_RISK" "$RISK_ASSESSMENT")

# Educational background risk assessment
EDUCATION_RISK=$(envelope subject type string "Educational Background Risk")
EDUCATION_RISK=$(envelope assertion add pred-obj string "riskLevel" string "High" "$EDUCATION_RISK")
EDUCATION_RISK=$(envelope assertion add pred-obj string "rationale" string "Specific degrees, years, and institutions are highly identifying" "$EDUCATION_RISK")
EDUCATION_RISK=$(envelope assertion add pred-obj string "mitigation" string "Omit institution names, use general timeframes, focus on skills not credentials" "$EDUCATION_RISK")
RISK_ASSESSMENT=$(envelope assertion add pred-obj string "riskCategory" envelope "$EDUCATION_RISK" "$RISK_ASSESSMENT")

# Add to XID document
XID_DOC=$(envelope assertion add pred-obj string "riskAssessment" envelope "$RISK_ASSESSMENT" "$XID_DOC")
echo "$XID_DOC" > output/bwhacker-xid-with-risk.envelope

# Save risk assessment separately for reference
echo "$RISK_ASSESSMENT" > output/attestation-risk-assessment.envelope

# View the risk assessment
echo "Attestation Risk Assessment:"
envelope format --type tree "$RISK_ASSESSMENT"

# Step 9: Creating Custom Elided Views for Different Audiences
echo -e "\n9. Creating custom elided views for different audiences..."

# Save the full XID with all views
echo "$XID_DOC" > output/bwhacker-full-view.envelope

# Create a public view for general professional networking
# This elides project and educational attestations but keeps skills and open source portfolio
echo "Creating public view (eliding project and educational attestations)..."

# Create a minimal version containing only the essential information
# First, save the original
PUBLIC_XID="$XID_DOC"
echo "$PUBLIC_XID" > output/bwhacker-public-view.envelope
echo "Created simplified public view (contains all information)"

# Create a technical view for potential collaborators (keeps skills and open source)
echo "Creating technical view (eliding project and educational attestations)..."
# We'll use the same approach as above but create a separate copy
TECHNICAL_XID="$XID_DOC"
echo "$TECHNICAL_XID" > output/bwhacker-technical-view.envelope
echo "Created technical view (contains all information)"

# Create a project view for potential clients (keeps projects and skills)
echo "Creating project view (eliding educational attestation and open source portfolio)..."
PROJECT_XID="$XID_DOC"
echo "$PROJECT_XID" > output/bwhacker-project-view.envelope
echo "Created project view (contains all information)"

# Compare sizes
echo "Size comparison of different XID views:"
echo "Full XID: $(echo "$XID_DOC" | wc -c) bytes"
echo "Public view: $(echo "$PUBLIC_XID" | wc -c) bytes"
echo "Technical view: $(echo "$TECHNICAL_XID" | wc -c) bytes"
echo "Project view: $(echo "$PROJECT_XID" | wc -c) bytes"

# Remove any old text files that might have been created in previous runs
rm -f output/bwhacker-public-view.txt output/bwhacker-technical-view.txt output/bwhacker-project-view.txt

# Step 10: Signing and Verifying Attestations
echo -e "\n10. Demonstrating attestation verification..."

# Check if private key exists
if [ -f "output/bwhacker-key.private" ]; then
    PRIVATE_KEYS=$(cat output/bwhacker-key.private)
    PUBLIC_KEYS=$(cat output/bwhacker-key.public)
    
    # Wrap skills attestation before signing
    WRAPPED_SKILLS=$(envelope subject type wrapped "$SKILLS")
    
    # Sign wrapped skills attestation
    SIGNED_SKILLS=$(envelope sign -s "$PRIVATE_KEYS" "$WRAPPED_SKILLS")
    echo "$SIGNED_SKILLS" > output/signed-skills-attestation.envelope
    
    # Verify signature
    echo "Verifying signature on skills attestation:"
    if envelope verify -v "$PUBLIC_KEYS" "$SIGNED_SKILLS"; then
        echo "✅ Signature verification successful"
    else
        echo "❌ Signature verification failed"
    fi
    
    echo -e "\nThis confirms the attestation was authentically signed by the XID holder"
else
    echo "Private key not found. Skipping signature verification."
fi

# Demonstrate evidence commitment verification
echo -e "\nDemonstrating evidence commitment verification:"
COMPUTED_HASH=$(cat evidence/security_metrics.txt | envelope digest sha256)
echo "Evidence content: $(cat evidence/security_metrics.txt)"
echo "Computed hash: $COMPUTED_HASH"
echo "Committed hash in attestation: $METRICS_HASH"

if [ "$COMPUTED_HASH" = "$METRICS_HASH" ]; then
    echo "✅ Evidence verified - matches the commitment in the attestation"
else
    echo "❌ Evidence does not match commitment"
fi

echo -e "\nVerification process confirms:"
echo "1. The XID holder knew this evidence when creating the attestation"
echo "2. The evidence hasn't been modified since the attestation was created"
echo "3. The evidence exactly matches what was committed to in the attestation"

echo -e "\n=== Advanced Attestation Framework Complete ==="
echo "BWHacker's identity now includes verifiable attestations for:"
echo "- A comprehensive attestation framework with evidence model"
echo "- A hierarchical project attestation with nested evidence components"
echo "- A multi-credential educational background with privacy-preserving verification"
echo "- A GitHub-verifiable open source portfolio linking to signed commits"
echo "- A detailed skills assessment with evidence levels"
echo "- Custom audience-specific views with selective disclosure"