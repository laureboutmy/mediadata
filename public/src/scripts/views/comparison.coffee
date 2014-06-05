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
		collections: {}
		name: {}
		template: _.template(tplComparison)

		initialize: (options) -> 
			@name.person1 = options.name1
			@name.person2 = options.name2
			@collections.person1 = new PersonsCollection(@name.person1)
			@collections.person2 = new PersonsCollection(@name.person2)
			
			@render(options)
			

		initializeModules: (data) ->
			@top51 = new Top5View({el: '.module.top-5.person1'})
			@top52 = new Top5View({el: '.module.top-5.person2'})
			@timeline = new TimelineView()
			@clock1 = new ClockView({el: '.module.clock.person1'})
			@clock2 = new ClockView({el: '.module.clock.person2'})
			@xWithY = new XWithYView({el: '.module.x-with-y'})
			@renderModules(data)

		bind: () ->
			$(window).on('scroll', @stickFilters)
			$(window).on('resize', @onResize)

		unbind: () ->
			$(window).off('scroll', @stickFilters)
			$(window).off('resize', @onResize)

		destroy: () ->
			@unbind()

		render: (options) ->
			md.Status['currentView'] = 'comparison'
			@collections.person1.fetch
				success: () =>
					@collections.person1 = @collections.person1.models[0].attributes
					@collections.person2.fetch
						success: () =>
							@collections.person2 = @collections.person2.models[0].attributes
							md.Router.getFilters()
							@$el.html(@template(@collections))
							@initializeModules(@collections)
							@bind()
							@onResize()
					return @
			
		renderModules: (data) ->
			@top51.render({ popularChannels: data.person1.popularChannels, popularShows: data.person1.popularShows })
			@top52.render({ popularChannels: data.person2.popularChannels, popularShows: data.person2.popularShows })
			@timeline.render
				person1: { name: data.person1.person.name, timelineMentions: data.person1.person.timelineMentions }
				person2: { name: data.person2.person.name, timelineMentions: data.person2.person.timelineMentions }

			@getStackedData(data)
			# tu devrais pouvoir faire un @stackedChart.render(@getStackData(data))
			@clock1.render({ broadcastHoursByDay: data.person1.broadcastHoursByDay })
			@clock2.render({ broadcastHoursByDay: data.person2.broadcastHoursByDay })


		rerender: () ->
			@collections.person1 = new PersonsCollection(@name.person1)
			@collections.person2 = new PersonsCollection(@name.person2)
			@collections.person1.fetch
				success: () =>
					@collections.person1 = @collections.person1.models[0].attributes
					@collections.person2.fetch
						success: () =>
							@collections.person2 = @collections.person2.models[0].attributes
							@renderModules(@collections)

		stickFilters: () ->
			if $(window).scrollTop() > $('header.header').outerHeight()  then $('#filters').addClass('fixed')
			else $('#filters').removeClass('fixed')
					
		onResize: () ->
			$('#filters').width($(window).width() - 80)

		getStackedData: (data) ->
			channels = 
				channelMap: [data.person1.person.name, data.person2.person.name]
				channelDatas: []
			i = 0
			while i < data.person1.channels.length
			  channels.channelDatas.push({})
			  i++
			_.each data.person1.channels, (channel, i) ->
				channels.channelDatas[i]['channelName'] = channel.channelName
				channels.channelDatas[i]['person1'] = channel.channelCount
			_.each data.person2.channels, (channel, i) ->
				channels.channelDatas[i]['person2'] = channel.channelCount

			return channels
				
