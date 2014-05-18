define ['mediadata', 'text!templates/home.html'], (MD, tplHome) ->
	'use strict'
	homeView = Backbone.View.extend
		el: '#main'
		template: _.template(tplHome)
		initialize: () ->
			@render()
		render: () ->
			@$el.html(@template())
			return @