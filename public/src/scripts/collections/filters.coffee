define [
	'jquery'
	'underscore'
	'backbone'
], ($, _, Backbone) ->
	'use strict'
	class FiltersCollection extends Backbone.Collection
		url: 'http://api.mediadata.fr/filters.php'
