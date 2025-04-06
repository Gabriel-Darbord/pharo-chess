Class {
	#name : 'ChessPGNInterpreter',
	#superclass : 'ChessInterpreter',
	#category : 'Chess-Importers',
	#package : 'Chess-Importers'
}

{ #category : 'utilities' }
ChessPGNInterpreter >> disambiguate: candidatePieces with: disambiguation [

	| candidates clue |
	candidates := candidatePieces.
	disambiguation size = 2 ifTrue: [ "source square is explicit"
		^ candidates detect: [ :piece | piece square name = disambiguation ] ].

	clue := disambiguation first.
	candidates := clue isDigit
		              ifTrue: [ "row"
			              candidates select: [ :piece |
				              piece square name second = clue ] ]
		              ifFalse: [ "column"
			              candidates select: [ :piece |
				              piece square name first = clue ] ].
	candidates size = 1 ifTrue: [ ^ candidates first ].
	self error: 'Ambiguous piece move'
]

{ #category : 'playing' }
ChessPGNInterpreter >> interpret: pgnString afterMoveDo: aBlock [

	| parser |
	pgnString ifEmpty: [ ^ self ].
	game ifNil: [ self reset ].
	parser := ChessPGNParser forString: pgnString.
	parser parseOnlyMovementsDo: [ :movement | "a movement contains two moves: white's and black's"
		movement size > 1 ifTrue: [
			whiteToPlay := true.
			aBlock cull: (self interpretMove: movement second).

			movement size > 2 ifTrue: [
				whiteToPlay := false.
				aBlock cull: (self interpretMove: movement third) ] ] ]
]

{ #category : 'playing' }
ChessPGNInterpreter >> interpretMove: move [

	| first |
	move = 'O-O' ifTrue: [ ^ self moveCastle ].
	move = 'O-O-O' ifTrue: [ ^ self moveCastleLong ].
	first := move first.
	first isUppercase ifFalse: [ ^ self movePawn: move ].
	first = $K ifTrue: [ ^ self moveKing: move ].
	first = $Q ifTrue: [ ^ self moveQueen: move ].
	first = $R ifTrue: [ ^ self moveRook: move ].
	first = $B ifTrue: [ ^ self moveBishop: move ].
	first = $N ifTrue: [ ^ self moveKnight: move ].
	self error: 'Invalid move notation: ' , move
]

{ #category : 'moves' }
ChessPGNInterpreter >> moveBishop: move [
	"Simply look for the same color bishop.
	Ignores that there could be multiple bishops of the same color (pawn promotion)."

	| destination isWhite candidates |
	destination := self moveDestination: move.
	isWhite := self isWhiteSquare: destination.
	candidates := self selectPieces: [ :piece |
		              piece isBishop and: [ "same square color"
			              isWhite = (self isWhiteSquare: piece square name) ] ].
	candidates size = 1 ifTrue: [
		^ self move: candidates first to: destination ].
	self notYetImplemented "TODO disambiguate, or find closest to destination if on the same diagonal"
]

{ #category : 'utilities' }
ChessPGNInterpreter >> moveDestination: move [
	"Does not apply to pawns."

	^ ('+#' includes: move last)
		  ifTrue: [ move copyFrom: move size - 2 to: move size - 1 ]
		  ifFalse: [ move last: 2 ]
]

{ #category : 'utilities' }
ChessPGNInterpreter >> moveDisambiguation: move [

	| dstIndex |
	dstIndex := move
		            indexOfSubCollection: (self moveDestination: move)
		            startingAt: 2.
	^ dstIndex = 2
		  ifTrue: [ nil ]
		  ifFalse: [ move copyFrom: 2 to: dstIndex - 1 ]
]

{ #category : 'moves' }
ChessPGNInterpreter >> moveKing: move [

	| king |
	king := game pieces detect: [ :piece |
		        piece isNotNil and: [
			        piece isKing and: [ "same color"
				        whiteToPlay = piece isWhite ] ] ].
	^ self move: king to: (self moveDestination: move)
]

{ #category : 'moves' }
ChessPGNInterpreter >> moveKnight: move [

	| destination validOrigins candidates disambiguation |
	destination := self moveDestination: move.
	validOrigins := self validKnightMovesFrom: destination.
	candidates := self selectPieces: [ :piece |
		              piece isKnight and: [
			              validOrigins includes: piece square name ] ].

	candidates size = 1 ifTrue: [
		^ self move: candidates first to: destination ].
	candidates ifEmpty: [ self notYetImplemented ].

	move size > 3 ifFalse: [ self error: 'Ambiguous PGN' ].

	disambiguation := move second.
	candidates := ('abcdefgh' includes: disambiguation)
		              ifTrue: [ "search column"
			              candidates select: [ :piece |
				              piece square name first = disambiguation ] ]
		              ifFalse: [ "search row"
			              candidates select: [ :piece |
				              piece square name second = disambiguation ] ].

	candidates size = 1 ifTrue: [
		^ self move: candidates first to: destination ].
	self notYetImplemented
]

{ #category : 'moves' }
ChessPGNInterpreter >> movePawn: move [

	| xIndex eIndex moveNoSuffix |
	xIndex := move indexOf: $x. "pawn takes?"
	eIndex := move indexOf: $=. "promotion?"

	moveNoSuffix := eIndex = 0
		                ifTrue: [ "check?"
			                ('+#' includes: move last)
				                ifTrue: [ move allButLast ]
				                ifFalse: [ move ] ]
		                ifFalse: [ move copyFrom: 1 to: eIndex - 1 ].

	xIndex = 0
		ifTrue: [ self movePawnForward: moveNoSuffix ]
		ifFalse: [ self movePawnTakes: moveNoSuffix ].

	eIndex = 0 ifFalse: [
		self promotePawnAt: (moveNoSuffix last: 2) to: (move at: eIndex + 1) ]
]

{ #category : 'moves' }
ChessPGNInterpreter >> movePawnForward: move [

	| candidates |
	candidates := self selectPieces: [ :piece |
		              piece isPawn and: [ "same column"
			              piece square name first = move first ] ].
	candidates size = 1 ifTrue: [
		^ self move: candidates first to: (self moveDestination: move) ].
	self notYetImplemented "TODO find closest to destination"
]

{ #category : 'moves' }
ChessPGNInterpreter >> movePawnTakes: move [

	| col row origin |
	self assert: (move size between: 4 and: 5).
	move size = 5 ifTrue: [ "fully disambiguated"
		^ self
			  move: (game board at: (move first: 2)) contents
			  to: (move last: 2) ].

	col := move first.
	row := Character value: move last asInteger + (whiteToPlay
			        ifTrue: [ -1 ]
			        ifFalse: [ 1 ]).
	origin := String with: col with: row.

	^ self move: (game board at: origin) contents to: (move last: 2)
]

{ #category : 'moves' }
ChessPGNInterpreter >> moveQueen: move [

	| destination candidates |
	destination := self moveDestination: move.
	candidates := self selectPieces: [ :piece | piece isQueen ].
	candidates size = 1 ifTrue: [
		^ self move: candidates first to: destination ].

	(self moveDisambiguation: move) ifNotNil: [ :disambiguation |
		^ self
			  move: (self disambiguate: candidates with: disambiguation)
			  to: destination ].

	candidates := candidates select: [ :piece |
		              self
			              queenCanReach: destination
			              from: piece square name ].
	candidates size = 1 ifTrue: [
		^ self move: candidates first to: destination ].
	self error: 'Ambiguous queen move(?)'
]

{ #category : 'moves' }
ChessPGNInterpreter >> moveRook: move [

	| destination candidates |
	destination := self moveDestination: move.
	candidates := self selectPieces: [ :piece |
		              piece isRook and: [
			              self
				              rookCanReach: destination
				              from: piece square name ] ].

	candidates size = 1 ifTrue: [
		^ self move: candidates first to: destination ].
	self notYetImplemented "TODO: disambiguate if multiple candidates exist"
]
