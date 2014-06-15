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
			@updateTexts()
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

		updateTexts: () ->
			# console.log(md.Filters)
			if md.Filters['par']
				if md.Filters['par'] is '1'
					$('h2.evolution').text('Chronologie des participations')
					$('p.top-emissions').text("Découvrez les 5 émissions auxquelles " + this.collection.person.name + " a le plus participé. Rediffusions comptabilisées. En cas d'émissions diffusées sur plusieurs chaînes, le logo de la chaîne d'origine s'affiche.")
					$('h2.horaires').text("Participations horaires et journalières")
					$('p.top-chaines').text("Quelles chaînes font le plus participer " + this.collection.person.name + " ? Survolez chaque barre pour afficher le nombre de participations par chaîne ou station.")
					$('p.horaires').text("Quand sont diffusés les programmes auxquels " + this.collection.person.name + " participe ? Survolez les barres circulaires pour découvrir la répartition horaire et utilisez les barres verticales pour explorer la répartition journalière.")
					$('p.avec').text("Découvrez les cinq personnes qui participent le plus souvent aux mêmes programmes que " + this.collection.person.name + ".")
					if @collection.person.gender is 'f'
						$('h2.avec').text("Elle participe aux mêmes émissions que...")
					else if @collection.person.gender is 'm'
						$('h2.avec').text("Il participe aux mêmes émissions que...")

				else if md.Filters['par'] is '0'
					$('h2.evolution').text('Chronologie des mentions')
					$('p.top-emissions').text("Découvrez les 5 émissions qui ont le plus parlé de " + @collection.person.name + ". Rediffusions comptabilisées. En cas d'émissions diffusées sur plusieurs chaînes, le logo de la chaîne d'origine s'affiche.")
					$('h2.horaires').text("Mentions horaires et journalières")
					$('p.top-chaines').text("Quelles chaînes parlent le plus de " + @collection.person.name + " ? Survolez chaque barre pour afficher le nombre de mentions par chaîne ou station.")
					$('p.horaires').text("Quand parle-t-on le plus ou le moins de " + @collection.person.name + " ? Survolez les barres circulaires pour découvrir la répartition horaire. Utilisez les barres verticales pour explorer la répartition journalière.")
					$('p.avec').text("Découvrez les cinq personnes les plus souvent mentionnées dans les mêmes programmes que " + @collection.person.name + ".")
					if @collection.person.gender is 'f'
						$('h2.avec').text("On parle souvent d'elle avec...")
					else if @collection.person.gender is 'm'
						$('h2.avec').text("On parle souvent de lui avec...")

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
