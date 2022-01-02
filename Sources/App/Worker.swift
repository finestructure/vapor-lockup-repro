import Fluent
import Vapor


struct Worker: Command {
    struct Signature: CommandSignature {
        @Option(name: "limit", short: "l")
        var limit: Int?
    }

    var help: String { "Run worker" }

    func run(using context: CommandContext, signature: Signature) throws {
        let limit = signature.limit ?? 1

        let db = context.application.db
        try db.transaction { tx -> EventLoopFuture<Void> in
            create(db: tx, limit: limit)
                .flatMap {
                    update(db: tx, limit: 10*limit)
                }
        }
        .wait()
    }
}


func randomTitle() -> String {
    String(
        (0..<100)
            .map { _ in "0123456789".shuffled() }
            .joined(separator: "")
    )
}


func create(db: Database, limit: Int) -> EventLoopFuture<Void> {
    (0..<limit).map { index -> EventLoopFuture<Void> in
        //        context.application.logger.info("creating item: \(index)")
        return Todo(title: randomTitle()).save(on: db)
    }
    .flatten(on: db.eventLoop)
}


func update(db: Database, limit: Int) -> EventLoopFuture<Void> {
    Todo.query(on: db)
        .limit(limit)
        .all()
        .flatMapEach(on: db.eventLoop) { todo in
            todo.title = randomTitle()
            return todo.save(on: db)
        }
}
