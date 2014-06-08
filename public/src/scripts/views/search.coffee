define [
	'jquery'
	'underscore'
	'backbone'
	'mediadata'
	'text!templates/search.html'
], ($, _, Backbone, md, tplSearch) ->
	'use strict'
	class SearchView extends Backbone.View
		el: '#main'
		collection: null
		template: _.template(tplSearch)
		name: null
		initialize: () -> 
			@render()
		destroy: () ->
		render: () ->
			document.body.scrollTop = document.documentElement.scrollTop = 0
			@$el.html(@template())
			md.Router.hideLoader()	
			return @

		