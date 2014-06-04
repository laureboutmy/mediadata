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

		render: () ->
			@$el.html(@template())
					
			return @

		