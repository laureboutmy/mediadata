define [
	'jquery'
	'underscore'
	'backbone'
	'mediadata'
	'text!templates/filters.html'
	'../vendors/slider-1.9.1.min'
], ($, _, Backbone, md, tplFilters) ->
	'use strict'
	class FiltersView extends Backbone.View
		el: '#filters'
		template: _.template(tplFilters)

		initialize: (options) -> 
			@render()

		render: () ->

			@$el.html(@template())
			$('#period').ionRangeSlider
				values: [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"],
				type: 'double',
				hasGrid: false,
				hideMinMax: true
      
			return @
				

			
