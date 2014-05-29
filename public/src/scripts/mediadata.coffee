define [
	'jquery' 
	'underscore'
	'backbone'
], ($, _, Backbone) ->
	'use strict'
	md = 
		Router: null,
		Views: {},
		Models: {},
		Collections: {},
		initialize: () ->
			require ['routers/router'], (Router) =>
				@Router = new Router()
				Backbone.history.start
					pushState: true
					root: '/mediadata/public/'

	# initialize = () ->
	# 	# Router = new Router()
	# 	Backbone.history.start
	# 		pushState: true
	# 		root: '/mediadata/public/'
	# return {
	# 	Views: {}
	# 	Models: {}
	# 	Collections: {}
	# 	Router: 
	# 	initialize: initialize 
	# }
