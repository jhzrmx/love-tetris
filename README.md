# Love Tetris

A clean, colorful Tetris game built with [LOVE / Love2D](https://love2d.org/) and Lua.

This project is intentionally small and approachable: one `main.lua` file, classic falling-block gameplay, and enough structure for beginners to read, tweak, and contribute without fighting a big codebase.

## Preview

Love Tetris includes:

- Classic 10 x 20 Tetris board
- Seven tetromino pieces: I, O, T, S, Z, J, and L
- Randomized 7-bag piece generation
- Next-piece preview
- Soft drop and hard drop
- Score, line, and level tracking
- Increasing speed as levels rise
- Game over screen with quick restart

## Requirements

- [LOVE / Love2D 11.x](https://love2d.org/) or newer
- Git, if you want to clone and contribute

## Getting Started

Clone the repository:

```bash
git clone https://github.com/jhzrmx/love-tetris.git
cd love-tetris
```

Run the game with Love2D:

```bash
love .
```

On Windows, you can also drag the project folder onto `love.exe`.

## Controls

| Key | Action |
| --- | --- |
| Left Arrow | Move piece left |
| Right Arrow | Move piece right |
| Up Arrow | Rotate piece |
| Down Arrow | Soft drop |
| Space | Hard drop |
| R | Restart after game over |

## Scoring

The game uses level-based line clear scoring:

| Lines Cleared | Points |
| --- | --- |
| 1 | 100 x level |
| 2 | 300 x level |
| 3 | 500 x level |
| 4 | 800 x level |

Soft drops add `1` point per row. Hard drops add `2` points per row.

## Project Structure

```text
love-tetris/
|-- main.lua
`-- README.md
```

Everything currently lives in `main.lua`, which makes the project easy to inspect. As the game grows, good future modules could include:

- `board.lua` for board state and line clearing
- `pieces.lua` for tetromino data and rotation
- `ui.lua` for drawing the side panel and overlays
- `config.lua` for colors, scoring, and timing

## Ideas for Contributors

Here are some friendly ways to improve the game:

- Add ghost piece preview
- Add hold piece support
- Add sound effects and background music
- Add pause and resume
- Add start menu and settings screen
- Add high score saving
- Improve wall kicks during rotation
- Add animations for line clears
- Add mobile or gamepad controls
- Split the code into small Lua modules

## Contributing

Contributions are welcome.

To contribute:

1. Fork the repository.
2. Create a new branch:

   ```bash
   git checkout -b feature/your-feature-name
   ```

3. Make your changes.
4. Test the game with:

   ```bash
   love .
   ```

5. Commit your work:

   ```bash
   git commit -m "Add your feature"
   ```

6. Open a pull request.

Please keep changes focused and easy to review. If you are planning a larger change, opening an issue first is a great way to discuss the direction.

## Development Notes

- Keep gameplay behavior simple and predictable.
- Prefer readable Lua over clever Lua.
- Avoid adding large dependencies unless they clearly improve the project.
- Test controls and game-over restart before opening a pull request.

## License

No license has been added yet. If you plan to accept contributions publicly, consider adding an open-source license such as MIT.
