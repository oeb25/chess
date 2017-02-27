// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

window.chess = {
  toIndicies(i) {
    const [a, b] = i.split('')
    return [8 - b, (parseInt(a, 32) - 10)]
  },
  fromIndices([b, a]) {
      return (a + 10).toString(32) + '' + (8 - b)
  },

  find([r, c]) {
    return document.querySelector('.board').children[r].children[c]
  },

  highlight(i) {
    chess.find(i).classList.add('highlight')
    return i
  },

  bindClick() {
    for (let r = 0; r < 8; r++) {
        for (let c = 0; c < 8; c++) {
            const i = chess.fromIndices([r, c])
            chess.find([r, c]).href = window.location.pathname + '?select=' + i
        }
    }
  },
}

m.map(chess.highlight)
chess.bindClick()
