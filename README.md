
# Card Game Generator

A tool for developing card games for or with [Tabletop Simulator][].

Render custom decks of cards with whatever templating/rendering solution you prefer
(you can use HTML+CSS, SVG, even WebGL!),
and automatically export them to Tabletop Simulator.

## Installation

* Have [Node.js][]
* `npm install card-game-generator --save-dev`

## Usage

You'll want to look at some examples like [some standard-ish playing cards][techy-playing-cards], [Systemocracy][], or [Prosperity][].

Set an environment variable `TABLETOP_SIMULATOR_FOLDER` to the `Tabletop Simulator` folder that should contain folders `Saves` and `Mods`.
If the folder doesn't have these folders, the code may need to be updated for a different operating system or a new version of Tabletop Simulator.

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

### `renderCards({page, to, scale, debug}, callback)`

Starts a renderer process with [Puppeteer][], and calls back when it exits.

`page` should be a path pointing to an `html` file which displays the cards.  
It will be served over HTTP to avoid issues with with the `file:` protocol.

The `location.hash` will have the card set name in it so you can switch between rendering different card sets on one page.

There must be one or more elements with the CSS class `card`.  
These elements must have an integer width and height in pixels.

`to` specifies the output directory, e.g.
`export/images` or `images/export`.
Directories are created automatically.

`scale` specifies the zoom level applied when rendering.
This must be an integer, greater than or equal to 1.
Use this to increase the resolution of the rendered cards.
You could also just make the card width/height huge but that's not recommended.

`debug` makes the browser window used for rendering show up
so you can inspect the page if something doesn't look right.

`callback` takes an error as an argument, or null/undefined in case of success.

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

* Handle a single array of cards with a default set name (like "Cards")

* Maybe handle card filtering in card-game-generator instead of having the card game project have to handle filtering based on the `location.hash`

* Detect card size automatically! You shouldn't have to pass in the dimensions.

* Export floating text labels for each deck in the Tabletop Simulator save

* Possibly populate the Tabletop Simulator cache rather than just clearing it
  (Note that while this could make it so you could see changes in TS immediately (before commiting and pushing), it could make it unclear whether the image URLs are correct)

* Export minimal rows of cards

* Handle the case of >= 70 cards in a single deck

* Maybe allow starting card sets off rendering earlier than the page load detection with a function the page can call

* Maybe add back the fancy loading indicator window in some way
  * Maybe allow previewing the card sets directly from the renderer once rendered

* Support decks with separate backs for each card

### Changelog

See [CHANGELOG.md](CHANGELOG.md) for API upgrading guide and history of changes.

### License

The MIT License (MIT)  
Copyright (c) 2016 Isaiah Odhner

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


[Node.js]: https://nodejs.org/en/
[Puppeteer]: https://github.com/puppeteer/puppeteer/
[Tabletop Simulator]: http://store.steampowered.com/app/286160/
[Open an issue]: https://github.com/1j01/card-game-generator/issues/new
[techy-playing-cards]: https://github.com/1j01/techy-playing-cards
[Systemocracy]: https://github.com/1j01/systemocracy
[Prosperity]: https://github.com/1j01/prosperity
