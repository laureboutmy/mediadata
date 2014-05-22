define [
	'jquery'
	'underscore'
	'backbone'
	'../collections/persons'
	'../models/person'
	'../views/home'
	'../views/explorer'
	'../views/person'
	'../views/search-bar'
], ($, _, Backbone, PersonsCollection, PersonModel, HomeView, ExplorerView, PersonView, SearchbarView) ->
	'use strict'
	class Router extends Backbone.Router
		routes:
			'': 'home'
			'explorer': 'explorer'
			':person': 'getPerson'
			':person/:otherPerson': 'compare'

		searchBar: null
		initialize: () ->
			@onResize()
			@bind()

		compare: (person, otherPerson) ->
			console.log person, otherPerson

		explorer: () ->
			explorerView = new ExplorerView()
			explorerView.render()

		home: () ->
			homeView = new HomeView()
			homeView.render()

		getPerson: (name) ->
			console.log name
			if !@searchBar then @searchBar = new SearchbarView()
			@searchBar.render()
			@searchBar.onResize()
			# personView = new PersonView(new PersonsCollection({name: name}))
			personView = new PersonView({name: name})

		onResize: () ->
			document.getElementById('main').style.width = window.innerWidth - 250 + 'px'
			# $('#search-bar').width($(window).width() - 250)
			# document.getElementById('search-bar').style.width = window.innerWidth - 250 + 'px';

		render: (view, name) ->
			@createView(view, name)

		bind: () ->
			_this = @
			$(window).on('resize', _this.onResize)

		createView: (view, name) ->
			
	