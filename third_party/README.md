# third_party

This folder lets droid_dash meet the GPL and LGPL source and license conditions
for the binaries it bundles. See
[THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md) for what each component is.

- `licenses/`: full license texts.
- `sources/`: the exact source archives for the bundled binaries. Their SHA-256
  checksums match the ones in Termux's package recipes.
- `sources/termux-build/`: the Termux recipes that build those packages.

## Updating a binary

Whenever a file in `spike/assets/proot/` changes, or bundled binaries move
elsewhere, do all of the following in the same commit:

1. Replace the matching source archive and build script here.
2. Update the versions and checksums in `THIRD_PARTY_NOTICES.md`.
3. Publish any changes made to GPL or LGPL code.
