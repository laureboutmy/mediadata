define [
	'jquery'
	'underscore'
	'backbone'
	'mediadata'
	'text!templates/home.html'
], ($, _, Backbone, md, tplHome) ->
	'use strict'
	HomeView = Backbone.View.extend
		el: '#main'
		template: _.template(tplHome)
		initialize: () ->
			
			@render()
		render: () ->
			document.body.scrollTop = document.documentElement.scrollTop = 0
			@$el.html(@template())
			md.Router.hideLoader()
			return @