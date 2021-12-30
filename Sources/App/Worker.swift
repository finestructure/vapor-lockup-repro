import Vapor


struct Worker: Command {
    struct Signature: CommandSignature {
        @Option(name: "limit", short: "l")
        var limit: Int?
    }

    var help: String { "Run worker" }

    func run(using context: CommandContext, signature: Signature) throws {
        let limit = signature.limit ?? 1

        try (0..<limit).forEach { index in
            context.application.logger.info("creating item: \(index)")
            let title = String(
                (0..<100)
                    .map { _ in "0123456789".shuffled() }
                    .joined(separator: "")
            )
            try Todo(title: title).save(on: context.application.db).wait()
        }
    }
}