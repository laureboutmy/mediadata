define [
	'jquery'
	'underscore'
	'backbone'
	'../models/topic'
], ($, _, Backbone, TopicModel) ->
	'use strict'
	class TopicsCollection extends Backbone.Collection
		url: 'http://localhost/mediadata/api/search-example.json'