# Progressive Trust Life Cycle Using XIDs

## Expected Learning Outcomes

By the end of this document, you will:

- Understand the concept of Progressive Trust and its life cycle phases
- Learn how XIDs and Gordian Envelopes can implement progressive trust relationships
- See how trust can evolve contextually through different life cycle phases
- Understand how to design systems that support gradiated trust assessment

## Introduction

Traditional digital systems often rely on centralized authorities and
binary trust decisions. **Progressive Trust** instead restores human
choice and agency by enabling nuanced, contextual trust evaluations
that can adjust based on new evidence and interactions. This mirrors
how human trust works in the real world, acknowledging that trust
develops gradually, evolves over time, and exists in shades of gray
rather than black and white.

> **"The basic idea behind progressive trust is to model how trust works in the real world"** [O—Christopher Allen, [Musings of a Trust Architect: Progressive Trust](https://www.blockchaincommons.com/musings/musings-progressive-trust/) (December 2022)

## The Progressive Trust Life Cycle

The [Progressive Trust Life Cycle consists of ten
phases](https://developer.blockchaincommons.com/progressive-trust/)
that reflect how trust evolves in human interactions.

0. Context (Interaction Considered)
1. Introduction (Assertions Declared)
2. Wholeness (Integrity Assessed)
3. Proofs (Secrets Verified)
4. References (Trust Affirmed)
5. Requirements (Community Compliance)
6. Approval (Risk Calculated)
7. Agreement (Threshold Endorsed) [optional]
8. Fulfillment (Interaction Finalized)
9. Escalation (Independently Inspected) [optional]
10. Dispute (Independently Arbitrated) [optional]

### Progressive Trust & Trust Networks

Progressive trust doesn't exist in isolation. It forms a network of
trust relationships across different contexts:

```text
Person A -- trusts --> Person B   (in context X with trust level 0.8)
                    -- trusts --> Person C   (in context Y with trust level 0.6)
                    
Person B -- trusts --> Person D   (in context X with trust level 0.7)

Person C -- trusts --> Person D   (in context Y with trust level 0.9)
```

This means Person A might derive indirect trust of Person D through
different paths with different trust levels in different contexts.

## Implementing Progressive Trust with XIDs

Gordian Envelope and XIDs provide ideal tools for implementing this
life cycle in digital systems. Across trust networks, XIDs provide
stable identifiers for entities while Gordian Envelope enables
context-specific trust assertions and selective disclosure.

To implement progressive trust using XIDs:

1. **Create XIDs for all entities** in your trust network.
2. **Define trust contexts** as specific domains of interaction (e.g., "code review," "document attestation").
3. **Use the life cycle phases** to track progression of trust in each context.
4. **Document trust assertions** using envelopes with appropriate attestations and endorsements.
5. **Implement selective disclosure** to reveal appropriate information based on trust level.
6. **Build trust scores** that adapt based on successful progression through the life cycle phases.
7. **Track trust history** to enable evolution of trust over time.

### Implementing Selective Disclosure for Progressive Trust

A well-constructed envelope detailing progressive trust will
encapsulate most indidivudal phases of the Progressive Trust Life
Cycle into sub-envelopes for organizational and referential
purposes. This also allows for easy elision of specific topics: you
can easily elide a topic or a whole sub-envelope.

Selective disclosure is most often required when some of the
progressive trust information is private, but the overall envelope,
which includes agreement sign-offs, must be disclosed. This might
occur, for example, if there is a legal dispute at the end of a
progressive trust life cycle.

Examples of selective disclosure might include:

* Elision of initial assertions (phase 1) that might break privacy.
* Elision of collected references (phase 4) that might be prejudicial.
* Elision of details of approval (phase 6) or agreement (phase &) that might be prejudicial to the counterparty.

In all of these cases, the data can be elided while maintaining
signatures, such as those offered for apporval.

There are many other possibilities. The important factor here is that
by maintaining progressive trust information in a Gordian Envelope,
you can then choose your level of disclosure when it's required.

## Progressive Trust & Fair Witness Assertions

The Progressive Trust Life Cycle aligns naturally with the [Fair
Witness assertions model](fair-witness.md) already implemented in the
xid-sandbox:

1. **Fair Witness Assertions** provide a foundation for making
verifiable claims with context, while the **Progressive Trust Life
Cycle** defines how these assertions evolve over time.
2. **Observation Context** in Fair Witness maps to the Introduction (1),
Wholeness (2), and Proofs (3) phases of Progressive Trust.
3. **Endorsements** in Fair Witness implement the References (4),
Requirements (5), and Approval (6) phases of Progressive Trust.
4. **Meta-Assertions** support the Agreement (7), Fulfillment (8), Escalation (9),
and Dispute (10) phases of Progressive Trust.
5. **Selective Disclosure** capabilities of Gordian Envelope enable
privacy-preserving progressive trust by revealing appropriate
information at each phase.

## Practical Implementation: Software Signoff

### Phase 0: Context *(Interaction Considered)*

Before trust formation begins, parties consider whether an interaction
requires progressive trust at all.

**XID Implementation:**
```sh
INTERACTION_CONTEXT=$(envelope subject type string "Software Contribution Evaluation")
INTERACTION_CONTEXT=$(envelope assertion add pred-obj string "interactionType" string "Code Contribution Review" "$INTERACTION_CONTEXT")
INTERACTION_CONTEXT=$(envelope assertion add pred-obj string "riskLevel" string "Medium - Production System Component" "$INTERACTION_CONTEXT")
INTERACTION_CONTEXT=$(envelope assertion add pred-obj string "trustModelRequired" string "Progressive" "$INTERACTION_CONTEXT")
```

In this phase, we decide that the evaluation of a software
contribution warrants a progressive trust approach due to its risk
level.

### Phase 1: Introduction *(Assertions Declared)*

Parties make initial declarations and reveal some information while
eliding other data.

**XID Implementation:**
```sh
# Developer declares their identity and code contribution
DEVELOPER_DECLARATION=$(envelope subject type string "Code Contribution #PR-123")
DEVELOPER_DECLARATION=$(envelope assertion add pred-obj string "contributor" string "$DEVELOPER_XID" "$DEVELOPER_DECLARATION")
DEVELOPER_DECLARATION=$(envelope assertion add pred-obj string "repositoryURL" string "https://github.com/example/project" "$DEVELOPER_DECLARATION")
DEVELOPER_DECLARATION=$(envelope assertion add pred-obj string "commitHash" string "7dd42c1be02cc53f70bfd0021d0aac15bf8e2ad5" "$DEVELOPER_DECLARATION")
DEVELOPER_DECLARATION=$(envelope assertion add pred-obj string "description" string "Add authentication module" "$DEVELOPER_DECLARATION")
DEVELOPER_DECLARATION=$(envelope assertion add pred-obj string "experience" string "5 years Node.js development" "$DEVELOPER_DECLARATION")
DEVELOPER_DECLARATION=$(envelope subject type wrapped $DEVELOPER_DECLARATION)
DEVELOPER_DECLARATION=$(envelope sign -s $DEVELOPER_XID_PRIVATE_KEYS $DEVELOPER_DECLARATION)
```

Here, the developer introduces themselves and their contribution,
revealing their XID, the specific contribution details, and relevant
experience.

### Phase 2: Wholeness *(Integrity Assessed)*

The data assets are checked for their structural integrity and completeness.

**XID Implementation:**
```sh
# Automated checks verify the structure and format of the contribution
WRAPPED_DEVELOPER_DECLARATION=$(envelope subject type wrapped "$DEVELOPER_DECLARATION")
INTEGRITY_CHECK=$(envelope subject type string "ContinuousIntegrationSystem")
INTEGRITY_CHECK=$(envelope assertion add pred-obj string "lintCheck" string "Passed - 0 errors, 2 warnings" "$INTEGRITY_CHECK")
INTEGRITY_CHECK=$(envelope assertion add pred-obj string "compilationCheck" string "Successful" "$INTEGRITY_CHECK")
INTEGRITY_CHECK=$(envelope assertion add pred-obj string "testCoverage" string "92% (meets minimum 90%)" "$INTEGRITY_CHECK")
INTEGRITY_CHECK=$(envelope assertion add pred-obj string "assessmentDate" string "2023-11-28T14:30:00Z" "$INTEGRITY_CHECK")
INTEGRITY_CHECK=$(envelope assertion add pred-obj string "assessmentBy" envelope $INTEGRITY_CHECK "$WRAPPED_DEVELOPER_DECLARATION")
```

This phase verifies that the contribution compiles, passes linting,
and has sufficient test coverage.

### Phase 3: Proofs *(Secrets Verified)*

Cryptographic secrets and other hidden information are verified.

**XID Implementation:**
```sh
# Verify cryptographic proofs of the contribution and identity
VERIFIED_CONTRIBUTION=$(envelope subject type string "RepositoryVerifier")
VERIFIED_CONTRIBUTION=$(envelope assertion add pred-obj string "commitSignatureVerified" string "Valid signature from $DEVELOPER_XID" "$VERIFIED_CONTRIBUTION")
VERIFIED_CONTRIBUTION=$(envelope assertion add pred-obj string "declarationSignatureVerified" string "Valid signature from $DEVELOPER_XID" "$VERIFIED_CONTRIBUTION")
VERIFIED_CONTRIBUTION=$(envelope assertion add pred-obj string "xidDocumentVerified" string "Valid" "$VERIFIED_CONTRIBUTION")
VERIFIED_CONTRIBUTION=$(envelope assertion add pred-obj string "verificationMethod" string "SSH ED25519 signature verification" "$VERIFIED_CONTRIBUTION")
VERIFIED_CONTRIBUTION=$(envelope assertion add pred-obj string "verificationBy" envelope $VERIFIED_CONTRIBUTION $INTEGRITY_CHECK)
```

This phase cryptographically verifies the developer's identity (via
their XID) and the authenticity of their code contribution (via commit
signature).

### Phase 4: References *(Trust Affirmed)*

Collect trust references from various sources to build a composite trust picture.

**XID Implementation:**
```sh
# Collect trust references about the contributor
TRUST_REFERENCES=$(envelope subject type string $MAINTAINER_XID)
TRUST_REFERENCES=$(envelope assertion add pred-obj string "previousContributions" string "27 accepted PRs" "$TRUST_REFERENCES")
TRUST_REFERENCES=$(envelope assertion add pred-obj string "averageCodeQuality" string "4.2/5.0 from peer reviews" "$TRUST_REFERENCES")
TRUST_REFERENCES=$(envelope assertion add pred-obj string "communityStanding" string "Active contributor since 2020" "$TRUST_REFERENCES")
TRUST_REFERENCES=$(envelope assertion add pred-obj string "codeReviewHistory" string "93% approval rate" "$TRUST_REFERENCES")
TRUST_REFERENCES=$(envelope assertion add pred-obj string "referencesCollectedBy" envelope "$TRUST_REFERENCES" $VERIFIED_CONTRIBUTION)
```

Here, the project maintainer collects references about the developer from past interactions, peer reviews, and community standing.

### Phase 5: Requirements *(Community Compliance)*

The contribution is audited against project requirements including security standards, code style, documentation, and API compatibility.

**XID Implementation:**
```sh
# Audit the contribution against project requirements
COMPLIANCE_CHECK=$(envelope subject type string "SecurityTeam")
COMPLIANCE_CHECK=$(envelope assertion add pred-obj string "securityReviewResult" string "Passed - No vulnerabilities detected" "$COMPLIANCE_CHECK")
COMPLIANCE_CHECK=$(envelope assertion add pred-obj string "codeStyleCompliance" string "Compliant with project standards" "$COMPLIANCE_CHECK")
COMPLIANCE_CHECK=$(envelope assertion add pred-obj string "documentationCompliance" string "Meets requirements - includes API docs" "$COMPLIANCE_CHECK")
COMPLIANCE_CHECK=$(envelope assertion add pred-obj string "breakingChanges" string "None - API backward compatible" "$COMPLIANCE_CHECK")
COMPLIANCE_CHECK=$(envelope assertion add pred-obj string "complianceAuditedby" envelope $COMPLIANCE_CHECK $TRUST_REFERENCES)

```

Here, the security team does a full security review of the contribution.

### Phase 6: Approval *(Risk Calculated)*

Based on all previous phases, the maintainer calculates the risk level
of the interaction, compares it to the trust score, and makes an
approval decision.

**XID Implementation:**
```sh
# Calculate risk and make approval decision
COMPLIANCE_CHECK_WRAPPED=$(envelope subject type wrapped "$COMPLIANCE_CHECK")
RISK_CALCULATION=$(envelope subject type string $MAINTAINER_XID)
RISK_CALCULATION=$(envelope assertion add pred-obj string "moduleImpact" string "Medium - Core authentication component" "$RISK_CALCULATION")
RISK_CALCULATION=$(envelope assertion add pred-obj string "trustScore" string "0.87" "$RISK_CALCULATION")
RISK_CALCULATION=$(envelope assertion add pred-obj string "riskLevel" string "Low - Sufficient tests and reviews" "$RISK_CALCULATION")
RISK_CALCULATION=$(envelope assertion add pred-obj string "approvalDecision" string "Approved for integration" "$RISK_CALCULATION")
RISK_CALCULATION=$(envelope assertion add pred-obj string "approvalDate" string "2023-11-30T09:15:00Z" "$RISK_CALCULATION")
RISK_CALCULATION=$(envelope subject type wrapped $RISK_CALCULATION)
RISK_CALCULATION=$(envelope sign -s $MAINTAINER_PRIVATE_KEYS $RISK_CALCULATION)
RISK_CALCULATION=$(envelope assertion add pred-obj string "approvedBy" envelope $RISK_CALCULATION $COMPLIANCE_CHECK_WRAPPED)
```

The repo maintainer offers initial agreement on the contribution, but a threshold of additional parties is required.

### Phase 7: Agreement *(Threshold Endorsed)* [optional]

Additional approvals are obtained to reach a required threshold.

**XID Implementation:**
```sh
# Collect additional approvals to reach threshold
THRESHOLD_APPROVAL_1=$(envelope subject type string "$SENIOR_DEV_XID")
THRESHOLD_APPROVAL_1=$(envelope assertion add pred-obj string "approval1Date" string "2023-11-30T10:20:00Z" "$THRESHOLD_APPROVAL_1")
THRESHOLD_APPROVAL_1=$(envelope subject type wrapped $THRESHOLD_APPROVAL_1)
THRESHOLD_APPROVAL_1=$(envelope sign -s $SENIOR_DEV_PRIVATE_KEYS $THRESHOLD_APPROVAL_1)
THRESHOLD_APPROVAL_2=$(envelope subject type string "$SECURITY_TEAM_XID")
THRESHOLD_APPROVAL_2=$(envelope assertion add pred-obj string "approval2Date" string "2023-11-30T11:45:00Z" "$THRESHOLD_APPROVAL_2")
THRESHOLD_APPROVAL_2=$(envelope subject type wrapped $THRESHOLD_APPROVAL_2)
THRESHOLD_APPROVAL_2=$(envelope sign -s $SECURITY_TEAM_PRIVATE_KEYS $THRESHOLD_APPROVAL_2)
THRESHOLD_APPROVAL=$(envelope subject type envelope "$RISK_CALCULATION")
THRESHOLD_APPROVAL=$(envelope assertion add pred-obj string "additionalApproval1" envelope $THRESHOLD_APPROVAL_1 $THRESHOLD_APPROVAL)
THRESHOLD_APPROVAL=$(envelope assertion add pred-obj string "additionalApproval2" envelope $THRESHOLD_APPROVAL_2 $THRESHOLD_APPROVAL)
THRESHOLD_APPROVAL=$(envelope assertion add pred-obj string "thresholdReached" string "Yes - All required approvals obtained" "$THRESHOLD_APPROVAL")
```

Here, the additional appprovals come from a senior developer and the security team.

### Phase 8: Fulfillment *(Interaction Finalized)*

The interaction is finalized according to the agreed-upon terms.

**XID Implementation:**
```sh
# Finalize the contribution
INTERACTION_FULFILLED=$(envelope subject type string "DeploymentSystem")
INTERACTION_FULFILLED=$(envelope assertion add pred-obj string "mergeStatus" string "Merged to main branch" "$INTERACTION_FULFILLED")
INTERACTION_FULFILLED=$(envelope assertion add pred-obj string "mergeCommit" string "cf37d69cea18b344d2c9e8aacc430b1d9ac0a74a" "$INTERACTION_FULFILLED")
INTERACTION_FULFILLED=$(envelope assertion add pred-obj string "deploymentStatus" string "Deployed to staging environment" "$INTERACTION_FULFILLED")
INTERACTION_FULFILLED=$(envelope assertion add pred-obj string "fulfillmentDate" string "2023-12-01T08:30:00Z" "$INTERACTION_FULFILLED")
WRAPPED_THRESHOLD_APPROVAL=$(envelope subject type wrapped $THRESHOLD_APPROVAL)
INTERACTION_FULFILLED=$(envelope assertion add pred-obj string "finalizedBy" envelope $INTERACTION_FULFILLED $WRAPPED_THRESHOLD_APPROVAL)
```

The code contribution is merged and deployed, finalizing the interaction.

### Phase 9: Escalation *(Independently Inspected)* [optional]

A third party inspects and potentially endorses the interaction.

**XID Implementation:**
```sh
# Independent security audit of the deployed code
INDEPENDENT_INSPECTION=$(envelope subject type string "SecureCode Auditors")
INDEPENDENT_INSPECTION=$(envelope assertion add pred-obj string "auditDate" string "2023-12-05T14:00:00Z" "$INDEPENDENT_INSPECTION")
INDEPENDENT_INSPECTION=$(envelope assertion add pred-obj string "auditScope" string "Authentication module security review" "$INDEPENDENT_INSPECTION")
INDEPENDENT_INSPECTION=$(envelope assertion add pred-obj string "auditResult" string "Passed - No critical or high vulnerabilities" "$INDEPENDENT_INSPECTION")
INDEPENDENT_INSPECTION=$(envelope assertion add pred-obj string "auditReport" string "sha256:7d8f9a234c9b67531d5f8b3a1b5d9c7e9a6b7c8d" "$INDEPENDENT_INSPECTION")
INDEPENDENT_INSPECTION=$(envelope assertion add pred-obj string "auditedBy" envelope $INDEPENDENT_INSPECTION $INTERACTION_FULFILLED)
```

An independent security firm audits the deployed code, providing additional assurance about its quality and security.

### Phase 10: Dispute *(Independently Arbitrated)* [optional]

If something goes wrong, a dispute process resolves issues through independent arbitration.

**XID Implementation:**
```sh
# Handle a security vulnerability discovered after deployment
DISPUTE_RESOLUTION=$(envelope subject type wrapped "$INDEPENDENT_INSPECTION")
DISPUTE_RESOLUTION=$(envelope assertion add pred-obj string "disputeRaised" string "Security vulnerability CVE-2023-98765" "$DISPUTE_RESOLUTION")
DISPUTE_RESOLUTION=$(envelope assertion add pred-obj string "disputeDate" string "2023-12-10T09:30:00Z" "$DISPUTE_RESOLUTION")
DISPUTE_RESOLUTION=$(envelope assertion add pred-obj string "raisedBy" string "SecurityResearcher" "$DISPUTE_RESOLUTION")
DISPUTE_RESOLUTION=$(envelope assertion add pred-obj string "vulnerabilityDetails" string "Authentication bypass in edge case" "$DISPUTE_RESOLUTION")
DISPUTE_RESOLUTION=$(envelope assertion add pred-obj string "arbitrator" string "OpenSourceSecurityCommittee" "$DISPUTE_RESOLUTION")
DISPUTE_RESOLUTION=$(envelope assertion add pred-obj string "resolution" string "Developer acknowledged and fixed issue within 24 hours" "$DISPUTE_RESOLUTION")
DISPUTE_RESOLUTION=$(envelope assertion add pred-obj string "trustImpact" string "Minimal - Prompt and transparent response" "$DISPUTE_RESOLUTION")
```

When a vulnerability is discovered, the dispute resolution process
documents the issue, assigns responsibility, and tracks the
resolution, including the impact on trust.

This is what the full envelope depicting the progressive trust looks like at the end:
```
{
    {
        {
            {
                {
                    "Code Contribution #PR-123" [
                        "commitHash": "7dd42c1be02cc53f70bfd0021d0aac15bf8e2ad5"
                        "contributor": "ur:xid/hdcxislndylonensmnfgaebbtpvapkhesoplykjslfaslspejshlytctcadncmtstddimnpamsie"
                        "description": "Add authentication module"
                        "experience": "5 years Node.js development"
                        "repositoryURL": "https://github.com/example/project"
                    ]
                } [
                    'signed': Signature
                ]
            } [
                "assessmentBy": "ContinuousIntegrationSystem" [
                    "assessmentDate": "2023-11-28T14:30:00Z"
                    "compilationCheck": "Successful"
                    "lintCheck": "Passed - 0 errors, 2 warnings"
                    "testCoverage": "92% (meets minimum 90%)"
                ]
                "complianceAuditedby": "SecurityTeam" [
                    "breakingChanges": "None - API backward compatible"
                    "codeStyleCompliance": "Compliant with project standards"
                    "documentationCompliance": "Meets requirements - includes API docs"
                    "securityReviewResult": "Passed - No vulnerabilities detected"
                ]
                "referencesCollectedBy": "ur:xid/hdcxbwkicsvsyloysacwmdckhhfyjkguzolateotwnnyneoyrtflyapaknfznevtnnfsrddpayly" [
                    "averageCodeQuality": "4.2/5.0 from peer reviews"
                    "codeReviewHistory": "93% approval rate"
                    "communityStanding": "Active contributor since 2020"
                    "previousContributions": "27 accepted PRs"
                ]
                "verificationBy": "RepositoryVerifier" [
                    "commitSignatureVerified": "Valid signature from ur:xid/hdcxislndylonensmnfgaebbtpvapkhesoplykjslfaslspejshlytctcadncmtstddimnpamsie"
                    "declarationSignatureVerified": "Valid signature from ur:xid/hdcxislndylonensmnfgaebbtpvapkhesoplykjslfaslspejshlytctcadncmtstddimnpamsie"
                    "verificationMethod": "SSH ED25519 signature verification"
                    "xidDocumentVerified": "Valid"
                ]
            ]
        } [
            "additionalApproval1": {
                "ur:xid/hdcxjlhtiamnfwoyntcadnemspctmsbdlbwzwzkgimemwpwsmdqzgocpcxykjtstceweqzinbytp" [
                    "approval1Date": "2023-11-30T10:20:00Z"
                ]
            } [
                'signed': Signature
            ]
            "additionalApproval2": {
                "ur:xid/hdcxvthsimhhpfdmfmpkensfstiegsfsbbmhlblflkfsprgwtbmefyzcuohtbzbshdurtyplrtfg" [
                    "approval2Date": "2023-11-30T11:45:00Z"
                ]
            } [
                'signed': Signature
            ]
            "approvedBy": {
                "ur:xid/hdcxbwkicsvsyloysacwmdckhhfyjkguzolateotwnnyneoyrtflyapaknfznevtnnfsrddpayly" [
                    "approvalDate": "2023-11-30T09:15:00Z"
                    "approvalDecision": "Approved for integration"
                    "moduleImpact": "Medium - Core authentication component"
                    "riskLevel": "Low - Sufficient tests and reviews"
                    "trustScore": "0.87"
                ]
            } [
                'signed': Signature
            ]
            "thresholdReached": "Yes - All required approvals obtained"
        ]
    } [
        "auditedBy": "SecureCode Auditors" [
            "auditDate": "2023-12-05T14:00:00Z"
            "auditReport": "sha256:7d8f9a234c9b67531d5f8b3a1b5d9c7e9a6b7c8d"
            "auditResult": "Passed - No critical or high vulnerabilities"
            "auditScope": "Authentication module security review"
        ]
        "finalizedBy": "DeploymentSystem" [
            "deploymentStatus": "Deployed to staging environment"
            "fulfillmentDate": "2023-12-01T08:30:00Z"
            "mergeCommit": "cf37d69cea18b344d2c9e8aacc430b1d9ac0a74a"
            "mergeStatus": "Merged to main branch"
        ]
    ]
} [
    "arbitrator": "OpenSourceSecurityCommittee"
    "disputeDate": "2023-12-10T09:30:00Z"
    "disputeRaised": "Security vulnerability CVE-2023-98765"
    "raisedBy": "SecurityResearcher"
    "resolution": "Developer acknowledged and fixed issue within 24 hours"
    "trustImpact": "Minimal - Prompt and transparent response"
    "vulnerabilityDetails": "Authentication bypass in edge case"
]
```

(There might be more signatures in a real-life case, but here they're restricted to the most crucial sign-offs, done with XIDs.)

## Conclusion

Progressive trust using XIDs enables a more human-centered approach to
digital trust that evolves gradually, considers context, and supports
nuanced trust decisions rather than binary choices.

By implementing the Progressive Trust Life Cycle with XIDs and Gordian
Envelope, we can create digital systems that better reflect how trust
works in the real world&mdash;as a gradual, evidence-based process that
exists in shades of gray rather than black and white.

## Check Your Understanding

1. How does progressive trust differ from traditional binary trust models?
2. What are the key phases in the Progressive Trust Life Cycle?
3. How can trust evolve across different contexts in a network of XIDs?
4. What role does selective disclosure play in progressive trust?
5. How do XIDs support progressive trust relationships?

## Next Steps

- Review [XID Fundamentals](xid-fundamentals.md) for the foundational technologies
- Read about [Fair Witness Approach](fair-witness-approach.md) to see how it implements many progressive trust concepts
- Explore [Pseudonymous Trust Building](pseudonymous-trust-building.md) for examples of progressive trust in action
- Try the [Self-Attestation Tutorial](../tutorials/03-self-attestation-with-xids.md) for hands-on implementation
