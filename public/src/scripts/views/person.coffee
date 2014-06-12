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
	'../views/modules/bar'
	'../views/modules/x-with-y'
], ($, _, Backbone, md, PersonsCollection, PersonModel, tplPerson, Top5View, TimelineView, ClockView, BarView, XWithYView) ->
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
			md.Router.showLoader()
			@render(options)

		initializeModules: (data) ->
			# console.log('data', data)
			@top5 = new Top5View()
			@timeline = new TimelineView()
			@clock = new ClockView()
			@bar = new BarView()
			@xWithY = new XWithYView()
			
			@renderModules(data)


		bind: () ->
			$(window).on('scroll', @stickFilters)
			$(window).on('resize', @onResize)

		unbind: () ->
			$(window).off('scroll', @stickFilters)
			$(window).off('resize', @onResize)

		destroy: () ->
			@unbind()

		stickFilters: () ->
			if $(window).scrollTop() > $('header.header').outerHeight()  then $('#filters').addClass('fixed')
			else $('#filters').removeClass('fixed');

		render: (options) ->
			ga('send', 'pageview', '/'+ @name)
			md.Status['currentView'] = 'person'
			$('div.loader').removeClass('loading').removeClass('complete')
			$('div.loader.topic1').addClass('loading')
			document.body.scrollTop = document.documentElement.scrollTop = 0

			@collection.fetch
				success: (data) =>
					$('div.loader.topic1').addClass('complete');
					@collection = @collection.models[0].attributes
					@$el.html(@template(@collection))
					md.Router.getFilters()
					@initializeModules(@collection)
					@bind()
					@onResize()
					$('div.loader.topic1').addClass('complete')
					md.Router.hideLoader()
					return @

		renderModules: (data) ->
			@top5.render({ popularChannels: data.popularChannels, popularShows: data.popularShows, totalMentions: data.timelineMentions })
			@timeline.render({ person1: { name: data.person.name, timelineMentions: data.timelineMentions }})
			@clock.render({ broadcastHoursByDay: data.broadcastHoursByDay })
			@bar.render({ channels: data.channels, name: data.person.name })
			@xWithY.render({ persons: data.seenWith })
		
		onResize: () ->
			$('#filters').width($(window).width() - 80)

		rerender: () ->
			md.Router.showLoader()
			@collection = new PersonsCollection(@name)
			@collection.fetch
				success: () =>
					@collection = @collection.models[0].attributes
					@renderModules(@collection)
					md.Router.hideLoader()

		# tweet: () ->
		# 	not (d, s, id) ->
		# 	  js = undefined
		# 	  fjs = d.getElementsByTagName(s)[0]
		# 	  unless d.getElementById(id)
		# 	    js = d.createElement(s)
		# 	    js.id = id
		# 	    js.src = "https://platform.twitter.com/widgets.js"
		# 	    fjs.parentNode.insertBefore js, fjs
		# 	  return
		# 	(document, "script", "twitter-wjs")