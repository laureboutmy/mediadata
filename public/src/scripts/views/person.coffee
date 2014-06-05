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
	'../views/modules/clock'
], ($, _, Backbone, md, PersonsCollection, PersonModel, tplPerson, Top5View, TimelineView, ClockView) ->
	'use strict'
	class PersonView extends Backbone.View
		el: '#main'
		collection: null
		template: _.template(tplPerson)
		name: null
		initialize: (options) -> 
			# console.log(md.Filters)
			# if md.Filters then console.log("yooo")
			@name = options.name1
			@collection = new PersonsCollection(@name)
			md.Status['currentView'] = 'person'
			@render(options)

		initializeModules: (data) ->
			# console.log('data', data)
			@top5 = new Top5View()
			@timeline = new TimelineView()
			@clock = new ClockView()
			@renderModules(data)

		bind: () ->
			_this = @
			$(window).on('scroll', @stickFilters);
			$(window).on('resize', @onResize);

		stickFilters: () ->
			if $(window).scrollTop() > $('header.header').outerHeight()  then $('#filters').addClass('fixed')
			else $('#filters').removeClass('fixed');

		render: (options) ->
			$('div.loader').addClass('loading')
			@collection.fetch
				success: (data) =>
					$('div.loader').addClass('complete');
					@collection = @collection.models[0].attributes
					@$el.html(@template(@collection))
					md.Router.getFilters()
					@initializeModules(@collection)
					@bind()
					@onResize()
					return @

		renderModules: (data) ->
			@top5.render({ popularChannels: data.popularChannels, popularShows: data.popularShows })
			@timeline.render({ person1: { name: data.person.name, timelineMentions: data.timelineMentions }})
			@clock.render({broadcastHoursByDay: data.broadcastHoursByDay, personNumber: 1 })
		
		onResize: () ->
			$('#filters').width($(window).width() - 80)

		rerender: () ->
			@collection = new PersonsCollection(@name)
			@collection.fetch
				success: () =>
					@collection = @collection.models[0].attributes
					@renderModules(@collection)

		