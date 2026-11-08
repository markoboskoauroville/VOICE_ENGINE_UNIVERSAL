package community.auroville.voiceengine

// PAUSE / CONTINUE, the one rule (VOICE_ENGINE_UNIVERSAL SPEC.md §3). Imports nothing from Android; the Swift twin is
// swift/PauseSync.swift. A press flips the button at once and takes the voice's own word about "paused" only after
// GUARD_S seconds, so the next poll (which still carries the old answer) cannot flip it back.
class PauseSync(private val guardS: Double = GUARD_S) {
    companion object { const val GUARD_S = 1.5 }

    var paused = false
        private set
    private var pressedAt = -1e9

    /** The button was pressed: the new state (true = now paused, the button reads CONTINUE). */
    fun press(now: Double): Boolean { paused = !paused; pressedAt = now; return paused }

    /** What the voice says; true when the button must be repainted. A press within the guard wins. */
    fun sync(serverPaused: Boolean, now: Double): Boolean {
        if (now - pressedAt <= guardS || serverPaused == paused) return false
        paused = serverPaused
        return true
    }

    /** A new reading starts playing. */
    fun reset() { paused = false; pressedAt = -1e9 }

    /** Word on the button: PAUSE while it plays, CONTINUE while it waits. */
    val label: String get() = if (paused) "CONTINUE" else "PAUSE"
}
