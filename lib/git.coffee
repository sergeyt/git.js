fs = require 'fs'
path = require 'path'
{exec} = require 'child_process'
Q = require 'q'

# load command plugins
plugins = ['status'].map (name) ->
	fn = require "./#{name}"
	fn.cmd = name
	return fn

# executes given command
execute = (cmd) ->
	# todo allow to configure exec options
	opts =
		encoding: 'utf8'
		timeout: 1000 * 60
		killSignal: 'SIGKILL'
		maxBuffer: 1024 * 1024
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

	if not fs.existsSync dir
		throw new Error "#{dir} does not exist"

	if path.basename dir != '.git'
		dir2 = path.join dir, '.git'
		if not fs.existsSync dir
			throw new Error "unable to resolve git repository in #{dir}"
		dir = dir2

	# runs git command
	run = (command) -> execute "#{bin()} --git-dir \"#{dir}\" #{command}"

	api = {run: run}

	# inject commands
	plugins.forEach (p) ->
		api[p.cmd] = p api

	return api

module.exports = git