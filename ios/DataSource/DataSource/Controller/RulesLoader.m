//
//  RulesLoader.m
//  DataSource
//
//  Created by Jovit Royeca on 11/4/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "RulesLoader.h"
#import "Database.h"
#import "DTComprehensiveGlossary.h"
#import "DTComprehensiveRule.h"

#import "TFHpple.h"

@implementation RulesLoader
{
    NSString *_lastContent;
}

-(void) parseRules
{
    NSDate *dateStart = [NSDate date];
    [[Database sharedInstance] setupDb];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"Data/MagicCompRules_20140926.htm"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    TFHpple *parser = [TFHpple hppleWithHTMLData:data];
    
    [self parse:parser];
    [[Database sharedInstance] closeDb];
    
    NSDate *dateEnd = [NSDate date];
    NSTimeInterval timeDifference = [dateEnd timeIntervalSinceDate:dateStart];
    NSLog(@"Started: %@", dateStart);
    NSLog(@"Ended: %@", dateEnd);
    NSLog(@"Time Elapsed: %@",  [JJJUtil formatInterval:timeDifference]);
}

-(void) parse:(TFHpple*) parser
{
    NSArray *nodes = [parser searchWithXPathQuery:@"//div"];

    for (TFHppleElement *element in nodes)
    {
        if ([element hasChildren])
        {
            for (TFHppleElement *child in element.children)
            {
                if ([[child tagName] isEqualToString:@"p"])
                {
                    if ([child.attributes[@"class"] isEqualToString:@"CR1100"])
                    {
                        NSString *content = [JJJUtil removeNewLines:[self extractContent:child]];
//                        NSString *content = [self extractContent:child];
                        [self createRule:content];
                    }
                    
                    else if ([child.attributes[@"class"] isEqualToString:@"CR1001"] ||
                             [child.attributes[@"class"] isEqualToString:@"CR1001a"])
                    {
                        NSString *content = [JJJUtil removeNewLines:[self extractContent:child]];
//                        NSString *content = [self extractContent:child];
                        
                        if (content.length > 0)
                        {
                            [self createRule:content];
                            _lastContent = content;
                        }
                    }
                    else if ([child.attributes[@"class"] isEqualToString:@"CREx1001"])
                    {
                        NSManagedObjectContext *currentContext = [NSManagedObjectContext MR_contextForCurrentThread];
                        NSString *content = [JJJUtil removeNewLines:[self extractContent:child]];
//                        NSString *content = [self extractContent:child];
                        
                        DTComprehensiveRule *rule = [self createRule:_lastContent];
                        
                        rule.rule = [NSString stringWithFormat:@"%@ %@", rule.rule, content];
                        [currentContext MR_save];
                        _lastContent = nil;
                    }
                    
                    else if ([child.attributes[@"class"] isEqualToString:@"CRGlossaryWord"])
                    {
                        _lastContent = [self extractContent:child];
                    }
                    else if ([child.attributes[@"class"] isEqualToString:@"CRGlossaryText"])
                    {
                        if (_lastContent) {
                            
                            DTComprehensiveGlossary *glossary = [DTComprehensiveGlossary MR_findFirstByAttribute:@"term"
                                                                                                       withValue:_lastContent];
                            
                            if (glossary)
                            {
                                NSManagedObjectContext *currentContext = [NSManagedObjectContext MR_contextForCurrentThread];
                                glossary.definition = [self extractContent:child];
                                [currentContext MR_save];
                            }
                            else
                            {
                                [self createGlossary:_lastContent withDefinition:[self extractContent:child]];
                            }
                            _lastContent = nil;
                            
                        }
                        else
                        {
                            [self createGlossary:[self extractContent:child] withDefinition:nil];
                            _lastContent = [self extractContent:child];
                        }
                    }
                }
            }
        }
    }
}

-(NSString*) extractContent:(TFHppleElement*) element
{
    NSMutableString *content = [[NSMutableString alloc] init];
    
    for (TFHppleElement *sub in element.children)
    {
        if ([sub content])
        {
            [content appendString:[sub content]];
        }
        
        if ([sub hasChildren])
        {
            [content appendString:[self extractContent:sub]];
        }
    }
    
    return content;
}

-(DTComprehensiveRule*) createRule:(NSString*) content
{
    if ([content rangeOfString:@"."].location == NSNotFound)
    {
        return nil;
    }
    
    NSRange range = [content rangeOfString:@" "];
    NSString *number = [content substringToIndex:range.location];
    NSString *text = [content substringFromIndex:range.location+1];
    
    if (!number || !text)
    {
        return nil;
    }
    
    if ([number characterAtIndex:number.length-1] == '.')
    {
        number = [number substringToIndex:range.location-1];
    }
    
    NSManagedObjectContext *currentContext = [NSManagedObjectContext MR_contextForCurrentThread];
    DTComprehensiveRule *rule = [DTComprehensiveRule MR_findFirstByAttribute:@"number"
                                                               withValue:number];
    DTComprehensiveRule *parent;
    
    if (!rule)
    {
        rule = [DTComprehensiveRule MR_createEntity];
        rule.number = number;
        rule.rule = text;
        
        range = [number rangeOfString:@"."];
        if (range.location != NSNotFound)
        {
            number = [number substringToIndex:range.location];
            parent = [DTComprehensiveRule MR_findFirstByAttribute:@"number"
                                                        withValue:number];
        }
        else
        {
            number = [number substringToIndex:1];
            parent = [DTComprehensiveRule MR_findFirstByAttribute:@"number"
                                                        withValue:number];
        }
        
        if (![rule.number isEqualToString:parent.number])
        {
            rule.parent = parent;
        }
        [currentContext MR_save];
    }
    
    return rule;
}

-(DTComprehensiveRule*) findParentRule:(NSString*) content
{
    return [DTComprehensiveRule MR_findFirstByAttribute:@"number"
                                              withValue:[content substringToIndex:1]];
}

-(DTComprehensiveGlossary*) createGlossary:(NSString*) term withDefinition:(NSString*) definition
{
    NSManagedObjectContext *currentContext = [NSManagedObjectContext MR_contextForCurrentThread];
    DTComprehensiveGlossary *glossary = [DTComprehensiveGlossary MR_findFirstByAttribute:@"term"
                                                                               withValue:term];
    
    if (!glossary)
    {
        glossary = [DTComprehensiveGlossary MR_createEntity];
        glossary.term = term;
        glossary.definition = definition;
        [currentContext MR_save];
    }
    
    return glossary;
}

@end
