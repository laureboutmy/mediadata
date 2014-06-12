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
	'../views/index'
	'../views/about'
	'../views/contact'
], ($, _, Backbone, md, PersonsCollection, PersonModel, HomeView, PersonView, ComparisonView, SearchView, IndexView, AboutView, ContactView) ->
	'use strict'
	class Router extends Backbone.Router
		routes:
			'': 'home'
			'rechercher': 'getSearch'
			'a-propos': 'getAbout'
			'contact': 'getContact'
			'index': 'getIndex'
			':person': 'getPerson'
			':person/:otherPerson': 'getComparison'

		initialize: () ->
			@onResize()
			@bind()

		bind: () ->
			$('#main').on('click', '[data-link]', @go)
			$('#sidebar').on('click', '[data-link]', @go)
			$(window).on('resize', @onResize)

		home: () ->
			@showLoader()
			@hideSearchbar()
			md.Views['home'] = new HomeView()
			md.Views['home'].render()

		getSearchbar: (name1 = null, name2 = null, isSearch = null) ->
			if !md.Views['search-bar'] 
				require ['views/search-bar'], (SearchbarView) =>
					if isSearch then md.Views['search-bar'] = new SearchbarView({isSearch: isSearch})
					else md.Views['search-bar'] = new SearchbarView({name1: name1, name2: name2})

					$(md.Views['search-bar'].el).addClass('visible')
			else
				if isSearch then md.Views['search-bar'].render({isSearch: isSearch})
				else md.Views['search-bar'].render({name1: name1, name2: name2})

				$(md.Views['search-bar'].el).addClass('visible')
		hideSearchbar: () ->
			if md.Views['search-bar'] then $(md.Views['search-bar'].el).removeClass('visible')
		getFilters: () ->
			if !md.Views['filters'] 
				require ['views/filters'], (FiltersView) =>
					md.Views['filters'] = new FiltersView()
			else 
				md.Views['filters'].render()

		getPerson: (name) ->
			md.Router.showLoader()
			@getSearchbar(name)
			md.Views['person'] = new PersonView({name1: name})

		getSearch: () ->

			md.Status['currentView'] = 'search'

			@getSearchbar(null, null, true)
			md.Views['search'] = new SearchView()

		getIndex: () ->
			md.Router.showLoader()
			md.Status['currentView'] = 'index'
			if md.Views['search-bar'] then $(md.Views['search-bar'].el).removeClass('visible')
			md.Views['index'] = new IndexView()
		getAbout: () ->
			md.Router.showLoader()
			md.Status['currentView'] = 'about'
			if md.Views['search-bar'] then $(md.Views['search-bar'].el).removeClass('visible')
			md.Views['about'] = new AboutView()
		getContact: () ->
			md.Router.showLoader()
			md.Status['currentView'] = 'contact'
			if md.Views['search-bar'] then $(md.Views['search-bar'].el).removeClass('visible')
			md.Views['contact'] = new ContactView()

		getComparison: (name1, name2) ->
			md.Router.showLoader()
			@getSearchbar(name1, name2)
			md.Views['comparison'] = new ComparisonView({name1: name1, name2: name2})

		onResize: () ->
			wWidth = $(window).width()
			$('#main').width(wWidth - 80)
			$('#search-bar').width(wWidth - 80)
			$('#loader').width(wWidth - 80)
		
		showLoader: () ->
			loader = $('#main-loader')
			if !loader.hasClass('visible') then loader.addClass('z-index').addClass('visible')

		hideLoader: () ->
			loader = $('#main-loader')
			if loader.hasClass('debut') then loader.removeClass('debut');
			loader.removeClass('visible')
			setTimeout () ->
				$("#main-loader").removeClass('z-index')
			, 300
			return

		go: (evt) ->
			evt.preventDefault()
			md.Views[md.Status['currentView']].destroy()
			url = $(this).data('link')
			md.Router.navigate(url, {trigger: true})
			# if url != 'rechercher' && url != 'index' && url != 'a-propos' && url != 'home'  then md.Router.getPerson(url)
