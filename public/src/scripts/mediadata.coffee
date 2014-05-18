define ['backbone'], (Backbone) ->
	'use strict'
	MD = 
		Models: {}
		Views: {}
		Collections: {}
		Router: {}
		Status: {}
		initialize: () ->
			require ['routers/router'], (Router) ->
				MD.Router = new Router()
