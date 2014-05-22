define [
	'jquery'
	'underscore'
	'backbone'
	'../collections/persons'
	'../models/person'
	'text!templates/person.html'
], ($, _, Backbone, PersonsCollection, PersonModel, tplPerson) ->
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

		render: () ->
			_this = @
			@collection.fetch
				success: () ->
					_this.$el.html(_this.template(_this.collection.models[0].attributes))
					return _this
			
		
		