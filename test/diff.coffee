git = require '../index'

git(__dirname + '/..').diff()
.then (files) ->
		console.log JSON.stringify files, null, 2
.fail (err) ->
		console.error err
