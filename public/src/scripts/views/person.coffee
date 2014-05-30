define [
	'jquery'
	'underscore'
	'backbone'
	'mediadata'
	'../collections/persons'
	'../models/person'
	'text!templates/person.html'
	'../views/modules/top-5'
	'../views/modules/timeline'
], ($, _, Backbone, md, PersonsCollection, PersonModel, tplPerson, Top5View, TimelineView) ->
	'use strict'
	class PersonView extends Backbone.View
		el: '#main'
		collection: null
		template: _.template(tplPerson)

		initialize: (options) -> 
			md.Collections[options.name1] = new PersonsCollection(options.name1)
			@render(options)

		initializeModules: (data) ->
			@top5 = new Top5View()
			@timeline = new TimelineView()
			@renderModules(data)

		render: (options) ->
			_this = @
			md.Collections[options.name1].fetch
				success: (data) ->
					console.log(data)
					_this.$el.html(_this.template(md.Collections[options.name1].models[0].attributes))
					_this.initializeModules(md.Collections[options.name1].models[0].attributes)
					return _this
			
		renderModules: (data) ->
			console.log(data)
			@top5.render({ popularChannels: data.popularChannels, popularShows: data.popularShows })
			@timeline.render({ person1: { name: data.person.name, timelineMentions: data.timelineMentions }})
		
		