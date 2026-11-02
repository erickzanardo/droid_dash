# 0004: Distribute outside Google Play

**Status:** Accepted
**Date:** 2026-11-02

## Context

Google Play doesn't allow downloading native code from outside Play, and it
requires a recent target SDK. Both conflict with how droid_dash works. The app is
primarily for personal use, and it will be open source.

## Decision

Distribute droid_dash as an APK through GitHub. Google Play policy is not a design
constraint. Android developer verification registration is deferred.

## Consequences

- We can use proot, target SDK 28 and runtime downloads freely.
- Users install manually, and Play Protect may show warnings.
- GitHub releases must meet the GPL and LGPL conditions for bundled binaries. See
  [decision 0005](0005-mit-license.md).
- Verification isn't enforced for sideloaded apps yet. Google plans a global
  rollout in 2027, when unregistered apps will need its advanced flow or `adb`.
  We'll revisit registration closer to then. The maintainer already has a Google
  developer account.
- Keep the release signing key safe from the first release, because registering a
  package later requires it.
