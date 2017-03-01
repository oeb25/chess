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

import {channel} from "./socket"

window.chess = {
  state: {
    selected: false
  },

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

  move(from, to) {
    chess.find(to).className = chess.find(from).className
    chess.find(from).className = 'piece empty'
  },

  removeHighlights() {
    for (let el of document.querySelectorAll('.board .highlight')) {
      console.log(el)
      el.classList.remove('highlight')
    }
  },
  highlight(i) {
    chess.find(i).classList.add('highlight')
    return i
  },

  click(e, pos) {
    // if (chess.state.selected && chess.state.selected[0] == pos[0] && chess.state.selected[1] == pos[1]) {
    //   chess.state.selected = false
    //   chess.removeHighlights()
    // } else
    if (chess.state.selected && e.classList.contains('highlight')) {
      channel.push('move', {from: chess.state.selected, to: pos})
    } else {
      channel.push('select', pos)
        .receive("ok", ({ moves }) => {
          chess.state.selected = pos
          chess.removeHighlights()
          moves.map(chess.highlight)
        })
        .receive("error", e => console.log('error', e))
        .receive("timeout", e => console.log('timeout', e))
    }
  },

  bindClick() {
    for (let r = 0; r < 8; r++) {
      for (let c = 0; c < 8; c++) {
        const pos = [r, c]
        const elem = chess.find(pos)
        elem.onclick = () => chess.click(elem, pos)
      }
    }
  },
}

// m.map(chess.highlight)
chess.bindClick()

channel
  .on("move", ({from, to}) => {
    chess.state.selected = false
    chess.removeHighlights()
    chess.move(from, to)
  })
