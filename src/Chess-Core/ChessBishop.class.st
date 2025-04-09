Class {
	#name : 'ChessBishop',
	#superclass : 'ChessPiece',
	#category : 'Chess-Core',
	#package : 'Chess-Core'
}

{ #category : 'accessing' }
ChessBishop >> id [
	
	^ 'B'
]

{ #category : 'testing' }
ChessBishop >> isBishop [

	^ true
]

{ #category : 'rendering' }
ChessBishop >> renderPieceOn: aSquare [

	^ aSquare renderBishop: self
]

{ #category : 'rendering' }
ChessBishop >> targetSquaresLegal: aBoolean [

	^ (self upRightDiagonalLegal: aBoolean)
	  , (self upLeftDiagonalLegal: aBoolean)
	  , (self downRightDiagonalLegal: aBoolean)
	  , (self downLeftDiagonalLegal: aBoolean)
]
