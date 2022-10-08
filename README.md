
# goal

Lights Off puzzle game implemented in bash.

Win the game by turning off all the lights. When toggling the state of a tile the neighbouring tiles (above, below, left and right) will also change state.

The starting level indicates the number of random tile toggles that are performed when creating a new board.

# command line options

```
lightsoff [-h] [-c columns] [-r rows] [-l levels] [-s seed]

  -h,--help    display this help text

  -c,--colors  integer representing the number of columns
  -r,--rows    integer representing the number of rows
  -l,--level   integer representing the level
  -s,--seed    integer seed for the pseudo-random number generator
```

# key mappings

 | Key             | Action                     |
 |:---------------:|:--------------------------:|
 | h,left          | move cursor left           |
 | l,right         | move cursor right          |
 | j,down          | move cursor down           |
 | k,up            | move cursor up             |
 | H               | move cursor to left edge   |
 | L               | move cursor to right edge  |
 | J               | move cursor to bottom edge |
 | K               | move cursor to top edge    |
 | enter,space,tab | toggle light               |
 | r               | replay game                |
 | n               | new game                   |
 | q               | quit game                  |
 | x               | change nr of columns       |
 | y               | change nr of rows          |
 | s               | change seed                |
 | v               | change level               |
 | z               | show move                  |
 | w               | redraw screen              |
 | i               | display goal               |
 | ?               | display key bindings       |

