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
			document.body.scrollTop = document.documentElement.scrollTop = 0
			ga('send', 'pageview', '/a-propos')
			@$el.html(@template())
			md.Router.hideLoader()
			return @

		