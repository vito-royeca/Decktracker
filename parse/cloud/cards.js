// Provides endpoints for user signup and login

module.exports = function(){
  var express = require('express');
  var app = express();

  app.get('/cards', function(req, res) {
    var query = new Parse.Query("Card");
    
	query.include("set");
	query.limit(10)
	query.descending("rating");
	query.exists("rating");
	
	query.find().then(function(objects) {
	   var query2 = new Parse.Query("Card");
	   query2.include("set");
	   query2.limit(10)
	   query2.descending("numberOfViews");

	   query2.find().then(function(objects2) {
	     res.render('cards', { title: "Cards",
	  	 	    			   navbar: "2",
						       topRated: objects,
							   topViewed: objects2});
	   });
    });
  });

  return app;
}();


