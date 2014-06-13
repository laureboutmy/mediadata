define [
	'jquery'
	'underscore'
	'backbone'
	'mediadata'
	'text!templates/search.html'
	'../collections/topics'
], ($, _, Backbone, md, tplSearch, TopicsCollection) ->
	'use strict'
	class SearchView extends Backbone.View
		el: '#main'
		collection: null
		template: _.template(tplSearch)
		name: null
		initialize: () ->
			@collection = new TopicsCollection()
			@collection.fetch 
				success: () =>
					@collection = @collection.models[0].attributes
					@render()

		destroy: () ->
		render: () ->
			document.body.scrollTop = document.documentElement.scrollTop = 0
			@$el.html(@template(@collection))
			md.Router.hideLoader()	
			return @

		