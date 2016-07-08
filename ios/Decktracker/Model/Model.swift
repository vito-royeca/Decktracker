//
//  Model.swift
//  Decktracker
//
//  Created by Jovit Royeca on 5/7/15.
//  Copyright (c) 2015 Jovito Royeca. All rights reserved.
//

import Foundation
import RealmSwift

public class DTArtist: Object {
    public dynamic var name = ""
    public let cards = List<DTCard>()
}

public class DTBlock: Object {
    public dynamic var name = ""
    public let cards = List<DTSet>()
}

public class DTCard: Object {
    public dynamic var border = ""
    public dynamic var cardID = 0
    public dynamic var cmc:Float = 0.0
    public dynamic var flavor = ""
    public dynamic var handModifier = 0
    public dynamic var imageName = ""
    public dynamic var layout = ""
    public dynamic var lifeModifier = 0
    public dynamic var loyalty = 0
    public dynamic var manaCost = ""
    public dynamic var multiverseID = 0
    public dynamic var name = ""
    public dynamic var number = ""
    public dynamic var originalText = ""
    public dynamic var originalType = ""
    public dynamic var power = ""
    public dynamic var rating:Double = 0.0
    public dynamic var releaseDate = ""
    public dynamic var reserved = false
    public dynamic var sectionColor = ""
    public dynamic var sectionNameInitial = ""
    public dynamic var sectionType = ""
    public dynamic var source = ""
    public dynamic var starter = false
    public dynamic var tcgPlayerFetchDate = NSDate(timeIntervalSince1970: 1)
    public dynamic var tcgPlayerFoilPrice:Double = 0.0
    public dynamic var tcgPlayerHighPrice:Double = 0.0
    public dynamic var tcgPlayerLink = ""
    public dynamic var tcgPlayerLowPrice:Double = 0.0
    public dynamic var tcgPlayerMidPrice:Double = 0.0
    public dynamic var text = ""
    public dynamic var timeshifted = false
    public dynamic var toughness = ""
    public dynamic var type = ""
    public dynamic var watermark = ""
    public dynamic var artist: DTArtist?
    public let colors = List<DTCardColor>()
    public let foreignNames = List<DTCardForeignName>()
    public let legalities = List<DTCardLegality>()
    public let names = List<DTCard>()
    public let printings = List<DTSet>()
    public dynamic var rarity: DTCardRarity?
    public let ratings = List<DTCardRating>()
    public let rulings = List<DTCardRuling>()
    public dynamic var set: DTSet?
    public let subTypes = List<DTCardType>()
    public let superTypes = List<DTCardType>()
    public let types = List<DTCardType>()
    public let variations = List<DTCard>()
}

public class DTCardColor: Object {
    public dynamic var name = ""
    public let cards = List<DTCard>()
}

public class DTCardForeignName : Object {
    public dynamic var language = ""
    public dynamic var name = ""
    public dynamic var card: DTCard?
}

public class DTCardLegality : Object {
    public dynamic var name = ""
    public dynamic var card: DTCard?
    public dynamic var format: DTFormat?
}

public class DTCardRarity : Object {
    public dynamic var name = ""
    public let cards = List<DTSet>()
}

public class DTCardRating : Object {
    public dynamic var rating:Double = 0.0
    public dynamic var card: DTCard?
}

public class DTCardRuling : Object {
    public dynamic var date = NSDate(timeIntervalSince1970: 1)
    public dynamic var text = ""
    public dynamic var card: DTCard?
}

public class DTCardType : Object {
    public dynamic var name = ""
    public let cardSubTypes = List<DTCard>()
    public let cardSuperTypes = List<DTCard>()
    public let cardTypes = List<DTCard>()
}

public class DTComprehensiveGlossary : Object {
    public dynamic var definition = ""
    public dynamic var term = ""
    public let cardTypes = List<DTComprehensiveRule>()
}

public class DTComprehensiveRule : Object {
    public dynamic var number = ""
    public dynamic var rule = ""
    public let children = List<DTComprehensiveRule>()
    public dynamic var glossary: DTComprehensiveGlossary?
    public dynamic var parent: DTComprehensiveRule?
}

public class DTFormat : Object {
    public dynamic var name = ""
    public let legalities = List<DTCardLegality>()
}

public class DTSet: Object {
    public dynamic var border = ""
    public dynamic var code = ""
    public dynamic var gathererCode = ""
    public dynamic var magicCardsInfoCode = ""
    public dynamic var imagesDownloaded = false
    public dynamic var name = ""
    public dynamic var numberOfCards = 0
    public dynamic var oldCode = ""
    public dynamic var onlineOnly = false
    public dynamic var releaseDate = NSDate(timeIntervalSince1970: 1)
    public dynamic var sectionNameInitial = ""
    public dynamic var sectionYear = ""
    public dynamic var tcgPlayerName = ""
    public dynamic var block: DTBlock?
    public dynamic var cards = List<DTCard>()
    public dynamic var printings = List<DTCard>()
    public dynamic var type: DTSetType?
}

public class DTSetType : Object {
    public dynamic var name = ""
    public let sets = List<DTSet>()
}
