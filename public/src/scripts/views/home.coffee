define [
	'jquery'
	'underscore'
	'backbone'
	'text!templates/home.html'
], ($, _, Backbone, tplHome) ->
	'use strict'
	HomeView = Backbone.View.extend
		el: '#main'
		template: _.template(tplHome)
		initialize: () ->
			@render()
		render: () ->
			@$el.html(@template())
			return @