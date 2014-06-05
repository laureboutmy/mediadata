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
			@$el.html(@template())
					
			return @

		