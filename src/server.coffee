class Server
  _send: (res, err, data) ->
    if err then res.send(err, 500) else res.send(data)

  _require_params: (req, res, params) ->
    result = {}
    for param in params
      value = req.param(param)
      if value
        result[param] = value
      else
        res.send("Param #{param} is required.", 400)
    result

  _send_error: (res, err) ->
    res.send(err, 500)

module.exports = Server