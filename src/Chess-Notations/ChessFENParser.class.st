Class {
	#name : 'ChessFENParser',
	#superclass : 'MyFENParser',
	#category : 'Chess-Notations',
	#package : 'Chess-Notations'
}

{ #category : 'parsing' }
ChessFENParser >> parse [

	| game |
	game := ChessFENGame new.

	game ranks: self parseRanks.
	self expectString: ' '.
	game sideToMove: self parseSideToMove.
	self expectString: ' '.
	game castlingAbility: self parseCastlingAbility.
	self expectString: ' '.
	game enPassantTargetSquare: self parseEnPassant.
	self expectString: ' '.
	game halfMoveClock: self parseNumber.
	self expectString: ' '.
	game moveCount: self parseNumber.

	^ game
]

{ #category : 'parsing' }
ChessFENParser >> parseCastlingAbility [

	| castling |
	self peek = $- ifTrue: [ ^ 'NO CASTLING' ].

	castling := OrderedCollection new: 4.
	[
	castling add: (self parseAnyOf: 'kKqQ').
	self peek = Character space ] whileFalse.
	^ castling
]
