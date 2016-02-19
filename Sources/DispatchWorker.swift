#if os(OSX)
import Darwin
import Dispatch
import Nest
import Inquiline


final public class DispatchWorker :  WorkerType {
  let configuration: Configuration
  let logger: Logger
  let listeners: [Socket]
  let notify: Void -> Void
  let application: RequestType -> ResponseType

  public init(configuration: Configuration, logger: Logger, listeners: [Socket], notify: Void -> Void, application: Application) {
    self.logger = logger
    self.listeners = listeners
    self.configuration = configuration
    self.notify = notify
    self.application = application
  }

  public func run() {
    logger.info("Booting worker process with pid: \(getpid())")

    // TODO: register signal handlers
    configureTimer()

    // TODO: setup dispatch source for socket
    listeners.forEach(registerSocketHandler)

    dispatch_main()
  }

  func registerSocketHandler(socket: Socket) {
    socket.consume { (source, socket) in
      if let clientSocket = try? socket.accept() {
        // TODO: Async HTTP Parsing
        let parser = HTTPParser(socket: clientSocket)

        if let request = try? parser.parse() {
          let response = self.application(request)
          sendResponse(clientSocket, response: response)
        }

        clientSocket.close()
      }
    }
  }

  func configureTimer() {
    let source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue())
    dispatch_source_set_timer(source, 0, UInt64(configuration.timeout) / 2 * NSEC_PER_SEC, 0)
    dispatch_source_set_event_handler(source) {
      self.notify()
    }
    dispatch_resume(source)
  }
}


extension Socket {
  func consume(closure: (dispatch_source_t, Socket) -> ()) {
    let source = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, UInt(descriptor), 0, dispatch_get_main_queue())
    dispatch_source_set_event_handler(source) {
      closure(source, self)
    }
    dispatch_source_set_cancel_handler(source) {
      self.close()
    }
    dispatch_resume(source)
  }
/*
  func consumeData(closure: (Socket, Data) -> ()) {
    consume { source, socket in
      let estimated = Int(dispatch_source_get_data(source))
      let data = self.read(estimated)
      closure(socket, data)
    }
  }
*/
}
#endif
