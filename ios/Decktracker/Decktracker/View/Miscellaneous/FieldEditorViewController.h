//
//  FieldEditorViewController.h
//  Decktracker
//
//  Created by Jovit Royeca on 9/18/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FieldEditorType)
{
    FieldEditorTypeText,
    FieldEditorTypeTextArea,
    FieldEditorTypeStepper,
    FieldEditorTypeNumber,
    FieldEditorTypeDate,
    FieldEditorTypeSelection
};

@protocol FieldEditorViewControllerDelegate <NSObject>

-(void) editorSaved:(id) newValue;

@end

@interface FieldEditorViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property(strong,nonatomic) id<FieldEditorViewControllerDelegate> delegate;
@property(strong,nonatomic) UITableView *tblEditor;

@property(nonatomic) FieldEditorType fieldEditorType;
@property(strong,nonatomic) NSString *fieldName;
@property(strong,nonatomic) id oldValue;
@property(strong,nonatomic) NSArray *fieldOptions;

@end
