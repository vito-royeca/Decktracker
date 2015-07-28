
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


// cards
var cards = require('cloud/cards.js');
app.get('/cards', function(req, res) {
    cards.root(req,res);
});
app.get('/cardsSearch', function(req, res) {
    cards.search(req,res);
});
app.get('/cardsTopRated', function(req, res) {
    cards.topRated(req,res);
});
app.get('/cardsTopViewed', function(req, res) {
    cards.topViewed(req,res);
});
app.get('/cardDetails', function(req, res) {
    cards.details(req,res);
});
app.get('/cardPrice', function(req, res) {
    cards.price(req,res);
});
app.get('/cardImage', function(req, res) {
    cards.image(req,res);
});

// decks
var decks = require('cloud/decks.js');
app.get('/decks', function(req, res) {
    decks.decks(req,res);
});

// card quiz
var cardquiz = require('cloud/cardquiz.js');
app.get('/cardquiz', function(req, res) {
    cardquiz.cardquiz(req,res);
});

// home
app.get('/', function(req, res) {
	res.render('home', { title: "",
						 navbar: "1"});
});

// sign-in
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
