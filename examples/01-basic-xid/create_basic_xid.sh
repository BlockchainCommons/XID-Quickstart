#!/bin/bash
# 01-your-first-xid.sh
#
# Creates three versions of an XID for pseudonymous identity:
# 1. Private XID with all keys
# 2. Basic public XID (just elided private key)
# 3. Enhanced public XID with persona details and signature

set -e  # Exit on any error

# Define XID name
XID_NAME="BRadvoc8"

# Create output directory
OUTPUT_DIR="xid-$(date +%Y%m%d%H%M%S)"
mkdir -p "$OUTPUT_DIR"

echo "## Step 1: Creating Private XID"

# Generate a private key base for XID
XID_PRVKEY_BASE=$(envelope generate prvkeys)
echo "Generated private key base for XID"

# Create a new XID with the private key
XID=$(envelope xid new "$XID_PRVKEY_BASE")
echo "Created new private XID"

# Display the private XID structure
echo -e "\nPrivate XID structure:"
envelope format "$XID"

# Save the private key base and XID
echo "$XID_PRVKEY_BASE" > "$OUTPUT_DIR/${XID_NAME}-xid-private.crypto-prvkey-base"
echo "$XID" > "$OUTPUT_DIR/${XID_NAME}-xid-private.xid"
envelope format "$XID" > "$OUTPUT_DIR/${XID_NAME}-xid-private.format"

# Extract key assertion and find private key
KEY_ASSERTION=$(envelope xid key at 0 "$XID")
PRIVATE_KEY_ASSERTION=$(envelope assertion find predicate known privateKey "$KEY_ASSERTION")
PRIVATE_KEY_ASSERTION_DIGEST=$(envelope digest "$PRIVATE_KEY_ASSERTION")

echo -e "\n## Step 2: Creating Basic Public XID"

# Elide private key from XID to create basic public version
BASIC_PUBLIC_XID=$(envelope elide removing "$PRIVATE_KEY_ASSERTION_DIGEST" "$XID")
echo "Created basic public XID"

# Display the basic public XID
echo -e "\nBasic Public XID:"
envelope format "$BASIC_PUBLIC_XID"

# Save the basic public XID
echo "$BASIC_PUBLIC_XID" > "$OUTPUT_DIR/${XID_NAME}-xid-basic-public.xid"
envelope format "$BASIC_PUBLIC_XID" > "$OUTPUT_DIR/${XID_NAME}-xid-basic-public.format"

echo -e "\n## Step 3: Creating Enhanced Public XID with Persona Details"

# Start with the basic public XID
ENHANCED_XID="$BASIC_PUBLIC_XID"

# Add isA assertion (using known value, not string)
ENHANCED_XID=$(envelope assertion add pred-obj known isA string "Persona" "$ENHANCED_XID")
echo "Added 'isA: Persona' assertion as a known predicate"

# Add nickname assertion
ENHANCED_XID=$(envelope assertion add pred-obj string "nickname" string "$XID_NAME" "$ENHANCED_XID")
echo "Added nickname assertion: $XID_NAME"

# Create GitHub account information with proper date types
GITHUB_ACCOUNT=$(envelope subject type string "$XID_NAME")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "created_at" date "2025-05-10T00:55:11Z" "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "updated_at" date "2025-05-10T00:55:28Z" "$GITHUB_ACCOUNT")
GITHUB_ACCOUNT=$(envelope assertion add pred-obj string "evidence" uri "https://api.github.com/users/$XID_NAME" "$GITHUB_ACCOUNT")

# Create a service envelope that contains the account information
GITHUB_SERVICE=$(envelope subject type string "GitHub")
# Add the type of service (using known isA predicate)
GITHUB_SERVICE=$(envelope assertion add pred-obj known isA string "SourceCodeRepository" "$GITHUB_SERVICE")
GITHUB_SERVICE=$(envelope assertion add pred-obj string "account" envelope "$GITHUB_ACCOUNT" "$GITHUB_SERVICE")

# Add the service information to the XID
ENHANCED_XID=$(envelope assertion add pred-obj string "service" envelope "$GITHUB_SERVICE" "$ENHANCED_XID")
echo "Added GitHub service information with account details"

# Create resolveVia URIs with proper URI type
GITHUB_REPO_URI=$(envelope subject type uri "https://github.com/$XID_NAME/$XID_NAME/$XID_NAME-public.envelope")
DID_URI=$(envelope subject type uri "did:repo:1ab31db40e48145c14f19bc735add0d279cdc62d/blob/main/$XID_NAME-public.envelope")

# Add individual resolveVia assertions directly to the XID
ENHANCED_XID=$(envelope assertion add pred-obj string "resolveVia" envelope "$GITHUB_REPO_URI" "$ENHANCED_XID")
ENHANCED_XID=$(envelope assertion add pred-obj string "resolveVia" envelope "$DID_URI" "$ENHANCED_XID")
echo "Added resolveVia URLs for resolution"

# Wrap the entire XID before signing - using wrapped type is critical for proper signatures
WRAPPED_XID=$(envelope subject type wrapped "$ENHANCED_XID")
echo "Wrapped the XID for signing (using wrapped type)"

# Sign the wrapped XID
SIGNED_ENHANCED_XID=$(envelope sign -s "$XID_PRVKEY_BASE" "$WRAPPED_XID")
echo "Created and signed enhanced public XID"

# Display the enhanced public XID
echo -e "\nEnhanced Public XID (with signature):"
envelope format "$SIGNED_ENHANCED_XID"

# Save the enhanced public XID
echo "$SIGNED_ENHANCED_XID" > "$OUTPUT_DIR/${XID_NAME}-xid-enhanced-public.envelope"
envelope format "$SIGNED_ENHANCED_XID" > "$OUTPUT_DIR/${XID_NAME}-xid-enhanced-public.format"

# Generate public keys for verification
PUBLIC_KEYS=$(envelope generate pubkeys "$XID_PRVKEY_BASE")
echo "$PUBLIC_KEYS" > "$OUTPUT_DIR/${XID_NAME}-xid-public.crypto-pubkeys"

# Verify the signature
echo -e "\nVerifying XID signature..."
if envelope verify -v "$PUBLIC_KEYS" "$SIGNED_ENHANCED_XID"; then
    echo "✅ XID signature verified! The enhanced XID is authentic."
else
    echo "❌ XID signature verification failed."
fi

echo -e "\nAll files have been created in the $OUTPUT_DIR directory."
ls -la "$OUTPUT_DIR"
echo "XID creation completed successfully!"