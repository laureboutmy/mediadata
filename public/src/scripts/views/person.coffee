define [
	'jquery'
	'underscore'
	'backbone'
	'../collections/persons'
	'../models/person'
	'text!templates/person.html'
	'../views/modules/top-5'
], ($, _, Backbone, PersonsCollection, PersonModel, tplPerson, Top5View) ->
	'use strict'
	class PersonView extends Backbone.View
		el: '#main'
		collection: null
		template: _.template(tplPerson)

		initialize: (options) -> 
			console.log(options)
			@collection = new PersonsCollection(options)
			console.log(@collection)
			@render()

		initializeModules: () ->
			@top5 = new Top5View()
			@renderModules()

		render: () ->
			_this = @
			@collection.fetch
				success: () ->
					_this.$el.html(_this.template(_this.collection.models[0].attributes))
					_this.initializeModules()
					return _this
			
		renderModules: () ->
			@top5.render()

		
		