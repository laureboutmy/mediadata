define [
	'jquery'
	'underscore'
	'backbone'
	'mediadata'
	'text!templates/contact.html'
], ($, _, Backbone, md, tplContact) ->
	'use strict'
	class ContactView extends Backbone.View
		el: '#main'
		collection: null
		template: _.template(tplContact)
		name: null
		initialize: () -> 
			@render()
		destroy: () ->
			
		render: () ->
			md.Status['currentView'] = 'contact'
			ga('send', 'pageview', '/contact')
			document.body.scrollTop = document.documentElement.scrollTop = 0
			@$el.html(@template())
			md.Router.hideLoader()	
			return @

		