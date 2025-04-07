Class {
	#name : 'BaselineOfChess',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfChess',
	#package : 'BaselineOfChess'
}

{ #category : 'baselines' }
BaselineOfChess >> baseline: spec [

	<baseline>
	spec for: #common do: [
		spec
			baseline: 'MygChess'
			with: [ spec repository: 'github://UnivLille-Meta/Chess:main' ];
			baseline: 'OSSubprocess' with: [
				spec repository:
						'github://pharo-contributions/OSSubprocess:master/repository' ].

		spec
			package: 'Chess-Core'
			with: [ spec requires: #( 'Chess-Importers' 'Chess-UCI' ) ];
			package: 'Chess-Importers';
			package: 'Chess-Animated' with: 'Chess-Importers';
			package: 'Chess-UCI' with: 'OSSubprocess' ]
]
