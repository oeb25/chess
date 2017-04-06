import React from 'react';
import Board from './Board';
import socket from './socket';

const contains = (squares, [r, c]) =>
  squares.filter(([a, b]) => r == a && c == b).length;

export default class Game extends React.Component {
  constructor() {
    super();
    this.state = {
      game: null,
      moves: [],
      flip: false,
      selected: window.location.hash &&
        window.location.hash.substr(1).split(',').map(a => parseInt(a, 10))
    };

    this.channel = socket.channel('game:1', {});
    this.channel
      .join()
      .receive('ok', game => {
        this.setState({ game });
        console.log('Joined successfully', game);
      })
      .receive('error', resp => {
        console.log('Unable to join', resp);
      });
  }

  componentDidMount() {
    this.state.selected && this.movesFor(this.state.selected);

    this.channel.on('gamestate', game => {
      this.setState({ game });
    });
  }

  movesFor([r, c]) {
    this.setState({
      selected: [r, c]
    });

    window.location.hash = [r, c].join(',');

    this.channel
      .push('get_moves_for', { for: [r, c] })
      .receive('ok', ({ moves }) => this.setState({ moves }));
  }

  move([r, c]) {
    const a = this.state.selected;
    const b = [r, c];

    console.log(a, b);

    this.setState({ selected: null, moves: [] });
    window.history.replaceState('', document.title, window.location.pathname);

    this.channel
      .push('move', { from: a, to: b })
      .receive('ok', msg => console.log('Move response:', msg));
  }

  render() {
    const { game, moves, selected, flip } = this.state;

    const click = ([r, c]) => {
      const [color, piece] = game.board.pieces[r][c];

      if (contains(moves, [r, c])) {
        this.move([r, c]);
      } else {
        this.movesFor([r, c]);
      }
    };

    return game
      ? <div>
          <label>
            Vend brædtet
            <input
              type="checkbox"
              onChange={e => this.setState({ flip: !!e.target.checked })}
            />
          </label>
          <p>
            Det er {game.who == 'white' ? 'hvids' : 'sorts'} tur
          </p>
          <Board
            board={game.board}
            highlights={moves}
            onClick={click}
            flip={flip}
          />
          <pre>{JSON.stringify(game.actions, 0, 2)}</pre>
        </div>
      : <h1>Loading game...</h1>;
  }
}
