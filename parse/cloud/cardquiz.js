exports.cardquiz = function(req, res) {
	var query = new Parse.Query("UserMana");
	query.include("user");
	query.descending("totalCMC");
	
	
	query.find().then(function(objects) {
	  res.render('cardquiz', { title: "Card Quiz",
	  						   navbar: "4",
							   userManas: objects});
	});	
}