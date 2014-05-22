define [
	'jquery'
	'underscore'
	'backbone'
	'text!templates/search-bar.html'
], ($, _, Backbone, tplSearchbar) ->
	'use strict'
	class SearchbarView extends Backbone.View
		el: '#search-bar'
		collection: null
		template: _.template(tplSearchbar)

		initialize: () -> 
			# @render()

		render: () ->
			@$el.html(@template())
			@bind()
			return @

		events: 
			'click .compare': 'compare'
			'click h1.person button.edit': 'edit'
			'blur form.search input': 'stopEditing'
			'click .delete': 'delete'

		bind: () ->
			_this = @
			$(window).on('resize', _this.onResize)

		compare: (evt) ->
			$(evt.target).removeClass('visible')
			$('h1.other-person').addClass('visible').find('form.search').addClass('visible').find('input').focus();
			$('h1.person').addClass('half');

		delete: (evt) ->
			console.log(evt);
			$(evt.currentTarget).parent().removeClass('visible');
			if !$(evt.currentTarget).parent().hasClass('other-person')
				$('h1.other-person').removeClass('other-person')
				$(evt.currentTarget).parent().addClass('other-person')
         
			$('h1.person').removeClass('half')
			$('button.compare').addClass('visible')

		edit: (evt) ->
			$(evt.target).parent().find('form.search').addClass('visible').find('input').focus()

			$(this).parent().find('form.search').addClass('visible').find('input').focus();

		stopEditing: (evt) ->
			$(evt.target).parent().removeClass('visible');
		
		onResize: () ->
			$('#search-bar').width($(window).width() - 250)