_ = require 'underscore'
_.str = require 'underscore.string'

# log command plugin
module.exports = (git) ->
	log = (opts) ->
		format = '--format=%H;%an;%ae;%ad;%s'
		args = [format, '--date=iso', transform(opts)...]
		git.run('log', args).then(parse)
	return log

transform = (opts)->
	return [] if not opts
	# todo support more options
	_.keys(opts)
	.map (k) ->
		v = opts[k]
		switch k
			when 'max' then "-n #{{v}}"
			else ''
	.filter _.identity

parse = (out) ->
	lines = _.str.lines(out)
	lines.map (l) ->
		p = l.split ';'
		id: p[0]
		author:
			name: p[1]
			email: p[2]
		date: new Date(p[3])
		message: p[4]
