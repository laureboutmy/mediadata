define [
	'jquery'
	'underscore'
	'backbone'
	'../models/person'
], ($, _, Backbone, PersonModel) ->
	'use strict'
	class PersonsCollection extends Backbone.Collection
		model: PersonModel
		url: 'http://localhost/mediadata/api/person-example.json'
		initialize: (options) ->
			# console.log(options)
			# this.fetch()