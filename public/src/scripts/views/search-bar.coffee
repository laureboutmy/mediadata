define [
	'jquery'
	'underscore'
	'backbone'
	'mediadata'
	'../collections/topics'
	'../models/topic'
	'text!templates/search-bar.html'
], ($, _, Backbone, md, TopicsCollection, TopicModel, tplSearchbar) ->
	'use strict'
	class SearchbarView extends Backbone.View
		el: '#search-bar'
		collection: null
		template: _.template(tplSearchbar)

		initialize: (options) -> 
			md.Collections['topics'] = new TopicsCollection()
			md.Collections['topics'].fetch 
				success: () =>
					md.Collections['topics'] = md.Collections['topics'].models[0].attributes.results
					@render(options)
					@bind()


		topics:
			topic1: null
			topic2: null

		inputs: 'form.search input'
		currentText: null
		render: (options) ->
			if options.name1
				@topics.topic1 = _.where(md.Collections['topics'], { slug: options.name1 })[0]
			if options.name2
				@topics.topic2 = _.where(md.Collections['topics'], { slug: options.name2 })[0]

			@$el.html(@template(@topics))
			if @topics.topic1 && @topics.topic2 then @$el.addClass('comparison').find('section.person').addClass('visible')
			return @


		events: 
			'click .compare': 'compare'
			'click .delete': 'delete'
			'click ul.topics li': 'submit'
			'click div.name button.edit': 'edit'

		bind: () ->
			_this = @
			$(_this.inputs).on('keyup', {context: this}, _this.keyup)
			$(_this.inputs).on('keydown', {context: this}, _this.keydown)
			$(_this.inputs).on('blur', {context: this}, _this.stop)


		compare: () ->
			@$el.addClass('comparison').find('section.person:not(.visible)').addClass('visible').find('form.search').addClass('visible').find('input').focus()

		delete: (evt) ->
			console.log(Backbone.history.fragment)
			if @$el.hasClass('comparison') 
				@$el.removeClass('comparison')
				$(evt.currentTarget).parent().find('h1').html('Vous devez choisir une sujet')
				$(evt.currentTarget).parent().parent().removeClass('visible')
			else 
				@$el.addClass('search')

		edit: (evt) ->
			$(evt.currentTarget).parent().find('form.search').addClass('visible').find('input').focus()

		stop: (evt) ->
			if evt then evt.data.context.$el.find('form.search.visible').removeClass('visible')
			else @$el.find('form.search.visible').removeClass('visible')
		
		onResize: () ->
			# $('#search-bar').width($(window).width() - 250)

		hasChanged: (keyword) ->
			@currentText != keyword

		keyup: (evt) ->
			_this = evt.data.context
			keyword = $(this).val()
			if _this.hasChanged(keyword) && keyword.length != 0
				_this.currentText = keyword
				_this.renderResults($(this), _this.filter(keyword))

		keydown: (evt) ->
			_this = evt.data.context;
			if evt.keyCode is 38 then _this.move(-1, this)
			if evt.keyCode is 40 then _this.move(+1, this)
			if evt.keyCode is 13 
				evt.preventDefault()
				_this.submit(null, this)
			if evt.keyCode is 27 then _this.hide()

		move: (position, input) ->
			current = $(input).parent().find('ul').children('.active')
			siblings = $(input).parent().find('ul').children()
			index = current.index() + position

			if siblings.eq(index).length 
				current.removeClass('active')
				siblings.eq(index).addClass('active')

		submit: (evt, input) ->
			if evt 
				selected = $(evt.currentTarget)
				input = selected.parent().parent().find('input')
			else
				selected = $(input).parent().find('ul').children('.active')
			
			$(input).parent().parent().find('h1').html(selected.html())

			if @$el.hasClass('comparison')
				if $(input).has('#name-2') 
					md.Router.navigate(@topics.topic1.slug + '/' + selected.data('slug'))
					md.Router.getComparison(@topics.topic1.slug, selected.data('slug'))
				else if $(input).has('#name-1')
					md.Router.navigate(selected.data('slug') + '/' + @topics.topic2.slug)
					md.Router.getComparison(selected.data('slug'), @topics.topic1.slug)
			else
				md.Router.navigate(selected.data('slug'))
				md.Router.getPerson(selected.data('slug'))
			# $(input).blur()

			@stop()

		filter: (keyword) ->
			keyword = keyword
			_.filter md.Collections['topics'], (topic) ->
				topic.name.toLowerCase().substring(0, keyword.length) == keyword
		
		renderResults: (input, results) ->
			ul = input.parent().find('ul').html('')
			_.each results, (result) ->
				el = $('<li>')
					.data('slug', result.slug)
					.append $('<div>').attr('class', 'img').append($('<img>').attr('src', 'images/topic--damien-cornu.jpg')), result.name
				ul.append(el)

				

			
