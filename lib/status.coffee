_ = require 'lodash'

# status command plugin
module.exports = (git) ->
	return (opts) ->
		opts = {} if not opts
		cmd = 'status'
		cmd += '-s' if opts.short
		git.run(cmd).then parser(opts)

parser = (opts) ->
	return parseShort if opts.short
	return parseNormal

parseShort = (out) ->
	lines = out.split '\n'
	lines = lines.filter (l) ->
		status = l.substr(0, 2).trim()
		status != 'D'
	lines.map (l) ->
		parts = l.trim().split ' '
		# todo unified status
		return {status: parts[0], file: parts[1]}

parseNormal = (out) ->
	lines = out.split '\n'
	lines = lines.map (l) -> trimStart(l, '#').trim()

	statuses = [
		['new file:', 'new'],
		['modified:', 'modified'],
		['removed:', 'removed'],
	]

	# todo add untracked files

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