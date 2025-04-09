Class {
	#name : 'ChessGame',
	#superclass : 'MyChessGame',
	#instVars : [
		'startFEN',
		'engine',
		'moveWriter'
	],
	#category : 'Chess-Core',
	#package : 'Chess-Core'
}

{ #category : 'instance creation' }
ChessGame class >> fromFENString: aFENString [

	^ (super fromFENString: aFENString)
		  startFEN: aFENString;
		  yourself
]

{ #category : 'accessing' }
ChessGame >> board [

	^ board
]

{ #category : 'accessing' }
ChessGame >> currentPlayer [

	^ currentPlayer
]

{ #category : 'accessing' }
ChessGame >> engine [

	^ engine
]

{ #category : 'accessing' }
ChessGame >> engine: aChessEngine [

	engine := aChessEngine.
	aChessEngine game: self
]

{ #category : 'initialization' }
ChessGame >> initialize [

	super initialize.
	whitePlayer := ChessPlayer new white game: self.
	blackPlayer := ChessPlayer new black game: self.
	moveWriter := ChessLongAlgebraicWriter new
]

{ #category : 'initialization' }
ChessGame >> initializeFromFENGame: aFENGame [

	| button infoPane |
	aFENGame sideToMove = 'White'
		ifTrue: [ currentPlayer := whitePlayer ]
		ifFalse: [ currentPlayer := blackPlayer ].

	moveCount := aFENGame moveCount.

	board := ChessBoard fromFENBoard: aFENGame board.
	board game: self.
	button := ToButton new.
	button labelText: 'Play!'.
	button whenClickedDo: [ self play ].

	infoPane := ToElement new.
	infoPane constraintsDo: [ :c |
		c vertical fitContent.
		c horizontal matchParent ].
	infoPane layout: BlLinearLayout vertical.
	infoPane layout cellSpacing: 10.
	infoPane margin: (BlInsets all: 20).
	infoPane matchParent.

	movesLabel := ToLabel new beMultiLine.
	movesLabel matchParent.

	self addChild: board.
	self addChild: infoPane.
	infoPane addChild: movesLabel.
	infoPane addChild: button.

	self layout: BlLinearLayout horizontal.
	self constraintsDo: [ :aLayoutConstraints |
		aLayoutConstraints horizontal fitContent.
		aLayoutConstraints vertical fitContent ]
]

{ #category : 'public' }
ChessGame >> move: piece to: square [

	self recordMovementOf: piece to: square.
	piece moveTo: square.

	currentPlayer = whitePlayer
		ifTrue: [ currentPlayer := blackPlayer ]
		ifFalse: [
			moveCount := moveCount + 1.
			currentPlayer := whitePlayer ]
]

{ #category : 'accessing' }
ChessGame >> moveWriter [

	^ moveWriter
]

{ #category : 'accessing' }
ChessGame >> moveWriter: aChessWriter [

	moveWriter := aChessWriter
]

{ #category : 'accessing' }
ChessGame >> moves [

	^ moves
]

{ #category : 'exporting' }
ChessGame >> pgnString [

	^ String streamContents: [ :s |
		  moves do: [ :move | s << move ] separatedBy: [ s space ] ]
]

{ #category : 'playing' }
ChessGame >> play [

	engine ifNotNil: [ engine play ] ifNil: [ currentPlayer play ].
	self checkForMate
]

{ #category : 'moves' }
ChessGame >> recordMovementOf: aPiece to: aSquare [
	"| movesText |
	moves add: (String streamContents: [ :s |
			 currentPlayer isWhite ifTrue: [
				 s print: moveCount.
				 s nextPut: $. ].
			 s space.
			 aPiece isPawn ifFalse: [ s << aPiece id ].
			 s << aSquare name ]).

	movesText := String streamContents: [ :stream |
		             | currentLine |
		             currentLine := ''.
		             moves do: [ :m |
			             currentLine := currentLine , ' ' , m.
			             currentLine size > 20 ifTrue: [
				             stream nextPutAll: currentLine.
				             stream cr.
				             currentLine := '' ] ].
		             stream nextPutAll: currentLine ].

	movesLabel text: movesText"

	moveWriter move: aPiece to: aSquare promotion: nil.
	movesLabel text: moveWriter movesString
]

{ #category : 'accessing' }
ChessGame >> startFEN [

	^ startFEN
]

{ #category : 'accessing' }
ChessGame >> startFEN: aFENString [

	startFEN := aFENString
]
