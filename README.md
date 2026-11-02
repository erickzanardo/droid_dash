# droid_dash

Code and run Flutter apps on your Android phone, with no root and no computer.

droid_dash is an Android app that bundles what you need to work on a Flutter
project: an editor with LSP support, a terminal with git, and a preview tab
that runs your app on Flutter web with hot reload. Flutter runs on the device
itself, and the app downloads the SDK for you.

## Status

Early. The core idea is proven on an emulator, but the app itself does not exist
yet. See [the spike results](spec/spikes/2026-11-on-device-toolchain.md).

## Repository layout

| Path | Contents |
| --- | --- |
| [`spec/`](spec/README.md) | Documentation, architecture and decisions |
| [`spike/`](spike/README.md) | The feasibility spike |
| [`third_party/`](third_party/README.md) | Licenses and source for bundled binaries |

## License

droid_dash is released under the [MIT License](LICENSE). Bundled third-party
components keep their own licenses, including GPL and LGPL. See
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
