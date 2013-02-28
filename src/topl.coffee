### PUBLIC ###
parse = (data) =>
  @parsed = {}

  lines = data.toString().replace(/\r\n/g, "\n").split("\n")

  for line, i in lines
    @currentLine = i + 1
    object = null

    stripped = stripComments line
    trimmed = trimWhitespace stripped

    if trimmed is ''
      # You are nothing! Get out of here!
    else if /^\[(.*)\]$/i.test trimmed
      createGroup trimmed
    else if /\[$/.test trimmed
      @currentArray = trimmed
    else if /^\]$/.test trimmed
      @currentArray += trimmed
      object = createObject @currentArray
      @currentArray = null
    else
      if @currentArray?
        @currentArray += trimmed
      else
        object = createObject trimmed

    if object?
      for key, value of object
        if @currentGroup?
          @currentGroup[key] = value
        else
          @parsed[key] = value

  @parsed

### PRIVATE ###
stripComments = (text) =>
  text.split("#")[0]

stripWhitespace = (text) =>
  text.replace /\s/g, ''

trimWhitespace = (text) =>
  text.replace(/^\s\s*/, '').replace(/\s\s*$/, '')

createGroup = (string) =>
  @currentGroup = null

  groupString = string.substring 1, string.length - 1
  groupArray = groupString.split '.'

  ref = @parsed

  for group, i in groupArray
    if !ref[group]?
      ref[group] = {}

    ref = ref[group]
    
    if i is groupArray.length - 1
      @currentGroup = ref

createObject = (text) =>
  values = text.split '='

  key = stripWhitespace values[0]

  valueString = trimWhitespace values[1]

  if /^\[(.*)\]$/i.test valueString
    value = createArray(valueString, 1).array
  else
    value = createPrimitive(valueString).value

  if value?
    object = {}
    object[key] = value
    object
  else
    null

createArray = (text, location) =>
  array = []

  while location < text.length
    if text.charAt(location) is ' ' or text.charAt(location) is ',' or text.charAt(location) is ']'
      location++

      if text.charAt(location) is ',' or text.charAt(location) is ']'
        break

    else if text.charAt(location) is '['
      newArray = createArray text, location + 1
      array.push newArray.array
      location = newArray.location
    else
      newValue = createArrayValue text, location

      if !type?
        type = newValue.value.type
      else
        if newValue.value.type isnt type
          throw new Error 'Check your arrays! They have to be all the same type!'

      array.push newValue.value.value
      location = newValue.location

  {array: array, location: location}

createArrayValue = (text, location) =>
  value = ''

  while location < text.length
    if text.charAt(location) is ',' or text.charAt(location) is ']'
      if text.charAt(location) is ','
        location++
      
      break
    else
      value += text.charAt location
      location++

  value = createPrimitive value

  {value:value, location:location}

createPrimitive = (text) =>
  text = trimWhitespace text

  primitive = {}

  if /^\"(.*)\"$/i.test text
    primitive.type = 'string'
    
    string = text.substring 1, text.length - 1

    for char, i in string
      if char is '\\'
        if string.charAt(i - 1) isnt '\\'
          if string.charAt(i + 1) isnt '0' and string.charAt(i + 1) isnt 't' and string.charAt(i + 1) isnt 'n' and string.charAt(i + 1) isnt 'r' and string.charAt(i + 1) isnt '"' and string.charAt(i + 1) isnt '\\'
            throw new Error 'Check your stings! Escape any forward slashes!'
      else if char is '"'
        if string.charAt(i - 1) isnt '\\'
          throw new Error 'Check your stings! Escape any double quotes!'

    primitive.value = string
    primitive
  else if /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})Z$/.test text
    primitive.type = 'date'
    primitive.value = new Date text
    primitive
  else if text is 'true'
    primitive.type = 'boolean'
    primitive.value = true
    primitive
  else if text is 'false'
    primitive.type = 'boolean'
    primitive.value = false
    primitive
  else if /^-?\d+$/.test text
    primitive.type = 'integer'
    primitive.value = parseInt text
    primitive
  else if /^-?\d+\.?\d+$/.test text or /^-?\.?\d+$/.test text
    primitive.type = 'float'
    primitive.value = parseFloat text
    primitive
  else
    throw new Error "Something is wrong on line #{@currentLine}"

module.exports.parse = parse
