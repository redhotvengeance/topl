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
      assert.deepEqual {test: 'test'}, topl.parse '\ttest=\t"test"\t'

  describe 'comment', ->
    it 'should ignore comments', ->
      assert.deepEqual {}, topl.parse '# comment'
      assert.deepEqual {test: 'test'}, topl.parse 'test="test" # comment'

  describe 'integer', ->
    it 'should return an integer', ->
      assert.deepEqual {integer:1}, topl.parse 'integer=1'
      assert.deepEqual {integer:-1}, topl.parse 'integer=-1'

  describe 'float', ->
    it 'should return a float', ->
      assert.deepEqual {float:1.0}, topl.parse 'float=1.0'
      assert.deepEqual {float:-1.0}, topl.parse 'float=-1.0'

  describe 'boolean', ->
    it 'should return a boolean', ->
      assert.deepEqual {true: true}, topl.parse 'true=true'
      assert.deepEqual {true: false}, topl.parse 'true=false'

  describe 'string', ->
    it 'should be wrapped in double quotes', ->
      should.Throw (-> topl.parse("string='string'"))
      assert.deepEqual {string:'string'}, topl.parse 'string="string"'
    it 'should escape double quotes', ->
      should.Throw (-> topl.parse('string="\"quoted\""'))
      assert.deepEqual {string:'\\\"quoted\\\"'}, topl.parse 'string="\\"quoted\\""'
    it 'should escape forward slashes', ->
      should.Throw (-> topl.parse('path="C:\\Users\\nodejs\\templates"'))
      assert.deepEqual {path:'C:\\\\Users\\\\nodejs\\\\templates'}, topl.parse 'path="C:\\\\Users\\\\nodejs\\\\templates"'
    it 'should allow escaped null character', ->
      assert.deepEqual {char:'\\0'}, topl.parse 'char="\\0"'
    it 'should allow escaped tab character', ->
      assert.deepEqual {char:'\\t'}, topl.parse 'char="\\t"'
    it 'should allow escaped newline character', ->
      assert.deepEqual {char:'\\n'}, topl.parse 'char="\\n"'
    it 'should allow escaped carriage return character', ->
      assert.deepEqual {char:'\\r'}, topl.parse 'char="\\r"'

  describe 'array', ->
    it 'should return an array', ->
      assert.deepEqual {array: [1, 2]}, topl.parse 'array=[1, 2]'
    it 'should be homogenous', ->
      should.Throw (-> topl.parse('array=[1, "2"]'))
    it 'should support nested arrays', ->
      assert.deepEqual {array: [[1, 2],["1", "2"]]}, topl.parse 'array=[[1, 2], ["1", "2"]]'
    it 'should support multiline arrays', ->
      assert.deepEqual {array: ["one", "two"]}, topl.parse 'array=[\n"one",\n"two"\n]'
    it 'should allow trailing commas', ->
      assert.deepEqual {array: [1, 2]}, topl.parse 'array=[1, 2,]'
      assert.deepEqual {array: ["one", "two"]}, topl.parse 'array=[\n"one",\n"two",\n]'

  describe 'date', ->
    it 'should return a date', ->
      assert.deepEqual {date: new Date('1979-05-27T07:32:00Z')}, topl.parse 'date=1979-05-27T07:32:00Z'
    it 'should be ISO8601 zulu', ->
      should.Throw (-> topl.parse('date=1979-05-27T07:32:00'))

  describe 'group', ->
    it 'should create a group', ->
      assert.deepEqual {group: {test: 'test'}}, topl.parse '[group]\ntest="test"'
    it 'should create a subgroup', ->
      assert.deepEqual {group: {sub: {test: 'test'}}}, topl.parse '[group.sub]\ntest="test"'
    it 'should not allow overwriting keys', ->
      should.Throw (-> topl.parse('[group]\nkey="value"\n[group.key]\nvalue="fail"'))
