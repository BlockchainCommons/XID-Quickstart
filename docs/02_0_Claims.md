# Chapter Two: Making Claims (And Protecting Them)

A XID is just an identifier: a pseudonymous label that allows for
consistent reference over time. Keys and a provenance mark support it,
but they're ultimately infrastructure: the keys control the
identifier, and the provenenance mark supports updates.

For an _identifier_ to truly become an _identity_ requires more: it
requires a rich collection of data that define and describe the real
person behind the identifier (or at least the persona that they embody
when they interact using the identifier).

A variety of content will be added to an identifier over this course,
and the first of those will be self-attestations: claims made by the
owner of the identifier themself. However, these first, simple claims
also offer the first danger of a breach in the cloak of pseudonymity
that a XID offers, so the addition of claims must go hand in hand with
the discussion of how to properly protect them.

## Major Objectives for this Chapter

After working through this chapter, a developer will be able to:

- Register additional keys in their XID.
- Create attestations that are publicly verifiable.
- Advance provenance marks.
- Commit to claims.
- Encrypt claims.

Supporting objectives include the ability to:

- Understand the **fair witness methodology** for making credible claims.
- Recognize correlation risks.
- Know the difference between a variety of types of attestations.
- Choose between a variety of methods for handling sensitive information

## Table of Contents

* [Section One: Creating Self Attestation](02_1_Creating_Self_Attestations.md)
* [Section Two: Managing Sensitive Claims with Elision](02_2_Managing_Claims_Elision.md)
* [Section Three: Managing Sensitive Claims with Encryption](02_3_Managing_Claims_Encryption.md)
