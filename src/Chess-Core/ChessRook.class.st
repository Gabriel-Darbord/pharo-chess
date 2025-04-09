Class {
	#name : 'ChessRook',
	#superclass : 'ChessPiece',
	#category : 'Chess-Core',
	#package : 'Chess-Core'
}

{ #category : 'accessing' }
ChessRook >> id [
	^ 'R'
]

{ #category : 'testing' }
ChessRook >> isRook [

	^ true
]

{ #category : 'rendering' }
ChessRook >> renderPieceOn: aSquare [

	^ aSquare renderRook: self
]

{ #category : 'rendering' }
ChessRook >> targetSquares [

	^ self upFile , self downFile , self leftFile , self rightFile
]

{ #category : 'rendering' }
ChessRook >> targetSquaresLegal: aBoolean [

	^ (self upFileLegal: aBoolean) , (self downFileLegal: aBoolean)
	  , (self leftFileLegal: aBoolean) , (self rightFileLegal: aBoolean)
]
