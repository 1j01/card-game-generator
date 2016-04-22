
# Card Game Generator

A tool for developing card games for and along with [Tabletop Simulator][].

Use HTML or SVG templates to create and render custom decks of cards
and style them with CSS.


## Installation

* Have [Node.js][] and create a project
* `npm install card-game-generator --save-dev`

<!--
## Import into Tabletop Simulator

Without installing, you can save [Card Game.json][] to `%USERPROFILE%\Documents\My Games\Tabletop Simulator\Saves\Chest\`

If installed, you can just `npm run export-to-tabletop-simulator`

In Tabletop Simulator, go to Host > Chest > Saved Objects and find Card Game.


## Update cards

* Edit `cards.json` and preview with `index.html`
* `npm run export`
* `npm run export-to-tabletop-simulator`

<!-- When there are multiple card sets:
You can `set PARALLEL_EXPORT=ON` before running `export` to speed it up significantly **IF** it's on a powerful enough machine.
If it's not powerful enough it might freeze up the entire computer.
It needs a lot of video memory.
 -->

## TODO

* API



[Node.js]: https://nodejs.org/en/
[Tabletop Simulator]: http://store.steampowered.com/app/286160/
