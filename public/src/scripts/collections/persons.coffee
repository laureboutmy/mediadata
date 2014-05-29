define [
	'jquery'
	'underscore'
	'backbone'
	'../models/person'
], ($, _, Backbone, PersonModel) ->
	'use strict'
	class PersonsCollection extends Backbone.Collection
		# model: PersonModel
		url: 'http://37.187.178.169/mediadata/API.php?slug='
		initialize: (name) ->
			@url = @url + name