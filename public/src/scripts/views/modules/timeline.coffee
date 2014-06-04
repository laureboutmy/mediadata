define [
	'jquery'
	'underscore'
	'backbone'
	'd3'
	'text!templates/modules/timeline.html'
], ($, _, Backbone, d3, tplTimeline) ->
	'use strict'
	class TimelineView extends Backbone.View
		el: '.module.timeline'
		template: _.template(tplTimeline)
		defaults:
			# Store minimum/maximum X/Y values from each dataset
			minXValues: [], minYValues: [], maxXValues: [], maxYValues: []
			# Store minimum/maximum X/Y values from both datasets
			minMaxY: [], minMaxX: []
			# Convert YYYY-MM format to full/exploitable date
			# parseDate: d3.time.format('%Y-%m').parse()
			margin: 
				top: 20, right: 20, bottom: 30, left: 50
			width: 960
			height: 300
		render: (data) ->
			# console.log(data)

			@$el.html(@template())
			@bind()
			return @


			
			