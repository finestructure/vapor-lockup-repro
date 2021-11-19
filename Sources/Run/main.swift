import App
import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)

let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
let app = Application(env, .shared(eventLoopGroup))

defer {
    app.shutdown()
    try! eventLoopGroup.syncShutdownGracefully()
}
try configure(app)
try app.run()
