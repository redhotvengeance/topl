# topl

[![Build Status](https://travis-ci.org/redhotvengeance/topl.png)](https://travis-ci.org/redhotvengeance/topl)
(Supports TOML spec: [3f4224ecdc4a65fdd28b4fb70d46f4c0bd3700aa](https://github.com/mojombo/toml/tree/3f4224ecdc4a65fdd28b4fb70d46f4c0bd3700aa))

[Node.js](http://nodejs.org/) meet [TOML](https://github.com/mojombo/toml).

## What?
It's [Tom's Obvious, Minimal Language](https://github.com/mojombo/toml).

## Why?
Why not?

## Okay, but why in Node.js?
Because it's time to have a simple config language that works across **all** platforms, not just one.

## How to install

```bash
npm install topl
```

## How to use

### Require it
```js
var topl = require('topl');
```

### Parse it
```js
require('fs').readFile('<path to toml file>', function(err, data) {
  var parsedObject = topl.parse(data);

  console.log(parsedObject);
});
```

## Tests
Want to test it out? Install `mocha`:

```bash
npm install -g mocha
```

Then run the tests:

```bash
mocha
```

You can also run the example TOML in `test/example.toml` with:

```bash
cake test
```

Want to see the output as a string? Go for it:

```bash
cake -s test
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

Copyright (c) 2013 Ian Lollar

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
