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
			$('ul.slider li').on 'click', @updateSlider
		scrollToTutorial: (e) ->
			e.preventDefault()
			$('html, body').animate({ scrollTop: $('.tutorial').offset().top + 'px' })
		destroy: () ->
			@unbind()
		unbind: () ->
			$('a.discover').off 'click', @scrollToTutorial
			$('ul.slider li').off 'click', @updateSlider

		render: () ->
			ga('send', 'pageview', '/')
			document.body.scrollTop = document.documentElement.scrollTop = 0
			@$el.html(@template())
			@bind()
			md.Router.hideLoader()
			return @
		updateSlider: () ->
			index = $(this).index()
			$('div.slider').find('.visible').removeClass('visible')
			$('ul.slider').find('.visible').removeClass('visible')
			$(this).addClass('visible')
			$('div.slider').find('img').eq(index).addClass('visible')