{ObjectId} = require('mongolian')
{log, log2, loge} = require('./util')

class Service
  constructor: (@app) ->

  list: (user, entity, callback) ->
    log "list:", entity
    collection = @app.collection(entity)
    criteria = {_user_id: new ObjectId(user._id)}
    cursor = collection.find(criteria)
    await cursor.toArray defer err, objects
    return callback(err) if err
    data = @serialize_array(objects)
    callback(err, data)

  create: (user, entity, object, callback) ->
    log "create:", entity, object
    delete object.identifier
    console.log user._id
    object._user_id = new ObjectId(user._id)
    collection = @app.collection(entity)
    collection.insert(object)
    data = @serialize_object(object)
    callback(null, data)

  update: (user, entity, id, object, callback) ->
    delete object._id
    delete object.identifier
    log "update: ", entity, id, object
    object._user_id = new ObjectId(user._id)
    collection = @app.collection(entity)
    criteria   = {_id: new ObjectId(id), _user_id: new ObjectId(user._id)}
    collection.update criteria, object, (err) =>
      return callback(err) if err
      data = @serialize_object(object)
      callback(null, data)

  del: (user, entity, id, callback) ->
    log "delete:", entity, id
    collection = @app.collection(entity)
    criteria   = {_id: new ObjectId(id), _user_id: new ObjectId(user._id)}
    collection.remove(criteria)
    callback(null)

  _validate_presence: (object, attributes, callback) ->
    errors = []
    for attribute in attributes
      if !object[attribute]
        errors.push("Missing required attribute #{attribute}")
    if errors.length == 0 then errors = null
    callback(errors)

  _validate_uniqueness: (object, attributes, callback) ->
    errors = []
    for attribute in attributes
      query = {}
      query[attribute] = object[attribute]
      await @collection.findOne query, defer err, user
      if user
        errors.push("Attribute #{attribute} must be unique")
    if errors.length == 0 then errors = null
    callback(errors)

  serialize_array: (array) ->
    @serialize_object(object) for object in array

  serialize_object: (object) ->
    for key, value of object
      if (typeof value is 'object') and value.bytes
        object[key] = value.toString()
    object

module.exports = Service