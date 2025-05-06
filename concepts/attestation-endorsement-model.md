# Attestation and Endorsement Model

## Expected Learning Outcomes
By the end of this document, you will:
- Understand the difference between self-attestations and peer endorsements
- Know how to structure proper attestations with verifiable evidence
- Learn the endorsement acceptance model for building trust
- Understand how to create and verify chains of trust
- See how attestations and endorsements work together in a trust framework

## The Foundation: Attestations vs. Endorsements

### Self-Attestations
Self-attestations are claims you make about yourself, your work, or your capabilities. While necessary, they have inherent limitations in building trust:

- **Source Limitation**: They come from the same entity making the claims
- **Verification Challenge**: They require external validation to be truly trusted
- **Trust Foundation**: They form the foundation upon which others can build

Proper self-attestations include:
- Clear statements of capability or experience
- Contextual information about how the capability was developed
- Limitations and boundaries of the claimed expertise
- Verifiable evidence when possible (without compromising privacy)
- Transparency about potential biases

### Peer Endorsements
Endorsements are attestations made by others about you or your work. They provide independent verification:

- **Independent Source**: They come from entities other than the subject
- **Enhanced Credibility**: They carry more weight due to their independence
- **Multiple Perspectives**: They can provide diverse viewpoints on the same work
- **Progressive Trust**: They build layers of verification over time

## Structuring Proper Self-Attestations

A well-formed self-attestation includes:

1. **Clear Subject**: What specifically is being attested to
   👉
   ```sh
   PROJECT=$(envelope subject type string "Financial API Security Overhaul")
   ```

2. **Specific Claims with Context**:
   👉
   ```sh
   PROJECT=$(envelope assertion add pred-obj string "role" string "Lead Security Developer" "$PROJECT")
   PROJECT=$(envelope assertion add pred-obj string "timeframe" string "2022-03 through 2022-09" "$PROJECT")
   ```

3. **Methodology and Evidence**:
   👉
   ```sh
   PROJECT=$(envelope assertion add pred-obj string "methodology" string "Security testing with automated scanning and manual code review" "$PROJECT")
   PROJECT=$(envelope assertion add pred-obj string "metricsHash" digest "$METRICS_HASH" "$PROJECT")
   ```

4. **Transparent Limitations**:
   👉
   ```sh
   PROJECT=$(envelope assertion add pred-obj string "limitations" string "Backend components only, limited frontend involvement" "$PROJECT")
   ```

5. **Cryptographic Signatures**:
   👉
   ```sh
   SIGNED_PROJECT=$(envelope sign -s "$PRIVATE_KEYS" "$PROJECT")
   ```

## Creating Verifiable External References

Self-attestations become more credible when they reference independently verifiable sources:

1. **Git Commit References**:
   👉
   ```sh
   # Generate a hash of the commit history
   GIT_HISTORY_HASH=$(git log --author="Amira's Git Email" --pretty=format:"%H" | envelope digest sha256)
   
   # Add the verifiable reference to the project
   PROJECT=$(envelope assertion add pred-obj string "gitCommitHistory" digest "$GIT_HISTORY_HASH" "$PROJECT")
   PROJECT=$(envelope assertion add pred-obj string "gitRepo" string "https://github.com/organization/project" "$PROJECT")
   PROJECT=$(envelope assertion add pred-obj string "gitVerificationNote" string "Commits signed with GPG key fingerprint 3AA5 C34D..." "$PROJECT")
   ```

2. **Published Work**:
   👉
   ```sh
   PROJECT=$(envelope assertion add pred-obj string "publicationDOI" string "10.1234/journal.article" "$PROJECT")
   PROJECT=$(envelope assertion add pred-obj string "publicationDate" string "2023-05-12" "$PROJECT")
   ```

3. **Public Demonstrations**:
   👉
   ```sh
   PROJECT=$(envelope assertion add pred-obj string "demoVideo" string "https://example.com/demo-with-timestamp" "$PROJECT")
   PROJECT=$(envelope assertion add pred-obj string "demoHash" digest "$DEMO_HASH" "$PROJECT")
   ```

## The Endorsement Model

### Endorsement Structure

A proper endorsement includes:

1. **Clear Identification of Subject**:
   👉
   ```sh
   ENDORSEMENT=$(envelope subject type string "Endorsement: Financial API Project")
   ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementTarget" digest "$XID_ID" "$ENDORSEMENT")
   ```

2. **Endorser Information**:
   👉
   ```sh
   ENDORSEMENT=$(envelope assertion add pred-obj string "endorser" string "TechPM - Project Manager with 12 years experience" "$ENDORSEMENT")
   ```

3. **Relationship Disclosure**:
   👉
   ```sh
   ENDORSEMENT=$(envelope assertion add pred-obj string "relationship" string "Direct project oversight as Project Manager" "$ENDORSEMENT")
   ```

4. **Specific Observations**:
   👉
   ```sh
   ENDORSEMENT=$(envelope assertion add pred-obj string "observation" string "BWHacker designed innovative authentication system that exceeded security requirements" "$ENDORSEMENT")
   ```

5. **Basis for Endorsement**:
   👉
   ```sh
   ENDORSEMENT=$(envelope assertion add pred-obj string "basis" string "Direct observation throughout the project plus review of metrics" "$ENDORSEMENT")
   ```

6. **Endorser's Limitations**:
   👉
   ```sh
   ENDORSEMENT=$(envelope assertion add pred-obj string "endorserLimitation" string "Limited technical background in cryptography" "$ENDORSEMENT")
   ```

7. **Potential Biases**:
   👉
   ```sh
   ENDORSEMENT=$(envelope assertion add pred-obj string "potentialBias" string "Had management responsibility for project success" "$ENDORSEMENT")
   ```

8. **Cryptographic Signature**:
   👉
   ```sh
   SIGNED_ENDORSEMENT=$(envelope sign -s "$ENDORSER_KEYS" "$ENDORSEMENT")
   ```

### The Endorsement Acceptance Model

For maximum credibility, endorsements should follow an acceptance model:

1. **Endorser Creates Signed Endorsement**:
   👉
   ```sh
   SIGNED_ENDORSEMENT=$(envelope sign -s "$ENDORSER_KEYS" "$ENDORSEMENT")
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
   
   # Extract and review the endorsement content
   envelope format --type tree "$SIGNED_ENDORSEMENT"
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
   UPDATED_XID=$(envelope sign -s "$PRIVATE_KEYS" "$XID_DOC")
   ```

This acceptance model ensures:
- The recipient maintains control over their identity
- Endorsements meet the recipient's standards for fairness and accuracy
- There's a clear process for accepting or declining endorsements
- The chain of signatures creates a verifiable trust path

## Building a Trust Network

The power of this model comes from combining multiple attestations and endorsements:

1. **Core Self-Attestations**: The foundation of the trust framework
2. **Direct Endorsements**: Peer verification of specific work or capabilities
3. **Secondary Endorsements**: Endorsements of endorsers (establishing their credibility)
4. **Diverse Perspectives**: Endorsements from different viewpoints (technical, managerial, client)
5. **Growing Over Time**: Progressive addition of new attestations and endorsements

### Self-Endorsements for Verified Public Achievements

For some achievements, you can create a special type of self-attestation that references publicly verifiable information:

👉
```sh
# Create a contributor self-endorsement
CONTRIBUTOR_CLAIM=$(envelope subject type string "Open Source Contributor")
CONTRIBUTOR_CLAIM=$(envelope assertion add pred-obj string "project" string "Blockchain Commons Libraries" "$CONTRIBUTOR_CLAIM")
CONTRIBUTOR_CLAIM=$(envelope assertion add pred-obj string "role" string "Core Contributor" "$CONTRIBUTOR_CLAIM")
CONTRIBUTOR_CLAIM=$(envelope assertion add pred-obj string "timeframe" string "2022-01 through present" "$CONTRIBUTOR_CLAIM")

# Add verifiable evidence
CONTRIBUTOR_CLAIM=$(envelope assertion add pred-obj string "gitUsername" string "BWHacker" "$CONTRIBUTOR_CLAIM")
CONTRIBUTOR_CLAIM=$(envelope assertion add pred-obj string "repoURL" string "https://github.com/BlockchainCommons/bc-libs" "$CONTRIBUTOR_CLAIM")
CONTRIBUTOR_CLAIM=$(envelope assertion add pred-obj string "commitCount" string "37 commits to main branch" "$CONTRIBUTOR_CLAIM")
CONTRIBUTOR_CLAIM=$(envelope assertion add pred-obj string "verificationMethod" string "All commits cryptographically signed with GPG key matching XID key" "$CONTRIBUTOR_CLAIM")

# Sign the claim
SIGNED_CONTRIBUTOR_CLAIM=$(envelope sign -s "$PRIVATE_KEYS" "$CONTRIBUTOR_CLAIM")

# Add to XID
XID_DOC=$(envelope assertion add pred-obj string "verifiedContribution" envelope "$SIGNED_CONTRIBUTOR_CLAIM" "$XID_DOC")
```

This kind of self-endorsement bridges the gap between pure self-attestation and peer endorsement by:
- Making specific claims about contributions
- Providing transparent verification methods
- Linking to public, independently verifiable evidence
- Establishing a cryptographic connection between the XID and external identity

## Trust Verification Process

The verification process for someone evaluating this trust network:

1. **Verify Self-Attestation Signatures**: Confirm the XID holder signed their claims
2. **Verify Endorsement Signatures**: Confirm each endorser signed their endorsements
3. **Check Acceptance Signatures**: Verify the XID holder accepted each endorsement
4. **Evaluate Context and Disclosures**: Review methodologies, limitations, and potential biases
5. **Check External References**: Verify any external evidence that was referenced
6. **Consider Multiple Perspectives**: Look for consistency across different endorsers

## Use Cases for Endorsements

Different types of endorsements serve different trust purposes:

1. **Professional Skill Endorsements**: Verifying technical capabilities or domain expertise
2. **Contribution Validations**: Confirming specific work on projects
3. **Behavioral Testimonials**: Attesting to how someone works and collaborates
4. **Credential Confirmations**: Validating education or certifications without revealing identity
5. **Reputation Transfers**: Allowing trusted introducers to vouch for someone

## Check Your Understanding

1. What are the key differences between self-attestations and endorsements?
2. Why is the acceptance model important for endorsements?
3. How does verifiable external evidence strengthen self-attestations?
4. What makes an endorsement more credible and trustworthy?
5. How does a network of attestations and endorsements build over time?

## Next Steps

After understanding the Attestation and Endorsement Model, you can:
- Apply self-attestation principles in Tutorial 3: Self-Attestation with XIDs
- Implement peer endorsements in Tutorial 4: Peer Endorsement with XIDs
- Explore [Pseudonymous Trust Building](pseudonymous-trust-building.md) for broader context