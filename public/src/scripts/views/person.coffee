define [
	'jquery'
	'underscore'
	'backbone'
	'mediadata'
	'../collections/persons'
	'../models/person'
	'text!templates/person.html'
	'../views/modules/top-5'
], ($, _, Backbone, md, PersonsCollection, PersonModel, tplPerson, Top5View) ->
	'use strict'
	class PersonView extends Backbone.View
		el: '#main'
		collection: null
		template: _.template(tplPerson)

		initialize: (options) -> 
			console.log(options)
			md.Collections[options.name1] = new PersonsCollection(options.name1)
			# console.log(@collection)
			@render(options)

		initializeModules: () ->
			@top5 = new Top5View()
			@renderModules()

		render: (options) ->
			console.log('render person')
			_this = @
			md.Collections[options.name1].fetch
				success: () ->
					_this.$el.html(_this.template(md.Collections[options.name1].models[0].attributes))
					_this.initializeModules()
					return _this
				error: (error) ->
					console.log('yoyo', error)
			
		renderModules: () ->
			@top5.render()

		
		