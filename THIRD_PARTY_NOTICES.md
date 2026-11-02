# Third-party notices

The [MIT License](LICENSE) covers droid_dash's own code. It does not cover the
components below, which keep their own licenses.

## Bundled binaries

These prebuilt arm64 Android binaries are in [`spike/assets/proot/`](spike/assets/proot)
and are packaged in the APK. They come unmodified from the
[Termux](https://termux.dev) package repository. droid_dash starts them as a
separate program.

| Component | Version | License | Files | Corresponding source |
| --- | --- | --- | --- | --- |
| [PRoot (Termux fork)](https://github.com/termux/proot) | 5.1.107.102 | GPL-2.0-or-later | `proot`, `loader` | [`proot-5.1.107.102.zip`](third_party/sources/proot-5.1.107.102.zip) |
| [talloc](https://talloc.samba.org) | 2.5.0 | LGPL-3.0-or-later | `libtalloc.so.2` | [`talloc-2.5.0.tar.gz`](third_party/sources/talloc-2.5.0.tar.gz) |
| [libandroid-shmem](https://github.com/termux/libandroid-shmem) | 0.7 | BSD-3-Clause | `libandroid-shmem.so` | [`libandroid-shmem-0.7.tar.gz`](third_party/sources/libandroid-shmem-0.7.tar.gz) |

PRoot's copyright holder is STMicroelectronics. Termux's package metadata lists
talloc as GPL-3.0, but its source states LGPL-3.0-or-later, and that is what
applies here.

Termux applies no source patches to these packages. The build scripts it uses
are in [`third_party/sources/termux-build/`](third_party/sources/termux-build).

License texts are in [`third_party/licenses/`](third_party/licenses).

### Checksums

SHA-256 of the bundled binaries:

```text
3621937c1c5a98d0d39ca599af573a6bc15128690606d535e8b05da00cec4f41  proot
1da54355333cca3fb6ee10e3b82a24df24fb230c99241ce83809bf9e240609b5  loader
742b438c4d09e276985a61d44164c9de207b6d8cc268f3018cb3001961bcb309  libtalloc.so.2
84475798e07c8174dbbfaec70a827fdb02f19ffa69a589380c13e7507fd0e731  libandroid-shmem.so
```

## Downloaded at runtime

The app does not include or redistribute these. It downloads them on the user's
device from their official sources, and they stay under their own licenses.

| Component | Source |
| --- | --- |
| [Ubuntu Base 24.04](https://ubuntu.com/legal/intellectual-property-policy) | cdimage.ubuntu.com |
| Ubuntu packages, such as git and curl | Ubuntu archive, through `apt` |
| [Flutter and Dart SDKs](https://github.com/flutter/flutter/blob/master/LICENSE) | github.com/flutter/flutter and Flutter's storage |

## Dart packages

The app also uses Dart packages listed in each `pubspec.yaml`, such as
`webview_flutter`. Their licenses are collected at build time by Flutter and can
be viewed through Flutter's license page.

## Trademarks

Flutter and Android are trademarks of Google LLC. Ubuntu is a trademark of
Canonical Ltd. droid_dash is an independent project and is not affiliated with
or endorsed by them.
