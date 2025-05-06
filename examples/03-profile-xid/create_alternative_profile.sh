#!/bin/bash
# create_alternative_profile.sh - Alternative approach to XID profile creation
#
# This script demonstrates an alternative approach to creating XIDs with progressive disclosure
# without using elision. While the tutorial and create_self_attestation_framework.sh show elision-based
# selective disclosure, this script shows how to create separate profiles with different
# information levels. It also includes additional fair witness practices and portfolio structures.

# This will continue even with some errors
set +e

echo "=== Building BWHacker's Alternative Profile XID ==="

# Create output directory
mkdir -p output

# Step 1: Starting with BWHacker's Basic XID
echo -e "\n1. Starting with BWHacker's basic XID..."

# Create a new XID for this tutorial
PRIVATE_KEYS=$(envelope generate prvkeys)
echo "$PRIVATE_KEYS" > output/bwhacker-key.private
PUBLIC_KEYS=$(envelope generate pubkeys "$PRIVATE_KEYS")
echo "$PUBLIC_KEYS" > output/bwhacker-key.public

# Create a basic XID with pseudonym and key
XID_DOC=$(envelope xid new --name "BWHacker" "$PUBLIC_KEYS")
echo "$XID_DOC" > output/bwhacker-xid.envelope

# View the starting point
XID_ID=$(envelope xid id "$XID_DOC")
echo "BWHacker's XID: $XID_ID"
envelope format --type tree "$XID_DOC"

# Step 2: Adding Professional Background
echo -e "\n2. Adding professional background..."

# Add professional details with pseudonymous approach
XID_DOC=$(envelope assertion add pred-obj string "profession" string "Software Engineer" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "specialization" string "Distributed Systems & Security" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "experience" number 8 "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "languages" string "Python, Rust, JavaScript" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "region" string "Europe" "$XID_DOC")

echo "XID with professional background:"
envelope format --type tree "$XID_DOC"

# Step 3: Adding Evidence of Competence
echo -e "\n3. Adding evidence of competence..."

# Create cryptographic commitment to evidence
PROJECT_EVIDENCE=$(envelope subject type string "Financial API Security Project")
PROJECT_EVIDENCE=$(envelope assertion add pred-obj string "projectRole" string "Security Authentication Developer" "$PROJECT_EVIDENCE")
PROJECT_EVIDENCE=$(envelope assertion add pred-obj string "contributionDate" string "2022-08-10" "$PROJECT_EVIDENCE")
PROJECT_EVIDENCE=$(envelope assertion add pred-obj string "innovationMetric" string "60% reduction in data exposure with 35% authentication speed improvement" "$PROJECT_EVIDENCE")
PROJECT_EVIDENCE=$(envelope assertion add pred-obj string "methodology" string "Zero-knowledge proofs with distributed rate limiting implementation" "$PROJECT_EVIDENCE")
PROJECT_EVIDENCE=$(envelope assertion add pred-obj string "assessmentMethod" string "System logs and security metrics available with permission" "$PROJECT_EVIDENCE")

# Add evidence to XID
XID_DOC=$(envelope assertion add pred-obj string "evidence" envelope "$PROJECT_EVIDENCE" "$XID_DOC")

echo "XID with evidence of competence:"
envelope format --type tree "$PROJECT_EVIDENCE"

# Step 4: Adding Peer Attestations
echo -e "\n4. Adding peer attestations..."

# Create peer attestation from project manager
PM_ATTESTATION=$(envelope subject type string "Attestation: Financial API Project")
PM_ATTESTATION=$(envelope assertion add pred-obj string "observer" string "TechPM - Project Manager with 12 years experience" "$PM_ATTESTATION")
PM_ATTESTATION=$(envelope assertion add pred-obj string "projectReference" string "Financial API Security Overhaul" "$PM_ATTESTATION")
PM_ATTESTATION=$(envelope assertion add pred-obj string "observation" string "BWHacker designed innovative authentication system that exceeded security requirements while maintaining performance" "$PM_ATTESTATION")
PM_ATTESTATION=$(envelope assertion add pred-obj string "basis" string "Direct project oversight including review of implementation results" "$PM_ATTESTATION")
PM_ATTESTATION=$(envelope assertion add pred-obj string "observationDate" string "2022-09-15" "$PM_ATTESTATION")
PM_ATTESTATION=$(envelope assertion add pred-obj string "potentialBias" string "Had management responsibility for project success" "$PM_ATTESTATION")

# Create peer attestation from technical collaborator
TECH_ATTESTATION=$(envelope subject type string "Attestation: Technical Collaboration")
TECH_ATTESTATION=$(envelope assertion add pred-obj string "observer" string "DevSecOps Engineer with 5 years in security infrastructure" "$TECH_ATTESTATION")
TECH_ATTESTATION=$(envelope assertion add pred-obj string "projectReference" string "Secure Payment Gateway" "$TECH_ATTESTATION")
TECH_ATTESTATION=$(envelope assertion add pred-obj string "observation" string "BWHacker implemented zero-knowledge authentication layer with excellent code quality" "$TECH_ATTESTATION")
TECH_ATTESTATION=$(envelope assertion add pred-obj string "basis" string "Code review and pair programming sessions" "$TECH_ATTESTATION")
TECH_ATTESTATION=$(envelope assertion add pred-obj string "observationDate" string "2023-04-22" "$TECH_ATTESTATION")
TECH_ATTESTATION=$(envelope assertion add pred-obj string "limitations" string "Limited to backend components; did not observe frontend work" "$TECH_ATTESTATION")

# Add attestations to XID
XID_DOC=$(envelope assertion add pred-obj string "attestation" envelope "$PM_ATTESTATION" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "attestation" envelope "$TECH_ATTESTATION" "$XID_DOC")

echo "Peer attestations (showing project manager attestation):"
envelope format --type tree "$PM_ATTESTATION"

# Step 5: Adding Key Projects in Portfolio
echo -e "\n5. Adding key projects to portfolio..."

# Create structured project entries with pseudonymous approach
PROJECT1=$(envelope subject type string "Distributed API Security System")
PROJECT1=$(envelope assertion add pred-obj string "client" string "Financial Services Company" "$PROJECT1")
PROJECT1=$(envelope assertion add pred-obj string "year" string "2022" "$PROJECT1")
PROJECT1=$(envelope assertion add pred-obj string "role" string "Lead Security Engineer" "$PROJECT1")
PROJECT1=$(envelope assertion add pred-obj string "description" string "Privacy-preserving authentication system for distributed APIs" "$PROJECT1")
PROJECT1=$(envelope assertion add pred-obj string "recognition" string "Financial Technology Security Innovation Award" "$PROJECT1")
PROJECT1=$(envelope assertion add pred-obj string "observableMetrics" string "60% data exposure reduction, 99.99% uptime" "$PROJECT1")

PROJECT2=$(envelope subject type string "Zero-Knowledge Authentication API")
PROJECT2=$(envelope assertion add pred-obj string "client" string "Financial Technology Sector" "$PROJECT2")
PROJECT2=$(envelope assertion add pred-obj string "year" string "2023" "$PROJECT2")
PROJECT2=$(envelope assertion add pred-obj string "role" string "Security Developer" "$PROJECT2")
PROJECT2=$(envelope assertion add pred-obj string "description" string "Authentication system that protects user privacy while maintaining security" "$PROJECT2")
PROJECT2=$(envelope assertion add pred-obj string "openSource" bool true "$PROJECT2")
PROJECT2=$(envelope assertion add pred-obj string "codeReview" string "Available with signed NDA" "$PROJECT2")

# Add projects to XID
XID_DOC=$(envelope assertion add pred-obj string "portfolio" envelope "$PROJECT1" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "portfolio" envelope "$PROJECT2" "$XID_DOC")

echo "XID with portfolio projects (showing first project):"
envelope format --type tree "$PROJECT1"

# Step 6: Adding Technical Skills and Knowledge Sources
echo -e "\n6. Adding skills and knowledge sources..."

# Create a structured knowledge source entry
KNOWLEDGE=$(envelope subject type string "Formal Education and Continuous Learning")
KNOWLEDGE=$(envelope assertion add pred-obj string "formalEducation" string "Computer Science - Research University" "$KNOWLEDGE")
KNOWLEDGE=$(envelope assertion add pred-obj string "completionYear" number 2015 "$KNOWLEDGE")
KNOWLEDGE=$(envelope assertion add pred-obj string "continuedLearning" string "Security certification program, distributed systems workshops" "$KNOWLEDGE")
KNOWLEDGE=$(envelope assertion add pred-obj string "assessment" string "Willing to discuss technical depth in relevant domains" "$KNOWLEDGE")

# Add knowledge sources to XID
XID_DOC=$(envelope assertion add pred-obj string "knowledge" envelope "$KNOWLEDGE" "$XID_DOC")

# Add technical skills with evidence of proficiency
SKILL_RUST=$(envelope subject type string "Rust Programming")
SKILL_RUST=$(envelope assertion add pred-obj string "proficiency" string "Advanced" "$SKILL_RUST")
SKILL_RUST=$(envelope assertion add pred-obj string "yearsExperience" number 4 "$SKILL_RUST")
SKILL_RUST=$(envelope assertion add pred-obj string "evidence" string "Open source contributions to security libraries" "$SKILL_RUST")

SKILL_DISTRIBUTED=$(envelope subject type string "Distributed Systems")
SKILL_DISTRIBUTED=$(envelope assertion add pred-obj string "proficiency" string "Expert" "$SKILL_DISTRIBUTED")
SKILL_DISTRIBUTED=$(envelope assertion add pred-obj string "yearsExperience" number 8 "$SKILL_DISTRIBUTED")
SKILL_DISTRIBUTED=$(envelope assertion add pred-obj string "evidence" string "Designed horizontally scalable security systems in production" "$SKILL_DISTRIBUTED")

# Add skills to XID
XID_DOC=$(envelope assertion add pred-obj string "skill" envelope "$SKILL_RUST" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "skill" envelope "$SKILL_DISTRIBUTED" "$XID_DOC")

echo "XID with knowledge sources and skills:"
envelope format --type tree "$KNOWLEDGE"

# Step 7: Creating Profile for Different Trust Contexts
echo -e "\n7. Creating profiles for different trust contexts..."

# Save the complete profile
echo "$XID_DOC" > output/bwhacker-professional-profile.envelope
echo "Saved complete profile to output/bwhacker-professional-profile.envelope"

# We'll demonstrate different levels of data minimization through creating
# separate profiles from the same base XID rather than using elision

# Create public profile with minimal information (for public consumption)
echo "Creating public profile (minimal information)..."
PUBLIC_PROFILE=$(envelope xid new --name "BWHacker" "$PUBLIC_KEYS")
PUBLIC_PROFILE=$(envelope assertion add pred-obj string "profession" string "Software Engineer" "$PUBLIC_PROFILE")
PUBLIC_PROFILE=$(envelope assertion add pred-obj string "specialization" string "Distributed Systems & Security" "$PUBLIC_PROFILE")

# Create collaboration profile with more information (for potential collaborators)
echo "Creating collaboration profile (more technical details)..."
COLLAB_PROFILE=$(envelope xid new --name "BWHacker" "$PUBLIC_KEYS")
COLLAB_PROFILE=$(envelope assertion add pred-obj string "profession" string "Software Engineer" "$COLLAB_PROFILE")
COLLAB_PROFILE=$(envelope assertion add pred-obj string "specialization" string "Distributed Systems & Security" "$COLLAB_PROFILE")
COLLAB_PROFILE=$(envelope assertion add pred-obj string "experience" number 8 "$COLLAB_PROFILE")
COLLAB_PROFILE=$(envelope assertion add pred-obj string "languages" string "Python, Rust, JavaScript" "$COLLAB_PROFILE")
COLLAB_PROFILE=$(envelope assertion add pred-obj string "skill" envelope "$SKILL_RUST" "$COLLAB_PROFILE")
COLLAB_PROFILE=$(envelope assertion add pred-obj string "skill" envelope "$SKILL_DISTRIBUTED" "$COLLAB_PROFILE")
COLLAB_PROFILE=$(envelope assertion add pred-obj string "portfolio" envelope "$PROJECT1" "$COLLAB_PROFILE")

echo "Created three different profiles with progressive trust disclosure:"
echo "1. Complete profile: All information for trusted relationships"
echo "2. Collaboration profile: Technical details for potential collaborators"
echo "3. Public profile: Minimal information for public consumption"

echo -e "\n=== BWHacker's Alternative Profile Creation Complete ==="
echo "This profile demonstrates building trust through evidence and attestations while maintaining pseudonymity."
echo "It shows an alternative approach to progressive disclosure without using elision."