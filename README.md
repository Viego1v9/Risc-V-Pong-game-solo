# Risc-V-Pong-game-solo
# RISC-V Pong

A single-player Pong game written in RISC-V assembly for the [RARS](https://github.com/TheThirdOne/rars) simulator. You control the left paddle against a computer opponent on the right.

## Features

- 3-2-1 countdown before the match starts
- Keyboard input (`a` and `d`) to move your paddle
- Computer opponent that tracks the ball once it gets closer to its side
- Bounce direction changes depending on whether the ball hits the top, middle, or bottom of a paddle
- Game speeds up slightly after every paddle hit
- Sudden death: first miss ends the match and prints `W` (win) or `L` (loss) to the RARS console

## How to Run in RARS

1. Open the `.asm` file in **RARS**.
2. Open **Tools - Bitmap Display** and set the following values:
   - **Unit Width in Pixels:** `8`
   - **Unit Height in Pixels:** `8`
   - **Display Width in Pixels:** `512`
   - **Display Height in Pixels:** `256`
   - **Base address for display:** `0x10010000 (static data)`
   - Click **Connect to Program**.
3. Open **Tools - Keyboard and Display MMIO Simulator** and click **Connect to Program**.
4. Assemble the code (**Run - Assemble**) and click **Run**.
5. Click inside the bottom text box of the Keyboard Simulator window so it captures your key presses.

## Controls

| Key | Action |
| :--- | :--- |
| `a` | Move paddle up |
| `d` | Move paddle down |

*(Make sure Caps Lock is off.)*

## How It Works

The display is treated as a 64x32 pixel grid mapped directly to memory starting at `0x10010000`.

Each frame follows four steps:
1. **Erase** the old ball and paddle positions by drawing over them in black (this avoids flickering from clearing the entire screen).
2. **Update** the player paddle from keyboard input, move the AI paddle, move the ball, and check for wall/paddle hits or misses.
3. **Draw** the paddles and ball in their new positions.
4. **Wait** before starting the next frame. The delay starts at 60ms and drops by 5ms on every paddle hit (down to 15ms) so the game speeds up smoothly.

### Main Registers Used

| Register | Purpose |
| :--- | :--- |
| `s0` | Player 1 paddle Y position |
| `s1` | Player 2 (AI) paddle Y position |
| `s2`, `s3` | Ball X and Y position |
| `s4`, `s5` | Ball X and Y direction (`-1`, `0`, or `1`) |
| `s6` | Frame delay in milliseconds |
