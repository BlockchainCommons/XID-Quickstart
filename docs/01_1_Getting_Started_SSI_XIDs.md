# 1.1: Getting Started with SSI & XIDs

XIDs are a powerful new type of decentralized identifier, meant to
fulfill the original principles of self-sovereign identity, much of
which has been lost as the commercial market for DIDs has evolved.

Here's a bit more about what that all means.

## Understanding Self-Sovereign Identity

The concept of self-sovereign identity (SSI) was popularized in ["The
Path to Self-Sovereign
Identity"](https://www.lifewithalacrity.com/article/the-path-to-self-soverereign-identity/)
and through the [Rebooting the Web of Trust
workshops](https://www.weboftrust.info/events/). The idea was simple:
people should control their digital identities, not be beholden to
centralized entities such as Google and Facebook who can remove their
identity at a whim.

That original article laid out ten principles for what SSI should
include: existence, control, access, transparency, persistence,
portability, interoperability, consent, minimization, and
protection. Those principles are still being [discussed
today](https://revisitingssi.com/) but their foundations are strong:
users should have full visibility on their identity, they should have
principal authority over it, and they should be able to move it around as
they see fit.

Unfortunately, as the SSI ecosystem matured, it has moved away from
these core principles, as discussed in ["Has our SSI Ecosystem Become
Morally
Bankrupt?"](https://www.blockchaincommons.com/musings/musings-ssi-bankruptcy/). Issuers
took control of identities and created centralized points-of-failure
and even centralized logging of identity usage. Many SSI deployments
ultimately reiterated the problems of centralized identity: they
weren't truly self-sovereign.

## Understanding XIDs

XIDs were invented to offer a new model for self-sovereign identity
that goes back to first principles. ["How XIDs Demonstrate a True
Self-Sovereign
Identity"](https://www.blockchaincommons.com/musings/XIDs-True-SSI/)
talks about many of the ways that they go back to those principles.

It starts out with the core design: a XID is an autonomous
cryptographic object (ACO). It's a self-sufficient package that
contains an identifier, keys to control that identifier, and other
data. You don't need to depend on any infrastructure: there's no
separate issuer or verifier, no centralized authority at all. It's
holder-created and holder-controlled. That's the dream of
self-sovereign identity.

The other major design element of the XID is a holder's ability to
redact (elide) content. This allows for selective disclosure (you
decide exactly what to give out to each person) and data minimization
(you release only the amount of information that's required). Although
data minimization has long been given lip service, it's rarely been
well-supported. Even when self-sovereign identity has enabled
redaction, _what_ you can redact has often been controlled by an
issuer (which violates the most central vision of SSI).

The technology in XIDs is novel (including deterministic encoding,
radical elision, and progressive trust). The privacy is greatly
improved over existing systems that put issuers in the driver's
seat. Finally, it's supported by radically private communication
methods such as
[Garner](https://developer.blockchaincommons.com/garner/), which
ensure your self-sovereign identity is supported by self-sovereign
networking.

If you believe in self-sovereign identity (or privacy or novel
technologies or improving the specifications we already have), then
XIDs are for you.

## Getting Started with XIDs

Working with XIDs in this tutorial will give you hands-on experience
with how you can maintain a stable identifier even through key
rotation, device additions, and recovery scenarios. It will also
demonstrate how to cryptographically elide data while maintaining
verifiability through signatures.

### Learning XIDs

The heart of this course is the [Learning XIDs tutorial](index.md). We
suggest downloading the few pieces of required software and running
all the commands discussed in the tutorial one at a time, to get a
feel for how everything works. Explore the results, digging into them
further if you wish, as that's the power of a hands-on course like
this.

### Core Concepts

A set of [Core Concepts
documents](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/concepts/README.md)
were written in conjunction with the course. They're not an integrated
part of the "Learning XIDs" tutorial, but they offer deep hands-on
exercises for a variety of related technologies.

In particular, we suggest reading three fundamental concepts before
you start in on the course:
[XIDs](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/concepts/xid.md),
[Gordian
Envelope](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/concepts/gordian-envelope.md),
and [Data
Minimization](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/concepts/data-minimization.md). At
a future point, we expect to move these to the [Developer web
pages](https://developer.blockchaincommons.com/) or their own course.

## Summary: Doing Self-Sovereign Identity Right

Self-sovereign identity was a dream of giving us all autonomy on the
internet: the ability to control who we are, and for those identities
not to be ripped away from us by centralized entities.

It failed.

XIDs are intended as a model for self-sovereign identity done right:
focused on the holder, not an issuer or verifier.

## What's Next

You now know what a XID is and should be ready to create one, which
you'll do in [§1.2: Creating Your First XID](01_2_Your_First_XID.md ).

