var kManaSymbols = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
            		"10", "11", "12", "13", "14", "15", "16", "17", "18", "19",
            		"20", "100", "1000000",
            		"W", "U", "B", "R", "G",
            		"S", "X", "Y", "Z",
            		"WU", "WB", "UB",
                    "UR", "BR", "BG", "RG", "RW", "GW", "GU", "2W",
                    "2U", "2B", "2R", "2G", "P", "PW", "PU", "PB",
                    "PR", "PG", "Infinity", "H", "HW", "HU", "HB",
                    "HR", "HG"];

var kCardTypeWithSymbols = ["Artifact", "Creature",
                            "Enchantment", "Instant", "Land",
                            "Planeswalker", "Sorcery"];


var urlBase = "https://jovitoroyecacom.ipage.com/decktracker";
var kLimit = 20;

function CardObject(pfobject) {
	this.pfobject = pfobject;
}

// CardObject.prototype.manaImages = function() {
//     return replaceSymbolsInText(this.pfobject.get("manaCost"));
// }
 
CardObject.prototype.typeImage = function() {
	var type = this.pfobject.get('type');
	
	if (type == null) {
		return "blank";
	}
	
	for (i=0; i<kCardTypeWithSymbols.length; i++) {
		if (type.lastIndexOf(kCardTypeWithSymbols[i], 0) == 0 || // startsWith
		 	type.indexOf(kCardTypeWithSymbols[i]) > -1) {        // contains
			return kCardTypeWithSymbols[i].toLowerCase(); 
		}
	}
	
	return "blank";
}
  
CardObject.prototype.typeDetails = function() {
    var type = this.pfobject.get("type");
    
    if (type == null) {
		return "";
	}
		
	if (this.pfobject.get("power") != null ||
	 	this.pfobject.get("thoughness") != null) {
    	type = type + " (" + this.pfobject.get("power") + "/" + this.pfobject.get("toughness") + ")";
    }
    
    return type;
}

CardObject.prototype.setDetails = function() {
	var rarity = this.pfobject.get('rarity') != null ? this.pfobject.get('rarity').get('name') : "C";
	
	return this.pfobject.get("set").get("name") + " (" + rarity + ")";
}

/*CardObject.prototype.originalTextWithManaImages = function() {
    if (this.pfobject.get("originalText") != null) {
    	if (this.pfobject.get("originalType") != null) {
    		var basicLand = "Basic Land";
    		
    		if ((this.pfobject.get("originalType").substring(0, basicLand.length) === basicLand ||
    			 this.pfobject.get("type").substring(0, basicLand.length) === basicLand) &&
	         	(this.pfobject.get("originalText") != null && this.pfobject.get("originalText").length == 1))
             
    	    {
            	return "<img src='https://jovitoroyecacom.ipage.com/decktracker/mana/"+this.pfobject.get("originalText")+"/96.png'/>";
            	
        	} else {
        		return replaceSymbolsInText(this.pfobject.get("originalText"));
    		}
        
    	} else {
    		return "";
    	}
    	
    } else {
    	return "";
    }
}*/


// handlers
var express = require('express');
var app = express();


exports.root = function(req, res) {
	res.render("cards", { title: "Cards",
	   	    		     navbar: "2",
				    	   view: "search",
				    cardObjects: [],
				    	     pp: 0,
				    searchTerms: ""
	});
}


exports.search = function(req, res) {
	var searchTerms = req.query.searchTerms;
	
	var pp = req.query.pp;
    if (pp == null) {
        pp = 0;
    }
    
    var query;
	
	if (searchTerms.length == 1) {
		var q = new Parse.Query("Card");
		q.startsWith("name", searchTerms.toUpperCase());
		subQueries.push(q);
		
		query = Parse.Query.or(q);
	} else {
		var q1 = new Parse.Query("Card");
		q1.matches("name", "(?)"+searchTerms, "i");
		
		var q2 = new Parse.Query("Card");
		q2.matches("flavor", "(?)"+searchTerms, "i");
		
		var q3 = new Parse.Query("Card");
		q3.matches("text", "(?)"+searchTerms, "i");
		
		var q4 = new Parse.Query("Card");
		q4.matches("originalText", "(?)"+searchTerms, "i");
		
		query = Parse.Query.or(q1, q2, q3, q4);
	}
	
    query.include("set");
	query.include("rarity");
	query.ascending("name");
	
	query.count({
	  	success: function(count) {
			query.limit(kLimit);
			query.skip(pp*kLimit);
			query.find().then(function(objects) {
    			var cardObjects = [];
	    		for (i=0; i<objects.length; i++) {
    				cardObjects.push(new CardObject(objects[i]));
    			}

			    res.render("cards", { title: "Cards",
		   	    			     	 navbar: "2",
							    	   view: "searchResults",
							    cardObjects: cardObjects,
									  	 pp: pp,
							    searchTerms: searchTerms,
							    resultCount: count
				});
	    	});
  		},
		error: function(error) {
    	
  		}
	});
}

exports.topRated = function(req, res) {
    var pp = req.query.pp;
    if (pp == null) {
        pp = 0;
    }
	
	var query = new Parse.Query("Card");    
    query.include("set");
	query.include("rarity");
    query.descending("rating");
// 		query.addDescending("updatedAt"); 
	query.addAscending("name");
	query.exists("rating");
    
    query.limit(kLimit);
	query.skip(pp*kLimit);
    query.find().then(function(objects) {
    	var cardObjects = [];
		for (i=0; i<objects.length; i++) {
    		cardObjects.push(new CardObject(objects[i]));
    	}
    	
		res.render("cards", { title: "Cards",
	   		   			     navbar: "2",
					    	   view: "topRated",
				 		cardObjects: cardObjects,
					  			 pp: pp,
					  	resultCount: 100 // retrieve only the top 100
		});
	});	
}

exports.topViewed = function(req, res) {
    var pp = req.query.pp;
    if (pp == null) {
        pp = 0;
    }
	
	var query = new Parse.Query("Card");    
    query.include("set");
	query.include("rarity");
    query.descending("numberOfViews");
	query.addAscending("name");
	query.exists("numberOfViews");
    
    query.limit(kLimit);
	query.skip(pp*kLimit);
    query.find().then(function(objects) {
    	var cardObjects = [];
		for (i=0; i<objects.length; i++) {
    		cardObjects.push(new CardObject(objects[i]));
    	}
    	
		res.render("cards", { title: "Cards",
	   		   			     navbar: "2",
					    	   view: "topViewed",
				 		cardObjects: cardObjects,
					  			 pp: pp,
					  	resultCount: 100 // retrieve only the top 100
		});
	});	
		    
    // query.count({
// 	  	success: function(count) {
// 	  		query.limit(kLimit);
// 			query.skip(pp*kLimit);
// 			query.find().then(function(objects) {
//     			var cardObjects = [];
// 		    	for (i=0; i<objects.length; i++) {
//     				cardObjects.push(new CardObject(objects[i]));
//     			}
//     	
// 			    res.render("cards", { title: "Cards",
// 	   			    			     navbar: "2",
// 							    	   view: "topViewed",
// 					    		cardObjects: cardObjects,
// 							  			 pp: pp,
// 							  	resultCount: count
// 				});
// 		    });		
//   		},
// 		error: function(error) {
//     		
//   		}
// 	});
}

exports.details = function(req, res) {
	var id = req.query.id;
	
	var query = new Parse.Query("Card");    
    query.include("set");
	query.include("rarity");
	
	query.get(id, {
  		success: function(card) {
			var query2 = new Parse.Query("Card");    
		    query2.include("set");
			query2.include("rarity");
			query2.equalTo("name", card.get("name"));
			query2.notEqualTo("objectId", card.id);
			
			query2.find({
			    success: function(objects) {
		    		card.increment("numberOfViews");
					card.save();

					var versions = [];

    				for (i=0; i<objects.length; i++) {
			    		versions.push(new CardObject(objects[i]));
    				}
    	
	    			res.render("cards", { title: "Cards",
	   	    				     	 	 navbar: "2",
					    		   	   	   view: "details",
						    		 cardObject: new CardObject(card),
						    		  versions: versions
					});
  				},
  				error: function(error) {
  					console.log("error = "+error);
  				}
  			});	
  		},
  		error: function(object, error) {
    		// The object was not retrieved successfully.
    		// error is a Parse.Error with an error code and message.
    		console.log("Can't retrieve card: " + id);
  		}
	});
}

exports.price = function(req, res) {
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
		},
		function(httpResponse) {
	  		console.error('Request failed with response code ' + httpResponse.status);
	});
}

exports.image = function(req, res) {
	var magicCardsInfoCode = req.query.magicCardsInfoCode;
    var number = req.query.number;
    var crop = req.query.crop == 'true';
	var url = "http://magiccards.info/scans/en/"+magicCardsInfoCode+"/"+number+".jpg";
	var Image = require("parse-image");
	var base64;
	
	Parse.Cloud.httpRequest({
        url: url

	}).then(function(response) {
    	var image = new Image();
    	return image.setData(response.buffer);
    	
  	}).then(function(image) {
  		if (crop) {
        	var width =  image.width()*3/4;
        	var height = width-60;
        
    		return image.crop({
      			left: (image.width()-width)/2,
		     	 top: 45,
           	   width: width,
              height: height
    		});
    		
    	} else {
    		return image;
    	}

	}).then(function(image) {
		if (crop) {
    		// Resize the image
    		return image.scale({
      			width: 150,
      		   height: 112
    		});
    		
    	} else {
    		return image;
    	}

  	}).then(function(image) {
    	// Make sure it's a JPEG to save disk space and bandwidth.
    	return image.setFormat("JPEG");

	}).then(function(image) {
    	// Get the image data in a Buffer.
    	return image.data();

  	}).then(function(buffer) {
    	// Return as base64 string
    	base64 = buffer.toString("base64");
    	
  	}).then(function(httpResponse) {
			res.type('text/plain');
	  		res.send(base64);
		},
		function(httpResponse) {
	  		console.error('Request failed with response code ' + httpResponse.status);
	});
}
