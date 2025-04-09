Class {
	#name : 'ChessStockfishEngine',
	#superclass : 'ChessUCIEngine',
	#category : 'Chess-Core',
	#package : 'Chess-Core'
}

{ #category : 'initialization' }
ChessStockfishEngine >> initialize [

	uci := Stockfish new
]
