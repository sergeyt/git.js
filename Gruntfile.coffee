module.exports = (grunt) ->

  # Project configuration.
	grunt.initConfig
		pkgFile: 'package.json'

		jshint:
			options:
				# Expected an assignment or function call and instead saw an expression.
				'-W030': true,
				globals:
					node: true,
					console: true,
					module: true,
					require: true
			all:
				src: ['*.js']

		coffeelint:
			options:
				no_tabs: {level: 'ignore'}
				indentation: {level: 'ignore'}
			dev: ['*.coffee', 'lib/**/*.coffee']

	grunt.loadNpmTasks 'grunt-contrib-jshint'
	grunt.loadNpmTasks 'grunt-coffeelint'

	grunt.registerTask 'lint', ['coffeelint', 'jshint']
	grunt.registerTask 'test', ['lint']
	grunt.registerTask 'default', ['test']
