parse = require 'parse-diff'

# diff command plugin
module.exports = (git) ->
	# todo provide more options
	return (files) ->
		files = [] if not files
		args = ['-u'] # unified diff format
		git.run('diff-files', [args..., files...]).then(parse)
