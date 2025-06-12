# Key Management Essentials

## Expected Learning Outcomes

By the end of this document, you will:

- Understand the importance of proper key management for XIDs.
- Know how to create and manage a trust-based key hierarchy.
- See how progressive permission models work in practice.
- Learn key rotation procedures and best practices.
- Understand recovery strategies that preserve XID stability.

## The Foundation of XID Security

Cryptographic keys are the foundation of XID security and
functionality. Proper key management is critical because:

- Keys control who can use and modify your XID.
- Keys enable verification, signing, and encryption capabilities.
- Key loss without recovery options means losing access to your identity.
- Key compromise could lead to identity impersonation.

### Key Management Best Practices

1. **Separate Keys by Purpose**: Authorize different keys for different functions.
2. **Progressive Permissions**: Align permissions with trust development.
3. **Document Key Operations**: Keep clear records of key changes.
4. **Regular Rotation**: Change keys on schedule and immediately if compromise is suspected.
5. **Backup Before Change**: Always ensure recovery options before key operations.
6. **Transparent Communication**: Notify collaborators of key changes.
7. **Multiple Recovery Paths**: Don't rely on a single recovery mechanism.

### Creating a Trust-Based Key Hierarchy

Rather than using a single key for everything, a trust-based key
hierarchy uses different keys for different purposes and contexts:

XIDs support these general permission types:

- **all**: Allow all operations (use sparingly)
- **auth**: Authenticate as this identity
- **sign**: Sign documents and messages as this XID
- **encrypt**: Encrypt/decrypt messages for this XID
- **elide**: Create elided (redacted) versions of documents
- **issue**: Issue or revoke credentials for this XID
- **access**: Access resources allocated to this XID

Plus these management permission types:

- **delegate**: Give function access to third parties
- **verify**: Update this XID
- **update**: Update service endpoints
- **transfer**: Remove inception key
- **elect**: Add or remove other keys
- **burn**: Transition to a new provenance mark chain
- **revoke**: Revoke this XID

Choose permissions based on the principle of least privilege: grant
only what's needed for each specific key's purpose.

### Progressive Permission Models

Key capabilities don't have to be locked in. Progressive permission
models align key capabilities with trust development. As a
relationship grows and expands, existing keys can be given new access
within a XID.

This approach implements least privilege while allowing trust
relationships to develop naturally. It is a form of [progressive
trust](progressive-trust.md).

## Rotation & Recovery

Key can be rotated and if lost they can be recovered.

### Key Rotation

Key rotation is the process of replacing existing keys with new
ones. It's an essential practice for:

- Limiting exposure from lost/stolen devices
- Mitigating other potential compromise
- Adapting to organizational changes
- Implementing regular security hygiene

Key rotation is especially powerful with XIDs because **the XID
identifier remains stable** even as keys change. This allows you to
maintain your digital identity across key changes.

As noted in best practices, key rotation should occur regularly,
should be well documented, and should be carefully administered, with
backups.

### Key Recovery

Key loss shouldn't mean identity loss. XID enables recovery approaches
that preserve your stable identifier.  This is typically done with a
Recovery Key, which has special permissions.

To recover a key:

- Use special keys with limited "update" and "elect" permissions only.
- Use different authorization pathway than for normal use.

Any recovery should also be supported with documents.

- Update XID, then sign attestation with recovery key.
- Produce clear records of the recovery process.
- Offer transparent explanation of what happened.

Though key recovery can be self-sovereign, which is something you do
yourself, you can also use social recovery, where other peoples' keys
have been identified as the recovery keys:

- Trusted peers hold recovery authorization
- Multiple perspectives reduce vulnerability

These recovery mechanisms maintain the XID's stable identifier
throughout the recovery process, preserving relationships and trust.

## Practical Implementation: Trust-Based Key Hierarchy

**Primary Identity Key**:
- Core key that controls the XID
- Highest security level with maximum protection
- Used rarely and stored very securely

  ```sh
  PRIMARY_KEY_PRIVATE=$(envelope generate prvkeys)
  PRIMARY_KEY_PUBLIC=$(envelope generate pubkeys $PRIMARY_KEY_PRIVATE)
  XID_DOC=$(envelope xid new --nickname "BWHacker" $PRIMARY_KEY_PUBLIC)
  ```

**Function-Specific Keys**:
- Keys with single purposes (signing, encryption, etc.)
- Following the principle of least privilege
- Can be combined with other key types, as shown in other examples

  ```sh
  XID_DOC=$(envelope xid key add --nickname "Evidence Commitment Key" --allow sign "$EVIDENCE_KEY_PUBLIC" "$XID_DOC")
  ```

**Project-Specific Keys**:
- Dedicated keys for specific projects or contexts

  ```sh
  XID_DOC=$(envelope xid key add --nickname "API Security Project" --allow sign --allow encrypt "$PROJECT_KEY_PUBLIC" "$XID_DOC")
  ```

**Device Keys**:
- Separate keys for different devices (laptop, tablet, phone)
- Limited permissions specific to device use
- More convenient day-to-day access

  ```sh
  XID_DOC=$(envelope xid key add --nickname "Tablet Key" --allow sign "$TABLET_KEY_PUBLIC" "$XID_DOC")
  ```

**Recovery Keys**:
- Special keys with update/elect permissions only
- Stored securely offline or with trusted individuals

  ```sh
  XID_DOC=$(envelope xid key add --nickname "Recovery Key" --allow update --allow elect "$RECOVERY_KEY_PUBLIC" "$XID_DOC")
  ```

This hierarchical approach combines security with usability by using the right key for each context.

Result:
```sh
XID(e4dd674b) [
    'key': PublicKeys(0c16852a) [
        'allow': 'Encrypt'
        'allow': 'Sign'
        'nickname': "API Security Project"
    ]
    'key': PublicKeys(26a3ad59) [
        'allow': 'All'
        'nickname': "BWHacker"
    ]
    'key': PublicKeys(63a005e6) [
        'allow': 'Sign'
        'nickname': "Evidence Commitment Key"
    ]
    'key': PublicKeys(652fc4d7) [
        'allow': 'Elect'
        'allow': 'Update'
        'nickname': "Recovery Key"
    ]
    'key': PublicKeys(9608e2d6) [
        'allow': 'Sign'
        'nickname': "Tablet Key"
    ]
]
```

## Practical Implementation: Progressive Permission Models

1. **Initial Limited Access**: Start with minimal permissions
   ```sh
   PROGRESSIVE_XID=$(envelope xid key add --nickname "New Collaboration (Initial)" --allow encrypt "$COLLAB_KEY_PUBLIC" "$XID_DOC")
   ```

2. **Documented Trust Development**: Record basis for upgrades
   ```sh
   DELIVERABLE=$(envelope subject type string "Collaborative Deliverable")
   DELIVERABLE=$(envelope assertion add pred-obj string "outcome" string "Successfully completed initial security analysis" "$DELIVERABLE")
   DELIVERABLE=$(envelope assertion add pred-obj string "evaluationResult" string "Exceeds expectations" "$DELIVERABLE")
   WRAPPED_DELIVERABLE=$(envelope subject type wrapped $DELIVERABLE)
   SIGNED_DELIVERABLE=$(envelope sign -s $PRIMARY_KEY_PRIVATE $WRAPPED_DELIVERABLE)
   ```

3. **Permission Evolution**: Increase capabilities as trust grows
   ```sh
   PROGRESSIVE_XID=$(envelope xid key update --nickname "New Collaboration (Stage 1)" --allow encrypt --allow sign "$COLLAB_KEY_PUBLIC" "$PROGRESSIVE_XID")
   ```

4. **Transparent Upgrade Process**: Document permission changes
   ```sh
   UPGRADE_RECORD=$(envelope subject type string "Permission Upgrade Record")
   UPGRADE_RECORD=$(envelope assertion add pred-obj string "addedPermissions" string "sign" "$UPGRADE_RECORD")
   UPGRADE_RECORD=$(envelope assertion add pred-obj string "justification" envelope "$SIGNED_DELIVERABLE" "$UPGRADE_RECORD")
   ```

Initial Result:
```
XID(e4dd674b) [
    'key': PublicKeys(26a3ad59) [
        'allow': 'All'
        'nickname': "BWHacker"
    ]
    'key': PublicKeys(92e399cd) [
        'allow': 'Encrypt'
        'nickname': "New Collaboration (Initial)"
    ]
]
```

Later Result:
```
XID(e4dd674b) [
    'key': PublicKeys(26a3ad59) [
        'allow': 'All'
        'nickname': "BWHacker"
    ]
    'key': PublicKeys(92e399cd) [
        'allow': 'Encrypt'
        'allow': 'Sign'
        'nickname': "New Collaboration (Stage 1)"
    ]
]

"Permission Upgrade Record" [
    "addedPermissions": "sign"
    "justification": {
        "Collaborative Deliverable" [
            "evaluationResult": "Exceeds expectations"
            "outcome": "Successfully completed initial security analysis"
        ]
    } [
        'signed': Signature
    ]
]
```

## Practical Implementation: Key Rotation

**The Rotation Process**:

1. **Document the Reason**: Record why rotation is happening

   ```sh
   TABLET_KEY=$(envelope xid key find name "Tablet Key" "$XID_DOC" | envelope extract ur)   
   ROTATION_RECORD=$(envelope subject type ur $TABLET_KEY)
   ROTATION_RECORD=$(envelope assertion add pred-obj string "rotationReason" string "Suspected device tampering at public cafe" "$ROTATION_RECORD")
   ```

2. **Generate New Key**: Create fresh key material

   ```sh
   NEW_TABLET_KEY_PRIVATE=$(envelope generate prvkeys)
   NEW_TABLET_KEY_PUBLIC=$(envelope generate pubkeys "$NEW_TABLET_KEY_PRIVATE")
   ```

3. **Remove Old Key**: Take out the key being rotated

   ```sh
   ROTATED_XID=$(envelope xid key remove "$TABLET_KEY" "$XID_DOC")
   ```

4. **Add New Key**: Add the replacement with appropriate permissions
   ```sh
   ROTATED_XID=$(envelope xid key add --nickname "Tablet Key (Rotated)" --allow sign "$NEW_TABLET_KEY_PUBLIC" "$ROTATED_XID")
   ```

5. **Notify Collaborators**: Inform others who need to verify your signatures
   ```sh
   NOTIFICATION=$(envelope subject type string "Key Rotation Notification")
   NOTIFICATION=$(envelope assertion add pred-obj string "oldKey" envelope $ROTATION_RECORD $NOTIFICATION)
   NOTIFICATION=$(envelope assertion add pred-obj string "newKey" ur $NEW_TABLET_KEY_PUBLIC $NOTIFICATION)
   WRAPPED_NOTIFICATION=$(envelope subject type wrapped $NOTIFICATION)
   SIGNED_NOTIFICATION=$(envelope sign -s "$PRIMARY_KEY_PRIVATE" "$WRAPPED_NOTIFICATION")
   ```

Result:
```
XID(e4dd674b) [
    'key': PublicKeys(0c16852a) [
        'allow': 'Encrypt'
        'allow': 'Sign'
        'nickname': "API Security Project"
    ]
    'key': PublicKeys(26a3ad59) [
        'allow': 'All'
        'nickname': "BWHacker"
    ]
    'key': PublicKeys(63a005e6) [
        'allow': 'Sign'
        'nickname': "Evidence Commitment Key"
    ]
    'key': PublicKeys(652fc4d7) [
        'allow': 'Elect'
        'allow': 'Update'
        'nickname': "Recovery Key"
    ]
    'key': PublicKeys(fd9589c4) [
        'allow': 'Sign'
        'nickname': "Tablet Key (Rotated)"
    ]
]

{
    "Key Rotation Notification" [
        "newKey": PublicKeys(fd9589c4)
        "oldKey": PublicKeys(9608e2d6) [
            "rotationReason": "Suspected device tampering at public cafe"
        ]
    ]
} [
    'signed': Signature
]
```

## Practical Implementation: Key Recovery

1. **Swap Out Key:**

  ```sh
  RECOVERED_XID=$(envelope xid key remove "$PRIMARY_KEY_PUBLIC" "$XID_DOC")
  RECOVERED_XID=$(envelope xid key add --nickname "Primary Identity (Recovered)" --allow all "$NEW_PRIMARY_KEY_PUBLIC" "$RECOVERED_XID")
  ```

2. **Document Recovery:**

  ```sh
  RECOVERY_ATTESTATION=$(envelope subject type string "Recovery Authorization")
  RECOVERY_ATTESTATION=$(envelope assertion add pred-obj string "regarding" string "$XID" "$RECOVERY_ATTESTATION")
  RECOVERY_ATTESTATION=$(envelope assertion add pred-obj string "recoveryKey" ur "$RECOVERY_KEY_PUBLIC" "$RECOVERY_ATTESTATION")
  RECOVERY_ATTESTATION=$(envelope assertion add pred-obj string "action" string "Recovery of primary identity key" "$RECOVERY_ATTESTATION")
  RECOVERY_ATTESTATION=$(envelope assertion add pred-obj string "methodology" string "Recovery key used" "$RECOVERY_ATTESTATION")
  ```

3. **Sign Recovery:**

  ```sh
  WRAPPED_RECOVERY_ATTESTATION=$(envelope subject type wrapped $RECOVERY_ATTESTATION)
  SIGNED_RECOVERY_ATTESTATION=$(envelope sign -s "$RECOVERY_KEY_PRIVATE" "$WRAPPED_RECOVERY_ATTESTATION")
  ```

Result:
```
XID(e4dd674b) [
    'key': PublicKeys(0c16852a) [
        'allow': 'Encrypt'
        'allow': 'Sign'
        'nickname': "API Security Project"
    ]
    'key': PublicKeys(31cd38e4) [
        'allow': 'All'
        'nickname': "Primary Identity (Recovered)"
    ]
    'key': PublicKeys(63a005e6) [
        'allow': 'Sign'
        'nickname': "Evidence Commitment Key"
    ]
    'key': PublicKeys(652fc4d7) [
        'allow': 'Elect'
        'allow': 'Update'
        'nickname': "Recovery Key"
    ]
    'key': PublicKeys(9608e2d6) [
        'allow': 'Sign'
        'nickname': "Tablet Key"
    ]
]

{
    "Recovery Authorization" [
        "action": "Recovery of primary identity key"
        "methodology": "Recovery key used"
        "recoveryKey": PublicKeys(652fc4d7)
        "regarding": "ur:xid/hdcxeylndptnkpjelgjtjeetrtnnjtbdswgdemgdtldlwtgdwknnrpytckvsfxdtmesbeekpjyoy"
    ]
} [
    'signed': Signature
]
```

## Check Your Understanding

1. Why is a key hierarchy more secure than a single key for everything?
2. What are the different types of permissions in the XID system?
3. How do progressive permission models enhance security?
4. What is the process for safely rotating a key?
5. How do XIDs maintain stable identity despite key changes?

## Next Steps

After understanding key management essentials, you can:
- Design a key hierarchy for your specific use case
- Create a recovery plan for your XID
- Apply these concepts in [Tutorial 4: Key Management with XIDs](../tutorials/04-key-management-with-xids.md)
- Move over to [Data Minimization Principles](data-minimization.md)
- Move over to [Fair Witness Approach](fair-witness.md)
- Continue on to [Progressive Trust](progressive-trust.md)