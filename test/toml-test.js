#!/usr/bin/env node

require('coffee-script/register');
fs = require('fs');
topl = require('../src/topl');

function pad(number) {
  var r = String(number);
  if ( r.length === 1 ) {
    r = '0' + r;
  }
  return r;
}

Date.prototype.toISOString = function() {
  return this.getUTCFullYear()
    + '-' + pad( this.getUTCMonth() + 1 )
    + '-' + pad( this.getUTCDate() )
    + 'T' + pad( this.getUTCHours() )
    + ':' + pad( this.getUTCMinutes() )
    + ':' + pad( this.getUTCSeconds() )
    + 'Z';
};

var input = fs.readFileSync('/dev/stdin').toString();

try {
  var output = topl.parse(input);
  var typedOutput = {};

  for (var key in output) {
    typedOutput[key] = getTyped(output[key]);
  }

  process.stdout.write(JSON.stringify(typedOutput));
}
catch (e) {
  process.stdout.write(1);
}

function getTyped(value) {
  var type = typeof value;
  var typed = {};

  if (type !== "object") {
    if (type === "boolean") {
      type = "bool";
    }

    if (type === "number") {
      if (value.toString().indexOf('.') < 0) {
        type = "integer";
      }
      else {
        type = "float";
      }
    }

    typed = {
      type: type,
      value: value.toString()
    }
  }
  else if (Object.prototype.toString.call(value) === "[object Array]") {
    var typedArray = [];
    var isTableArray = false;

    for (var i = 0; i < value.length; i++) {
      if (typeof value[i] === 'object') {
        if (Object.prototype.toString.call(value[i]) !== "[object Array]") {
          if (Object.prototype.toString.call(value[i]) !== "[object Date]") {
            isTableArray = true;
          }
        }
      }

      typedArray.push(getTyped(value[i]));
    }

    if (isTableArray) {
      typed = typedArray;
    }
    else {
      typed = {
        type: "array",
        value: typedArray
      };
    }
  }
  else if (Object.prototype.toString.call(value) === "[object Date]") {
    typed = {
      type: "datetime",
      value: value
    };
  }
  else {
    for (var key in value) {
      typed[key] = getTyped(value[key])
    }
  }

  return typed;
}
