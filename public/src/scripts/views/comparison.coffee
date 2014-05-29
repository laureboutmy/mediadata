define [
	'jquery'
	'underscore'
	'backbone'
	'../collections/persons'
	'../models/person'
	'text!templates/comparison.html'
	'../views/modules/top-5'
], ($, _, Backbone, PersonsCollection, PersonModel, tplComparison, Top5View) ->
	'use strict'
	class ComparisonView extends Backbone.View
		el: '#main'
		collection: null
		template: _.template(tplComparison)

		initialize: (options) -> 
			# console.log(options)
			# @collection = new PersonsCollection(options)
			# console.log(@collection)
			console.log(options)
			@render()

		initializeModules: () ->
			@top5 = new Top5View()
			@renderModules()

		render: () ->
			console.log('render perosn')
			_this = @
			@collection.fetch
				success: () ->
					_this.$el.html(_this.template(_this.collection.models[0].attributes))
					_this.initializeModules()
					return _this
			
		renderModules: () ->
			@top5.render()

		
		