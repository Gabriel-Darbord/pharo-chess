Class {
	#name : 'ChessLongAlgebraicWriter',
	#superclass : 'ChessWriter',
	#category : 'Chess-Importers-Writer',
	#package : 'Chess-Importers',
	#tag : 'Writer'
}

{ #category : 'writing' }
ChessLongAlgebraicWriter >> move: piece to: square promotion: pieceNotation [

	| origin destination |
	origin := piece square name.
	destination := square name.
	moves add: (pieceNotation
			 ifNil: [ origin , destination ]
			 ifNotNil: [ origin , destination , pieceNotation asLowercase ])
]
