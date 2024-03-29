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
	'../views/bibliotheque'
	'../views/about'
	'../views/contact'
], ($, _, Backbone, md, PersonsCollection, PersonModel, HomeView, PersonView, ComparisonView, SearchView, BibliothequeView, AboutView, ContactView) ->
	'use strict'
	class Router extends Backbone.Router
		routes:
			'': 'home'
			'rechercher': 'getSearch'
			'a-propos': 'getAbout'
			'contact': 'getContact'
			'bibliotheque': 'getBibliotheque'
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
			md.Status['currentView'] = 'home'
			@updateSidebar()
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
			@updateSidebar()

		getSearch: () ->

			md.Status['currentView'] = 'rechercher'

			@getSearchbar(null, null, true)
			md.Views['rechercher'] = new SearchView()
			@updateSidebar()

		getBibliotheque: () ->
			md.Router.showLoader()
			md.Status['currentView'] = 'bibliotheque'
			if md.Views['search-bar'] then $(md.Views['search-bar'].el).removeClass('visible')
			md.Views['bibliotheque'] = new BibliothequeView()
			@updateSidebar()
		getAbout: () ->
			md.Router.showLoader()
			md.Status['currentView'] = 'a-propos'
			if md.Views['search-bar'] then $(md.Views['search-bar'].el).removeClass('visible')
			md.Views['a-propos'] = new AboutView()
			@updateSidebar()

		getContact: () ->
			md.Router.showLoader()
			md.Status['currentView'] = 'contact'
			if md.Views['search-bar'] then $(md.Views['search-bar'].el).removeClass('visible')
			md.Views['contact'] = new ContactView()
			@updateSidebar()

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
		
		updateSidebar: () ->
			$('#sidebar').find('.active').removeClass('active')
			if md.Status['currentView'] is 'person' or md.Status['currentView'] is 'comparison'
				$('#sidebar').find('[data-link=rechercher]').addClass('active')
			else if md.Status['currentView'] is 'home'
				$('#sidebar').find('.mediadata').addClass('active')
			else
				$('#sidebar').find('[data-link=' + md.Status['currentView'] + ']').addClass('active')