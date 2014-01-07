# config command plugin
module.exports = (git) ->
	# todo support more options
	config = (opts) ->
		name = opts.name
		value = opts.value
		args = if value then [name, value] else ['--get', name]
		git.run('config', args)
	local = create git
	config.system = create git, ['--system']
	config.global = create git, ['--global']
	config.get = local.get
	config.set = local.set
	config

# creates config api
create = (git, ctx) ->
	ctx = [] if not ctx
	get = (name) ->
		args = [ctx..., name]
		git.run('config', args)
	set = (name, value) ->
		args = [ctx..., name, value]
		git.run('config', args)
	{get: get, set: set}
