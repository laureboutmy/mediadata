define [
	'jquery'
	'underscore'
	'backbone'
	'../models/topic'
], ($, _, Backbone, TopicModel) ->
	'use strict'
	class TopicsCollection extends Backbone.Collection
		model: TopicModel
		url: 'http://localhost/mediadata/api/search-example.json'
		initialize: () ->
			console.log 'ckeorie'