define [
	'jquery'
	'underscore'
	'backbone'
	'mediadata'
	'../collections/filters'
	'text!templates/filters.html'
	'../vendors/slider-1.9.1.min'
], ($, _, Backbone, md, FiltersCollection, tplFilters) ->
	'use strict'
	class FiltersView extends Backbone.View
		el: '#filters'
		template: _.template(tplFilters)
		collection: null
		monthsDisplayed: []
		monthsAPI: []
		initialize: (options) ->
			@collection = new FiltersCollection() 
			@collection.fetch
				success: () =>
					@collection = @collection.models[0].attributes
					_.each @collection.months, (month) =>
						@monthsDisplayed.push(month.monthDisplayed)
						@monthsAPI.push(month.monthAPI)
						
					# console.log(@monthsDisplayed, @monthsAPI)
					@render()

		bind: () ->
			_this = @
			$('#details, #medias').on('change', {context: _this}, _this.onChange)

		onChange: (evt) ->
			if $(this).attr('name') == 'details' 
				md.Filters['par'] = $(this).val()
			else if $(this).attr('name') == 'medias'
				md.Filters['canal'] = $(this).val()
			evt.data.context.update()

		render: () ->
			@$el.html(@template(@collection))
			@bind()
			if md.Filters.dateMin then from = md.Filters.fromNumber
			if md.Filters.dateMax then to = md.Filters.toNumber
			$('#period').ionRangeSlider
				values: @monthsDisplayed
				type: 'double'
				from: from
				to: to
				hasGrid: false
				hideMinMax: true
				onFinish: (obj) =>
					md.Filters['fromNumber'] = obj.fromNumber
					md.Filters['toNumber'] = obj.toNumber
					md.Filters['dateMin'] = @monthsAPI[obj.fromNumber]
					md.Filters['dateMax'] = @monthsAPI[obj.toNumber]
					@update()

			return @
			
		update: () ->
			md.Views[md.Status.currentView].rerender()


			
