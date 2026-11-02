# 0001: Preview apps on Flutter web only

**Status:** Accepted
**Date:** 2026-11-02

## Context

Running a user's app natively on the phone would need Gradle, the Android SDK and
the native engine on the device. Web is the lightest Flutter platform, and its
output can be shown in a WebView inside our own app.

## Decision

The only preview target is Flutter web, using `flutter run -d web-server` in an
in-app WebView.

## Consequences

- We don't need Flutter's native engine, Gradle or a C toolchain.
- The preview lives inside the app, so the app stays in the foreground while the
  user tests.
- Hot reload works through an ordinary page, as tested in the
  [spike](../spikes/2026-11-on-device-toolchain.md).
- Packages without web support, `dart:io` and `dart:ffi` won't work in the
  preview. Users can't produce an APK or test native behaviour.
