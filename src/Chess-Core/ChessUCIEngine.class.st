Class {
	#name : 'ChessUCIEngine',
	#superclass : 'ChessEngine',
	#instVars : [
		'uci'
	],
	#category : 'Chess-Core',
	#package : 'Chess-Core'
}

{ #category : 'initialization' }
ChessUCIEngine >> initialize [

	self newGame
]

{ #category : 'instance creation' }
ChessUCIEngine >> newGame [
	"Tell the engine a new game is starting and clear caches"

	uci awaitNewGame
]

{ #category : 'playing' }
ChessUCIEngine >> play [
	"Plays the best move found by the engine at a depth of 1"

	| move destination interpreter |
	self updatePosition.

	"Make a search and play the best move"
	move := uci goWith
		        depth: 2;
		        awaitGo.
	move := move first. "look at best move, ignore ponder"
	destination := move copyFrom: 3 to: 4.

	(interpreter := ChessLongAlgebraicInterpreter on: game)
		interpretMove: move.

	"Update game state"
	"game
		recordMovementOf: (game board at: destination) contents
		to: (game board at: destination)."
	move size = 5 ifFalse: [ ^ self ].
	game moves
		at: game moves size
		put: game moves last , '=' , move fifth asString
]

{ #category : 'accessing' }
ChessUCIEngine >> uci [
	"Direct access to the UCI wrapper, not recommended."

	^ uci
]

{ #category : 'accessing' }
ChessUCIEngine >> uci: aChessUCI [

	uci := aChessUCI
]

{ #category : 'as yet unclassified' }
ChessUCIEngine >> updatePosition [
	"Set the engine internal position to the game's position"

	uci positionFEN: game startFEN moves: game moveWriter moves "(Array streamContents: [ :s |
			 ChessPGN2LongAlgebraicTranslator new
				 interpret: game pgnString
				 afterMoveDo: [ :m | s nextPut: m ] ])"
]
