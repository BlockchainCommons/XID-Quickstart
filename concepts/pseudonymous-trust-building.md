# Pseudonymous Trust Building

## Expected Learning Outcomes

By the end of this document, you will:

- Understand how to build trust without revealing identity
- See how pseudonymous identity enables contribution without exposure
- Know how to use evidence commitments, peer endorsements, and progressive trust to empower pseudonymous identities
- Learn how to balance verification with privacy

## The Challenge of Pseudonymous Trust

Building trust traditionally relies on real-world identity,
credentials, and reputation. When operating pseudonymously (using an
identity that's not linked to your real-world self), these traditional
trust signals are unavailable.

The challenge becomes: How do you build trust when nobody knows who
you are?

## Core Principles of Pseudonymous Trust

1. **Work Quality Over Identity**: Let the quality of your work speak rather than your credentials
2. **Verifiable Contributions**: Provide work that can be independently verified
3. **Contextual Transparency**: Be open about methods, limitations, and biases
4. **Progressive Evidence**: Build a consistent track record over time
5. **Peer Validation**: Gather attestations from others in the community

### Core Principles of Pseudonymous Verification

The key to pseudonymous trust is maintaining verification capabilities while preserving privacy:

1. **Minimal Disclosure**: Only reveal what's necessary for the specific context
2. **Evidence Without Identity**: Provide verifiable evidence without connecting to real identity
3. **Separate Contexts**: Use different pseudonyms for different contexts if needed
4. **Cryptographic Verification**: Use signatures to prove consistent identity
5. **Progressive Trust**: Reveal more information as relationships develop

### Core Systems of Pseudonymous Trust & Verification

The mechanical systems for creating pseudonymous trust have already been covered:

1. **Evidence Commitment.** This is a specific application of [elision cryptography](elision-cryptography.md).
2. **Peer Endorsements.** This is part of the [attestation & endorsement model](attestation-endorsement-model.md).
3. **The Progressive Trust Life Cycle.** This [life cycle](progressive-trust.md) can be expanded through constant iteration.

## Evidence Commitments: Proving Without Revealing

Evidence commitments use elision cryptography to commit to evidence
without revealing it prematurely. This is done by hasing data that
contain evidence.

Evidence commitments can be used to improve the trustworthiness of a
pseudonymous identity: you can state what evidence you've committed,
in case it's required at some future point, and you can reveal that
information in the future, possibly as part of a [progressive
trust](progressive-trust.md) life cycle with a specific entity.

This approach lets you:

- Maintain control over sensitive information
- Prove you had specific knowledge at a certain time when you released the hash
- Reveal evidence progressively as trust develops
- Provide cryptographic verification of your claims

The following methodology can be used to commit evidence contained
within a file. It might be done to prove a creation date for a piece
of artwork or the content of a legal contract. It can also be used to
record specific information for commtiment.

1. **Create Evidence**: Choose a file whose evidence you want to commit.
   ```
   echo "API security enhancements with privacy-preserving authentication system" > evidence/project_summary.txt
   ```

2. **Generate Cryptographic Hash**: Create a digest of the evidence
   ```
   SUMMARY_HASH=$(cat evidence/project_summary.txt | shasum -a 256 | awk '{print $1}')
   ```

3.  **Encode:** Encode per the [ur:digest CDDL](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2021-002-digest.md#cddl)

   ```
   SUMMARY_HASH_BW=$(bytewords -i hex "5820"$SUMMARY_HASH -o minimal)
   SUMMARY_HASH_UR="ur:digest/"$SUMMARY_HASH_BW
   ```

4. **Include Hash in Assertions**: Reference the evidence in your XID
   ```
   PROJECT=$(envelope assertion add pred-obj string "projectSummaryHash" digest "$SUMMARY_HASH_UR" "$XID_DOC")
   ```

```
XID(68863088) [
    "projectSummaryHash": Digest(74c01878)
    'key': PublicKeys(2e1a74fd) [
        'allow': 'All'
        'nickname': "MyIdentifier"
    ]
]
```
   
5. **Selective Reveal**: Share the actual evidence only with trusted parties
   ```
   # When trust is established:
   cat evidence/project_summary.txt
   ```

6. **Verification**: Trusted Parties can verify the evidence matches your earlier commitment
   ```
   COMPUTED_HASH=$(cat evidence/project_summary.txt | shasum -a 256 | awk '{print $1}')
   if [ "$COMPUTED_HASH" = "$SUMMARY_HASH" ]; then
       echo "Evidence verified - matches the commitment"
   fi
   ```

### Evidence Commitments in Gordian Envelope

Evidence commitment capability is already built into Gordian Envelope:
you just include the desired data, then elide it, and a digest will be
left behind. When your data is short and simple and you're not trying
to prove the existence or content of a larger file, this is often a
more desirable approaach.

See [Elision Cryptograph](elision-cryptography.md) for more examples
of how to use elision to protect and prove data.

1. **Create Evidence:** Document your work directly in your XID.

   ```
   PROJECT_E=$(envelope assertion add pred-obj string "projectSummary" string "API security enhancements with privacy-preserving authentication system" $XID_DOC)                 
   ```

2. **Elide Data:** Remove data to be kept private.
   ```
   PROJECTSUMMARY=$(envelope assertion find predicate string projectSummary $PROJECT_E)
   ELIDED_PROJECT_E=$(envelope elide removing $PROJECTSUMMARY $PROJECT_E)
   ```

3. **Publication:** Send the elided data out to the public.

```
envelope format $ELIDED_PROJECT_E

XID(03061331) [
    'key': PublicKeys(73fc5e62) [
        'allow': 'All'
        'nickname': "BRadvoc8"
    ]
    ELIDED
]
```

4. **Selective Reveal:** Reveal an elided assertion (or other data) to a trusted party.

   ```
   envelope format $PROJECTSUMMARY
   
   "projectSummary": "API security enhancements with privacy-preserving authentication system"
   ```   		     	  

5. **Verification:** Compare the digest of the revealed data to the digest of the elided data

   ```
   PROJECTSUMMARY_DIGEST=$(echo $PROJECTSUMMARY | envelope digest) 
   ELIDED_DIGEST=$(envelope assertion at 1 $ELIDED_PROJECT_E | envelope digest)
   if [ "$ELIDED_DIGEST" = "$PROJECTSUMMARY_DIGEST" ]; then echo "Elided content is 'API security enhancements ...'"; fi
   ```
   
Note that if information is notably short and simple, you might need
to [salt it](elision-cryptography.md#salting-for-privacy-protection)
to ensure that it can't be guessed. You'll then have to [share the
salt](elision-cryptography.md#5-known-content-verification-with-salt)
to allow verification.

## Peer Endorsements: Building a Network of Trust

As discussed in [Attestation & Endorsement
Model](attestation-endorsement-model.md), peers can make their own
attestations of you, to support your self-attestations. This is
equally true for a pseudonymous identity and a real-world identity.

In fact, the peer endorsements you get might be pseudonymous too: they
then are supported by their own self-attestations, by their own
evidence commitments, and by their own network of trust.

These attestations build a web of trust around your pseudonymous
identity without requiring you to reveal who you are.

See [this practical
implementation](attestation-endorsement-model.md#practical-implementation-peer-endorsements)
for making and accepting a peer endorsement.

## The Progressive Trust Model: Expanding the Life Cycle

Progressive Trust as described in [The Progressive Trust Life
Cycle](progressive-trust.md) may also be more important for a
pseudonymous identity than a real-world one, because peers of a
pseudonymous identityhave nothing to go on except the trust that
gradually extends over time.

This goes further than a single life cycle. A single progressive trust
life cycle increases the trust between two entities as they
interact. That in turn can increase the trust between an entity and
the larger community as the life cycle repeats again and again for
individual interactions, because those interactions create the record
of a longer-term history.

The initial phases of using progressive trust for a pseudonymous
identity require the same type of self-attestation, peer endorsement,
and elision that you'd use in any progressive trust situation:

1. **Introduction**: Offer initial self-assertions.
   ```
   PRIVATE_KEYS=$(envelope generate prvkeys)
   PUBLIC_KEYS=$(envelope generate pubkeys "$PRIVATE_KEYS")
   XID_DOC=$(envelope xid new --nickname "BRadvoc8" "$PUBLIC_KEYS")
   X_XID_DOC=$(envelope assertion add pred-obj string email string "bwh@bwhacker.org" $XID_DOC)
   X_XID_DOC=$(envelope assertion add pred-obj string domain string "Distributed Systems & Security" $X_XID_DOC)
   ```

```
XID(03061331) [
    "domain": "Distributed Systems & Security"
    "email": "bwh@bwhacker.org"
    'key': PublicKeys(73fc5e62) [
        'allow': 'All'
        'nickname': "BRadvoc8"
    ]
]
```

2. **Proofs**: Provided verification of secrets.
   ```
   WRAPPED_X_XID=$(envelope subject type wrapped $X_XID_DOC)
   SIGNED_X_XID=$(envelope sign -s "$PRIVATE_KEYS" "$WRAPPED_X_XID")
   ```

```
{
    XID(03061331) [
        "domain": "Distributed Systems & Security"
        "email": "bwh@bwhacker.org"
        'key': PublicKeys(73fc5e62) [
            'allow': 'All'
            'nickname': "BRadvoc8"
        ]
    ]
} [
    'signed': Signature
]
```

3. **Elision**: Hide some information for initial interactions, while maintaining verifications.

```
EMAIL=$(envelope extract wrapped $SIGNED_X_XID | envelope assertion find predicate string "email")
ELIDED_X_XID=$(envelope elide removing $EMAIL $SIGNED_X_XID)
```

```
{
    XID(03061331) [
        "domain": "Distributed Systems & Security"
        'key': PublicKeys(73fc5e62) [
            'allow': 'All'
            'nickname': "BRadvoc8"
        ]
        ELIDED
    ]
} [
    'signed': Signature
]
```

A singular progressive trust life cycle would simply involve revealing
and proving the commitment of information as time goes on:


4. **Revelation**: Reveal additional information in later interactions

```
 envelope format $EMAIL
"email": "bwh@bwhacker.org"
```

```
envelope digest $EMAIL
ur:digest/hdcxpmwzqdhgmwhpfsvohtcayamwnewffncnptlrzcrlrdprnlcstokitewyrfaefxzmpygybyss

envelope extract wrapped $ELIDED_X_XID | envelope assertion at 1 | envelope digest
ur:digest/hdcxpmwzqdhgmwhpfsvohtcayamwnewffncnptlrzcrlrdprnlcstokitewyrfaefxzmpygybyss
```

However, as the progressive trust life cycle extends, a XID_DOC too
can expand, creating the additional trust that's needed for a
pseudonymous situation.

5. **Expansion**: Gather peer endorsements.

```
# Endorsement from peer on "Distributed Systems & Security", per [practical implementation](attestation-endorsement-model.md#practical-implementation-peer-endorsements)

ur:envelope/lftpsplotpsokscpfejtiejljpjkihjnihjtjyftcxfginjthsjtiainhsjzcxfpgdgacxgdjpjlimihiajyoytpsojpihjtiejljpjkihjpgsinjninjyhsjyinjljttpsoksdwgsinjninjyihiecxjyihiaisjtiniahsjzcxidhsiajeiojpjlkpjtiecxinjtcxiajpkkjojyjliojphsjoiskkoytpsojsihjtiejljpjkihjnihjtjyghhsjpioihjytpsotanshdhdcxaxambwehcnknwlnbdmsboyvllrweksdwfrdkcwiojnmenydycplnbsbabezcvakboytpsoisihjtiejljpjkihjptpsoksehghihiaisgdgtcxdpcxgdjpjlimihiajycxgthsjthsioihjpcxktinjyiscxeheycxkkihhsjpjkcxihksjoihjpinihjtiaihoytpsoihidhsjkinjktpsoksfzfyinjpihiajycxjlidjkihjpkohsjyinjljtcxjyisjpjlkpioisjlkpjycxjyisihcxjojpjlimihiajycxjojzkpjkcxjpihkoinihktcxjliycxjnihjyjpiniajkoytpsojzjpihjzhsjyinjljtjkisinjotpsoksdnfyinjpihiajycxjojpjlimihiajycxjlkoihjpjkinioisjycxhsjkcxgdjpjlimihiajycxgthsjthsioihjpoytpsojnjojljyihjtjyinhsjzfwinhsjktpsoksehfdhsiecxjnhsjthsioihjnihjtjycxjpihjkjojljtjkinidinjzinjykkcxiyjljpcxjojpjlimihiajycxjkkpiaiaihjkjkoytpsojejlidjkihjpkohsjyinjljttpsokshffwhgfdhsiajeihjpcxieihjkiniojtihiecxinjtjtjlkohsjyinkoihcxhskpjyisihjtjyiniahsjyinjljtcxjkkkjkjyihjncxjyishsjycxihksiaihihieihiecxjkihiakpjpinjykkcxjpihjskpinjpihjnihjtjyjkoyaxtpsotansghhdfzzcjtoscwmwmdbsaegsrhmetdknetisiovwmdehhdpyvlrortnndinttpesbktaaaprtplbendegmjtzehyfwpfttiooeksiehslyttsgsglkctvwgdatlsplspmysgrnghlostjz
```

   The pseudoynmous "BRadvoc8" can examine that endorsement (`envelope
   format $SIGNED_ENDORSEMENT) and then add it to a new version of
   their XID_DOC:

   ```
   DSS=$(envelope subject type string "Distributed Systems & Security")
   DSS=$(envelope assertion add pred-obj string peerEndorsements envelope $SIGNED_ENDORSEMENT $DSS)

   X_XID_DOC_1=$(envelope assertion add pred-obj string email string "bwh@bwhacker.org" $XID_DOC)
   X_XID_DOC_1=$(envelope assertion add pred-obj string domain envelope $DSS $X_XID_DOC_1)
   ```

   Afterward, they could wrap, sign, and elide as normal:
```
{
    XID(03061331) [
        "domain": "Distributed Systems & Security" [
            "peerEndorsements": {
                "Endorsement: Financial API Project" [
                    "basis": "Direct observation throughout the project plus review of metrics"
                    "endorsementTarget": XID(03061331)
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
        'key': PublicKeys(73fc5e62) [
            'allow': 'All'
            'nickname': "BRadvoc8"
        ]
        ELIDED
    ]
} [
    'signed': Signature
]
```
Though this is a new verison of the `XID_DOC`, the XID and the public keys remain consistent, and the new signature is valid, proving continuity.

6. **Consistency**: Build a track record over time.
   ```
   # Additional domain of expertise with similar quality and transparency
   X_XID_DOC_2=$(envelope assertion add pred-obj string domain string "Payment Gateway Security" $X_XID_DOC_1)
   ```

```
{
    XID(03061331) [
        "domain": "Payment Gateway Security"
        "domain": "Distributed Systems & Security" [
            "peerEndorsements": {
                "Endorsement: Financial API Project" [
                    "basis": "Direct observation throughout the project plus review of metrics"
                    "endorsementTarget": XID(03061331)
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
        'key': PublicKeys(73fc5e62) [
            'allow': 'All'
            'nickname': "BRadvoc8"
        ]
        ELIDED
    ]
} [
    'signed': Signature
]
```

Through additional life cycles, more peer endorsements and more
domains could be added, more personal information could be added, and
information could be elided and/or revealed in different ways,
increasing the amount of evidence that the entity can be trusted, even
when using a pseudonymous identity.

## Check Your Understanding

1. How can you use XIDs to maintain consistent pseudonymous identity over time?
2. What role do transparency and context play in building trust without identity?
3. How do evidence commitments allow verification without premature disclosure?
4. Why are peer attestations important for pseudonymous trust?
5. How does progressive trust development work in pseudonymous contexts?

## Next Steps

After understanding pseudonymous trust building, you can:

- Apply these concepts in [Tutorial 3: Building Trust with Pseudonymous XIDs](../tutorials/03-building-trust-with-pseudonymous-xids.md)
- Implement evidence commitments and peer attestations in your own XID
- Finish up core concepts with [Public Participation Profiles](public-participation-profiles.md)
