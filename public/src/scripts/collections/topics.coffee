define [
	'jquery'
	'underscore'
	'backbone'
	'../models/topic'
], ($, _, Backbone, TopicModel) ->
	'use strict'
	class TopicsCollection extends Backbone.Collection
		url: 'http://api.mediadata.fr/search.php'