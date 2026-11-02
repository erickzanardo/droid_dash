# droid_dash_spike

A throwaway app that tests whether an unrooted Android app can run Flutter's web
toolchain on the device. It has no product features. Results are in
[the spike report](../spec/spikes/2026-11-on-device-toolchain.md).

On launch it runs each stage in order: unpack proot, install Ubuntu, install
Flutter, then serve a test app in a WebView and hot reload it. Completed stages
leave a `.done` marker in the app's files directory, so relaunching resumes
after a failure.

## Running it

You need an arm64 device or emulator with about 3 GB free and internet access.

```sh
flutter build apk --debug --target-platform android-arm64
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb shell am start -n dev.droiddash.droid_dash_spike/.MainActivity
```

Keep the app in the foreground. To read the log:

```sh
adb exec-out run-as dev.droiddash.droid_dash_spike cat files/spike.log
```

If hostnames don't resolve inside the emulator, start it with explicit DNS
servers:

```sh
emulator -avd <name> -dns-server 8.8.8.8,1.1.1.1
```

## Licensing

`assets/proot/` contains third-party GPL, LGPL and BSD binaries. See
[THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md).
