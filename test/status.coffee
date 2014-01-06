git = require '../index'

git(__dirname + '/..').status()
	.then (files) ->
		console.log JSON.stringify files, null, 2
	.fail (err) ->
		console.error err
