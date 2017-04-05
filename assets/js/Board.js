import React from 'react';

const contains = (highlights, [r, c]) =>
  highlights.filter(([a, b]) => r == a && c == b).length;

const Board = ({ board, highlights = [], onClick = () => {}, flip = true }) => (
  <div className="board" style={{ transform: `rotate(${flip ? 180 : 0}deg)` }}>
    {board.pieces.map((row, r) => (
      <div className="chess-row" key={r}>
        {row.map(([color, piece], c) => (
          <div
            className={
              `piece-square ${contains(highlights, [r, c]) ? 'highlight' : ''}`
            }
            onClick={() => onClick([r, c])}
          >
            <a
              key={c}
              style={{ transform: `rotate(${flip ? -180 : 0}deg)` }}
              className={`piece ${color} ${piece}`}
            />
          </div>
        ))}
      </div>
    ))}
  </div>
);

export default Board;
