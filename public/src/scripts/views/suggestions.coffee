define [
	'jquery'
	'underscore'
	'backbone'
	'mediadata'
	'text!templates/suggestions.html'
], ($, _, Backbone, md, tplSuggestions) ->
	'use strict'
	class SuggestionsView extends Backbone.View
		el: '#main'
		collection: null
		template: _.template(tplSuggestions)
		name: null
		initialize: () -> 
			@render()
		destroy: () ->
		render: () ->
			document.body.scrollTop = document.documentElement.scrollTop = 0
			@$el.html(@template())
			md.Router.hideLoader()	
			return @

		