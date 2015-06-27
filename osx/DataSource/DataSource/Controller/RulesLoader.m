//
//  RulesLoader.m
//  DataSource
//
//  Created by Jovit Royeca on 11/4/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "RulesLoader.h"
#import "Database.h"

#import "TFHpple.h"

@implementation RulesLoader
{
    NSString *_lastContent;
}

-(void) json2Database
{
    [[Database sharedInstance] setupDb];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"Data/MagicCompRules_20140926.htm"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    TFHpple *parser = [TFHpple hppleWithHTMLData:data];
    
    // clean first
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    NSLog(@"-ComprehensiveRules");
    [realm deleteObjects:[DTComprehensiveRule allObjects]];
    NSLog(@"-ComprehensiveGlossaries");
    [realm deleteObjects:[DTComprehensiveGlossary allObjects]];
    [realm commitWriteTransaction];
    
    [self parse:parser];
    
    realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    for (DTComprehensiveRule *parent in [DTComprehensiveRule objectsWithPredicate:[NSPredicate predicateWithFormat:@"parent = nil"]])
    {
        for (DTComprehensiveRule *child in [DTComprehensiveRule objectsWithPredicate:[NSPredicate predicateWithFormat:@"parent = %@", parent]])
        {
            [parent.children addObject:child];
        }
    }
    [realm commitWriteTransaction];
    
    [[Database sharedInstance] closeDb];
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
                        [self createRuleWithContent:content cascadeRule:NO];
                    }
                    
                    else if ([child.attributes[@"class"] isEqualToString:@"CR1001"] ||
                             [child.attributes[@"class"] isEqualToString:@"CR1001a"])
                    {
                        NSString *content = [JJJUtil removeNewLines:[self extractContent:child]];
                        
                        if (content.length > 0)
                        {
                            [self createRuleWithContent:content cascadeRule:NO];
                            _lastContent = content;
                        }
                    }
                    else if ([child.attributes[@"class"] isEqualToString:@"CREx1001"])
                    {
                        NSString *content = [JJJUtil removeNewLines:[self extractContent:child]];
                        
                        [self createRuleWithContent:content cascadeRule:YES];
                        _lastContent = nil;
                    }
                    
                    else if ([child.attributes[@"class"] isEqualToString:@"CRGlossaryWord"])
                    {
                        _lastContent = [self extractContent:child];
                    }
                    else if ([child.attributes[@"class"] isEqualToString:@"CRGlossaryText"])
                    {
                        if (_lastContent) {
                            
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"term = %@", _lastContent];
                            DTComprehensiveGlossary *glossary = [[DTComprehensiveGlossary objectsWithPredicate:predicate] firstObject];
                            if (glossary)
                            {
                                RLMRealm *realm = [RLMRealm defaultRealm];
                                [realm beginWriteTransaction];
                                NSLog(@"^ComprehensiveGlossary: %@", glossary.term);
                                glossary.definition = [self extractContent:child];
                                [realm commitWriteTransaction];
                            }
                            else
                            {
                                [self createGlossaryWithTerm:_lastContent andDefinition:[self extractContent:child]];
                            }
                            _lastContent = nil;
                            
                        }
                        else
                        {
                            [self createGlossaryWithTerm:[self extractContent:child] andDefinition:nil];
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

-(DTComprehensiveRule*) createRuleWithContent:(NSString*) content cascadeRule:(BOOL) cascadeRule
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
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"number = %@", number];
    DTComprehensiveRule *rule = [[DTComprehensiveRule objectsWithPredicate:predicate] firstObject];
    DTComprehensiveRule *parent;
    
    if (!rule)
    {
        rule = [[DTComprehensiveRule alloc] init];
        rule.number = number;
        rule.rule = text;
        
        range = [number rangeOfString:@"."];
        if (range.location != NSNotFound)
        {
            number = [number substringToIndex:range.location];
            predicate = [NSPredicate predicateWithFormat:@"number = %@", number];
            parent = [[DTComprehensiveRule objectsWithPredicate:predicate] firstObject];
        }
        else
        {
            number = [number substringToIndex:1];
            predicate = [NSPredicate predicateWithFormat:@"number = %@", number];
            parent = [[DTComprehensiveRule objectsWithPredicate:predicate] firstObject];
        }
        
        if (![rule.number isEqualToString:parent.number])
        {
            rule.parent = parent;
        }
        
        if (cascadeRule)
        {
            rule.rule = [NSString stringWithFormat:@"%@ %@", rule.rule, content];
        }

        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        NSLog(@"+ComprehensiveRule: %@", rule.number);
        [realm addObject:rule];
        [realm commitWriteTransaction];
    }
    
    return rule;
}

-(DTComprehensiveRule*) findParentRule:(NSString*) content
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"number = %@", [content substringToIndex:1]];
    return [[DTComprehensiveRule objectsWithPredicate:predicate] firstObject];
}

-(DTComprehensiveGlossary*) createGlossaryWithTerm:(NSString*) term andDefinition:(NSString*) definition
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"term = %@", term];
    DTComprehensiveGlossary *glossary = [[DTComprehensiveGlossary objectsWithPredicate:predicate] firstObject];
    
    if (!glossary)
    {
        glossary = [[DTComprehensiveGlossary alloc] init];
        glossary.term = term;
        glossary.definition = definition ? definition : @"";
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        NSLog(@"+ComprehensiveGlossary: %@", glossary.term);
        [realm addObject:glossary];
        [realm commitWriteTransaction];
    }
    
    return glossary;
}

@end
