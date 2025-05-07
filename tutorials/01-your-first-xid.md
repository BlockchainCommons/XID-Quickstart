# Creating Your First XID

This tutorial introduces Amira, a software developer with a politically sensitive background who wants to contribute to social impact projects without risking her professional position or revealing her identity. By the end, you'll have created an XID (eXtensible IDentifier) that enables pseudonymous contributions while building trust progressively.

**Time to complete: 15-20 minutes**

> **Related Concepts**: Before or after completing this tutorial, you may want to read about [XID Fundamentals](../concepts/xid-fundamentals.md) and [Gordian Envelope Basics](../concepts/gordian-envelope-basics.md) to understand the theoretical foundations behind what you're implementing.

## Prerequisites

- Basic terminal/command line familiarity
- The envelope CLI tool installed
- SSH key utilities (ssh-keygen) for creating Git signing keys

## What You'll Learn

- How to create a minimal XID for pseudonymous contributions
- How to link your XID to GitHub with SSH keys
- How to sign a basic attestation with your XID
- How to maintain pseudonymity while contributing to projects

## Amira's Story: Why Pseudonymous Identity Matters

Amira is a successful software developer working at a prestigious multinational bank in Boston. With her expertise in distributed systems security, she earns a comfortable living, but she wants more purpose in her work. On the advice of her friend Charlene, Amira discovers RISK - a network that connects developers with social impact projects while protecting participants' privacy.

Given her background from a politically tense region, contributing openly to certain social impact projects could risk her visa status, professional position, or even the safety of family members back home. Yet she's deeply motivated to use her skills to help oppressed people globally. This tension between professional security and meaningful contribution creates a specific need.

Amira needs a technological solution that allows her to:

1. Share her valuable security expertise without revealing her real identity
2. Build verifiable trust through the quality of her work, not her existing credentials
3. Establish a consistent "BWHacker" digital presence that can evolve and build reputation over time
4. Connect with project leaders like Ben from the women's services non-profit
5. Protect herself from adversaries like Elias who might target her for her contributions

This is where XIDs come in - they enable pseudonymous identity with progressive trust development, allowing Amira to safely collaborate on projects aligned with her values while maintaining separation between her pseudonymous contributions and her legal identity.

## Why XIDs Matter

XIDs provide significant advantages that go well beyond standard cryptographic keys:

1. **Stable identity** - XIDs maintain the same identifier even when you rotate keys
2. **Progressive disclosure** - XIDs let you selectively share different information with different parties
3. **Rich metadata** - XIDs can contain structured attestations, endorsements, and claims
4. **Peer validation** - XIDs enable others to make cryptographically verifiable claims about your identity
5. **Multi-key support** - XIDs can link multiple keys for different devices while maintaining a single identity
6. **Recovery mechanisms** - XIDs support social recovery without losing your reputation history

This first tutorial is deliberately simple to get you started with the basics. While we're using SSH keys in this tutorial (which offer excellent synergy with Git for pseudonymous software development), Gordian XIDs support many cryptographic key types, including advanced formats for threshold signatures and post-quantum cryptography. As we progress through subsequent tutorials, we'll explore these more advanced capabilities in depth.

## 1. Creating a Secure Foundation with Keys

First, Amira needs to generate cryptographic keys as the foundation for her pseudonymous identity. She'll create both SSH keys for Git operations and XID keys for her digital identity.

Generate an SSH key for Git authentication and commit signing:

👉 
```sh
SSH_KEY_FILE="./bwhacker-ssh-key"
SSH_PUB_KEY_FILE="${SSH_KEY_FILE}.pub"
ssh-keygen -t ed25519 -f "$SSH_KEY_FILE" -N "" -C "BWHacker <bwhacker@example.com>"
```

This creates an SSH key pair that Amira can use for signing Git commits and authenticating to GitHub, all while using her pseudonym.

Extract the SSH public key and fingerprint:

👉 
```sh
SSH_PUB_KEY=$(cat "$SSH_PUB_KEY_FILE")
SSH_KEY_FINGERPRINT=$(ssh-keygen -l -E sha256 -f "$SSH_PUB_KEY_FILE" | awk '{print $2}')
echo "SSH public key fingerprint: $SSH_KEY_FINGERPRINT"
```

🔍 
```console
SSH public key fingerprint: SHA256:dFbxBGrqMQNJKpZccInX7l/QE1xH/jNzDvUo/jICSHE
```

Now, generate a separate private key for her XID:

👉 
```sh
envelope generate prvkeys > bwhacker-key.private
echo "Private key generated - keep this secret and secure!"
```

🔍 
```console
Private key generated - keep this secret and secure!
```

This XID private key must be kept secure - it's what Amira will use to prove ownership of her identity document without revealing who she is.

Derive the corresponding public key from the private key:

👉 
```sh
PRIVATE_KEYS=$(cat bwhacker-key.private)
PUBLIC_KEYS=$(envelope generate pubkeys "$PRIVATE_KEYS")
echo "$PUBLIC_KEYS" > bwhacker-key.public
```

View the public key (which is safe to share):

👉 
```sh
cat bwhacker-key.public | head -n 1
```

🔍 
```console
ur:crypto-pubkeys/hdcxlkadjnghfejtmyyloeadmyfqzswdaeayfnmddpjygtmyaeaelytsqdisaeaeaeae
```

## 2. Creating a Minimal Pseudonymous XID

Next, Amira creates an XID with her pseudonym "BWHacker" (Better World Hacker), which she'll use for contributing to projects that align with her values.

Create the pseudonymous XID:

👉 
```sh
envelope xid new --name "BWHacker" "$PUBLIC_KEYS" > bwhacker-xid.envelope
```

View the minimal XID structure:

👉 
```sh
XID_DOC=$(cat bwhacker-xid.envelope)
envelope format --type tree "$XID_DOC"
```

🔍 
```console
"BWHacker" [
   "name": "BWHacker"
   "publicKeys": ur:crypto-pubkeys/hdcxlkadjnghfejtmyyloeadmyfqzswdaeayfnmddpjygtmyaeaelytsqdisaeaeaeae
]
```

This minimal structure only reveals her chosen pseudonym, nothing about her real identity or background.

## 3. Understanding the XID Identifier

Extract the unique XID identifier that will represent her consistently:

👉 
```sh
XID_ID=$(envelope xid id "$XID_DOC")
echo "XID identifier: $XID_ID"
```

🔍 
```console
XID identifier: 7e1e25d7c4b9e4c92753f4476158e972be2fbbd9dffdd13b0561b5f1177826d3
```

This identifier is derived cryptographically but remains stable even if Amira later updates her keys. Others can consistently reference this identifier without knowing Amira's real identity.

## 4. Adding GitHub Identity with SSH Key Verification

Amira now wants to create a verifiable link between her XID and her GitHub activity, without revealing her real identity.

Add her GitHub identity:

👉 
```sh
XID_DOC=$(envelope assertion add pred-obj string "gitHubUsername" string "BWHacker" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "gitHubProfileURL" string "https://github.com/BWHacker" "$XID_DOC")
```

Link her SSH key to enable verification of her Git commits:

👉 
```sh
XID_DOC=$(envelope assertion add pred-obj string "sshKey" string "$SSH_PUB_KEY" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "sshKeyFingerprint" string "$SSH_KEY_FINGERPRINT" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "sshKeyVerificationURL" string "https://api.github.com/users/BWHacker/ssh_signing_keys" "$XID_DOC")
```

Add basic professional information:

👉 
```sh
XID_DOC=$(envelope assertion add pred-obj string "domain" string "Distributed Systems & Security" "$XID_DOC")
XID_DOC=$(envelope assertion add pred-obj string "experienceLevel" string "8 years professional practice" "$XID_DOC")
```

Save the updated XID:

👉 
```sh
echo "$XID_DOC" > bwhacker-xid.envelope
```

View the enhanced XID:

👉 
```sh
envelope format --type tree "$XID_DOC"
```

🔍 
```console
"BWHacker" [
   "name": "BWHacker"
   "publicKeys": ur:crypto-pubkeys/hdcxlkadjnghfejtmyyloeadmyfqzswdaeayfnmddpjygtmyaeaelytsqdisaeaeaeae
   "gitHubUsername": "BWHacker"
   "gitHubProfileURL": "https://github.com/BWHacker"
   "sshKey": "ssh-ed25519 AAAAC3NzaC... BWHacker <bwhacker@example.com>"
   "sshKeyFingerprint": "SHA256:dFbxBGrqMQNJKpZccInX7l/QE1xH/jNzDvUo/jICSHE"
   "sshKeyVerificationURL": "https://api.github.com/users/BWHacker/ssh_signing_keys"
   "domain": "Distributed Systems & Security"
   "experienceLevel": "8 years professional practice"
]
```

## 5. Organizing Your XID Files

Organize the XID and SSH key information in a project directory:

👉 
```sh
mkdir -p output
cp bwhacker-xid.envelope output/bwhacker-xid.envelope
cp "$SSH_KEY_FILE" output/
cp "$SSH_PUB_KEY_FILE" output/
ls -la output/
```

🔍 
```console
total 32
drwxr-xr-x  5 user  staff  160 Apr 29 14:32 .
drwxr-xr-x  7 user  staff  224 Apr 29 14:32 ..
-rw-r--r--  1 user  staff  524 Apr 29 14:32 bwhacker-xid.envelope
-rw-------  1 user  staff  419 Apr 29 14:32 bwhacker-ssh-key
-rw-r--r--  1 user  staff  110 Apr 29 14:32 bwhacker-ssh-key.pub
```

## 6. Creating and Signing a Basic Attestation

Now Amira will create a simple attestation about her skills and sign it with her XID key:

👉 
```sh
ATTESTATION=$(envelope subject type string "Skill Attestation")
ATTESTATION=$(envelope assertion add pred-obj string "skill" string "Rust Programming" "$ATTESTATION")
ATTESTATION=$(envelope assertion add pred-obj string "experienceYears" string "3" "$ATTESTATION")
ATTESTATION=$(envelope assertion add pred-obj string "projectCount" string "5" "$ATTESTATION")
```

First, wrap the attestation before signing. This critical step ensures the signature applies to the entire envelope with all its assertions, not just the subject:

👉 
```sh
WRAPPED_ATTESTATION=$(envelope subject type wrapped "$ATTESTATION")
```

Then sign the wrapped attestation with her private key:

👉 
```sh
SIGNED_ATTESTATION=$(envelope sign -s "$PRIVATE_KEYS" "$WRAPPED_ATTESTATION")
echo "$SIGNED_ATTESTATION" > output/bwhacker-skill-attestation-signed.envelope
```

View the signed attestation:

👉 
```sh
envelope format --type tree "$SIGNED_ATTESTATION"
```

🔍 
```console
WRAPPED [
   subject: "Skill Attestation" [
      "skill": "Rust Programming"
      "experienceYears": "3"
      "projectCount": "5"
   ]
   SIGNATURE
]
```

Verify the signature to confirm it came from the XID holder:

👉 
```sh
if envelope verify -v "$PUBLIC_KEYS" "$SIGNED_ATTESTATION"; then
    echo "✅ Signature verified. The attestation is authentically from the XID holder."
  else
    echo "❌ Signature verification failed."
  fi
```

🔍 
```console
✅ Signature verified. The attestation is authentically from the XID holder.
```

## 7. Configuring Git for SSH Key Signing

Finally, Amira sets up Git to use her SSH key for signing commits, creating a link between her XID and her Git contributions:

👉 
```sh
echo "Git configuration commands for SSH signing:"
echo "git config --local user.name \"BWHacker\""
echo "git config --local user.email \"bwhacker@example.com\""
echo "git config --local user.signingkey \"$SSH_KEY_FILE\""
echo "git config --local gpg.format ssh"
echo "git config --local commit.gpgsign true"
```

🔍 
```console
Git configuration commands for SSH signing:
git config --local user.name "BWHacker"
git config --local user.email "bwhacker@example.com"
git config --local user.signingkey "./amira-ssh-key"
git config --local gpg.format ssh
git config --local commit.gpgsign true
```

With this configuration, all of Amira's Git commits will be signed with the same SSH key referenced in her XID.

## Understanding What Happened

1. **Privacy-Preserving Identity**: Amira created a pseudonymous XID that allows her to contribute without revealing her real identity.

2. **SSH Key Integration**: She generated an SSH key for her pseudonymous identity and included it in her XID to enable Git commit signing.

3. **Minimal Yet Verifiable**: She created a simple identity with just enough information to be useful, while maintaining her privacy.

4. **Signature Verification**: She demonstrated how signatures can verify that content came from her pseudonymous identity.

5. **GitHub Connection**: The SSH key creates a verifiable link between her XID and her GitHub activity.

### Theory to Practice: XID Creation and Core Identity Principles

The XID you just created demonstrates several foundational identity concepts:

1. **Self-Sovereign Identity**: BWHacker's identity is fully under Amira's control. No central authority issued this identifier, and Amira maintains complete ownership of both the keys and the resulting XID document.
   > **Why this matters**: Unlike traditional identities (email accounts, social profiles) that can be suspended or controlled by providers, BWHacker's XID remains under Amira's control regardless of any third party.

2. **Stable Identifier**: The 32-byte hexadecimal identifier (7e1e25d7c4b9...) produced by `envelope xid id` is derived cryptographically from the inception key but remains stable even if Amira later updates her keys.
   > **Cross-Tutorial Connection**: In Tutorial #5, you'll see this principle in action when BWHacker rotates keys and recovers from key loss while maintaining this same stable identifier.

3. **Pseudonymity vs. Anonymity**: This XID implements **pseudonymity** rather than anonymity. The identity "BWHacker" can build reputation and trust over time through verifiable contributions, while still protecting Amira's real-world identity.
   > **Real-World Analogy**: This is similar to how authors might use pen names (like Mark Twain for Samuel Clemens) - they can build reputation under their pseudonym while keeping their personal identity separate.

4. **Cryptographic Binding**: The cryptographic foundation for this identity provides non-repudiation - where control of the identity is proven through possession of private keys rather than knowledge-based authentication (like passwords), providing significantly stronger security.
   > **ANTI-PATTERN**: Using password-based authentication for identity systems provides weaker security than cryptographic keys. Passwords can be guessed, stolen, or shared, while private keys remain securely in the owner's possession.

5. **Subject-Assertion Model**: The XID document follows Gordian Envelope's subject-assertion-object model, where the subject (BWHacker's identity) is connected to assertions (name, keys) in a cryptographically verifiable structure.

These principles form the foundation of the XID trust model, where identifiers are self-created, cryptographically verifiable, and maintain separation between digital and physical identities.

## Next Steps

In the next tutorial, we'll explore the structure of Amira's XID in detail and understand how XIDs work under the hood with Gordian Envelopes.

## Example Script

This tutorial has an accompanying script in the `examples/01-basic-xid` directory:

**`create_basic_xid.sh`**: Implements all the steps shown in this tutorial to create a pseudonymous XID with SSH key integration. The script automates the creation of keys, XID generation, and signing of a basic attestation.

Running this script will produce the same outputs shown in this tutorial and create all the necessary files in the output directory for further experimentation.

## Exercises

1. Create your own XID with a pseudonym and SSH key.

2. Add different assertions to your XID that express your skills without revealing your identity.

3. Create and sign a simple attestation with your XID private key.

4. Configure a local Git repository to use your SSH key for signing commits.

5. Try creating a minimal XID with just a name and public key, then gradually add more information.