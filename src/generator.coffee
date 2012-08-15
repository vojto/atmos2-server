class Generator
  init: ->
    console.log 'initializing generator'

  run: (options) ->
    app = options._[0] or options.app
    throw 'Expected application name' unless app
    console.log 'Making app', app

module.exports = Generator