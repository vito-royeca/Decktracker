//
//  FieldEditorViewController.m
//  Decktracker
//
//  Created by Jovit Royeca on 9/18/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#import "FieldEditorViewController.h"

@implementation FieldEditorViewController
{
    NSInteger _selectedIndex;
}

@synthesize delegate = _delegate;
@synthesize tblEditor = _tblEditor;
@synthesize fieldEditorType = _fieldEditorType;
@synthesize fieldName = _fieldName;
@synthesize oldValue = _oldValue;
@synthesize fieldOptions = _fieldOptions;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat dX = 0;
    CGFloat dY = 0;
    CGFloat dWidth = self.view.frame.size.width;
    CGFloat dHeight = self.view.frame.size.height;
    
    self.tblEditor = [[UITableView alloc] initWithFrame:CGRectMake(dX, dY, dWidth, dHeight)
                                                 style:UITableViewStylePlain];
    self.tblEditor.delegate = self;
    self.tblEditor.dataSource = self;
    
    UIBarButtonItem *btnOk = [[UIBarButtonItem alloc] initWithTitle:@"Ok"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(btnOkTapped:)];
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                               target:self
                                                                               action:@selector(btnCancelTapped:)];
    self.navigationItem.leftBarButtonItem = btnCancel;
    self.navigationItem.rightBarButtonItem = btnOk;
    
    [self.view addSubview:self.tblEditor];
    self.navigationItem.title = @"Editor";
    
    if (self.fieldOptions)
    {
        _selectedIndex = [self.fieldOptions indexOfObject:self.oldValue];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) btnOkTapped:(id) sender
{
    [self.delegate editorSaved:self.oldValue];
    [self.navigationController popViewControllerAnimated:NO];
}

-(void) btnCancelTapped:(id) sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

-(UIView*) createEditor
{
    UIView *editor;
    
    switch (self.fieldEditorType)
    {
        case FieldEditorTypeText:
        case FieldEditorTypeNumber:
        {
            UITextField *txtField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width-20, 30)];
            txtField.adjustsFontSizeToFitWidth = YES;
            txtField.borderStyle = UITextBorderStyleRoundedRect;
            txtField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
            txtField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
            txtField.text = self.oldValue;
            txtField.delegate = self;
            txtField.clearButtonMode = UITextFieldViewModeAlways;
            txtField.tag = 1;
            [txtField addTarget:self
                         action:@selector(textFieldDidChange:)
               forControlEvents:UIControlEventEditingChanged];
            
            UIToolbar *toolbar = [self toolbarWithDoneButton:txtField];
            txtField.inputAccessoryView = toolbar;
            
            if (self.fieldEditorType == FieldEditorTypeNumber)
            {
                txtField.keyboardType = UIKeyboardTypeNumberPad;
            }
            editor = txtField;
            break;
        }
        case FieldEditorTypeTextArea:
        {
            UITextView *txtView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width-20, self.tblEditor.frame.size.height/2)];
            txtView.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
            txtView.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
            txtView.text = self.oldValue;
            txtView.delegate = self;
            txtView.tag = 1;
            
            UIToolbar *toolbar = [self toolbarWithDoneButton:txtView];
            txtView.inputAccessoryView = toolbar;
            editor = txtView;
            break;
        }
        default:
        {
            break;
        }
    }
    
    return editor;
}

-(UIToolbar*) toolbarWithDoneButton:(UIView*) field
{
    // Add a Done button in the keyboard
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                               target:field
                                                                               action:@selector(resignFirstResponder)];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    toolbar.items = [NSArray arrayWithObject:barButton];
    
    return toolbar;
}

#pragma mark - UITableView
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (self.fieldEditorType)
    {
        case FieldEditorTypeText:
        case FieldEditorTypeTextArea:
        case FieldEditorTypeStepper:
        case FieldEditorTypeNumber:
        {
            return [NSString stringWithFormat:@"Edit %@", self.fieldName];
        }
        case FieldEditorTypeDate:
        case FieldEditorTypeSelection:
        {
            return [NSString stringWithFormat:@"Select %@", self.fieldName];
        }
        default:
        {
            return nil;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.fieldOptions)
    {
        return self.fieldOptions.count;
    }
    else
    {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.fieldEditorType == FieldEditorTypeTextArea)
    {
        return self.tblEditor.frame.size.height/2;
    }
    else
    {
        return UITableViewAutomaticDimension;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell0"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell0"];
    }
    
    switch (self.fieldEditorType)
    {
        case FieldEditorTypeText:
        case FieldEditorTypeTextArea:
        case FieldEditorTypeStepper:
        case FieldEditorTypeNumber:
        case FieldEditorTypeDate:
        {
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            [cell.contentView addSubview:[self createEditor]];
            break;
        }
        
        case FieldEditorTypeSelection:
        {
            tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            cell.textLabel.text = [self.fieldOptions[indexPath.row] description];
            cell.accessoryType = indexPath.row == _selectedIndex ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedIndex = indexPath.row;
    self.oldValue = self.fieldOptions[_selectedIndex];
    
    [self.tblEditor reloadData];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.oldValue = textField.text;
    
    if ([textField canBecomeFirstResponder])
    {
        [textField resignFirstResponder];
    }
    return YES;
}

-(void) textFieldDidChange:(id) sender
{
    UITextField *textField = sender;
    
    self.oldValue = textField.text;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    self.oldValue = textView.text;
}

@end
