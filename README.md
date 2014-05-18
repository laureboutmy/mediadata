mediadata
=========

Datavisualization INA

## Coffee
	coffee --watch --compile --output public/scripts/ public/src/scripts/

## Sass
	sass --watch public/src/styles/master.scss:public/styles/master.css --style compact

## Backbone pushState
public/index.html, line 9:
	<base href="[INSERT URL HERE]" />


public/src/scripts/routers/router.coffee:
	initialize: () ->
		Backbone.history.start
			pushState: true
			root: '[INSERT URL HERE]'
