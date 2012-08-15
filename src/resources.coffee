Mongolian = require('mongolian')
ObjectId  = Mongolian.ObjectId

Server = require('./server')
Service = require('./service')
{log, log2, loge}     = require('./util')

class ResourcesServer extends Server
  constructor: (@app, options = {}) ->
    @service = new ResourcesService(@app)
    @entity = options.entity

    throw 'Expected entity' unless @entity

    @app.route 'get',    "/#{@entity}",     @list
    @app.route 'post',   "/#{@entity}",     @create
    @app.route 'put',    "/#{@entity}/:id", @update
    @app.route 'delete', "/#{@entity}/:id", @del

  list: (req, res) =>
    await @service.list req.user, @entity, defer err, data
    @_send(res, err, data)

  create: (req, res) =>
    body = req.body
    await @service.create req.user, @entity, body, defer err, data
    @_send(res, err, data)

  update: (req, res) =>
    body    = req.body
    id      = req.param('id')
    return @_send_error(res, "No ID")     unless id
    await @service.update req.user, @entity, id, body, defer err, data
    @_send(res, err, data)

  del: (req, res) =>
    id = req.param('id')
    return @_send_error(res, "No ID")     unless id
    await @service.del req.user, @entity, id, defer err
    @_send(res, err, true)

class ResourcesService extends Service

module.exports = ResourcesServer