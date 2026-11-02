# Spec

This folder holds droid_dash's documentation and the reasoning behind it.

| Document | Purpose |
| --- | --- |
| [overview.md](overview.md) | What we're building, and what we aren't |
| [architecture.md](architecture.md) | How the app works |
| [open-questions.md](open-questions.md) | What's unknown or undecided |
| [decisions/](decisions) | Why things are the way they are |
| [spikes/](spikes) | Experiments and their measured results |

## Conventions

- **Decisions** are numbered and written once. To reverse one, add a new decision
  and mark the old one `Superseded by NNNN`. Use
  [`decisions/TEMPLATE.md`](decisions/TEMPLATE.md).
- **Spikes** are dated records of what was measured. Don't update the results
  afterwards; run a new spike.
- **Other documents** describe the current state, so update them in the same
  commit as the change they describe.
- Move a question out of `open-questions.md` once it's answered, into a decision
  or the relevant document.

## Decisions

| # | Decision | Status |
| --- | --- | --- |
| [0001](decisions/0001-web-only-preview.md) | Preview apps on Flutter web only | Accepted |
| [0002](decisions/0002-proot-ubuntu-toolchain.md) | Run official Flutter in Ubuntu under proot | Accepted |
| [0003](decisions/0003-target-sdk-28.md) | Target SDK 28 | Accepted |
| [0004](decisions/0004-distribute-outside-google-play.md) | Distribute outside Google Play | Accepted |
| [0005](decisions/0005-mit-license.md) | License droid_dash under MIT | Accepted |
