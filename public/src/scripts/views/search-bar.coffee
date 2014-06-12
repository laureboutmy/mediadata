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
		topics:
			topic1: null
			topic2: null
		inputs: 'form.search input'
		currentText: null

		initialize: (options) ->
			console.log(options)
			@collection = new TopicsCollection()
			@collection.fetch 
				success: () =>
					@collection = @collection.models[0].attributes.searchResults
					@render(options)
					# @bind()
		
		render: (options) ->
			if options.name1
				@topics.topic1 = _.where(@collection, { slug: options.name1 })[0]
			if options.name2
				@topics.topic2 = _.where(@collection, { slug: options.name2 })[0]
			if options.name1 && !options.name2 then @topics.topic2 = null
			if options.name2 && !options.name1 then @topics.topic1 = null
			if !options.name2 && !options.name1 
				@topics.topic1 = null
				@topics.topic2 = null
			if options.isSearch then @topics['isSearch'] = true
			else @topics['isSearch'] = false

			@$el.html(@template(@topics))

			# render Sidebar if comparison or search
			if @topics.topic1 && @topics.topic2 then @$el.addClass('comparison').find('section.person').addClass('visible')
			else if @topics['isSearch'] then @$el.removeClass('comparison').addClass('search')
			else 
				@$el.removeClass('search')
				@$el.removeClass('comparison')
			@bind()
			# @$el.addClass('visible')
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
			# $(_this.inputs).on('blur', {context: this}, _this.stop)

		# update name, picture in search-bar
		update: (name, nb) ->
			@topics['topic' + nb] = _.where(@collection, { slug: name })[0]
			el = $('#name' + nb).parent().parent().find('h1')

			el.find('span.name').html(@topics['topic' + nb].name);
			el.find('span.role').html(@topics['topic' + nb].role);
			el.find('.img img').attr('src', @topics['topic' + nb].picture);
			

		# on click on "compare"
		compare: () ->
			@$el.addClass('comparison').find('section.person:not(.visible)').addClass('visible').find('form.search').addClass('visible').find('input').focus()

		# on click on "x"
		delete: (evt) ->
			if @$el.hasClass('comparison') 
				@$el.removeClass('comparison')
				$(evt.currentTarget).parent().parent().removeClass('visible')
				slug = $(evt.currentTarget).parent().parent().data('slug')
				slug = (Backbone.history.fragment).replace(slug, '').replace('/', '')
				md.Router.getPerson(slug)
				md.Router.navigate(slug)
			else 
				@$el.addClass('search')
				md.Router.getSearch()
				md.Router.navigate('rechercher')

			$(evt.currentTarget).parent().find('h1').html('Cliquez pour rechercher')

		edit: (evt) ->
			$(evt.currentTarget).parent().find('form.search').addClass('visible').find('input').focus()

		stop: (evt) ->
			if evt then evt.data.context.$el.find('form.search.visible').removeClass('visible')
			else @$el.find('form.search.visible').removeClass('visible')

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
				evt.stopPropagation()
				selected = $(evt.currentTarget)
				input = selected.parent().parent().find('input')
			else
				selected = $(input).parent().find('ul').children('.active')
			
			$(input).parent().parent().find('h1').html(selected.html())

			if @$el.hasClass('comparison')

				if $(input).attr('id') is 'name-2'
					@update(selected.data('slug'), 2)
					md.Router.navigate(@topics.topic1.slug + '/' + selected.data('slug'))
					md.Router.getComparison(@topics.topic1.slug, selected.data('slug'))
				else if $(input).attr('id') is 'name-1'
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

		navigate: () ->


		filter: (keyword) ->
			keyword = keyword.toLowerCase()
			_.filter @collection, (topic) ->
				topic.name.toLowerCase().substring(0, keyword.length) == keyword
		
		renderResults: (input, results) ->
			ul = input.parent().find('ul').html('')
			_.each results, (result) ->
				el = $('<li>')
					.data('slug', result.slug)
					.append $('<div>').attr('class', 'img').append($('<img>').attr('src', result.picture)), result.name
				ul.append(el)

				

			
