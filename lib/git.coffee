fs = require 'fs'
path = require 'path'
{spawn} = require 'child_process'
Q = require 'q'

verbose = false

# load command plugins
plugins = fs.readdirSync(__dirname)
	.filter (file) ->
		name = path.basename(file, '.coffee')
		switch name
			when 'git' then false
			else true
	.map (file) ->
		name = path.basename(file, '.coffee')
		factory = require "./#{name}"
		factory.cmdname = name
		return factory

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

	argv = [cmd, args...]
	if verbose
		console.log "git #{argv.join(' ')}"
	git = spawn "git", argv, opts

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

	git.on 'close', ->
		def.resolve '' if def.promise.isPending()

	return def.promise

# creates git command runner
git = (dir) ->
	if not fs.existsSync dir
		throw new Error "#{dir} does not exist"

	# runs given command
	run = (cmd, args) ->
		exec dir, cmd, args

	api = {run: run}

	# inject commands
	plugins.forEach (factory) ->
		cmdfn = factory api
		api[factory.cmdname] = cmdfn
		(cmdfn.aliases || []).forEach (name) ->
			api[name] = cmdfn

	return api

module.exports = git
