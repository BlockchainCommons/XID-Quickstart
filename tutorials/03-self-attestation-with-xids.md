# Advanced Self-Attestation Frameworks with XIDs

This tutorial demonstrates how Amira builds comprehensive trust frameworks using structured self-attestations with her "BWHacker" pseudonymous identity. You'll learn how to create advanced attestation models with multiple verification methods and evidence commitments while maintaining cryptographic verifiability.

**Time to complete: 30-40 minutes**

> **Related Concepts**: Before or after completing this tutorial, you may want to read about [Fair Witness Approach](../concepts/fair-witness-approach.md) and [Attestation and Endorsement Model](../concepts/attestation-endorsement-model.md) to understand the theoretical foundations behind proper attestations.

## Prerequisites

- Completed the first two XID tutorials
- The envelope CLI tool installed
- BWHacker's XID from the previous tutorials
- Understanding of cryptographic hashing
- Basic understanding of evidence commitments

## What You'll Learn

- How to create advanced self-attestation frameworks with multiple attestation types
- How to build hierarchical attestation structures with nested attestations
- How to include cryptographic evidence commitments for verifiable claims
- How to design different disclosure levels for different verification contexts
- How to apply fair witness principles to self-attestations at scale
- How to link multiple attestations to form a coherent trust network

## Amira's Challenge: Building Comprehensive Trust Frameworks

Having created her pseudonymous identity and understood its technical structure, Amira now needs to build a sophisticated trust framework that enables verifiable contributions across multiple contexts. She needs to:

1. Create different types of attestations for different domains
2. Structure these attestations to support progressive trust building
3. Provide various levels of evidence tailored to different trust relationships
4. Enable selective disclosure while maintaining verifiability
5. Design a unified framework that supports various verification methods

This tutorial focuses on building these advanced attestation structures on top of the basic XID and verification chains established in the previous tutorials.

## 1. Designing an Advanced Self-Attestation Framework

Let's start by creating a comprehensive framework for organizing different types of self-attestations:

👉
First, let's create our output directories:

```sh
mkdir -p output
mkdir -p evidence
```

Next, we'll load BWHacker's XID from the previous tutorial:

```sh
if [ -f "output/enhanced-xid.envelope" ]; then
    XID_DOC=$(cat output/enhanced-xid.envelope)
elif [ -f "output/amira-xid-with-tablet.envelope" ]; then
    XID_DOC=$(cat output/amira-xid-with-tablet.envelope)
elif [ -f "output/amira-xid.envelope" ]; then
    XID_DOC=$(cat output/amira-xid.envelope)
elif [ -f "../02-xid-structure/output/enhanced-xid.envelope" ]; then
    cp ../02-xid-structure/output/enhanced-xid.envelope output/
    XID_DOC=$(cat output/enhanced-xid.envelope)
elif [ -f "../02-xid-structure/output/amira-xid-with-tablet.envelope" ]; then
    cp ../02-xid-structure/output/amira-xid-with-tablet.envelope output/
    XID_DOC=$(cat output/amira-xid-with-tablet.envelope)
else
    echo "Could not find BWHacker's XID from previous tutorials"
    exit 1
fi
```

Now let's create a comprehensive self-attestation framework:

👉 
```sh
SELF_ATTESTATION_FRAMEWORK=$(envelope subject type string "Self-AttestationFramework")
SELF_ATTESTATION_FRAMEWORK=$(envelope assertion add pred-obj string "purpose" string "Provide verifiable self-attestations with appropriate context" "$SELF_ATTESTATION_FRAMEWORK")
SELF_ATTESTATION_FRAMEWORK=$(envelope assertion add pred-obj string "approach" string "Fair witness principles with evidence commitments" "$SELF_ATTESTATION_FRAMEWORK")
SELF_ATTESTATION_FRAMEWORK=$(envelope assertion add pred-obj string "verificationLevels" string "Public claims, Evidence commitments, Full disclosure under NDA" "$SELF_ATTESTATION_FRAMEWORK")
```

Next, let's add the framework categories for different attestation types:

👉 
```sh
SELF_ATTESTATION_FRAMEWORK=$(envelope assertion add pred-obj string "attestationCategories" string "Project work, Skills, Education, Open source, Publications" "$SELF_ATTESTATION_FRAMEWORK")
```

Now let's define the framework's evidence commitment model:

👉 
```sh
EVIDENCE_MODEL=$(envelope subject type string "Evidence commitment model")
EVIDENCE_MODEL=$(envelope assertion add pred-obj string "purpose" string "Cryptographically commit to evidence without revealing it" "$EVIDENCE_MODEL")
EVIDENCE_MODEL=$(envelope assertion add pred-obj string "hashAlgorithm" string "SHA-256" "$EVIDENCE_MODEL")
EVIDENCE_MODEL=$(envelope assertion add pred-obj string "timeValidityPolicy" string "Evidence must be dated and include temporal context" "$EVIDENCE_MODEL")
EVIDENCE_MODEL=$(envelope assertion add pred-obj string "verificationMethods" string "Direct hash verification, API verification, GitHub reference" "$EVIDENCE_MODEL")
```

Now let's add the evidence model to the framework:

👉 
```sh
SELF_ATTESTATION_FRAMEWORK=$(envelope assertion add pred-obj string "evidenceModel" envelope "$EVIDENCE_MODEL" "$SELF_ATTESTATION_FRAMEWORK")
```

Next, let's add the self-attestation framework to BWHacker's XID:

👉 
```sh
XID_DOC=$(envelope assertion add pred-obj string "attestationFramework" envelope "$SELF_ATTESTATION_FRAMEWORK" "$XID_DOC")
echo "$XID_DOC" > output/amira-xid-with-framework.envelope

# View the framework structure
echo "BWHacker's Self-Attestation Framework:"
envelope format --type tree "$SELF_ATTESTATION_FRAMEWORK"
```

🔍
```console
"Self-AttestationFramework" [
   "purpose": "Provide verifiable self-attestations with appropriate context"
   "approach": "Fair witness principles with evidence commitments"
   "verificationLevels": "Public claims, Evidence commitments, Full disclosure under NDA"
   "attestationCategories": "Project work, Skills, Education, Open source, Publications"
   "evidenceModel": "Evidence commitment model" [
      "purpose": "Cryptographically commit to evidence without revealing it"
      "hashAlgorithm": "SHA-256"
      "timeValidityPolicy": "Evidence must be dated and include temporal context"
      "verificationMethods": "Direct hash verification, API verification, GitHub reference"
   ]
]
```

This framework provides a structured approach to organizing different types of attestations with clear verification levels and evidence requirements.

## 2. Creating a Hierarchical Project Attestation

Now let's create a sophisticated project attestation with nested structure and multiple evidence commitments:

👉
First, let's create some sample project evidence files:

```sh
echo "API security enhancements with privacy-preserving authentication system" > evidence/project_summary.txt
echo "Reduced data exposure by 60% while improving authentication speed by 35%" > evidence/security_metrics.txt
echo "Implementation uses zero-knowledge proofs, rate limiting, and robust input validation" > evidence/design_approach.txt
echo "Deployed to production environments across 3 geographic regions" > evidence/deployment_scope.txt
echo "Received security audit approval from external firm (Ref: SA-2023-0142)" > evidence/audit_results.txt
```

Now we'll create cryptographic hashes of this evidence:

👉
```sh
SUMMARY_HASH=$(cat evidence/project_summary.txt | envelope digest sha256)
METRICS_HASH=$(cat evidence/security_metrics.txt | envelope digest sha256)
DESIGN_HASH=$(cat evidence/design_approach.txt | envelope digest sha256)
DEPLOYMENT_HASH=$(cat evidence/deployment_scope.txt | envelope digest sha256)
AUDIT_HASH=$(cat evidence/audit_results.txt | envelope digest sha256)
```

Next, let's create the main project attestation:
👉 
```sh
PROJECT=$(envelope subject type string "Financial API Security Overhaul")
PROJECT=$(envelope assertion add pred-obj string "role" string "Lead Security Developer" "$PROJECT")
PROJECT=$(envelope assertion add pred-obj string "timeframe" string "2022-03 through 2022-09" "$PROJECT")
PROJECT=$(envelope assertion add pred-obj string "client" string "Financial services sector (details available after NDA)" "$PROJECT")
```

Now let's create a nested technical component for implementation details:
👉 
```sh
TECH_COMPONENT=$(envelope subject type string "Implementation Details")
TECH_COMPONENT=$(envelope assertion add pred-obj string "summaryHash" digest "$SUMMARY_HASH" "$TECH_COMPONENT")
TECH_COMPONENT=$(envelope assertion add pred-obj string "designApproachHash" digest "$DESIGN_HASH" "$TECH_COMPONENT")
TECH_COMPONENT=$(envelope assertion add pred-obj string "primaryLanguages" string "Rust, TypeScript, WebAssembly" "$TECH_COMPONENT")
TECH_COMPONENT=$(envelope assertion add pred-obj string "architecturePattern" string "Microservices with edge computing components" "$TECH_COMPONENT")
```

Next, let's create a nested results component for outcome evidence:
👉 
```sh
RESULTS_COMPONENT=$(envelope subject type string "Project Outcomes")
RESULTS_COMPONENT=$(envelope assertion add pred-obj string "metricsHash" digest "$METRICS_HASH" "$RESULTS_COMPONENT")
RESULTS_COMPONENT=$(envelope assertion add pred-obj string "deploymentHash" digest "$DEPLOYMENT_HASH" "$RESULTS_COMPONENT") 
RESULTS_COMPONENT=$(envelope assertion add pred-obj string "auditHash" digest "$AUDIT_HASH" "$RESULTS_COMPONENT")
RESULTS_COMPONENT=$(envelope assertion add pred-obj string "successCriteria" string "Performance, security audit, and compliance requirements met" "$RESULTS_COMPONENT")
```

Finally, let's add the nested components to the main project:
👉 
```sh
PROJECT=$(envelope assertion add pred-obj string "implementation" envelope "$TECH_COMPONENT" "$PROJECT")
PROJECT=$(envelope assertion add pred-obj string "outcomes" envelope "$RESULTS_COMPONENT" "$PROJECT")
```

Now let's add verification methods and context (following fair witnessing principles):

👉 
```sh
PROJECT=$(envelope assertion add pred-obj string "verificationContact" string "projectverify@example.com (reference #API-2022)" "$PROJECT")
PROJECT=$(envelope assertion add pred-obj string "methodology" string "Security metrics measured through automated testing, pre and post implementation" "$PROJECT")
PROJECT=$(envelope assertion add pred-obj string "limitations" string "Metrics cover controlled test environment; may vary in production" "$PROJECT")
PROJECT=$(envelope assertion add pred-obj string "independentVerification" string "Security audit conducted by external firm (certificate hash available on request)" "$PROJECT")
```

Now let's add this to BWHacker's XID as a formal self-attestation:
👉 
```sh
XID_DOC=$(envelope assertion add pred-obj string "projectAttestation" envelope "$PROJECT" "$XID_DOC")
echo "$XID_DOC" > output/amira-xid-with-project.envelope
```

Let's view the hierarchical project attestation structure:

👉 
```sh
echo "Hierarchical Project Attestation Structure:"
envelope format --type tree "$PROJECT"
```

🔍
```console
"Financial API Security Overhaul" [
   "role": "Lead Security Developer"
   "timeframe": "2022-03 through 2022-09"
   "client": "Financial services sector (details available after NDA)"
   "implementation": "Implementation Details" [
      "summaryHash": DIGEST
      "designApproachHash": DIGEST
      "primaryLanguages": "Rust, TypeScript, WebAssembly"
      "architecturePattern": "Microservices with edge computing components"
   ]
   "outcomes": "Project Outcomes" [
      "metricsHash": DIGEST
      "deploymentHash": DIGEST
      "auditHash": DIGEST
      "successCriteria": "Performance, security audit, and compliance requirements met"
   ]
   "verificationContact": "projectverify@example.com (reference #API-2022)"
   "methodology": "Security metrics measured through automated testing, pre and post implementation"
   "limitations": "Metrics cover controlled test environment; may vary in production"
   "independentVerification": "Security audit conducted by external firm (certificate hash available on request)"
]
```

This hierarchical structure organizes information logically while protecting sensitive details through evidence commitments, providing multiple levels of verification.

## 3. Creating a Multi-Credential Educational Attestation

Let's create an educational attestation with a multi-credential structure that respects privacy:

👉
```sh
# Create an educational background attestation with multiple credentials
EDUCATION=$(envelope subject type string "Educational Background")

# Primary Degree (Computer Science)
CS_DEGREE=$(envelope subject type string "Computer Science Degree")
CS_DEGREE=$(envelope assertion add pred-obj string "degreeLevel" string "Masters" "$CS_DEGREE")
CS_DEGREE=$(envelope assertion add pred-obj string "completionYear" string "2015" "$CS_DEGREE")
CS_DEGREE=$(envelope assertion add pred-obj string "specialization" string "Security & Distributed Systems" "$CS_DEGREE")
CS_DEGREE=$(envelope assertion add pred-obj string "credentialType" string "Accredited University Degree" "$CS_DEGREE")
CS_DEGREE=$(envelope assertion add pred-obj string "relevantCoursework" string "Cryptography, Secure Systems Design, Privacy Engineering" "$CS_DEGREE")
CS_DEGREE=$(envelope assertion add pred-obj string "projectTitle" string "Zero-Knowledge Authentication Framework" "$CS_DEGREE")

# Add context and limitations for fair witnessing
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

# Add all credentials to the educational background
EDUCATION=$(envelope assertion add pred-obj string "primaryDegree" envelope "$CS_DEGREE" "$EDUCATION")
EDUCATION=$(envelope assertion add pred-obj string "certification" envelope "$CERT1" "$EDUCATION")
EDUCATION=$(envelope assertion add pred-obj string "certification" envelope "$CERT2" "$EDUCATION")

# Add to BWHacker's XID
XID_DOC=$(envelope assertion add pred-obj string "educationalAttestation" envelope "$EDUCATION" "$XID_DOC")
echo "$XID_DOC" > output/amira-xid-with-education.envelope

# View the educational attestation
echo "Multi-Credential Educational Attestation:"
envelope format --type tree "$EDUCATION"
```

🔍
```console
"Educational Background" [
   "primaryDegree": "Computer Science Degree" [
      "degreeLevel": "Masters"
      "completionYear": "2015"
      "specialization": "Security & Distributed Systems"
      "credentialType": "Accredited University Degree"
      "relevantCoursework": "Cryptography, Secure Systems Design, Privacy Engineering"
      "projectTitle": "Zero-Knowledge Authentication Framework"
      "limitations": "Cannot provide specific institution without compromising pseudonymity"
      "verificationOption": "Partial transcript available under strict NDA"
   ]
   "certification": "Security Certification" [
      "certName": "Certified Information Systems Security Professional (CISSP)"
      "issueYear": "2017"
      "status": "Active"
      "verificationMethod": "Certificate ID hash available for private verification"
   ]
   "certification": "Cloud Security Certification" [
      "certName": "Certified Cloud Security Professional (CCSP)"
      "issueYear": "2019"
      "status": "Active"
      "verificationMethod": "Certificate ID hash available for private verification"
   ]
]
```

This multi-credential structure enables Amira to provide detailed educational information without revealing her identity, while still offering verification paths for each credential.

## 4. Creating a GitHub-Verifiable Open Source Portfolio

Now let's create an open source contribution portfolio with direct links to verifiable GitHub activity:

👉
```sh
# Create a GitHub-verifiable open source portfolio
PORTFOLIO=$(envelope subject type string "Open Source Portfolio")

# Extract SSH key fingerprint from XID for verification chain
SSH_KEY_FINGERPRINT=$(envelope format --type tree "$XID_DOC" | grep "sshKeyFingerprint" | cut -d'"' -f2)

# Create sample contribution records
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

# Add project contributions to the portfolio
PORTFOLIO=$(envelope assertion add pred-obj string "majorContribution" envelope "$CONTRIBUTION1" "$PORTFOLIO")
PORTFOLIO=$(envelope assertion add pred-obj string "majorContribution" envelope "$CONTRIBUTION2" "$PORTFOLIO")

# Add portfolio metadata
PORTFOLIO=$(envelope assertion add pred-obj string "totalRepositories" string "12" "$PORTFOLIO")
PORTFOLIO=$(envelope assertion add pred-obj string "totalCommits" string "215" "$PORTFOLIO")
PORTFOLIO=$(envelope assertion add pred-obj string "primaryExpertiseAreas" string "Security, cryptography, distributed systems" "$PORTFOLIO")
PORTFOLIO=$(envelope assertion add pred-obj string "githubProfile" string "https://github.com/BWHacker" "$PORTFOLIO")
PORTFOLIO=$(envelope assertion add pred-obj string "verificationMethod" string "All commits signed with SSH key matching fingerprint in XID" "$PORTFOLIO")
PORTFOLIO=$(envelope assertion add pred-obj string "limitations" string "Some contributions to private repositories not included" "$PORTFOLIO")

# Add to BWHacker's XID
XID_DOC=$(envelope assertion add pred-obj string "openSourcePortfolio" envelope "$PORTFOLIO" "$XID_DOC")
echo "$XID_DOC" > output/amira-xid-with-os-portfolio.envelope

# View the open source portfolio
echo "GitHub-Verifiable Open Source Portfolio:"
envelope format --type tree "$PORTFOLIO"
```

🔍
```console
"Open Source Portfolio" [
   "majorContribution": "Privacy Library Contribution" [
      "repository": "github.com/example/privacy-toolkit"
      "role": "Core Contributor & Security Reviewer"
      "timeframe": "2020-05 through 2022-01"
      "commitCount": "47"
      "featuresImplemented": "Zero-knowledge authentication module, GDPR compliance tools"
      "commitSignatureMethod": "SSH signed with key fingerprint in XID"
      "sshKeyFingerprint": "SHA256:dFbxBGrqMQNJKpZccInX7l/QE1xH/jNzDvUo/jICSHE"
      "verificationInstructions": "Filter commits by author 'BWHacker', verify SSH signatures match fingerprint"
   ]
   "majorContribution": "Distributed Systems Framework" [
      "repository": "github.com/example/distributed-consensus"
      "role": "Security Auditor & Performance Optimizer"
      "timeframe": "2021-04 through 2022-03"
      "commitCount": "23"
      "issueCount": "15"
      "contributionFocus": "Security hardening, performance optimization, consensus protocol"
      "commitSignatureMethod": "SSH signed with key fingerprint in XID"
      "sshKeyFingerprint": "SHA256:dFbxBGrqMQNJKpZccInX7l/QE1xH/jNzDvUo/jICSHE"
      "verificationInstructions": "Filter commits by author 'BWHacker', verify SSH signatures match fingerprint"
   ]
   "totalRepositories": "12"
   "totalCommits": "215"
   "primaryExpertiseAreas": "Security, cryptography, distributed systems"
   "githubProfile": "https://github.com/BWHacker"
   "verificationMethod": "All commits signed with SSH key matching fingerprint in XID"
   "limitations": "Some contributions to private repositories not included"
]
```

This portfolio connects directly to Amira's GitHub activity, creating a verifiable chain between her pseudonymous XID and her public contributions.

## 5. Creating a Comprehensive Skills Assessment with Evidence Levels

Let's create a detailed skills assessment with evidence levels for different verification contexts:

👉
```sh
# Create a comprehensive skills assessment
SKILLS=$(envelope subject type string "Technical Skills Assessment")

# Core technical skill domains with evidence levels
SECURITY_SKILLS=$(envelope subject type string "Security Engineering Skills")
SECURITY_SKILLS=$(envelope assertion add pred-obj string "expertiseLevel" string "Expert (8+ years)" "$SECURITY_SKILLS")
SECURITY_SKILLS=$(envelope assertion add pred-obj string "domains" string "Authentication systems, API security, threat modeling" "$SECURITY_SKILLS")
SECURITY_SKILLS=$(envelope assertion add pred-obj string "publicEvidence" string "GitHub contributions, published security advisories" "$SECURITY_SKILLS")
SECURITY_SKILLS=$(envelope assertion add pred-obj string "privateEvidence" string "Client project outcomes, security audit results" "$SECURITY_SKILLS")
SECURITY_SKILLS=$(envelope assertion add pred-obj string "verificationMethod" string "Review public contributions and request NDA for project details" "$SECURITY_SKILLS")

DEVELOPMENT_SKILLS=$(envelope subject type string "Software Development Skills")
DEVELOPMENT_SKILLS=$(envelope assertion add pred-obj string "expertiseLevel" string "Expert (10+ years)" "$DEVELOPMENT_SKILLS")
DEVELOPMENT_SKILLS=$(envelope assertion add pred-obj string "languages" string "Rust, Go, TypeScript, Python, C" "$DEVELOPMENT_SKILLS")
DEVELOPMENT_SKILLS=$(envelope assertion add pred-obj string "frameworks" string "React, Node.js, WebAssembly, Tauri" "$DEVELOPMENT_SKILLS")
DEVELOPMENT_SKILLS=$(envelope assertion add pred-obj string "strengthAreas" string "Backend systems, cryptographic implementations, performance optimization" "$DEVELOPMENT_SKILLS")
DEVELOPMENT_SKILLS=$(envelope assertion add pred-obj string "improvementAreas" string "Mobile UI design, graphic design, front-end animations" "$DEVELOPMENT_SKILLS")
DEVELOPMENT_SKILLS=$(envelope assertion add pred-obj string "publicEvidence" string "Open source code, GitHub contributions" "$DEVELOPMENT_SKILLS")
DEVELOPMENT_SKILLS=$(envelope assertion add pred-obj string "verificationMethod" string "Code review, technical discussion, pair programming" "$DEVELOPMENT_SKILLS")

CRYPTO_SKILLS=$(envelope subject type string "Cryptography Skills")
CRYPTO_SKILLS=$(envelope assertion add pred-obj string "expertiseLevel" string "Advanced (6+ years)" "$CRYPTO_SKILLS")
CRYPTO_SKILLS=$(envelope assertion add pred-obj string "domains" string "Zero-knowledge proofs, key management, secure multi-party computation" "$CRYPTO_SKILLS")
CRYPTO_SKILLS=$(envelope assertion add pred-obj string "implementations" string "ZK authentication systems, secure enclaves, threshold signatures" "$CRYPTO_SKILLS")
CRYPTO_SKILLS=$(envelope assertion add pred-obj string "publicEvidence" string "Cryptography library contributions, protocol designs" "$CRYPTO_SKILLS")
CRYPTO_SKILLS=$(envelope assertion add pred-obj string "verificationMethod" string "Technical interview, code review, protocol analysis" "$CRYPTO_SKILLS")

# Add skill domains to the skills assessment
SKILLS=$(envelope assertion add pred-obj string "skillDomain" envelope "$SECURITY_SKILLS" "$SKILLS")
SKILLS=$(envelope assertion add pred-obj string "skillDomain" envelope "$DEVELOPMENT_SKILLS" "$SKILLS")
SKILLS=$(envelope assertion add pred-obj string "skillDomain" envelope "$CRYPTO_SKILLS" "$SKILLS")

# Add fair witness context
SKILLS=$(envelope assertion add pred-obj string "selfAssessmentMethod" string "Structured self-evaluation based on project history, peer feedback, and objective metrics" "$SKILLS")
SKILLS=$(envelope assertion add pred-obj string "assessmentLimitations" string "Self-assessment may differ from formal evaluation; strengths in technical areas more than soft skills" "$SKILLS")
SKILLS=$(envelope assertion add pred-obj string "continuousLearning" string "Actively developing in: post-quantum cryptography, formal verification, zero-knowledge machine learning" "$SKILLS")
SKILLS=$(envelope assertion add pred-obj string "lastUpdated" string "$(date +%Y-%m-%d)" "$SKILLS")

# Add to BWHacker's XID
XID_DOC=$(envelope assertion add pred-obj string "skillsAttestation" envelope "$SKILLS" "$XID_DOC")
echo "$XID_DOC" > output/amira-xid-with-skills.envelope

# View the skills assessment structure
echo "Comprehensive Skills Assessment Framework:"
envelope format --type tree "$SKILLS"
```

🔍
```console
"Technical Skills Assessment" [
   "skillDomain": "Security Engineering Skills" [
      "expertiseLevel": "Expert (8+ years)"
      "domains": "Authentication systems, API security, threat modeling"
      "publicEvidence": "GitHub contributions, published security advisories"
      "privateEvidence": "Client project outcomes, security audit results"
      "verificationMethod": "Review public contributions and request NDA for project details"
   ]
   "skillDomain": "Software Development Skills" [
      "expertiseLevel": "Expert (10+ years)"
      "languages": "Rust, Go, TypeScript, Python, C"
      "frameworks": "React, Node.js, WebAssembly, Tauri"
      "strengthAreas": "Backend systems, cryptographic implementations, performance optimization"
      "improvementAreas": "Mobile UI design, graphic design, front-end animations"
      "publicEvidence": "Open source code, GitHub contributions"
      "verificationMethod": "Code review, technical discussion, pair programming"
   ]
   "skillDomain": "Cryptography Skills" [
      "expertiseLevel": "Advanced (6+ years)"
      "domains": "Zero-knowledge proofs, key management, secure multi-party computation"
      "implementations": "ZK authentication systems, secure enclaves, threshold signatures"
      "publicEvidence": "Cryptography library contributions, protocol designs"
      "verificationMethod": "Technical interview, code review, protocol analysis"
   ]
   "selfAssessmentMethod": "Structured self-evaluation based on project history, peer feedback, and objective metrics"
   "assessmentLimitations": "Self-assessment may differ from formal evaluation; strengths in technical areas more than soft skills"
   "continuousLearning": "Actively developing in: post-quantum cryptography, formal verification, zero-knowledge machine learning"
   "lastUpdated": "2023-05-12"
]
```

This skills framework provides a nuanced assessment with different evidence types and verification methods for each skill domain, while acknowledging limitations.

## 6. Creating Custom Elided Views for Different Audiences

Let's create specialized elided views of BWHacker's XID for different audiences:

👉
```sh
# Create a public view for general professional networking
PUBLIC_XID=$(envelope elide assertion predicate string "projectAttestation" "$XID_DOC")
PUBLIC_XID=$(envelope elide assertion predicate string "educationalAttestation" "$PUBLIC_XID")
echo "$PUBLIC_XID" > output/bwhacker-public-view.envelope

# Create a technical view for potential collaborators (keeps skills and open source)
TECHNICAL_XID=$(envelope elide assertion predicate string "projectAttestation" "$XID_DOC")
TECHNICAL_XID=$(envelope elide assertion predicate string "educationalAttestation" "$TECHNICAL_XID")
echo "$TECHNICAL_XID" > output/bwhacker-technical-view.envelope

# Create a project view for potential clients (keeps projects and skills)
PROJECT_XID=$(envelope elide assertion predicate string "educationalAttestation" "$XID_DOC")
PROJECT_XID=$(envelope elide assertion predicate string "openSourcePortfolio" "$PROJECT_XID")
echo "$PROJECT_XID" > output/bwhacker-project-view.envelope

# View the sizes of the different profiles
echo "Size comparison of different XID views:"
echo "Full XID: $(echo "$XID_DOC" | wc -c) bytes"
echo "Public view: $(echo "$PUBLIC_XID" | wc -c) bytes"
echo "Technical view: $(echo "$TECHNICAL_XID" | wc -c) bytes"
echo "Project view: $(echo "$PROJECT_XID" | wc -c) bytes"
```

🔍
```console
Size comparison of different XID views:
Full XID: 4782 bytes
Public view: 1654 bytes
Technical view: 2836 bytes
Project view: 3219 bytes
```

These different views enable Amira to share tailored portions of her identity with different audiences while maintaining cryptographic verifiability of each view.

## 7. Affirming Attestations and Evidence

Let's demonstrate the affirmation process for the evidence commitments and attestations:

👉
```sh
# Use the private key if available to sign the most comprehensive attestation (skills)
if [ -f "output/amira-key.private" ]; then
    PRIVATE_KEYS=$(cat output/amira-key.private)
    PUBLIC_KEYS=$(cat output/amira-key.public)
    
    # Sign the skills attestation
    SIGNED_SKILLS=$(envelope sign -s "$PRIVATE_KEYS" "$SKILLS")
    echo "$SIGNED_SKILLS" > output/signed-skills-attestation.envelope
    
    # Verify the signature
    echo "Verifying signature on skills attestation:"
    if envelope verify -v "$PUBLIC_KEYS" "$SIGNED_SKILLS"; then
        echo "✅ Signature verification successful"
    else
        echo "❌ Signature verification failed"
    fi
    
    echo -e "\nThis verification confirms the attestation was signed by the XID holder"
fi

# Demonstrate evidence commitment verification
echo -e "\nDemonstrating verification of evidence commitments:"
COMPUTED_HASH=$(cat evidence/security_metrics.txt | envelope digest sha256)
echo "Evidence content: $(cat evidence/security_metrics.txt)"
echo "Computed hash: $COMPUTED_HASH"
echo "Committed hash in attestation: $METRICS_HASH"

if [ "$COMPUTED_HASH" = "$METRICS_HASH" ]; then
    echo "✅ Evidence verified - matches the commitment in the attestation"
else
    echo "❌ Evidence does not match commitment"
fi

echo -e "\nThis verification process confirms:"
echo "1. The XID holder knew this evidence when creating the attestation"
echo "2. The evidence hasn't been modified since the attestation was created"
echo "3. The evidence exactly matches what was committed to in the attestation"
```

🔍
```console
Verifying signature on skills attestation:
✅ Signature verification successful

This verification confirms the attestation was signed by the XID holder

Demonstrating verification of evidence commitments:
Evidence content: Reduced data exposure by 60% while improving authentication speed by 35%
Computed hash: 9c7b54a731a08643209d9b352392a3b1960a25b3f761b388b8180ed82d3e8cd2
Committed hash in attestation: 9c7b54a731a08643209d9b352392a3b1960a25b3f761b388b8180ed82d3e8cd2
✅ Evidence verified - matches the commitment in the attestation

This verification process confirms:
1. The XID holder knew this evidence when creating the attestation
2. The evidence hasn't been modified since the attestation was created
3. The evidence exactly matches what was committed to in the attestation
```

This verification demonstrates how others can validate evidence and attestations through cryptographic means without Amira revealing her identity.

## Understanding the Advanced Attestation Framework

In this tutorial, we've seen how Amira creates a sophisticated self-attestation framework:

1. **Structured Framework Design**: Creating a comprehensive framework to organize different attestation types and evidence models.

2. **Hierarchical Information Organization**: Building nested structures that logically arrange information while supporting selective disclosure.

3. **Multi-Credential Approach**: Organizing multiple credentials in a way that protects privacy while enabling verification.

4. **GitHub Verification Integration**: Creating a bidirectional verification chain between the XID and GitHub activity.

5. **Evidence Level Separation**: Distinguishing between public, private, and confidential evidence with appropriate verification paths.

6. **Audience-Specific Views**: Creating tailored profiles for different verification contexts while maintaining integrity.

7. **Fair Witness Principles at Scale**: Consistently applying proper context, limitations, and verification methods across all attestation types.

This approach enables Amira to build comprehensive trust frameworks without revealing her identity, using cryptographic verification and selective disclosure to control what information is shared with whom.

## Next Steps

In the next tutorial, we'll explore how Amira can further strengthen her professional identity through peer endorsements - attestations made by others that verify her claims and add additional trust signals to her pseudonymous identity.

## Exercises

1. Create your own multi-level attestation structure for a different domain (e.g., creative work, research).

2. Design different elided views for specific audiences and verification purposes.

3. Create a verification chain that incorporates multiple types of evidence (e.g., GitHub, professional certification, project results).

4. Build an attestation with nested evidence commitments that reveal progressively more detail.

5. Design a hierarchical skills framework with evidence commitments for each skill level.