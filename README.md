
# Card Game Generator

A tool for developing card games for and along with [Tabletop Simulator][].

Render custom decks of cards with whatever templating/rendering solution you prefer
(you can use HTML+CSS, SVG, even WebGL!),
and automatically export them to Tabletop Simulator.

This tool may not be a procedurally generated card game (PGCG),
but if you were going to make one, this would be the tool to do it with.

**Note:** This tool may not be in a usable state!
[Open an issue][] if you want that to change.


## Installation

* Have [Node.js][]
* `npm install card-game-generator --save-dev`


## Usage

You'll want to look at some examples like [some playing cards][], [Systemocracy][], or [Prosperity][].

### `new CardGameGenerator({cardSets, counters})`

`cardSets` can be an object keyed by set/deck name
(you can say "Cards" if you only need one set),
where the values are arrays of cards.
Each card object can have whatever data you want.

`counters` is a poorly named option that lets you create
both tokens and tiles.
It can be an object with ignored keys and values like
`{type: "token", fname: "images/cherry.png"}`
or
`{type: "tile", obverse: "images/lemon.png", reverse: "images/lime.png"}`

### `renderCards({page, to, cardWidth, cardHeight, scale, debug}, callback)`

Starts a renderer process with [nw.js][], and calls back when it exits.

`page` should be a path to an `html` file which displays the cards.

`to` specifies the output directory, e.g.
`export/images` or `images/export`
(Directories are created automatically.)

`cardWidth`/`Height` must be the exact width and height in pixels of each individual card.
You can measure this with Inspect Element on the page.

`scale` specifies the zoom level applied when rendering.
Use this to increase the resolution of the rendered cards.
You could also just make the card width/height huge but that's not recommended.

**NOTE**: this option is temporarily ignored and hardcoded as `2`

`debug` makes the window(s) used for rendering ~~show up~~ stay open
so you can inspect the page(s) if something doesn't look right
(with <kbd>F12</kbd> / <kbd>⌘+⌥+i</kbd>)

`callback` takes an error as an argument
for if the process crashes or fails to start,
but it's not guaranteed to have exported properly even in absence of an error.
The rendering is based on a timer, so if the page doesn't finish rendering in that time, it can get messed up.

### `exportTabletopSimulatorSave({to, saveName, imagesURL, renderedImagesURL}, callback)`

`to` specifies the output directory, e.g.
`export` or `data/export` or `Chest`
(Directories are created automatically.)

`saveName` determines the filename of the savegame
and the name of the save as it appears in Tabletop Simulator's Chest.

`imagesURL` specifies where the token/tile images are hosted, e.g.
`https://raw.githubusercontent.com/you/game-repo/gh-pages/images`

`renderedImagesURL` specifies where the rendered card images are hosted, e.g.
`https://raw.githubusercontent.com/you/game-repo/gh-pages/export/images`


## TODO

* Rewrite "`counters`" part of the API to be game-agnostic
  (just have `tokens` and `tiles`)

* Compile CoffeeScript / just use JS

* Make cross-platform (should just need to know what the Tabletop Simulator directory is on platforms other than Windows)

* Handle a single array of cards with a default set name (like "Cards")

* Maybe handle card filtering in card-game-generator instead of having the card game project have to handle filtering based on the `location.hash`

* Detect card size automatically! You shouldn't have to pass in the dimensions.

* Possibly populate the cache rather than just clearing it
  (Note that while this could make it so you could see changes in TS immediately (before commiting and pushing), it could make it unclear whether the image URLs are correct)

* Export minimal rows of cards

* Handle the case of >= 70 cards in a single deck

* Maybe allow starting card sets off rendering early

* Maybe allow previewing the card sets directly from the renderer once rendered

* Support decks with separate backs for each card


### License

The MIT License (MIT)
Copyright (c) 2016 Isaiah Odhner

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


[Node.js]: https://nodejs.org/en/
[nw.js]: http://nwjs.io/
[Tabletop Simulator]: http://store.steampowered.com/app/286160/
[Open an issue]: https://github.com/1j01/card-game-generator/issues/new
[some playing cards]: https://github.com/1j01/techy-playing-cards
[Systemocracy]: https://github.com/1j01/systemocracy
[Prosperity]: https://github.com/1j01/prosperity
