parse = require 'parse-diff'

# diff command plugin
module.exports = (git) ->
	# todo provide more options
	diff = (files) ->
		files = [] if not files
		args = ['-u'] # unified diff format
		git.run('diff-files', [args..., files...]).then(parse)
	return diff
