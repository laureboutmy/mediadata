define [
  'jquery'
  'underscore'
  'backbone'
  'd3'
  'text!templates/modules/stacked.html'
], ($, _, Backbone, d3, tplStacked) ->
  'use strict'
  class StackedView extends Backbone.View
    el: '.module.stacked'
    template: _.template(tplStacked)

    margin = {top: 60, right: 20, bottom: 60, left: 40}
    width = 1020
    height = 355
    marginRect = 25
    stacked_data = undefined
    x = d3.scale.ordinal()
      .rangeRoundBands([0, width])
    y = d3.scale.linear()
      .range([0, height])


    svg: () ->
      d3.selectAll(@$el)
        .append('svg')
          .attr('id', 'stackedchart')
          .attr('width', width)
          .attr('height', height+margin.top+margin.bottom)

    yAxis = d3.svg.axis()
          .orient 'left'
          .ticks 5
          .tickSize(-width, 0, 0)
          .tickValues [83, 83*2, 83*3, 83*4, 83*5]

    getScale: (data) ->
      
      stacked_data = d3.layout.stack()(data.channelMap.map( (data_nd) ->

          data.channelDatas.map( (d) -> x:d.channelName, y: +d[data_nd] )
        ))
        
      x.domain(stacked_data[0].map( (d) -> d.x ))
      y.domain([0, d3.max(stacked_data[stacked_data.length - 1], (d) -> d.y0 + d.y )])


    getTotals: (data) ->
      $('.module.stacked h4:first-of-type').html(data.names[0])
      $('.module.stacked h3:first-of-type span').html(data.totalCount[0].toLocaleString())

      $('.module.stacked h4:last-of-type').html(data.names[1])
      $('.module.stacked h3:last-of-type span').html(data.totalCount[1].toLocaleString())


    drawContent: (data) ->
      d3.select('#stackedchart').append('g')
        .attr('height', height)
        .attr('class', 'grid')
        .call(yAxis)

      d3.select('#stackedchart').selectAll('g.stacked-g')
          .data(stacked_data)
        .enter().append('g')
          .attr('class', (d,i) -> 'stacked-g person'+(i+1)+" "+ data.channelMap[i])
          .attr('transform', 'translate(0,' + (height+margin.bottom) + ')')

      d3.select('#stacked').selectAll('g.stacked-g')
        .selectAll('g')
         .data(Object)
       .enter().append('g')
        .append('rect')
          .attr('class', 'stacked-rect')
          .attr('x', (d) -> x(d.x)+33)
          .attr('y', (d) -> -y(d.y0) - y(d.y) )
          .attr('height', (d) -> y(d.y))
          .attr('width', 35)

      d3.select('#stackedchart').select('g.person1')
          .selectAll('image')
            .data(data.channelDatas)
          .enter().append('image')
            .attr('xlink:href', (d) -> d.channelPicture)
            .data(Object)
            .attr('height', 80)
            .attr('width', 70)
            .attr('x', (d) -> x(d.x)+15)
            .attr('y', -5)


    drawTooltip: (data) ->
      ## TOOLTIP ##
      total_height = []
      i = 0
      while i < stacked_data[0].length
        total_height[i] = (y(stacked_data[0][i].y) + y(stacked_data[1][i].y))
        ++i

      # total_height = total_height.concat(total_height)
      # Filtre servant à faire l'ombre du tooltip
      d3.select('#stacked').append('filter')
          .attr('id', 'f1')
          .attr('width', '150%')
          .attr('height', '150%')
        .append('feOffset')
          .attr('result', 'offOut')
          .attr('in', 'SourceAlpha')
          .attr('dx', 0)
          .attr('dy', 3)

      d3.select('#stacked').select('filter')
        .append( 'feGaussianBlur' )
          .attr( 'stdDeviation', 1 )
          .attr( 'result', 'blur' )


      d3.select('#stacked').selectAll('g.stacked-g g')
        .append('rect')
          .attr( 'filter', 'url("#f1")' ) 
          .attr('class', 'tooltip shadow')
          .attr('height', 45)
          .attr('width', 100)
          .attr('x', (d) -> x(d.x))
          .attr('y', (d,i) -> -y(d.y0) - (if typeof total_height[i] == 'undefined' then  y(d.y) else total_height[i])-53 )
          .attr('rx', 20)
          .attr('ry', 25)

      d3.select('#stacked').selectAll('g.stacked-g g')
        .append('rect')
          .attr('class', 'tooltip')
          .attr('height', 45)
          .attr('width', 100)
          .attr('x', (d) -> x(d.x))
          .attr('y', (d,i) -> -y(d.y0) - (if typeof total_height[i] == 'undefined' then  y(d.y) else total_height[i])-55 )
          .attr('rx', 20)
          .attr('ry', 25)


      d3.select('#stacked').selectAll('g.stacked-g g')
        .append('text')
        .attr('text-anchor', 'middle')
        .attr('class', 'tooltip name')
        .attr('x', (d) -> x(d.x)+50)
        .attr('y', (d,i) -> -y(d.y0) - (if typeof total_height[i] == 'undefined' then  y(d.y) else total_height[i])-33 )
        .text((d)->d.x)


      d3.select('#stacked').selectAll('g.stacked-g g')
        .append('text')
        .attr('text-anchor', 'middle')
        .attr('class', 'tooltip count')
        .attr('x', (d) -> x(d.x)+50)
        .attr('y', (d,i) -> -y(d.y0) - (if typeof total_height[i] == 'undefined' then  y(d.y) else total_height[i])-18 )
        .text((d)->d.y)


    render: (data) -> 

      @$el.html(@template())
      @svg()
      @getScale(data)
      @drawContent(data)
      @drawTooltip(data)
      @getTotals(data)
      
      if (data.channelDatas.length <= 0 )
        $('.module.stacked').empty().append('<div class="no-data"></div>')
        $('.module.stacked .no-data').append('<p><i class="icon-heart_broken"></i>Aucune donnée disponible</p>')


