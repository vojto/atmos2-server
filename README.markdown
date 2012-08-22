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

*(#ProTip: These are actual commands for [httpie](https://github.com/jkbr/httpie).)*

Logging in:

    http get 'http://localhost:4001/login?username=foo&password=bar'

Creating account:

    http post http://localhost:4001/sign_up username=foo password=bar email=foo@bar.com