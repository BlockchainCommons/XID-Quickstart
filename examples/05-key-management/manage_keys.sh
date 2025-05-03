#!/bin/bash
# manage_keys.sh - Script for "Key Management with Pseudonymous XIDs" tutorial

# Continue even with some errors to show the complete process
set +e

echo "=== Key Management with Pseudonymous XIDs ==="

# Create output directory
mkdir -p output evidence

echo -e "\n1. Examining BWHacker's existing pseudonymous XID..."

# Generate new keys and create a fresh XID
# In a real workflow, you would use existing keys from previous tutorials
PRIVATE_KEYS=$(envelope generate prvkeys)
echo "$PRIVATE_KEYS" > output/amira-key.private
PUBLIC_KEYS=$(envelope generate pubkeys "$PRIVATE_KEYS")
echo "$PUBLIC_KEYS" > output/amira-key.public

# Create a basic pseudonymous XID as BWHacker
XID_DOC=$(envelope xid new --name "BWHacker" "$PUBLIC_KEYS")

# Add information with verifiable contexts to mimic Tutorial #1 results
XID_DOC=$(envelope assertion add pred-obj string "domain" string "Sustainable Urban Architecture" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "experienceLevel" string "8 years professional practice" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "verificationMethod" string "Work samples and designs available on request" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "projectHistory" string "10+ urban renewal projects across 3 continents" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "observableSince" string "2015" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "potentialBias" string "Particular focus on solutions for disadvantaged communities" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "methodologicalApproach" string "User-centered, participatory design processes" "$XID_DOC")

# Generate and add a tablet key to simulate Tutorial #2 completion
TABLET_PRIVATE_KEYS=$(envelope generate prvkeys)
echo "$TABLET_PRIVATE_KEYS" > output/tablet-key.private
TABLET_PUBLIC_KEYS=$(envelope generate pubkeys "$TABLET_PRIVATE_KEYS")
echo "$TABLET_PUBLIC_KEYS" > output/tablet-key.public
XID_DOC=$(envelope xid key add --name "Tablet Key" --allow sign "$TABLET_PUBLIC_KEYS" "$XID_DOC")
echo "$XID_DOC" > output/bwhacker-trust-profile.envelope

# Display the XID details
XID_ID=$(envelope xid id "$XID_DOC")
echo "BWHacker's XID identifier: $XID_ID"
echo -e "\nBWHacker's current XID structure:"
envelope format --type tree "$XID_DOC"

# Now check BWHacker's current keys
echo -e "\nCurrent keys in BWHacker's XID:"
KEYS=$(envelope xid key all "$XID_DOC")
echo "$KEYS"

echo -e "\nCreating BWHacker's key management policy..."
KEY_POLICY=$(envelope subject type string "BWHacker Key Management Policy")
KEY_POLICY=$(envelope assertion add pred-obj string "purpose" string "Manage cryptographic keys while maintaining pseudonymity" "$KEY_POLICY")
KEY_POLICY=$(envelope assertion add pred-obj string "created" string "$(date +%Y-%m-%d)" "$KEY_POLICY")
KEY_POLICY=$(envelope assertion add pred-obj string "principle" string "Different keys for different trust contexts" "$KEY_POLICY")
KEY_POLICY=$(envelope assertion add pred-obj string "principle" string "Least privilege for each key" "$KEY_POLICY")
KEY_POLICY=$(envelope assertion add pred-obj string "principle" string "Recovery procedures that don't expose identity" "$KEY_POLICY")
KEY_POLICY=$(envelope assertion add pred-obj string "rotationPolicy" string "Regular rotation for active keys, immediate rotation for suspected compromise" "$KEY_POLICY")

echo "$KEY_POLICY" > output/bwhacker-key-policy.envelope
echo "Key policy created and saved to output/bwhacker-key-policy.envelope"

echo -e "\n2. Creating a trust-based key hierarchy..."

# First, rename the primary key for clarity
echo "Renaming primary key for clarity..."
PRIMARY_KEY=$(cat output/amira-key.public)
UPDATED_XID=$(envelope xid key rename "$PRIMARY_KEY" "BWHacker Primary Identity" "$XID_DOC")
echo "$UPDATED_XID" > output/bwhacker-updated.envelope

echo "Creating project-specific key..."
# Create a project-specific key
PROJECT_KEY_PRIVATE=$(envelope generate prvkeys)
echo "$PROJECT_KEY_PRIVATE" > output/project-key.private
PROJECT_KEY_PUBLIC=$(envelope generate pubkeys "$PROJECT_KEY_PRIVATE")
echo "$PROJECT_KEY_PUBLIC" > output/project-key.public

UPDATED_XID=$(envelope xid key add --name "Urban Design Project" --allow sign --allow encrypt "$PROJECT_KEY_PUBLIC" "$UPDATED_XID")
echo "$UPDATED_XID" > output/bwhacker-updated.envelope

echo "Creating evidence commitment key..."
# Create an evidence commitment key
EVIDENCE_KEY_PRIVATE=$(envelope generate prvkeys)
echo "$EVIDENCE_KEY_PRIVATE" > output/evidence-key.private
EVIDENCE_KEY_PUBLIC=$(envelope generate pubkeys "$EVIDENCE_KEY_PRIVATE")
echo "$EVIDENCE_KEY_PUBLIC" > output/evidence-key.public

UPDATED_XID=$(envelope xid key add --name "Evidence Commitment Key" --allow sign "$EVIDENCE_KEY_PUBLIC" "$UPDATED_XID")
echo "$UPDATED_XID" > output/bwhacker-updated.envelope

echo "Creating recovery key..."
# Create a recovery key with limited permissions
RECOVERY_KEY_PRIVATE=$(envelope generate prvkeys)
echo "$RECOVERY_KEY_PRIVATE" > output/recovery-key.private
RECOVERY_KEY_PUBLIC=$(envelope generate pubkeys "$RECOVERY_KEY_PRIVATE")
echo "$RECOVERY_KEY_PUBLIC" > output/recovery-key.public

UPDATED_XID=$(envelope xid key add --name "Recovery Key" --allow update --allow elect "$RECOVERY_KEY_PUBLIC" "$UPDATED_XID")
echo "$UPDATED_XID" > output/bwhacker-updated.envelope

# Review our key hierarchy
echo -e "\nBWHacker's key hierarchy:"
envelope xid key all "$UPDATED_XID"

echo -e "\nKey details and permissions:"
for KEY in $(envelope xid key all "$UPDATED_XID"); do
    NAME=$(envelope xid key name "$KEY" "$UPDATED_XID" 2>/dev/null || echo "Unnamed key")
    PERMS=$(envelope xid key permissions "$KEY" "$UPDATED_XID")
    echo "- $NAME: $PERMS"
done

echo -e "\n3. Key rotation as a privacy enhancement..."

# Create a key rotation record with fair witnessing principles
ROTATION_RECORD=$(envelope subject type string "Key Rotation Record")
ROTATION_RECORD=$(envelope assertion add pred-obj string "date" string "$(date +%Y-%m-%d)" "$ROTATION_RECORD")
ROTATION_RECORD=$(envelope assertion add pred-obj string "keyName" string "Tablet Key" "$ROTATION_RECORD")
ROTATION_RECORD=$(envelope assertion add pred-obj string "reason" string "Suspected device tampering at public cafe" "$ROTATION_RECORD")
ROTATION_RECORD=$(envelope assertion add pred-obj string "observation" string "Device left unattended for approximately 3 minutes" "$ROTATION_RECORD")
ROTATION_RECORD=$(envelope assertion add pred-obj string "action" string "Preventative key rotation and device reset" "$ROTATION_RECORD")
ROTATION_RECORD=$(envelope assertion add pred-obj string "methodology" string "Complete replacement with new key material" "$ROTATION_RECORD")

echo "$ROTATION_RECORD" > output/key-rotation-record.envelope
echo "Created key rotation record in output/key-rotation-record.envelope"

# Generate a new tablet key
echo "Generating new tablet key..."
NEW_TABLET_KEY_PRIVATE=$(envelope generate prvkeys)
echo "$NEW_TABLET_KEY_PRIVATE" > output/new-tablet-key.private
NEW_TABLET_KEY_PUBLIC=$(envelope generate pubkeys "$NEW_TABLET_KEY_PRIVATE")
echo "$NEW_TABLET_KEY_PUBLIC" > output/new-tablet-key.public

# Remove the old tablet key and add the new one
echo "Performing key rotation..."
TABLET_KEY=$(envelope xid key find "Tablet Key" "$UPDATED_XID")
ROTATED_XID=$(envelope xid key remove "$TABLET_KEY" "$UPDATED_XID")
ROTATED_XID=$(envelope xid key add --name "Tablet Key (Rotated)" --allow sign "$NEW_TABLET_KEY_PUBLIC" "$ROTATED_XID")
echo "$ROTATED_XID" > output/bwhacker-rotated.envelope

# Check if the XID remains stable 
ORIGINAL_ID=$(envelope xid id "$XID_DOC")
ROTATED_ID=$(envelope xid id "$ROTATED_XID")
echo "Original XID: $ORIGINAL_ID"
echo "After rotation: $ROTATED_ID"

if [ "$ORIGINAL_ID" = "$ROTATED_ID" ]; then
    echo "✅ BWHacker's identity remained stable through key rotation"
else
    echo "❌ Identity changed during rotation (unexpected)"
fi

# Create a rotation notification for collaborators
echo "Creating key rotation notification..."
NOTIFICATION=$(envelope subject type string "Key Rotation Notification")
NOTIFICATION=$(envelope assertion add pred-obj string "date" string "$(date +%Y-%m-%d)" "$NOTIFICATION")
NOTIFICATION=$(envelope assertion add pred-obj string "keyChanged" string "Tablet Key" "$NOTIFICATION")
NOTIFICATION=$(envelope assertion add pred-obj string "rotationRecord" envelope "$ROTATION_RECORD" "$NOTIFICATION")
NOTIFICATION=$(envelope assertion add pred-obj string "verificationInstructions" string "Update your contacts with the new public key" "$NOTIFICATION")

# Sign with primary key to verify authenticity
PRIMARY_KEY_PRIVATE=$(cat output/amira-key.private)
SIGNED_NOTIFICATION=$(envelope sign -s "$PRIMARY_KEY_PRIVATE" "$NOTIFICATION")
echo "$SIGNED_NOTIFICATION" > output/key-rotation-notification.envelope
echo "Created signed notification in output/key-rotation-notification.envelope"

echo -e "\n4. Setting up recovery without identity exposure..."

# Create a trusted peer for social recovery
echo "Creating trusted peer for social recovery..."
PEER_KEYS_PRIVATE=$(envelope generate prvkeys)
echo "$PEER_KEYS_PRIVATE" > output/trusted-peer.private
PEER_KEYS_PUBLIC=$(envelope generate pubkeys "$PEER_KEYS_PRIVATE")
echo "$PEER_KEYS_PUBLIC" > output/trusted-peer.public

PEER_XID=$(envelope xid new --name "TrustedPeer" "$PEER_KEYS_PUBLIC")
echo "$PEER_XID" > output/trusted-peer.envelope

# Create a recovery attestation signed by the peer
echo "Creating peer-signed recovery attestation..."
RECOVERY_ATTESTATION=$(envelope subject type string "Recovery Authorization")
RECOVERY_ATTESTATION=$(envelope assertion add pred-obj string "regarding" string "$ORIGINAL_ID" "$RECOVERY_ATTESTATION")
RECOVERY_ATTESTATION=$(envelope assertion add pred-obj string "recoveryKey" digest "$RECOVERY_KEY_PUBLIC" "$RECOVERY_ATTESTATION")
RECOVERY_ATTESTATION=$(envelope assertion add pred-obj string "validFrom" string "$(date +%Y-%m-%d)" "$RECOVERY_ATTESTATION")
RECOVERY_ATTESTATION=$(envelope assertion add pred-obj string "validUntil" string "$(date -d "+6 months" +%Y-%m-%d 2>/dev/null || date -v+6m +%Y-%m-%d)" "$RECOVERY_ATTESTATION")
RECOVERY_ATTESTATION=$(envelope assertion add pred-obj string "limitations" string "One-time use for primary key recovery only" "$RECOVERY_ATTESTATION")
RECOVERY_ATTESTATION=$(envelope assertion add pred-obj string "verificationMethod" string "In-person confirmation with pre-established challenges" "$RECOVERY_ATTESTATION")
RECOVERY_ATTESTATION=$(envelope assertion add pred-obj string "observer" string "Collaborator since 2022, 3 joint projects completed" "$RECOVERY_ATTESTATION")

SIGNED_RECOVERY_ATTESTATION=$(envelope sign -s "$PEER_KEYS_PRIVATE" "$RECOVERY_ATTESTATION")
echo "$SIGNED_RECOVERY_ATTESTATION" > output/recovery-attestation.envelope

echo "Simulating primary key loss and recovery process..."

# Generate a new primary key to replace the "lost" one
NEW_PRIMARY_KEY_PRIVATE=$(envelope generate prvkeys)
echo "$NEW_PRIMARY_KEY_PRIVATE" > output/new-primary-key.private
NEW_PRIMARY_KEY_PUBLIC=$(envelope generate pubkeys "$NEW_PRIMARY_KEY_PRIVATE")
echo "$NEW_PRIMARY_KEY_PUBLIC" > output/new-primary-key.public

# Use the recovery key to prepare for recovery
RECOVERY_KEY_PRIVATE=$(cat output/recovery-key.private)
PRIMARY_KEY=$(cat output/amira-key.public)

# Create a recovery record with fair witnessing principles
RECOVERY_RECORD=$(envelope subject type string "Key Recovery Record")
RECOVERY_RECORD=$(envelope assertion add pred-obj string "date" string "$(date +%Y-%m-%d)" "$RECOVERY_RECORD")
RECOVERY_RECORD=$(envelope assertion add pred-obj string "action" string "Recovery of primary identity key" "$RECOVERY_RECORD")
RECOVERY_RECORD=$(envelope assertion add pred-obj string "methodology" string "Social recovery with peer attestation verification" "$RECOVERY_RECORD")
RECOVERY_RECORD=$(envelope assertion add pred-obj string "verificationMethod" string "Cross-referenced with existing attestations in BWHacker's trust framework" "$RECOVERY_RECORD")
RECOVERY_RECORD=$(envelope assertion add pred-obj string "peerAttestation" envelope "$SIGNED_RECOVERY_ATTESTATION" "$RECOVERY_RECORD")

# Sign the recovery record with the recovery key
SIGNED_RECOVERY_RECORD=$(envelope sign -s "$RECOVERY_KEY_PRIVATE" "$RECOVERY_RECORD")
echo "$SIGNED_RECOVERY_RECORD" > output/recovery-record.envelope

# Perform the recovery by removing old primary key and adding new one
RECOVERED_XID=$(envelope xid key remove "$PRIMARY_KEY" "$ROTATED_XID")
RECOVERED_XID=$(envelope xid key add --name "BWHacker Primary Identity (Recovered)" --allow all "$NEW_PRIMARY_KEY_PUBLIC" "$RECOVERED_XID")
echo "$RECOVERED_XID" > output/bwhacker-recovered.envelope

# Verify that the XID remained stable
RECOVERED_ID=$(envelope xid id "$RECOVERED_XID")
echo "Original XID: $ORIGINAL_ID"
echo "After recovery: $RECOVERED_ID"

if [ "$ORIGINAL_ID" = "$RECOVERED_ID" ]; then
    echo "✅ BWHacker's identity remained stable through recovery process"
else
    echo "❌ Identity changed during recovery (unexpected)"
fi

echo -e "\n5. Implementing progressive permission models..."

# Create an initial collaboration key with minimal permissions
echo "Creating initial collaboration key with minimal permissions..."
COLLAB_KEY_PRIVATE=$(envelope generate prvkeys)
echo "$COLLAB_KEY_PRIVATE" > output/collab-key.private
COLLAB_KEY_PUBLIC=$(envelope generate pubkeys "$COLLAB_KEY_PRIVATE")
echo "$COLLAB_KEY_PUBLIC" > output/collab-key.public

UPDATED_XID=$(envelope xid key add --name "New Collaboration (Initial)" --allow encrypt "$COLLAB_KEY_PUBLIC" "$RECOVERED_XID")
echo "$UPDATED_XID" > output/bwhacker-updated2.envelope

# Document the progressive permission plan
echo "Creating progressive permission plan..."
PERMISSION_PLAN=$(envelope subject type string "Progressive Permission Plan")
PERMISSION_PLAN=$(envelope assertion add pred-obj string "keyName" string "New Collaboration (Initial)" "$PERMISSION_PLAN")
PERMISSION_PLAN=$(envelope assertion add pred-obj string "initialPermissions" string "encrypt" "$PERMISSION_PLAN")
PERMISSION_PLAN=$(envelope assertion add pred-obj string "stage1Upgrade" string "After successful first deliverable: add sign permission" "$PERMISSION_PLAN")
PERMISSION_PLAN=$(envelope assertion add pred-obj string "stage2Upgrade" string "After 3 successful collaborations: add auth permission" "$PERMISSION_PLAN")
PERMISSION_PLAN=$(envelope assertion add pred-obj string "finalUpgrade" string "After 1 year of successful collaboration: full permissions" "$PERMISSION_PLAN")
PERMISSION_PLAN=$(envelope assertion add pred-obj string "rationale" string "Progressive trust development through demonstrated reliability" "$PERMISSION_PLAN")
PERMISSION_PLAN=$(envelope assertion add pred-obj string "documentation" string "Each upgrade will be documented with specific accomplishments" "$PERMISSION_PLAN")

echo "$PERMISSION_PLAN" > output/permission-plan.envelope

echo "Simulating permission upgrade after successful deliverable..."

# Create a record of a successful deliverable
DELIVERABLE=$(envelope subject type string "Collaborative Deliverable")
DELIVERABLE=$(envelope assertion add pred-obj string "project" string "Urban Park Sustainability Analysis" "$DELIVERABLE")
DELIVERABLE=$(envelope assertion add pred-obj string "date" string "$(date +%Y-%m-%d)" "$DELIVERABLE")
DELIVERABLE=$(envelope assertion add pred-obj string "outcome" string "Successfully completed initial sustainability analysis" "$DELIVERABLE")
DELIVERABLE=$(envelope assertion add pred-obj string "contribution" string "BWHacker: methodology design, data analysis; Collaborator: data collection, visualization" "$DELIVERABLE")
DELIVERABLE=$(envelope assertion add pred-obj string "evaluationMethod" string "Peer review by project stakeholders" "$DELIVERABLE")
DELIVERABLE=$(envelope assertion add pred-obj string "evaluationResult" string "Exceeds expectations - methodology highly praised" "$DELIVERABLE")

NEW_PRIMARY_KEY_PRIVATE=$(cat output/new-primary-key.private)
SIGNED_DELIVERABLE=$(envelope sign -s "$NEW_PRIMARY_KEY_PRIVATE" "$DELIVERABLE")
echo "$SIGNED_DELIVERABLE" > output/successful-deliverable.envelope

# Create an upgrade record with fair witnessing principles
UPGRADE_RECORD=$(envelope subject type string "Permission Upgrade Record")
UPGRADE_RECORD=$(envelope assertion add pred-obj string "date" string "$(date +%Y-%m-%d)" "$UPGRADE_RECORD")
UPGRADE_RECORD=$(envelope assertion add pred-obj string "keyName" string "New Collaboration (Initial)" "$UPGRADE_RECORD")
UPGRADE_RECORD=$(envelope assertion add pred-obj string "newName" string "New Collaboration (Stage 1)" "$UPGRADE_RECORD")
UPGRADE_RECORD=$(envelope assertion add pred-obj string "addedPermissions" string "sign" "$UPGRADE_RECORD")
UPGRADE_RECORD=$(envelope assertion add pred-obj string "justification" envelope "$SIGNED_DELIVERABLE" "$UPGRADE_RECORD")
UPGRADE_RECORD=$(envelope assertion add pred-obj string "methodology" string "Evaluation against pre-established success criteria" "$UPGRADE_RECORD")
UPGRADE_RECORD=$(envelope assertion add pred-obj string "limitations" string "Sign permission limited to this specific collaboration" "$UPGRADE_RECORD")

SIGNED_UPGRADE_RECORD=$(envelope sign -s "$NEW_PRIMARY_KEY_PRIVATE" "$UPGRADE_RECORD")
echo "$SIGNED_UPGRADE_RECORD" > output/permission-upgrade-record.envelope

# Find and remove the original collaboration key
COLLAB_KEY=$(envelope xid key find "New Collaboration (Initial)" "$UPDATED_XID")
PROGRESSIVE_XID=$(envelope xid key remove "$COLLAB_KEY" "$UPDATED_XID")

# Add back with upgraded permissions and new name
PROGRESSIVE_XID=$(envelope xid key add --name "New Collaboration (Stage 1)" --allow encrypt --allow sign "$COLLAB_KEY_PUBLIC" "$PROGRESSIVE_XID")
echo "$PROGRESSIVE_XID" > output/bwhacker-progressive.envelope

# Check the updated permission structure
echo -e "\nUpdated permission structure:"
for KEY in $(envelope xid key all "$PROGRESSIVE_XID"); do
    NAME=$(envelope xid key name "$KEY" "$PROGRESSIVE_XID" 2>/dev/null || echo "Unnamed key")
    PERMS=$(envelope xid key permissions "$KEY" "$PROGRESSIVE_XID")
    echo "- $NAME: $PERMS"
done

echo -e "\n6. Creating BWHacker's comprehensive key management plan..."

# Create a comprehensive key management plan
KM_PLAN=$(envelope subject type string "BWHacker's Comprehensive Key Management Plan")

# Add general principles
KM_PLAN=$(envelope assertion add pred-obj string "principle" string "Maintain pseudonymity across all key operations" "$KM_PLAN")
KM_PLAN=$(envelope assertion add pred-obj string "principle" string "Apply least privilege to all keys" "$KM_PLAN")
KM_PLAN=$(envelope assertion add pred-obj string "principle" string "Document all key changes with fair witnessing principles" "$KM_PLAN")
KM_PLAN=$(envelope assertion add pred-obj string "principle" string "Enable progressive trust through granular permissions" "$KM_PLAN")
KM_PLAN=$(envelope assertion add pred-obj string "principle" string "Maintain stable identity through all key changes" "$KM_PLAN")

# Add key inventory structure
KM_PLAN=$(envelope assertion add pred-obj string "keyCategories" string "Identity, Project-specific, Function-specific, Recovery, Collaboration" "$KM_PLAN")
KM_PLAN=$(envelope assertion add pred-obj string "storagePractices" string "Primary keys: offline secure storage; Project keys: project-specific hardware; Recovery keys: distributed with trusted peers" "$KM_PLAN")

# Add rotation and recovery policies
KM_PLAN=$(envelope assertion add pred-obj string "rotationSchedule" string "Identity keys: yearly; Project keys: project conclusion; Collaboration keys: with permission upgrades" "$KM_PLAN")
KM_PLAN=$(envelope assertion add pred-obj string "recoveryProtocol" string "Social recovery with multiple peer attestations and pre-established challenges" "$KM_PLAN")

# Add documentation requirements
KM_PLAN=$(envelope assertion add pred-obj string "documentationRequirements" string "All key operations must include: date, justification, methodology, limitations, and verification method" "$KM_PLAN")
KM_PLAN=$(envelope assertion add pred-obj string "notificationProtocol" string "All collaborators must receive signed notifications of key changes that affect them" "$KM_PLAN")

# Sign the key management plan
SIGNED_KM_PLAN=$(envelope sign -s "$NEW_PRIMARY_KEY_PRIVATE" "$KM_PLAN")
echo "$SIGNED_KM_PLAN" > output/bwhacker-key-management-plan.envelope

echo -e "\n=== BWHacker's Key Management Strategy Complete ==="
echo "This demonstration shows how to manage keys for a pseudonymous identity"
echo "while maintaining privacy and supporting progressive trust development."