define ['mediadata', 'text!templates/explorer.html'], (MD, tplExplorer) ->
	'use strict'
	explorerView = Backbone.View.extend
		el: '#main'
		template: _.template(tplExplorer)
		initialize: () ->
			@render()
		render: () ->
			@$el.html(@template())
			return @