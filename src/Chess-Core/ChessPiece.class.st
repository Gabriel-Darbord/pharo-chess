Class {
	#name : 'ChessPiece',
	#superclass : 'MyPiece',
	#category : 'Chess-Core',
	#package : 'Chess-Core'
}

{ #category : 'testing' }
ChessPiece class >> isAbstract [

	^ self == ChessPiece
]

{ #category : 'testing' }
ChessPiece >> isBishop [

	^ false
]

{ #category : 'testing' }
ChessPiece >> isKnight [

	^ false
]

{ #category : 'testing' }
ChessPiece >> isPawn [

	^ false
]

{ #category : 'testing' }
ChessPiece >> isQueen [

	^ false
]

{ #category : 'testing' }
ChessPiece >> isRook [

	^ false
]

{ #category : 'path commands' }
ChessPiece >> moveTo: aSquare [
	"Do not verify legality"

	square emptyContents.
	square := aSquare.
	aSquare contents: self
]
