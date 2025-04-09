Class {
	#name : 'ChessInterpreter',
	#superclass : 'Object',
	#instVars : [
		'game',
		'whiteToPlay'
	],
	#category : 'Chess-Notations-Interpreters',
	#package : 'Chess-Notations',
	#tag : 'Interpreters'
}

{ #category : 'testing' }
ChessInterpreter class >> isAbstract [

	^ self == ChessInterpreter
]

{ #category : 'instance creation' }
ChessInterpreter class >> on: aChessGame [

	^ self new
		  game: aChessGame;
		  whiteToPlay: aChessGame currentPlayer isWhite
]

{ #category : 'testing' }
ChessInterpreter >> bishopCanReach: destination from: source [

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
ChessInterpreter >> classForPiece: notation [

	notation = $K ifTrue: [ ^ ChessKing ].
	notation = $Q ifTrue: [ ^ ChessQueen ].
	notation = $R ifTrue: [ ^ ChessRook ].
	notation = $B ifTrue: [ ^ ChessBishop ].
	notation = $N ifTrue: [ ^ ChessKnight ].
	self error: 'Invalid piece notation: ' , notation asString
]

{ #category : 'accessing' }
ChessInterpreter >> game [

	^ game
]

{ #category : 'accessing' }
ChessInterpreter >> game: aChessGame [

	game := aChessGame
]

{ #category : 'playing' }
ChessInterpreter >> interpret: aString [

	self interpret: aString afterMoveDo: [  ]
]

{ #category : 'playing' }
ChessInterpreter >> interpret: aString afterMoveDo: aBlock [

	self subclassResponsibility
]

{ #category : 'playing' }
ChessInterpreter >> interpretMove: move [

	self subclassResponsibility
]

{ #category : 'testing' }
ChessInterpreter >> isStraightPathClearFrom: source to: destination [
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
ChessInterpreter >> isWhiteSquare: square [

	| col row |
	col := 'abcdefgh' indexOf: square first.
	row := square second digitValue.
	^ (col + row) odd
]

{ #category : 'utilities' }
ChessInterpreter >> move: piece to: squareName [

	game move: piece to: (game board at: squareName)
]

{ #category : 'moves' }
ChessInterpreter >> moveCastle [

	game currentPlayer canCastle: false.
	whiteToPlay
		ifTrue: [
			self move: (game board at: 'e1') contents to: 'g1'.
			(game board at: 'h1') contents moveTo: (game board at: 'f1') ]
		ifFalse: [
			self move: (game board at: 'e8') contents to: 'g8'.
			(game board at: 'h8') contents moveTo: (game board at: 'f8') ]
]

{ #category : 'moves' }
ChessInterpreter >> moveCastleLong [

	game currentPlayer canCastle: false.
	whiteToPlay
		ifTrue: [
			self move: (game board at: 'e1') contents to: 'c1'.
			(game board at: 'a1') contents moveTo: (game board at: 'd1') ]
		ifFalse: [
			self move: (game board at: 'e8') contents to: 'c8'.
			(game board at: 'a8') contents moveTo: (game board at: 'd8') ]
]

{ #category : 'utilities' }
ChessInterpreter >> promotePawnAt: coords to: pieceNotation [

	| square piece |
	square := game board at: coords.
	piece := (self classForPiece: pieceNotation) new.
	piece color: square contents color.
	piece square: square.
	square contents: piece
]

{ #category : 'testing' }
ChessInterpreter >> queenCanReach: destination from: origin [
	"Return true if a queen at origin can reach destination (rook or bishop path), and path is clear."

	^ (self rookCanReach: destination from: origin) or: [
		  self bishopCanReach: destination from: origin ]
]

{ #category : 'initialization' }
ChessInterpreter >> reset [

	game := ChessGame freshGame.
	game size: 400 @ 400
]

{ #category : 'testing' }
ChessInterpreter >> rookCanReach: destination from: origin [
	"Return true if a rook at `origin` can legally reach `destination` by row or column, taking obstructions into account."

	^ (origin first = destination first or: [
		   origin second = destination second ]) and: [
		  self isStraightPathClearFrom: origin to: destination ]
]

{ #category : 'utilities' }
ChessInterpreter >> selectPieces: aBlock [

	^ game pieces select: [ :piece |
		  piece isNotNil and: [ "of player color, check using XNOR: (T=T)|(F=F)"
			  whiteToPlay = piece isWhite and: [ aBlock value: piece ] ] ]
]

{ #category : 'utilities' }
ChessInterpreter >> validKnightMovesFrom: move [

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

{ #category : 'accessing' }
ChessInterpreter >> whiteToPlay: aBoolean [

	whiteToPlay := aBoolean
]
