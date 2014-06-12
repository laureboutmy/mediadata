define [
	'jquery'
	'underscore'
	'backbone'
	'mediadata'
	'text!templates/home.html'
], ($, _, Backbone, md, tplHome) ->
	'use strict'
	HomeView = Backbone.View.extend
		el: '#main'
		template: _.template(tplHome)
		initialize: () ->
			md.Status['currentView'] = 'home'
			@render()

		bind: () ->
			$('a.discover').on 'click', @scrollToTutorial

		scrollToTutorial: (e) ->
			e.preventDefault()
			$('html, body').animate({ scrollTop: $('.tutorial').offset().top + 'px' })
		destroy: () ->
			$('a.discover').off 'click', @scrollToTutorial

		render: () ->
			ga('send', 'pageview', '/')
			md.Status['currentView'] = 'home'
			document.body.scrollTop = document.documentElement.scrollTop = 0
			@$el.html(@template())
			@bind()
			md.Router.hideLoader()
			return @