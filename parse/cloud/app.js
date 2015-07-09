
// These two lines are required to initialize Express in Cloud Code.
express = require('express');
expressLayouts = require('cloud/express-layouts');
parseExpressCookieSession = require('parse-express-cookie-session');
parseExpressHttpsRedirect = require('parse-express-https-redirect');
app = express();

// Global app configuration section
app.set('views', 'cloud/views');  // Specify the folder to find templates
app.set('view engine', 'ejs');    // Set the template engine
app.use(express.bodyParser());    // Middleware for reading request body
app.use(expressLayouts);
app.use(express.methodOverride());
app.use(parseExpressHttpsRedirect());    // Automatically redirect non-secure urls to secure ones
app.use(express.cookieParser('SECRET_SIGNING_KEY'));
app.use(parseExpressCookieSession({
  fetchUser: true,
  key: 'image.sess',
  cookie: {
    maxAge: 3600000 * 24 * 30
  }
}));

app.locals._ = require('underscore');

// Setup your keys here (TODO: toggle between dev and production)
// dev keys
// app.locals.parseApplicationId = 'mKMQ9Hl7eGJJIwWb77WYyLfr7GpvsmuNKgGRRZyR';
// app.locals.parseJavascriptKey = 'YCphnlQGSSAZnQYtZeDhvSz5aRj0djOi0zr2k4GZ';
// app.locals.facebookApplicationId = '341320496039341';
// production keys
app.locals.parseApplicationId = 'gWQ4zjHnoXHJK15ipFVgWLUSA979mqHaZ7sOlPU9';
app.locals.parseJavascriptKey = 'c2IvVJIhJBCDFQcZtoEgST8g4SfmAvWRxdYoHJ3v';
app.locals.facebookApplicationId = '341320496039341';


// // Example reading from the request query string of an HTTP get request.
// app.get('/test', function(req, res) {
//   // GET http://example.parseapp.com/test?message=hello
//   res.send(req.query.message);
// });

// // Example reading from the request body of an HTTP post request.
// app.post('/test', function(req, res) {
//   // POST http://example.parseapp.com/test (with request body "message=hello")
//   res.send(req.body.message);
// });

// Render the pages
app.get('/cards', function(req, res) {
    var view = req.query.view
    if (view == null) {
        view = "topRated";
    }
    
    var pp = req.query.pp
    if (pp == null) {
        pp = 0;
    }

	var query = new Parse.Query("Card");    
    query.include("set");
	query.include("rarity");
	query.limit(10)
	query.skip(pp*10)
	    
    if (view == "topRated") {
		query.descending("rating");
		query.addAscending("name");
		query.exists("rating");
		
		query.find().then(function(objects) {
	       res.render('cards', { title: "Cards",
	  	 	    			     navbar: "2",
						         topRated: objects,
							     view: view,
							     pp: pp});
		});
		
    } else {
	    query.descending("numberOfViews");
	    query.addAscending("name");
	    query.exists("numberOfViews");
	    
	    query.find().then(function(objects) {
	       res.render('cards', { title: "Cards",
	  	 	    			     navbar: "2",
						         topViewed: objects,
							     view: view,
							     pp: pp});
        });
     }
});

app.get('/cardPrice', function(req, res) {
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
  		console.log(httpResponse.text);
		res.type('text/xml');
	  	res.send(httpResponse.text);
	}, function(httpResponse) {
	  	console.error('Request failed with response code ' + httpResponse.status);
	});
});

app.get('/decks', function(req, res) {
    res.render('decks', { title: "Decks",
    					  navbar: "3"});
});

app.get('/cardquiz', function(req, res) {
    var query = new Parse.Query("UserMana");
	query.include("user");
	query.descending("totalCMC");
	
	
	query.find().then(function(objects) {
	  res.render('cardquiz', { title: "Card Quiz",
	  						   navbar: "4",
							   userManas: objects});
	});
});

app.get('/', function(req, res) {
	res.render('home', { title: "",
						 navbar: "1"});
});

app.get('/sign-in', function(req, res) {
    res.render('sign-in', { title: "Sign In",
    						navbar: "5"});
});

app.get('/sign-up', function(req, res) {
    res.render('sign-up', { title: "Sign Up",
    						navbar: "6"});
});

app.use('/', require('cloud/user'));

// Attach the Express app to Cloud Code.
app.listen();
