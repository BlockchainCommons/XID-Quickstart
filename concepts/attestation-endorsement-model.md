# Attestation and Endorsement Model

## Expected Learning Outcomes

By the end of this document, you will:

- Understand the difference between self-attestations and peer endorsements.
- Know how to structure proper attestations with verifiable evidence.
- Learn the endorsement acceptance model for building trust.
- Understand how to create and verify chains of trust.
- See how attestations and endorsements work together in a trust framework.

## The Foundation: Self-Attestations vs. Endorsements

Claims can come in two sorts: self-attestations and third-party
endorsements. These claims are usually attached to an identifier, such
as a [XID](xid.md).

### Self-Attestations

Self-attestations are claims you make about yourself, your work, or
your capabilities. While necessary, they have inherent limitations in
building trust:

- **Source Limitation**: They come from the subject of the claim.
- **Verification Challenge**: They require external validation to be truly trusted.

The best self-attestations include:

- Clear statements of capability or experience
- Contextual information about how the capability was developed
- Limitations and boundaries of the claimed expertise
- Verifiable evidence when possible (without compromising privacy)
- Transparency about potential biases

### Verifiable Self-Attestations

Self-attestations can gain weight if they are verifiable, offering
some way for third parties to check the claims. This kind of
self-endorsement bridges the gap between pure self-attestation and
peer endorsement by:

- Making specific claims about contributions
- Providing transparent verification methods
- Linking to public, independently verifiable evidence

### Peer Endorsements

Endorsements are attestations made by others about you or your
work. They implicitly provide some level of verification, depending on
the trust lvel of the third-party endorser.

- **Independent Source**: They come from entities other than the subject.
- **Enhanced Credibility**: They carry more weight due to their independence.
- **Multiple Perspectives**: They can provide diverse viewpoints on the same work.
- **Progressive Trust**: They build layers of verification over time.

### Endorsement Acceptance

Because peer endorsements were not made by the subject, they should be
accepted by the subject if they are to become part of the subject's
identity information. This acceptance model ensures:

- The recipient maintains control over their identity.
- Endorsements meet the recipient's standards for fairness and accuracy.
- There's a clear process for accepting or declining endorsements.
- The chain of signatures creates a verifiable trust path.

### Use Cases for Self-Attestations & Endorsements

Different types of self-attestations and endorsements serve different trust purposes:

1. **Professional Skill Endorsements**: Verifying technical capabilities or domain expertise
2. **Contribution Validations**: Confirming specific work on projects
3. **Behavioral Testimonials**: Attesting to how someone works and collaborates
4. **Credential Confirmations**: Validating education or certifications, potentially without revealing identity
5. **Reputation Transfers**: Allowing trusted introducers to vouch for someone

## Building a Trust Network

The power of this model of self-attestations and endorsements comes
from combining multiple claims over an extended period of time:

1. **Core Self-Attestations**: User offers their own foundation for the trust framework.
2. **Direct Endorsements**: Peers verify specific work or capabilities.
3. **Diverse Perspectives**: Peers offer endorsements from different viewpoints (technical, managerial, client).
4. **Secondary Endorsements**: Other peers endorse endorsers to establish their credibility.
5. **Growing Over Time**: New attestations and endorsements are progressively added over time.

### Trust Network Verification Process

This trust network can be verified by the following steps:

1. **Verify Self-Attestation Signatures**: Confirm the XID holder signed their claims.
2. **Verify Endorsement Signatures**: Confirm each endorser signed their endorsements.
3. **Check Acceptance Signatures**: Verify the XID holder accepted and signed each endorsement.
4. **Evaluate Context and Disclosures**: Review methodologies, limitations, and potential biases.
5. **Check External References**: Verify any external evidence that was referenced.
6. **Consider Multiple Perspectives**: Look for consistency across different endorsers.

## Practical Implementation: Self-Attestations

A well-formed self-attestation includes:

1. **Clear Subject**: What specifically is being attested to

   ```sh
   PROJECT=$(envelope subject type string "Financial API Security Overhaul")
   ```

2. **Specific Claims with Context**:

   ```sh
   PROJECT=$(envelope assertion add pred-obj string "role" string "Lead Security Developer" "$PROJECT")
   PROJECT=$(envelope assertion add pred-obj string "timeframe" string "2022-03 through 2022-09" "$PROJECT")
   ```

3. **Methodology and Evidence**:

   ```sh
   PROJECT=$(envelope assertion add pred-obj string "methodology" string "Security testing with automated scanning and manual code review" "$PROJECT")
   PROJECT=$(envelope assertion add pred-obj string "metricsHash" digest "$METRICS_HASH" "$PROJECT")
   ```

4. **Transparent Limitations**:

   ```sh
   PROJECT=$(envelope assertion add pred-obj string "limitations" string "Backend components only, limited frontend involvement" "$PROJECT")
   ```

5. **Cryptographic Signatures**:

   ```sh
   WRAPPED_PROJECT=$(envelope subject type wrapped $PROJECT)
   SIGNED_PROJECT=$(envelope sign -s "$PRIVATE_KEYS" "$WRAPPED_PROJECT")
   ```

6. **Identifier Link**:

   ```sh
   XID_DOC_WITH_CLAIMS=$(envelope assertion add pred-obj string selfAssertedClaims envelope $SIGNED_PROJECT $XID_DOC)
   ```
   
This complete self-attestation would be:
```
XID(32862dda) [
    "selfAssertedClaims": {
        "Financial API Security Overhaul" [
            "limitations": "Backend components only, limited frontend involvement"
            "methodology": "Security testing with automated scanning and manual code review"
            "metricsHash": Digest(c90eb8af)
            "role": "Lead Security Developer"
            "timeframe": "2022-03 through 2022-09"
        ]
    } [
        'signed': Signature
    ]
    'key': PublicKeys(007e64a4) [
        'allow': 'All'
        'nickname': "MyIdentifier"
    ]
]
```

## Practical Implementation: Verifiable Self-Attestations

Self-attestations become more credible when they reference independently verifiable sources:

1. **Git Commit References**:

   ```sh
   # Generate a hash of the hashes in the commit history
   GIT_HISTORY_HASH=$(git log --pretty=format:"%H" | shasum -a 256 | awk '{print $1}')

   # Encode per the [ur:digest CDDL](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2021-002-digest.md#cddl)
   GIT_HISTORY_HASH_BW=$(bytewords -i hex "5820"$GIT_HISTORY_HASH -o minimal)
   GIT_HISTORY_HASH_UR="ur:digest/"$GIT_HISTORY_HASH_BW  

   # Add the verifiable reference to the project
   PROJECT_GIT=$(envelope subject type string "https://github.com/organization/project")   
   PROJECT_GIT=$(envelope assertion add pred-obj string "gitCommitHistory" digest "$GIT_HISTORY_HASH_UR" "$PROJECT_GIT")
   PROJECT_GIT=$(envelope assertion add pred-obj string "gitVerificationNote" string "Commits signed with GPG key fingerprint 3AA5 C34D..." "$PROJECT_GIT")
   PROJECT=$(envelope assertion add pred-obj string "gitRepo" envelope $PROJECT_GIT $PROJECT)
   ```
 
2. **Published Work**:

   ```sh
   PROJECT_DOI=$(envelope subject type string "10.1234/journal.article")
   PROJECT_DOI=$(envelope assertion add pred-obj string "publicationDate" string "2023-05-12" "$PROJECT_DOI")
   PROJECT=$(envelope assertion add pred-obj string "publicationDOI" envelope $PROJECT_DOI "$PROJECT")
   ```

3. **Public Demonstrations**:

   ```sh
   PROJECT_DEMO=$(envelope subject type string "https://example.com/demo-with-timestamp")
   PROJECT_DEMO=$(envelope assertion add pred-obj string "demoHash" digest "$DEMO_HASH" "$PROJECT_DEMO")
   PROJECT=$(envelope assertion add pred-obj string "demoVideo" envelope $PROJECT_DEMO "$PROJECT")
   ```

4. **Cryptographic Signatures**:

   ```sh
   WRAPPED_PROJECT=$(envelope subject type wrapped $PROJECT)
   SIGNED_PROJECT=$(envelope sign -s "$PRIVATE_KEYS" "$WRAPPED_PROJECT")
   ```

5. **Identifier Link**:

   ```sh
   XID_DOC_WITH_CLAIMS_AND_REFS=$(envelope assertion add pred-obj string selfAssertedClaims envelope $SIGNED_PROJECT $XID_DOC)
   ```
   
The project with external references could look as follows:
```
XID(32862dda) [
    "selfAssertedClaims": {
        "Financial API Security Overhaul" [
            "demoVideo": "https://example.com/demo-with-timestamp" [
                "demoHash": Digest(d76d4c26)
            ]
            "gitRepo": "https://github.com/organization/project" [
                "gitCommitHistory": Digest(993eabca)
                "gitVerificationNote": "Commits signed with GPG key fingerprint 3AA5 C34D..."
            ]
            "limitations": "Backend components only, limited frontend involvement"
            "methodology": "Security testing with automated scanning and manual code review"
            "metricsHash": Digest(c90eb8af)
            "publicationDOI": "10.1234/journal.article" [
                "publicationDate": "2023-05-12"
            ]
            "role": "Lead Security Developer"
            "timeframe": "2022-03 through 2022-09"
        ]
    } [
        'signed': Signature
    ]
    'key': PublicKeys(007e64a4) [
        'allow': 'All'
        'nickname': "MyIdentifier"
    ]
]
```

## Practical Implementation: Peer Endorsements

### Creating the Endorsement

A proper endorsement includes:

1. **Clear Identification of Subject**:

   ```sh
   ENDORSEMENT=$(envelope subject type string "Endorsement: Financial API Project")
   ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementTarget" ur "$XID" "$ENDORSEMENT")
   ```

2. **Endorser Information**:

   ```sh
   ENDORSEMENT=$(envelope assertion add pred-obj string "endorser" string "TechPM - Project Manager with 12 years experience" "$ENDORSEMENT")
   ```
   
3. **Relationship Disclosure**:

   ```sh
   ENDORSEMENT=$(envelope assertion add pred-obj string "relationship" string "Direct project oversight as Project Manager" "$ENDORSEMENT")
   ```

4. **Specific Observations**:

   ```sh
   ENDORSEMENT=$(envelope assertion add pred-obj string "observation" string "BRadvoc8 designed innovative authentication system that exceeded security requirements" "$ENDORSEMENT")
   ```

5. **Basis for Endorsement**:

   ```sh
   ENDORSEMENT=$(envelope assertion add pred-obj string "basis" string "Direct observation throughout the project plus review of metrics" "$ENDORSEMENT")
   ```

6. **Endorser's Limitations**:

   ```sh
   ENDORSEMENT=$(envelope assertion add pred-obj string "endorserLimitation" string "Limited technical background in cryptography" "$ENDORSEMENT")
   ```

7. **Potential Biases**:

   ```sh
   ENDORSEMENT=$(envelope assertion add pred-obj string "potentialBias" string "Had management responsibility for project success" "$ENDORSEMENT")
   ```

8. **Cryptographic Signature**:

   ```sh
   WRAPPED_ENDORSEMENT=$(envelope subject type wrapped $ENDORSEMENT)
   SIGNED_ENDORSEMENT=$(envelope sign -s "$ENDORSER_KEYS" "$WRAPPED_ENDORSEMENT")
   ```
The result is as follows:
```
{
    "Endorsement: Financial API Project" [
        "basis": "Direct observation throughout the project plus review of metrics"
        "endorsementTarget": XID(32862dda)
        "endorser": "TechPM - Project Manager with 12 years experience"
        "endorserLimitation": "Limited technical background in cryptography"
        "observation": "BRadvoc8 designed innovative authentication system that exceeded security requirements"
        "potentialBias": "Had management responsibility for project success"
        "relationship": "Direct project oversight as Project Manager"
    ]
} [
    'signed': Signature
]
```

### Accepting the Endorsement

For maximum credibility, endorsements should follow an acceptance model:

1. **Endorser Creates Signed Endorsement**:

   ```sh
   WRAPPED_ENDORSEMENT=$(envelope subject type wrapped $ENDORSEMENT)
   SIGNED_ENDORSEMENT=$(envelope sign -s "$ENDORSER_KEYS" "$WRAPPED_ENDORSEMENT")
   ```

2. **Recipient Reviews Endorsement**:
   - Evaluates accuracy and fairness
   - Checks for appropriate context and disclosure
   - Verifies the endorser's signature
   
   👉
   ```sh
   # Verify the signature is valid
   if envelope verify -v "$ENDORSER_PUBLIC_KEY" "$SIGNED_ENDORSEMENT"; then
     echo "✅ Endorsement signature verified"
   else
     echo "❌ Invalid endorsement signature"
   fi
   
   # Review the endorsement content
   envelope format "$SIGNED_ENDORSEMENT"
   ```

3. **Recipient Decides Whether to Accept**:
   - Can accept the endorsement as is
   - Can request modifications before accepting
   - Can decline the endorsement

4. **Recipient Includes Accepted Endorsement**:
   👉
   ```sh
   XID_DOC=$(envelope assertion add pred-obj string "acceptedEndorsement" envelope "$SIGNED_ENDORSEMENT" "$XID_DOC")
   ```

5. **Optional: Recipient Signs the Updated XID**:
   👉
   ```sh
   WRAPPED_XID=$(envelope subject type wrapped $XID_DOC)
   UPDATED_XID=$(envelope sign -s "$PRIVATE_KEYS" "$WRAPPED_XID")
   ```

The result will look like:
```
{
    XID(32862dda) [
        "acceptedEndorsement": {
            "Endorsement: Financial API Project" [
                "basis": "Direct observation throughout the project plus review of metrics"
                "endorsementTarget": XID(32862dda)
                "endorser": "TechPM - Project Manager with 12 years experience"
                "endorserLimitation": "Limited technical background in cryptography"
                "observation": "BRadvoc8 designed innovative authentication system that exceeded security requirements"
                "potentialBias": "Had management responsibility for project success"
                "relationship": "Direct project oversight as Project Manager"
            ]
        } [
            'signed': Signature
        ]
        'key': PublicKeys(007e64a4) [
            'allow': 'All'
            'nickname': "MyIdentifier"
        ]
    ]
} [
    'signed': Signature
]
```

## Check Your Understanding

1. What are the key differences between self-attestations and endorsements?
2. How does verifiable external evidence strengthen self-attestations?
3. Why is the acceptance model important for endorsements?
4. What makes an endorsement more credible and trustworthy?
5. How does a network of attestations and endorsements build over time?

## Next Steps

After understanding the Attestation and Endorsement Model, you can:
- Apply self-attestation principles in Tutorial 3: Self-Attestation with XIDs
- Implement peer endorsements in Tutorial 4: Peer Endorsement with XIDs
- Move sideways to [Data Minimization Principles](data-minimization.md) or [Key Management Essentials](key-management.md).
- Continue on to [Progressive Trust](progressive-trust.md).
