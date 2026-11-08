# Voice Engine Universal: the one rule for the subtitle, on every device

Marko, 8.11.2026: *"If the repository doesn't exist for the subtitles, or as we like to call it, a voice engine, then you
need to create it. You just need to point the phones to that repository to update its engines."* Public, no secrets:
every app reads its keys from local storage (~/Downloads/API on the Mac) after installation.

Used by: **VOICE_ENGINE** (Mac, Swift, `swift/`) and **VOICE_ENGINE_ANDROID** (phones, Kotlin, `kotlin/`), each with this
repository as the git submodule `universal/`. A change here is pulled by `git submodule update --remote` and built by the
app's own GitHub workflow.

## 1. The subtitle
The sentence in a band across the screen, the word being said lit (`Reading.kt`; the Mac's clock is the same:
predicted on wall time, eased halfway to each answer, snapped when 0.35 s off; lit word = last started at clock + 50 ms;
the last word lets go 0.12 s after its end). Words are `[{s, e, t, d}]`, characters and seconds.

## 2. The four buttons, in this order, on the right of the subtitle
| Word | Symbol | Does |
|---|---|---|
| PAUSE (CONTINUE while paused) | pause.fill / play.fill | holds the voice at the word being said; again, it goes on from that word |
| HIDE | captions crossed out | the subtitle goes, the voice reads on |
| STOP | square | the reading ends completely |
Accessibility ids: `subtitle-pause`, `subtitle-hide`, `subtitle-stop` (Android: contentDescription "Pause" / "Continue", "Hide", "Stop").
No keyboard keys (Marko, 6.11.2026): mouse and finger only.

## 3. PAUSE: the rule (`PauseSync`)
- Press: flip at once; send the new state; for 1.5 s the voice's own `paused` is not believed (the next poll still carries the old one).
- After that the button follows the voice's `paused` (the blob, the menu bar, the mic guard may pause it too).
- While paused the subtitle's clock stands still, so the lit word does not creep on.
- Resume is word-exact: the voice server feeds silence to the speaker and keeps its position; nothing is re-synthesised.

## 4. The calls
Mac (MANTRA_VOICE, http://127.0.0.1:8837): `GET /speaking` (`paused`, `pos`, `words`, `sentence`), `POST /speak/pause`
`{"paused": true|false}` (empty turns it over), `POST /speak/stop`, `POST /speak/close`.
Phone (talker, app on 127.0.0.1:8720..8735): `POST /start`, `POST /pos {id,pos,paused,dur}` answered with
`{"cmd": "" | "stop" | "toggle"}`, `POST /end`; the buttons set the pending `toggle` / `stop` the talker takes in its next `/pos`.
