"
I wrap a process running the Stockfish engine and communicate with it using UCI.
Stockfish offers additional non-standard UCI commands.

### Resources
[Stockfish UCI & Commands](https://official-stockfish.github.io/docs/stockfish-wiki/UCI-&-Commands.html)
"
Class {
	#name : 'Stockfish',
	#superclass : 'ChessUCI',
	#category : 'Chess-Stockfish',
	#package : 'Chess-Stockfish'
}

{ #category : 'instance creation' }
Stockfish class >> new [

	^ self executable: 'stockfish' withArguments: #(  )
]

{ #category : 'UCI - sync' }
Stockfish >> display [
	"Print the current position, with ASCII art and FEN."

	self write: 'd'.
	^ self readUntil: [ :line | line beginsWith: 'Checkers:' ]
]

{ #category : 'UCI - sync' }
Stockfish >> evaluation [
	"Display the static evaluation of the current position."

	self write: 'eval'.
	^ self readUntil: [ :line | line beginsWith: 'Final' ]
]

{ #category : 'UCI' }
Stockfish >> flip [
	"Flip the side to move"

	self write: 'flip'
]

{ #category : 'UCI' }
Stockfish >> go [
	"Stockfish defaults to executing `go depth 245`"

	self write: 'go'
]
