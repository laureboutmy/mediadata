define [
	'jquery'
	'underscore'
	'backbone'
	'../collections/topics'
	'../models/topic'
	'text!templates/search-bar.html'
], ($, _, Backbone, TopicsCollection, TopicModel, tplSearchbar) ->
	'use strict'
	class SearchbarView extends Backbone.View
		el: '#search-bar'
		collection: null
		template: _.template(tplSearchbar)

		initialize: (options) -> 
			# console.log(options);
			# @render()
			@collection = new TopicsCollection()


		data:
			topic1: null
			topic2: null

		render: (options) ->
			_this = @

			console.log('hey', options)
			@collection.fetch
				success: () ->
					_this.collection = _this.collection.models[0].attributes.results
					_this.data.topic1 = _.where(_this.collection, {slug: 'segolene-royal'})[0]
					# if options.comparison then 
					console.log(_this.data)
					_this.$el.html(_this.template(_this.data))
					_this.bind()
			return @

		inputs: 'form.search input'

		events: 
			'click .compare': 'compare'
			'click div.name button.edit': 'edit'
			'blur form.search input': 'stopEditing'
			'click .delete': 'delete'
			# 'change form.search input': 'onChange'
		bind: () ->
			_this = @
			# $(window).on('resize', _this.onResize)
			$(_this.inputs).on('keyup', {context: this}, _this.keyup)
			$(_this.inputs).on('keydown', {context: this}, _this.keydown)

		compare: (evt) ->
			# $(evt.target).removeClass('visible')
			# $('h1.other-person').addClass('visible').find('form.search').addClass('visible').find('input').focus();
			# $('h1.person').addClass('half');
			# console.log('hehehe');
			@$el.addClass('comparison').find('section.person').addClass('visible');

		delete: (evt) ->
			if @$el.hasClass('comparison') 
				@$el.removeClass('comparison');
				$(evt.currentTarget).parent().parent().removeClass('visible');
			else 
				@$el.addClass('search');

		edit: (evt) ->
			$(evt.target).parent().find('form.search').addClass('visible').find('input').focus()
			$(this).parent().find('form.search').addClass('visible').find('input').focus();

		stopEditing: (evt) ->
			# $(evt.currentTarget).parent().removeClass('visible');
		
		onResize: () ->
			# $('#search-bar').width($(window).width() - 250)

		currentText: null
		hasChanged: (keyword) ->
			@current != keyword

		keyup: (evt) ->
			_this = evt.data.context
			keyword = $(this).val()
			console.log(_this.collection)
			if _this.hasChanged(keyword)
				_this.currentText = keyword
				_this.filter(keyword)

		keydown: (evt) ->
			_this = evt.data.context;
			if evt.keyCode is 38 then _this.move(-1, this)
			if evt.keyCode is 40 then _this.move(+1, this)
			if evt.keyCode is 13 
				evt.preventDefault()
				_this.submit(this)
			if evt.keyCode is 27 then _this.hide()

		

		move: (position, input) ->
			current = $(input).parent().find('ul').children('.active')
			siblings = $(input).parent().find('ul').children()
			index = current.index() + position

			if siblings.eq(index).length 
				current.removeClass('active')
				siblings.eq(index).addClass('active')

		submit: (input) ->
			console.log(input)
			selected = $(input).parent().find('ul').children('.active')
			console.log(selected.data('slug'));
			$(input).parent().parent().find('h1').html(selected.html())

		filter: (keyword) ->
			keyword = keyword.toLowerCase()

