#!/bin/bash
# create_profile.sh - Example script for "Building Amira's Professional Profile XID" tutorial

# This will continue even with some errors
set +e

echo "=== Building Amira's Professional Profile XID ==="

# Create output directory
mkdir -p output

# Step 1: Starting with Amira's Basic XID
echo -e "\n1. Starting with Amira's basic XID..."

# Create a new XID for Amira for this tutorial
PRIVATE_KEYS=$(envelope generate prvkeys)
echo "$PRIVATE_KEYS" > output/amira-key.private
PUBLIC_KEYS=$(envelope generate pubkeys "$PRIVATE_KEYS")
echo "$PUBLIC_KEYS" > output/amira-key.public

# Create a basic XID with her name and key
XID_DOC=$(envelope xid new --name "Amira" "$PUBLIC_KEYS")
echo "$XID_DOC" > output/amira-xid.envelope

# View the starting point
XID_ID=$(envelope xid id "$XID_DOC")
echo "Amira's XID: $XID_ID"
envelope format --type tree "$XID_DOC"

# Step 2: Adding Professional Background
echo -e "\n2. Adding professional background..."

# Add professional details to Amira's XID
XID_DOC=$(envelope assertion add pred-obj string "profession" string "Architect" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "specialization" string "Sustainable Urban Design" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "experience" number 8 "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "languages" string "English, Spanish, Arabic" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "location" string "Barcelona, Spain" "$XID_DOC")

echo "XID with professional background:"
envelope format --type tree "$XID_DOC"

# Step 3: Adding Structured Contact Information
echo -e "\n3. Adding structured contact information..."

# Create structured contact information
WORK_EMAIL=$(envelope subject type string "amira@studio-verde.example.com")
WORK_EMAIL=$(envelope assertion add pred-obj string "type" string "work" "$WORK_EMAIL")
WORK_EMAIL=$(envelope assertion add pred-obj string "primary" bool true "$WORK_EMAIL")

PERSONAL_EMAIL=$(envelope subject type string "amira.architect@example.com")
PERSONAL_EMAIL=$(envelope assertion add pred-obj string "type" string "personal" "$PERSONAL_EMAIL")
PERSONAL_EMAIL=$(envelope assertion add pred-obj string "primary" bool false "$PERSONAL_EMAIL")

PHONE=$(envelope subject type string "+34-555-123-4567")
PHONE=$(envelope assertion add pred-obj string "type" string "mobile" "$PHONE")
PHONE=$(envelope assertion add pred-obj string "hours" string "09:00-18:00 CET" "$PHONE")

WEBSITE=$(envelope subject type string "https://amira-designs.example.com")
WEBSITE=$(envelope assertion add pred-obj string "type" string "portfolio" "$WEBSITE")
WEBSITE=$(envelope assertion add pred-obj string "lastUpdated" string "2023-12-15" "$WEBSITE")

# Add contact methods to Amira's XID
XID_DOC=$(envelope assertion add pred-obj string "contact" envelope "$WORK_EMAIL" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "contact" envelope "$PERSONAL_EMAIL" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "contact" envelope "$PHONE" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "contact" envelope "$WEBSITE" "$XID_DOC")

echo "XID with structured contact information (showing first part):"
envelope format --type tree "$XID_DOC" | head -n 20
echo "... (more assertions not shown) ..."

# Step 4: Adding Key Projects in Portfolio
echo -e "\n4. Adding key projects to portfolio..."

# Create structured project entries
PROJECT1=$(envelope subject type string "Community Garden Redesign")
PROJECT1=$(envelope assertion add pred-obj string "client" string "City Council" "$PROJECT1")
PROJECT1=$(envelope assertion add pred-obj string "year" string "2023" "$PROJECT1")
PROJECT1=$(envelope assertion add pred-obj string "role" string "Lead Architect" "$PROJECT1")
PROJECT1=$(envelope assertion add pred-obj string "description" string "Transformation of abandoned lot into sustainable community garden" "$PROJECT1")
PROJECT1=$(envelope assertion add pred-obj string "awards" string "Urban Green Space Award 2023" "$PROJECT1")

PROJECT2=$(envelope subject type string "Sustainable Office Complex")
PROJECT2=$(envelope assertion add pred-obj string "client" string "GreenTech Innovations" "$PROJECT2")
PROJECT2=$(envelope assertion add pred-obj string "year" string "2022" "$PROJECT2")
PROJECT2=$(envelope assertion add pred-obj string "role" string "Design Architect" "$PROJECT2")
PROJECT2=$(envelope assertion add pred-obj string "description" string "Zero-carbon office building with integrated renewable energy" "$PROJECT2")
PROJECT2=$(envelope assertion add pred-obj string "published" bool true "$PROJECT2")

# Add projects to Amira's XID
XID_DOC=$(envelope assertion add pred-obj string "portfolio" envelope "$PROJECT1" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "portfolio" envelope "$PROJECT2" "$XID_DOC")

echo "XID with portfolio projects (showing first part):"
envelope format --type tree "$XID_DOC" | head -n 20
echo "... (more assertions not shown) ..."

# Step 5: Adding Professional Credentials with Verification
echo -e "\n5. Adding professional credentials with verification..."

# Generate keys for a certification authority
CERT_AUTHORITY_PRIVATE=$(envelope generate prvkeys)
CERT_AUTHORITY_PUBLIC=$(envelope generate pubkeys "$CERT_AUTHORITY_PRIVATE")

# Create a verified professional credential
CREDENTIAL=$(envelope subject type string "Licensed Architect")
CREDENTIAL=$(envelope assertion add pred-obj string "issuer" string "Royal Institute of Architects" "$CREDENTIAL")
CREDENTIAL=$(envelope assertion add pred-obj string "issueDate" string "2018-06-12" "$CREDENTIAL")
CREDENTIAL=$(envelope assertion add pred-obj string "licenseNumber" string "AR-2018-78342" "$CREDENTIAL")
CREDENTIAL=$(envelope assertion add pred-obj string "validUntil" string "2024-06-11" "$CREDENTIAL")

# Sign the credential with the authority's key
SIGNED_CREDENTIAL=$(envelope sign -s "$CERT_AUTHORITY_PRIVATE" "$CREDENTIAL")

# Add the verified credential to Amira's XID
XID_DOC=$(envelope assertion add pred-obj string "credential" envelope "$SIGNED_CREDENTIAL" "$XID_DOC")

echo "XID with verified credential:"
envelope format --type tree "$SIGNED_CREDENTIAL"

# Verify the credential signature
echo "Verifying credential signatures..."
if envelope verify -v "$CERT_AUTHORITY_PUBLIC" "$SIGNED_CREDENTIAL"; then
    echo "✅ Architecture license credential verified successfully"
else
    echo "❌ Credential verification failed"
fi

# Step 6: Adding Professional Skills and Education
echo -e "\n6. Adding skills and education..."

# Create a structured education entry
EDUCATION=$(envelope subject type string "Master of Architecture")
EDUCATION=$(envelope assertion add pred-obj string "institution" string "Barcelona School of Architecture" "$EDUCATION")
EDUCATION=$(envelope assertion add pred-obj string "graduationYear" number 2015 "$EDUCATION")
EDUCATION=$(envelope assertion add pred-obj string "honors" string "Summa Cum Laude" "$EDUCATION")
EDUCATION=$(envelope assertion add pred-obj string "thesis" string "Biomimicry in Urban Architecture" "$EDUCATION")

# Add education to Amira's XID
XID_DOC=$(envelope assertion add pred-obj string "education" envelope "$EDUCATION" "$XID_DOC")

# Add professional skills (simplified for script readability)
XID_DOC=$(envelope assertion add pred-obj string "skill" string "Sustainable Design" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "skill" string "Urban Planning" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "skill" string "Restoration" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "skill" string "AutoCAD" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "skill" string "Revit" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "skill" string "Green Building Standards" "$XID_DOC")

echo "XID with education and skills (showing education):"
envelope format --type tree "$EDUCATION" 

# Step 7: Creating a Professional Statement
echo -e "\n7. Adding professional statement..."

# Create a professional statement
STATEMENT=$(envelope subject type string "Professional Statement")
STATEMENT=$(envelope assertion add pred-obj string "text" string "I am a sustainable architecture specialist with 8 years of experience designing environmentally responsive buildings and urban spaces." "$STATEMENT")
STATEMENT=$(envelope assertion add pred-obj string "lastUpdated" string "$(date +%Y-%m-%d)" "$STATEMENT")

# Add the statement to Amira's XID
XID_DOC=$(envelope assertion add pred-obj string "statement" envelope "$STATEMENT" "$XID_DOC")

echo "Amira's professional statement:"
envelope format --type tree "$STATEMENT"

# Step 8: Saving and Using the Professional Profile
echo -e "\n8. Saving and extracting from the profile..."

# Save the complete profile
echo "$XID_DOC" > output/amira-professional-profile.envelope
echo "Saved Amira's professional profile to output/amira-professional-profile.envelope"

# Extract specific information for a portfolio website
echo "Extracting information for Amira's portfolio website..."

# Get professional details
NAME=$(envelope xid name "$XID_DOC" 2>/dev/null || echo "Amira")
PROFESSION=$(envelope extract assertion predicate string "profession" "$XID_DOC" | envelope extract --object 2>/dev/null || echo "Architect")
SPECIALIZATION=$(envelope extract assertion predicate string "specialization" "$XID_DOC" | envelope extract --object 2>/dev/null || echo "Sustainable Design")

echo "Portfolio Website Information:"
echo "----------------------------"
echo "Name: $NAME"
echo "Profession: $PROFESSION"
echo "Specialization: $SPECIALIZATION"
echo "Notable Project: Community Garden Redesign (Urban Green Space Award 2023)"
echo "Credential: Licensed Architect (Royal Institute of Architects)"

echo -e "\n=== Amira's Professional Profile XID Creation Complete ==="
echo "This profile demonstrates structured identity information using Gordian Envelope and XIDs."