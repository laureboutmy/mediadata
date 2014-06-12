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

		# Chart size
		margin = {top: 30, right: 50, bottom: 50, left: 50}
		width = 920
		height = 300

		# X/Y axes
		xScale = d3.time.scale()
		.range [0, width]

		yScale = d3.scale.linear()
		.range [height, 0]

		xAxis =	d3.svg.axis()
			.scale xScale
			.orient 'bottom'
			.ticks 8

		yAxis = d3.svg.axis()
			.scale yScale
			.orient 'left'
			.ticks 5

		# Grid
		yGrid = () ->
			return d3.svg.axis()
				.scale yScale
				.orient 'left'
				.ticks 5

		# Area element
		area = d3.svg.area() 
			.x (d) -> if d then return xScale d.mentionDate
			.y0 height
			.y1 (d) -> if d then return yScale d.mentionCount

		# Path element
		valueline = d3.svg.line()
			.x (d) -> if d then return xScale d.mentionDate
			.y (d) -> if d then return yScale d.mentionCount

		# Convert YYYY-MM format to full/exploitable date
		parseDate = d3.time.format('%Y-%m').parse

		# Append SVG container
		svg: () ->
			d3.selectAll(@$el)
				.append 'svg'
					.attr 'width', width + margin.left + margin.right
					.attr 'height', height + margin.top + margin.bottom
				.append 'g'
					.attr 'transform', 'translate(' + margin.left + ',' + margin.top + ')'
					.attr 'class', 'thetimeline'

		# Translate month names to FR (should look into d3.locale feature)
		translate: () ->
			monthsEN = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
			monthsFR = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre']
			shortMonthsEN = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
			shortMonthsFR = ['janv', 'févr', 'mars', 'avr', 'mai', 'juin', 'juill', 'août', 'sept', 'oct', 'nov', 'déc']
			for i in [0 .. 12]
				$('g.tick text:contains(' + monthsEN[i] + ')').html(monthsFR[i])
				# shortmonths doesn't work, d3.locale is the solution

		### HEADER INFOS ###

		# Append total values / names in timeline's header
		getTotals: (data) ->
			total = 0
			for d,i in data.person1.timelineMentions
				d.mentionCount = +d.mentionCount
				total += d.mentionCount
			$('.module.timeline h4:first-of-type').html(data.person1.name)
			$('.module.timeline h3:first-of-type span').html(total.toLocaleString())
			# Align blocs
			widthFirstBloc = $('.module.timeline h4:first-of-type').width()
			if widthFirstBloc > $('.module.timeline h3:first-of-type').width()
				$('.module.timeline h3:first-of-type').width(widthFirstBloc + 2)

			if data.person2 
				total = 0
				for d,i in data.person2.timelineMentions
					d.mentionCount = +d.mentionCount
					total += d.mentionCount
				$('.module.timeline h4:last-of-type').html(data.person2.name)
				$('.module.timeline h3:last-of-type span').html(total.toLocaleString())
			else
				$('.module.timeline h3:last-of-type').hide()
				$('.module.timeline h4:last-of-type').hide()

		### FILTER ###
		
		# Make the list of years the timeline's filter will use/redraw
		getYears: (data,comparison) ->
			_this = @
			years = []

			getYears = []
			# Make a filtered copy of data
			getYears = JSON.parse(JSON.stringify(data))
			for d,i in getYears.person1.timelineMentions
				d.mentionRawDate = d.mentionDate
				d.year = d.mentionRawDate.substring(0,4)
				d.year = +d.year
			if comparison is true
				for d,i in getYears.person2.timelineMentions
					d.mentionRawDate = d.mentionDate
					d.year = d.mentionRawDate.substring(0,4)
					d.year = +d.year

			# Store years in years list
			for d,i in getYears.person1.timelineMentions
				if years.indexOf(d.year) < 0
					years.push d.year
			if comparison is true
				for d,i in getYears.person2.timelineMentions
					if years.indexOf(d.year) < 0
						years.push d.year
			years.sort()

			# If less than 3 values in year, remove it from the years list.
			for d,i in years
				if @getCount(getYears, years[i], if comparison is true then true else false) < 3
					j = years.indexOf(years[i])
					if (j > -1)
						years.splice(j, 1)

			@drawFilter years, data, if comparison is true then true else false

		# Filter data by year
		getDataYear: (data,year,comparison) ->
			dataYear = []
			# Make a filtered copy of data
			dataYear = JSON.parse(JSON.stringify(data))
			for d,i in dataYear.person1.timelineMentions
				d.mentionRawDate = d.mentionDate
				d.mentionDate = parseDate d.mentionDate
				d.year = d.mentionRawDate.substring(0,4)
				d.year = +d.year
			if comparison is true
				for d,i in dataYear.person2.timelineMentions
					d.mentionRawDate = d.mentionDate
					d.mentionDate = parseDate d.mentionDate
					d.year = d.mentionRawDate.substring(0,4)
					d.year = +d.year

			if year
				# Filter the data
				for d,i in dataYear.person1.timelineMentions
					if dataYear.person1.timelineMentions[i].year
						if dataYear.person1.timelineMentions[i].year != year
							delete dataYear.person1.timelineMentions[i]
				if comparison is true
					for d,i in dataYear.person2.timelineMentions
						if dataYear.person2.timelineMentions[i].year
							if dataYear.person2.timelineMentions[i].year != year
								delete dataYear.person2.timelineMentions[i]

				# Get rid of undefined keys
				tmpArray = []
				for d in dataYear.person1.timelineMentions
					if d
							tmpArray.push(d)
				dataYear.person1.timelineMentions = tmpArray
				if comparison is true
					tmpArray = []
					for d in dataYear.person2.timelineMentions
						if d
								tmpArray.push(d)
					dataYear.person2.timelineMentions = tmpArray
			return dataYear

		# Return number of values in year to check if this year is useless
		getCount: (getYears, year, comparison) ->
			count = 0
			for d,i in getYears.person1.timelineMentions
				if +d.year == year
					count++
			if comparison is true
				for d,i in getYears.person2.timelineMentions
					if +d.year == year
						count++
			return count

		# Find max Y value for a year to draw Y axis
		getMaxYValuesYear: (data,comparison) ->
			maxYValuesYear = 0 # reset
			maxYValuesYear = []
			maxYValuesYear.push d3.max data.person1.timelineMentions, (d) -> return d.mentionCount
			if comparison is true
				maxYValuesYear.push d3.max data.person2.timelineMentions, (d) -> return d.mentionCount
			return maxYValuesYear

		# Timeline's filter (years/all)
		drawFilter: (years,data,comparison) ->
			_this = @
			iArrow = 0
			$('#filter > ul ul li').html('Par années (' + years[0] + '-' + years[years.length - 1] + ')')
			
			# Dropdown
			$('#filter > ul').on('click', ->
				$(@).toggleClass('active')
			)

			# Click on dropdown's buttons : redraw last year or default view
			$('#filter > ul ul li').on('click', ->
				iArrow = years.length - 1
				$(@).siblings().remove()
				if $(@).hasClass('get-all')
					$(@).parent().parent().find('>:first-child').html($(@).html())
					$(@).html('Par années (' + years[0] + '-' + years[years.length - 1] + ')')
					$('.arrow').removeClass('enabled').addClass('disabled')
					$(@).toggleClass('get-all')
					if comparison is true
						dataAll = _this.getDataYear(data,null,true)
						maxYValuesAll = _this.getMaxYValuesYear(dataAll, true)
						if maxYValuesAll[0] < maxYValuesAll[1]
							_this.redraw(dataAll, null, 2, d3.max maxYValuesAll)
							_this.redraw(dataAll, null, 1, d3.max maxYValuesAll)
						else
							_this.redraw(dataAll, null, 1, d3.max maxYValuesAll)
							_this.redraw(dataAll, null, 2, d3.max maxYValuesAll)		
					else
						dataAll = _this.getDataYear(data,null,false)
						maxYValuesAll = _this.getMaxYValuesYear(dataAll, false)
						_this.redraw(dataAll, null, 1, d3.max maxYValuesAll)
				else
					$(@).parent().parent().find('>:first-child').html('Année ' + years[years.length - 1])
					$('.arrow:first-child').toggleClass('enabled disabled')
					$(@).html('Toutes les mentions').toggleClass('get-all')
					if comparison is true
						dataYear = _this.getDataYear(data,years[years.length - 1], true)
						maxYValuesYear = _this.getMaxYValuesYear(dataYear, true)
						if maxYValuesYear[0] < maxYValuesYear[1]
							_this.redraw(dataYear, years[years.length - 1], 2, d3.max maxYValuesYear)
							_this.redraw(dataYear, years[years.length - 1], 1, d3.max maxYValuesYear)
						else
							_this.redraw(dataYear, years[years.length - 1], 1, d3.max maxYValuesYear)
							_this.redraw(dataYear, years[years.length - 1], 2, d3.max maxYValuesYear)
					else
						dataYear = _this.getDataYear(data,years[years.length - 1], false)
						maxYValuesYear = _this.getMaxYValuesYear(dataYear, false)
						_this.redraw(dataYear, years[years.length - 1], 1, maxYValuesYear[0])
			)

			# Click on prev/next arrows : redraw selected year
			$('.arrow').on('click', ->
				if $(@).hasClass('enabled')
					if $(@).hasClass('next')
						iArrow++
						if comparison is true
							dataYear = []
							maxYValuesYear = []
							dataYear = _this.getDataYear(data,years[iArrow],true)
							maxYValuesYear = _this.getMaxYValuesYear(dataYear, true)
							if maxYValuesYear[0] < maxYValuesYear[1]
								_this.redraw(dataYear,years[iArrow], 2, d3.max maxYValuesYear)
								_this.redraw(dataYear,years[iArrow], 1, d3.max maxYValuesYear)
							else
								_this.redraw(dataYear,years[iArrow], 1, d3.max maxYValuesYear)
								_this.redraw(dataYear,years[iArrow], 2, d3.max maxYValuesYear)
						else
							dataYear = []
							maxYValuesYear = []
							dataYear = _this.getDataYear(data,years[iArrow],false)
							maxYValuesYear = _this.getMaxYValuesYear(dataYear, false)
							_this.redraw(dataYear,years[iArrow], 1, d3.max maxYValuesYear)
						if years[iArrow]
							$('#filter > ul > li').html('Année ' + years[iArrow])
							$('.arrow:first-child').removeClass('disabled').addClass('enabled')
						if !years[iArrow + 1]
							$('.arrow:last-child').toggleClass('enabled disabled')
					else if $(@).hasClass('prev')
						iArrow--
						if comparison is true
							dataYear = []
							maxYValuesYear = []
							dataYear = _this.getDataYear(data,years[iArrow],true)
							maxYValuesYear = _this.getMaxYValuesYear(dataYear, true)
							if maxYValuesYear[0] < maxYValuesYear[1]
								_this.redraw(dataYear,years[iArrow], 2, d3.max maxYValuesYear)
								_this.redraw(dataYear,years[iArrow], 1, d3.max maxYValuesYear)
							else
								_this.redraw(dataYear,years[iArrow], 1, d3.max maxYValuesYear)
								_this.redraw(dataYear,years[iArrow], 2, d3.max maxYValuesYear)
						else
							dataYear = []
							maxYValuesYear = []
							dataYear = _this.getDataYear(data,years[iArrow],false)
							maxYValuesYear = _this.getMaxYValuesYear(dataYear, false)
							_this.redraw(dataYear,years[iArrow], 1, d3.max maxYValuesYear)
						if years[iArrow]
							$('#filter > ul > li').html('Année ' + years[iArrow])
							$('.arrow:last-child').removeClass('disabled').addClass('enabled')
						if !years[iArrow - 1]
							$('.arrow:first-child').toggleClass('enabled disabled')
			)

		### CHART (draw/redraw) ###

		# Find min/max values in dataset and append the chart
		getMinMax: (data, comparison) ->
			# Parse dates
			for d,i in data.person1.timelineMentions
				d.mentionRawDate = d.mentionDate
				d.mentionDate = parseDate d.mentionDate
				d.mentionCount = +d.mentionCount
			if comparison
				for d,i in data.person2.timelineMentions
					d.mentionRawDate = d.mentionDate
					d.mentionDate = parseDate d.mentionDate
					d.mentionCount = +d.mentionCount

			# Store minimum/maximum X/Y values from each dataset
			minXValues = []
			minYValues = []
			maxXValues = []
			maxYValues = []
			# Store minimum/maximum X/Y values from both datasets
			minMaxX = []
			minMaxY = []

			minXValues.push d3.min data.person1.timelineMentions, (d) -> return d.mentionDate
			maxXValues.push d3.max data.person1.timelineMentions, (d) -> return d.mentionDate
			minYValues.push d3.min data.person1.timelineMentions, (d) -> return d.mentionCount
			maxYValues.push d3.max data.person1.timelineMentions, (d) -> return d.mentionCount

			if comparison
				minXValues.push d3.min data.person2.timelineMentions, (d) -> return d.mentionDate
				maxXValues.push d3.max data.person2.timelineMentions, (d) -> return d.mentionDate
				minYValues.push d3.min data.person2.timelineMentions, (d) -> return d.mentionCount
				maxYValues.push d3.max data.person2.timelineMentions, (d) -> return d.mentionCount

			minXValue = d3.min minXValues
			maxXValue = d3.max maxXValues
			minMaxX.push minXValue, maxXValue
			minYValue = d3.max minYValues
			maxYValue = d3.max maxYValues
			minMaxY.push minYValue, maxYValue

			# Generate X/Y axes
			xScale.domain minMaxX
			yScale.domain minMaxY

			# Append everything
			if comparison
				if maxYValues[0] < maxYValues[1]
					@draw data.person2.timelineMentions, 2, true
					@draw data.person1.timelineMentions, 1
				else
					@draw data.person1.timelineMentions, 1, true
					@draw data.person2.timelineMentions, 2
			else
				@draw data.person1.timelineMentions, 1, true

		# Append chart elements
		draw: (data, datasetnumber, drawGrid) ->
			if drawGrid is true # (don't draw two grids)
				# Draw horizontal grid
				d3.select('g.thetimeline').append 'g'
					.attr 'class', 'grid'
					.call(yGrid()
						.tickSize(-width, 0, 0)
						.tickFormat '')

			# Draw main path
			path = d3.select('g.thetimeline').append 'path'
				.datum data
				.attr 'class', 'line' + datasetnumber
				.attr 'd', valueline

			# totalLength = path.node().getTotalLength()
			# path
			# 	.attr("stroke-dasharray", totalLength+","+totalLength)
			# 	.attr("stroke-dashoffset", totalLength)
			# 	.transition()
			# 	.duration(3000)
			# 	.ease("linear-in-out")
			# 	.attr("stroke-dashoffset", 0);

			# Draw area
			d3.select('g.thetimeline').append('path')
				.datum data
				.attr 'class', 'area' + datasetnumber
				.transition().duration(1500).ease('sin-in-out')
				.style 'opacity', 1
				.attr 'd', area

			# Draw dots
			d3.select('g.thetimeline').selectAll 'circle' + datasetnumber
				.data data
				.enter()
				.append 'circle'
					.attr 'class', 'circle' + datasetnumber
					.attr 'r', 3.5
					.attr 'cx', (d) -> return xScale d.mentionDate
					.attr 'cy', (d) -> return yScale d.mentionCount

			if datasetnumber is 1 # (don't draw two X/Y axes)
				# Draw X/Y axes
				d3.select('g.thetimeline').append 'g'
					.attr 'class', 'x axis'
					.attr 'transform', 'translate(0,' + height + ')'
					.call xAxis
				d3.select('g.thetimeline').append 'g'
					.attr 'class', 'y axis'
					.call yAxis
				.append 'text'        
					.datum data
					.attr 'transform', 'rotate(-90)'
					.attr 'y' , 6
					.attr 'dy', '.71em'
					.style 'text-anchor', 'end'

			@translate()

		# Redraw the chart (year/default view)
		redraw: (data,year,personNumber,maxYValueYear) ->
			# Scale with new data
			xScale.domain(d3.extent(data['person' + personNumber].timelineMentions, (d) -> return d.mentionDate))
			yScale.domain([0, maxYValueYear])

			# Update horizontal grid
			d3.select('g.grid')
				.transition().duration(1500).ease('sin-in-out')
				.call(yGrid()
					.tickSize(-width, 0, 0)
					.tickFormat '')

			# Update axes
			d3.select('g.thetimeline').select('g.x')
				.transition().duration(1500).ease('sin-in-out')
				.call xAxis
			d3.select('g.thetimeline').select('g.y')
				.transition().duration(1500).ease('sin-in-out')
				.call yAxis

			# Update line
			d3.select('g.thetimeline').select('path.line' + personNumber).remove()
			d3.select('g.thetimeline')
				.append 'path'
				.attr 'class', 'line' + personNumber
				.datum data['person' + personNumber].timelineMentions
				.transition().duration(1500).ease('sin-in-out')
				.attr 'd', valueline

			# Update area
			d3.select('g.thetimeline').select('path.area' + personNumber).remove()
			d3.select('g.thetimeline')
				.append 'path'
				.attr 'class', 'area' + personNumber
				.datum data['person' + personNumber].timelineMentions
				.transition().duration(1500).ease('sin-in-out')
				.attr 'd', area
				# .transition()
				# .delay(1500)
				.style 'opacity', 1

			if year
				# Redraw dots
				if data['person2']
					d3.selectAll 'circle:not(.stay)'
						.remove()
				else
					d3.selectAll 'circle'
						.remove()
				d3.selectAll 'circle.stay'
					.classed 'stay', false
				d3.select('g.thetimeline').selectAll('circle' + personNumber)
					.data data['person' + personNumber].timelineMentions
					.enter()
					.append 'circle'
						.attr 'class', 'circle' + personNumber
						.classed 'stay', true
						.attr 'r', 3.5
						.attr 'cx', (d) -> return xScale d.mentionDate
						.attr 'cy', (d) -> return yScale d.mentionCount
						.transition()
						.delay(1300)
						.style 'opacity', 1
			else
				d3.selectAll 'circle'
					.remove()

			@translate()

		### EXEC ###
		render: (data) ->
			# Save a copy of original dataset
			originalData = JSON.parse(JSON.stringify(data))

			# Append HTML template + SVG container
			@$el.html(@template())
			@svg()

			# Append persons' infos in timeline's header
			@getTotals originalData

			# Draw the chart
			if data.person2
				@getMinMax data,true
				@getYears originalData,true
			else
				@getMinMax data,false
				@getYears originalData