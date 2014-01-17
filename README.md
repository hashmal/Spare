Spare – Web server for Io
=========================

This is a basic server to run Io web applications. It is probably not suitable
for "real" projects but it is good enough for tinkering. Requests are handled
using Io's concurrency features.

The interface is simple and roughly mimics the Rack protocol. Here is an
example that runs on Heroku:

    app := block(env,
        list(
            "200 OK",
            Map clone atPut("Content-Type", "text/plain; charset=UTF-8"),
            list("Hello, world!\n")
        )
    )

    // Heroku requires to bind the server to a particular port
    PORT = if(PORT := System getEnvironmentVariable("PORT"),
        PORT asNumber,
        3000 // When used locally, bind on port 3000 instead
    )

    Spare clone setPort(PORT) setApp(app) start

The object passed to `setApp` must respond to `call`. It can receive a single
argument, the *environment,* which is a `Map` containing information about
the request. The object must return a `List` of 3 values:

* The response status
* The HTTP headers as a `Map`
* The response body as a `List` of strings (`Sequence` objects)

To do
-----

* Fix many bugs, write tests
* Make POST data accessible via the environment
* Add support for middlewares

License
-------

Copyright 2014, Jérémy Pinat.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
