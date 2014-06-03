define [
	'jquery'
	'underscore'
	'backbone'
	'd3'
], ($, _, Backbone, d3) ->
	'use strict'
	class ClockView extends Backbone.View
		el: '.module.clock'
		initialize: () ->

		render: (data) ->
			### Var / Functions ###
			days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday']
			daysFR = ['Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi','Dimanche']

			# Two additional JSON to store mentions by day or hour
			mentionsByDay = []
			for i in [1 .. 7]
				mentionsByDay.push {mentions: 0}

			mentionsByHour = []
			for i in [1 .. 24]
				mentionsByHour.push {mentions: 0, outerRadius: 0}

			# console.log 'mentionsByDay: ', mentionsByDay
			# console.log 'mentionsByHour: ', mentionsByHour

			# Main text dimensions
			tw = 215
			th = 50

			# Filter dimensions
			fw = 125
			fh = 40

			# Width of the whole visualization; used for centering
			visWidth = 180
			visHeight = 350

			# Store max values (for current view and for overall)
			maxHourValue = [0,]
			overallMaxHourValue = [0,]

			# Path/circle radius scaling
			radiusScale =
				d3.scale.linear()
				.domain [0, 20]
				.range [100, visWidth-40]
				.clamp false

			# Arc settings
			arcOptions = {
				width: 7.1,
				from: 50,
				to: (d) -> d.outerRadius
			}

			# Arc function
			arc = (d,o) ->
				return d3.svg.arc()
					.startAngle (d) -> if d.mentions > 0 then (d.hour * 15 - o.width) * Math.PI/180 else 0
					.endAngle (d) -> if d.mentions > 0 then (d.hour * 15 + o.width) * Math.PI/180 else 0
					.innerRadius o.from
					.outerRadius (d) -> if d.mentions > 0 then o.to d else 0

			mouseOut = () ->
				clock.selectAll 'path.person' + data.personNumber
					.on 'mouseout', (d) ->
						d3.select '.center .time.person' + data.personNumber
							.text maxHourValue[1] + ' heures'
						d3.select '.center .value.person' + data.personNumber 
							.text maxHourValue[0]

			# Append SVG element for main text
			d3.selectAll @$el
				.append 'svg'
					.attr 'id', 'maintext' + data.personNumber
					.attr 'width', tw
					.attr 'height', th

			# Append SVG element for filter
			svg = d3.selectAll @$el
				.append 'svg'
					.attr 'id', 'filter' + data.personNumber
					.attr 'width', fw
					.attr 'height', fh

			# Append SVG element for clock
			d3.selectAll @$el
				.append 'svg'
					.attr 'id', 'clockchart'
					.attr 'height', visHeight
					.append 'g'
						.attr 'class', 'theclock' + data.personNumber

			# The clock element
			clock = d3.select 'g.theclock' + data.personNumber

			### Draw the chart ###
			draw = () ->
				# parseInt JSON data
				for d,i in data.broadcastHoursByDay
					d.broadcastHour = +d.broadcastHour
					d.broadcastCount = +d.broadcastCount

				appendMainText = () ->
					d3.select '#maintext' + data.personNumber
						.append 'svg:text'
							.attr 'class', 'value person' + data.personNumber
							.attr 'x', '0'
							.attr 'y', '16'
							.text mentionsByDay[0].mentions

					d3.select '#maintext' + data.personNumber
						.append 'svg:text'
							.attr 'class', 'time person' + data.personNumber
							.attr 'x', '0'
							.attr 'y', '40'
							.text 'Mentions horaires le ' + daysFR[0]

				drawFilter = () ->
					# Fill-in JSON mentionsByDay
					for d,i in data.broadcastHoursByDay
						for d2,i2 in days
							if d.broadcastWeekday is days[i2]
								mentionsByDay[i2].mentions += d.broadcastCount
								mentionsByDay[i2].day = d2

					# Find the maximum value to scale the filter chart
					maxDayValue = 0
					for d,i in mentionsByDay
						if maxDayValue < d.mentions
							maxDayValue = d.mentions

					# Draw the filter
					xScale = d3.scale.ordinal()
						.domain d3.range 7
						.rangeRoundBands [0, fw], 0.3
					yScale = d3.scale.linear()
						.domain [0, maxDayValue, (d) -> return d]
						.range [0, fh]

					svg.selectAll 'rect'
						.data mentionsByDay
						.enter()
						.append 'rect'
							.attr 'x', (d,i) -> return xScale i
							.attr 'y', (d) -> return fh - yScale d.mentions
							.attr 'width', xScale.rangeBand()
							.attr 'height', (d) -> return yScale d.mentions
							.attr 'class', 'bar' + data.personNumber
							.attr 'id', (d) -> d.day + data.personNumber

					svg.select '#filter' + data.personNumber + ' #Monday' + data.personNumber
						.classed 'selected', true

					# When filter is clicked, redraw the chart
					filterClick = (i,day) ->
						document.getElementById days[i] + data.personNumber
							.onclick = (d) -> 
								redrawContent day
								d3.selectAll '.bar' + data.personNumber
									.classed 'selected', false
								d3.select this
									.classed 'selected', true
					for d,i in days
						filterClick i,days[i]

				redrawContent = (day) ->
					# Get current day index number
					currentDay = days.indexOf day

					# Reset mentionsByHour JSON
					for d,i in mentionsByHour
						d.mentions = 0
						d.outerRadius = 0

					# Reset maxHourValue and get max value for current day
					maxHourValue[0] = 0
					for d,i in data.broadcastHoursByDay
						if d.broadcastWeekday == day
							if d.broadcastCount > maxHourValue[0]
								maxHourValue[0] = d.broadcastCount
								maxHourValue[1] = d.broadcastHour

					pathScale =
						d3.scale.linear()
						.domain [0, overallMaxHourValue[0] + 20]
						.range [80, visWidth - 40]
						.clamp true

					# Get mentions by hour for selected day
					for d,i in data.broadcastHoursByDay
						if d.broadcastWeekday == day
							console.log 'New maxHourValue: ', maxHourValue[0]
							mentionsByHour[d.broadcastHour].mentions += d.broadcastCount
							mentionsByHour[d.broadcastHour].outerRadius = pathScale mentionsByHour[d.broadcastHour].mentions

					# Update main text
					d3.select '#maintext' + data.personNumber + ' .value.person' + data.personNumber
						.text mentionsByDay[currentDay].mentions
					d3.select '#maintext' + data.personNumber + ' .time.person' + data.personNumber
						.text 'Mentions horaires le ' + daysFR[currentDay]

					# Update paths
					clock.select 'g.arcs' + data.personNumber
						.selectAll 'path'
						.data mentionsByHour
						.transition().duration(500)
						.attr 'd', arc mentionsByHour,arcOptions

					# Update max value label (time)
					clock.select 'g.center'
						.select 'text.time'
						.data mentionsByHour
						.text maxHourValue[1] + ' heures'

					# Update max value label (value)
					clock.select 'g.center'
						.select 'text.value'
						.data mentionsByHour
						.text maxHourValue[0]

				drawContent = () ->
					# Init keys in new json
					for d,i in data.broadcastHoursByDay
						mentionsByHour[d.broadcastHour].hour = d.broadcastHour

					# Fill-in empty keys to make new json fancier
					for d,i in mentionsByHour
						if !d.hour
							d.hour = i

					# Get overall max value
					for d,i in data.broadcastHoursByDay
						if d.broadcastCount > overallMaxHourValue[0]
							overallMaxHourValue[0] = d.broadcastCount
							overallMaxHourValue[1] = d.broadcastHour

					# Scale paths with overall max value
					pathScale =
						d3.scale.linear()
						.domain [0, overallMaxHourValue[0] + 20]
						.range [80, visWidth - 40]
						.clamp true

					# Get mentions by hour for selected day
					for d,i in data.broadcastHoursByDay
						if d.broadcastWeekday == 'Monday'
							# console.log 'overallMaxHourValue: ', overallMaxHourValue[0]
							mentionsByHour[d.broadcastHour].mentions += d.broadcastCount
							mentionsByHour[d.broadcastHour].outerRadius = pathScale mentionsByHour[d.broadcastHour].mentions

					# Get max value for current day
					for d,i in data.broadcastHoursByDay
						if d.broadcastWeekday == 'Monday'
							if d.broadcastCount > maxHourValue[0]
								maxHourValue[0] = d.broadcastCount
								maxHourValue[1] = d.broadcastHour

					# Append paths / Show labels paths mouseover
					clock.append 'svg:g'
							.attr 'class', 'arcs' + data.personNumber
							.selectAll 'path'
							.data mentionsByHour
						.enter().append 'svg:path'
							.attr 'class', 'person' + data.personNumber
							.attr 'd', arc mentionsByHour,arcOptions
							.attr 'transform', 'translate(' + visWidth + ',' + visWidth + ')'
							.on 'mouseover', (d) -> 
								d3.select '.center .time.person' + data.personNumber
									.text d.hour + ' heures'
								d3.select '.center .value.person' + data.personNumber 
									.text d.mentions
							.on 'mouseout', mouseOut

					# Append center labels
					center = clock.append 'svg:g'
						.attr 'class', 'center'
					center.append 'svg:text'
							.attr 'transform', 'translate(' + visWidth + ',' + visWidth + ')'
							.attr 'class', 'time person' + data.personNumber
							.text maxHourValue[1] + ' heures'
					center.append 'svg:text'
							.attr 'transform', 'translate(' + visWidth + ',' + (visWidth+20) + ')'
							.attr 'class', 'value person' + data.personNumber
							.text maxHourValue[0]

				# Draw the clock element
				drawClock = (d) ->
					# Clock's parameters
					w = 360
					h = 360
					r = Math.min(w, h) / 2                       # center
					p = 24                                       # labels padding
					labels = ['00:00','06:00','12:00','18:00']   # labels names

					# Circle settings
					ticks = d3.range 20, 20.1
					radiusFunction = radiusScale

					# Append circle
					clock.append 'svg:g'
							.attr 'class', 'circle'
						.selectAll 'circle'
							.data ticks
						.enter().append 'svg:circle'
							.attr 'cx', r 
							.attr 'cy', r
							.attr 'r', radiusScale

					# Append outside labels
					clock.append 'svg:g'
						.attr 'class', 'labels'
						.selectAll 'text'
							.data d3.range 0, 360, 90
						.enter().append 'svg:text'
							.attr 'transform', (d) ->
									return 'translate(' + r + ',' + p + ') rotate(' + d + ',0,' + (r-p) + ')'
							.text (d) -> d / 15 + ':00'

					drawContent()

				drawFilter()
				drawClock mentionsByHour
				appendMainText()

			### Init ###
			draw()

			return @