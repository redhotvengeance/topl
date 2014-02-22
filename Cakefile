fs = require('fs')
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
