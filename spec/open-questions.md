# Open questions

## Needs testing

| Question | Why it matters |
| --- | --- |
| How fast is it on a real phone? | The spike ran on an M2 Pro emulator, so its timings are a best case. Slow results may force the fallback in [decision 0002](decisions/0002-proot-ubuntu-toolchain.md). |
| How much memory does `dart language-server` use under proot? | It runs alongside the compilers and sets the minimum phone we can support. |
| How does a real project behave? | The spike used an empty app. Large apps with many packages will compile more slowly. |
| Do processes survive when the user leaves the app? | Android can kill child processes, so this likely needs a foreground service. |
| Does `git push` work, and how do users log in? | Git is installed, but nothing has been pushed yet. |
| Does the toolchain work on Android 16 and newer? | The spike only covered Android 15. |
| Does anything break on phones with 16 KB memory pages? | Newer devices use them, and neither the proot build nor the official Dart SDK has been tested on them. |

## Needs a decision

| Question | Notes |
| --- | --- |
| Which editor do we use? | A Flutter code editor, or an existing web editor in a WebView. This may be the largest piece of work. |
| Which terminal do we use? | It needs a real PTY, plus a terminal widget. The spike only streams process output. |
| What's the final package name? | Choose it before the first release. Later registration ties it to the signing key. |
| Where do bundled binaries live? | They're in `spike/assets/proot/` for now. Moving them means updating `THIRD_PARTY_NOTICES.md`. |
| Should we build proot ourselves in CI? | That would tie each binary directly to its source. |
| Which Flutter versions do we offer? | One default version, or a choice. |

## Deferred

- **Android developer verification.** It isn't enforced for sideloaded apps until
  the global rollout planned for 2027, so we'll revisit it closer to then. See
  [decision 0004](decisions/0004-distribute-outside-google-play.md).
