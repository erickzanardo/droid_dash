# Overview

droid_dash lets someone work on a Flutter app using only an Android phone. It
needs no root, no computer and no remote build server, and it works out of the
box: the app sets up everything it needs.

## Goals

- **Set up automatically.** The app downloads the Flutter SDK and its
  dependencies with no manual steps.
- **Edit code** in an editor with LSP support.
- **Use a terminal** for git commands and for running the app.
- **Work with git**, including committing and pushing to a remote repository.
- **Preview the app** in a web view tab, with hot reload.
- **Run on the device.** Flutter runs locally, and the app works without root.

## Non-goals

- Running or building Android, iOS or desktop versions of the user's app.
  [Web is the only target](decisions/0001-web-only-preview.md).
- Compiling native code, or using packages that need it.
- Publishing on Google Play. See
  [decision 0004](decisions/0004-distribute-outside-google-play.md).

## Limits this creates for users

Because previews run on the web:

- Packages without web support won't work in the preview.
- Code that uses `dart:io` or `dart:ffi` won't run in the preview.
