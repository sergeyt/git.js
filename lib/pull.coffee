# pull command plugin
module.exports = (git) ->
	pull = (opts) ->
		args = ['--quiet', transform(opts)...]
		git.run('pull', args)
	return pull

transform = (opts) ->
	return [] if not opts
	# todo support more options
	_.keys(opts)
	.map (k) ->
			switch k
				# fetch all remotes.
				when 'all' then "--all"
				when 'force' then "--force"
				when 'keep' then "--keep"
				when 'update' then "-u"
				else ''
	.filter _.identity
