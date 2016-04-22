
# Card Game Generator

A tool for developing card games for and along with [Tabletop Simulator][].

Render custom decks of cards with whatever templating solution you prefer,
and automatically export them to Tabletop Simulator.

This tool may not be a procedurally generated card game (PGCG),
but if you were going to make one, this would be the tool to do it with.

**Note:** This tool is a work in progress!
Don't try to use it just yet.

## Installation

* Have [Node.js][] and create a project
* `npm install card-game-generator --save-dev`


## TODO

* API and documentation

* Compile CoffeeScript

* Make cross-platform (should just need to know what the Tabletop Simulator directory is on platforms other than Windows)

* Better feedback while exporting

* Manage the cache better than just clearing it

* Export minimal rows of cards

* Handle the case of >= 70 cards in a single deck

* Support decks with backs for each card


### License

The MIT License (MIT)
Copyright (c) 2016 Isaiah Odhner

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


[Node.js]: https://nodejs.org/en/
[Tabletop Simulator]: http://store.steampowered.com/app/286160/
