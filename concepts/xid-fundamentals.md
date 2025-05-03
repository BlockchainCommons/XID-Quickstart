# XID Fundamentals

## Expected Learning Outcomes
By the end of this document, you will:
- Understand what XIDs are and why they're valuable
- Know how XIDs are derived from cryptographic keys
- Understand how XIDs maintain stable identity despite key changes
- Be familiar with basic XID document structure
- Know when to use XIDs for pseudonymous identity

## What Are XIDs?

An XID (eXtensible IDentifier, pronounced "zid") is a unique 32-byte identifier derived from a cryptographic key. It provides a stable digital identity that remains consistent even as the keys associated with it evolve over time.

For example, an XID might look like this:
```
7e1e25d7c4b9e4c92753f4476158e972be2fbbd9dffdd13b0561b5f1177826d3
```

For convenience, XIDs are often shown in shortened form using just the first few bytes:
```
7e1e25d7...
```

## How XIDs Are Created

An XID is created through a straightforward process:
1. Generate a cryptographic key pair (public and private keys)
2. Take the SHA-256 hash of the public key material
3. This hash becomes the stable identifier (the XID)

In the envelope CLI tool, the process looks like this:

👉 
```sh
PRIVATE_KEYS=$(envelope generate prvkeys)
PUBLIC_KEYS=$(envelope generate pubkeys "$PRIVATE_KEYS")
XID_DOC=$(envelope xid new --name "MyIdentifier" "$PUBLIC_KEYS")
XID=$(envelope xid id "$XID_DOC")
```

## Stability Through Change

One of the most powerful aspects of XIDs is that they maintain a stable identifier even as associated keys change:

1. The XID is derived from the initial "inception" key
2. Additional keys can be added or removed without affecting the XID
3. The original key can eventually be rotated out entirely
4. The identifier remains consistent throughout these changes

This stability allows for:
- Secure key rotation without disrupting existing relationships
- Adding device-specific keys while maintaining the same identity
- Recovery from key loss without losing your established identity
- Progressive trust building over time with a consistent identifier

## XID Document Structure

An XID alone is just an identifier. The real power comes from the XID document - a Gordian Envelope containing structured data about the XID:

```
"MyIdentifier" [
   "name": "MyIdentifier"
   "publicKeys": ur:crypto-pubkeys/hdcxlkadjngh...
   "domain": "Software Development"
   "key": [
      ur:crypto-pubkeys/hdcxaeluhhfy...
      "Secondary Device Key"
      "sign"
   ]
]
```

The XID document contains:
- The name of the identity
- Public key material
- Additional assertions about the identity
- Additional keys with specific permissions
- Other relevant information for verification

## When to Use XIDs for Pseudonymous Identity

XIDs are particularly valuable for pseudonymous identity when:

1. **Privacy is required**: You need to participate without revealing your real identity
2. **Trust must be verifiable**: Others need to verify your contributions come from the same identity
3. **Progressive disclosure is needed**: You want to reveal information gradually as trust develops
4. **Identity persistence matters**: You need a stable identifier even as your keys or devices change
5. **Cryptographic verification is important**: You need to prove control without revealing identity

As seen in Amira's case (Tutorial 1), a pseudonymous XID allows her to contribute professionally while protecting her personal information and building trust through verified work rather than credentials.

## Relationship to Other Concepts

XIDs work together with:
- **Gordian Envelopes**: The data structure that enables XID documents
- **Fair Witness assertions**: A framework for making verifiable claims with an XID
- **Data minimization**: Techniques to control what information is revealed
- **Progressive trust**: A model for building trust relationships over time

## Check Your Understanding

1. How is an XID derived from a cryptographic key?
2. Why does an XID remain stable even when keys are added or rotated?
3. What is the difference between an XID and an XID document?
4. What types of information can be included in an XID document?
5. When would you want to use a pseudonymous XID rather than your real identity?

## Next Steps

After understanding XID fundamentals, you can:
- Apply these concepts in [Tutorial 1: Creating Your First XID](../tutorials/01-your-first-xid.md)
- Learn about [Gordian Envelope Basics](gordian-envelope-basics.md)
- Explore [Data Minimization Principles](data-minimization-principles.md)