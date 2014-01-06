{exec} = Npm.require 'child_process'
Q = Npm.require 'q'

# load command plugins
plugins = ['status'].map (name) ->
	fn = require "./#{name}"
	fn.cmd = name
	return fn

# executes given command
execute = (cmd) ->
	def = Q.defer()
	exec cmd, opts, (err, stdout) ->
		return def.reject (err.toString())?.trim() if err
		return def.resolve (stdout.toString())?.trim()
	return def.promise

# resolves git binary
bin = ->
	isWin = process.platform.toLowerCase().match /mswin(?!ce)|mingw|bccwin|win32/
	return 'git' if isWin
	return '/usr/bin/env git'

# creates git command runner
git = (dir, opts) ->

	# runs git command
	run = (command) -> execute "#{bin()} --git-dir \"#{dir}\" #{command}"

	api = {run: run}

	# inject commands
	plugins.forEach (p) ->
		api[p.cmd] = p api

	return api

module.exports = git