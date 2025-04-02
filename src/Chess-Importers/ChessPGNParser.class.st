Class {
	#name : 'ChessPGNParser',
	#superclass : 'MyPGNParser',
	#category : 'Chess-Importers',
	#package : 'Chess-Importers'
}

{ #category : 'enumerating' }
ChessPGNParser >> parseOnlyMovementsDo: aBlock [

	| movement |
	self parseTagPairs. "skip"
	[ (movement := self parseMovement) isNotNil ] whileTrue: [
		aBlock value: movement ]
]

{ #category : 'parsing' }
ChessPGNParser >> parseTag [
	"fix of super implementation which gobbles the first movement token"

	| tag |
	self peekToken = '[' ifFalse: [ ^ nil ].
	self nextToken.

	tag := MyPGNTag new
		       tagName: self nextToken;
		       value: self nextToken;
		       yourself.

	"Consume closing bracket"
	self nextToken.
	^ tag
]
