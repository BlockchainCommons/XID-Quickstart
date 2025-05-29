# The Fair Witness Approach

## Expected Learning Outcomes

By the end of this document, you will:

- Understand the concept of Fair Witness and its origin
- Know the principles for making trustworthy assertions
- Understand how to document observations with context and transparency
- Learn how to acknowledge biases and limitations
- See how this approach builds trust in pseudonymous environments

## The Fair Witness Concept

The term "Fair Witness" comes from Robert A. Heinlein's novel
_Stranger in a Strange Land_, where Fair Witnesses were professionals
trained to observe events with perfect objectivity and recall. When
asked to describe what they saw, a Fair Witness would report only what
they directly observed, without interpretation or assumption.

For example, if asked about the color of a house visible in the
distance, a Fair Witness might say, "It appears to be painted white on
this side," rather than simply "It's white" &mdash; acknowledging they
cannot see all sides of the house.

### Principles for Trustworthy Assertions

When making claims as a Fair Witness, follow these core principles:

1. **Core Observation:**
   * **Specificity**: Be precise about what you observed directly.
2. **Context & Methodology:**   
   * **Context**: Provide relevant contextual information.
   * **Methodology**: Explain how observations were made.
   * **Verifiability**: Include or reference supporting evidence.
3. **Limitations & Potential Bias:**   
   * **Limitations**: Acknowledge what you couldn't observe.
   * **Separation**: Distinguish facts from interpretations.
   * **Transparency**: Disclose potential biases and conflicts.

### Creating Contextual Assertions

These principles can be reflected in data stored in Gordian Envelope.

**Core Observation**:
```
"API Security Assessment" [
   "securityVulnerabilities": "Three XSS vulnerabilities found in user input fields"
]
```

**Context and Methodology**:
```
"API Security Assessment" [
   "securityVulnerabilities": "Three XSS vulnerabilities found in user input fields"
   "testingMethodology": "Automated scanning with manual verification"
   "testDate": "2023-11-28"
   "testDuration": "40 hours"
   "toolsUsed": "OWASP ZAP, Burp Suite, custom scripts"
]
```

**Limitations and Potential Biases**:
```
"API Security Assessment" [
   "securityVulnerabilities": "Three XSS vulnerabilities found in user input fields"
   "testingMethodology": "Automated scanning with manual verification"
   "testDate": "2023-11-28"
   "testDuration": "40 hours"
   "toolsUsed": "OWASP ZAP, Burp Suite, custom scripts"
   "limitationsOfAnalysis": "No access to source code, black-box testing only"
   "potentialBias": "Prior experience with similar authentication systems"
]
```

## The Power of Fair Witnessing in Digital Identity

In digital environments where traditional trust signals (such as
real-world identities) are absent, the Fair Witness approach provides
an alternative foundation for trust:

1. **Verifiability Over Authority**: Trust is based on verification rather than credentials.
2. **Context Over Claims**: A rich context allows others to evaluate reliability.
3. **Transparency Over Opacity**: Methods and limitations are openly revealed.
4. **Progressive Trust**: Revelation of additional context can improve trust.

## Building Trust Through Endorsements

The Fair Witness approach becomes even more powerful when combined with proper peer endorsements:

1. **Independent Verification**: Third parties can confirm claims through formal endorsements.
2. **Multiple Perspectives**: Different observers can endorse the same work from their unique viewpoint.
3. **Network of Trust**: Endorsements build a web of verifiable relationships.
4. **Transparent Relationships**: Connections are explicitly disclosed.
5. **Acceptance Model**: Endorsements are reviewed and formally accepted by the recipient.

## Practical Implement: Fair Witness Assertion

Following the Fair Witnessing methodology, a person can use
[Gordian-Enveloope
CLI](https://github.com/BlockchainCommons/bc-envelope-cli-rust) to
create a personal assertion that reveals what they've done (and how
they did so).

When creating assertions with their XID, they should include:

1. **Clear Subject Matter**:
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

5. **Cryptographic Signatures** for verification:
   ```sh
  WRAPPED_PROJECT=$(envelope subject type wrapped $PROJECT)
  SIGNED_PROJECT=$(envelope sign -s "$PRIVATE_KEYS" "$WRAPPED_PROJECT")
   ```

The final enveope should look like this:
```
{
    "Financial API Security Overhaul" [
        "limitations": "Backend components only, limited frontend involvement"
        "methodology": "Security testing with automated scanning and manual code review"
        "metricsHash": Digest(42b89478)
        "role": "Lead Security Developer"
        "timeframe": "2022-03 through 2022-09"
    ]
} [
    'signed': Signature
]
```
## Practical Implementation: Fair Witness Endorsement

A peer endorsement can be created in the same way as a fair witness
assertion using [Gordian Envelope
CLI](https://github.com/BlockchainCommons/bc-envelope-cli-rust).

```sh
ENDORSEMENT=$(envelope subject type string "Endorsement: Financial API Project")
ENDORSEMENT=$(envelope assertion add pred-obj string "endorser" string "TechPM - Project Manager with 12 years experience" "$ENDORSEMENT")
ENDORSEMENT=$(envelope assertion add pred-obj string "relationship" string "Direct project oversight as Project Manager" "$ENDORSEMENT")
ENDORSEMENT=$(envelope assertion add pred-obj string "observation" string "BRadvoc8 designed innovative authentication system that exceeded security requirements" "$ENDORSEMENT")
ENDORSEMENT=$(envelope assertion add pred-obj string "basis" string "Direct oversight throughout the project" "$ENDORSEMENT")
ENDORSEMENT=$(envelope assertion add pred-obj string "potentialBias" string "Had management responsibility for project success" "$ENDORSEMENT")
ENDORSEMENT=$(envelope assertion add pred-obj string "endorserLimitation" string "Limited technical background in cryptography" "$ENDORSEMENT")

# Wrap & sign the endorsement - this makes it cryptographically verifiable
WRAPPED_ENDORSEMENT=$(envelope subject type wrapped "$ENDORSEMENT")
SIGNED_ENDORSEMENT=$(envelope sign -s "$ENDORSER_KEYS" "$WRAPPED_ENDORSEMENT")
```

The endorsement is then formally reviewed and accepted by the recipient:

```sh
# Verify the endorser's signature
envelope verify -v "$ENDORSER_PUBLIC_KEY" "$SIGNED_ENDORSEMENT"

# After review, accept and incorporate the endorsement
XID_DOC=$(envelope assertion add pred-obj string "acceptedEndorsement" envelope "$SIGNED_ENDORSEMENT" "$XID_DOC")
```
Here's a potential result:
```
XID(7dbdac6e) [
    'key': PublicKeys(dba49741) [
        'allow': 'All'
        'nickname': "MyIdentifier"
    ]
    "acceptedEndorsement": {
        "Endorsement: Financial API Project" [
            "basis": "Direct oversight throughout the project"
            "endorser": "TechPM - Project Manager with 12 years experience"
            "endorserLimitation": "Limited technical background in cryptography"
            "observation": "BRadvoc8 designed innovative authentication system that exceeded security requirements"
            "potentialBias": "Had management responsibility for project success"
            "relationship": "Direct project oversight as Project Manager"
        ]
    } [
        'signed': Signature
    ]
]
```

## Check Your Understanding

1. What is the core principle of the Fair Witness approach?
2. Why is context important when making assertions?
3. How does disclosing limitations and potential biases build trust?
4. How do peer attestations strengthen the Fair Witness model?
5. How does the Fair Witness approach enable trust in pseudonymous environments?

## Next Steps

After understanding the Fair Witness approach, you can:
- Apply these concepts to self-attestations in [Tutorial 3: Self-Attestation with XIDs](../tutorials/03-self-attestation-with-xids.md)
- Learn how to apply them to endorsements in [Tutorial 4: Peer Endorsement with XIDs](../tutorials/04-peer-endorsement-with-xids.md)
- Learn about the [Attestation and Endorsement Model](attestation-endorsement-model.md)
- Explore [Pseudonymous Trust Building](pseudonymous-trust-building.md)