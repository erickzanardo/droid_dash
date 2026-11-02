# Spike: on-device Flutter toolchain

**Date:** 2026-11-02
**Code:** [`spike/`](../../spike)
**Result:** Success on an emulator. Not yet tested on a real phone.

## Question

Can an unrooted Android app run the Flutter web toolchain on the device, and show
the result in its own WebView with hot reload?

## Setup

- `droid_dash_test` emulator: Android 15 arm64 Google Play image, unrooted, with
  8 GB of RAM, 6 CPU cores and a 32 GB disk.
- Host: Apple M2 Pro with 32 GB of RAM.
- App target SDK: 28.
- Termux proot 5.1.107.102, Ubuntu Base 24.04.5 and Flutter 3.47.7 with Dart
  3.13.5.

## Results

The app ran a binary it had written to its own storage, then completed every
stage. The final screenshot showed the edited text in the WebView, which confirms
that hot reload reached the page.

| Stage | Time |
| --- | --- |
| Download Ubuntu | 32 s |
| Extract Ubuntu | 21 s |
| Install tools with `apt` | 61 s |
| Clone Flutter | 26 s |
| Download Dart and web tools | 113 s |
| Create the test app | 4 s |
| First compile until served | 14 s |
| WebView connects | 3 s |
| Hot reload | 552 ms |
| Hot restart | 608 ms |

### Compared with native macOS

Both ran an empty app using the same Flutter version, on the same Mac. The macOS
run used headless Chrome.

| Measure | Native macOS | Emulator with proot |
| --- | --- | --- |
| First compile, by Flutter's timer | 10.5 s | 12.9 s |
| Hot reload | 95 ms | 542 ms |
| Hot restart | 262 ms | 601 ms |

### Resources

| Measure | Result |
| --- | --- |
| App storage in total | 2.1 GB |
| Ubuntu including Flutter | 2.0 GB |
| Flutter including its cache | 1.2 GB |
| Drop in available memory, running | About 1.2 GB |
| `dartaotruntime` (largest process) | About 615 MB |
| `dartvm` | About 246 MB |
| App with WebView | About 450 MB |

## Findings

- Targeting SDK 28 lets the app run binaries from its own storage on Android 15.
- proot adds noticeable latency to hot reload, but it stays well under a second
  on this hardware.
- The Android emulator needs `-dns-server 8.8.8.8,1.1.1.1` on the test Mac. Raw IP
  traffic worked without it, but hostnames did not resolve. This is an emulator
  problem, not an app problem.
- Plain `flutter run -d web-server` hot reloads through an ordinary page. Before
  a page connects, it reports `No client connected`.

## Not covered

The spike doesn't tell us about real phone speed, the language server, real
projects, background survival or `git push`. See
[open-questions.md](../open-questions.md).
