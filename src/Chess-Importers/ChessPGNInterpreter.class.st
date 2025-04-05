Class {
	#name : 'ChessPGNInterpreter',
	#superclass : 'Object',
	#instVars : [
		'whiteToPlay',
		'game'
	],
	#category : 'Chess-Importers',
	#package : 'Chess-Importers'
}

{ #category : 'testing' }
ChessPGNInterpreter >> bishopCanReach: destination from: source [

	| srcCol srcRow dstCol dstRow colDelta rowDelta colStep rowStep |
	srcCol := 'abcdefgh' indexOf: source first.
	srcRow := source second digitValue.
	dstCol := 'abcdefgh' indexOf: destination first.
	dstRow := destination second digitValue.

	colDelta := dstCol - srcCol.
	rowDelta := dstRow - srcRow.
	colDelta abs = rowDelta abs ifFalse: [ ^ false ].

	colStep := colDelta sign.
	rowStep := rowDelta sign.

	^ (1 to: colDelta abs - 1) noneSatisfy: [ :i |
		  | c r |
		  c := srcCol + (i * colStep).
		  r := srcRow + (i * rowStep).
		  (game board at:
			   (String with: (c + 96) asCharacter with: r asCharacterDigit))
			  hasPiece ]
]

{ #category : 'utilities' }
ChessPGNInterpreter >> classForPiece: notation [

	notation = $K ifTrue: [ ^ MyKing ].
	notation = $Q ifTrue: [ ^ MyQueen ].
	notation = $R ifTrue: [ ^ MyRook ].
	notation = $B ifTrue: [ ^ MyBishop ].
	notation = $N ifTrue: [ ^ MyKnight ].
	self error: 'Invalid piece notation: ' , notation asString
]

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

{ #category : 'accessing' }
ChessPGNInterpreter >> game [

	^ game
]

{ #category : 'accessing' }
ChessPGNInterpreter >> game: aChessGame [

	game := aChessGame
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

{ #category : 'playing' }
ChessPGNInterpreter >> interpretPGN: pgnString [

	self interpretPGN: pgnString afterMoveDo: [  ]
]

{ #category : 'playing' }
ChessPGNInterpreter >> interpretPGN: pgnString afterMoveDo: aBlock [

	| parser |
	game ifNil: [ self reset ].
	parser := ChessPGNParser forString: pgnString.
	parser parseOnlyMovementsDo: [ :movement | "a movement contains two moves: white's and black's"
		whiteToPlay := true.
		aBlock cull: (self interpretMove: movement second).

		whiteToPlay := false.
		aBlock cull: (self interpretMove: movement third) ]
]

{ #category : 'testing' }
ChessPGNInterpreter >> isStraightPathClearFrom: source to: destination [
	"Return true if all squares strictly between origin and destination are empty."

	| srcColChar srcRowChar srcRow dstRow |
	srcColChar := source first.
	srcRowChar := source second.
	srcRow := srcRowChar digitValue.
	dstRow := destination second digitValue.

	srcRow = dstRow ifTrue: [
		| srcCol dstCol |
		srcCol := srcColChar asInteger - 96. "96 = $a asInteger - 1"
		dstCol := destination first asInteger - 96.
		^ ((srcCol min: dstCol) + 1 to: (srcCol max: dstCol) - 1)
			  noneSatisfy: [ :c |
				  (game board at:
					   (String with: (c + 96) asCharacter with: srcRowChar)) hasPiece ] ].

	^ ((srcRow min: dstRow) + 1 to: (srcRow max: dstRow) - 1)
		  noneSatisfy: [ :r |
			  (game board at:
				   (String with: srcColChar with: r asCharacterDigit)) hasPiece ]
]

{ #category : 'testing' }
ChessPGNInterpreter >> isWhiteSquare: square [

	| col row |
	col := 'abcdefgh' indexOf: square first.
	row := square second digitValue.
	^ (col + row) odd
]

{ #category : 'utilities' }
ChessPGNInterpreter >> move: piece to: squareName [
	"Bypass move legality check"

	| square |
	square := game board at: squareName.
	piece square emptyContents.
	piece square: square.
	square contents: piece
]

{ #category : 'moves' }
ChessPGNInterpreter >> moveBishop: move [
	"Simply look for the same color bishop.
	Ignores that there could be multiple bishops of the same color (pawn promotion)."

	| destination isWhite candidates |
	destination := self moveDestination: move.
	isWhite := self isWhiteSquare: destination.
	candidates := self selectPieces: [ :piece |
		              piece class = MyBishop and: [ "same square color"
			              isWhite = (self isWhiteSquare: piece square name) ] ].
	candidates size = 1 ifTrue: [
		^ self move: candidates first to: destination ].
	self notYetImplemented "TODO disambiguate, or find closest to destination if on the same diagonal"
]

{ #category : 'moves' }
ChessPGNInterpreter >> moveCastle [

	whiteToPlay
		ifTrue: [
			self move: (game board at: 'e1') contents to: 'g1'.
			self move: (game board at: 'h1') contents to: 'f1' ]
		ifFalse: [
			self move: (game board at: 'e8') contents to: 'g8'.
			self move: (game board at: 'h8') contents to: 'f8' ]
]

{ #category : 'moves' }
ChessPGNInterpreter >> moveCastleLong [

	whiteToPlay
		ifTrue: [
			self move: (game board at: 'e1') contents to: 'c1'.
			self move: (game board at: 'a1') contents to: 'd1' ]
		ifFalse: [
			self move: (game board at: 'e8') contents to: 'c8'.
			self move: (game board at: 'a8') contents to: 'd8' ]
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
			        piece class = MyKing and: [ "same color"
				        whiteToPlay = piece isWhite ] ] ].
	^ self move: king to: (self moveDestination: move)
]

{ #category : 'moves' }
ChessPGNInterpreter >> moveKnight: move [

	| destination validOrigins candidates disambiguation |
	destination := self moveDestination: move.
	validOrigins := self validKnightMovesFrom: destination.
	candidates := self selectPieces: [ :piece |
		              piece class = MyKnight and: [
			              validOrigins includes: piece square name ] ].

	candidates size = 1 ifTrue: [
		^ self move: candidates first to: destination ].
	candidates ifEmpty: [ self notYetImplemented ].
	candidates size > 2 ifTrue: [
		self notYetImplemented "possible w/ promotion" ].

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
		              piece class = MyPawn and: [ "same column"
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
	candidates := self selectPieces: [ :piece | piece class = MyQueen ].
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
		              piece class = MyRook and: [
			              self
				              rookCanReach: destination
				              from: piece square name ] ].

	candidates size = 1 ifTrue: [
		^ self move: candidates first to: destination ].
	self notYetImplemented "TODO: disambiguate if multiple candidates exist"
]

{ #category : 'utilities' }
ChessPGNInterpreter >> promotePawnAt: coords to: pieceNotation [

	| square piece |
	square := game board at: coords.
	piece := (self classForPiece: pieceNotation) new.
	piece color: square contents color.
	piece square: square.
	square contents: piece
]

{ #category : 'testing' }
ChessPGNInterpreter >> queenCanReach: destination from: origin [
	"Return true if a queen at origin can reach destination (rook or bishop path), and path is clear."

	^ (self rookCanReach: destination from: origin) or: [
		  self bishopCanReach: destination from: origin ]
]

{ #category : 'initialization' }
ChessPGNInterpreter >> reset [

	game := MyChessGame freshGame.
	game size: 400 @ 400
]

{ #category : 'testing' }
ChessPGNInterpreter >> rookCanReach: destination from: origin [
	"Return true if a rook at `origin` can legally reach `destination` by row or column, taking obstructions into account."

	^ (origin first = destination first or: [
		   origin second = destination second ]) and: [
		  self isStraightPathClearFrom: origin to: destination ]
]

{ #category : 'utilities' }
ChessPGNInterpreter >> selectPieces: aBlock [

	^ game pieces select: [ :piece |
		  piece isNotNil and: [ "of player color, check using XNOR: (T=T)|(F=F)"
			  whiteToPlay = piece isWhite and: [ aBlock value: piece ] ] ]
]

{ #category : 'utilities' }
ChessPGNInterpreter >> validKnightMovesFrom: move [

	| col row offsets newCol newRow |
	col := 'abcdefgh' indexOf: move first.
	row := move second digitValue.

	offsets := #( (  1  2 ) (  2  1 ) (  2 -1 ) (  1 -2 )
	              ( -1 -2 ) ( -2 -1 ) ( -2  1 ) ( -1  2 ) ).

	^ offsets
		  select: [ :offset |
			  newCol := col + offset first.
			  newRow := row + offset second.
			  (newCol between: 1 and: 8) and: [ newRow between: 1 and: 8 ] ]
		  thenCollect: [ :offest |
			  String with: ('abcdefgh' at: newCol) with: newRow asString first ]
]
