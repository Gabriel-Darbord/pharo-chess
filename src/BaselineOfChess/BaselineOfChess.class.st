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
			with: [ spec repository: 'github://UnivLille-Meta/Chess:main' ].

		spec
			package: 'Chess-Importers';
			package: 'Chess-Animated' with: 'Chess-Importers' ]
]
