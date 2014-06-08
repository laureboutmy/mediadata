define [
	'jquery'
	'underscore'
	'backbone'
	'mediadata'
	'../collections/topics'
	'text!templates/index.html'
], ($, _, Backbone, md, TopicsCollection, tplIndex) ->
	'use strict'
	class IndexView extends Backbone.View
		el: '#main'
		collection: null
		template: _.template(tplIndex)
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
		unbind: () ->
			$(window).off('scroll', @stickNavigation).off('resize', @onResize)
		render: () ->
			document.body.scrollTop = document.documentElement.scrollTop = 0

			@$el.html(@template(@collection))
			md.Router.hideLoader()		
			return @
		destroy: () ->
			@unbind()
		stickNavigation: () ->
			if $(window).scrollTop() > $('header.introduction').outerHeight() then $('nav.alphabet').addClass('fixed')
			else $('nav.alphabet').removeClass('fixed');

		onResize: () ->
			$('nav.alphabet').width($(window).width() - 80)
