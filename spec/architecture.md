# Architecture

droid_dash is a Flutter Android app that runs a Linux userland in its private
storage. The Flutter toolchain runs in that userland as ordinary child
processes, and the app talks to them. This design is proven in the
[spike](spikes/2026-11-on-device-toolchain.md). Parts marked *planned* have not
been built.

```text
droid_dash (Flutter app, targetSdk 28)
  ├── Editor (planned) ─────── LSP ──────┐
  ├── Terminal (planned) ───── PTY ──────┤
  ├── Preview (WebView) ── 127.0.0.1 ──┐ │
  │                                    │ │
  └── starts as child process          │ │
        proot                          │ │
          └── Ubuntu 24.04 (arm64)     │ │
                ├── flutter run -d web-server
                ├── dart language-server (planned)
                └── git, bash, apt
```

## Layers

**proot.** The app ships Termux's proot build as assets, copies it to private
storage and marks it executable. Targeting SDK 28 is what allows this, as
[decision 0003](decisions/0003-target-sdk-28.md) explains. Its environment needs:

| Variable | Value |
| --- | --- |
| `LD_LIBRARY_PATH` | The folder holding `libtalloc.so.2` and `libandroid-shmem.so` |
| `PROOT_LOADER` | Path to the bundled `loader` |
| `PROOT_TMP_DIR` | A writable folder in app storage |

**Ubuntu.** The app downloads Ubuntu Base and extracts it through proot with
`--link2symlink`, which emulates hard links with symlinks. It then writes `/etc/resolv.conf` and `/etc/hosts`, and installs tools with `apt`.

**Flutter.** The app clones the official SDK inside Ubuntu. Flutter treats the
environment as ordinary arm64 Linux, so it needs no patches and downloads its
own arm64 Dart SDK.

**Preview.** `flutter run -d web-server` serves the app on `127.0.0.1`, which is
reachable from the WebView. The app sends `r` and `R` to the process's stdin for
hot reload and hot restart. The WebView connects as an ordinary page, so the
Chrome debug protocol isn't needed.

## Requirements from the spike

- The manifest needs the `INTERNET` permission and
  `android:usesCleartextTraffic="true"`, because the preview uses plain HTTP.
- Expect about 2.1 GB of storage for the toolchain.
- Expect about 1.2 GB of memory for the toolchain and preview, before adding the
  language server.
