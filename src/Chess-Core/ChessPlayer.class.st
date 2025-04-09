Class {
	#name : 'ChessPlayer',
	#superclass : 'MyPlayer',
	#instVars : [
		'canCastleKingside',
		'canCastleQueenside'
	],
	#category : 'Chess-Core',
	#package : 'Chess-Core'
}

{ #category : 'accessing' }
ChessPlayer >> canCastle: aBoolean [

	canCastleKingside := canCastleQueenside := aBoolean
]

{ #category : 'accessing' }
ChessPlayer >> canCastleKingside [

	^ canCastleKingside
]

{ #category : 'accessing' }
ChessPlayer >> canCastleKingside: aBoolean [

	canCastleKingside := aBoolean
]

{ #category : 'accessing' }
ChessPlayer >> canCastleQueenside [

	^ canCastleQueenside
]

{ #category : 'accessing' }
ChessPlayer >> canCastleQueenside: aBoolean [

	canCastleQueenside := aBoolean
]

{ #category : 'initialization' }
ChessPlayer >> initialize [

	self canCastle: true
]
