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
			console.log('INIT SEARCHBAR') 
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

		update: (name, nb) ->
			if nb = 1 
				@topics.topic1 = _.where(md.Collections['topics'], { slug: name })[0]
				el = $('#name-1').parent().parent().find('h1')
				el.find('span.name').html(@topics.topic1.name);
				el.find('span.role').html(@topics.topic1.role);
				el.find('.img img').attr('src', @topics.topic1.picture);
			else 
				@topics.topic2 = _.where(md.Collections['topics'], { slug: name })[0]
				el = $('#name-2').parent().parent().find('h1')
				el.find('span.name').html(@topics.topic2.name);
				el.find('span.role').html(@topics.topic2.role);
				el.find('.img img').attr('src', @topics.topic2.picture);

		compare: () ->
			@$el.addClass('comparison').find('section.person:not(.visible)').addClass('visible').find('form.search').addClass('visible').find('input').focus()

		delete: (evt) ->
			console.log(Backbone.history.fragment)
			if @$el.hasClass('comparison') 
				@$el.removeClass('comparison')
				$(evt.currentTarget).parent().parent().removeClass('visible')
			else 
				@$el.addClass('search')
			$(evt.currentTarget).parent().find('h1').html('Cliquez pour rechercher')

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
			console.log('KEYUP')
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
					@update(selected.data('slug'), 2)
					md.Router.navigate(@topics.topic1.slug + '/' + selected.data('slug'))
					md.Router.getComparison(@topics.topic1.slug, selected.data('slug'))
				else if $(input).has('#name-1')
					@update(selected.data('slug'), 1)
					md.Router.navigate(selected.data('slug') + '/' + @topics.topic2.slug)
					md.Router.getComparison(selected.data('slug'), @topics.topic2.slug)
			else 
				if @$el.hasClass('search') then @$el.removeClass('search')
				@update(selected.data('slug'), $(input).attr('id').substring(5,6))
				md.Router.navigate(selected.data('slug'))
				md.Router.getPerson(selected.data('slug'))

			# $(input).blur()
			@stop()
			@bind()

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

				

			
