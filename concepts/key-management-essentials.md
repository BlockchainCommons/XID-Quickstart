# Key Management Essentials

## Expected Learning Outcomes
By the end of this document, you will:
- Understand the importance of proper key management in XIDs
- Know how to create and manage a trust-based key hierarchy
- Learn key rotation procedures and best practices
- Understand recovery strategies that preserve XID stability
- See how progressive permission models work in practice

## The Foundation of XID Security

Cryptographic keys are the foundation of XID security and functionality. Proper key management is critical because:

1. Keys control who can use and modify your XID
2. Key compromise could lead to identity impersonation
3. Key loss without recovery options means losing access to your identity
4. Keys enable verification, signing, and encryption capabilities

## Creating a Trust-Based Key Hierarchy

Rather than using a single key for everything, a trust-based key hierarchy uses different keys for different purposes and contexts:

**Primary Identity Key**:
- Core key that controls the XID
- Highest security level with maximum protection
- Used rarely and stored very securely
- Example:
  👉 ```sh
  PRIMARY_KEY=$(cat output/amira-key.public)
  XID_DOC=$(envelope xid new --name "BWHacker" "$PRIMARY_KEY")
  ```

**Device Keys**:
- Separate keys for different devices (laptop, tablet, phone)
- Limited permissions specific to device use
- More convenient day-to-day access
- Example:
  👉 ```sh
  TABLET_KEY_PUBLIC=$(envelope generate pubkeys "$TABLET_KEY_PRIVATE")
  XID_DOC=$(envelope xid key add --name "Tablet Key" --allow sign "$TABLET_KEY_PUBLIC" "$XID_DOC")
  ```

**Project-Specific Keys**:
- Dedicated keys for specific projects or contexts
- Isolated from other contexts for security
- Example:
  👉 ```sh
  XID_DOC=$(envelope xid key add --name "API Security Project" --allow sign --allow encrypt "$PROJECT_KEY_PUBLIC" "$XID_DOC")
  ```

**Function-Specific Keys**:
- Keys with single purposes (signing, encryption, etc.)
- Following the principle of least privilege
- Example:
  👉 ```sh
  XID_DOC=$(envelope xid key add --name "Evidence Commitment Key" --allow sign "$EVIDENCE_KEY_PUBLIC" "$XID_DOC")
  ```

**Recovery Keys**:
- Special keys with update/elect permissions only
- Stored securely offline or with trusted individuals
- Example:
  👉 ```sh
  XID_DOC=$(envelope xid key add --name "Recovery Key" --allow update --allow elect "$RECOVERY_KEY_PUBLIC" "$XID_DOC")
  ```

This hierarchical approach combines security with usability by using the right key for each context.

## Key Rotation: Procedures and Best Practices

Key rotation is the process of replacing existing keys with new ones. It's an essential practice for:
- Mitigating potential compromise
- Limiting exposure from lost/stolen devices
- Adapting to organizational changes
- Implementing regular security hygiene

**The Rotation Process**:

1. **Document the Reason**: Record why rotation is happening
   👉 ```sh
   ROTATION_RECORD=$(envelope subject type string "Key Rotation Record")
   ROTATION_RECORD=$(envelope assertion add pred-obj string "reason" string "Suspected device tampering at public cafe" "$ROTATION_RECORD")
   ```

2. **Generate New Key**: Create fresh key material
   👉 ```sh
   NEW_TABLET_KEY_PRIVATE=$(envelope generate prvkeys)
   NEW_TABLET_KEY_PUBLIC=$(envelope generate pubkeys "$NEW_TABLET_KEY_PRIVATE")
   ```

3. **Remove Old Key**: Take out the key being rotated
   👉 ```sh
   TABLET_KEY=$(envelope xid key find "Tablet Key" "$XID_DOC")
   ROTATED_XID=$(envelope xid key remove "$TABLET_KEY" "$XID_DOC")
   ```

4. **Add New Key**: Add the replacement with appropriate permissions
   👉 ```sh
   ROTATED_XID=$(envelope xid key add --name "Tablet Key (Rotated)" --allow sign "$NEW_TABLET_KEY_PUBLIC" "$ROTATED_XID")
   ```

5. **Notify Collaborators**: Inform others who need to verify your signatures
   👉 ```sh
   NOTIFICATION=$(envelope subject type string "Key Rotation Notification")
   NOTIFICATION=$(envelope assertion add pred-obj string "keyChanged" string "Tablet Key" "$NOTIFICATION")
   SIGNED_NOTIFICATION=$(envelope sign -s "$PRIMARY_KEY_PRIVATE" "$NOTIFICATION")
   ```

Key rotation is especially powerful with XIDs because **the XID identifier remains stable** even as keys change. This allows you to maintain your digital identity across key changes.

## Recovery Strategies That Preserve Identity

Key loss shouldn't mean identity loss. XID enables recovery approaches that preserve your stable identifier:

**Social Recovery**:
- Trusted peers hold recovery authorization
- Multiple perspectives reduce vulnerability
- Example:
  👉 ```sh
  RECOVERY_ATTESTATION=$(envelope subject type string "Recovery Authorization")
  RECOVERY_ATTESTATION=$(envelope assertion add pred-obj string "regarding" string "$XID" "$RECOVERY_ATTESTATION")
  RECOVERY_ATTESTATION=$(envelope assertion add pred-obj string "recoveryKey" digest "$RECOVERY_KEY_PUBLIC" "$RECOVERY_ATTESTATION")
  SIGNED_RECOVERY_ATTESTATION=$(envelope sign -s "$PEER_KEYS_PRIVATE" "$RECOVERY_ATTESTATION")
  ```

**Recovery Key Usage**:
- Special keys with limited "update" and "elect" permissions only
- Different authorization pathway than normal use
- Example:
  👉 ```sh
  RECOVERED_XID=$(envelope xid key remove "$PRIMARY_KEY" "$XID_DOC")
  RECOVERED_XID=$(envelope xid key add --name "Primary Identity (Recovered)" --allow all "$NEW_PRIMARY_KEY_PUBLIC" "$RECOVERED_XID")
  ```

**Recovery Documentation**:
- Clear records of the recovery process
- Transparent explanation of what happened
- Example:
  👉 ```sh
  RECOVERY_RECORD=$(envelope subject type string "Key Recovery Record")
  RECOVERY_RECORD=$(envelope assertion add pred-obj string "action" string "Recovery of primary identity key" "$RECOVERY_RECORD")
  RECOVERY_RECORD=$(envelope assertion add pred-obj string "methodology" string "Social recovery with peer attestation verification" "$RECOVERY_RECORD")
  ```

These recovery mechanisms maintain the XID's stable identifier throughout the recovery process, preserving relationships and trust.

## Progressive Permission Models

Progressive permission models align key capabilities with trust development:

1. **Initial Limited Access**: Start with minimal permissions
   👉 ```sh
   XID_DOC=$(envelope xid key add --name "New Collaboration (Initial)" --allow encrypt "$COLLAB_KEY_PUBLIC" "$XID_DOC")
   ```

2. **Documented Trust Development**: Record basis for upgrades
   👉 ```sh
   DELIVERABLE=$(envelope subject type string "Collaborative Deliverable")
   DELIVERABLE=$(envelope assertion add pred-obj string "outcome" string "Successfully completed initial security analysis" "$DELIVERABLE")
   DELIVERABLE=$(envelope assertion add pred-obj string "evaluationResult" string "Exceeds expectations" "$DELIVERABLE")
   ```

3. **Permission Evolution**: Increase capabilities as trust grows
   👉 ```sh
   PROGRESSIVE_XID=$(envelope xid key add --name "New Collaboration (Stage 1)" --allow encrypt --allow sign "$COLLAB_KEY_PUBLIC" "$PROGRESSIVE_XID")
   ```

4. **Transparent Upgrade Process**: Document permission changes
   👉 ```sh
   UPGRADE_RECORD=$(envelope subject type string "Permission Upgrade Record")
   UPGRADE_RECORD=$(envelope assertion add pred-obj string "addedPermissions" string "sign" "$UPGRADE_RECORD")
   UPGRADE_RECORD=$(envelope assertion add pred-obj string "justification" envelope "$SIGNED_DELIVERABLE" "$UPGRADE_RECORD")
   ```

This approach implements least privilege while allowing trust relationships to develop naturally.

## Permission Types and Their Uses

XIDs support these permission types:

- **all**: Allow all operations (use sparingly)
- **sign**: Sign documents and messages as this XID
- **encrypt**: Encrypt/decrypt messages for this XID
- **auth**: Authenticate as this identity
- **update**: Update service endpoints
- **elect**: Add or remove other keys
- **elide**: Create elided (redacted) versions of documents

Choose permissions based on the principle of least privilege - grant only what's needed for each specific key's purpose.

## Key Management Best Practices

1. **Separate Keys by Purpose**: Different keys for different functions
2. **Document Key Operations**: Keep clear records of key changes
3. **Regular Rotation**: Change keys on schedule and immediately if compromise is suspected
4. **Backup Before Change**: Always ensure recovery options before key operations
5. **Transparent Communication**: Notify collaborators of key changes
6. **Progressive Permissions**: Align permissions with trust development
7. **Multiple Recovery Paths**: Don't rely on a single recovery mechanism

## Check Your Understanding

1. Why is a key hierarchy more secure than a single key for everything?
2. What is the process for safely rotating a key?
3. How do XIDs maintain stable identity despite key changes?
4. What are the different types of permissions in the XID system?
5. How do progressive permission models enhance security?

## Next Steps

After understanding key management essentials, you can:
- Apply these concepts in [Tutorial 4: Key Management with XIDs](../tutorials/04-key-management-with-xids.md)
- Create a recovery plan for your XID
- Design a key hierarchy for your specific use case