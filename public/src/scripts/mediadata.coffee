define [
	'jquery' 
	'underscore'
	'backbone'
	'routers/router'
], ($, _, Backbone, Router) ->
	'use strict'
	initialize = () ->
		Router = new Router()
		Backbone.history.start
			pushState: true
			root: '/mediadata/public/'

	return { initialize: initialize }