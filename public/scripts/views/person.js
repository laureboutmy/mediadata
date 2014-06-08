// Generated by CoffeeScript 1.7.1
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'underscore', 'backbone', 'mediadata', '../collections/persons', '../models/person', 'text!templates/person.html', '../views/modules/top-5', '../views/modules/timeline', '../views/modules/clock', '../views/modules/x-with-y'], function($, _, Backbone, md, PersonsCollection, PersonModel, tplPerson, Top5View, TimelineView, ClockView, XWithYView) {
    'use strict';
    var PersonView;
    return PersonView = (function(_super) {
      __extends(PersonView, _super);

      function PersonView() {
        return PersonView.__super__.constructor.apply(this, arguments);
      }

      PersonView.prototype.el = '#main';

      PersonView.prototype.collection = null;

      PersonView.prototype.template = _.template(tplPerson);

      PersonView.prototype.name = null;

      PersonView.prototype.initialize = function(options) {
        this.name = options.name1;
        this.collection = new PersonsCollection(this.name);
        md.Router.showLoader();
        return this.render(options);
      };

      PersonView.prototype.initializeModules = function(data) {
        this.top5 = new Top5View();
        this.timeline = new TimelineView();
        this.clock = new ClockView();
        this.xWithY = new XWithYView();
        return this.renderModules(data);
      };

      PersonView.prototype.bind = function() {
        $(window).on('scroll', this.stickFilters);
        return $(window).on('resize', this.onResize);
      };

      PersonView.prototype.unbind = function() {
        $(window).off('scroll', this.stickFilters);
        return $(window).off('resize', this.onResize);
      };

      PersonView.prototype.destroy = function() {
        return this.unbind();
      };

      PersonView.prototype.stickFilters = function() {
        if ($(window).scrollTop() > $('header.header').outerHeight()) {
          return $('#filters').addClass('fixed');
        } else {
          return $('#filters').removeClass('fixed');
        }
      };

      PersonView.prototype.render = function(options) {
        md.Status['currentView'] = 'person';
        $('div.loader').addClass('loading');
        document.body.scrollTop = document.documentElement.scrollTop = 0;
        return this.collection.fetch({
          success: (function(_this) {
            return function(data) {
              $('div.loader').addClass('complete');
              _this.collection = _this.collection.models[0].attributes;
              _this.$el.html(_this.template(_this.collection));
              md.Router.getFilters();
              _this.initializeModules(_this.collection);
              _this.bind();
              _this.onResize();
              $('div.loader').addClass('complete');
              md.Router.hideLoader();
              return _this;
            };
          })(this)
        });
      };

      PersonView.prototype.renderModules = function(data) {
        this.top5.render({
          popularChannels: data.popularChannels,
          popularShows: data.popularShows
        });
        this.timeline.render({
          person1: {
            name: data.person.name,
            timelineMentions: data.timelineMentions
          }
        });
        this.clock.render({
          broadcastHoursByDay: data.broadcastHoursByDay
        });
        return this.xWithY.render({
          persons: data.seenWith
        });
      };

      PersonView.prototype.onResize = function() {
        return $('#filters').width($(window).width() - 80);
      };

      PersonView.prototype.rerender = function() {
        md.Router.showLoader();
        this.collection = new PersonsCollection(this.name);
        return this.collection.fetch({
          success: (function(_this) {
            return function() {
              _this.collection = _this.collection.models[0].attributes;
              _this.renderModules(_this.collection);
              return md.Router.hideLoader();
            };
          })(this)
        });
      };

      return PersonView;

    })(Backbone.View);
  });

}).call(this);
