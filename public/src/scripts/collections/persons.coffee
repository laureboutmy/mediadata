define [
	'jquery'
	'underscore'
	'backbone'
	'mediadata'
	# '../models/person'
], ($, _, Backbone, md) ->
	'use strict'
	class PersonsCollection extends Backbone.Collection
		# model: PersonModel
		url: 'http://api.mediadata.fr/person.php'
		initialize: (name) ->
			@url = @url + '?slug=' + name
			console.log(md.Filters)
			if md.Filters.dateMin then @url = @url + '&datemin=' + md.Filters.dateMin
			if md.Filters.dateMax then @url = @url + '&datemax=' + md.Filters.dateMax
			if md.Filters.canal then @url = @url + '&canal=' + md.Filters.canal
			if md.Filters.par then @url = @url + '&par=' + md.Filters.par
			console.log(@url)

			# http://api.mediadata.fr/person.php?slug=anne-hidalgo&datemin=2000-09&datemax=2010-10&canal=TVH&chaine=France%202&par=1

		# fetch: (options) ->
		# 	@trigger('fetchStart', @, options)
		# 	return Backbone.Collection.prototype.fetch.call(@, options)