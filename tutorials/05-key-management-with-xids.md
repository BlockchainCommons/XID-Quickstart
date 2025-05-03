# Key Management with Pseudonymous XIDs

This tutorial demonstrates how Amira manages cryptographic keys for her "BWHacker" pseudonymous identity. You'll learn how to create a trust-based key hierarchy, implement secure key rotation, and establish recovery procedures - all while maintaining pseudonymity and supporting progressive trust development.

**Time to complete: 30-40 minutes**

> **Related Concepts**: Before or after completing this tutorial, you may want to read about [Key Management Essentials](../concepts/key-management-essentials.md) to understand the theoretical foundations behind secure key management for XIDs.

## Prerequisites

- Completed the first four XID tutorials
- The envelope CLI tool installed
- BWHacker's XID with self-attestations and endorsements from the previous tutorials
- Basic understanding of cryptographic key concepts

## What You'll Learn

- How to manage keys without compromising pseudonymity
- How to create a trust-based key hierarchy for different contexts
- How to implement key rotation as both a security and privacy enhancement
- How to establish recovery mechanisms that preserve pseudonymous identity
- How to create progressive permission models aligned with trust relationships
- How to apply fair witnessing principles to key management decisions

## Amira's Challenge: Managing Keys for Pseudonymous Trust

After establishing her "BWHacker" identity and building trust through self-attestations and peer endorsements, Amira now faces a new challenge. She needs a comprehensive key management strategy that will:

1. Allow her to use different devices securely without compromising her pseudonymity
2. Support different trust relationships with varying levels of disclosure
3. Protect against potential compromise without losing her established identity
4. Maintain transparency in her key management without revealing her real identity
5. Enable progressive trust development with new collaborators

The way she manages her keys must align with her existing trust framework while enhancing both security and privacy.

## 1. Foundations of Pseudonymous Key Management

Let's start by examining BWHacker's current XID from the previous tutorial:

👉
```sh
mkdir -p output
XID_DOC=$(cat output/bwhacker-with-endorsements.envelope)
echo "BWHacker's XID identifier:"
envelope xid id "$XID_DOC"
```

🔍
```console
BWHacker's XID identifier:
7e1e25d7c4b9e4c92753f4476158e972be2fbbd9dffdd13b0561b5f1177826d3
```

Let's review BWHacker's current keys:

👉
```sh
echo "Current keys in BWHacker's XID:"
KEYS=$(envelope xid key all "$XID_DOC")
echo "$KEYS"
```

🔍
```console
ur:crypto-pubkeys/hdcxlkadjnghfejtmyyloeadmyfqzswdaeayfnmddpjygtmyaeaelytsqdisaeaeaeae
ur:crypto-pubkeys/hdcxaeluhhfymwfldptadtfehsbeiyoschktwzmeticyaasrrfbyatjtcmzsbnsgtszo
```

Before adding more keys, let's create a key management policy document that will guide BWHacker's key usage while preserving her pseudonymity:

👉
```sh
KEY_POLICY=$(envelope subject type string "BWHacker Key Management Policy")
KEY_POLICY=$(envelope assertion add pred-obj string "purpose" string "Manage cryptographic keys while maintaining pseudonymity" "$KEY_POLICY")
KEY_POLICY=$(envelope assertion add pred-obj string "created" string "$(date +%Y-%m-%d)" "$KEY_POLICY")
KEY_POLICY=$(envelope assertion add pred-obj string "principle" string "Different keys for different trust contexts" "$KEY_POLICY")
KEY_POLICY=$(envelope assertion add pred-obj string "principle" string "Least privilege for each key" "$KEY_POLICY")
KEY_POLICY=$(envelope assertion add pred-obj string "principle" string "Recovery procedures that don't expose identity" "$KEY_POLICY")
KEY_POLICY=$(envelope assertion add pred-obj string "rotationPolicy" string "Regular rotation for active keys, immediate rotation for suspected compromise" "$KEY_POLICY")

echo "$KEY_POLICY" > output/bwhacker-key-policy.envelope
```

This policy will help BWHacker maintain consistent key management practices aligned with her pseudonymous identity needs.

## 2. Creating a Trust-Based Key Hierarchy

Now, let's create a key hierarchy that aligns with BWHacker's trust framework. We'll define keys for different purposes and contexts:

### Primary Identity Key

First, let's clearly label the existing primary key:

👉
```sh
PRIMARY_KEY=$(cat output/amira-key.public)
UPDATED_XID=$(envelope xid key rename "$PRIMARY_KEY" "BWHacker Primary Identity" "$XID_DOC")
echo "$UPDATED_XID" > output/bwhacker-updated.envelope
```

### Project-Specific Key

Now, let's create a key specifically for the API security project BWHacker is joining:

👉
```sh
PROJECT_KEY_PRIVATE=$(envelope generate prvkeys)
echo "$PROJECT_KEY_PRIVATE" > output/project-key.private
PROJECT_KEY_PUBLIC=$(envelope generate pubkeys "$PROJECT_KEY_PRIVATE")
echo "$PROJECT_KEY_PUBLIC" > output/project-key.public

UPDATED_XID=$(envelope xid key add --name "API Security Project" --allow sign --allow encrypt "$PROJECT_KEY_PUBLIC" "$UPDATED_XID")
echo "$UPDATED_XID" > output/bwhacker-updated.envelope
```

By limiting this key to only sign and encrypt (not manage other keys), BWHacker implements least privilege principles.

### Evidence Commitment Key

For managing evidence commitments from Tutorial #3, let's create a specialized key:

👉
```sh
EVIDENCE_KEY_PRIVATE=$(envelope generate prvkeys)
echo "$EVIDENCE_KEY_PRIVATE" > output/evidence-key.private
EVIDENCE_KEY_PUBLIC=$(envelope generate pubkeys "$EVIDENCE_KEY_PRIVATE")
echo "$EVIDENCE_KEY_PUBLIC" > output/evidence-key.public

UPDATED_XID=$(envelope xid key add --name "Evidence Commitment Key" --allow sign "$EVIDENCE_KEY_PUBLIC" "$UPDATED_XID")
echo "$UPDATED_XID" > output/bwhacker-updated.envelope
```

This key will only be used for signing evidence commitments, further compartmentalizing BWHacker's cryptographic activities.

### Endorsement Signing Key

Let's create a dedicated key for signing endorsements of other people's work:

👉
```sh
ENDORSE_KEY_PRIVATE=$(envelope generate prvkeys)
echo "$ENDORSE_KEY_PRIVATE" > output/endorsement-key.private
ENDORSE_KEY_PUBLIC=$(envelope generate pubkeys "$ENDORSE_KEY_PRIVATE")
echo "$ENDORSE_KEY_PUBLIC" > output/endorsement-key.public

UPDATED_XID=$(envelope xid key add --name "Endorsement Signing Key" --allow sign "$ENDORSE_KEY_PUBLIC" "$UPDATED_XID")
echo "$UPDATED_XID" > output/bwhacker-updated.envelope
```

This dedicated key makes it clear when BWHacker is endorsing others' work.

### Recovery Key (For Emergency Use Only)

Let's create a recovery key with extremely limited permissions, to be stored securely offline:

👉
```sh
RECOVERY_KEY_PRIVATE=$(envelope generate prvkeys)
echo "$RECOVERY_KEY_PRIVATE" > output/recovery-key.private
RECOVERY_KEY_PUBLIC=$(envelope generate pubkeys "$RECOVERY_KEY_PRIVATE")
echo "$RECOVERY_KEY_PUBLIC" > output/recovery-key.public

UPDATED_XID=$(envelope xid key add --name "Recovery Key" --allow update --allow elect "$RECOVERY_KEY_PUBLIC" "$UPDATED_XID")
echo "$UPDATED_XID" > output/bwhacker-updated.envelope
```

This recovery key can only update endpoints and manage other keys, not sign or encrypt as BWHacker.

### Reviewing Our Key Hierarchy

Let's see all the keys we've added:

👉
```sh
echo "BWHacker's key hierarchy:"
envelope xid key all "$UPDATED_XID"
```

🔍
```console
ur:crypto-pubkeys/hdcxlkadjnghfejtmyyloeadmyfqzswdaeayfnmddpjygtmyaeaelytsqdisaeaeaeae
ur:crypto-pubkeys/hdcxaeluhhfymwfldptadtfehsbeiyoschktwzmeticyaasrrfbyatjtcmzsbnsgtszo
ur:crypto-pubkeys/hdcxbylyrtjohsmtaeaeaeaeaeaeaeaeaximutmudaahaeaeaeaeaeaeaeaeaeaegscecpck
ur:crypto-pubkeys/hdcxiocmvazesectrfbaidaddaadaeaeaekoiodlvskptimoeowdpfiegrfwoylkatkemh
ur:crypto-pubkeys/hdcxftghvabdvskpoybssbkbcsaodmdsiezsfdknflkidylgrpmomeptgwchcprsueae
ur:crypto-pubkeys/hdcxpkiyflvsbyidfsaeaeaeaeaecnurdyzmchinlkcpdmaxgubsdridonnyhdmomtmsba
```

Let's also check key names and permissions:

👉
```sh
echo "Key details and permissions:"
for KEY in $(envelope xid key all "$UPDATED_XID"); do
    NAME=$(envelope xid key name "$KEY" "$UPDATED_XID" 2>/dev/null || echo "Unnamed key")
    PERMS=$(envelope xid key permissions "$KEY" "$UPDATED_XID")
    echo "- $NAME: $PERMS"
  done
```

🔍
```console
- BWHacker Primary Identity: all
- Tablet Key: sign
- API Security Project: sign encrypt
- Evidence Commitment Key: sign
- Endorsement Signing Key: sign
- Recovery Key: update elect
```

This structured approach provides BWHacker with the right keys for each purpose while minimizing risk through appropriate permission boundaries.

## 3. Key Rotation as a Privacy Enhancement

Key rotation is essential for both security and privacy. Let's demonstrate how BWHacker can rotate a key while maintaining her pseudonymous identity.

First, let's document the reason for rotation following fair witnessing principles:

👉
```sh
ROTATION_RECORD=$(envelope subject type string "Key Rotation Record")
ROTATION_RECORD=$(envelope assertion add pred-obj string "date" string "$(date +%Y-%m-%d)" "$ROTATION_RECORD")
ROTATION_RECORD=$(envelope assertion add pred-obj string "keyName" string "Tablet Key" "$ROTATION_RECORD")
ROTATION_RECORD=$(envelope assertion add pred-obj string "reason" string "Suspected device tampering at public cafe" "$ROTATION_RECORD")
ROTATION_RECORD=$(envelope assertion add pred-obj string "observation" string "Device left unattended for approximately 3 minutes" "$ROTATION_RECORD")
ROTATION_RECORD=$(envelope assertion add pred-obj string "action" string "Preventative key rotation and device reset" "$ROTATION_RECORD")
ROTATION_RECORD=$(envelope assertion add pred-obj string "methodology" string "Complete replacement with new key material" "$ROTATION_RECORD")

echo "$ROTATION_RECORD" > output/key-rotation-record.envelope
```

Now let's generate a new tablet key:

👉
```sh
NEW_TABLET_KEY_PRIVATE=$(envelope generate prvkeys)
echo "$NEW_TABLET_KEY_PRIVATE" > output/new-tablet-key.private
NEW_TABLET_KEY_PUBLIC=$(envelope generate pubkeys "$NEW_TABLET_KEY_PRIVATE")
echo "$NEW_TABLET_KEY_PUBLIC" > output/new-tablet-key.public
```

Remove the old tablet key and add the new one:

👉
```sh
TABLET_KEY=$(envelope xid key find "Tablet Key" "$UPDATED_XID")
ROTATED_XID=$(envelope xid key remove "$TABLET_KEY" "$UPDATED_XID")
ROTATED_XID=$(envelope xid key add --name "Tablet Key (Rotated)" --allow sign "$NEW_TABLET_KEY_PUBLIC" "$ROTATED_XID")
echo "$ROTATED_XID" > output/bwhacker-rotated.envelope
```

Let's verify that BWHacker's identity remains stable despite this key change:

👉
```sh
ORIGINAL_ID=$(envelope xid id "$XID_DOC")
ROTATED_ID=$(envelope xid id "$ROTATED_XID")
echo "Original XID: $ORIGINAL_ID"
echo "After rotation: $ROTATED_ID"
```

🔍
```console
Original XID: 7e1e25d7c4b9e4c92753f4476158e972be2fbbd9dffdd13b0561b5f1177826d3
After rotation: 7e1e25d7c4b9e4c92753f4476158e972be2fbbd9dffdd13b0561b5f1177826d3
```

👉
```sh
if [ "$ORIGINAL_ID" = "$ROTATED_ID" ]; then
    echo "✅ BWHacker's identity remained stable through key rotation"
  else
    echo "❌ Identity changed during rotation (unexpected)"
  fi
```

🔍
```console
✅ BWHacker's identity remained stable through key rotation
```

To inform collaborators about the key rotation in a transparent way:

👉
```sh
NOTIFICATION=$(envelope subject type string "Key Rotation Notification")
NOTIFICATION=$(envelope assertion add pred-obj string "date" string "$(date +%Y-%m-%d)" "$NOTIFICATION")
NOTIFICATION=$(envelope assertion add pred-obj string "keyChanged" string "Tablet Key" "$NOTIFICATION")
NOTIFICATION=$(envelope assertion add pred-obj string "rotationRecord" envelope "$ROTATION_RECORD" "$NOTIFICATION")
NOTIFICATION=$(envelope assertion add pred-obj string "verificationInstructions" string "Update your contacts with the new public key" "$NOTIFICATION")

# Sign with primary key to verify authenticity
PRIMARY_KEY_PRIVATE=$(cat output/amira-key.private)
SIGNED_NOTIFICATION=$(envelope sign -s "$PRIMARY_KEY_PRIVATE" "$NOTIFICATION")
echo "$SIGNED_NOTIFICATION" > output/key-rotation-notification.envelope
```

This notification could be shared with collaborators so they can update their verification procedures, while the transparent explanation builds trust through adherence to fair witnessing principles.

## 4. Recovery Without Identity Exposure

Let's prepare for a worst-case scenario: what if BWHacker loses access to her primary key? We need a recovery process that doesn't compromise her pseudonymity.

First, let's establish a social recovery approach by creating a trusted peer XID:

👉
```sh
PEER_KEYS_PRIVATE=$(envelope generate prvkeys)
echo "$PEER_KEYS_PRIVATE" > output/trusted-peer.private
PEER_KEYS_PUBLIC=$(envelope generate pubkeys "$PEER_KEYS_PRIVATE")
echo "$PEER_KEYS_PUBLIC" > output/trusted-peer.public

PEER_XID=$(envelope xid new --name "TrustedPeer" "$PEER_KEYS_PUBLIC")
echo "$PEER_XID" > output/trusted-peer.envelope
```

Now, let's create a recovery attestation signed by this peer:

👉
```sh
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
```

Now, let's simulate a recovery where BWHacker has lost her primary key but still has her recovery key:

👉
```sh
echo "Simulating primary key loss and recovery process..."

# Generate a new primary key to replace the lost one
NEW_PRIMARY_KEY_PRIVATE=$(envelope generate prvkeys)
echo "$NEW_PRIMARY_KEY_PRIVATE" > output/new-primary-key.private
NEW_PRIMARY_KEY_PUBLIC=$(envelope generate pubkeys "$NEW_PRIMARY_KEY_PRIVATE")
echo "$NEW_PRIMARY_KEY_PUBLIC" > output/new-primary-key.public

# Use the recovery key to add this new primary key
RECOVERY_KEY_PRIVATE=$(cat output/recovery-key.private)
PRIMARY_KEY=$(cat output/amira-key.public)

# Create a recovery record with fair witnessing principles
RECOVERY_RECORD=$(envelope subject type string "Key Recovery Record")
RECOVERY_RECORD=$(envelope assertion add pred-obj string "date" string "$(date +%Y-%m-%d)" "$RECOVERY_RECORD")
RECOVERY_RECORD=$(envelope assertion add pred-obj string "action" string "Recovery of primary identity key" "$RECOVERY_RECORD")
RECOVERY_RECORD=$(envelope assertion add pred-obj string "methodology" string "Social recovery with peer attestation verification" "$RECOVERY_RECORD")
RECOVERY_RECORD=$(envelope assertion add pred-obj string "verificationMethod" string "Cross-referenced with existing attestations in BWHacker's trust framework" "$RECOVERY_RECORD")
RECOVERY_RECORD=$(envelope assertion add pred-obj string "peerAttestation" envelope "$SIGNED_RECOVERY_ATTESTATION" "$RECOVERY_RECORD")

# Sign the recovery record
SIGNED_RECOVERY_RECORD=$(envelope sign -s "$RECOVERY_KEY_PRIVATE" "$RECOVERY_RECORD")
echo "$SIGNED_RECOVERY_RECORD" > output/recovery-record.envelope

# Now remove old primary key and add new one
RECOVERED_XID=$(envelope xid key remove "$PRIMARY_KEY" "$ROTATED_XID")
RECOVERED_XID=$(envelope xid key add --name "BWHacker Primary Identity (Recovered)" --allow all "$NEW_PRIMARY_KEY_PUBLIC" "$RECOVERED_XID")
echo "$RECOVERED_XID" > output/bwhacker-recovered.envelope
```

Verify that the XID remained stable through this recovery process:

👉
```sh
RECOVERED_ID=$(envelope xid id "$RECOVERED_XID")
echo "Original XID: $ORIGINAL_ID"
echo "After recovery: $RECOVERED_ID"
```

🔍
```console
Original XID: 7e1e25d7c4b9e4c92753f4476158e972be2fbbd9dffdd13b0561b5f1177826d3
After recovery: 7e1e25d7c4b9e4c92753f4476158e972be2fbbd9dffdd13b0561b5f1177826d3
```

👉
```sh
if [ "$ORIGINAL_ID" = "$RECOVERED_ID" ]; then
    echo "✅ BWHacker's identity remained stable through recovery process"
  else
    echo "❌ Identity changed during recovery (unexpected)"
  fi
```

🔍
```console
✅ BWHacker's identity remained stable through recovery process
```

This recovery mechanism maintains BWHacker's pseudonymous identity while providing a secure way to recover from key loss.

## 5. Progressive Permission Models

As trust relationships evolve, key permissions may need to change. Let's demonstrate how BWHacker can implement a progressive permission model for a new collaborator relationship:

First, let's create an initial collaboration key with minimal permissions:

👉
```sh
COLLAB_KEY_PRIVATE=$(envelope generate prvkeys)
echo "$COLLAB_KEY_PRIVATE" > output/collab-key.private
COLLAB_KEY_PUBLIC=$(envelope generate pubkeys "$COLLAB_KEY_PRIVATE")
echo "$COLLAB_KEY_PUBLIC" > output/collab-key.public

UPDATED_XID=$(envelope xid key add --name "New Collaboration (Initial)" --allow encrypt "$COLLAB_KEY_PUBLIC" "$RECOVERED_XID")
echo "$UPDATED_XID" > output/bwhacker-updated2.envelope
```

This key initially only allows encryption, which means BWHacker can receive encrypted messages but not sign as BWHacker in this collaboration.

Let's document the progressive permission plan:

👉
```sh
PERMISSION_PLAN=$(envelope subject type string "Progressive Permission Plan")
PERMISSION_PLAN=$(envelope assertion add pred-obj string "keyName" string "New Collaboration (Initial)" "$PERMISSION_PLAN")
PERMISSION_PLAN=$(envelope assertion add pred-obj string "initialPermissions" string "encrypt" "$PERMISSION_PLAN")
PERMISSION_PLAN=$(envelope assertion add pred-obj string "stage1Upgrade" string "After successful first deliverable: add sign permission" "$PERMISSION_PLAN")
PERMISSION_PLAN=$(envelope assertion add pred-obj string "stage2Upgrade" string "After 3 successful collaborations: add auth permission" "$PERMISSION_PLAN")
PERMISSION_PLAN=$(envelope assertion add pred-obj string "finalUpgrade" string "After 1 year of successful collaboration: full permissions" "$PERMISSION_PLAN")
PERMISSION_PLAN=$(envelope assertion add pred-obj string "rationale" string "Progressive trust development through demonstrated reliability" "$PERMISSION_PLAN")
PERMISSION_PLAN=$(envelope assertion add pred-obj string "documentation" string "Each upgrade will be documented with specific accomplishments" "$PERMISSION_PLAN")

echo "$PERMISSION_PLAN" > output/permission-plan.envelope
```

Now, let's simulate the first permission upgrade after a successful deliverable:

👉
```sh
echo "Simulating permission upgrade after successful deliverable..."

# Create a record of the successful deliverable
DELIVERABLE=$(envelope subject type string "Collaborative Deliverable")
DELIVERABLE=$(envelope assertion add pred-obj string "project" string "API Security Assessment" "$DELIVERABLE")
DELIVERABLE=$(envelope assertion add pred-obj string "date" string "$(date +%Y-%m-%d)" "$DELIVERABLE")
DELIVERABLE=$(envelope assertion add pred-obj string "outcome" string "Successfully completed initial security analysis" "$DELIVERABLE")
DELIVERABLE=$(envelope assertion add pred-obj string "contribution" string "BWHacker: security system design, vulnerability analysis; Collaborator: testing, documentation" "$DELIVERABLE")
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

# Find the collaboration key
COLLAB_KEY=$(envelope xid key find "New Collaboration (Initial)" "$UPDATED_XID")

# Remove the original key
PROGRESSIVE_XID=$(envelope xid key remove "$COLLAB_KEY" "$UPDATED_XID")

# Add back with upgraded permissions and new name
PROGRESSIVE_XID=$(envelope xid key add --name "New Collaboration (Stage 1)" --allow encrypt --allow sign "$COLLAB_KEY_PUBLIC" "$PROGRESSIVE_XID")
echo "$PROGRESSIVE_XID" > output/bwhacker-progressive.envelope
```

Now let's verify the new permission structure:

👉
```sh
echo "Updated permission structure:"
for KEY in $(envelope xid key all "$PROGRESSIVE_XID"); do
    NAME=$(envelope xid key name "$KEY" "$PROGRESSIVE_XID" 2>/dev/null || echo "Unnamed key")
    PERMS=$(envelope xid key permissions "$KEY" "$PROGRESSIVE_XID")
    echo "- $NAME: $PERMS"
  done
```

🔍
```console
- BWHacker Primary Identity (Recovered): all
- Tablet Key (Rotated): sign
- API Security Project: sign encrypt
- Evidence Commitment Key: sign
- Endorsement Signing Key: sign
- Recovery Key: update elect
- New Collaboration (Stage 1): sign encrypt
```

This progressive approach to permissions:
1. Aligns key privileges with demonstrated trust
2. Documents the basis for permission changes
3. Maintains fair witnessing principles with transparent evaluation
4. Preserves BWHacker's pseudonymity throughout the process

## 6. Maintaining Endorsements Through Key Changes

A crucial aspect of key management is ensuring that previously received endorsements remain valid even when keys change. Let's update one of the endorsements BWHacker received to work with her new key:

👉
```sh
# Get an endorsement from the previous tutorial
PM_ENDORSEMENT=$(cat output/pm-endorsement.envelope)

# Verify that this endorsement is still valid with our new XID state
if envelope verify -v "$(cat output/greenpm-key.public)" "$PM_ENDORSEMENT"; then
  echo "✅ PM endorsement signature still valid"
else
  echo "❌ Invalid endorsement signature"
fi

# Add context about key rotation to the endorsement acceptance
ENDORSEMENT_UPDATE=$(envelope subject type string "Endorsement Validity Update")
ENDORSEMENT_UPDATE=$(envelope assertion add pred-obj string "endorsementReference" digest "$PM_ENDORSEMENT" "$ENDORSEMENT_UPDATE")
ENDORSEMENT_UPDATE=$(envelope assertion add pred-obj string "keyRotationReference" digest "$SIGNED_RECOVERY_RECORD" "$ENDORSEMENT_UPDATE")
ENDORSEMENT_UPDATE=$(envelope assertion add pred-obj string "validityStatement" string "This endorsement remains valid through key rotation, as BWHacker's identity is preserved" "$ENDORSEMENT_UPDATE")
ENDORSEMENT_UPDATE=$(envelope assertion add pred-obj string "updateDate" string "$(date +%Y-%m-%d)" "$ENDORSEMENT_UPDATE")

# Sign with new primary key
SIGNED_UPDATE=$(envelope sign -s "$NEW_PRIMARY_KEY_PRIVATE" "$ENDORSEMENT_UPDATE")

# Add this update to the key-rotated XID
PROGRESSIVE_XID=$(envelope assertion add pred-obj string "endorsementUpdate" envelope "$SIGNED_UPDATE" "$PROGRESSIVE_XID")
echo "$PROGRESSIVE_XID" > output/bwhacker-endorsement-preserved.envelope

echo "✅ Endorsement validity preserved through key rotation"
```

This ensures that BWHacker's professional reputation and trust network remains intact despite key changes.

## 7. BWHacker's Complete Key Management Plan

Let's put all these elements together in a comprehensive key management plan:

👉
```sh
KM_PLAN=$(envelope subject type string "BWHacker's Comprehensive Key Management Plan")

# Add general principles
KM_PLAN=$(envelope assertion add pred-obj string "principle" string "Maintain pseudonymity across all key operations" "$KM_PLAN")
KM_PLAN=$(envelope assertion add pred-obj string "principle" string "Apply least privilege to all keys" "$KM_PLAN")
KM_PLAN=$(envelope assertion add pred-obj string "principle" string "Document all key changes with fair witnessing principles" "$KM_PLAN")
KM_PLAN=$(envelope assertion add pred-obj string "principle" string "Enable progressive trust through granular permissions" "$KM_PLAN")
KM_PLAN=$(envelope assertion add pred-obj string "principle" string "Maintain stable identity through all key changes" "$KM_PLAN")
KM_PLAN=$(envelope assertion add pred-obj string "principle" string "Preserve endorsement validity through key rotations" "$KM_PLAN")

# Add key inventory structure
KM_PLAN=$(envelope assertion add pred-obj string "keyCategories" string "Identity, Project-specific, Function-specific, Recovery, Collaboration, Endorsement" "$KM_PLAN")
KM_PLAN=$(envelope assertion add pred-obj string "storagePractices" string "Primary keys: offline secure storage; Project keys: project-specific hardware; Recovery keys: distributed with trusted peers" "$KM_PLAN")

# Add rotation and recovery policies
KM_PLAN=$(envelope assertion add pred-obj string "rotationSchedule" string "Identity keys: yearly; Project keys: project conclusion; Collaboration keys: with permission upgrades" "$KM_PLAN")
KM_PLAN=$(envelope assertion add pred-obj string "recoveryProtocol" string "Social recovery with multiple peer attestations and pre-established challenges" "$KM_PLAN")

# Add documentation requirements
KM_PLAN=$(envelope assertion add pred-obj string "documentationRequirements" string "All key operations must include: date, justification, methodology, limitations, and verification method" "$KM_PLAN")
KM_PLAN=$(envelope assertion add pred-obj string "notificationProtocol" string "All collaborators must receive signed notifications of key changes that affect them" "$KM_PLAN")
KM_PLAN=$(envelope assertion add pred-obj string "endorsementPolicy" string "All endorsements must be preserved through key changes with signed validity updates" "$KM_PLAN")

# Sign the key management plan
SIGNED_KM_PLAN=$(envelope sign -s "$NEW_PRIMARY_KEY_PRIVATE" "$KM_PLAN")
echo "$SIGNED_KM_PLAN" > output/bwhacker-key-management-plan.envelope
```

## Key Concepts

- **Pseudonymous Key Management**: Managing keys to support pseudonymous identity without compromising privacy
- **Trust-Based Key Hierarchy**: Structuring keys based on their role in trust relationships
- **Key Rotation for Privacy**: Using key rotation as both a security and privacy enhancement
- **Social Recovery**: Establishing recovery methods that don't compromise pseudonymity
- **Progressive Permissions**: Aligning key permissions with trust development
- **Fair Witnessing in Key Management**: Applying transparency principles to key operations
- **Endorsement Preservation**: Maintaining the validity of peer endorsements through key changes

## Permission Types

When adding keys, you can specify different permission levels:

- **all**: Allow all operations
- **auth**: Authenticate as the subject
- **sign**: Sign communications as the subject
- **encrypt**: Encrypt messages from the subject
- **elide**: Perform data minimization through elision on the subject's data
- **update**: Update service endpoints
- **elect**: Add or remove other keys

## Best Practices for Pseudonymous Key Management

1. **Never Link Keys to Real Identity**: Keep all key management separate from your real identity
2. **Context Separation**: Use different keys for different contexts and trust relationships
3. **Document Without Identifying**: Create thorough documentation that maintains pseudonymity
4. **Progressive Trust Development**: Start with minimal permissions and expand based on demonstrated trust
5. **Transparent Key Changes**: Document key changes with fair witnessing principles
6. **Distributed Recovery**: Create recovery systems that don't rely on a single point of failure
7. **Regular Rotation**: Rotate keys on a regular schedule and immediately if compromise is suspected
8. **Preserve Endorsements**: Ensure peer endorsements remain valid through key changes

## Next Steps

In the next tutorial, we'll see how BWHacker leverages her key management strategy while evolving her identity over time, maintaining trust relationships even as her cryptographic foundations change.

## Exercises

1. Create a key hierarchy for a specific pseudonymous use case with at least three different trust contexts
2. Implement a key rotation with proper documentation following fair witnessing principles
3. Design a social recovery mechanism with multiple pseudonymous identities
4. Create a progressive permission plan for a new collaborative relationship
5. Document a comprehensive key management plan for a pseudonymous identity
6. Implement a system for preserving endorsements through key changes