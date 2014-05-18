define ['mediadata'], (MD) ->
	'use strict'
	Backbone.Router.extend
		routes:
			'': 'home'
			'explorer': 'explorer'
			':person': 'setFilter'
			':person/:otherPerson': 'compare'

		initialize: () ->
			Backbone.history.start
				pushState: true
				root: '/mediadata/public/'

			@onResize()

		compare: (person, otherPerson) ->
			console.log person, otherPerson

		explorer: () ->
			console.log('explorer')
			@render('explorer')

		home: () ->
			console.log('home')
			@render('home')

		setFilter: (param) ->
			console.log param

		onResize: () ->
			document.getElementById('main').style.width = window.innerWidth - 275 + 'px'
	
		render: (view) ->
			MD.Status.previousView = MD.Status.currentView || ''
			MD.Status.currentView = view
			@createView(view)

		createView: (view) ->
			require ['views/' + view], (View) ->
				MD.Views[view] = new View()