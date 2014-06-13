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
	'../views/modules/stacked'
], ($, _, Backbone, md, PersonsCollection, PersonModel, tplComparison, Top5View, TimelineView, ClockView, StackedView) ->
	'use strict'
	class ComparisonView extends Backbone.View
		el: '#main'
		collections: {}
		name: {}
		template: _.template(tplComparison)

		initialize: (options) -> 
			md.Router.showLoader()
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
			@stacked = new StackedView()
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
			ga('send', 'pageview', '/'+ @name.person1.slug + '/' + @name.person2.slug)
			$('div.loader').removeClass('loading', 'complete')
			$('div.loader.topic1').addClass('loading')
			document.body.scrollTop = document.documentElement.scrollTop = 0
			@collections.person1.fetch
				success: () =>
					$('div.loader.topic1').addClass('complete')
					$('div.loader.topic2').addClass('loading')
					@collections.person1 = @collections.person1.models[0].attributes
					@collections.person2.fetch
						success: () =>
							$('div.loader.topic2').addClass('complete')
							@collections.person2 = @collections.person2.models[0].attributes
							@$el.html(@template(@collections))
							@initializeModules(@collections)
							md.Router.getFilters()

							@bind()
							@onResize()
							md.Router.hideLoader()
					return @
			
		renderModules: (data) ->
			@top51.render({ popularChannels: data.person1.popularChannels, popularShows: data.person1.popularShows, totalMentions: data.person1.timelineMentions, person: 'person1' })
			@top52.render({ popularChannels: data.person2.popularChannels, popularShows: data.person2.popularShows, totalMentions: data.person2.timelineMentions, person: 'person2' })
			@timeline.render
				person1: { name: data.person1.person.name, timelineMentions: data.person1.timelineMentions }
				person2: { name: data.person2.person.name, timelineMentions: data.person2.timelineMentions }

			@stacked.render(@getStackedData(data))
			# tu devrais pouvoir faire un @stackedChart.render(@getStackData(data))
			@clock1.render({ broadcastHoursByDay: data.person1.broadcastHoursByDay })
			@clock2.render({ broadcastHoursByDay: data.person2.broadcastHoursByDay })


		rerender: () ->
			md.Router.showLoader()
			@collections.person1 = new PersonsCollection(@name.person1)
			@collections.person2 = new PersonsCollection(@name.person2)
			@collections.person1.fetch
				success: () =>
					@collections.person1 = @collections.person1.models[0].attributes
					@collections.person2.fetch
						success: () =>
							@collections.person2 = @collections.person2.models[0].attributes
							@renderModules(@collections)
							md.Router.hideLoader()

		stickFilters: () ->
			if $(window).scrollTop() > $('header.header').outerHeight()  then $('#filters').addClass('fixed')
			else $('#filters').removeClass('fixed')
					
		onResize: () ->
			$('#filters').width($(window).width() - 80)

		getStackedData: (data) ->
			console.log data.person1.channels, data.person2.channels
			
			totalCount1 = 0
			for d,i in data.person1.channels
				totalCount1 += +data.person1.channels[i].channelCount
			totalCount2 = 0
			for d,i in data.person2.channels
				totalCount2 += +data.person2.channels[i].channelCount

			channels =
				names: [data.person1.person.name, data.person2.person.name]
				slugs: [data.person1.person.slug, data.person2.person.slug]
				totalCount: [totalCount1, totalCount2]
				channelMap: [data.person1.person.slug, data.person2.person.slug]
				channelDatas: []
			i = 0
			while i < data.person1.channels.length
			  channels.channelDatas.push({})
			  i++
			_.each data.person1.channels, (channel, i) ->
				channels.channelDatas[i]['channelName'] = channel.channelName
				channels.channelDatas[i]['channelPicture'] = channel.channelPicture
				channels.channelDatas[i][data.person1.person.slug] = channel.channelCount
			_.each data.person2.channels, (channel, i) ->
				channels.channelDatas[i][data.person2.person.slug] = channel.channelCount

			return channels
				
