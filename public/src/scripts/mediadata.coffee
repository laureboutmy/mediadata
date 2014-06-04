define [
	'jquery' 
	'underscore'
	'backbone'
], ($, _, Backbone) ->
	'use strict'
	md = 
		Router: null
		Views: {}
		Models: {}
		Collections: {}
		# Filters: { canal: "TVH", dateMax: "2009-10", dateMin: "1999-02", fromNumber: 61, par: "1", toNumber: 189 }
		Filters: {}
		Status: {}
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
