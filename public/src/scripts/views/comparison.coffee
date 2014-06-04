define [
	'jquery'
	'underscore'
	'backbone'
	'mediadata'
	'../collections/persons'
	'../models/person'
	'text!templates/comparison.html'
	'../views/modules/top-5'
	'../views/modules/timeline'
	'../views/modules/clock'
], ($, _, Backbone, md, PersonsCollection, PersonModel, tplComparison, Top5View, TimelineView, ClockView) ->
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
			# console.log(data)
			@top51 = new Top5View({el: '.module.top-5.person1'})
			@top52 = new Top5View({el: '.module.top-5.person2'})
			@timeline = new TimelineView()
			@clock1 = new ClockView({el: '.module.clock.person1'})
			@clock2 = new ClockView({el: '.module.clock.person2'})
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
			@timeline.render({ 
				person1: { name: data.person1.person.name, timelineMentions: data.person1.person.timelineMentions }
				person2: { name: data.person2.person.name, timelineMentions: data.person2.person.timelineMentions }
				})
			@clock1.render({ broadcastHoursByDay: data.person1.broadcastHoursByDay, personNumber: 1 })
			@clock2.render({ broadcastHoursByDay: data.person2.broadcastHoursByDay, personNumber: 2 })
