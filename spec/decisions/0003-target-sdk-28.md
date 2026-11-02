# 0003: Target SDK 28

**Status:** Accepted
**Date:** 2026-11-02

## Context

Apps targeting Android 10 (API 29) or newer can't execute files in their writable
home directory. The workarounds are to ship binaries as `lib*.so` files in the
APK, or to start them through `/system/bin/linker64`. Both add complexity. The
first also ties tools to app releases.

Apps targeting API 28 aren't subject to that restriction.

## Decision

Set `targetSdk = 28`, so the app can download and execute binaries directly.

## Consequences

- Execution from app storage is simple, and confirmed on Android 15 in the
  [spike](../spikes/2026-11-on-device-toolchain.md).
- Google Play won't accept this app, as
  [decision 0004](0004-distribute-outside-google-play.md) covers.
- Users may see warnings that the app was built for an older Android version.
- Android could raise its minimum installable target SDK, or restrict older
  targets further. If so, move to `lib*.so` packaging or `linker64`.
