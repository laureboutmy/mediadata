'use strict'
require.config
  shim: 
  	underscore:
  		exports: '_'
  	backbone:
  		deps: ['jquery', 'underscore']
  		exports: 'Backbone'
  paths:
    jquery: 'vendors/jquery-2.1.1.min'
    backbone: 'vendors/backbone.min'
    underscore: 'vendors/underscore.min'
    text: 'vendors/require-text'

define ['mediadata'], (md) ->
	md.initialize()
	# console.log(Md);
	# Backbone.history.start
	# 	pushState: true
	# 	root: '/mediadata/public/'