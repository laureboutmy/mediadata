define [
	'jquery'
	'underscore'
	'backbone'
	'd3'
], ($, _, Backbone, d3) ->
	'use strict'
	class ClockView extends Backbone.View
		el: '.module.clock'
		defaults:
			# Main label dimensions
			mlw: 215
			mlh: 50
		days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday']
		daysFR = ['Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi','Dimanche']
		# Filter dimensions
		fw = 125
		fh = 40
		# Width of the whole visualization; used for centering
		visWidth = 180
		visHeight = 350
		# Path/circle radius scaling
		radiusScale = d3.scale.linear().domain([0, 20]).range([100, visWidth-40]).clamp(false)
		# Arc settings
		arcOptions = { width: 7.1, from: 50, to: (d) -> d.outerRadius }
		# Arc function
		arc = (d,o) ->
			return d3.svg.arc()
				.startAngle (d) -> if d.mentions > 0 then (d.hour * 15 - o.width) * Math.PI/180 else 0
				.endAngle (d) -> if d.mentions > 0 then (d.hour * 15 + o.width) * Math.PI/180 else 0
				.innerRadius o.from
				.outerRadius (d) -> if d.mentions > 0 then o.to d else 0

		# Do mouseout in a func to get current maxHourValue
		mouseOut: (maxHourValue) ->
			d3.selectAll @$el
				.selectAll 'path'
				.on 'mouseout', (d) ->
					d3.select @.parentNode.parentNode 
						.select '.center .time'
						.text maxHourValue[1] + ' heures'
					d3.select @.parentNode.parentNode 
						.select '.center .value'
						.text maxHourValue[0]

		# Append SVG containers
		svg: () ->
			# Append SVG container for main label
			d3.selectAll(@$el).append('svg')
				.attr('id', 'mainlabel')
				.attr('width', @defaults.mlw)
				.attr('height', @defaults.mlh)

			# Append SVG container for filter
			d3.selectAll(@$el).append('svg')
				.attr('id', 'filter')
				.attr('width', fw)
				.attr('height', fh)

			# Append SVG container for clock
			d3.selectAll(@$el).append('svg')
				.attr('id', 'clockchart')
				.attr('height', visHeight)
				.append('g')

		# parseInt JSON data
		parse: (data) ->
			for d,i in data.broadcastHoursByDay
				d.broadcastHour = +d.broadcastHour
				d.broadcastCount = +d.broadcastCount

		# Append main label text
		appendMainLabel: (data) ->
			mentionsByDay = []
			for i in [1 .. 7]
				mentionsByDay.push {mentions: 0}

			# Fill-in mentionsByDay
			for d,i in data.broadcastHoursByDay
				for d2,i2 in days
					if d.broadcastWeekday is days[i2]
						mentionsByDay[i2].mentions += d.broadcastCount
						mentionsByDay[i2].day = d2

			d3.selectAll(@$el).select('#mainlabel').append('svg:text')
				.attr('class', 'value')
				.attr('x', '0').attr('y', '16')
				.text(mentionsByDay[0].mentions)

			d3.selectAll(@$el).select('#mainlabel').append('svg:text')
				.attr('class', 'time')
				.attr('x', '0').attr('y', '40')
				.text('Mentions horaires le ' + daysFR[0])

		# Append filter chart
		drawFilter: (data) ->
			mentionsByDay = []
			for i in [1 .. 7]
				mentionsByDay.push {mentions: 0}

			# Fill-in JSON mentionsByDay
			for d,i in data.broadcastHoursByDay
				for d2,i2 in days
					if d.broadcastWeekday is days[i2]
						mentionsByDay[i2].mentions += d.broadcastCount
						mentionsByDay[i2].day = d2

			# Find the maximum value to scale the filter chart
			maxDayValue = 0
			for d,i in mentionsByDay
				if maxDayValue < d.mentions then maxDayValue = d.mentions

			# Draw the filter
			xScale = d3.scale.ordinal().domain(d3.range(7)).rangeRoundBands([0, fw], 0.3)
			yScale = d3.scale.linear().domain([0, maxDayValue, (d) -> return d]).range([0, fh])

			_this = @

			d3.selectAll @$el
				.selectAll '#filter'
					.selectAll 'rect'
					.data mentionsByDay
					.enter()
					.append 'rect'
						.attr 'x', (d,i) -> return xScale i
						.attr 'y', (d) -> return fh - yScale d.mentions
						.attr 'width', xScale.rangeBand()
						.attr 'height', (d) -> return yScale d.mentions
						.attr 'class', 'bar'
						.attr 'name', (d) -> d.day
					.on 'click', (d) -> 
						_this.redrawContent d.day,data,mentionsByDay
						d3.select @.parentNode
							.selectAll '.bar'
							.classed 'selected', false
						d3.select @
							.classed 'selected', true

			d3.selectAll(@$el).select('[name=Monday]').classed('selected', true)

		#  Update chart
		redrawContent: (day,data,mentionsByDay) ->
			# Init new data arrays/vars
			mentionsByHour = []
			for i in [1 .. 24]
				mentionsByHour.push {mentions: 0, outerRadius: 0}
			maxHourValue = [0,]
			overallMaxHourValue = [0,]
			currentDay = days.indexOf day

			# Get max value for current day
			for d,i in data.broadcastHoursByDay
				if d.broadcastWeekday == day
					if d.broadcastCount > maxHourValue[0]
						maxHourValue[0] = d.broadcastCount
						maxHourValue[1] = d.broadcastHour

			@mouseOut(maxHourValue)

			# Get overall max value
			for d,i in data.broadcastHoursByDay
				if d.broadcastCount > overallMaxHourValue[0]
					overallMaxHourValue[0] = d.broadcastCount
					overallMaxHourValue[1] = d.broadcastHour

			pathScale =	d3.scale.linear().domain([0, overallMaxHourValue[0] + 20]).range([80, visWidth - 40]).clamp(true)

			# Init keys in new json
			for d,i in data.broadcastHoursByDay
				mentionsByHour[d.broadcastHour].hour = d.broadcastHour

			# Fill-in empty keys to make new json fancier
			for d,i in mentionsByHour
				if !d.hour then d.hour = i

			# Get mentions by hour for selected day
			for d,i in data.broadcastHoursByDay
				if d.broadcastWeekday == day
					mentionsByHour[d.broadcastHour].mentions += d.broadcastCount
					mentionsByHour[d.broadcastHour].outerRadius = pathScale mentionsByHour[d.broadcastHour].mentions
			
			# Update main text
			d3.selectAll(@$el).select('#mainlabel .value').text(mentionsByDay[currentDay].mentions)
			d3.selectAll(@$el).select('#mainlabel .person').text('Mentions horaires le ' + daysFR[currentDay])

			# Update paths
			d3.selectAll @$el
				.selectAll 'path'
				.data mentionsByHour
				.transition().duration(500)
				.attr 'd', arc mentionsByHour,arcOptions

			# Update max value label (time)
			d3.selectAll @$el
				.select 'g.center text.time'
				.data mentionsByHour
				.text maxHourValue[1] + ' heures'

			# Update max value label (value)
			d3.selectAll @$el
				.select 'g.center text.value'
				.data mentionsByHour
				.text maxHourValue[0]

		# Draw the clock element
		drawClock: (d,data) ->
			# Clock's parameters
			w = 360
			h = 360
			r = Math.min(w, h) / 2                       		# center
			p = 24                                       				# labels padding
			labels = ['00:00','06:00','12:00','18:00']   	# labels names

			# Circle settings
			ticks = d3.range 20, 20.1
			radiusFunction = radiusScale

			# Append circle
			d3.selectAll(@$el).select('g').append('svg:g').attr('class', 'circle').selectAll('circle').data(ticks).enter().append('svg:circle')
				.attr('cx', r ).attr('cy', r).attr('r', radiusScale)

			# Append outside labels
			d3.selectAll(@$el).select('g').append('svg:g')
				.attr('class', 'labels')
				.selectAll('text').data(d3.range 0, 360, 90).enter().append('svg:text')
				.attr('transform', (d) -> return 'translate(' + r + ',' + p + ') rotate(' + d + ',0,' + (r-p) + ')')
				.text ((d) -> d / 15 + ':00')

		# Push data into the clock element and draw paths
		drawContent: (data) ->
			# Init new data arrays
			maxHourValue = [0,]
			overallMaxHourValue = [0,]
			mentionsByHour = []
			for i in [1 .. 24]
				mentionsByHour.push {mentions: 0, outerRadius: 0}

			# Init keys in new json
			for d,i in data.broadcastHoursByDay
				mentionsByHour[d.broadcastHour].hour = d.broadcastHour

			# Fill-in empty keys to make new json fancier
			for d,i in mentionsByHour
				if !d.hour then d.hour = i

			# Get overall max value
			for d,i in data.broadcastHoursByDay
				if d.broadcastCount > overallMaxHourValue[0]
					overallMaxHourValue[0] = d.broadcastCount
					overallMaxHourValue[1] = d.broadcastHour

			# Scale paths with overall max value
			pathScale =	d3.scale.linear().domain([0, overallMaxHourValue[0] + 20]).range([80, visWidth - 40]).clamp(true)

			# Get mentions by hour for selected day
			for d,i in data.broadcastHoursByDay
				if d.broadcastWeekday == 'Monday'
					mentionsByHour[d.broadcastHour].mentions += d.broadcastCount
					mentionsByHour[d.broadcastHour].outerRadius = pathScale mentionsByHour[d.broadcastHour].mentions

			# Get max value for current day
			for d,i in data.broadcastHoursByDay
				if d.broadcastWeekday == 'Monday'
					if d.broadcastCount > maxHourValue[0]
						maxHourValue[0] = d.broadcastCount
						maxHourValue[1] = d.broadcastHour

			_this = @
			# Append paths / Show labels paths mouseover
			d3.selectAll @$el
				.select 'g'
					.append 'svg:g'
					.attr 'class', 'arcs'
					.selectAll 'path'
					.data mentionsByHour
				.enter().append 'svg:path'
					.attr 'd', arc mentionsByHour,arcOptions
					.attr 'transform', 'translate(' + visWidth + ',' + visWidth + ')'
					.on 'mouseover', (d) ->
						d3.select @.parentNode.parentNode 
							.select '.center .time'
							.text d.hour + ' heures'
						d3.select @.parentNode.parentNode 
							.select '.center .value'
							.text d.mentions
					.on 'mouseout', (d) -> _this.mouseOut(maxHourValue)

			# Append center labels
			d3.selectAll(@$el).select('g').append('svg:g').attr('class', 'center')
			d3.selectAll(@$el).select('g.center').append('svg:text').attr('transform', 'translate(' + visWidth + ',' + visWidth + ')')
				.attr('class', 'time')
				.text(maxHourValue[1] + ' heures')
			d3.selectAll(@$el).select('g.center').append('svg:text').attr('transform', 'translate(' + visWidth + ',' + (visWidth+20) + ')')
				.attr('class', 'value')
				.text(maxHourValue[0])

		clear: () ->
			@$el.children().remove()

		render: (data) ->
			if (@$el.children().length > 0)
				@clear()

			@parse data
			@svg()
			@drawFilter data
			@drawClock data
			@drawContent data
			@appendMainLabel data