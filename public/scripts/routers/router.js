// Generated by CoffeeScript 1.7.1
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'underscore', 'backbone', '../collections/persons', '../models/person', '../views/home', '../views/explorer', '../views/person', '../views/search-bar'], function($, _, Backbone, PersonsCollection, PersonModel, HomeView, ExplorerView, PersonView, SearchbarView) {
    'use strict';
    var Router;
    return Router = (function(_super) {
      __extends(Router, _super);

      function Router() {
        return Router.__super__.constructor.apply(this, arguments);
      }

      Router.prototype.routes = {
        '': 'home',
        'explorer': 'explorer',
        ':person': 'getPerson',
        ':person/:otherPerson': 'compare'
      };

      Router.prototype.searchBar = null;

      Router.prototype.initialize = function() {
        this.onResize();
        return this.bind();
      };

      Router.prototype.compare = function(person, otherPerson) {
        return console.log(person, otherPerson);
      };

      Router.prototype.explorer = function() {
        var explorerView;
        explorerView = new ExplorerView();
        return explorerView.render();
      };

      Router.prototype.home = function() {
        var homeView;
        homeView = new HomeView();
        return homeView.render();
      };

      Router.prototype.getPerson = function(name) {
        var personView;
        console.log(name);
        if (!this.searchBar) {
          this.searchBar = new SearchbarView();
        }
        this.searchBar.render({
          name: name,
          comparison: false
        });
        this.searchBar.onResize();
        return personView = new PersonView({
          name: name
        });
      };

      Router.prototype.onResize = function() {};

      Router.prototype.render = function(view, name) {
        return this.createView(view, name);
      };

      Router.prototype.bind = function() {
        var _this;
        _this = this;
        return $(window).on('resize', _this.onResize);
      };

      Router.prototype.createView = function(view, name) {};

      return Router;

    })(Backbone.Router);
  });

}).call(this);
