#!/bin/bash
# key_management.sh - Example script for "Key Management with XIDs" tutorial

set -e # Exit on error

echo "=== Key Management with XIDs ==="

# Create output directory
mkdir -p output

# Step 1: Reviewing Amira's Initial XID
echo -e "\n1. Reviewing Amira's initial XID..."

# Check if amira-xid.envelope exists in the output directory
if [ ! -f "../output/amira-xid.envelope" ] && [ ! -f "output/amira-xid.envelope" ]; then
  echo "Creating initial Amira XID since it doesn't exist yet"
  INITIAL_PRIVATE_KEYS=$(envelope generate prvkeys)
  echo "$INITIAL_PRIVATE_KEYS" > output/amira-key.private
  INITIAL_PUBLIC_KEYS=$(envelope generate pubkeys "$INITIAL_PRIVATE_KEYS")
  echo "$INITIAL_PUBLIC_KEYS" > output/amira-key.public
  
  # Create a basic XID for Amira
  XID=$(envelope xid new --name "Amira" "$INITIAL_PUBLIC_KEYS")
  echo "$XID" > output/amira-xid.envelope
  cp output/amira-xid.envelope ../output/amira-xid.envelope 2>/dev/null || true
else
  if [ -f "../output/amira-xid.envelope" ]; then
    cp ../output/amira-xid.envelope output/amira-xid.envelope
  fi
  # Display Amira's existing XID
  XID=$(cat output/amira-xid.envelope)
fi

# Display the XID
echo "Amira's XID structure:"
envelope format --type tree --file output/amira-xid.envelope
XID_ID=$(envelope xid id --file output/amira-xid.envelope)
echo "Amira's XID ID: $XID_ID"

# Step 2: Adding a Device Key
echo -e "\n2. Adding a tablet device key..."

# Generate a new key for Amira's tablet
envelope generate prvkeys > output/tablet-key.private
envelope generate pubkeys --file output/tablet-key.private > output/tablet-key.public

# Add this new key to her XID with specific permissions
envelope xid key add --name "Tablet Key" --allow sign --allow encrypt --file output/tablet-key.public --in output/amira-xid.envelope > output/amira-xid-with-tablet.envelope

echo "XID with tablet key added:"
envelope format --type tree --file output/amira-xid-with-tablet.envelope

# List all keys in the XID
echo -e "\nVerifying keys in the XID:"
envelope xid key all --file output/amira-xid-with-tablet.envelope

# Step 3: Adding a High-Security Key
echo -e "\n3. Adding a high-security key..."

# Generate a high-security key
envelope generate prvkeys > output/hsm-key.private
envelope generate pubkeys --file output/hsm-key.private > output/hsm-key.public

# Add the key with full permissions
envelope xid key add --name "Hardware Security Key" --allow all --file output/hsm-key.public --in output/amira-xid-with-tablet.envelope > output/amira-xid-enhanced.envelope

echo "XID with hardware security key:"
envelope format --type tree --file output/amira-xid-enhanced.envelope

# Step 4: Creating a Secure Transaction
echo -e "\n4. Creating a secure transaction with high-security key..."

# Create a transaction message
envelope subject type string "Contract approval for collaborative project" > output/transaction.envelope
envelope assertion add pred-obj string "project" string "Community Garden Design" --in output/transaction.envelope > output/transaction.envelope
envelope assertion add pred-obj string "timestamp" string "$(date +%Y-%m-%dT%H:%M:%S)" --in output/transaction.envelope > output/transaction.envelope

# Sign with high-security key
envelope sign --signature-file output/hsm-key.private --in output/transaction.envelope > output/transaction-signed.envelope

echo "Message signed with high-security key:"
envelope format --type tree --file output/transaction-signed.envelope

# Verify the signature
if envelope verify --verification-key-file output/hsm-key.public --in output/transaction-signed.envelope; then
    echo "✅ Signature verification successful"
else
    echo "❌ Signature verification failed"
fi

# Step 5: Key Rotation After Compromise
echo -e "\n5. Handling key compromise scenario..."

# Document the key revocation
envelope subject type string "Tablet device possibly compromised" > output/revocation.envelope
envelope assertion add pred-obj string "date" string "$(date +%Y-%m-%d)" --in output/revocation.envelope > output/revocation.envelope
envelope assertion add pred-obj string "keyId" string "Tablet Key" --in output/revocation.envelope > output/revocation.envelope

# Sign the revocation notice with high-security key
envelope sign --signature-file output/hsm-key.private --in output/revocation.envelope > output/revocation-signed.envelope

echo "Revocation notice:"
envelope format --type tree --file output/revocation-signed.envelope

# Remove the tablet key from the XID
envelope xid key remove --file output/tablet-key.public --in output/amira-xid-enhanced.envelope > output/amira-xid-rotated.envelope

echo "XID after key removal:"
envelope format --type tree --file output/amira-xid-rotated.envelope

# Step 6: Verifying Identity Persistence
echo -e "\n6. Verifying identity persistence across key changes..."

# Check original identity
ORIGINAL_ID=$(envelope xid id --file output/amira-xid.envelope)

# Check current identity after key changes
CURRENT_ID=$(envelope xid id --file output/amira-xid-rotated.envelope)

# Compare
echo "Original XID: $ORIGINAL_ID"
echo "Current XID:  $CURRENT_ID"
if [ "$CURRENT_ID" = "$ORIGINAL_ID" ]; then
    echo "✅ Identity verification successful! The XID maintains stable identity despite key changes."
else
    echo "❌ Identity verification failed!"
fi

# Step 7: Setting Up Recovery Keys
echo -e "\n7. Setting up recovery mechanisms..."

# Generate recovery keys
envelope generate prvkeys > output/recovery-key.private
envelope generate pubkeys --file output/recovery-key.private > output/recovery-key.public

# Add recovery key with minimal permissions
envelope xid key add --name "Recovery Key" --allow update --allow elect --file output/recovery-key.public --in output/amira-xid-rotated.envelope > output/amira-xid-with-recovery.envelope

echo "XID with recovery key added:"
envelope format --type tree --file output/amira-xid-with-recovery.envelope

# Step 8: Simulating Recovery
echo -e "\n8. Simulating key recovery scenario..."

# Generate replacement keys after loss
envelope generate prvkeys > output/replacement-key.private
envelope generate pubkeys --file output/replacement-key.private > output/replacement-key.public

# Use recovery key to add new primary key
envelope xid key add --name "New Primary Key" --allow all --file output/replacement-key.public --in output/amira-xid-with-recovery.envelope > output/amira-xid-restored.envelope

echo "XID after recovery:"
envelope format --type tree --file output/amira-xid-restored.envelope

# Check final identity persistence
FINAL_ID=$(envelope xid id --file output/amira-xid-restored.envelope)
echo "Recovered XID: $FINAL_ID" 
if [ "$FINAL_ID" = "$ORIGINAL_ID" ]; then
    echo "✅ Recovery successful! The XID maintained stable identity throughout all key operations."
else
    echo "❌ Recovery verification failed!"
fi

echo -e "\n=== Key Management Tutorial Complete ==="