//
//  EEPaidTableCell.m
//  SplitIt
//
//  Created by GAD ELMOZNINO on 2015-07-12.
//  Copyright (c) 2015 Eric Elmoznino. All rights reserved.
//

#import "EEPaidTableCell.h"

@interface EEPaidTableCell ()
<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *contributedSwitch;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *paidLabel;
@property (weak, nonatomic) IBOutlet UILabel *splitLabel;

@property (weak, nonatomic) IBOutlet UITextField *paidTextField;
@property (weak, nonatomic) IBOutlet UITextField *splitTextField;

@property (weak, nonatomic) IBOutlet UILabel *currencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentLabel;

@property (nonatomic, strong) UIToolbar *numberPadBar;
@property (nonatomic, strong) UIBarButtonItem *doneTypingButton;
@property (nonatomic, strong) UILabel *typedTextlabel;

@property (weak, nonatomic) IBOutlet UIView *separator;

@end

@implementation EEPaidTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.paidTextField.delegate = self;
    self.splitTextField.delegate = self;
    
    //Create the toolbar that will allow the numberPad
    //to finish typing and contain a label that displays
    //what is being typed
    self.numberPadBar = [[UIToolbar alloc] initWithFrame:
                         CGRectMake(0, 0, self.contentView.frame.size.width, 44)];
    
    self.doneTypingButton = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                             target:self
                             action:@selector(doneWithNumberPad:)];
    
    self.typedTextlabel = [[UILabel alloc] initWithFrame:
                           CGRectMake(0, 5, 150, 34)];
    [self.typedTextlabel setFont:[UIFont systemFontOfSize:14]];
    [self.typedTextlabel setBackgroundColor:[UIColor clearColor]];
    [self.typedTextlabel setTextColor:[UIColor blackColor]];
    [self.typedTextlabel setTextAlignment:NSTextAlignmentCenter];
    self.typedTextlabel.text = @"";
    self.typedTextlabel.layer.borderColor = [UIColor grayColor].CGColor;
    self.typedTextlabel.layer.borderWidth = 0.5;
    self.typedTextlabel.layer.cornerRadius = 6;
    UIBarButtonItem *labelHolder = [[UIBarButtonItem alloc]
                                    initWithCustomView:self.typedTextlabel];
    
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                               target:nil
                               action:nil];
    
    UIBarButtonItem *padding = [[UIBarButtonItem alloc]
                                initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                target:nil
                                action:nil];
    padding.width = 5;
    
    self.numberPadBar.items = @[labelHolder, spacer, self.doneTypingButton, padding];
    
    self.paidTextField.inputAccessoryView = self.numberPadBar;
    self.splitTextField.inputAccessoryView = self.numberPadBar;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.numberPadBar.hidden = YES;
    }
    
    //Format the "paid" currency label
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    NSString *currencySymbol = currencyFormatter.currencySymbol;
    self.currencyLabel.text = currencySymbol;
}

- (void)setPerson:(EEPerson *)person
{
    _person = person;
    self.nameLabel.text = person.name;
}

//Last data object to be set that affects textField values.
//Setup separator color here as well.
- (void)setEvenSplitting:(BOOL)evenSplitting
{
    _evenSplitting = evenSplitting;
    
    if (self.evenSplitting) {
        self.splitTextField.enabled = NO;
        self.splitTextField.textColor = [UIColor lightGrayColor];
        
        //Set split between percentage evenly among everyone
        [self splitEvenly];
    }
    else {
        self.splitTextField.enabled = YES;
        self.splitTextField.textColor = [UIColor blackColor];
    }
    
    //Set up separator color
    if (self.contributedSwitch.on) {
        [self separatorGreenRedOrBlue];
    }
    else {
        self.separator.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    }
}

//Must set "person" property before setting contributions and included dictionaries
- (void)setContributions:(NSMutableDictionary *)contributions
{
    _contributions = contributions;
    
    NSNumber *contributionNumber = _contributions[self.person.personKey];
    //If the person has made a contribution
    if (contributionNumber) {
        [self.contributedSwitch setOn:YES animated:NO];
        
        self.paidLabel.hidden = NO;
        self.paidTextField.hidden = NO;
        self.currencyLabel.hidden = NO;
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        self.paidTextField.text = [NSString stringWithFormat:@"%@",
                                           [formatter stringFromNumber:contributionNumber]];
    }
    else {
        [self.contributedSwitch setOn:NO animated:NO];
        
        self.paidLabel.hidden = YES;
        self.paidTextField.hidden = YES;
        self.currencyLabel.hidden = YES;
    }
}

- (void)setIncluded:(NSMutableDictionary *)included
{
    _included = included;
    
    NSNumber *splitPercentNumber = _included[self.person.personKey];
    //If the person is in the split
    if (splitPercentNumber) {
        [self.contributedSwitch setOn:YES animated:NO];
        
        self.splitLabel.hidden = NO;
        self.splitTextField.hidden = NO;
        self.percentLabel.hidden = NO;
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        self.splitTextField.text = [NSString stringWithFormat:@"%@",
                                   [formatter stringFromNumber:splitPercentNumber]];
    }
    else {
        [self.contributedSwitch setOn:NO animated:NO];
        
        self.splitLabel.hidden = YES;
        self.splitTextField.hidden = YES;
        self.percentLabel.hidden = YES;
    }
}

- (void)setUpdateCostActionBlock:(void (^)(void))updateCostActionBlock
{
    _updateCostActionBlock = updateCostActionBlock;
    self.updateCostActionBlock();
}

- (void)setUpdatePurchasePermittedBlock:(void (^)(void))updatePurchasePermittedBlock
{
    _updatePurchasePermittedBlock = updatePurchasePermittedBlock;
}

- (void)setCanGoBack:(BOOL)canGoBack
{
    _canGoBack = canGoBack;
    
    if (canGoBack) {
        //Set splitTextFields to normal if canGoBack
        self.splitTextField.backgroundColor = [UIColor clearColor];
    }
    else {
        //Set splitTextFields to red if canGoBack is false
        self.splitTextField.backgroundColor = [UIColor colorWithRed:1.0
                                                              green:0.0
                                                               blue:0.0
                                                              alpha:1.0];
    }
}

- (IBAction)switchDidChangeStates:(id)sender {
    if (self.contributedSwitch.on) {
        self.contributions[self.person.personKey] = @0;
        self.paidLabel.hidden = NO;
        self.paidTextField.hidden = NO;
        self.currencyLabel.hidden = NO;
        self.paidTextField.text = @"0";
        
        self.included[self.person.personKey] = @0;
        self.splitLabel.hidden = NO;
        self.splitTextField.hidden = NO;
        self.percentLabel.hidden = NO;
        self.splitTextField.text = @"0";
        if (self.evenSplitting) {
            [self splitEvenly];
            self.reloadTableBlock();
        }
        
        [self separatorGreenRedOrBlue];
    }
    
    else {
        [self.contributions removeObjectForKey:self.person.personKey];
        self.paidLabel.hidden = YES;
        self.paidTextField.hidden = YES;
        self.currencyLabel.hidden = YES;
        self.paidTextField.text = @"";
        self.updateCostActionBlock();
        
        [self.included removeObjectForKey:self.person.personKey];
        self.splitLabel.hidden = YES;
        self.splitTextField.hidden = YES;
        self.percentLabel.hidden = YES;
        self.splitTextField.text = @"";
        if (self.evenSplitting) {
            self.reloadTableBlock();
        }
        self.updatePurchasePermittedBlock();
        
        self.separator.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.text = @"";
    
    self.typedTextlabel.text = [NSString stringWithFormat:@"%@", textField.text];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.typedTextlabel.text = [NSString stringWithFormat:@"%@", textField.text];
    
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)doneWithNumberPad:(id)sender
{
    if ([self.paidTextField isFirstResponder]) {
        [self.paidTextField resignFirstResponder];
    }
    else if ([self.splitTextField isFirstResponder]) {
        [self.splitTextField resignFirstResponder];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    //If the user did not enter a valid number, force the textField to 0
    NSNumber *userEnteredNumber;
    if (textField == self.paidTextField) {
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        userEnteredNumber = [formatter
                             numberFromString:self.paidTextField.text];
        if (userEnteredNumber == nil) {
            self.paidTextField.text = @"0";
        }
    }
    else {
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        userEnteredNumber = [formatter
                             numberFromString:self.splitTextField.text];
        if (userEnteredNumber == nil) {
            self.splitTextField.text = @"0";
        }
    }
    
    //If the user entered a number with leading 0's
    formatter.allowsFloats = YES;
    formatter.usesGroupingSeparator = NO;
    formatter.maximumFractionDigits = 2;
    if (textField == self.paidTextField) {
        userEnteredNumber = [formatter numberFromString:self.paidTextField.text];
        userEnteredNumber = [NSNumber numberWithDouble:fabs([userEnteredNumber doubleValue])];
        self.paidTextField.text = [formatter stringFromNumber:userEnteredNumber];
    }
    else {
        userEnteredNumber = [formatter numberFromString:self.splitTextField.text];
        userEnteredNumber = [NSNumber numberWithDouble:fabs([userEnteredNumber doubleValue])];
        self.splitTextField.text = [formatter stringFromNumber:userEnteredNumber];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField==self.paidTextField) {
        [self updateContribution];
        self.updateCostActionBlock();
    }
    else {
        [self updateIncluded];
        self.updatePurchasePermittedBlock();
    }
    
    //Update all cell separator colors
    self.reloadTableBlock();
}

- (void)updateContribution
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    self.contributions[self.person.personKey] = [formatter
                                                 numberFromString:self.paidTextField.text];
}

- (void)updateIncluded
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    self.included[self.person.personKey] = [formatter
                                            numberFromString:self.splitTextField.text];
}

- (void)splitEvenly
{
    //Only include in the split if the person is included in the purchase
    if (self.included[self.person.personKey]) {
        double splitPercentage = 100.0 / (double)[[self.included allKeys] count];
        NSNumber *splitPercentageNumber = [NSNumber numberWithDouble:splitPercentage];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.allowsFloats = YES;
        formatter.usesGroupingSeparator = NO;
        formatter.maximumFractionDigits = 2;
        
        self.splitTextField.text = [formatter stringFromNumber:splitPercentageNumber];
        
        [self updateIncluded];
    }
}

- (void)separatorGreenRedOrBlue
{
    double credit = [[self.contributions valueForKey:self.person.personKey] doubleValue];
    
    double totalCost = 0;
    for (NSNumber *cost in [self.contributions allValues]) {
        totalCost += [cost doubleValue];
    }
    
    double debt = totalCost * [[self.included valueForKey:self.person.personKey] doubleValue] / 100;
    
    if (credit - debt > 0) {
        self.separator.backgroundColor = [UIColor greenColor];
    }
    else if (credit - debt < 0) {
        self.separator.backgroundColor = [UIColor redColor];
    }
    else {
        self.separator.backgroundColor = [UIColor colorWithRed:0
                                                         green:0.47843137
                                                          blue:1
                                                         alpha:1];
    }
}

@end
