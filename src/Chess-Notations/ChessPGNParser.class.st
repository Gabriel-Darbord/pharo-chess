Class {
	#name : 'ChessPGNParser',
	#superclass : 'MyPGNParser',
	#category : 'Chess-Notations-Parsers',
	#package : 'Chess-Notations',
	#tag : 'Parsers'
}

{ #category : 'as yet unclassified' }
ChessPGNParser >> parseMovement [

	| nextToken moveNumber firstMovement |
	nextToken := self peekToken.
	(#( '1-0' '0-1' '1/2-1/2' '*' ) includes: nextToken) ifTrue: [ ^ nil ].

	moveNumber := self parseMoveNumber.
	nextToken := self peekToken.
	(nextToken isNil or: [
		 nextToken first isDigit or: [
			 #( '1-0' '0-1' '1/2-1/2' '*' ) includes: nextToken ] ]) ifTrue: [
		^ nil ].

	firstMovement := self nextToken.
	nextToken := self peekToken.
	(nextToken isNil or: [
		 nextToken first isDigit or: [
			 #( '1-0' '0-1' '1/2-1/2' '*' ) includes: nextToken ] ]) ifTrue: [
		^ {
			  moveNumber.
			  firstMovement } ].

	^ {
		  moveNumber.
		  firstMovement.
		  self nextToken }
]

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
