fs = require 'fs'
assert = require 'assert'
chai = require 'chai'
should = chai.should()
topl = require '../src/topl'

describe 'topl', ->
  describe 'whitespace', ->
    it 'should ignore spaces', ->
      assert.deepEqual {test: 'test'}, topl.parse '    test =    "test"   '
    it 'should ignore tabs', ->
      assert.deepEqual {test: 'test'}, topl.parse '\ttest = \t"test"\t'

  describe 'comment', ->
    it 'should ignore comments', ->
      assert.deepEqual {}, topl.parse '# comment'
      assert.deepEqual {test: 'test'}, topl.parse 'test = "test" # comment'
      assert.deepEqual {test: 1}, topl.parse 'test = 1 # comment'
      assert.deepEqual {test: new Date('1979-05-27T07:32:00Z')}, topl.parse 'test = 1979-05-27T07:32:00Z # comment'
      assert.deepEqual {test: true}, topl.parse 'test = true # comment'
      assert.deepEqual {test: ["item"]}, topl.parse 'test = [\n"item",\n# comment\n]'
      assert.deepEqual {test: {}}, topl.parse '[test] # comment'
      assert.deepEqual {test: [{}]}, topl.parse '[[test]] # comment'
    it 'should not strip appropriate non-comment hashbangs', ->
      assert.deepEqual {test: 'test # with comment in string'}, topl.parse 'test = "test # with comment in string" # and comment out of string'
      assert.deepEqual {"test#": {}}, topl.parse '[test#] # comment'
      assert.deepEqual {"test#": [{}]}, topl.parse '[[test#]] # comment'
    it 'should error at missing hashbangs', ->
      should.Throw (-> topl.parse('test = "test" hanging comment'))
      should.Throw (-> topl.parse('test = 1 hanging comment'))
      should.Throw (-> topl.parse('test = true hanging comment'))
      should.Throw (-> topl.parse('test = 1979-05-27T07:32:00Z hanging comment'))
      should.Throw (-> topl.parse('test = [1, 2] hanging comment'))
      should.Throw (-> topl.parse('[test] hanging comment'))

  describe 'integer', ->
    it 'should return an integer', ->
      assert.deepEqual {integer: 1}, topl.parse 'integer = 1'
      assert.deepEqual {integer: -1}, topl.parse 'integer = -1'

  describe 'float', ->
    it 'should return a float', ->
      assert.deepEqual {float: 1.0}, topl.parse 'float = 1.0'
      assert.deepEqual {float: -1.0}, topl.parse 'float = -1.0'

  describe 'boolean', ->
    it 'should return a boolean', ->
      assert.deepEqual {true: true}, topl.parse 'true = true'
      assert.deepEqual {true: false}, topl.parse 'true = false'
    it 'should error on anything other than "true" or "false"', ->
      should.Throw (-> topl.parse("true = TRUE"))
      should.Throw (-> topl.parse("true = FALSE"))
      should.Throw (-> topl.parse("true = null"))

  describe 'string', ->
    it 'should be wrapped in double quotes', ->
      should.Throw (-> topl.parse("string = 'string'"))
      assert.deepEqual {string:"string"}, topl.parse 'string = "string"'
    it 'should allow escaped backspace character', ->
      assert.deepEqual {char:"\b"}, topl.parse 'char = "\\b"'
    it 'should allow escaped tab character', ->
      assert.deepEqual {char:"\t"}, topl.parse 'char = "\\t"'
    it 'should allow escaped linefeed character', ->
      assert.deepEqual {char:"\n"}, topl.parse 'char = "\\n"'
    it 'should allow escaped form feed character', ->
      assert.deepEqual {char:"\f"}, topl.parse 'char = "\\f"'
    it 'should allow escaped carriage return character', ->
      assert.deepEqual {char:"\r"}, topl.parse 'char = "\\r"'
    it 'should allow escaped quote character', ->
      should.Throw (-> topl.parse('string = "\"quoted\""'))
      assert.deepEqual {string:"\"quoted\""}, topl.parse 'string = "\\"quoted\\""'
    it 'should allow escaped slash character', ->
      assert.deepEqual {char:"\/"}, topl.parse 'char = "\\/"'
    it 'should allow escaped backslash character', ->
      should.Throw (-> topl.parse('path = "C:\\Users\\nodejs\\templates"'))
      assert.deepEqual {path:"C:\\Users\\nodejs\\templates"}, topl.parse 'path = "C:\\\\Users\\\\nodejs\\\\templates"'
    it 'should allow escaped unicode character', ->
      assert.deepEqual {char:"!"}, topl.parse 'char = "\u0021"'

  describe 'array', ->
    it 'should return an array', ->
      assert.deepEqual {array: [1, 2]}, topl.parse 'array = [1, 2]'
    it 'should be single-typed', ->
      should.Throw (-> topl.parse('array = [1, "2"]'))
    it 'should support nested arrays', ->
      assert.deepEqual {array: [[1, 2],["1", "2"]]}, topl.parse 'array = [[1, 2], ["1", "2"]]'
    it 'should support multiline arrays', ->
      assert.deepEqual {array: ["one", "two"]}, topl.parse 'array = [\n"one",\n"two"\n]'
    it 'should allow trailing commas', ->
      assert.deepEqual {array: [1, 2]}, topl.parse 'array = [1, 2,]'
      assert.deepEqual {array: ["one", "two"]}, topl.parse 'array = [\n"one",\n"two",\n]'

  describe 'date', ->
    it 'should return a date', ->
      assert.deepEqual {date: new Date('1979-05-27T07:32:00Z')}, topl.parse 'date = 1979-05-27T07:32:00Z'
    it 'should be ISO 8601 zulu', ->
      should.Throw (-> topl.parse('date = 1979-05-27T07:32:00'))

  describe 'table', ->
    it 'should create a table', ->
      assert.deepEqual {table: {test: 'test'}}, topl.parse '[table]\ntest = "test"'
    it 'should create an empty table when there are no key/value pairs', ->
      assert.deepEqual {a: {}}, topl.parse '[a]'
    it 'should create a subtable', ->
      assert.deepEqual {table: {sub: {test: 'test'}}}, topl.parse '[table.sub]\ntest = "test"'
    it 'should allow writing to a super-table if it doesn\'t overwrite any keys', ->
      assert.deepEqual {a: {b: {c: 1 }}, d: 2 }, topl.parse '[a.b]\nc = 1\n[a]\nd = 2'
    it 'should not allow overwriting keys', ->
      should.Throw (-> topl.parse('[table]\nkey = "value"\n[table.key]\nvalue = "fail"'))
      should.Throw (-> topl.parse('[table]\nkey = "value"\n[table]\nvalue = "fail"'))

  describe 'array of tables', ->
    it 'should create an array of tables', ->
      assert.deepEqual {table: [{test: "test"}]}, topl.parse '[[table]]\ntest = "test"'
    it 'should create an empty table when there are no key/value pairs', ->
      assert.deepEqual {a: [{}]}, topl.parse '[[a]]'
    it 'should nest arrays of tables', ->
      assert.deepEqual {table: [{sub: [{}]}]}, topl.parse '[[table]]\n[[table.sub]]'
    it 'should nest tables in arrays of tables', ->
      assert.deepEqual {table: [{sub: {}}]}, topl.parse '[[table]]\n[table.sub]'
