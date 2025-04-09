Class {
	#name : 'ChessUCIReader',
	#superclass : 'Object',
	#instVars : [
		'uci',
		'process',
		'onReady',
		'onUCI',
		'onBestMove',
		'onInfo'
	],
	#category : 'Chess-UCI',
	#package : 'Chess-UCI'
}

{ #category : 'instance creation' }
ChessUCIReader class >> on: aUCI [

	^ self new uci: aUCI
]

{ #category : 'accessing' }
ChessUCIReader >> onBestMove [

	^ onBestMove
]

{ #category : 'accessing' }
ChessUCIReader >> onBestMove: aBlock [

	onBestMove := aBlock
]

{ #category : 'accessing' }
ChessUCIReader >> onInfo [

	^ onInfo
]

{ #category : 'accessing' }
ChessUCIReader >> onInfo: aBlock [

	onInfo := aBlock
]

{ #category : 'accessing' }
ChessUCIReader >> onReady [

	^ onReady
]

{ #category : 'accessing' }
ChessUCIReader >> onReady: aBlock [

	onReady := aBlock
]

{ #category : 'accessing' }
ChessUCIReader >> onUCI [

	^ onUCI
]

{ #category : 'accessing' }
ChessUCIReader >> onUCI: aBlock [

	onUCI := aBlock
]

{ #category : 'reading' }
ChessUCIReader >> read: line [

	| index command |
	index := line indexOf: Character space.
	command := index = 0
		           ifTrue: [ line ]
		           ifFalse: [ line copyFrom: 1 to: index ].

	command = 'info' ifTrue: [ self readInfo: line ].
	command = 'bestmove' ifTrue: [ self readBestMove: line ].
	command = 'readyok' ifTrue: [ self onReady value ].
	command = 'uciok' ifTrue: [ self onUCI value ]
]

{ #category : 'reading' }
ChessUCIReader >> readBestMove: line [

	self halt
]

{ #category : 'reading' }
ChessUCIReader >> readInfo: line [

	self halt
]

{ #category : 'reading' }
ChessUCIReader >> startReading [

	process := [ [ self read: uci read ] repeat ] fork
]

{ #category : 'reading' }
ChessUCIReader >> stopReading [

	process terminate
]

{ #category : 'accessing' }
ChessUCIReader >> uci [

	^ uci
]

{ #category : 'accessing' }
ChessUCIReader >> uci: aUCI [

	uci := aUCI
]
