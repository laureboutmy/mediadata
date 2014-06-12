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
			@total = 0
			for d,i in data.totalMentions
				d.mentionCount = +d.mentionCount
				@total += d.mentionCount
			@$el.html(@template(data))
			@setTotal(data)
			@fillGauges('shows')

		# Init gauges var
		total: 0
		fillPercent: 0
			
		# Get fill % of gauge
		getFillPercent: (bar, type) ->
			_this = @
			@fillPercent = 0
			@fillPercent = bar.data('appearances') * 100 / @total
		
		# Fill gauge and append total
		fillGauges: (type) ->
			_this = @
			$('#' + type + ' .gauge span').each ->
				_this.getFillPercent($(@), type)
				# $('#' + type + ' span.total').html '/' + _this.total
				$(@).addClass('width').width(0)
				$(@).removeClass('width').width(_this.fillPercent + '%')
		
		setTotal: (data) ->
			_this = @
			if !data.person
				$('.header-wrap span.value').html(_this.total)
			else if data.person is 'person2'
				$('section .top-5.person2 .header-wrap span.value').html(_this.total)
			else
				$('section .top-5.person1 .header-wrap span.value').html(_this.total)
		
			
			