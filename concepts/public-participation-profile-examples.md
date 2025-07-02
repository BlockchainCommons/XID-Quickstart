# Public Participation Profile Examples

⚠️ _This documentation has not been fully checked and proofed like the rest of the core concepts. Please see the main [Public Participation Profiles article](public-participation-profiles.md) article for this content, as the examples in this addendum may not work._

## Expected Learning Outcomes
By the end of this document, you will:
- Understand how to implement practical participation profiles using XIDs and Gordian Envelopes
- See concrete examples of profiles for different trust levels and contexts
- Learn how to create context-specific views through selective disclosure
- Connect these examples to the implementations in the tutorials
- Access a comprehensive taxonomy of assertion types for different contexts

## Introduction

This document provides practical examples of public participation profiles using XIDs, serving as a companion to the [Public Participation Profiles](public-participation-profiles.md) concept. These examples demonstrate how to balance the fundamental tension between privacy needs and contribution desires, enabling meaningful participation while protecting identity.

The examples are aligned with Amira's scenario throughout the tutorials, particularly her work on Ben's women's safety application. They show concrete implementations of the progressive trust approach described in [Progressive Trust Life Cycle](progressive-trust-lifecycle.md).

## Practical XID Implementation Examples

The following examples show how to implement participation profiles using XIDs and Gordian Envelopes, demonstrating patterns you can adapt for your own use cases.

### Example 1: BWHacker's Initial Profile

This minimal profile establishes Amira's initial presence as BWHacker:

```sh
# Create Amira's initial pseudonymous identity
AMIRA_XID=$(envelope xid new --name "BWHacker" "$PUBLIC_KEY")

# Add basic non-identifying information
AMIRA_XID=$(envelope assertion add pred-obj string "domain" string "Distributed Systems & Security" "$AMIRA_XID")
AMIRA_XID=$(envelope assertion add pred-obj string "purpose" string "Contributing to privacy-preserving systems that protect vulnerable populations" "$AMIRA_XID")
AMIRA_XID=$(envelope assertion add pred-obj string "values" string "Privacy as a human right, user agency, ethical data use" "$AMIRA_XID")

# Technical skill declarations
SKILLS=$(envelope subject type string "TechnicalSkills")
SKILLS=$(envelope assertion add pred-obj string "mobileDevelopment" string "Mobile application development with security focus" "$SKILLS")
SKILLS=$(envelope assertion add pred-obj string "apiSecurity" string "Secure API implementation and authentication systems" "$SKILLS")
AMIRA_XID=$(envelope assertion add pred-obj string "skills" envelope "$SKILLS" "$AMIRA_XID")

# Initial evidence commitment (without revealing the evidence)
EVIDENCE="Implemented secure authentication system with privacy-preserving features"
EVIDENCE_HASH=$(echo "$EVIDENCE" | envelope digest sha256)
AMIRA_XID=$(envelope assertion add pred-obj string "evidenceCommitment" digest "$EVIDENCE_HASH" "$AMIRA_XID")
```

This example shows how Amira can create her initial BWHacker identity with:
- A stable identifier using her key pair
- General technical domain information
- Purpose and values statements aligned with Ben's women's safety app
- Technical skills relevant to the project
- An evidence commitment that can be selectively revealed later

At this initial stage, the profile contains minimal privacy risk while establishing basic credibility.

### Example 2: BWHacker's Women's Safety App Developer Profile

This expanded profile shows Amira's identity as it evolves for Ben's women's safety application:

```sh
# Start with the basic profile and expand it for the women's safety context
SAFETY_PROFILE=$(envelope subject type envelope "$AMIRA_XID")

# Add safety-specific technical skills
SAFETY_SKILLS=$(envelope subject type string "SafetyAppSkills")
SAFETY_SKILLS=$(envelope assertion add pred-obj string "locationPrivacy" string "Privacy-preserving location sharing with minimal data exposure" "$SAFETY_SKILLS")
SAFETY_SKILLS=$(envelope assertion add pred-obj string "emergencyFeatures" string "Reliable emergency alert mechanisms with offline capability" "$SAFETY_SKILLS")
SAFETY_SKILLS=$(envelope assertion add pred-obj string "threatModeling" string "Threat modeling for safety applications protecting vulnerable users" "$SAFETY_SKILLS")
SAFETY_PROFILE=$(envelope assertion add pred-obj string "safetyAppSkills" envelope "$SAFETY_SKILLS" "$SAFETY_PROFILE")

# Add safety-focused principles
PRINCIPLES=$(envelope subject type string "SafetyPrinciples")
PRINCIPLES=$(envelope assertion add pred-obj string "userControl" string "Users maintain full control of their information and sharing" "$PRINCIPLES")
PRINCIPLES=$(envelope assertion add pred-obj string "minimumExposure" string "Minimize data collection and sharing while preserving essential functionality" "$PRINCIPLES")
PRINCIPLES=$(envelope assertion add pred-obj string "resilience" string "System functions in adverse conditions like network unavailability" "$PRINCIPLES")
SAFETY_PROFILE=$(envelope assertion add pred-obj string "safetyPrinciples" envelope "$PRINCIPLES" "$SAFETY_PROFILE")

# Implementation examples (without identifying details)
IMPLEMENTATIONS=$(envelope subject type string "SafetyImplementations")
IMPLEMENTATIONS=$(envelope assertion add pred-obj string "locationSystem" string "Location system that only shares data during emergency situations" "$IMPLEMENTATIONS")
IMPLEMENTATIONS=$(envelope assertion add pred-obj string "offlineAlert" string "Emergency alert that works without internet connectivity" "$IMPLEMENTATIONS")
IMPLEMENTATIONS=$(envelope assertion add pred-obj string "secureStorage" string "Encrypted local storage with secure authentication" "$IMPLEMENTATIONS")
SAFETY_PROFILE=$(envelope assertion add pred-obj string "implementations" envelope "$IMPLEMENTATIONS" "$SAFETY_PROFILE")

# Add Charlene's endorsement
CHARLENE_ENDORSEMENT=$(envelope subject type string "PeerEndorsement")
CHARLENE_ENDORSEMENT=$(envelope assertion add pred-obj string "endorser" string "CharlieOne" "$CHARLENE_ENDORSEMENT")
CHARLENE_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsementDate" string "2023-06-15" "$CHARLENE_ENDORSEMENT")
CHARLENE_ENDORSEMENT=$(envelope assertion add pred-obj string "skill" string "Mobile Security Architecture" "$CHARLENE_ENDORSEMENT")
CHARLENE_ENDORSEMENT=$(envelope assertion add pred-obj string "observation" string "Demonstrated exceptional understanding of security for mobile applications" "$CHARLENE_ENDORSEMENT")
CHARLENE_ENDORSEMENT=$(envelope assertion add pred-obj string "context" string "Collaborative work on privacy-focused features" "$CHARLENE_ENDORSEMENT")
CHARLENE_ENDORSEMENT=$(envelope assertion add pred-obj string "basis" string "Direct collaboration on shared projects" "$CHARLENE_ENDORSEMENT")

# Sign the endorsement with Charlene's key
SIGNED_ENDORSEMENT=$(envelope sign -s "$CHARLENE_PRIVATE_KEY" "$CHARLENE_ENDORSEMENT")
SAFETY_PROFILE=$(envelope assertion add pred-obj string "endorsement" envelope "$SIGNED_ENDORSEMENT" "$SAFETY_PROFILE")
```

This example shows how Amira can develop a more specialized profile for the women's safety application context:
- Safety-specific technical skills relevant to Ben's project
- Security and privacy principles for safety applications
- Implementation examples focused on the women's safety context
- A peer endorsement from Charlene that validates her skills
  
This profile provides Ben with the specific trust signals needed for the safety application without compromising Amira's privacy.

### Example 3: Context-Specific Profile Views

This example shows how Amira can create different views of her profile for different contexts:

```sh
# Starting with the full safety app profile
FULL_PROFILE=$(envelope subject type envelope "$SAFETY_PROFILE")

# Create a public view for initial engagement
PUBLIC_VIEW=$(envelope subject type envelope "$FULL_PROFILE")
PUBLIC_VIEW=$(envelope elide assertion predicate string "locationHistory" "$PUBLIC_VIEW" 1)
PUBLIC_VIEW=$(envelope elide assertion predicate string "communicationPreferences" "$PUBLIC_VIEW" 1)
PUBLIC_VIEW=$(envelope elide assertion predicate string "endorsement" "$PUBLIC_VIEW" 1)

# Create a project maintainer view for Ben
MAINTAINER_VIEW=$(envelope subject type envelope "$FULL_PROFILE")
MAINTAINER_VIEW=$(envelope elide assertion predicate string "locationHistory" "$MAINTAINER_VIEW" 1)

# Create a security collaboration view for working on sensitive features
SECURITY_VIEW=$(envelope subject type envelope "$FULL_PROFILE")
SECURITY_VIEW=$(envelope elide assertion predicate string "locationHistory" "$SECURITY_VIEW" 1)

# Sign different views with appropriate timestamps
SIGNED_PUBLIC_VIEW=$(envelope sign -s "$AMIRA_PRIVATE_KEY" "$PUBLIC_VIEW")
SIGNED_MAINTAINER_VIEW=$(envelope sign -s "$AMIRA_PRIVATE_KEY" "$MAINTAINER_VIEW")
SIGNED_SECURITY_VIEW=$(envelope sign -s "$AMIRA_PRIVATE_KEY" "$SECURITY_VIEW")
```

This example demonstrates how Amira can create tailored views of her profile:
- A public view for initial engagement with minimal information
- A project maintainer view with more detail for Ben as their trust develops
- A security collaboration view that includes sensitive skill information for working on critical features

Through selective disclosure using Gordian Envelope's elision capabilities, Amira maintains control over what information is revealed in each context while providing appropriate trust signals.

### Example 4: Progressive Trust Development

This example shows how Amira's profile evolves through different trust levels:

```sh
# Initial contact - minimal profile
INITIAL_PROFILE=$(envelope subject type string "BWHacker")
INITIAL_PROFILE=$(envelope assertion add pred-obj string "name" string "BWHacker" "$INITIAL_PROFILE")
INITIAL_PROFILE=$(envelope assertion add pred-obj string "domain" string "Mobile Security" "$INITIAL_PROFILE")
INITIAL_PROFILE=$(envelope assertion add pred-obj string "purpose" string "Contributing to privacy-focused applications" "$INITIAL_PROFILE")

# Regular contributor - expanded profile with evidence
REGULAR_PROFILE=$(envelope subject type envelope "$INITIAL_PROFILE")
REGULAR_PROFILE=$(envelope assertion add pred-obj string "experienceLevel" string "5+ years of development experience" "$REGULAR_PROFILE")
REGULAR_PROFILE=$(envelope assertion add pred-obj string "technicalSkills" string "Mobile security, privacy-preserving design, API security" "$REGULAR_PROFILE")

# Add implementation examples
EXAMPLES=$(envelope subject type string "ImplementationExamples")
EXAMPLES=$(envelope assertion add pred-obj string "secureStorage" string "Encrypted local storage system with offline authentication" "$EXAMPLES")
EXAMPLES=$(envelope assertion add pred-obj string "locationPrivacy" string "Privacy-preserving location sharing with minimal data collection" "$EXAMPLES")
REGULAR_PROFILE=$(envelope assertion add pred-obj string "examples" envelope "$EXAMPLES" "$REGULAR_PROFILE")

# Trusted contributor - with peer endorsements and deeper expertise
TRUSTED_PROFILE=$(envelope subject type envelope "$REGULAR_PROFILE")

# Add Carlos's endorsement (from Tutorial 4)
CARLOS_ENDORSEMENT=$(envelope subject type string "PeerEndorsement")
CARLOS_ENDORSEMENT=$(envelope assertion add pred-obj string "endorser" string "Carlos_SecResearcher" "$CARLOS_ENDORSEMENT")
CARLOS_ENDORSEMENT=$(envelope assertion add pred-obj string "projectName" string "Privacy-First Safety Alert System" "$CARLOS_ENDORSEMENT")
CARLOS_ENDORSEMENT=$(envelope assertion add pred-obj string "endorsedSkill" string "Privacy-preserving location tracking" "$CARLOS_ENDORSEMENT")
CARLOS_ENDORSEMENT=$(envelope assertion add pred-obj string "observation" string "Implemented privacy-preserving location tracking that minimizes data exposure risk" "$CARLOS_ENDORSEMENT")
SIGNED_CARLOS_ENDORSEMENT=$(envelope sign -s "$CARLOS_PRIVATE_KEY" "$CARLOS_ENDORSEMENT")

# Add Maya's code review endorsement (from Tutorial 4)
MAYA_ENDORSEMENT=$(envelope subject type string "CodeReviewEndorsement")
MAYA_ENDORSEMENT=$(envelope assertion add pred-obj string "endorser" string "MayaCodeX" "$MAYA_ENDORSEMENT")
MAYA_ENDORSEMENT=$(envelope assertion add pred-obj string "repositoryURL" string "https://github.com/example/safety-location-privacy" "$MAYA_ENDORSEMENT")
MAYA_ENDORSEMENT=$(envelope assertion add pred-obj string "assessment" string "Excellent: Optimized location privacy algorithm with minimal battery impact" "$MAYA_ENDORSEMENT")
SIGNED_MAYA_ENDORSEMENT=$(envelope sign -s "$MAYA_PRIVATE_KEY" "$MAYA_ENDORSEMENT")

# Add endorsements to trusted profile
TRUSTED_PROFILE=$(envelope assertion add pred-obj string "endorsement" envelope "$SIGNED_CARLOS_ENDORSEMENT" "$TRUSTED_PROFILE")
TRUSTED_PROFILE=$(envelope assertion add pred-obj string "endorsement" envelope "$SIGNED_MAYA_ENDORSEMENT" "$TRUSTED_PROFILE")

# Add specialized security expertise for women's safety applications
SECURITY_EXPERTISE=$(envelope subject type string "SafetySecurityExpertise")
SECURITY_EXPERTISE=$(envelope assertion add pred-obj string "threatModeling" string "Comprehensive threat modeling for women's safety applications" "$SECURITY_EXPERTISE")
SECURITY_EXPERTISE=$(envelope assertion add pred-obj string "adversarialTesting" string "Testing features against realistic adversarial scenarios" "$SECURITY_EXPERTISE")
TRUSTED_PROFILE=$(envelope assertion add pred-obj string "securityExpertise" envelope "$SECURITY_EXPERTISE" "$TRUSTED_PROFILE")
```

This example demonstrates how Amira's profile evolves through the progressive trust life cycle:
- Initial contact stage with minimal information
- Regular contributor stage with more skills and examples
- Trusted contributor stage with peer endorsements and deeper expertise

The profile builds trust gradually while maintaining privacy protection throughout, showing how Amira can engage more deeply with Ben's project as trust develops.

## Connection to Tutorials

These examples directly connect to the implementations in the tutorials:

### Connection to Tutorial 1: Your First XID

In [Tutorial 1](../tutorials/01-your-first-xid.md), Amira creates her first XID as BWHacker, establishing her pseudonymous identity. The implementation follows a similar pattern to the initial profile example:

```sh
# In Tutorial 1, Amira creates her initial XID
envelope xid new --name "BWHacker" "$AMIRA_PUBLIC" > amira-xid.envelope
```

The BWHacker profile created in Tutorial 1 serves as the foundation for Amira's pseudonymous participation with Ben's project.

### Connection to Tutorial 3: Self-Attestation with XIDs

In [Tutorial 3](../tutorials/03-self-attestation-with-xids.md), Amira expands her profile with self-attestations about her skills and experience, similar to the "Regular Contributor" example:

```sh
# In Tutorial 3, Amira adds skills and project experience
PROJECT=$(envelope subject type string "Privacy-Focused Safety App")
PROJECT=$(envelope assertion add pred-obj string "role" string "Security & Privacy Engineer" "$PROJECT")
PROJECT=$(envelope assertion add pred-obj string "timeframe" string "2022-01 through 2022-06" "$PROJECT")
PROJECT=$(envelope assertion add pred-obj string "client" string "Nonprofit organization (details available after NDA)" "$PROJECT")
```

The self-attestations in Tutorial 3 follow the patterns shown in the Technical Competence and Public Interest sections of the taxonomy, focusing on skills relevant to the women's safety application.

### Connection to Tutorial 4: Peer Endorsement with XIDs

In [Tutorial 4](../tutorials/04-peer-endorsement-with-xids.md), Amira's profile evolves to include peer endorsements, just as shown in the "Trusted Contributor" example:

```sh
# In Tutorial 4, peers endorse Amira's skills
COLLABORATION_ENDORSEMENT=$(envelope assertion add pred-obj string "projectName" string "Privacy-First Safety Alert System" "$COLLABORATION_ENDORSEMENT")
COLLABORATION_ENDORSEMENT=$(envelope assertion add pred-obj string "repositoryURL" string "https://github.com/example/privacy-alert-system" "$COLLABORATION_ENDORSEMENT")
COLLABORATION_ENDORSEMENT=$(envelope assertion add pred-obj string "collaborationContext" string "Joint development of privacy-preserving location features for a women's safety app" "$COLLABORATION_ENDORSEMENT")
```

The peer endorsement model in Tutorial 4 implements the Peer-Endorsed Skills section of the taxonomy, showing how third-party attestations strengthen BWHacker's credibility for Ben's project.

## Comprehensive Assertion Taxonomy

The following tables provide a complete reference taxonomy of assertion types for different contexts and trust levels. These can be used as a foundation for designing your own participation profiles.

### 1. Technical Competence Assertions

#### Self-Attestable Technical Skills (Low Privacy Risk)

| Assertion Type | Example Content | Verification Method | Privacy Protection | Appropriate Trust Level |
|----------------|-----------------|---------------------|-------------------|-------------------------|
| **Test-Driven Developer** | "I write code using test-first methodology" | PR with commit history showing failing → passing tests | Use project's testing framework, avoid personal patterns | Initial Contributor |
| **Modular Code Contributor** | "I write reusable, modular components" | Commits with well-factored structure and interfaces | Create new implementations, don't reuse personal patterns | Regular Contributor |
| **Refactoring Contributor** | "I improve code structure without changing behavior" | Before/after diffs showing cleaner implementation | Focus on project standards, avoid personal style markers | Regular Contributor |
| **Complex Algorithm Implementer** | "I implemented a non-trivial distributed consensus algorithm" | Algorithm implementation with correctness proofs | Use standard algorithm patterns, no personal optimizations | Trusted Contributor |
| **State Management Contributor** | "I designed efficient state management for concurrent access" | Architecture diagram and implementation | Use project-specific patterns, minimal external references | Trusted Contributor |
| **Code Optimization Achiever** | "I improved API performance by 60% for critical endpoints" | Benchmarks, profiling reports, optimized code | Use standardized benchmarking, avoid custom tools | Regular Contributor |
| **CLI Tool Developer** | "I built a command-line utility for developers" | CLI tool with documentation and test suite | Create project-specific tool, no personal CLI patterns | Regular Contributor |
| **Static Typing Adopter** | "I added type definitions to improve code safety" | Commits showing type annotations and safety improvements | Follow project's type conventions, avoid personal style | Initial Contributor |
| **Frontend Component Developer** | "I created a reusable component library" | Component documentation, demos, and tests | Use project design system, no personal component patterns | Regular Contributor |
| **Backend API Designer** | "I designed RESTful APIs following best practices" | API specification, implementation, and tests | Follow project API conventions, avoid personal standards | Trusted Contributor |

#### Peer-Endorsed Technical Skills (Medium Privacy Risk)

| Assertion Type | Example Content | Endorser Type | Evidence Required | Privacy Protection | Appropriate Trust Level |
|----------------|-----------------|---------------|-------------------|-------------------|-------------------------|
| **Testing & QA Contributor** | "Contributor significantly improved our test coverage" | Peer reviewer or QA lead | Test coverage metrics, bug prevention evidence | Endorsement cites only public PRs, no discussion context | Regular Contributor |
| **Security Contributor** | "Identified and fixed critical authentication vulnerability" | Security team member | Security fix PRs, vulnerability details | Redactable disclosure of vulnerability details | Trusted Contributor |
| **Release Manager** | "Successfully coordinated complex release with multiple dependencies" | Release team or maintainer | Release plans, coordination threads | References only public release artifacts | Core Contributor |
| **Code Review Skill** | "Provides insightful, constructive code review feedback" | Developers who received reviews | Code review threads showing impact | Cites only public review comments | Regular Contributor |
| **Design Thinking in Code** | "Delivered elegant solutions to complex architectural challenges" | Architecture team member | Architecture discussions, implementations | References only public design documents | Trusted Contributor |
| **System Design Contributor** | "Designed scalable system that handled 10x traffic increase" | Senior developer or architect | System design docs, performance metrics | Focus on technical decisions, not context | Core Contributor |
| **Interoperability Contributor** | "Improved cross-platform compatibility for critical components" | Integration team member | Compatibility fixes, test matrices | Reference only public APIs and standards | Trusted Contributor |
| **Performance Optimizer** | "Reduced database load by 70% through query optimization" | Performance team or DBA | Performance metrics, optimization PRs | Use generic database examples, no schema details | Trusted Contributor |
| **Accessibility Advocate** | "Ensured all interfaces meet WCAG AA standards" | Accessibility team or user | Accessibility audit results, improvements | Reference only public UI components | Regular Contributor |
| **API Usability Improver** | "Redesigned API that significantly improved developer experience" | API consumers or team lead | Before/after API design, developer feedback | Reference only public API documentation | Trusted Contributor |

### 2. Collaboration and Community Assertions

#### Self-Attestable Collaboration Skills (Low Privacy Risk)

| Assertion Type | Example Content | Verification Method | Privacy Protection | Appropriate Trust Level |
|----------------|-----------------|---------------------|-------------------|-------------------------|
| **Documentation Author** | "I create clear, comprehensive documentation" | Documentation PRs, technical writing samples | Focus on project-specific concepts only | Initial Contributor |
| **Responsive Communicator** | "I communicate clearly across time zones" | Issue/PR response patterns, comment quality | Use only public threads, no private chats | Regular Contributor |
| **Meeting Participant** | "I contribute constructively to team discussions" | Meeting summaries, action items completed | Reference only public meetings, no recordings | Regular Contributor |
| **User Perspective Advocate** | "I consider diverse user needs in feature design" | Feature proposals with user perspective analysis | Use generic personas, no specific user data | Trusted Contributor |
| **Mentorship Provider** | "I help onboard new contributors effectively" | Onboarding guides, mentee progress | Anonymize mentee details, focus on process | Trusted Contributor |
| **Feedback Integrator** | "I incorporate feedback effectively to improve work" | Before/after examples showing feedback integration | Reference only public feedback threads | Regular Contributor |
| **Cross-functional Collaborator** | "I work effectively with design, product, and engineering teams" | Cross-functional feature implementations | Focus on technical interfaces, not team dynamics | Trusted Contributor |
| **Remote Collaboration Expert** | "I maintain productive asynchronous workflows" | Async communication patterns, documentation | Use only public threads, no private contexts | Regular Contributor |
| **Technical Writer** | "I translate complex concepts for different audiences" | Technical docs, tutorials, user guides | Use only project-specific examples | Regular Contributor |
| **Community Resource Creator** | "I develop resources to help the community succeed" | Training materials, starter templates, guides | Focus on public-facing resources only | Trusted Contributor |

#### Peer-Endorsed Collaboration Skills (Medium Privacy Risk)

| Assertion Type | Example Content | Endorser Type | Evidence Required | Privacy Protection | Appropriate Trust Level |
|----------------|-----------------|---------------|-------------------|-------------------|-------------------------|
| **Asynchronous Collaborator** | "Effectively communicates and coordinates across time zones" | Remote team member | Communication threads, coordination examples | Reference only public channels, no private chats | Regular Contributor |
| **Constructive Disagreement** | "Navigates technical debates with respect and focus on solutions" | Peer in technical discussions | Discussion threads showing conflict resolution | Reference only public debates, not heated moments | Trusted Contributor |
| **Onboarding Supporter** | "Consistently helps new contributors succeed in the project" | Mentored contributor | Onboarding materials, successful first PRs | Anonymize mentee details when possible | Regular Contributor |
| **Community Facilitator** | "Helps run events and discussions that strengthen community" | Event participants or co-hosts | Event summaries, participant feedback | Focus on format and content, not participants | Core Contributor |
| **Inclusive Contributor** | "Makes the project more welcoming to diverse contributors" | New community members | Inclusive documentation, code of conduct work | Reference only public inclusion initiatives | Trusted Contributor |
| **Cross-Project Collaborator** | "Effectively aligns work across related open source projects" | Contributor from other project | Joint issues, shared specifications | Focus on technical alignment, not relationships | Core Contributor |
| **Meeting Facilitator** | "Runs effective meetings that respect people's time" | Meeting participants | Meeting notes, action outcomes | Reference meeting format, not specific discussions | Trusted Contributor |
| **Feedback Champion** | "Provides actionable feedback that helps others improve" | Feedback recipients | Review comments, improvement outcomes | Cite only public feedback examples | Regular Contributor |
| **Conflict Resolver** | "Helps resolve tension and miscommunication constructively" | Conflict participants | Resolution threads, retrospective notes | Highly redacted to protect all parties | Trusted Contributor |
| **Recognition Giver** | "Actively acknowledges others' contributions and strengthens culture" | Recognition recipients | Recognition patterns, community impact | Focus on public recognition only | Regular Contributor |

### 3. Public Interest and Ethics Assertions

#### Self-Attestable Public Interest Commitments (Medium Privacy Risk)

| Assertion Type | Example Content | Verification Method | Privacy Protection | Appropriate Trust Level |
|----------------|-----------------|---------------------|-------------------|-------------------------|
| **Privacy Advocate** | "I design systems that protect user privacy by default" | Privacy-by-design implementations | Use general privacy principles, avoid personal philosophy | Trusted Contributor |
| **Ethical Technology Proponent** | "I consider ethical implications of design decisions" | Feature analysis with ethical considerations | Use established ethical frameworks, not personal views | Trusted Contributor |
| **Digital Rights Supporter** | "I build systems respecting user agency and control" | User control implementations, consent flows | Reference public digital rights frameworks | Trusted Contributor |
| **Accessible Design Practitioner** | "I ensure technology works for people with disabilities" | Accessibility implementations, WCAG compliance | Use standard accessibility guidelines only | Regular Contributor |
| **Security Mindset Practitioner** | "I anticipate and mitigate security risks proactively" | Threat models, security-focused implementations | Use standard security frameworks, no personal techniques | Trusted Contributor |
| **Transparent System Designer** | "I create systems that are explainable and auditable" | Transparency features, system documentation | Focus on technical transparency, not motivations | Trusted Contributor |
| **Ethical Data Use Advocate** | "I implement responsible data practices" | Data minimization examples, anonymization techniques | Use standard data ethics frameworks | Core Contributor |
| **Inclusive Feature Designer** | "I design features considering diverse global contexts" | Internationalization support, cultural considerations | Use public internationalization standards | Trusted Contributor |
| **Environmental Impact Considerer** | "I optimize for computational efficiency" | Resource usage optimizations, efficiency metrics | Use standard efficiency metrics only | Regular Contributor |
| **Public Good Prioritizer** | "I focus on features with broad social benefit" | Feature prioritization with public benefit analysis | Use established public good frameworks | Core Contributor |

#### Peer-Endorsed Ethics and Public Interest (High Privacy Risk)

| Assertion Type | Example Content | Endorser Type | Evidence Required | Privacy Protection | Appropriate Trust Level |
|----------------|-----------------|---------------|-------------------|-------------------|-------------------------|
| **Civic Technologist** | "Develops public interest technology with focus on citizen empowerment" | Public interest organization | Civic tech contributions, public good impact | Focus on technical contributions, not affiliations | Core Contributor |
| **Privacy Advocate** | "Consistently enhances privacy protections in system design" | Privacy researcher or reviewer | Privacy-enhancing features, data protection analysis | Reference standard privacy frameworks, not philosophy | Trusted Contributor |
| **Open Access Promoter** | "Makes knowledge and tools more accessible to underserved groups" | Community organizer or educator | Documentation, translations, accessibility features | Focus on technical contributions, not personal mission | Trusted Contributor |
| **Ethical Technologist** | "Applies ethical frameworks to technology decisions" | Ethics reviewer or governance member | Design decisions with ethical analysis, value trade-offs | Use established ethical frameworks, not personal stances | Core Contributor |
| **Civic Steward** | "Participates constructively in project governance" | Governance participant or lead | Governance proposals, voting record | Highly redacted to protect voting patterns | Core Contributor |
| **Ethical Commitment Signatory** | "Upholds project's ethical standards in all contributions" | Ethics committee or project lead | Code of conduct adherence, ethical decision making | Reference only public ethical commitments | Trusted Contributor |
| **Knowledge Transfer Agent** | "Makes complex knowledge accessible to diverse audiences" | Learners or educational peers | Learning materials, knowledge sharing threads | Focus on content quality, not teaching style | Regular Contributor |
| **Watchdog or Whistleblower** | "Identified and responsibly disclosed potential misuse concerns" | Community investigator or governance | Issue reports, disclosure documentation | Highly redacted or zero-knowledge proof | Core Contributor |
| **Infrastructure Maintainer** | "Sustains critical but underrecognized public infrastructure" | Downstream users or integrators | Maintenance history, dependency impact | Focus on technical contributions, not personal commitment | Trusted Contributor |
| **Values Alignment Attestation** | "Demonstrates project values consistently in technical choices" | Project ethics committee | Value-aligned decisions, ethical considerations in PRs | Reference only public value statements | Core Contributor |

### 4. Progressive Trust Implementation

#### Trust Levels and Required Assertions

| Trust Level | Required Assertions | Verification Methods | Typical Access Level | Privacy Risk Level |
|-------------|---------------------|----------------------|----------------------|-------------------|
| **First Contact** | Basic pseudonymous identifier with public key | Cryptographic verification of control | Issue reporting, small docs PRs | Minimal |
| **Initial Contributor** | 1-2 self-attestations about relevant skills | Small contribution demonstrating claims | Small bug fixes, documentation | Low |
| **Issue Solver** | Technical skill attestation relevant to specific issues | Successful PR addressing specific issue | Targeted bug fixes, small features | Low |
| **Documentation Contributor** | Writing skill attestation, project understanding | Documentation improvements | Documentation ownership | Low |
| **Regular Contributor** | 3-5 self-attestations with verifiable evidence | Multiple successful contributions | Feature development, testing | Low-Medium |
| **Consistent Contributor** | Demonstrated pattern of quality contributions | Contribution history, 1-2 peer endorsements | Regular code review, feature planning | Medium |
| **Domain Specialist** | Deep expertise in specific project area | Substantial contributions to specific component | Component ownership | Medium |
| **Technical Mentor** | Teaching and documentation skills | Onboarding materials, helping new contributors | Mentorship role | Medium |
| **Trusted Contributor** | 5+ peer endorsements across multiple dimensions | Substantial contribution history, diverse skillset | Significant features, security review | Medium-High |
| **Architecture Contributor** | System design attestations and endorsements | Successful architectural contributions | Architecture planning, technical direction | High |
| **Security Contributor** | Security expertise with verification | Security improvements, vulnerability management | Security-sensitive components | High |
| **Cross-Functional Lead** | Collaboration endorsements from multiple teams | Cross-component features, integration work | Cross-team coordination | High |
| **Core Contributor** | 10+ endorsements including project leadership | Long-term impactful contribution history | Critical components, release planning | High |
| **Technical Leader** | Technical vision attestations with endorsements | Technical direction setting, mentorship | Technical decision authority | Very High |
| **Governance Participant** | Ethics and public interest endorsements | Governance contributions, value alignment | Policy decisions, conflict resolution | Very High |
| **Project Steward** | Long-term commitment with community trust | Sustained leadership, community growth | Project-wide responsibilities | Highest |

#### Domain-Specific Adaptations

##### Security-Focused Projects

| Trust Level | Required Assertions | Verification Methods | Special Considerations | Privacy Protection |
|-------------|---------------------|----------------------|------------------------|-------------------|
| **Initial Security Contributor** | Basic security knowledge attestation | Security bug fix with proper handling | Requires extra scrutiny on first contributions | Use public CVE references only |
| **Security Reviewer** | Threat modeling attestation with evidence | Thorough security reviews with actionable findings | May require backdated disclosure after trust establishment | Zero-knowledge proof of security expertise |
| **Security Component Owner** | Cryptographic expertise attestation and endorsements | Implementation of security-critical components | Often requires multi-party review process | Cryptographic commitment to expertise without specifics |
| **Security Architect** | Multiple security endorsements from trusted team | Security architecture that withstands review | May require trusted escrow of additional credentials | Progressive disclosure with trusted leadership only |

##### Privacy-Focused Projects

| Trust Level | Required Assertions | Verification Methods | Special Considerations | Privacy Protection |
|-------------|---------------------|----------------------|------------------------|-------------------|
| **Initial Privacy Contributor** | Data minimization understanding | Privacy-enhancing feature implementation | Emphasis on demonstrating privacy principles | Use standard privacy frameworks, avoid unique approaches |
| **Privacy Reviewer** | Privacy threat modeling attestation | Privacy analysis with actionable improvements | Particular attention to regulatory knowledge | Anonymize regulatory expertise to avoid jurisdiction hints |
| **Privacy Component Owner** | Multiple privacy-focused endorsements | Implementation of core privacy features | May require advanced knowledge of anonymity systems | Abstract implementation details from personal knowledge |
| **Privacy Architect** | Research-based privacy attestations, peer recognition | Design of privacy-preserving architecture | Often requires specialized cryptographic knowledge | Use zero-knowledge proofs for credential verification |

##### Women's Safety Application Projects

| Trust Level | Required Assertions | Verification Methods | Special Considerations | Privacy Protection |
|-------------|---------------------|----------------------|------------------------|-------------------|
| **Initial Safety Contributor** | Safety-focused technical skill | Small enhancement to safety feature | Requires demonstration of understanding safety context | Avoid revealing personal experiences with safety issues |
| **Safety Feature Developer** | Implementation of privacy-preserving safety features | Privacy-respecting safety feature with documentation | Particular attention to sensitive user protection | Use standard safety patterns, avoid unique approaches |
| **Safety Component Owner** | Security and privacy expertise relevant to safety | Core safety feature implementation with thorough testing | May require specialized safety-domain knowledge | Abstract implementation details from personal experience |
| **Safety Application Architect** | Multiple safety domain endorsements | Safety-focused architecture that protects vulnerable users | Requires understanding of threat models against vulnerable users | Use generalized threat models, not personal experience |

## Check Your Understanding

1. How would you structure a participation profile for a different context, such as an accessibility-focused contributor?
2. What kinds of assertions would be most important when contributing to a security-critical component of a women's safety app?
3. How would you create selective disclosure views for different audiences of your participation profile?
4. What are the key differences in required assertions between an initial contributor and a trusted contributor role?
5. How do peer endorsements enhance the credibility of self-attestations in a participation profile?

## Next Steps

- Create your own participation profile using [Tutorial 1: Your First XID](../tutorials/01-your-first-xid.md)
- Add self-attestations to your profile with [Tutorial 3: Self-Attestation with XIDs](../tutorials/03-self-attestation-with-xids.md)
- Gather and integrate peer endorsements using [Tutorial 4: Peer Endorsement with XIDs](../tutorials/04-peer-endorsement-with-xids.md)
- Learn about the [Progressive Trust Life Cycle](progressive-trust-lifecycle.md) that underlies participation profiles
- Explore [XID Fundamentals](xid-fundamentals.md) to understand the technical foundations