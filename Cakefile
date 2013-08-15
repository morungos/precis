# Cakefile

fs         = require 'fs'
util       = require 'util'

{print} = require 'sys'

{exec} = require "child_process"

{spawn} = require "child_process"

REPORTER = "list"

build = (cb) ->
  files = fs.readdirSync 'app/coffee'
  files = ('app/coffee/' + file for file in files when file.match(/\.(?:lit)?coffee$/))
  exec 'cp -rf app/coffee/lib app/js/lib', (error, stdout, stderr) ->
    run ['-c', '-o', 'app/js'].concat(files), cb

run = (args, cb) ->
  proc =         spawn 'coffee', args
  proc.stderr.on 'data', (buffer) -> console.log buffer.toString()
  proc.on        'exit', (status) ->
    process.exit(1) if status != 0
    cb() if typeof cb is 'function'

task "test", "run tests", ->
  build ->
    tester = spawn 'node', ['./node_modules/mocha/bin/mocha', '--reporter', REPORTER, '--colors', '--compilers', 'coffee:coffee-script']
    tester.stderr.on 'data', (data) ->
      process.stderr.write data.toString()
    tester.stdout.on 'data', (data) ->
      print data.toString()

task "build", 'Compile sources', ->
  build ->

task "watch", 'Watch src for changes', ->
  coffee = spawn 'coffee', ['-w', '-c', '-o', 'app/js', 'app/coffee']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()

task "run", 'Start the command-line', ->
  build ->
    coffee = spawn 'node', ['app/js/main.js']
    coffee.stderr.on 'data', (data) ->
      process.stderr.write data.toString()
    coffee.stdout.on 'data', (data) ->
      print data.toString()
    coffee.on 'error', (error) ->
      process.stderr.write data.toString()
