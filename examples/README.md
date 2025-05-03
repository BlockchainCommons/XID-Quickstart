# XID Tutorial Examples

This directory contains example scripts that implement the functionality covered in each tutorial. These scripts provide complete, working implementations that you can use to experiment with XIDs.

## Example Structure

Each subdirectory corresponds to a specific tutorial:

1. **01-basic-xid** - Creating your first XID
2. **02-xid-structure** - Understanding XID structure
3. **03-profile-xid** - Self-attestation with XIDs
4. **04-peer-endorsement** - Peer endorsement with XIDs
5. **05-key-management** - Key management with XIDs

## Running the Examples

Each example directory contains shell scripts that demonstrate the concepts from the corresponding tutorial.

To run an example:

```sh
cd examples/01-basic-xid
./create_basic_xid.sh
```

The script output will show you the steps and results similar to what you would see when following the tutorial manually.

## Directory Contents

Each example directory typically contains:

- **Shell scripts** that implement the tutorial functionality
- An **output** subdirectory where generated files are stored
- Any **key files** needed for the examples

## Example Use Cases

- **Learning**: Run the examples to see XIDs in action before trying the tutorials
- **Testing**: Use the examples to validate your understanding after completing a tutorial
- **Development**: Reference the examples when building your own XID applications
- **Troubleshooting**: Compare your work with the examples when debugging issues

## Prerequisites

The same prerequisites for the tutorials apply to these examples:

- The `envelope` CLI tool installed
- Basic familiarity with the command line
- No prior knowledge of XIDs or Gordian Envelope is required