_ = require 'underscore'
_.str = require 'underscore.string'
parse = require('../parse/status').short

# commit command plugin
module.exports = (git) ->
	commit = (opts) ->
		files = opts.files || []
		args = ['--short', transform(opts)..., files...]
		git.run('commit', args).then(parse)
	return commit

transform = (opts) ->
	return [] if not opts
	# todo support more options
	_.keys(opts)
	.map (k) ->
			v = opts[k]
			switch k
				# do not create a commit, but show a list of paths that are to be committed.
				when 'dryrun' then "--dry-run"
				when 'all' then "--all"
				when 'message' then "--message=#{_.str.quote(v)}"
				else ''
	.filter _.identity
