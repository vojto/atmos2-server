Crypto = require('crypto')
Sha1              = require('sha1')
{log, log2, loge} = require('./util')

Service = require('./service')

class UserService extends Service
  constructor: (@app) ->
    @collection = @app.collection('users')

  auth_by_token: (token, callback) ->
    await @collection.findOne {tokens: {$in: [token]}}, defer err, user
    callback(user)

  auth_by_credentials: (username, password, callback) ->
    return callback(null) unless username and password
    hash = Sha1(password)
    await @collection.findOne {username: username, encoded_password: hash}, defer err, user
    return callback(null) unless user
    await @_create_token user, defer token
    data = @_serialize_user(user, token)
    callback(data)

  _create_token: (user, callback) ->
    await Crypto.randomBytes 48, defer ex, buf
    token = buf.toString('hex');
    @collection.update({_id: user._id}, {$push: {tokens: token}})
    callback(token)

  _serialize_user: (user, token) ->
    data = @serialize_object(user)
    delete data.tokens
    data.token = token
    data

  create: (user, callback) ->
    await @_validate_presence user, ['username', 'password', 'email'], defer errors
    return callback(errors) if errors
    await @_validate_uniqueness user, ['email', 'username'], defer errors
    return callback(errors) if errors
    user.encoded_password = Sha1(user.password)
    delete user.password
    await @collection.insert(user)
    data = @serialize_object(user)
    callback(null, data)

module.exports = UserService