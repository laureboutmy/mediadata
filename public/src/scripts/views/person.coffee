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

		initialize: (options) -> 
			@collection = new PersonsCollection(options.name1)
			@render(options)

		machin: (options) ->
			console.log('fetching', options)

		initializeModules: (data) ->
			console.log('data', data)
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
			_this = @
			console.log(md.Router)
			# md.Router.resetLoader();
			# md.Router.load();
			# $('div.loader').removeClass('loading', 'complete')
			$('div.loader').addClass('loading')

			@collection.fetch
				success: (data) ->
					$('div.loader').addClass('complete');
					_this.$el.html(_this.template(_this.collection.models[0].attributes))
					md.Router.getFilters()
					_this.initializeModules(_this.collection.models[0].attributes)
					_this.bind()
					_this.onResize()
					return _this

		renderModules: (data) ->
			console.log(data)
			@top5.render({ popularChannels: data.popularChannels, popularShows: data.popularShows })
			@timeline.render({ person1: { name: data.person.name, timelineMentions: data.timelineMentions }})
			@clock.render({broadcastHoursByDay: data.broadcastHoursByDay, personNumber: 1 })
		
		onResize: () ->
			$('#filters').width($(window).width() - 80)
		