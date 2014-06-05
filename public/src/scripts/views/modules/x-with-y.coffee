define [
	'jquery'
	'underscore'
	'backbone'
	'text!templates/modules/x-with-y.html'
], ($, _, Backbone, tplXWithY) ->
	'use strict'
	class XWithYView extends Backbone.View
		el: '.module.x-with-y'
		template: _.template(tplXWithY)

		render: (data) ->
			@$el.html(@template(data))
			return @