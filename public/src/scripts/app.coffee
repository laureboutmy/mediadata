'use strict'
require.config
  shim: 
  	underscore:
  		exports: '_'
  	backbone:
  		deps: ['jquery', 'underscore']
  		exports: 'Backbone'
    mediadata:
      deps: ['backbone']
      exports: 'MD'
  paths:
    jquery: 'vendors/jquery-2.1.1.min'
    backbone: 'vendors/backbone.min'
    underscore: 'vendors/underscore.min'
    text: 'vendors/require-text'
    mediadata: 'mediadata'

define ['mediadata'], (MD) ->
	MD.initialize()
