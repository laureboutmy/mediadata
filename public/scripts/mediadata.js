// Generated by CoffeeScript 1.7.1
(function() {
  define(['jquery', 'underscore', 'backbone'], function($, _, Backbone) {
    'use strict';
    var md;
    return md = {
      Router: null,
      Views: {},
      Models: {},
      Collections: {},
      Filters: {},
      Status: {},
      initialize: function() {
        return require(['routers/router'], (function(_this) {
          return function(Router) {
            _this.Router = new Router();
            return Backbone.history.start({
              pushState: true,
              root: '/mediadata/public/'
            });
          };
        })(this));
      }
    };
  });

}).call(this);
