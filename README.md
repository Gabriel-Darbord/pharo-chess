# Pharo Chess
Features:
- GUI
- Universal Chess Interface implementation with [OSSubprocess](https://github.com/pharo-contributions/OSSubprocess)
- Stockfish engine using UCI
- Making GIFs of games in PGN notation

## Installation

```st
Metacello new
  repository: 'github://Gabriel-Darbord/pharo-chess:main/src';
  baseline: 'Chess';
  onConflictUseLoaded;
  load
```
