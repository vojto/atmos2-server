# atmos2-server

Framework for making REST APIs with MongoDB database.

## Getting started

Subclass Atmos.App.

    Atmos = require('atmos2-server')

    class App extends Atmos.App
      constructor: ->
        super

Instantiate and start on your favorite port.

    app = new App
    app.start(4001)

## Authentication

Atmos2 comes with authentication.

Logging in:

    GET /login?username=foo&password=bar

Creating account:

    POST /sign_up username=foo&password=bar&email=foo@bar.com