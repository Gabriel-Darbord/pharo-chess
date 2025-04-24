Class {
	#name : 'ChessFENGame',
	#superclass : 'MyFENGame',
	#category : 'Chess-Notations',
	#package : 'Chess-Notations'
}

{ #category : 'accessing' }
ChessFENGame >> ranks: aCollection [

	board := Dictionary new.
	aCollection reversed with: (1 to: 8) do: [ :rankPieces :rank |
		| index |
		index := 97. "$a asInteger"
		rankPieces do: [ :piece |
			piece isCharacter
				ifTrue: [ index := index + piece digitValue ]
				ifFalse: [
					board
						at: (String with: index asCharacter with: rank asCharacterDigit)
						put: piece.
					index := index + 1 ] ] ]
]
