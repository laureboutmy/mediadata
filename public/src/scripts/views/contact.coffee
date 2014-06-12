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
			@unbind()
		bind: () ->
			$('#submit').on('click', @send)
		unbind: () ->
			$('#submit').off('click', @send)
		send: (e) ->
			e.preventDefault()
			form = $(this).parent()
			mail = form.find('#mail').val()
			subject = form.find('#subject').val()
			message = form.find('#message').val()
			console.log mail, subject, message
			if mail == '' || subject == '' || message == '' || !/^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/.test(mail) then error = true

			$.ajax 
				type: 'POST'
				url: 'http://laureboutmy.com/mediadata/public/form.php'
				data: { mail: mail, subject: subject, message: message }
				success: (data) ->
					console.log(data, 'send')
		render: () ->
			md.Status['currentView'] = 'contact'
			ga('send', 'pageview', '/contact')
			document.body.scrollTop = document.documentElement.scrollTop = 0
			@$el.html(@template())
			@bind()
			md.Router.hideLoader()
			return @

		