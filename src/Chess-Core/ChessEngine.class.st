Class {
	#name : 'ChessEngine',
	#superclass : 'Object',
	#instVars : [
		'game'
	],
	#category : 'Chess-Core',
	#package : 'Chess-Core'
}

{ #category : 'accessing' }
ChessEngine >> game [

	^ game
]

{ #category : 'accessing' }
ChessEngine >> game: aChessGame [

	game := aChessGame
]
