import React from 'react';

const contains = (highlights, [r, c]) =>
  highlights.filter(([a, b]) => r == a && c == b).length;

const Board = ({ board, highlights = [], onClick = () => {} }) => (
  <div className="board">
    {board.pieces.map((row, r) => (
      <div className="row">
        {row.map(([color, piece], c) => (
          <a
            onClick={() => onClick([r, c])}
            className={
              `piece ${color} ${piece} ${contains(highlights, [
                r,
                c
              ]) ? 'highlight' : '0'}`
            }
          />
        ))}
      </div>
    ))}
  </div>
);

export default Board;
