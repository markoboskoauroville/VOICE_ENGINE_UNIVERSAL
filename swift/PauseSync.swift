import Foundation

// PAUSE / CONTINUE, the one rule (VOICE_ENGINE_UNIVERSAL SPEC.md §3); the Kotlin twin is kotlin/PauseSync.kt.
// A press flips the button at once and takes the voice's own word about "paused" only after `guardS` seconds.
public struct PauseSync {
    public static let guardS = 1.5
    public private(set) var paused = false
    private var pressedAt = -1e9
    public init() {}
    /// The button was pressed: the new state (true = now paused, the button reads CONTINUE).
    public mutating func press(_ now: Double = Date().timeIntervalSince1970) -> Bool { paused.toggle(); pressedAt = now; return paused }
    /// What the voice says; true when the button must be repainted. A press within the guard wins.
    public mutating func sync(_ serverPaused: Bool, _ now: Double = Date().timeIntervalSince1970) -> Bool {
        if now - pressedAt <= PauseSync.guardS || serverPaused == paused { return false }
        paused = serverPaused; return true
    }
    public mutating func reset() { paused = false; pressedAt = -1e9 }
    public var label: String { paused ? "CONTINUE" : "PAUSE" }
    public var symbol: String { paused ? "play.fill" : "pause.fill" }
    /// POST this path with this body to the voice server (:8837) for the state just reached.
    public var request: (path: String, body: String) { ("/speak/pause", paused ? "{\"paused\": true}" : "{\"paused\": false}") }
}

/// The word being said at `t` seconds: the last word started; -1 before the first and once the last has let go.
public func litWord(_ starts: [Double], lastEnd: Double?, at t: Double) -> Int {
    var k = -1, lo = 0, hi = starts.count - 1
    while lo <= hi { let m = (lo + hi) / 2; if starts[m] <= t { k = m; lo = m + 1 } else { hi = m - 1 } }
    if k >= 0, k == starts.count - 1, let e = lastEnd, t > e + 0.12 { return -1 }
    return k
}
