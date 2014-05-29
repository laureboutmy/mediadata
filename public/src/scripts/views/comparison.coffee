define [
	'jquery'
	'underscore'
	'backbone'
	'mediadata'
	'../collections/persons'
	'../models/person'
	'text!templates/comparison.html'
	'../views/modules/top-5'
], ($, _, Backbone, md, PersonsCollection, PersonModel, tplComparison, Top5View) ->
	'use strict'
	class ComparisonView extends Backbone.View
		el: '#main'
		collection: null
		template: _.template(tplComparison)

		initialize: (options) -> 
			md.Collections[options.name1] = new PersonsCollection(options.name1)
			md.Collections[options.name2] = new PersonsCollection(options.name2)
			@render(options)

		initializeModules: (data) ->
			console.log(data)
			@top51 = new Top5View({el: '.module.top-5.person1'})
			@top52 = new Top5View({el: '.module.top-5.person2'})
			@renderModules(data)

		render: (options) ->
			_this = @
			_this.collection = {}
			md.Collections[options.name1].fetch
				success: () ->
					_this.collection.person1 = md.Collections[options.name1].models[0].attributes
					md.Collections[options.name2].fetch
						success: () ->
							_this.collection.person2 = md.Collections[options.name2].models[0].attributes
							_this.$el.html(_this.template(_this.collection))
							_this.initializeModules(_this.collection)
					return _this
			
		renderModules: (data) ->
			@top51.render({ popularChannels: data.person1.popularChannels, popularShows: data.person1.popularShows })
			@top52.render({ popularChannels: data.person2.popularChannels, popularShows: data.person2.popularShows })


		
		