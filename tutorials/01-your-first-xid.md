# Creating Your First XID

This tutorial introduces Amira, a software developer with a
politically sensitive background who wants to contribute to social
impact projects without risking her professional position or revealing
her identity. By the end, you'll have created an XID (eXtensible
IDentifier) that enables pseudonymous contributions while building
trust progressively.

**Time to complete: 15-20 minutes**

> **Related Concepts**: Before or after completing this tutorial, you
may want to read about [XID Fundamentals](../concepts/xid.md) and
[Gordian Envelope Basics](../concepts/gordian-envelope.md) to
understand the theoretical foundations behind what you're
implementing.

## Prerequisites

- Basic terminal/command line familiarity
- The [Gordian Envelope-CLI](https://github.com/BlockchainCommons/bc-envelope-cli-rust) tool installed (release 13.1 or later).

## What You'll Learn

- How to create a minimal XID for pseudonymous contributions
- How to add and verifiable assertions to your XID and sign them
- How to create public versions of your XID redacting private data using elision
- How to maintain strong cryptographic integrity while sharing only what you choose
- How to organize and store XID files using secure naming conventions

## Amira's Story: Why Pseudonymous Identity Matters

Amira is a successful software developer working at a prestigious
multinational bank in Boston. With her expertise in distributed
systems security, she earns a comfortable living, but she wants more
purpose in her work. On the advice of her friend Charlene, Amira
discovers RISK, a network that connects developers with social impact
projects while protecting participants' privacy.

Given Amira's background in a politically tense region, contributing
openly to certain social impact projects could risk her visa status,
professional position, or even the safety of family members back
home. Yet she's deeply motivated to use her skills to help oppressed
people globally. This tension between professional security and
meaningful contribution creates a specific need.

However, Amira faces a dilemma: she can't contribute anonymously
because anonymous contributions lack credibility. Project maintainers
need confidence in the quality and provenance of code, especially for
socially important applications. She needs a solution that protects
her identity while allowing her to build a verifiable reputation for
her skills.

Amira needs a technological solution that allows her to:

1. Share her valuable security expertise without revealing her real identity
2. Build verifiable trust through the quality of her work, not her existing credentials
3. Establish a consistent "BRadvoc8" (aka Basic Rights Advocate) digital presence that can evolve and build reputation over time
4. Connect with project leaders like Ben from the women's services non-profit
5. Protect herself from adversaries who might target her for her contributions

This is where XIDs come in: they enable pseudonymous identity with
progressive trust development, allowing Amira to safely collaborate on
projects aligned with her values while maintaining separation between
her pseudonymous contributions and her legal identity.

## Why XIDs Matter

XIDs provide significant advantages that go well beyond standard
cryptographic keys:

1. **Stable identity** - XIDs maintain the same identifier even when
you rotate keys.
2. **Progressive trust** - XIDs let you selectively share different
information with different parties.
3. **Rich metadata** - XIDs can contain structured attestations,
endorsements, and claims.
4. **Peer validation** - XIDs enable others to make cryptographically
verifiable claims about your identity.
5. **Multi-key support** - XIDs can link multiple keys for different
devices while maintaining a single identity.
6. **Recovery mechanisms** - XIDs support recovery without losing your
reputation history.
7. **Cryptographic integrity** - XIDs preserve verifiability even when
portions are not included when sharing.

This first tutorial is deliberately simple to get you started with the
basics. While we're using basic cryptographic primitives in this
tutorial, Gordian XIDs support many cryptographic key types, including
advanced formats for threshold signatures and post-quantum
cryptography. As we progress through subsequent tutorials, we'll
explore these more advanced capabilities in depth.

## Step 1: Creating a Private XID

Now that we understand why XIDs are valuable, let's help Amira create
her "BRadvoc8" identity.

An XID is fundamentally a digital container built using cryptographic
key material. To create one, Amira will need to generate a private key
base specifically for her XID. This command creates the cryptographic
foundation for all her future operations.

```sh
XID_PRVKEY_BASE=$(envelope generate prvkeys)
echo "Generated private key base for XID"
```

Now you can create a new XID using this private key base. This command
generates an XID container that incorporates the public key derived
from the private key base while also securely storing the private key
information within the structure:

```sh
XID=$(envelope xid new "$XID_PRVKEY_BASE")
echo "Created new XID"
```

At this point, your XID contains the private key information. Let's
view it in a human-readable format to examine its structure:

```sh
envelope format "$XID"
```

You should see output similar to:

```
XID(d5aad53e) [
    'key': PublicKeys(6d165468) [
        {
            'privateKey': PrivateKeys(a7ba7576)
        } [
            'salt': Salt
        ]
        'allow': 'All'
    ]
]
```

The XID starts with a minimal structure: just a unique identifier
(`d5aad53e and cryptographic key material in the form of a public and
private key pair. Note that the `privateKey` section contains
sensitive information derived from your previously generated private
key base, thus this data should be protected with the same diligence
you would apply to SSH or other cryptographic keys.

## Toward an Enhanced XID

The basic XID provides a cryptographic foundation but its true power
comes from adding assertions and structure. In the next part of this
tutorial, we'll transform a simple XID into a rich digital identity.

## Step 2: Creating a Basic Public XID

To make her XID safely shareable, Amira needs to create a public copy
of her XID by removing the private key components. This process is
called elision, which selectively removes private information while
preserving the cryptographic integrity of the envelope.

This process involves:

1. Finding the private key component within the XID
2. Eliding (removing) it while maintaining the cryptographic integrity
3. Saving the resulting public XID for sharing

We'll implement these steps as follows:

To find the private key component that needs to be elided, Amira first
extracts the key assertion and locates the private key:

```sh
KEY_ASSERTION=$(envelope xid key at 0 "$XID")
PRIVATE_KEY_ASSERTION=$(envelope assertion find predicate known privateKey "$KEY_ASSERTION")
PRIVATE_KEY_ASSERTION_DIGEST=$(envelope digest "$PRIVATE_KEY_ASSERTION")
```

Now that she has identified the private key assertion, she can elide
it from the XID to create a basic public version that's safe to share:

```sh
BASIC_PUBLIC_XID=$(envelope elide removing "$PRIVATE_KEY_ASSERTION_DIGEST" "$XID")
echo "Created basic public XID"
```

Let's view the resulting basic public XID:

```sh
envelope format "$BASIC_PUBLIC_XID"
```

```
XID(d5aad53e) [
    'key': PublicKeys(6d165468) [
        'allow': 'All'
        ELIDED
    ]
]
```

Notice the `ELIDED` marker in the output, which indicates where the
private key information has been removed. This basic public XID
retains its cryptographic integrity but no longer contains the
sensitive private key material.

## XID Version Types

An important feature of XIDs is the ability to create different
versions for different purposes. Throughout this tutorial, Amira
creates three versions of her XID:

1. A **private XID** (Step 1) that contains her private key material,
kept secure
2. A **basic public XID** (Step 2) with the private key elided, that
can be safely shared
3. An **enhanced public XID** (Step 3) with additional persona details
and signature, also safe to share

The public versions are created through a process called elision,
which selectively removes private information while preserving the
cryptographic integrity of the envelope.

## Proper File Organization

For real-world usage, Amira will want to organize her files in a
dedicated directory with names that clearly indicate their security
level. She uses clear naming conventions:

- Files with `-private` contain sensitive private keys that must be
  kept secret
- Files with `-basic-public` contain a minimal public XID with private
  keys elided
- Files with `-enhanced-public` contain a feature-rich public XID with
  additional assertions
- Files with `.format` are human-readable versions of the
  corresponding envelope files
- Files with `.xid` or `.envelope` contain the binary serialized versions

All files are stored in a timestamp-based directory (e.g.,
`xid-20250510123456`) to keep versions organized.

These naming conventions help prevent accidentally sharing private key
material.

Now that we understand the basic principles of XIDs and their
organization, let's put everything together to create a fully
functional, feature-rich XID that Amira can use for her pseudonymous
contributions.

## Step 3: Creating an Enhanced XID with Persona Details

Having created a basic public XID, Amira now wants to create an
enhanced version that provides more information about her persona and
resolution methods, while still keeping her private key information
secure.

> **Quick Reference**: An "enhanced XID" goes beyond basic
identification by adding structure, context, and verifiable
assertions. The process below transforms a simple public XID (with
just a key) into a rich digital identity that includes persona
information, service details, and resolution methods - all while
maintaining cryptographic integrity.

Amira will start with the basic public XID that she created
earlier. This is a basic XID with the private key components already
elided (removed while preserving cryptographic integrity) for safe
sharing. She assigns this to a new variable to begin her enhancements:


```sh
ENHANCED_XID="$BASIC_PUBLIC_XID"
```

```
XID(d5aad53e) [
    'key': PublicKeys(6d165468) [
        'allow': 'All'
        ELIDED
    ]
]
```

Notice how the initial XID contains only a public key with elided
(removed) private components. Now Amira will transform this into a
rich, structured identifier.

Let's compare where we're starting from and where we're heading:

| **Basic Public XID (Starting Point)** | **Enhanced XID (Our Goal)** |
|----------------------------------|------------------------------|
| A minimal XID with just public keys | A rich XID with structure and assertions |
| No type declaration | Clear "Persona" type |
| No nickname | Human-readable "BRadvoc8" nickname |
| No service info | Contains GitHub account details |
| No resolution methods | Multiple resolution URIs |
| Not signed | Cryptographically signed |
| Flat structure | Hierarchical organization |
| **Sample Basic Public XID**                           | **Sample Enhanced XID**
| XID(d5aad53e) [               | XID(d5aad53e) [
|     'key': PublicKeys(...) [  |     'isA': "Persona"
|         'allow': 'All'        |     "nickname": "BRadvoc8"
|         ELIDED                |     "service": "GitHub" [...]
|     ]                         |     "resolveVia": URI(...)
| ]                             |     'key': PublicKeys(...)
|                               | ] [
|                               |     'signed': Signature
|                               | ]

### Creating a Persona

Amira begins the process by adding a type declaration to clearly
identify this as a persona XID. This helps systems understand what
kind of entity this XID represents. Note that `isA` is used as a
[known
value](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2023-002-known-value.md)
rather than a string. This makes the XID more semantically meaningful
to systems that understand these known values:

> **Technical Note**: Known values (like `isA`, `dereferenceVia`,
etc.) are special values in the Gordian Envelope system that have
standard, well-defined meanings. Using known values instead of
strings enables better interoperability, validation, and semantic
understanding across different systems.

```sh
ENHANCED_XID=$(envelope assertion add pred-obj known isA string "Persona" "$ENHANCED_XID")
```

Then she adds a nickname to provide a human-readable identifier, using
the XID_NAME variable:

```sh
XID_NAME=BRadvoc8
ENHANCED_XID=$(envelope assertion add pred-obj string "nickname" string "$XID_NAME" "$ENHANCED_XID")
```

Let's see how the XID looks after adding these basic identity
assertions:

```sh
envelope format "$ENHANCED_XID"

XID(d5aad53e) [
    'isA': "Persona"
    "nickname": "BRadvoc8"
    'key': PublicKeys(6d165468) [
        'allow': 'All'
        ELIDED
    ]
]
```

Notice how `isA` appears with single quotes to indicate it's a known
value predicate, while "nickname" is in double quotes because it's a
string predicate. Known values are distinguished with single quotes,
while string predicates use double quotes in the formatted output.

### Adding a Service

Next, she wants to add detailed information about her GitHub
account. She'll create this as a nested structure to demonstrate the
hierarchical capabilities of Gordian Envelopes.

> **Technical Note**: Using proper data types (instead of just strings) makes XIDs more powerful because:
> - **Date types** enable chronological operations and validation
> - **URI types** allow systems to recognize and validate web resources
> - **Structured data** enables machine readability and complex queries

First, she creates an account information envelope with timestamps
using the proper date type and evidence using the URI type. Note how
she uses the XID_NAME variable consistently:


```sh
GITHUB_ACCOUNT=$(envelope subject type string "$XID_NAME")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "created_at" date "2025-05-10T00:55:11Z" "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "updated_at" date "2025-05-10T00:55:28Z" "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "evidence" uri "https://api.github.com/users/$XID_NAME" "$GITHUB_ACCOUNT")
```

```
"BRadvoc8" [
    "created_at": 2025-05-10T00:55:11Z
    "evidence": URI(https://api.github.com/users/BRadvoc8)
    "updated_at": 2025-05-10T00:55:28Z
]
```

Notice how the dates appear without quotes, showing they're not simple
strings, and that the evidence URL has the URI() wrapper, indicating
its special type.

Now, Amira creates a service envelope that contains this account
information. She also adds a type classification for the service using
the `isA` known value. This nesting (service → account) and typing
creates a logical hierarchy that helps organize related information:

```sh
GITHUB_SERVICE=$(envelope subject type string "GitHub")
# Add the type of service (using known isA predicate)
GITHUB_SERVICE=$(envelope assertion add pred-obj known isA string "SourceCodeRepository" "$GITHUB_SERVICE")
GITHUB_SERVICE=$(envelope assertion add pred-obj string "account" envelope "$GITHUB_ACCOUNT" "$GITHUB_SERVICE")
```

The result:

```
"GitHub" [
    'isA': "SourceCodeRepository"
    "account": "BRadvoc8" [
        "created_at": 2025-05-10T00:55:11Z
        "evidence": URI(https://api.github.com/users/BRadvoc8)
        "updated_at": 2025-05-10T00:55:28Z
    ]
]
```

Finally, she adds this service information to her XID, demonstrating
how XIDs can contain complex, nested data structures while maintaining
cryptographic integrity:

```sh
ENHANCED_XID=$(envelope assertion add pred-obj string "service" envelope "$GITHUB_SERVICE" "$ENHANCED_XID")
```

She views the result:

```
envelope format "$ENHANCED_XID"

XID(d5aad53e) [
    'isA': "Persona"
    "nickname": "BRadvoc8"
    "service": "GitHub" [
        'isA': "SourceCodeRepository"
        "account": "BRadvoc8" [
            "created_at": 2025-05-10T00:55:11Z
            "evidence": URI(https://api.github.com/users/BRadvoc8)
            "updated_at": 2025-05-10T00:55:28Z
        ]
    ]
    'key': PublicKeys(6d165468) [
        'allow': 'All'
        ELIDED
    ]
]
```

### Adding Resolution Info

To finish her XID, Amira will add resolution information to provide
ways for others to find this XID. This is crucial for discoverability
in decentralized systems where no central registry exists.

She creates URI objects for both a GitHub repository and a DID
(Decentralized Identifier) reference. The following commands create
properly typed URI objects using the XID_NAME variable, which is
important for systems that need to properly interpret and validate
these URLs:

```sh
GITHUB_REPO_URI=$(envelope subject type uri "https://github.com/$XID_NAME/$XID_NAME/$XID_NAME-public.envelope")
DID_URI=$(envelope subject type uri "did:repo:1ab31db40e48145c14f19bc735add0d279cdc62d/blob/main/$XID_NAME-public.envelope")
```

Each will be a properly typed URI envelope:

```
URI(https://github.com/BRadvoc8/BRadvoc8/BRadvoc8-public.envelope)
URI(did:repo:1ab31db40e48145c14f19bc735add0d279cdc62d/blob/main/BRadvoc8-public.envelope)
```

She adds these URIs to her XID as "resolveVia" assertions. By
providing multiple resolution methods, Amira ensures her XID can be
found through different channels, increasing resilience:

```sh
ENHANCED_XID=$(envelope assertion add pred-obj string "resolveVia" envelope "$GITHUB_REPO_URI" "$ENHANCED_XID")
ENHANCED_XID=$(envelope assertion add pred-obj string "resolveVia" envelope "$DID_URI" "$ENHANCED_XID")
```

### Signing the XID

Having completed the construction of her enhanced XID, Amira is now
ready to sign it. This will verify that she actually holds the private
key linked to the listed public key and also that she authenticates
the XID.

Before signing, Amira wraps the XID using the specific "wrapped"
type. This critical step ensures the signature applies to the entire
envelope with all its assertions, not just the subject. Without proper
wrapping, the signature would not apply to the rest of the XID structure.

```sh
WRAPPED_XID=$(envelope subject type wrapped "$ENHANCED_XID")
```

Finally, Amira signs the wrapped XID with her private key and displays
the result. This signature creates a cryptographic guarantee that this
XID and all its assertions were created by the holder of the private
key:

```sh
SIGNED_ENHANCED_XID=$(envelope sign -s "$XID_PRVKEY_BASE" "$WRAPPED_XID")
```

We can now view the signed, enhanced XID:
```sh
envelope format "$SIGNED_ENHANCED_XID"
```

It should look something like:


```
{
    XID(d5aad53e) [
        'isA': "Persona"
        "nickname": "BRadvoc8"
        "resolveVia": URI(did:repo:1ab31db40e48145c14f19bc735add0d279cdc62d/blob/main/BRadvoc8-public.envelope)
        "resolveVia": URI(https://github.com/BRadvoc8/BRadvoc8/BRadvoc8-public.envelope)
        "service": "GitHub" [
            'isA': "SourceCodeRepository"
            "account": "BRadvoc8" [
                "created_at": 2025-05-10T00:55:11Z
                "evidence": URI(https://api.github.com/users/BRadvoc8)
                "updated_at": 2025-05-10T00:55:28Z
            ]
        ]
        'key': PublicKeys(6d165468) [	
            'allow': 'All'
            ELIDED
        ]
    ]
} [
    'signed': Signature
]
```

Note that the structure looks a little different since we wrapped the
original envelope.  There are now curly braces `{}` surrounding the
XID (indicating it's wrapped) and square brackets `[]` surrounding the
'signed' assertion, showing that it applies to the wrapped element
above.

This enhanced, signed XID provides several important elements:

1. **Type Declaration** - The `isA: "Persona"` assertion clearly identifies this as a persona XID.
2. **Nickname** - The `nickname: "BRadvoc8"` provides a human-readable identifier.
3. **Multiple Resolution Methods** - Multiple `resolveVia` assertions provide different ways to find the XID.
4. **Service Information** - The `service` section contains detailed, structured information about BRadvoc8's GitHub account.
5. **Nested Structure** - The hierarchical structure allows for organizing related information (service → account → details).
6. **Proper Data Types** - Dates use the `date` type and URLs use the `uri` type for better semantic meaning.
7. **Proper Wrapping and Signing** - The XID is properly wrapped using the `wrapped` type before signing, creating a signature that covers the entire XID structure with all its assertions.

Here's a visual representation of the XID's hierarchical structure:

```mermaid
graph TD
    A["{Signed Wrapper}"] --> B["XID(d5aad53e)"]
    B --> C["'isA': Persona (known value)"]
    B --> D["\"nickname\": BRadvoc8 (string predicate)"]
    B --> E["\"service\": GitHub"]
    B --> F["\"resolveVia\": GitHub URI"]
    B --> G["\"resolveVia\": DID URI"]
    B --> H["'key': PublicKeys"]
    E --> I["'isA': SourceCodeRepository (known)"]
    E --> J["\"account\": BRadvoc8"]
    J --> K["\"created_at\": 2025-05-10"]
    J --> L["\"updated_at\": 2025-05-10"]
    J --> M["\"evidence\": URI(https://api.github.com/users/BRadvoc8)"]
    H --> N["'allow': All"]
    H --> O["ELIDED"]
    A --> P["'signed': Signature"]
```

To verify the authenticity of the signed XID, others would need to
verify its signature. This requires a public key, which can be derived
from the private key base:

```sh
PUBLIC_KEYS=$(envelope generate pubkeys "$XID_PRVKEY_BASE")
```

These public keys can be shared with others who need to verify attestations signed by this XID:

🔎
```
ur:crypto-pubkeys/hdcxtipscnhsondlbthsrfwzkefxttwttdgmkbvdtnlffsmsnsadwssyalrhlsrliaddlbehfcaflkfwelftbztk
```

> Note: The public keys output is in Uniform Resources (UR) format,
which provides a compact and reliable way to encode binary data using
text.


Now anyone with the pubic keys can verify the signature on the signed
XID. This verification process confirms that the XID was indeed signed
by the holder of the corresponding private key and hasn't been altered
since signing:

```sh
if envelope verify -v "$PUBLIC_KEYS" "$SIGNED_ENHANCED_XID"; then
    echo "✅ Signature verified! The enhanced XID is authentically from the XID holder."
else
    echo "❌ Signature verification failed."
fi
```

The verification confirms that the signature is valid:

```
ur:envelope/lftpsplttpsotanshdhdcxwesssfcmmwzmhlmesguyeorhdyeepkstlgeeetaoheeysbmsjpurbdaeaohfgheooytpsoim...
✅ Signature verified! The enhanced XID is authentically from the XID holder.
```

### Enhanced XID Summary

This signed, enhanced XID provides a complete digital representation
of Amira's persona that can be shared and verified by others, while
still protecting her private key material through elision.

> **XID Evolution Summary**:
>
> | **Step 1: Private XID** | **Step 2: Basic Public XID** | **Step 3: Enhanced XID** |
> |-------------------------|------------------------------|--------------------------|
> | Contains private keys   | Private keys elided          | Private keys elided      |
> | Not safe to share       | Safe to share                | Safe to share            |
> | Just cryptographic info | Just cryptographic info      | Rich structured identity |
> | No specific type        | No specific type             | Typed as "Persona"       |
> | No human-readable ID    | No human-readable ID         | BRadvoc8 nickname        |
> | No service information  | No service information       | GitHub account details   |
> | No resolution methods   | No resolution methods        | Multiple resolution URIs |
> | Not signed              | Not signed                   | Cryptographically signed |
> | Flat structure          | Flat structure               | Hierarchical organization|
> | For key operations only | For basic identification     | Full machine-readable ID |

## Understanding What Happened

1. **Privacy-Preserving Identity**: Amira created a pseudonymous XID
that allows her to contribute without revealing her real identity.

2. **Selective Disclosure**: She learned how to control exactly what
information she shares through elision, keeping sensitive information
private while sharing what's needed.

3. **Cryptographic Integrity**: She verified that even when certain
parts of the XID are removed, its cryptographic integrity remains
intact, providing non-repudiation and verifiability. (Elision could
have even occurred after Amira signed, not just before!)

4. **Verifiable Attestations**: She created and signed an attestation
that cryptographically links her XID to her GitHub account, allowing
her to build a verifiable online presence.

5. **Secure File Organization**: She established clear naming
conventions for different security levels of her XID files, ensuring
proper protection of sensitive material.

6. **Self-Sovereign Identity**: BRadvoc8's identity is fully under
Amira's control. No central authority issued this identifier, and she
maintains complete ownership of both the keys and the resulting XID
document.
   - **Why this matters**: Unlike traditional identities (email accounts,
social profiles) that can be suspended or controlled by
providers, BRadvoc8's XID remains under Amira's control
regardless of any third party.

7. **Pseudonymity vs. Anonymity**: This XID implements
**pseudonymity** rather than anonymity. The identity "BRadvoc8" can
build reputation and trust over time through verifiable contributions,
while still protecting Amira's real-world identity.
   - **Real-World Analogy**: This is similar to how authors might use pen
names (like Mark Twain for Samuel Clemens). They can build
reputation under their pseudonym while keeping their personal
identity separate.

## Next Steps

In the next tutorial, we'll explore the structure of Amira's XID in
detail and understand how XIDs work under the hood with Gordian
Envelopes.

## Example Script

This tutorial has an accompanying script:

**`../examples/01-basix-xid/create_basic_xid.sh`**: Implements all the
steps shown in this tutorial to create a pseudonymous XID. The
script automates the creation of private and public XIDs, including:

1. Creating the private XID with full key material
2. Creating a basic public XID with private keys elided
3. Creating an enhanced public XID with persona details and cryptographic signature

Running this script will produce the same outputs shown in this
tutorial and create all the necessary files in a timestamped output
directory (e.g., `xid-20250510123456`) for further experimentation.

When you run the script, you'll see files created with the following structure:

```
xid-20250510123456/
├── BRadvoc8-xid-basic-public.format    # Human-readable basic public XID
├── BRadvoc8-xid-basic-public.envelope       # Serialized basic public XID
├── BRadvoc8-xid-enhanced-public.envelope  # Serialized enhanced XID
├── BRadvoc8-xid-enhanced-public.format # Human-readable enhanced XID
├── BRadvoc8-xid-private.crypto-prvkey-base  # Private key material (SECRET!)
├── BRadvoc8-xid-private.format         # Human-readable private XID
├── BRadvoc8-xid-private.xid            # Serialized private XID
└── BRadvoc8-xid-public.crypto-pubkeys  # Public keys for verification
```

## Key Terminology

> **XID Terminology Reference**:
>
> - **XID** - eXtensible IDentifier; a digital container that includes cryptographic key material and can be extended with assertions.
>
> - **Assertion** - A claim made within an XID, consisting of a predicate (attribute name) and an object (attribute value).
>
> - **Elision** - The process of selectively removing private information from an XID while preserving its cryptographic integrity.
>
> - **Known Value** - A predicate with a standardized meaning in the Gordian Envelope system (e.g., `isA`, `dereferenceVia`). These appear with single quotes ('isA') in formatted output, distinguishing them from strings. The examples here are all known-value predicates, or "known predicates."
>
> - **Persona** - A pseudonymous identity represented by an XID, which can build reputation while protecting real-world identity.
>
> - **Resolution** - The process of finding and retrieving an XID through various methods, as specified in resolveVia assertions.

> - **Signature** - A cryptographic proof that an XID was created by the holder of a specific private key.
>
> - **String Predicate** - A custom predicate represented as a string (e.g., "nickname", "service"). These appear with double quotes in formatted output.
>
> - **Wrapped Type** - A specific envelope type (`wrapped`) that correctly prepares an XID for signing.
>
> - **Wrapping** - Enclosing an entire XID structure in an envelope before signing, ensuring the signature covers all assertions.

## Exercises

1. Create your own XID with a pseudonym and additional assertions of your choice.

2. Create and sign different types of attestations with your XID private key.

3. Experiment with eliding different parts of your XID for different audiences.

4. Try creating a more complex XID with nested assertions and verify that elision still preserves integrity.

5. Create a minimal XID with just a name and public key, then gradually add more information as you would in a real trust-building scenario.