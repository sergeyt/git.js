_ = require 'lodash'

# status command plugin
module.exports = (git) ->
	return (opts) ->
		opts = {} if not opts
		args = if opts.full then [] else ['-s']
		git.run('status', args).then parser(opts)

parser = (opts) ->
	return parseNormal if opts.full
	return parseShort

# parser of output in short format
parseShort = (out) ->
	return [] if not out
	lines = out.split '\n'
	lines.map (l) ->
		status = l.substr(0, 2)
		file = l.substr(2).trim()
		return {
			status: fullStatus(status)
			file: file
		}

fullStatus = (s) ->
	switch s.trim()
		when 'M' then 'modified'
		when 'A' then 'new'
		when 'AM' then 'new'
		when 'D' then 'deleted'
		when 'R' then 'renamed'
		when 'C' then 'copied'
		when 'U' then 'updated'
		else return ''

# normal output parser
parseNormal = (out) ->
	return [] if not out

	lines = out.split '\n'
	lines = lines.map (l) -> trimStart(l, '#').trim()

	statuses = [
		['new file:', 'new'],
		['modified:', 'modified'],
		['removed:', 'deleted'],
		['deleted:', 'deleted']
	]

	# todo support untracked files

	files = lines.map (l) ->
		st = _.find statuses, (s)-> startsWith l, s[0]
		if st
			file = l.substr(st[0].length).trim()
			return {file: file, status: st[1]}
		return null

	return files.filter (f) -> f?

# string utils
startsWith = (s, prefix) ->
	r = new RegExp("^" + prefix + ".*$", "g")
	return r.test s

trimStart = (s, prefix) ->
	p = s.substr(0, prefix.length)
	return s.substr(prefix.length) if p == prefix
	return s