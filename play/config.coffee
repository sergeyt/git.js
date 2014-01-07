git = require './index'

print = (p) ->
	p.then (val) ->
		console.log val
	.fail (err) ->
		console.error err

print git.config.get 'user.name'
print git.config.get 'user.email'
print git.config.global.get 'user.name'
print git.config.global.get 'user.email'
print git.config.system.get 'user.name'
print git.config.system.get 'user.email'
