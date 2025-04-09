Class {
	#name : 'ChessWriter',
	#superclass : 'Object',
	#instVars : [
		'moves'
	],
	#category : 'Chess-Notations-Writer',
	#package : 'Chess-Notations',
	#tag : 'Writer'
}

{ #category : 'testing' }
ChessWriter class >> isAbstract [

	^ self == ChessWriter
]

{ #category : 'writing' }
ChessWriter >> move: piece to: square promotion: pieceNotation [

	self subclassResponsibility
]

{ #category : 'accessing' }
ChessWriter >> moves [

	^ moves ifNil: [ moves := OrderedCollection new ]
]

{ #category : 'printing' }
ChessWriter >> movesString [

	^ String streamContents: [ :s |
		  moves withIndexDo: [ :move :i |
			  s nextPut: Character space.
			  i odd ifTrue: [
				  i > 1 ifTrue: [ s cr ].
				  s print: i // 2 + 1.
				  s nextPutAll: '. ' ].
			  s nextPutAll: move ] ]
]
