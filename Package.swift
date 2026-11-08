// swift-tools-version:5.9
import PackageDescription
let package = Package(name: "VoiceEngineUniversal", products: [.library(name: "VoiceEngineUniversal", targets: ["VoiceEngineUniversal"])],
                      targets: [.target(name: "VoiceEngineUniversal", path: "swift")])
