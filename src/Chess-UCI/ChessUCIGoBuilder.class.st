"
Convenience for mixing and matching arguments of the `go` command.
The search ends when it hits any one of those limits.

Configure the search with `building` methods and execute it with the `go` method.
It returns a string indicating the best move it found in long algebraic notation.

### Resources
[UCI go command](https://backscattering.de/chess/uci/#gui-go)
"
Class {
	#name : 'ChessUCIGoBuilder',
	#superclass : 'Object',
	#instVars : [
		'uci'
	],
	#category : 'Chess-UCI',
	#package : 'Chess-UCI'
}

{ #category : 'instance creation' }
ChessUCIGoBuilder class >> on: aUCI [

	^ self new uci: aUCI
]

{ #category : 'executing' }
ChessUCIGoBuilder >> awaitGo [
	"Send the go command built so far to the engine and await the best move."

	^ uci flush awaitBestMove
]

{ #category : 'UCI' }
ChessUCIGoBuilder >> blackIncrement: x [
	"Black increment per move in ms if > 0"

	uci nextPutAll: ' binc '.
	uci nextPutAll: x asString
]

{ #category : 'UCI' }
ChessUCIGoBuilder >> blackTime: x [
	"Black has x ms left on the clock"

	uci nextPutAll: ' btime '.
	uci nextPutAll: x asString
]

{ #category : 'UCI' }
ChessUCIGoBuilder >> depth: x [
	"Search x plies only"

	uci nextPutAll: ' depth '.
	uci nextPutAll: x asString
]

{ #category : 'executing' }
ChessUCIGoBuilder >> go [
	"Send the go command built so far to the engine.
	Either send the stop command or await the best move with #readBestMove."

	uci flush
]

{ #category : 'UCI' }
ChessUCIGoBuilder >> mate: x [
	"Search for a mate in x moves"

	uci nextPutAll: ' mate '.
	uci nextPutAll: x asString
]

{ #category : 'UCI' }
ChessUCIGoBuilder >> moveTime: x [
	"Search exactly x mseconds"

	uci nextPutAll: ' movetime '.
	uci nextPutAll: x asString
]

{ #category : 'UCI' }
ChessUCIGoBuilder >> movesToGo: x [
	"There are x (>0) moves to the next time control"

	uci nextPutAll: ' movestogo '.
	uci nextPutAll: x asString
]

{ #category : 'UCI' }
ChessUCIGoBuilder >> nodes: x [
	"Search x nodes only"

	uci nextPutAll: ' nodes '.
	uci nextPutAll: x asString
]

{ #category : 'UCI' }
ChessUCIGoBuilder >> searchMoves: moves [
	"Restrict search to these moves only.
	Moves are given as an array of strings in long algebraic notation."

	uci nextPutAll: ' searchmoves'.
	moves do: [ :move |
		uci nextPutAll: ' '.
		uci nextPutAll: move ]
]

{ #category : 'private - accessing' }
ChessUCIGoBuilder >> uci: aUniversalChessInterface [

	uci := aUniversalChessInterface
]

{ #category : 'UCI' }
ChessUCIGoBuilder >> whiteIncrement: x [
	"White increment per move in ms if > 0"

	uci nextPutAll: ' winc '.
	uci nextPutAll: x asString
]

{ #category : 'UCI' }
ChessUCIGoBuilder >> whiteTime: x [
	"White has x ms left on the clock"

	uci nextPutAll: ' wtime '.
	uci nextPutAll: x asString
]
