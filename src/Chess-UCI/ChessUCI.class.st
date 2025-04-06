"
I wrap a process running a chess engine and communicate with it using Universal Chess Interface (UCI).

The `UCI` protocol are for sending commands.
Users have the responsibility to synchronize read and write operations.
In a standard scenario, there can be any number of writer threads, but only a single reader thread to ensure all commands sent by the engine are read.

The `UCI - sync` protocol offers basic synchronous command handling, but `info` commands will be lost.

### Resources

[UCI Protocol](https://backscattering.de/chess/uci/)
"
Class {
	#name : 'ChessUCI',
	#superclass : 'Object',
	#instVars : [
		'process',
		'command',
		'arguments'
	],
	#category : 'Chess-UCI',
	#package : 'Chess-UCI'
}

{ #category : 'instance creation' }
ChessUCI class >> create: pathString withArguments: arguments [
	"Initialize an engine process using:
	- command or executable path
	- arguments: array of string arguments for the engine process"

	^ self basicNew initialize autoRelease
		  command: pathString;
		  arguments: arguments;
		  startEngine
]

{ #category : 'class initialization' }
ChessUCI class >> initialize [

	SessionManager default registerUserClassNamed: self name
]

{ #category : 'instance creation' }
ChessUCI class >> new [
	"Subclasses can redefine if there is a default way to connect to the engine"

	self error:
		'Use `executable: ''path/to/engine'' withArguments: { ''-eg'' }`'
]

{ #category : 'system startup' }
ChessUCI class >> shutDown: quitting [

	quitting ifFalse: [ ^ self ].
	self allSubInstancesDo: [ :uci | uci destroy ]
]

{ #category : 'system startup' }
ChessUCI class >> startUp: resuming [

	resuming ifFalse: [ ^ self ].
	self allSubInstancesDo: [ :uci | uci startEngine ]
]

{ #category : 'accessing' }
ChessUCI >> arguments [

	^ arguments
]

{ #category : 'accessing' }
ChessUCI >> arguments: aStringCollection [

	arguments := aStringCollection
]

{ #category : 'converting' }
ChessUCI >> asEngine [

	^ self engineClass new uci: self
]

{ #category : 'initialization' }
ChessUCI >> autoRelease [

	self finalizationRegistry add: self
]

{ #category : 'UCI - sync' }
ChessUCI >> awaitBestMove [
	"Await until the engine stops searching and announces the best move it found.
	Return the best move, and the expected best move of the adversary called 'ponder'.
	The moves are strings in long algebraic notation."

	| line best ponder |
	[ (line := self read) beginsWith: 'bestmove' ] whileFalse.
	best := line
		        copyFrom: 10
		        to:
			        (line indexOf: Character space startingAt: 14 ifAbsent: [
				         ^ {
					           (line copyFrom: 10 to: line size).
					           nil } ]) - 1.
	ponder := line
		          copyFrom: (line lastIndexOf: Character space) + 1
		          to: line size.
	^ {
		  best.
		  ponder }
]

{ #category : 'UCI - sync' }
ChessUCI >> awaitNewGame [
	"Tell the engine the next search (started with position and go) will be from a different game."

	self write: 'ucinewgame'.
	self awaitReady
]

{ #category : 'UCI - sync' }
ChessUCI >> awaitPonderHit [
	"Tell the engine its adversary played the move it expected.
	Returns the moves from the bestmove command it sent."

	self ponderHit.
	^ self awaitBestMove
]

{ #category : 'UCI - sync' }
ChessUCI >> awaitReady [
	"Await until the engine is ready"

	self isReady.
	self read: 'readyok'
]

{ #category : 'UCI - sync' }
ChessUCI >> awaitStop [
	"Stop calculating as soon as possible"

	self write: 'stop'.
	^ self awaitBestMove
]

{ #category : 'UCI - sync' }
ChessUCI >> awaitUCI [
	"Tell engine to use UCI, this must be sent once as a first command after program boot to tell the engine to switch to uci mode.
	This is called automatically if you used #create:withArguments: to initialize the engine."

	self uci.
	self read: 'uciok'
]

{ #category : 'accessing' }
ChessUCI >> command [

	^ command
]

{ #category : 'accessing' }
ChessUCI >> command: pathString [

	command := pathString
]

{ #category : 'API' }
ChessUCI >> destroy [
	"Ensure the engine process stops and clean up"

	| theProcess |
	process isComplete ifTrue: [ ^ self ].
	process stdinStream closed
		ifFalse: [ "send quit command" self quit ]
		ifTrue: [ "cannot communicate" process terminate ].
	theProcess := process. "don't lose track of the instance"
	[ "ensure process resources are cleaned"
	[ theProcess waitForExit ]
		valueWithin: 1 second
		onTimeout: [ theProcess kill ].
	theProcess waitForExit.
	theProcess closeAndCleanStreams ] fork
]

{ #category : 'converting' }
ChessUCI >> engineClass [

	^ ChessEngine
]

{ #category : 'finalization' }
ChessUCI >> finalize [

	(process isNil or: [ process isComplete ]) ifFalse: [ self destroy ]
]

{ #category : 'private' }
ChessUCI >> flush [
	"Flush a command to the engine"

	process stdinStream
		nextPut: Character lf;
		flush
]

{ #category : 'UCI' }
ChessUCI >> goInfinite [
	"Search until the stop command is given.
	The engine won't exit the search without being told so in this mode!"

	self write: 'go infinite'
]

{ #category : 'UCI' }
ChessUCI >> goPonder [
	"Start searching in pondering mode.
	Engine won't exit the search in ponder mode, even if it's mate!"

	self write: 'go ponder'
]

{ #category : 'UCI' }
ChessUCI >> goWith [
	"The go command can mix and match different ways of limiting the search time.
	The search ends when it hits any one of those limits.
	Use the API of UCIGoBuilder to configure and send this command."

	self nextPutAll: 'go'.
	^ ChessUCIGoBuilder on: self
]

{ #category : 'UCI' }
ChessUCI >> isReady [
	"Ask the engine if it is ready, it should answer 'readyok'"

	self write: 'isready'
]

{ #category : 'UCI' }
ChessUCI >> newGame [
	"Tell the engine the next search (started with position and go) will be from a different game."

	self write: 'ucinewgame'
]

{ #category : 'private' }
ChessUCI >> nextPutAll: messagePart [

	process stdinStream nextPutAll: messagePart
]

{ #category : 'UCI' }
ChessUCI >> ponderHit [
	"Tell the engine its adversary played the move it expected.
	The engine switches from pondering to normal search and announces its best move."

	self write: 'ponderhit'
]

{ #category : 'UCI' }
ChessUCI >> positionFEN: fenString [
	"Set up the position described in fenString"

	self nextPutAll: 'position fen '.
	self nextPutAll: fenString.
	self flush
]

{ #category : 'UCI' }
ChessUCI >> positionFEN: fenString moves: moves [
	"Set up the position described in fenString and play the moves.
	Moves are given as an array of strings in long algebraic notation."

	self nextPutAll: 'position fen '.
	self nextPutAll: fenString.
	self nextPutAll: ' moves'.
	moves do: [ :move |
		self nextPutAll: ' '.
		self nextPutAll: move ].
	self flush
]

{ #category : 'UCI' }
ChessUCI >> positionMoves: moves [
	"Set up the position from the start position and play the moves.
	Moves are given as an array of strings in long algebraic notation."

	self nextPutAll: 'position startpos moves'.
	moves do: [ :move |
		self nextPutAll: ' '.
		self nextPutAll: move ].
	self flush
]

{ #category : 'UCI' }
ChessUCI >> positionStart [
	"Set the position to the start position"

	self write: 'position startpos'
]

{ #category : 'UCI' }
ChessUCI >> quit [
	"Quit the program as soon as possible.
	Use #destroy instead to cleanly terminate the engine process."

	self write: 'quit'
]

{ #category : 'API' }
ChessUCI >> read [
	"Read the next line from engine's stdout on a blocking pipe."

	| reader lf |
	reader := process stdoutStream reader.
	lf := Character lf.
	String streamContents: [ :line |
		[
		| char |
		char := reader next. "blocking"
		char == lf ifTrue: [ ^ line contents ].
		line nextPut: char ] repeat ]
]

{ #category : 'private' }
ChessUCI >> read: expected [
	"Await a specific answer from the engine for at most 1 minute."

	self read: expected within: 1 minute
]

{ #category : 'private' }
ChessUCI >> read: expected within: duration [
	"Await a specific answer from the engine with a timeout."

	self read: expected within: duration onTimeout: [
		process terminate.
		process closeAndCleanStreams.
		TimedOut signal ]
]

{ #category : 'private' }
ChessUCI >> read: expected within: duration onTimeout: block [
	"Await a specific answer from the engine with a timeout and timeout handling."

	[ [ self read = expected ] whileFalse ]
		valueWithin: duration
		onTimeout: block
]

{ #category : 'private' }
ChessUCI >> readUntil: aBlock [
	"Read multiple lines until the condition is true.
	Since reading is blocking, we have to know when to stop."

	^ String streamContents: [ :s |
		  [ aBlock value: (s nextPutAll: self read) ] whileFalse: [ s cr ] ]
]

{ #category : 'UCI' }
ChessUCI >> setOption: name [

	self nextPutAll: 'setoption name '.
	self nextPutAll: name.
	self flush
]

{ #category : 'UCI' }
ChessUCI >> setOption: name value: optionValue [

	self nextPutAll: 'setoption name '.
	self nextPutAll: name.
	self nextPutAll: ' value '.
	self nextPutAll: optionValue.
	self flush
]

{ #category : 'private' }
ChessUCI >> startEngine [

	self startEngineProcess.
	self awaitUCI awaitReady "Ask engine to use uci and wait until it is ready"
]

{ #category : 'private' }
ChessUCI >> startEngineProcess [

	(process := OSSUnixSubprocess new)
		command: command;
		arguments: arguments;
		redirectStdin;
		redirectStdoutTo: process systemAccessor makeBlockingPipe;
		redirectStderr;
		run
]

{ #category : 'UCI' }
ChessUCI >> stop [
	"Stop calculating as soon as possible"

	self write: 'stop'
]

{ #category : 'UCI' }
ChessUCI >> uci [
	"Tell engine to use UCI"

	self write: 'uci'
]

{ #category : 'private' }
ChessUCI >> write: message [

	process stdinStream
		nextPutAll: message;
		nextPut: Character lf;
		flush
]
