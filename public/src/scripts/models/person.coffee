define [
	'jquery'
	'underscore'
	'backbone'
], ($, _, Backbone) ->
	'use strict'
	personModel = Backbone.Model.extend
		# url: 'http://localhost/mediadata/api/person-example.json'
		# defaults: 
		# 	person: {}
		initialize: () ->
			console.log('heeye')
		