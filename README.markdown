# atmos2-server

Framework for making REST APIs quickly.

## Getting started

Subclass Atmos.App.

    Atmos = require('atmos2-server')

    class App extends Atmos.App
      constructor: ->
        super

Instantiate and start on your favorite port.

    app = new App
    app.start(4001)