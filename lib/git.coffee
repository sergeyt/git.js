fs = require 'fs'
{spawn} = require 'child_process'
Q = require 'q'

# load command plugins
plugins = ['status'].map (name) ->
	fn = require "./#{name}"
	fn.cmd = name
	return fn

# executes given git command
exec = (cwd, cmd, args) ->
	args = [] if not args

	# todo allow to configure exec options
	opts =
		encoding: 'utf8'
		timeout: 1000 * 60
		killSignal: 'SIGKILL'
		maxBuffer: 1024 * 1024
		cwd: cwd
		env: process.env

  # inherit process identity
	opts.uid = process.getuid() if process.getuid
	opts.gid = process.getgid() if process.getgid

	def = Q.defer()

	git = spawn "git", [cmd, args...], opts

	git.stdout.on 'data', (data) ->
		msg = data?.toString().trim()
		def.resolve msg

	git.stderr.on 'data', (data) ->
		msg = data?.toString().trim()
		console.error data
		def.reject msg

	git.on 'error', (err) ->
		msg = err?.toString().trim()
		console.error msg
		def.reject msg

	return def.promise

# creates git command runner
git = (dir) ->

	if not fs.existsSync dir
		throw new Error "#{dir} does not exist"

	# runs given command
	run = (cmd, args) -> exec dir, cmd, args

	api = {run: run}

	# inject commands
	plugins.forEach (p) ->
		api[p.cmd] = p api

	return api

module.exports = git