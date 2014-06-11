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
			
			@render()
		bind: () ->
			$('a.discover').on 'click', (e) ->
				e.preventDefault()
				console.log $('.tutorial').offset()
				$('html, body').animate({ scrollTop: $('.tutorial').offset().top + 'px' });
				# window.scroll($('.tutorial').offset().top, 0)

		render: () ->
			document.body.scrollTop = document.documentElement.scrollTop = 0
			@$el.html(@template())
			@bind()
			md.Router.hideLoader()
			return @