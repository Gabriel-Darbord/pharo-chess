Class {
	#name : 'ChessGIFExporter',
	#superclass : 'Object',
	#instVars : [
		'delay'
	],
	#category : 'Chess-Animated',
	#package : 'Chess-Animated'
}

{ #category : 'instance creation' }
ChessGIFExporter class >> fromFEN: fenString andPGN: pgnString [

	^ self new
		  fromPGN: pgnString
		  onGame: (ChessGame fromFENString: fenString)
]

{ #category : 'instance creation' }
ChessGIFExporter class >> fromPGN: pgnString [

	^ self new fromPGN: pgnString
]

{ #category : 'private' }
ChessGIFExporter >> buildGIF: frames [

	| fileName writer |
	fileName := 'chess-' , DateAndTime now asFileNameCompatibleString
	            , '.gif'.
	writer := GIFReadWriter on: (File openForWriteFileNamed: fileName).
	writer loopCount: 0. "infinite"

	[ frames do: [ :frame | writer nextPutFrame: frame ] ] ensure: [
		writer close ].

	self uiManager
		inform: 'Chess GIF created: '
			, fileName asFileReference absolutePath pathString
		actionOnClick: [ fileName asFileReference openInOSFileBrowser ]
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
	"In ms, default is 1 second."

	^ delay ifNil: [ delay := 1000 ]
]

{ #category : 'accessing' }
ChessGIFExporter >> delay: anInteger [
	"in ms"

	delay := anInteger
]

{ #category : 'API' }
ChessGIFExporter >> fromPGN: pgnString [

	^ self fromPGN: pgnString onGame: ChessGame freshGame
]

{ #category : 'API' }
ChessGIFExporter >> fromPGN: pgnString onGame: chessGame [

	| interpreter frames |
	frames := OrderedCollection new.
	interpreter := ChessPGNInterpreter on: chessGame.

	interpreter
		interpret: pgnString
		afterMoveDo: [
		frames add: (self captureBoard: interpreter game board) ].

	self buildGIF: frames
]
