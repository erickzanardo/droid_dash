# 0002: Run official Flutter in Ubuntu under proot

**Status:** Accepted
**Date:** 2026-11-02

## Context

Official Linux arm64 Dart binaries are linked against glibc, but Android uses
bionic, so they can't run on Android directly. There are two ways around that:

- **proot with a glibc Linux userland**, running official binaries unchanged.
- **Dart built for Android**, which runs natively but needs a patched
  `flutter_tools`, because Flutter rejects Android as a host. Dart would also
  have to be rebuilt to match each Flutter version.

## Decision

Run the official Flutter SDK in an Ubuntu userland under proot. Android-built
Dart is the fallback if proot proves too slow on real phones.

## Consequences

- There's no Flutter fork or Dart build to maintain, and any Flutter version
  should work.
- The terminal gets a full Linux environment, including `apt`.
- `flutter test` should work, since the Linux engine binaries are available. This
  is untested.
- proot adds latency: hot reload took 542 ms against 95 ms natively in the
  [spike](../spikes/2026-11-on-device-toolchain.md).
- It uses more storage, at about 2.1 GB.
- Real-phone speed is still unknown. If it's unusable, revisit this decision.
