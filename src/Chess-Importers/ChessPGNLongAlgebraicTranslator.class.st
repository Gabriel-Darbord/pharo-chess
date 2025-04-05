Class {
	#name : 'ChessPGNLongAlgebraicTranslator',
	#superclass : 'ChessPGNInterpreter',
	#category : 'Chess-Importers',
	#package : 'Chess-Importers'
}

{ #category : 'utilities' }
ChessPGNLongAlgebraicTranslator >> move: piece to: destination [

	| origin |
	origin := piece square name.
	super move: piece to: destination. "update the board"
	^ origin , destination
]

{ #category : 'moves' }
ChessPGNLongAlgebraicTranslator >> moveCastle [

	super moveCastle.
	^ whiteToPlay
		  ifTrue: [ 'e1g1' ]
		  ifFalse: [ 'e8g8' ]
]

{ #category : 'moves' }
ChessPGNLongAlgebraicTranslator >> moveCastleLong [

	super moveCastleLong.
	^ whiteToPlay
		  ifTrue: [ 'e1c1' ]
		  ifFalse: [ 'e8c8' ]
]

{ #category : 'moves' }
ChessPGNLongAlgebraicTranslator >> movePawn: move [

	| xIndex eIndex moveNoSuffix notation |
	xIndex := move indexOf: $x. "pawn takes?"
	eIndex := move indexOf: $=. "promotion?"

	moveNoSuffix := eIndex = 0
		                ifTrue: [ "check?"
			                ('+#' includes: move last)
				                ifTrue: [ move allButLast ]
				                ifFalse: [ move ] ]
		                ifFalse: [ move copyFrom: 1 to: eIndex - 1 ].

	notation := xIndex = 0
		            ifTrue: [ self movePawnForward: moveNoSuffix ]
		            ifFalse: [ self movePawnTakes: moveNoSuffix ].

	eIndex = 0 ifFalse: [
		notation := notation , self
			            promotePawnAt: (moveNoSuffix last: 2)
			            to: (move at: eIndex + 1) ].
	^ notation
]

{ #category : 'translate' }
ChessPGNLongAlgebraicTranslator >> translatePGN: pgnString [

	| index |
	index := 0.
	^ String streamContents: [ :s |
		  self interpretPGN: pgnString afterMoveDo: [ :move |
			  s nextPut: Character space.
			  (index := index + 1) odd ifTrue: [
				  s print: index.
				  s nextPutAll: '. ' ].
			  s nextPutAll: move ] ]
]
