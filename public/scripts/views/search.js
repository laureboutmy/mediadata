// Generated by CoffeeScript 1.7.1
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'underscore', 'backbone', 'mediadata', 'text!templates/search.html'], function($, _, Backbone, md, tplSearch) {
    'use strict';
    var SearchView;
    return SearchView = (function(_super) {
      __extends(SearchView, _super);

      function SearchView() {
        return SearchView.__super__.constructor.apply(this, arguments);
      }

      SearchView.prototype.el = '#main';

      SearchView.prototype.collection = null;

      SearchView.prototype.template = _.template(tplSearch);

      SearchView.prototype.name = null;

      SearchView.prototype.initialize = function() {
        return this.render();
      };

      SearchView.prototype.render = function() {
        this.$el.html(this.template());
        return this;
      };

      return SearchView;

    })(Backbone.View);
  });

}).call(this);