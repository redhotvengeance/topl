###!
# topl (v0.3.1) - a TOML parser for JavaScript
# Copyright (c) 2014 Ian Lollar (rhv@redhotvengeance.com)
# Distributed under The MIT License
# https://github.com/redhotvengeance/topl
 ###

### PUBLIC ###
parse = (data) =>
  @parsed = {}
  @index = -1
  @line = 1
  @currentCharacter = ''
  @currentObject = @parsed
  @currentKey = ''
  @tableKeys = []

  lines = data.toString().replace(/\r\n/g, "\n").split("\n")
  lines.push ''

  for line in lines
    line = trimWhitespace line

  @text = lines.join('\n')

  while progress()
    switch @currentCharacter
      when ' ' then progress()
      when '#' then killComment()
      when '[' then makeTable()
      else makeKey()

  @parsed

### PRIVATE ###
error = (message) =>
  throw new Error(message)

progress = (char) =>
  if char and char isnt nextCharacter()
    error "Syntax error on line #{@line}"

  if @currentCharacter is '\n'
    @line++

  @index++
  @currentCharacter = @text.charAt @index

nextCharacter = =>
  @text.charAt @index + 1

stripWhitespace = =>
  if nextCharacter() is ' ' or nextCharacter() is '\t'
    while progress()
      if nextCharacter() isnt ' ' and nextCharacter() isnt '\t'
        break

trimWhitespace = (text) =>
  text.replace(/^[\s]+/, '').replace(/[\s]+$/, '')

killComment = =>
  while progress()
    if @currentCharacter is '\n' or nextCharacter() is '\n'
      break

parseString = =>
  string = ''

  if nextCharacter() isnt '"'
    while progress()
      if @currentCharacter is '\\'
        progress()

        if @currentCharacter is 'u'
          uffff = 0

          for num in [1..4]
            hex = parseInt progress(), 16

            if !isFinite(hex)
              break

            uffff = uffff * 16 + hex

          string += String.fromCharCode uffff
        else
          char = ''

          switch @currentCharacter
            when 'b' then char = '\b'
            when 't' then char = '\t'
            when 'n' then char = '\n'
            when 'f' then char = '\f'
            when 'r' then char = '\r'
            when '"' then char = '\"'
            when '/' then char = '\/'
            when '\\' then char = '\\'
            else
              error "Whatever you're trying to escape on line #{@line} isn't supported. Try adding it in Unicode (\\uXXXX)."

          string += char
      else
        string += @currentCharacter

      if nextCharacter() is '"'
        break

  progress()

  {type: 'string', value: string}

parseNumber = =>
  number = @currentCharacter

  if /[.Z:T\d-]/.test(nextCharacter())
    while progress()
      number += @currentCharacter
      if !(/[.Z:T\d-]/.test(nextCharacter()))
        break

  if /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})Z$/.test number
    type = 'date'
    result = new Date(number)
  else if /^-?(\d+)?\.\d+$/.test number
    type = 'float'
    result = parseFloat(number)
  else if /^-?\d+$/.test number
    type = 'integer'
    result = parseInt(number)
  else
    error "Invalid primitive type on line #{@line}"

  {type: type, value: result}

parseBoolean = =>
  switch @currentCharacter.toLowerCase()
    when 't'
      progress('r')
      progress('u')
      progress('e')
      result = true
    when 'f'
      progress('a')
      progress('l')
      progress('s')
      progress('e')
      result = false
    else
      error "Invalid primitive type on line #{@line}"

  {type: 'boolean', value: result}

makeArray = =>
  array = []
  type = null

  stripWhitespace()

  while progress()
    value = getValue()

    if value
      type = value.type if !type

      if value.type isnt type
        error "Array on line #{@line} is mixing data types! That is a TOML no-no."

      array.push value.value

      stripWhitespace()
      progress()

    if @currentCharacter is ',' or @currentCharacter is '\n'
      stripWhitespace()
    else if @currentCharacter is ']'
      break

  {type: 'array', value: array}

makeTable = =>
  stripWhitespace()
  progress()

  array = false

  if @currentCharacter is '['
    array = true

    stripWhitespace()
    progress()

  key = @currentCharacter

  if nextCharacter() isnt ']'
    while progress()
      if @currentCharacter isnt '[' and @currentCharacter isnt '#'
        key += @currentCharacter
      else
        error "Improper table declaration on line #{@line}"

      if nextCharacter() is ']'
        break

  progress()
  stripWhitespace()
  key = trimWhitespace(key)

  if array
    progress()
    stripWhitespace()

  if nextCharacter() isnt '\n' and nextCharacter() isnt '#'
    error "Improper table declaration on line #{@line}"

  tableArray = key.split '.'

  @currentObject = @parsed

  for table, i in tableArray
    table = trimWhitespace(table)
    last = false

    if table.length <= 0
      error "Improper table declaration on line #{@line}"

    if i is tableArray.length - 1
      last = true

    if !@currentObject[table]?
      if array and last
        @currentObject[table] = [{}]
        @currentObject = @currentObject[table][0]
      else
        @currentObject[table] = {}
        @currentObject = @currentObject[table]
    else
      if array
        if last
          if !Array.isArray(@currentObject[table])
            error "Check your tables and keys! You\'re attempting an overwrite on line #{@line}!"

          @currentObject[table].push {}
          @currentObject = @currentObject[table][@currentObject[table].length - 1]
        else
          if Array.isArray(@currentObject[table])
            @currentObject = @currentObject[table][@currentObject[table].length - 1]
          else
            @currentObject = @currentObject[table]
      else
        for tableKey in @tableKeys
          if tableKey is key
            error "Check your tables and keys! You\'re attempting an overwrite on line #{@line}!"

        @currentObject = @currentObject[table]

        if Array.isArray(@currentObject)
          @currentObject = @currentObject[@currentObject.length - 1]

  @tableKeys.push key
  @currentKey = key

makeKey = =>
  if /[\w~!@#$^&*()_+-`1234567890\[\]\\|\/?><.,;:']/i.test @currentCharacter
    key = @currentCharacter

    if nextCharacter() isnt '='
      while progress()
        key += @currentCharacter
        if nextCharacter() is '='
          break

    stripWhitespace()
    key = trimWhitespace(key)

    if progress() is '='
      stripWhitespace()
      progress()

      value = getValue()

    if !value
      error "Syntax error on line #{@line}"

    if @currentObject[key]?
      error "Trying to overwrite previously set value on line #{@line}"

    @currentObject[key] = value.value
    @tableKeys.push "#{@currentKey}.#{key}"

    stripWhitespace()

    if nextCharacter() isnt '\n' and nextCharacter() isnt '#'
      error "Syntax error on line #{@line}"

getValue = =>
  value = null

  switch @currentCharacter
    when '#'
      killComment()
    when '"'
      value = parseString()
    when "'"
      error "Check the string on line #{@line}! TOML does not support single-quoted strings."
    when '['
      value = makeArray()
    when '-'
      value = parseNumber()
    when ']'
      break
    when '\n'
      stripWhitespace()
    else
      if '0' <= @currentCharacter <= '9'
        value = parseNumber()
      else
        value = parseBoolean()
        if value is null
          error "Invalid primitive type on line #{@line}"

  value

if typeof Array.isArray is 'undefined'
  Array.isArray = (obj) ->
    Object.toString.call(obj) is '[object] Array'

if exports?
  exports.parse = parse
else
  @['topl'] = {}
  @['topl']['parse'] = parse
