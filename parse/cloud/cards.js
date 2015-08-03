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
var kMaxTopFetch = 100;

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

CardObject.prototype.setImage = function() {
	var rarity = this.pfobject.get('rarity') != null ? this.pfobject.get('rarity').get('symbol') : "C";
	
	return this.pfobject.get("set").get("code") + "/" + rarity;
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
				    searchTerms: "",
				   searchInName: true,
				   searchInText: true,
				 searchInFlavor: true,
                     colorBlack: true,
                      colorBlue: true,
                     colorGreen: true,
                       colorRed: true,
                     colorWhite: true,
                      colorless: true,
                    matchColors: false
	});
}


exports.search = function(req, res) {
	var searchTerms    = req.query.searchTerms;
	var searchInName   = req.query.searchInName   == "on";
	var searchInText   = req.query.searchInText   == "on";
	var searchInFlavor = req.query.searchInFlavor == "on";
    var colorBlack     = req.query.colorBlack     == "on";
    var colorBlue      = req.query.colorBlue      == "on";
    var colorGreen     = req.query.colorGreen     == "on";
    var colorRed       = req.query.colorRed       == "on";
    var colorWhite     = req.query.colorWhite     == "on";
    var colorless      = req.query.colorless      == "on";
    var matchColors    = req.query.matchColors    == "on";
							
	var pp = req.query.pp;
    if (pp == null) {
        pp = 0;
    }
    
    var query;

    // search terms
	if (searchTerms.length == 1) {
        query = new Parse.Query("Card");
		query.startsWith("name", pSearchTerms.toUpperCase());
		
	} else {
		if (searchInName) {
            query = new Parse.Query("Card");
			query.matches("name", "(?)"+searchTerms, "i");
		}
		
		if (searchInText) {
			var q1 = new Parse.Query("Card");
			q1.matches("text", "(?)"+searchTerms, "i");
            
			var q2 = new Parse.Query("Card");
			q2.matches("originalText", "(?)"+searchTerms, "i");
            
            if (query == null) {
                query = Parse.Query.or(q1, q2);
            } else {
                query = Parse.Query.or(query, q1, q2);
            }
		}
		
		if (searchInFlavor) {
			var q = new Parse.Query("Card");
			q.matches("flavor", "(?)"+searchTerms, "i");
            
            if (query == null) {
                query = q;
            } else {
                query = Parse.Query.or(query, q);
            }
		}
        
        if (query == null) {
            query = new Parse.Query("Card");
			query.matches("name", "(?)"+searchTerms, "i");    
        }
	}
	
    // colors
    var regex = "";
//    if (matchColors) {
//        regex = "^{}BURGW0-9XYZ" //^[+\-{}B(). ]+$   
//    }
//    if (colorBlack) {
//        regex = matchColors ? regex.replace("B", "") : regex.concat("B");    
//    }
//    if (colorBlue) {
//        regex = matchColors ? regex.replace("U", "") : regex.concat("U");    
//    }
//    if (colorGreen) {
//        regex = matchColors ? regex.replace("G", "") : regex.concat("G");    
//    }
//    if (colorRed) {
//        regex = matchColors ? regex.replace("R", "") : regex.concat("R");    
//    }
//    if (colorWhite) {
//        regex = matchColors ? regex.replace("W", "") : regex.concat("W");    
//    }
//    if (colorless) {
//        regex = matchColors ? regex.replace("0-9XYZ", "") : regex.concat("0-9XYZ");
//    }

    if (colorBlack) {
        regex = regex.concat("B");    
    }
    if (colorBlue) {
        regex = regex.concat("U");    
    }
    if (colorGreen) {
        regex = regex.concat("G");    
    }
    if (colorRed) {
        regex = regex.concat("R");    
    }
    if (colorWhite) {
        regex = regex.concat("W");    
    }
    if (colorless) {
        regex = regex.concat("0-9XYZ");
    }
    //^[+\-{}BG(). ]+$
    if (matchColors) {
        regex = "^[+\\-{}"+regex+"(). ]+$";
    } else {
        regex = "["+regex+"]";
    }
    
    query.matches("manaCost", regex, "i");
    query.include("set");
	query.include("rarity");
	query.exists("type"); // fix until mobile v1.5 is updated
	query.ascending("name");
	
	query.count({
	  	success: function(count) {
            console.log("count="+count);
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
							   searchInName: searchInName,
							   searchInText: searchInText,
							 searchInFlavor: searchInFlavor,
                                 colorBlack: colorBlack,
                                  colorBlue: colorBlue,
                                 colorGreen: colorGreen,
                                   colorRed: colorRed,
                                 colorWhite: colorWhite,
                                  colorless: colorless,
                                matchColors: matchColors,
							    resultCount: count
				});
	    	});
  		},
		error: function(error) {
    	   console.log("count error:"+error.toString());
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
    query.exists("type"); // fix until mobile v1.5 is updated
    
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
					    	           view: "topRated",
				 		        cardObjects: cardObjects,
                                         pp: pp,
					  	        resultCount: count > kMaxTopFetch ? kMaxTopFetch : count
		        });
	        });	
   		},
 		error: function(error) {
     		
   		}
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
	query.exists("type"); // fix until mobile v1.5 is updated
    
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
					    	           view: "topViewed",
				 		        cardObjects: cardObjects,
                                         pp: pp,
					  	        resultCount: count > kMaxTopFetch ? kMaxTopFetch : count
		        });
	        });	
   		},
 		error: function(error) {
     		
   		}
 	});
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
			query2.exists("type"); // fix until mobile v1.5 is updated
			
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
    		// error is a Parse.Error with an error code and message
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
    var crop = req.query.crop == "true";
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
