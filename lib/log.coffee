_ = require 'underscore'
_.str = require 'underscore.string'
parseDiff = require 'parse-diff'
Q = require 'q'
async = require 'async'

# log command plugin
module.exports = (git) ->
	return (opts) ->
		format = '--format=%H;%an;%ae;%ad;%s'
		args = [format, '--date=iso', transform(opts)...]
		git.run('log', args).then(parse).then(extend(git))

transform = (opts) ->
	return [] if not opts
	# todo support more options like since, after, etc
	_.keys(opts)
	.map (k) ->
		v = opts[k]
		switch k
			when 'max' then "-n #{{v}}"
			else ''
	.filter _.identity

parse = (out) ->
	return [] if not out
	lines = _.str.lines(out)
	lines.map (l) ->
		p = l.split ';'
		id: p[0]
		author:
			name: p[1]
			email: p[2]
		date: new Date(p[3])
		message: p[4]

extend = (git) ->
	(commits) ->
		list = commits.map (c) ->
			c.diff = -> diff(git, c)
			return c
		list.diffs = -> diffs(git, commits)
		list

# fetch diff for given commit
diff = (git, commit) ->
	git.run('diff', ['-u', commit.id]).then(parseDiff)

# fetch diffs for given commits
diffs = (git, commits) ->
	def = Q.defer()
	funcs = commits.map (c) -> diffAsyncFn(git, c)
	async.parallel funcs, (err, res) ->
		def.reject(err) if err
		def.resolve(res)
	def.promise

diffAsyncFn = (git, commit) ->
	(cb) ->
		diff(git, commit)
		.then (res) ->
			cb null, res
		.fail (err) ->
			cb err, null
