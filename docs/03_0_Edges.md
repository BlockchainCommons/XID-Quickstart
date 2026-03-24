# Chapter Three: Working with Edges

Claims and other credentials offer crucial support for an XID. They
reveal the experience of the person behind the digital identity;
learning about that improves progressive trust.

To date, this course has focused on detached claims. Often this is
because claims are small enough that they shouldn't be cluttering up
the XID Document that's fundamental to the description of an
identity. But sometimes it's because claims are sensitive and may need
to be hidden in various ways.

This isn't always the case. There are claims (and other data) that are
important enough that they should be linked to the XID in a more
permanent way. They can still be elided: any data on a XID can be
redacted to ensure data minimization. But, because of their
importance, they need be embedded within the XID rather than being
separate.

This chapter will discuss a variety of ways to add data to a XID using
_edges_, which are a methodology for placing a claim directly on a
XID. It will also talk about how to produce clean views of a XID, even
when it's grown quite complex.

## Major Objectives for this Chapter

After working through this chapter, a developer will be able to:

- Create self-attestation edges
- Create peer endorsement edges
- Extract attestations from XIDs
- Remove elements from XIDs
- Build a Web of Trust

Supporting objectives include the ability to:

- Know different methodologies for linking data to XIDs
- Understand the difference between self-attestations and peer endorsements
- Know the value of relationship transparency

## Table of Contents

* [Section One: Creating Edges](03_1_Creating_Edges.md)
* [Section Two: Supporting Cross Verification](03_2_Supporting_Cross_Verification.md)
* [Section Three: Creating Peer Endorsements](03_3_Creating_Peer_Endorsements.md)
* [Section Four: Creating Binding Agreements](03_4_Creating_Binding_Agreements.md)
* [Section Five: Creating Views and Versions](03_5_Creating_Views_and_Versions.md)
