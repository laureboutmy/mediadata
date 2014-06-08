define [
	'jquery'
	'underscore'
	'backbone'
	'mediadata'
	'text!templates/about.html'
], ($, _, Backbone, md, tplAbout) ->
	'use strict'
	class AboutView extends Backbone.View
		el: '#main'
		collection: null
		template: _.template(tplAbout)
		name: null
		initialize: () -> 
			@render()
		destroy: () ->
		render: () ->
			
			@$el.html(@template())
			md.Router.hideLoader()
			return @

		