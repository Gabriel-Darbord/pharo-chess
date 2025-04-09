Class {
	#name : 'ChessBoard',
	#superclass : 'MyChessBoard',
	#category : 'Chess-Core-Model',
	#package : 'Chess-Core',
	#tag : 'Model'
}

{ #category : 'initialization' }
ChessBoard >> initializeFromFENBoard: aFENBoard [

	aFENBoard keysAndValuesDo: [ :k :v |
		v ~= 'empty' ifTrue: [
			| substrings color piece |
			substrings := v substrings.
			color := substrings first.
			piece := substrings second.
			self
				at: k
				put:
					((self class environment at:
						  ('Chess' , piece capitalized) asSymbol) perform:
						 color asLowercase asSymbol) ] ]
]
