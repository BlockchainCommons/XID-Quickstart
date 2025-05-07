#!/bin/bash
# create_basic_xid.sh - Example script for "Creating Your First XID" tutorial

set -e # Exit on error

echo "=== BWHacker's Pseudonymous Identity Journey ==="

# Step 1: Creating SSH Keys and XID Foundation
echo -e "\n1. Creating a secure foundation with SSH and XID keys..."

# Generate an SSH key for Git authentication and signing
SSH_KEY_FILE="./bwhacker-ssh-key"
SSH_PUB_KEY_FILE="${SSH_KEY_FILE}.pub"

if [ ! -f "$SSH_KEY_FILE" ]; then
    ssh-keygen -t ed25519 -f "$SSH_KEY_FILE" -N "" -C "BWHacker <bwhacker@example.com>"
    echo "SSH key created for Git operations and commit signing"
else
    echo "Using existing SSH key: $SSH_KEY_FILE"
fi

# Read the SSH public key content
SSH_PUB_KEY=$(cat "$SSH_PUB_KEY_FILE")
SSH_KEY_FINGERPRINT=$(ssh-keygen -l -E sha256 -f "$SSH_PUB_KEY_FILE" | awk '{print $2}')
echo "SSH public key fingerprint: $SSH_KEY_FINGERPRINT"

# Generate private key for the XID
envelope generate prvkeys > bwhacker-key.private
echo "Private key generated - keep this secret and secure!"

# Derive the corresponding public key
PRIVATE_KEYS=$(cat bwhacker-key.private)
PUBLIC_KEYS=$(envelope generate pubkeys "$PRIVATE_KEYS")
echo "$PUBLIC_KEYS" > bwhacker-key.public

# View the public key
echo "Public key created (safe to share):"
cat bwhacker-key.public | head -n 1

# Step 2: Creating a Minimal Pseudonymous XID
echo -e "\n2. Creating a minimal pseudonymous XID..."

# Create an XID with a pseudonym and public key
envelope xid new --name "BWHacker" "$PUBLIC_KEYS" > bwhacker-xid.envelope

# View the XID document structure
echo "Initial pseudonymous XID document:"
XID_DOC=$(cat bwhacker-xid.envelope)
envelope format --type tree "$XID_DOC"

# Step 3: Understanding the XID Identifier
echo -e "\n3. Understanding the stable XID identifier..."

# Extract the unique XID identifier
XID_ID=$(envelope xid id "$XID_DOC")
echo "XID identifier: $XID_ID"
echo "This identifier will remain stable even when keys change."
echo "It can be referenced without revealing personal identity."

# Step 4: Adding GitHub Identity with SSH Key Verification
echo -e "\n4. Adding GitHub identity with SSH key verification..."

# Add GitHub identity
XID_DOC=$(envelope assertion add pred-obj string "gitHubUsername" string "BWHacker" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "gitHubProfileURL" string "https://github.com/BWHacker" "$XID_DOC")

# Add SSH key for Git commit verification
XID_DOC=$(envelope assertion add pred-obj string "sshKey" string "$SSH_PUB_KEY" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "sshKeyFingerprint" string "$SSH_KEY_FINGERPRINT" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "sshKeyVerificationURL" string "https://api.github.com/users/BWHacker/ssh_signing_keys" "$XID_DOC")

# Add basic professional information
XID_DOC=$(envelope assertion add pred-obj string "domain" string "Distributed Systems & Security" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "experienceLevel" string "8 years professional practice" "$XID_DOC")

# Save updated XID
echo "$XID_DOC" > bwhacker-xid.envelope

# View the enhanced XID
echo "Enhanced XID with GitHub identity and SSH key observation:"
envelope format --type tree "$XID_DOC"

# Step 5: Organizing XID Files
echo -e "\n5. Organizing XID information..."

# Create an output directory to store XID information
mkdir -p output

# Copy the XID file to the organized location
cp bwhacker-xid.envelope output/bwhacker-xid.envelope
cp "$SSH_KEY_FILE" output/
cp "$SSH_PUB_KEY_FILE" output/

# Verify the files were successfully copied
echo "XID and SSH key documents organized in project directory:"
ls -la output/

# Step 6: Creating and Signing a Basic Attestation
echo -e "\n6. Creating and signing a basic attestation..."

# Create a simple skill attestation
ATTESTATION=$(envelope subject type string "Skill Attestation")
ATTESTATION=$(envelope assertion add pred-obj string "skill" string "Rust Programming" "$ATTESTATION")
ATTESTATION=$(envelope assertion add pred-obj string "experienceYears" string "3" "$ATTESTATION")
ATTESTATION=$(envelope assertion add pred-obj string "projectCount" string "5" "$ATTESTATION")

# Save the attestation
echo "$ATTESTATION" > output/bwhacker-skill-attestation.envelope

# Wrap the attestation before signing
WRAPPED_ATTESTATION=$(envelope subject type wrapped "$ATTESTATION")

# Sign the wrapped attestation with private key
SIGNED_ATTESTATION=$(envelope sign -s "$PRIVATE_KEYS" "$WRAPPED_ATTESTATION")

# Save the signed attestation
echo "$SIGNED_ATTESTATION" > output/bwhacker-skill-attestation-signed.envelope

# View the signed attestation
echo "Signed skill attestation:"
envelope format --type tree "$SIGNED_ATTESTATION"

# Verify the signature is valid
if envelope verify -v "$PUBLIC_KEYS" "$SIGNED_ATTESTATION"; then
    echo "✅ Signature verified. The attestation is authentically from the XID holder."
else
    echo "❌ Signature verification failed."
fi

# Step 7: Configuring Git for SSH Key Signing
echo -e "\n7. Git configuration for SSH key signing..."
echo "To configure Git to use the SSH key for signing commits:"
echo "git config --local user.name \"BWHacker\""
echo "git config --local user.email \"bwhacker@example.com\""
echo "git config --local user.signingkey \"$SSH_KEY_FILE\""
echo "git config --local gpg.format ssh"
echo "git config --local commit.gpgsign true"

echo -e "\n=== BWHacker's Pseudonymous Identity Journey Complete ==="
echo "This example demonstrates how XIDs enable pseudonymous contributions"
echo "with GitHub-verifiable identity through SSH key connections,"
echo "without revealing personal identity."