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
], ($, _, Backbone, md, PersonsCollection, PersonModel, HomeView, PersonView, ComparisonView) ->
	'use strict'
	class Router extends Backbone.Router
		routes:
			'': 'home'
			':person': 'getPerson'
			':person/:otherPerson': 'getComparison'

		initialize: () ->
			@onResize()
			# @bind()

		compare: (person, otherPerson) ->
			console.log person, otherPerson

		# explorer: () ->
		# 	explorerView = new ExplorerView()
			# explorerView.render()

		home: () ->
			md.Views['home'] = new HomeView()
			md.Views['home'].render()

		getSearchbar: (name1 = null, name2 = null) ->
			if !md.Views['search-bar'] 
				require ['views/search-bar'], (SearchbarView) =>
					md.Views['search-bar'] = new SearchbarView({name1: name1, name2: name2})
					$(md.Views['search-bar'].el).addClass('visible');
			else
				md.Views['search-bar'].render(name1)
				$(md.Views['search-bar'].el).addClass('visible');

		getFilters: () ->
			if !md.Views['filters'] 
				require ['views/filters'], (FiltersView) =>
					md.Views['filters'] = new FiltersView()

		getPerson: (name) ->
			if !md.Views['searchBar'] then @getSearchbar(name)
			md.Views['person'] = new PersonView({name1: name})

		getComparison: (name1, name2) ->
			@getSearchbar(name1, name2)
			md.Views['person'] = new ComparisonView({name1: name1, name2: name2})

		# resetLoader: () ->
			# $('div.loader').removeClass('loading', 'complete')

		# load: () ->
		# 	$('div.loader').addClass('loading');

		onResize: () ->
			$('#main').width($(window).width() - 80)
			$('#search-bar').width($(window).width() - 80)
			$('#loader').width($(window).width() - 80)
			

			# document.getElementById('search-bar').style.width = window.innerWidth - 250 + 'px';

		# render: (view, name) ->
		# 	@createView(view, name)

		# bind: () ->
		# 	_this = @
		# 	$(window).on('resize', _this.onResize)

		# createView: (view, name) ->
			
	