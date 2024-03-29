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
			mlw: 218
			mlh: 50
		days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday']
		daysFR = ['Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi','Dimanche']
		# Filter dimensions
		fw = 105
		fh = 28
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

		# Append SVG containers
		svg: () ->
			svg = d3.selectAll(@$el).append('svg')
			svg.append('g').attr('id', 'mainlabel')
			svg.append('g').attr('id', 'filter').attr('transform', 'translate(320,0)')
			svg.append('g').attr('id', 'letters').attr('transform', 'translate(320,31)')
			svg.append('g').attr('id', 'clockchart').attr('transform', 'translate(30,62)')

		# Bind mouseout and mouseover to current data
		mouseOut: (currentDay, data) ->
			mentionsByDayValue = @getMentionsByDay(data,true,currentDay)
			d3.selectAll @$el
				.selectAll 'path'
				.on 'mouseout', (d) ->
					d3.select @.parentNode.parentNode 
						.select '.center .time'
						.text 'Total :'
					d3.select @.parentNode.parentNode 
						.select '.center .value'
						.text mentionsByDayValue

		mouseOver: (currentDay, data) ->
			mentionsByDayValue = @getMentionsByDay(data,true,currentDay)
			d3.selectAll @$el
				.selectAll 'path'
				.on 'mouseover', (d) ->
					d3.select @.parentNode.parentNode
						.select '.center .time'
						.text d.hour + ' heures'
					d3.select @.parentNode.parentNode 
						.select '.center .value'
						.text Math.round((d.mentions / mentionsByDayValue * 100) * 100) / 100 + ' %'

		clear: () ->
			@$el.children().remove()

		# Add all values in data to get total
		getTotal: (data) ->
			total = 0
			for d,i in data.broadcastHoursByDay
					total += d.broadcastCount
			return total

		# parseInt JSON data
		parse: (data) ->
			for d,i in data.broadcastHoursByDay
				d.broadcastHour = +d.broadcastHour
				d.broadcastCount = +d.broadcastCount

		getMentionsByDay: (data,mouseover,currentDay) ->
			mentionsByDay = []
			for i in [1 .. 7]
				mentionsByDay.push {mentions: 0}

			# Fill-in mentionsByDay
			for d,i in data.broadcastHoursByDay
				for d2,i2 in days
					if d.broadcastWeekday is days[i2]
						mentionsByDay[i2].mentions += d.broadcastCount
						mentionsByDay[i2].day = d2

			if mouseover is true
				return mentionsByDay[currentDay].mentions
			else
				return mentionsByDay

		# Append main label text
		appendMainLabel: (data) ->
			mentionsByDay = @getMentionsByDay data

			d3.selectAll(@$el).select('#mainlabel').append('svg:text')
				.attr('class', 'value')
				.attr('x', '0').attr('y', '16')
				.text Math.round(((mentionsByDay[0].mentions / @getTotal data) * 100) * 100) / 100 + ' %'

			d3.selectAll(@$el).select('#mainlabel').append('svg:text')
				.attr('class', 'time')
				.attr('x', '0').attr('y', '40')
				.text('des mentions totales le ' + daysFR[0])

		# Append filter (mini bar chart)
		drawFilter: (data) ->
			_this = @

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
						.attr 'class', (d) -> d.day
						.classed 'bar', true
					.on 'click', (d) -> 
						_this.redrawContent d.day,data,mentionsByDay
						d3.select @.parentNode
							.selectAll '.bar'
							.classed 'selected', false
						d3.select @.parentNode.parentNode
							.selectAll '.dayletter'
							.classed 'selected', false
						d3.select @
							.classed 'selected', true
						_this.barClick(d.day)
					.on 'mouseover', (d) ->
						d3.select @.parentNode.parentNode
							.select '.dayletter.' + d.day
							.classed 'hovered', true
					.on 'mouseleave', (d) ->
						d3.select @.parentNode.parentNode
							.select '.dayletter.' + d.day
							.classed 'hovered', false

			d3.selectAll @$el
				.selectAll '#letters'
					.selectAll 'text'
					.data (['L', 'M', 'M', 'J', 'V', 'S', 'D'])
					.enter()
					.append 'text'
						.attr 'class', 'dayletter'
						.attr 'x', (d,i) -> xScale i
						.attr 'y', '10'
						.text (d) -> return d

			d3.selectAll @$el
				.selectAll '.dayletter'
				.data mentionsByDay
				.on 'click', (d) ->
					_this.redrawContent d.day,data,mentionsByDay
					d3.select @.parentNode
						.selectAll '.dayletter'
						.classed 'selected', false
					d3.select @.parentNode.parentNode
						.selectAll '.bar'
						.classed 'selected', false
					d3.select @
						.classed 'selected', true
					_this.letterClick(d.day)
				.on 'mouseover', (d) ->
					d3.select @.parentNode.parentNode
						.select '.bar.' + d.day
						.classed 'hovered', true
				.on 'mouseleave', (d) ->
					d3.select @.parentNode.parentNode
						.select '.bar.' + d.day
						.classed 'hovered', false

			d3.selectAll(@$el).select('.bar').classed('selected', true)
			d3.selectAll(@$el).select('.dayletter:nth-of-type(1)').classed('selected', true)

			for i in [1 .. 7]
				d3.selectAll(@$el).select('.dayletter:nth-of-type(' + i + ')')
					.classed days[i - 1], true

		barClick: (day) ->
			d3.selectAll(@$el).select('text.dayletter.' + day).classed('selected', true)

		letterClick: (day) ->
			d3.selectAll(@$el).select('.bar.' + day).classed('selected', true)

		### REDRAW ###
		redrawContent: (day,data,mentionsByDay) ->
			# Init new data arrays/vars
			mentionsByHour = []
			for i in [1 .. 24]
				mentionsByHour.push {mentions: 0, outerRadius: 0}
			maxHourValue = [0,]
			overallMaxHourValue = [0,]
			currentDay = days.indexOf day
			mentionsByDayValue = @getMentionsByDay(data,true,currentDay)

			# Get max value for current day
			for d,i in data.broadcastHoursByDay
				if d.broadcastWeekday == day
					if d.broadcastCount > maxHourValue[0]
						maxHourValue[0] = d.broadcastCount
						maxHourValue[1] = d.broadcastHour

			@mouseOut(currentDay, data)
			@mouseOver(currentDay, data)

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
			
			# Update main label text (((mentionsByDay[0].mentions / @getTotal data) * 100) * 100) / 100 + ' %'
			d3.selectAll(@$el).select('#mainlabel .value').text(Math.round(((mentionsByDay[currentDay].mentions / @getTotal data) * 100) * 100) / 100 + ' %')
			d3.selectAll(@$el).select('#mainlabel .time').text('des mentions le ' + daysFR[currentDay])

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
				.text 'Total :'

			# Update max value label (value)
			d3.selectAll @$el
				.select 'g.center text.value'
				.data mentionsByHour
				.text mentionsByDay[currentDay].mentions

		### FIRST DRAW ###

		# Draw the clock element
		drawClock: (d,data) ->
			# Clock's parameters
			w = 360
			h = 360
			r = Math.min(w, h) / 2                       		# center
			p = 24                                       		# labels padding
			labels = ['00:00','06:00','12:00','18:00']   		# labels names

			# Circle settings
			ticks = d3.range 20, 20.1
			radiusFunction = radiusScale

			# Append circle
			d3.selectAll(@$el).select('g#clockchart').append('svg:g').attr('class', 'circle').selectAll('circle').data(ticks).enter().append('svg:circle')
				.attr('cx', r ).attr('cy', r).attr('r', radiusScale)

			# Append outside labels
			d3.selectAll(@$el).select('g#clockchart').append('svg:g')
				.attr('class', 'labels')
				.selectAll('text').data(d3.range 0, 360, 90).enter().append('svg:text')
				.attr('transform', (d) -> return 'translate(' + r + ',' + p + ') rotate(' + d + ',0,' + (r-p) + ')')
				.text ((d) -> d / 15 + ':00')

		# Push data into the clock element and draw paths
		drawContent: (data) ->
			_this = @
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

			currentDay = 0
			mentionsByDayValue = @getMentionsByDay(data,true,currentDay)

			# Append paths / Show labels paths mouseover
			d3.selectAll @$el
				.select 'g#clockchart'
					.append 'svg:g'
					.attr 'class', 'arcs'
					.selectAll 'path'
					.data mentionsByHour
				.enter().append 'svg:path'
					.attr 'd', arc mentionsByHour,arcOptions
					.attr 'transform', 'translate(' + visWidth + ',' + visWidth + ')'
					.on 'mouseover', (d) -> _this.mouseOver(currentDay, data)
					.on 'mouseout', (d) -> _this.mouseOut(currentDay, data)

			# Append center labels
			d3.selectAll(@$el).select('g#clockchart').append('svg:g').attr('class', 'center')
			d3.selectAll(@$el).select('g.center').append('svg:text').attr('transform', 'translate(' + visWidth + ',' + visWidth + ')')
				.attr('class', 'time')
				.text('Total :')

			d3.selectAll(@$el).select('g.center').append('svg:text').attr('transform', 'translate(' + visWidth + ',' + (visWidth+20) + ')')
				.attr('class', 'value')
				.text(mentionsByDayValue)

		### EXEC ###
		render: (data) ->
			if (data.broadcastHoursByDay.length is 0)
				$('.module.clock').empty().append('<div class="no-data"></div>')
				$('.module.clock .no-data').append('<p><i class="icon-heart_broken"></i>Aucune donnée disponible</p>')
			else
				if (@$el.children().length > 0)
					@clear()

				@parse data
				@svg()
				@drawFilter data
				@drawClock data
				@drawContent data
				@appendMainLabel data