# topl

[![Build Status](https://travis-ci.org/redhotvengeance/topl.png)](https://travis-ci.org/redhotvengeance/topl)
[![NPM version](https://badge.fury.io/js/topl.png)](http://badge.fury.io/js/topl)

JavaScript ([Node.js](http://nodejs.org/) and browser) meets [TOML](https://github.com/mojombo/toml).

Supports most recent TOML spec ([v0.2.0](https://github.com/mojombo/toml/commit/4f23be43e42775493f142e7dd025b6227e037dd9)).

## What?
It's [Tom's Obvious, Minimal Language](https://github.com/mojombo/toml).

## Why?
Why not?

## Okay, but why in Node.js and the browser?
Because it's time to have a simple config language that works across **all** platforms, not just one.

## How to install

```bash
npm install topl
```

## How to use

### Node.js

#### Bootstrap it

```bash
./script/bootstrap
```

#### Require it
```js
var topl = require('topl');
```

#### Parse it
```js
require('fs').readFile('<path to toml file>', function(err, data) {
  var parsedObject = topl.parse(data);

  console.log(parsedObject);
});
```

### Browser

#### Load it

```html
<script src="topl.min.js" type="text/javascript"></script>
```

#### Parse it

```js
topl.parse('hello = "world"');
```

## Tests
Simply run the helper script:
```bash
./script/test
```

You can also run the examples in `test/fixtures` through topl with:

```bash
cake test
```

Want to see the output as a string? Go for it:

```bash
cake -s test
```

`topl` also supports running the [toml-test](https://github.com/BurntSushi/toml-test) test suite. Pass `test/toml-test.js` to `toml-test` to run it:

```bash
export GOPATH=$HOME/go
go get github.com/BurntSushi/toml-test
~/go/bin/toml-test ./test/toml-test.js
```

## Build
You can compile the CoffeeScript source into the JavaScript files in `lib` by running:

```bash
cake build
```

## Contribute

1. Fork
2. Create
3. Code
4. Test
5. Push
6. Submit
7. Yay!

## License

(The MIT License)

Copyright (c) 2014 Ian Lollar

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
