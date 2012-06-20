fs        = require('fs')

Express   = require('express')
Mongolian = require('mongolian')
ObjectId  = Mongolian.ObjectId
{log, log2, loge}     = require('./util')

Server          = require('./server')
Users           = require('./user_service')

is_production = process.env.NODE_ENV == 'production'

#        __
#       ()'`;
#       /\|`
#      /  |
#    (/_)_|_
#

class Application extends Server
  # -^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
  # Lifecycle
  # ---------------------------------------------------------------------------

  constructor: (options = {}) ->
    server = new Mongolian
    options.database or= 'impensi_dev'
    @_database = server.db(options.database)

    @_http = Express.createServer()
    @_http.use(Express.static(__dirname + '/../public'))
    @_http.use(Express.bodyParser())
    @_http.use(Express.cookieParser());
    @_http.use(Express.session({secret: "foobar"}))

    # Services -- only users in this case
    @_users = new Users(@)

    @_http.get '/login', @login
    @_http.post '/sign_up', @sign_up

    @modules = {}

  start: (port) ->
    @_http.listen(port)
    log "Starting HTTP server on port #{port}."

  # -^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
  # Interface for modules
  # ---------------------------------------------------------------------------

  add: (modules) ->
    for name, module of modules
      instance = new module(@)
      @modules[name] = instance

  route: (method, route, handler) ->
    @_http[method].call(@_http, route, @middlewares(), handler)

  collection: (name) ->
    @_database.collection(name)

  # -^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
  # Middlewares
  # ---------------------------------------------------------------------------

  middlewares: ->
    [@web_security, @authentication]

  web_security: (req, res, next) ->
    res.header('Access-Control-Allow-Origin', '*')
    res.header('Access-Control-Allow-Headers', 'Auth-Token')
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
    next()

  authentication: (req, res, next) =>
    if req.session.user
      req.user = req.session.user
      return next()

    token = req.header('Auth-Token')
    user = null
    await @_users.auth_by_token token, defer user if token

    if user
      req.user = user
      req.user._id = req.user._id.toString()
      return next()
    else
      res.send("Invalid token #{token}", 401)

  # -^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
  # Actions
  # ---------------------------------------------------------------------------

  login: (req, res) =>
    username  = req.param('username')
    password  = req.param('password')
    log "login: #{username}/#{password}"
    await @_users.auth_by_credentials username, password, defer user
    if user
      req.session.user = user
      res.send(user, 200)
    else
      res.send({error: 'Invalid username/password'}, 401)

  sign_up: (req, res) =>
    params = @_require_params(req, res, ['username', 'password', 'email'])
    log 'creating account', params
    await @_users.create params, defer err, user
    delete user.encoded_password if user
    @_send(res, err, user)

module.exports = Application