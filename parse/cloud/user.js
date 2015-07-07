// Provides endpoints for user signup and login

module.exports = function(){
  var express = require('express');
  var app = express();

  // Signs up a new user
  app.post('/sign-up', function(req, res) {
    var username = req.body.username;
    var password = req.body.password;

    var user = new Parse.User();
    user.set('username', username);
    user.set('password', password);
    
    user.signUp().then(function(user) {
      res.redirect('/');
    }, function(error) {
      // Show the error message and let the user try again
      res.render('sign-up', { title: "Sign In",
      						  navbar: "6",
    						  flash: error.message});
    });
  });

  // Logs in the user
  app.post('/sign-in', function(req, res) {
    Parse.User.logIn(req.body.username, req.body.password).then(function(user) {
    res.render('home', { title: "",
    					 navbar: "1"});
    }, function(error) {
      // Show the error message and let the user try again
      res.render('sign-in', { title: "Sign In",
      						  navbar: "5",
    						  flash: error.message});
    });
  });

  // Logs out the user
  app.post('/logout', function(req, res) {
    Parse.User.logOut();
    res.render('home', { title: "",
    					 navbar: "1"});
  });

  return app;
}();


