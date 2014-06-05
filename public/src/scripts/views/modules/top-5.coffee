define [
	'jquery'
	'underscore'
	'backbone'
	'text!templates/modules/top-5.html'
], ($, _, Backbone, tplTop5) ->
	'use strict'
	class Top5View extends Backbone.View
		el: '.module.top-5'
		template: _.template(tplTop5)

		render: (data) ->
			# if data.popularShows.length == 0 
				# @$el.html(@template())
			@$el.html(@template(data))
			@bind()
			@fillGauges('shows')
			return @

		# Init gauges var
		totalAppearances: 0
		fillPercent: 0
		
		events: 
			'click .tabs li': 'onClick'

		# On tab click, change content and refill gauges
		onClick: (evt) ->
			if not $(evt.currentTarget).hasClass('active')
				@$el.find('li.active').removeClass('active')
				$(evt.currentTarget).addClass('active')
				currentTab = $(evt.currentTarget).data('tab')
				@$el.find('section').removeClass('visible')
				@$el.find('section#' + currentTab).addClass('visible')
				# Refill gauges
				@fillGauges(currentTab)
		
			
		# Get fill % of gauge
		getFillPercent: (bar, type) ->
			_this = @
			@totalAppearances = 0
			@fillPercent = 0
			$('#' + type + ' .gauge span').each -> 
				_this.totalAppearances += parseInt($(@).data('appearances'))
			@fillPercent = bar.data('appearances') * 100 / @totalAppearances
		
		# Fill gauge and append total
		fillGauges: (type) ->
			_this = @
			$('#' + type + ' .gauge span').each ->
				_this.getFillPercent($(@), type)
				$('#' + type + ' span.total').html '/' + _this.totalAppearances
				$(@).addClass('width').width(0)
				$(@).removeClass('width').width(_this.fillPercent + '%')

		

		
			
			