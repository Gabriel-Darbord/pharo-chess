Class {
	#name : 'ChessGIFExporter',
	#superclass : 'Object',
	#instVars : [
		'delay'
	],
	#category : 'Chess-Animated',
	#package : 'Chess-Animated'
}

{ #category : 'private' }
ChessGIFExporter >> buildGIF: frames [

	| fileName writer |
	fileName := 'chess-' , DateAndTime now asFileNameCompatibleString
	            , '.gif'.
	writer := GIFReadWriter on: (File openForWriteFileNamed: fileName).
	writer loopCount: 0. "infinite"

	[ frames do: [ :frame | writer nextPutFrame: frame ] ] ensure: [
		writer close ].

	self inform: 'Chess GIF created: '
		, fileName asFileReference absolutePath pathString
]

{ #category : 'private' }
ChessGIFExporter >> captureBoard: board [

	^ AnimatedImageFrame new
		  delay: self delay;
		  form: board asForm;
		  yourself
]

{ #category : 'accessing' }
ChessGIFExporter >> delay [

	^ delay ifNil: [ delay := 1 second asMilliSeconds ]
]

{ #category : 'accessing' }
ChessGIFExporter >> delay: anInteger [
	"in ms"

	delay := anInteger
]

{ #category : 'API' }
ChessGIFExporter >> fromPGN: pgnString [

	| interpreter frames |
	frames := OrderedCollection new.
	interpreter := ChessPGNInterpreter new.

	interpreter
		interpretPGN: pgnString
		afterMoveDo: [
		frames add: (self captureBoard: interpreter game board) ].

	self buildGIF: frames
]
