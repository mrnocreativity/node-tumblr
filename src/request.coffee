qs      = require 'querystring'
request = require 'request'

module.exports =
  # Prepare URL for creating posts via POST request
  postUrl: (self) ->
    'http://api.tumblr.com/v2/blog/' + self.host + '/post';

  # Prepare URL for blog requests
  blogUrl: (action, self, options = {}) ->
    params = [
      'http://api.tumblr.com/v2/blog/'         # Tumblr API URL
      self.host + '/' + action                 # blog host and action
      '/' + options.type if options.type?      # optional type of post to return
      '?'
    ]

    delete options.type if options.type?

    options.api_key = self.oauth.consumer_key  # OAuth Consumer Key

    query = qs.stringify options
    params.push query                          # optional params

    params.join ''

  # Prepare URL for user requests
  userUrl: (action, options = {}) ->
    query = qs.stringify options
    params = "http://api.tumblr.com/v2/user/#{action}?#{query}"
    params

  # Prepare URL for tagged posts requests
  taggedUrl: (self, options = {}) ->
    options.api_key = self.oauth.consumer_key
    "http://api.tumblr.com/v2/tagged?#{qs.stringify options}"

  # Send GET and POST requests
  get: (url, fn) -> req url, 'GET', fn
  post: (url, fn, oauth, data) -> req url, 'POST', fn, oauth, data

  # Send GET and POST requests with OAuth
  oauthGet: (url, oauth, fn) -> req url, 'GET', fn, oauth
  oauthPost: (url, oauth, fn) -> req url, 'POST', fn, oauth

# Send requests
req = (url, method = 'GET', fn, oauth, data) ->
  options = {url, method, followRedirect: false, json: true, protocol: 'http:'}
  options.oauth = oauth if oauth?

  # If we have POST data, set as form element and set json to false
  options.json = false if data?
  options.form = data if data?

  request options, (error, response, body) ->
    if not error and response.statusCode not in [200, 201, 301]
      error = "#{response.statusCode} #{body.meta.msg}"

    if fn?
      fn.call body, error, body.response
