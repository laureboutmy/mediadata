define [
	'jquery'
	'underscore'
	'backbone'
	'text!templates/modules/clock.html'
], ($, _, Backbone, tplClock) ->
	'use strict'
	class ClockView extends Backbone.View
		el: '.module.clock'
		template: _.template(tplClock)
		initialize: () ->

		render: (data) ->
			console.log('CLOCK', data)
			@$el.html(@template())
			return @		


