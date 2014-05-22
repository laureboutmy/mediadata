$(document).ready () ->

	# Get total appearances
	$('span.total').html()

	# Init gauges var
	totalAppearances = 0
	fillPercent = 0

	# Get fill % of gauge
	getFillPercent = (bar, type) ->
		totalAppearances = 0
		fillPercent = 0
		$('#' + type + ' .gauge span').each -> 
			totalAppearances += parseInt($(@).data('appearances'))
		fillPercent = bar.data('appearances') * 100 / totalAppearances

	# Fill gauge and append total
	fillGauges = (type) ->
		$('#' + type + ' .gauge span').each ->
			getFillPercent($(@), type)
			$('#' + type + ' span.total').html '/' + totalAppearances
			$(@).css('width', 0)
			$(@).animate({width: fillPercent + '%'}, {duration: 500})

	fillGauges('channels')
	fillGauges('shows')

	# On tab click, change content and refill gauges
	$('.tab').on 'click', () -> 
		if not $(@).hasClass 'active'
			$('.tab').removeClass 'active'
			$(@).addClass 'active'
			tabclicked = $(@).data 'tab'
			$('section').addClass 'hidden'
			$('section#' + tabclicked).removeClass 'hidden'
			# Refill gauges
			fillGauges('channels')
			fillGauges('shows')

