require('coffee-script/register')
fs = require('fs')
{exec} = require 'child_process'
topl = require('./src/topl')

option '-s', '--string', 'Output test as string'

task 'test', 'Run examples in test/fixtures though topl', (options) ->
  fs.readFile './test/fixtures/example.toml', (err, data) =>
    if err
      console.log err
    else
      parsed = topl.parse data

      if options.string
        console.log JSON.stringify(parsed)
      else
        console.log parsed

  fs.readFile './test/fixtures/hard_example.toml', (err, data) =>
    if err
      console.log err
    else
      parsed = topl.parse data

      if options.string
        console.log JSON.stringify(parsed)
      else
        console.log parsed

task 'build', 'Compile topl JavaScript files from CoffeeScript source', ->
  exec './node_modules/.bin/coffee -c -o lib src', (error, stdout, stderr) ->
    if error
      console.log error
    else
      exec './node_modules/.bin/uglifyjs -m --comments /topl/ -o ./lib/topl.min.js ./lib/topl.js', (error, stdout, stderr) ->
        if error
          console.log error
        else
          console.log 'Build complete!'
