# Curassow

[![Build Status](https://travis-ci.org/kylef/Curassow.svg?branch=master)](https://travis-ci.org/kylef/Curassow)

Curassow is a Swift [Nest](https://github.com/nestproject/Nest)
HTTP Server. It uses the pre-fork worker model and it's similar to Python's
Gunicorn and Ruby's Unicorn.

It exposes a [Nest-compatible interface](https://github.com/nestproject/Nest)
for your application, allowing you to use Curassow with any Nest compatible
web frameworks of your choice.

## Usage

To use Curassow, you will need to install it via the Swift Package Manager,
you can add it to the list of dependencies in your `Package.swift`:

```swift
import PackageDescription

let package = Package(
  name: "HelloWorld",
  dependencies: [
    .Package(url: "https://github.com/kylef/Curassow.git", majorVersion: 0, minor: 4),
  ]
)
```

Afterwards you can place your web application implementation in `Sources`
and add the runner inside `main.swift` which exposes a command line tool to
run your web application:

```swift
import Curassow
import Inquiline


serve { request in
  return Response(.Ok, contentType: "text/plain", body: "Hello World")
}
```

```shell
$ swift build --configuration release
```

### Command Line Interface

Curassow provides you with a command line interface to configure the
address you want to listen on and the amount of workers you wish to use.

##### Setting the workers

```shell
$ ./.build/release/HelloWorld --workers 3
[arbiter] Listening on 0.0.0.0:8000
[arbiter] Started worker process 18405
[arbiter] Started worker process 18406
[arbiter] Started worker process 18407
```

##### Configuring the address

```shell
$ ./.build/release/HelloWorld --bind 127.0.0.1:9000
[arbiter] Listening on 127.0.0.1:9000
```

```shell
$ ./.build/release/HelloWorld --bind unix:/tmp/helloworld.sock
[arbiter] Listening on unix:/tmp/helloworld.sock
```

##### Configuring worker timeouts

By default, Curassow will kill and restart workers after 30 seconds if it
hasn't responded to the master process.

```
$ ./.build/release/HelloWorld --timeout 30
```

You can set the timeout to `0` to disable worker timeout handling.

### FAQ

#### What platforms does Curassow support?

Curassow supports both Linux and OS X.

#### Is there any example applications?

Yes, check out the [Hello World example](https://github.com/kylef/Curassow-example-helloworld).

#### How can I change the number of workers dynamically?

TTIN and TTOU signals can be sent to the master to increase or decrease the number of workers.

To increase the worker count by one, where $PID is the PID of the master process.

```
$ kill -TTIN $PID
```

To decrease the worker count by one:

```
$ kill -TTOU $PID
```

#### Is it ready for production?

Please consult the [deployment guide](Deployment.md) before deploying Curassow
to a production environment. It's important to run Curassow behind a HTTP
proxy.

## License

Curassow is licensed under the BSD license. See [LICENSE](LICENSE) for more
info.
