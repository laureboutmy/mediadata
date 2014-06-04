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
			@collection = new TopicsCollection()
			@collection.fetch 
				success: () =>
					@collection = @collection.models[0].attributes
					console.log(@collection)
					@render() 
			

		render: () ->
			@$el.html(@template(@collection))
					
			return @

		