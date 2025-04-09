Class {
	#name : 'ChessLongAlgebraicInterpreter',
	#superclass : 'ChessInterpreter',
	#category : 'Chess-Notations-Interpreters',
	#package : 'Chess-Notations',
	#tag : 'Interpreters'
}

{ #category : 'playing' }
ChessLongAlgebraicInterpreter >> interpret: aString afterMoveDo: aBlock [

	self notYetImplemented
]

{ #category : 'playing' }
ChessLongAlgebraicInterpreter >> interpretMove: move [

	| destination result |
	game currentPlayer canCastleKingside ifTrue: [
		whiteToPlay
			ifTrue: [ move = 'e1g1' ifTrue: [ ^ self moveCastle ] ]
			ifFalse: [ move = 'e8g8' ifTrue: [ ^ self moveCastle ] ] ].
	game currentPlayer canCastleQueenside ifTrue: [
		whiteToPlay
			ifTrue: [ move = 'e1c1' ifTrue: [ ^ self moveCastleLong ] ]
			ifFalse: [ move = 'e8c8' ifTrue: [ ^ self moveCastleLong ] ] ].

	destination := move copyFrom: 3 to: 4.

	result := self
		          move: (game board at: (move first: 2)) contents
		          to: destination.

	move size = 5 ifTrue: [ "if promotion"
		self promotePawnAt: destination to: move fifth asString.
		game moves
			at: game moves size
			put: game moves last , '=' , move fifth asString ].
	^ result
]
