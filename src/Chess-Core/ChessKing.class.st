Class {
	#name : 'ChessKing',
	#superclass : 'ChessPiece',
	#category : 'Chess-Core',
	#package : 'Chess-Core'
}

{ #category : 'as yet unclassified' }
ChessKing >> attackingSquares [

	^ self basicTargetSquares
]

{ #category : 'rendering' }
ChessKing >> basicTargetSquares [
	"The king can move one square on each direction including diagonals"

	^ {
		  square right.
		  (square up ifNotNil: #right).
		  square up.
		  (square up ifNotNil: #left).
		  square left.
		  (square left ifNotNil: #down).
		  square down.
		  (square down ifNotNil: #right) }
]

{ #category : 'accessing' }
ChessKing >> id [
	
	^ 'K'
]

{ #category : 'testing' }
ChessKing >> isCheckMated [
	"We check if the opponent pieces target all my potential movements and myself"

	| threatenedSquares |
	threatenedSquares := self opponentPieces flatCollect: [ :e |
		                     e attackingSquares ].

	^ self legalTargetSquares isEmpty and: [
		  threatenedSquares includes: self square ]
]

{ #category : 'testing' }
ChessKing >> isInCheck [
	"We check if the opponent pieces target all my potential movements and myself"

	| threatenedSquares |
	threatenedSquares := self opponentPieces flatCollect: [ :e |
		                     e attackingSquares ].

	^ threatenedSquares includes: self square
]

{ #category : 'testing' }
ChessKing >> isKing [
	
	^ true
]

{ #category : 'accessing' }
ChessKing >> opponentPieces [

	^ self board pieces select: [ :e |
		  e notNil and: [ e color = color negated ] ]
]

{ #category : 'rendering' }
ChessKing >> renderPieceOn: aSquare [

	^ aSquare renderKing: self
]

{ #category : 'rendering' }
ChessKing >> targetSquaresLegal: aBoolean [
	"The king cannot move to threatened squares"

	| threatenedSquares |
	threatenedSquares := self opponentPieces flatCollect: [ :e |
		                     e attackingSquares ].

	^ self basicTargetSquares select: [ :s |
		  s notNil and: [
			  (threatenedSquares includes: s) not and: [
				  s hasPiece not or: [ 
					"The square has an opponent piece"
					s contents color ~= color and: [ 
						"Let's hope the piece is not defended"
						threatenedSquares includes: s  ] ] ] ] ]
]
