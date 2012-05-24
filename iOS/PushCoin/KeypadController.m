//
//  KeypadController.m
//  PushCoin
//
//  Created by Gilbert Cheung on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KeypadController.h"
#import "AppDelegate.h"
#import "NSString+HexStringToBytes.h"

BOOL REVERSE_KEYPAD = YES;
int KeyBackgroundStyle = 1;

@implementation KeypadController

@synthesize placeHolderView;
@synthesize keypadView;
@synthesize displayBackground;
@synthesize displayLabel;
@synthesize amountString;
@synthesize payment;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self prepareKeypad]; 
    self.amountString = @"";
    self.payment = [[PushCoinPayment alloc] init];
}

- (void)viewDidUnload
{
    [self setPlaceHolderView:nil];
    [self setKeypadView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) prepareKeypad
{
    self.displayBackground = [[UIView alloc] initWithFrame:
                              CGRectMake(0, 0, 
                                         self.placeHolderView.frame.size.width, 87)];
    self.displayBackground.opaque = YES;
    self.displayBackground.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"display_background.png"]];
    
    self.displayLabel = [[UILabel alloc] initWithFrame:
                         CGRectInset(self.displayBackground.frame, 5.0f, 5.0f)];    
    self.displayLabel.opaque = NO;
	self.displayLabel.font = [UIFont systemFontOfSize:50.0f];
    self.displayLabel.textColor = [UIColor blackColor];
    self.displayLabel.backgroundColor = [UIColor clearColor];
    self.displayLabel.textAlignment = UITextAlignmentRight;
    
    self.keypadView = [KeypadView keypadViewWithFrame:
                       CGRectMake(0, 87.0, 
                                  self.placeHolderView.frame.size.width,
                                  self.placeHolderView.frame.size.height - 87.0)];
    
	self.keypadView.delegate = self;	
    self.keypadView.opaque = YES;
    
    [self.placeHolderView addSubview:self.displayBackground];
    [self.placeHolderView addSubview:self.displayLabel];
    [self.placeHolderView addSubview:self.keypadView];        
}



- (IBAction)amountTextFieldTouched:(id)sender
{

}



#pragma mark -
#pragma mark Keypads


-(int) numberOfRows
{
	return 4;
}

-(int) numberOfColumns
{
	return 3;
}

-(CGSize) sizeForButtonOnRow:(int)row 
                   andColumn:(int)column
{
    int width = self.keypadView.frame.size.width / 3;
    int height = self.keypadView.frame.size.height / 4;
    
    return CGSizeMake(width, height);
}

-(NSString *) titleForButtonOnRow:(int)row
                        andColumn:(int)column
{
	if (REVERSE_KEYPAD) {		
		if (row == 0) {
			if (column == 0) return @"7";
			if (column == 1) return @"8";
			if (column == 2) return @"9";
		}
		if (row == 1) {
			if (column == 0) return @"4";
			if (column == 1) return @"5";
			if (column == 2) return @"6";
		}
		if (row == 2) {
			if (column == 0) return @"1";
			if (column == 1) return @"2";
			if (column == 2) return @"3";
		}
		if (row == 3) {
            if (column == 0) return @"Receiver";
			if (column == 1) return @"0";
            if (column == 2) return @"OK";
        }
		return @"";
	} else {
		if (row == 3) {
            if (column == 0) return @"Receiver";
			if (column == 1) return @"0";
            if (column == 2) return @"OK";
			return @"";
		}
		return [NSString stringWithFormat:@"%d", row*[self.keypadView.delegate numberOfColumns]+column+1];
	}
	return nil;
}

-(id) valueForButtonOnRow:(int)row 
                andColumn:(int)column
{
    return [self titleForButtonOnRow:row andColumn:column];
}

-(void) receivedValue:(id)value
{
    if ([value isEqualToString:@"OK"] == YES)
    {
        [self.delegate keypadControllerDidClose:self];
        return;
    }
    else if ([value isEqualToString:@"Receiver"] == YES)
    {
//        ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
 //       picker.peoplePickerDelegate = self;
  //      [self presentModalViewController:picker animated:YES];
    }
    else
    {
        // Empty Check
        if (self.displayLabel.text.length == 0)
        {
            self.amountString = @"";
        }
        
        // Sanity check (8.2)
        if (self.amountString.length < 10)
        {
            self.amountString = [self.amountString stringByAppendingFormat:@"%@", value];
        }
        
        // Zero check
        if ([self.amountString isEqualToString:@"0"])
        {
            self.amountString =@"";
        }
        
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        NSNumber *number = [f numberFromString:self.amountString];
        NSString *numStr = [NSString stringWithFormat:@"$ %.2lf", number.doubleValue / 100];
        self.displayLabel.text = numStr;
        
        self.payment.amountValue = [number intValue];
        self.payment.amountScale = -2;
    }
}

-(UIImage *) backgroundImageForState:(UIControlState)state 
                         forKeyAtRow:(int)row 
                           andColumn:(int)column
{
    if (state != UIControlStateHighlighted)
        return [UIImage imageNamed:@"keyBG.png"];
    else
        return [UIImage imageNamed:@"keyBG_touched.png"];
}

-(CGPoint) keypadOrigin
{
	return CGPointMake(0, 0);
}

-(BOOL)isButtonEnabledAtRow:(int)row 
                  andColumn:(int)column
{
	return ![[self titleForButtonOnRow:row andColumn:column] isEqualToString:@""];
}


@end
