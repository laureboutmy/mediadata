define [
	'jquery'
	'underscore'
	'backbone'
	'mediadata'
	'../collections/topics'
	'text!templates/bibliotheque.html'
], ($, _, Backbone, md, TopicsCollection, tplBibliotheque) ->
	'use strict'
	class BibliothequeView extends Backbone.View
		el: '#main'
		collection: null
		template: _.template(tplBibliotheque)
		name: null
		initialize: () ->
			
			@collection = new TopicsCollection('http://api.mediadata.fr/alphabetical-index.php')
			@collection.fetch 
				success: () =>
					@collection = @collection.models[0].attributes

					@render() 
					@bind()
					@onResize()
			
		bind: () ->
			$(window).on('scroll', @stickNavigation).on('resize', @onResize)
			$('nav.alphabet li').on('click', @scrollToLetter)
		unbind: () ->
			$(window).off('scroll', @stickNavigation).off('resize', @onResize)
			$('nav.alphabet li').off('click', @scrollToLetter)

		render: () ->
			document.body.scrollTop = document.documentElement.scrollTop = 0
			ga('send', 'pageview', '/bibliotheque')
			@$el.html(@template(@collection))
			md.Router.hideLoader()		
			return @
		destroy: () ->
			@unbind()

		scrollToLetter: (e) ->
			e.preventDefault()
			console.log($(this).data('letter'))
			$('nav.alphabet li.active').removeClass('active')
			$(this).addClass('active')
			$('html, body').animate({ scrollTop: $('h3[data-letter=' + $(this).data('letter') + ']').offset().top - 70 + 'px' })

		stickNavigation: () ->
			if $(window).scrollTop() > $('header.introduction').outerHeight() then $('nav.alphabet').addClass('fixed')
			else $('nav.alphabet').removeClass('fixed');

			letter = null
			_.each $('h3[data-letter]'), (el) ->
				if $(el).offset().top - 200 < $(window).scrollTop()
					letter = $(el).data('letter')
			if letter 
				$('nav.alphabet li.active').removeClass('active')
				$('li[data-letter=' + letter + ']').addClass('active')
		onResize: () ->
			$('nav.alphabet').width($(window).width() - 80)
