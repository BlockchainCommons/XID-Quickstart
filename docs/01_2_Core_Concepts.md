# 1.2: Understanding Core Concepts

Self-sovereign identity tells the core story of XIDs: why they exist
and what they do. However, XIDs are built on a number of additional
core concepts. They're all detailed in the [Core Concepts
documents](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/concepts/README.md)
and further summarized here.

All of the core concepts are useful for understanding XIDs, but you
may particularly want to read the discussions of [Data
Minimization](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/concepts/data-minimization.md)
and the technologies for
[XIDs](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/concepts/xid.md)
and [Gordian
Envelope](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/concepts/gordian-envelope.md).

## Core Philosophies

[**Attestation & Endorsement
Model**](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/concepts/attestation-endorsement-model.md). An
attestation is a formal statement of something. Broadly, it can come
in two forms: a self-attestation, which is a formal statement you make
about yourself, and a peer endorsement, which is a formal statement
that you make about something else. Attestations and endorsements are
closely related to claims and credentials in the larger world of
identity.

An attestation is most powerful if it's provable, partially or
fully. Building out context for an attestation can also help in
that. Beyond that, the value of an attestation ultimately depends on
the reputation of the person making the attestation. Your
self-attestations, beyond what can be proven, are only as strong as
your reputation. Your peer endorsements ultimately lend your
reputation to the people your endorse: if they prove incorrect, your
reputation suffers.

[**Data
Minimization**](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/concepts/data-minimization.md). The
concept behind data minimization is simple: you should disclose the
minimal amount of data that you need to at any time. Making an
age-restricted purchase is the traditional example: you shouldn't have
to show your driver's license, which has lots of other personal
information about you, you shouldn't even have to reveal your age,
simply that your age is within the range that allows the purchase.

This isn't a philosophical question of privacy. Every bit of
information that you reveal is dangerous. It might allow correlation,
revealing something more than you intended. It might be used for
purposes that you didn't intend. It might create possibilities for
coercion. It might cause prejudice or disadvantage. And every bit of
data that you reveal is potentially out there forever.

[**Elision
Cryptography**](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/concepts/elision-cryptography.md). One
way to support _Data Minimization_ is to selectively elide (remove)
information from documents before you send them out, ensuring that
what you send to each person only contains the information that you
need to know.

Crypographic elision takes the next step: it preserves hashes of
elided data so that you can later prove that the data was in a
document, even after it is removed. If signatures are made across data
hashes, rather than the data itself, then the signatures also remain
valid. This allows for the creation of signed credentials that the
credential holder can selectively elide to ensure _Data Minimization_.

[**The Fair Witness
Approach**](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/concepts/fair-witness.md).
Another way to increase the value of _Endorsements_ and other
_Attestation_ is by using the fair witness approach: you carefully
attest to only what you can independently determine, you acknowledge
any biases in the observation, you add context that's important to the
observation, and you document it all as part of the _Attestation_.

Even if a fair-witness _Attestation_ reveals bias, it can still be
more valuable than an _Attestation_ without that contextual
information, because it allows the reader of the _Attestation_ to better
assess what it actually means.

[**Key
Management**](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/concepts/key-management.md). Keys
are what make the trustless world of cryptographic identities and
digital assets go 'round. They're what control your identity and
assets, and what you use to prove ownership of the same. Without the
keys, you literally have nothing.

Key management is what ensures you maintain control of those
things. Its built on a foundation of heterogeneity, meaning that you
use different keys for different things, so that when you lose one,
you don't lose everything. Beyond that, it requires key rotation and
revocation as things change over time.

[**The Progressive Trust Life
Cycle**](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/concepts/progressive-trust.md). In
real life, trust is a progressive thing. When you meet someone and
grow your relationship over years, you slowly extend new information
to them, slowly learn new things about them, and so over time gain
increasing trust of them (or possibly the opposite, depending on what
you learn).

The progressive trust life cycle models real-world relationships as a life
cycle of increased disclosure and trust. It's intended as a foundation
for how digital relationships can be similarly modeled, in part by
using the concept of _Data Minimization_. This replaces the
all-or-nothing disclosure that is much more common on the 'net today.

[**Pseudonymous Trust
Building**](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/concepts/pseudonymous-trust-building.md). Revealing
your identity can be dangerous. This has become very obvious in recent
years when judges, politicians, and other people impacting the civil
society of America have been targeted and even killed for what they
said or did. One solution is to adopt a pseudonymous identity: a
stable identity that is not associated with your real-world self.

The problem with pseudonymous identities is creating trust for
them. However, that trust can be bootstrapped through a _Progressive
Trust Life Cycle_ that includes quality work, verifiable
self-attestations, and contextual peer endorsements. Over time, a
pseudonymous identity can gain as much trust as a real-world identity.

[**Public Participation
Profiles**](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/concepts/public-participation-profiles.md). Public
participation profiles are _Pseudonymous_ identities that are created
specifically so that the identity holder can engage in public
projects.

There are risks to participation, as they can expose information that
you hadn't intended, and managing your pseudonymous identity requires
all of the care of any _Pseudonymous_ identity. But there can also be
rewards in good work done.

## Core Technologies

[**Gordian
Envelope**](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/concepts/gordian-envelope.md). The
Gordian Envelope is a "smart document" system that collects and
displays data in a regularized, deterministic way. Its recursive
design allows for the storage of great depths of information, while
its self-describing foundation ensures that it's always possible to
see what a Gordian Envelope is and what it contains.

One of the greatest strengths of Gordian Envelope is its use of
_Elision Cryptopgraphy_. The holder of an envelope can practice _Data
Minimization_ by eliding any information in an envelope while
maintaining any signatures on the envelope and any credentials it
might hold.

[**XID**](https://github.com/BlockchainCommons/XID-Quickstart/blob/main/concepts/xid.md). Obviously this whole course is about XIDs,
Blockchain Commons' self-sovereign identifier. The XID core concept
document briefly outlines what a XID is, what it contains, and how
it's created.

XIDs are built on _Gordian Envelope_ using a tight structure that
limits what objects can be placed at the top level of an envelope to
standardize and simplify their content.

## Summary: Getting to the Core

Why XIDs? These core concepts explain some of the reasons:

_ They enable _Pseudonymous Trust Building_ where you can build up a pseudonymous identity over time, including _Public Participant Profiles_ for working on public projects.
- They allow for _Attestations_ and _Endorsements_ to be attached to your identity, possibly using a _Fair Witness Approach that will improve their trustworthiness.
- They support _Data Minimization_ using  _Elision Cryptography_ ensures that allows the holder to decide what to reveal while ensuring that signed statements remain valid.
- This allows a _Progressive Trust Life Cycle_ where you reveal details over time, just like in the real world.
- They support _Key Management_ that enables the best practices of heterogeneity and rotation.

## What's Next

You're now ready to begin [§1.3: Creating Your First
XID](01_3_Your_First_XID.md), to get your hands into the actual work
of XIDs.
