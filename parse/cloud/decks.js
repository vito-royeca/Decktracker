exports.decks = function(req, res) {
	res.render('decks', { title: "Decks",
    					  navbar: "3"});
}