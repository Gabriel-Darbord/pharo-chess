Class {
	#name : 'ChessQueen',
	#superclass : 'ChessPiece',
	#category : 'Chess-Core',
	#package : 'Chess-Core'
}

{ #category : 'testing' }
ChessQueen >> isQueen [

	^ true
]

{ #category : 'rendering' }
ChessQueen >> renderPieceOn: aSquare [

	^ aSquare renderQueen: self
]

{ #category : 'rendering' }
ChessQueen >> targetSquaresLegal: aBoolean [

	| likeABishop likeARook |
	likeABishop := (self upRightDiagonalLegal: aBoolean)
	               , (self upLeftDiagonalLegal: aBoolean)
	               , (self downRightDiagonalLegal: aBoolean)
	               , (self downLeftDiagonalLegal: aBoolean).
	likeARook := (self upFileLegal: aBoolean)
	             , (self downFileLegal: aBoolean)
	             , (self leftFileLegal: aBoolean)
	             , (self rightFileLegal: aBoolean).
	^ likeABishop , likeARook
]
