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
		bool: false
		initialize: (options) ->
			console.log('yohoho')
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

			@$el.find('#search').html(@template(@topics))

			# render Sidebar if comparison or search
			if @topics.topic1 && @topics.topic2 then @$el.addClass('comparison').find('section.person').addClass('visible')
			else if @topics['isSearch'] then @$el.removeClass('comparison').addClass('search')
			else 
				@$el.removeClass('search')
				@$el.removeClass('comparison')

			# if !@bool 
			@bind()
				# @bool = !@bool
			# @$el.addClass('visible')
			return @

		# events: 
			# 'click .compare': 'compare'
			# 'click .delete': 'delete'
			'click ul.topics li': 'submit'
			# 'click div.name button.edit': 'edit'

		bind: () ->
			_this = @
			$('.compare').on('click', {context: @}, @compare)
			$('.delete').on('click', {context: @}, @delete)
			$(window).on('click', {context: this}, _this.stop)
			$('div.name button.edit').on('click', @edit)
			$(_this.inputs).on('keyup', {context: @}, @keyup)
			$(_this.inputs).on('keydown', {context: @}, @keydown)
			$('ul.topics').on('click', 'li', {context: @}, @submit)
		


		# update name, picture in search-bar
		update: (name, nb) ->
			@topics['topic' + nb] = _.where(@collection, { slug: name })[0]
			el = $('#name' + nb).parent().parent().find('h1')
			# console.log(@topics['topic' + nb])
			el.find('span.name').html(@topics['topic' + nb].name);
			el.find('span.role').html(@topics['topic' + nb].role);
			el.find('.img img').attr('src', @topics['topic' + nb].picture);
			

		# on click on "compare"
		compare: (evt) ->
			evt.stopPropagation()
			evt.data.context.$el.addClass('comparison').find('section.person:not(.visible)').addClass('visible').find('form.search').addClass('visible').find('input').focus()

		# on click on "x"
		delete: (evt) ->
			evt.stopPropagation()
			btn = $(this)
			ctxt = evt.data.context
			if ctxt.$el.hasClass('comparison')
				ctxt.$el.removeClass('comparison')
				btn.parent().parent().removeClass('visible')
				slug = btn.parent().parent().data('slug')
				slug = (Backbone.history.fragment).replace(slug, '').replace('/', '')
				md.Router.getPerson(slug)
				md.Router.navigate(slug)
			else 
				ctxt.$el.addClass('search')
				md.Router.getSearch()
				md.Router.navigate('rechercher')
			btn.parent().find('h1').html('Cliquez pour rechercher')

			# if @$el.hasClass('comparison') 
			# 	@$el.removeClass('comparison')
			# 	$(evt.currentTarget).parent().parent().removeClass('visible')
			# 	slug = $(evt.currentTarget).parent().parent().data('slug')
			# 	slug = (Backbone.history.fragment).replace(slug, '').replace('/', '')
			# 	md.Router.getPerson(slug)
			# 	md.Router.navigate(slug)
			# else 
			# 	@$el.addClass('search')
			# 	md.Router.getSearch()
			# 	md.Router.navigate('rechercher')

			# $(evt.currentTarget).parent().find('h1').html('Cliquez pour rechercher')

		edit: (evt) ->
			evt.stopPropagation()
			$(this).parent().find('form.search').addClass('visible').find('input').focus()

		stop: (evt) ->
			console.log(evt)
			if evt 
				evt.data.context.$el.find('form.search.visible').removeClass('visible')
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
				_this.submit(null, this, _this)
			if evt.keyCode is 27 then _this.hide()

		move: (position, input) ->
			current = $(input).parent().find('ul').children('.active')
			siblings = $(input).parent().find('ul').children()
			index = current.index() + position

			if siblings.eq(index).length 
				current.removeClass('active')
				siblings.eq(index).addClass('active')

		submit: (evt, input = null, ctxt = null) ->
			if evt 
				# evt.stopPropagation()
				selected = $(this)
				ctxt = evt.data.context

				input = selected.parent().parent().find('input')
			else
				selected = $(input).parent().find('ul').children('.active')
			
			$(input).parent().parent().find('h1').html(selected.html())
			# console.log(selected, selected.data('slug'))
			if ctxt.$el.hasClass('comparison')

				if $(input).attr('id') is 'name-2'
					ctxt.update(selected.data('slug'), 2)
					md.Router.navigate(ctxt.topics.topic1.slug + '/' + selected.data('slug'))
					md.Router.getComparison(ctxt.topics.topic1.slug, selected.data('slug'))
				else if $(input).attr('id') is 'name-1'
					ctxt.update(selected.data('slug'), 1)
					md.Router.navigate(selected.data('slug') + '/' + ctxt.topics.topic2.slug)
					md.Router.getComparison(selected.data('slug'), ctxt.topics.topic2.slug)
			else 
				if ctxt.$el.hasClass('search') then ctxt.$el.removeClass('search')
				ctxt.update(selected.data('slug'), $(input).attr('id').substring(5,6))
				md.Router.navigate(selected.data('slug'))
				md.Router.getPerson(selected.data('slug'))

			# $(input).blur()
			ctxt.stop()
			# ctxt.bind()

		navigate: () ->


		filter: (keyword) ->
			keyword = keyword.toLowerCase()
			_.filter @collection, (topic) ->
				if topic.lastName.toLowerCase().substring(0, keyword.length) == keyword then return true
				else if topic.firstName.toLowerCase().substring(0, keyword.length) == keyword then return true
		
		renderResults: (input, results) ->
			ul = input.parent().find('ul').html('')
			_.each results, (result) ->
				el = $('<li>')
					.data('slug', result.slug)
					.append $('<div>').attr('class', 'img').append($('<img>').attr('src', result.picture)), result.name
				ul.append(el)

				

			
