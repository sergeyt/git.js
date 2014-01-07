parse = require 'parse-diff'
Q = require 'q'

# diff command plugin
module.exports = (git) ->
	cmd = (commits, opts) ->
		# be smart, by default show changes
		if not commits || commits.length == 0
			return cmd.files([], opts)
		if commits.length > 2
			return Q.reject 'diff failed: bad number of commits'
		# using unified diff format
		args = ['-u', transform(opts)...]
		git.run('diff', [args..., commits...]).then(parse)
	# diff files
	cmd.files = (files, opts) ->
		# todo support more options
		files = [] if not files
		# using unified diff format
		args = ['-u', transform(opts)...]
		git.run('diff-files', [args..., files...]).then(parse)
	cmd

transform = (opts) ->
	return [] if not opts
	# todo support more options
	_.keys(opts)
	.map (k) ->
			v = opts[k]
			switch k
				when 'n' then "--unified=#{v}"
				when 'minimal' then "--minimal"
				when 'patience' then "--patience"
				when 'histogram' then "--histogram"
				when 'summary' then "--summary"
				else ''
	.filter _.identity
