exports.cards = function(req, res) {
    var view = req.query.view
    if (view == null) {
        view = "topRated";
    }
    
    var pp = req.query.pp;
    if (pp == null) {
        pp = 0;
    }
	
	var query = new Parse.Query("Card");    
    query.include("set");
	query.include("rarity");
	query.limit(10);
	query.skip(pp*10);
	
    if (view == "topRated") {
		query.descending("rating");
		query.addAscending("name");
		query.exists("rating");
		
    } else {
	    query.descending("numberOfViews");
	    query.addAscending("name");
	    query.exists("numberOfViews");
    }
    
    /*query.find({
		success: function(objects) {
		    var i = 0;
    		var printings = [];
    		
    		do {
    			var relation = objects[i].relation("printings");

				relation.query().find({
			    	success: function(list) {
				    	console.log("list="+list);
				    	
				    	printings[i] = [];
 						for (j=0; j<list.length; j++) {
 							
  							printings[i][j] = list[j];
 						}
  					},
  					error: function(error) {
  						console.log("error = "+error);
  					}
				});

				i++;
				
				

    		} while (i<objects.length-1);
    		
    		if (i == objects.length-1) {
					console.log("printings="+printings);
    				res.render('cards', { title: "Cards",
					   	    	 navbar: "2",
								  cards: objects,
			        			   view: view,
							  printings: printings,
									 pp: pp
					});
				}
				
  		},
  		error: function(error) {
  			console.log(error);
  		}
	});
	*/

    query.find().then(function(objects) {
	    res.render('cards', { title: "Cards",
	   	    			     navbar: "2",
					          cards: objects,
					           view: view,
							     pp: pp
		});
    });
}

exports.cardPrice = function(req, res) {
	var tcgPlayerName = req.query.tcgPlayerName;
    var cardName = req.query.cardName;
		
	Parse.Cloud.httpRequest({
	    url: "http://partner.tcgplayer.com/x3/phl.asmx/p",
  		params: {
   		 	pk : "DECKTRACKER",
   		 	s : tcgPlayerName,
   		 	p : cardName
  		}
	}).then(function(httpResponse) {
		res.type('text/xml');
	  	res.send(httpResponse.text);
	}, function(httpResponse) {
	  	console.error('Request failed with response code ' + httpResponse.status);
	});
}