import swiftMetal
import COpenCL
import Foundation
import Metal

internal final class CompilerSession: MetalCompilerSession {
    private static let precompiledSources: [String: String] = [:]

    internal init?(source: String) {
        let base64Encoded = source.data(using: .utf8)!.base64EncodedString()

        guard let metalSource = CompilerSession.precompiledSources[base64Encoded] else {
            print("Source: \(source)")
            print("Base64: \(base64Encoded)")
            return nil
        }

        super.init(source: source,
                   metalSource: metalSource)
    }
}

internal final class Compiler: MetalCompiler {
    func makeSession(source: String) -> CompilerSession? {
        return CompilerSession(source: source)
    }
}
