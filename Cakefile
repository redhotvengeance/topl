fs = require('fs')
topl = require('./src/topl')

option '-s', '--string', 'Output test as string'

task 'test', 'Run test/example.toml though topl', (options) ->
  fs.readFile './test/example.toml', (err, data) =>
    if err
      console.log err
    else
      parsed = topl.parse data

      if options.string
        console.log JSON.stringify(parsed)
      else
        console.log parsed
