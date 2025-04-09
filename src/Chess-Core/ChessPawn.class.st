Class {
	#name : 'ChessPawn',
	#superclass : 'ChessPiece',
	#category : 'Chess-Core',
	#package : 'Chess-Core'
}

{ #category : 'as yet unclassified' }
ChessPawn >> attackingSquares [

	^ self isWhite
		  ifTrue: [
			  {
				  square up left.
				  square up right } ]
		  ifFalse: [
			  {
				  square down left.
				  square down right } ]
]

{ #category : 'testing' }
ChessPawn >> hasMoved [

	^ square name last ~~ (self isWhite
		   ifTrue: [ $2 ]
		   ifFalse: [ $7 ])
]

{ #category : 'accessing' }
ChessPawn >> id [

	^ 'P'
]

{ #category : 'testing' }
ChessPawn >> isPawn [

	^ true
]

{ #category : 'rendering' }
ChessPawn >> renderPieceOn: aSquare [ 
	
	^ aSquare renderPawn: self
]

{ #category : 'rendering' }
ChessPawn >> targetSquaresLegal: aBoolean [

	^ (self hasMoved
		   ifTrue: [
			   self isWhite
				   ifTrue: [ { square up } ]
				   ifFalse: [ { square down } ] ]
		   ifFalse: [
			   self isWhite
				   ifTrue: [ { square up. square up up } ]
				   ifFalse: [ { square down. square down down } ] ])
		select: [ :s | s notNil and: [ s hasPiece not ] ]
]
