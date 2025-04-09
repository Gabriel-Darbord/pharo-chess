Class {
	#name : 'ChessKnight',
	#superclass : 'ChessPiece',
	#category : 'Chess-Core',
	#package : 'Chess-Core'
}

{ #category : 'accessing' }
ChessKnight >> id [
	
	^ 'N'
]

{ #category : 'testing' }
ChessKnight >> isKnight [

	^ true
]

{ #category : 'rendering' }
ChessKnight >> renderPieceOn: aSquare [

	^ aSquare renderKnight: self
]

{ #category : 'rendering' }
ChessKnight >> targetSquaresLegal: aBoolean [

	^ {
		  (square right ifNotNil: [ :p | p right ifNotNil: #up ]).
		  (square right ifNotNil: [ :p | p right ifNotNil: #down ]).
		  (square left ifNotNil: [ :p | p left ifNotNil: #up ]).
		  (square left ifNotNil: [ :p | p left ifNotNil: #down ]).
		  (square up ifNotNil: [ :p | p up ifNotNil: #left ]).
		  (square up ifNotNil: [ :p | p up ifNotNil: #right ]).
		  (square down ifNotNil: [ :p | p down ifNotNil: #left ]).
		  (square down ifNotNil: [ :p | p down ifNotNil: #right ]) }
		  select: [ :s |
			  s notNil and: [ s hasPiece not or: [ s contents color ~= color ] ] ]
]
