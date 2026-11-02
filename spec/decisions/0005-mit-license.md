# 0005: License droid_dash under MIT

**Status:** Accepted
**Date:** 2026-11-02

## Context

droid_dash is open source, and MIT is common in the Flutter ecosystem. The app also
bundles proot (GPL-2.0-or-later), talloc (LGPL-3.0-or-later) and libandroid-shmem
(BSD-3-Clause).

The app starts proot as a separate program and doesn't link it. Our code and those
binaries are generally treated as separate works in that arrangement, so they can
keep different licenses.

## Decision

droid_dash's own code uses the MIT License. Bundled components keep their own
licenses, documented in
[THIRD_PARTY_NOTICES.md](../../THIRD_PARTY_NOTICES.md).

## Consequences

- We keep exact source archives, build scripts and license texts in
  [`third_party/`](../../third_party/README.md), so every distributed binary has
  its source alongside it.
- Any update to a bundled binary must update those files too.
- If we ever link GPL code into the app itself, this decision no longer holds.
- Forks may be closed source, apart from the bundled GPL and LGPL components.
