# Cakefile

{print} = require 'sys'

{exec} = require "child_process"

{spawn} = require "child_process"

REPORTER = "list"

task "test", "run tests", ->
  invoke "build"
  tester = spawn 'node', ['./node_modules/mocha/bin/mocha', '--reporter', REPORTER, '--colors']
  tester.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  tester.stdout.on 'data', (data) ->
    print data.toString()

task "build", 'Compile sources', ->
  coffee = spawn 'coffee', ['-c', '-o', 'app/js', 'app/coffee']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()

task "watch", 'Watch src for changes', ->
  coffee = spawn 'coffee', ['-w', '-c', '-o', 'app/js', 'app/coffee']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()

task "run", 'Start the command-line', ->
  invoke "build"
  coffee = spawn 'node', ['app.js']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()
  coffee.on 'error', (error) ->
    process.stderr.write data.toString()
