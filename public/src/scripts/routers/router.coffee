define [
	'jquery'
	'underscore'
	'backbone'
	'mediadata'
	'../collections/persons'
	'../models/person'
	'../views/home'
	'../views/person'
	# '../views/search-bar'
	'../views/comparison'
	'../views/search'
], ($, _, Backbone, md, PersonsCollection, PersonModel, HomeView, PersonView, ComparisonView, SearchView) ->
	'use strict'
	class Router extends Backbone.Router
		routes:
			'': 'home'
			'rechercher': 'getSearch'
			':person': 'getPerson'
			':person/:otherPerson': 'getComparison'

		initialize: () ->
			@onResize()
			# @bind()

		compare: (person, otherPerson) ->
			console.log person, otherPerson

		home: () ->
			md.Views['home'] = new HomeView()
			md.Views['home'].render()

		getSearchbar: (name1 = null, name2 = null) ->
			if !md.Views['search-bar'] 
				require ['views/search-bar'], (SearchbarView) =>
					md.Views['search-bar'] = new SearchbarView({name1: name1, name2: name2})
					$(md.Views['search-bar'].el).addClass('visible')
			else
				md.Views['search-bar'].render({name1: name1, name2: name2})
				$(md.Views['search-bar'].el).addClass('visible')

		getFilters: () ->
			if !md.Views['filters'] 
				require ['views/filters'], (FiltersView) =>
					md.Views['filters'] = new FiltersView()
			else 
				md.Views['filters'].render()

		getPerson: (name) ->
			@getSearchbar(name)
			# if !md.Views['search-bar'] then @getSearchbar(name)
			# else md.Views['search-bar'].render({name1: name})
			md.Views['person'] = new PersonView({name1: name})

		getSearch: () ->
			if !md.Views['search-bar'] then @getSearchbar(name)
			md.Views['search'] = new SearchView()

		getComparison: (name1, name2) ->
			console.log('getcomparison')
			@getSearchbar(name1, name2)

			# if !md.Views['search-bar'] then @getSearchbar(name1, name2)
			# else md.Views['search-bar'].render({name1: name1, name2: name2})
			md.Views['comparison'] = new ComparisonView({name1: name1, name2: name2})

		onResize: () ->
			$('#main').width($(window).width() - 80)
			$('#search-bar').width($(window).width() - 80)
			$('#loader').width($(window).width() - 80)