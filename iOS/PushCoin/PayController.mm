//
//  FirstViewController.m
//  PushCoin
//
//  Created by Gilbert Cheung on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PayController.h"
#import "VSKeypadView.h"
#import "PushCoinConfig.h"
#import "KeychainItemWrapper.h"
#import "AppDelegate.h"
#import "NSString+HexStringToBytes.h"

@implementation PayController
@synthesize amountTextField;
@synthesize encodedData;
@synthesize receiverLabel;
@synthesize scrollView;
@synthesize pageControl;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    buffer_ = [[NSMutableData alloc] initWithLength:PushCoinWebServiceOutBufferSize];
    parser_ = [[PushCoinMessageParser alloc] init];

    self.scrollView.delegate = self;
    
    emptyCellIndex_ = NSNotFound;
    
    keypadView_ = [VSKeypadView keypadViewWithFrame:
                       CGRectMake(self.scrollView.frame.size.width, 0, 
                                  self.scrollView.frame.size.width,
                                  self.scrollView.frame.size.height)];
	keypadView_.delegate = self;	
	[keypadView_ setOpaque:YES];
    [self.scrollView addSubview:keypadView_];    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width * 2, 
                                               self.scrollView.frame.size.height)];  
    
   
    enteredAmountString_ = @"";
    
    gridView_ = [[AQGridView alloc] initWithFrame: 
                 CGRectMake(0, 0,
                            self.scrollView.frame.size.width,
                             self.scrollView.frame.size.height)];
    gridView_.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    gridView_.backgroundColor = [UIColor colorWithRed:119.0/255.0 green:136.0/255.0 blue:153.0/255.0 alpha:1.0];
    gridView_.opaque = NO;
    gridView_.dataSource = self;
    gridView_.delegate = self;
    gridView_.scrollEnabled = NO;
    
    [self.scrollView addSubview:gridView_];    
    
    /*
    // add our gesture recognizer to the grid view
    UILongPressGestureRecognizer * gr = [[UILongPressGestureRecognizer alloc] initWithTarget: self action: @selector(moveActionGestureRecognizerStateChanged:)];
    gr.minimumPressDuration = 0.5;
    gr.delegate = self;
    [gridView_ addGestureRecognizer: gr];
    */
    
    if ( icons_ == nil )
    {
        icons_ = [[NSMutableArray alloc] initWithCapacity: 9];
        UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0.0, 0.0, 72.0, 72.0)
                                                         cornerRadius: 14.0];
        
        for ( NSUInteger i = 0; i < 9; i++ )
        {
            UIGraphicsBeginImageContext( CGSizeMake(72.0, 72.0) );
            
            // clear background
            [[UIColor clearColor] set];
            UIRectFill( CGRectMake(0.0, 0.0, 72.0, 72.0) );
            
            // fill the rounded rectangle
            //[color set];
            [[UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:210.0/255.0 alpha:1.0] set];
            [path fill];
            
            [[UIColor blackColor] set];
            NSString * text = [NSString stringWithFormat:@"$%d", i + 1];
            [text drawInRect:CGRectMake(0.0, 30.0, 72.0, 20.0)
                    withFont:[UIFont systemFontOfSize:20]
               lineBreakMode:UILineBreakModeWordWrap
                   alignment:UITextAlignmentCenter];
              
            UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            // put the image into our list
            [icons_ addObject: image];
        }
    }
    
    [gridView_ reloadData];
    
}

- (void)viewDidUnload
{
    [self setAmountTextField:nil];
    [self setReceiverLabel:nil];
    [self setScrollView:nil];
    [self setPageControl:nil];
    gridView_ = nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //hide keyboard
    //if (textField == amountTextField)
    //    [textField resignFirstResponder];
    
    [self push:textField];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return NO;
}

- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark -
#pragma mark QRController


- (void)prepareForSegue:(UIStoryboardSegue *)segue 
                 sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"SegueToQR"])
	{
		UIViewController *viewController = segue.destinationViewController;
		QRViewController *qrViewController = (QRViewController *)viewController;
		qrViewController.delegate = self;
        [qrViewController setQRData:encodedData
                        withSummary:self.amountTextField.text];
	}
}

-(void)qrViewControllerDidCloseQR:(QRViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)push:(id)sender
{
    NSDate * now = [NSDate date];
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    NSNumber *number = [f numberFromString:enteredAmountString_];
    
    //set data
    PaymentTransferAuthorizationMessage * msgOut = [[PaymentTransferAuthorizationMessage alloc] init];
    PCOSRawData * dataOut = [[PCOSRawData alloc] initWithData:buffer_];
    
    msgOut.prv_block.mat.data = self.appDelegate.authToken.hexStringToBytes;
    msgOut.prv_block.user_data.string=@"";
    
    msgOut.pub_block.utc_ctime.val = (SInt64)[now timeIntervalSince1970];
    msgOut.pub_block.utc_etime.val = (SInt64)[now timeIntervalSince1970] + 60; /* exp in 1 min */
    
    msgOut.pub_block.payment_limit.value.val = number.intValue;
    msgOut.pub_block.payment_limit.scale.val = -2;
    
    msgOut.pub_block.currency.string = @"USD";
    msgOut.pub_block.keyid.data = [PushCoinRSAPublicKeyID hexStringToBytes];
    msgOut.pub_block.receiver.string = @"";
    msgOut.pub_block.note.string = @"";
    
    [parser_ encodeMessage:msgOut to:dataOut];
    encodedData = dataOut.consumedData;
    
    if (encodedData.length)
    {
        //show qr view
        [self performSegueWithIdentifier:@"SegueToQR"
                                  sender:self ];   
    }
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
    int width = self.scrollView.frame.size.width / 3;
    int height = self.scrollView.frame.size.height / 4;
       
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
		return [NSString stringWithFormat:@"%d", row*[keypadView_.delegate numberOfColumns]+column+1];
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
        [self push:nil];
        return;
    }
    else if ([value isEqualToString:@"Receiver"] == YES)
    {
        ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
        picker.peoplePickerDelegate = self;
        [self presentModalViewController:picker animated:YES];
    }
    else
    {
        // Empty Check
        if (amountTextField.text.length == 0)
        {
            enteredAmountString_ = @"";
        }

        // Sanity check (8.2)
        if (enteredAmountString_.length < 10)
        {
            enteredAmountString_ = [enteredAmountString_ stringByAppendingFormat:@"%@", value];
        }
    
        // Zero check
        if ([enteredAmountString_ isEqualToString:@"0"])
        {
            enteredAmountString_ =@"";
        }
        
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        NSNumber *number = [f numberFromString:enteredAmountString_];
        NSString *numStr = [NSString stringWithFormat:@"$ %.2lf", number.doubleValue / 100];
        amountTextField.text = numStr;
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

#pragma mark -
#pragma mark peoplePicker delegates


- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissModalViewControllerAnimated:YES];
}


- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person 
{
    [self selectReceiver:person];
    [self dismissModalViewControllerAnimated:YES];
    
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}


- (void)selectReceiver:(ABRecordRef)receiver
{
    NSString* name = (__bridge_transfer NSString*)ABRecordCopyValue(receiver,                                                                    
                                                                    kABPersonFirstNameProperty);
    NSString* email = nil;
    ABMultiValueRef emails = ABRecordCopyValue(receiver, kABPersonEmailProperty);
    
    if (ABMultiValueGetCount(emails) > 0) 
    {
        email = (__bridge_transfer NSString*)
        ABMultiValueCopyValueAtIndex(emails, 0);
    } 
    else 
    {
        email = @"[None]";
    }
    receiverLabel.text = [NSString stringWithFormat:@"Pay to: %@ <%@>", name, email];
}


#pragma mark -
#pragma mark UIScrollViewDelegate


- (void)scrollViewDidScroll:(UIScrollView *)sender {
   
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
   
}



#pragma mark -
#pragma mark UIGestureRecognizer Delegate/Actions

/*
- (BOOL) gestureRecognizerShouldBegin: (UIGestureRecognizer *) gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView: gridView_];
    if ( [gridView_ indexForItemAtPoint: location] < [icons_ count] )
        return ( YES );
    
    // touch is outside the bounds of any icon cells, so don't start the gesture
    return ( NO );
}

- (void) moveActionGestureRecognizerStateChanged: (UIGestureRecognizer *) recognizer
{
    switch ( recognizer.state )
    {
        default:
        case UIGestureRecognizerStateFailed:
            // do nothing
            break;
            
        case UIGestureRecognizerStatePossible:
        case UIGestureRecognizerStateCancelled:
        {
            [gridView_ beginUpdates];
            
            if ( emptyCellIndex_ != dragOriginIndex_ )
            {
                [gridView_ moveItemAtIndex: emptyCellIndex_ toIndex: dragOriginIndex_ withAnimation: AQGridViewItemAnimationFade];
            }
            
            emptyCellIndex_ = dragOriginIndex_;
            
            // move the cell back to its origin
            [UIView beginAnimations: @"SnapBack" context: NULL];
            [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
            [UIView setAnimationDuration: 0.5];
            [UIView setAnimationDelegate: self];
            [UIView setAnimationDidStopSelector: @selector(finishedSnap:finished:context:)];
            
            CGRect f = draggingCell_.frame;
            f.origin = dragOriginCellOrigin_;
            draggingCell_.frame = f;
            
            [UIView commitAnimations];
            
            [gridView_ endUpdates];
            
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        {
            CGPoint p = [recognizer locationInView: gridView_];
            NSUInteger index = [gridView_ indexForItemAtPoint: p];
			if ( index == NSNotFound )
			{
				// index is the last available location
				index = [icons_ count] - 1;
			}
            
            // update the data store
            id obj = [icons_ objectAtIndex: dragOriginIndex_];
            [icons_ removeObjectAtIndex: dragOriginIndex_];
            [icons_ insertObject: obj atIndex: index];
            
            if ( index != emptyCellIndex_ )
            {
                [gridView_ beginUpdates];
                [gridView_ moveItemAtIndex: emptyCellIndex_ toIndex: index withAnimation: AQGridViewItemAnimationFade];
                emptyCellIndex_ = index;
                [gridView_ endUpdates];
            }
            
            // move the real cell into place
            [UIView beginAnimations: @"SnapToPlace" context: NULL];
            [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
            [UIView setAnimationDuration: 0.5];
            [UIView setAnimationDelegate: self];
            [UIView setAnimationDidStopSelector: @selector(finishedSnap:finished:context:)];
            
            CGRect r = [gridView_ rectForItemAtIndex: emptyCellIndex_];
            CGRect f = draggingCell_.frame;
            f.origin.x = r.origin.x + floorf((r.size.width - f.size.width) * 0.5);
            f.origin.y = r.origin.y + floorf((r.size.height - f.size.height) * 0.5) - gridView_.contentOffset.y;
            NSLog( @"Gesture ended-- moving to %@", NSStringFromCGRect(f) );
            draggingCell_.frame = f;
            
            draggingCell_.transform = CGAffineTransformIdentity;
            draggingCell_.alpha = 1.0;
            
            [UIView commitAnimations];
            break;
        }
            
        case UIGestureRecognizerStateBegan:
        {
            NSUInteger index = [gridView_ indexForItemAtPoint: [recognizer locationInView: gridView_]];
            emptyCellIndex_ = index;    // we'll put an empty cell here now
            
            // find the cell at the current point and copy it into our main view, applying some transforms
            AQGridViewCell * sourceCell = [gridView_ cellForItemAtIndex: index];
            CGRect frame = [self.view convertRect: sourceCell.frame fromView: gridView_];
            draggingCell_ = [[SpringBoardIconCell alloc] initWithFrame: frame reuseIdentifier: @""];
            draggingCell_.icon = [icons_ objectAtIndex: index];
            [self.view addSubview: draggingCell_];
            
            // grab some info about the origin of this cell
            dragOriginCellOrigin_ = frame.origin;
            dragOriginIndex_ = index;
            
            [UIView beginAnimations: @"" context: NULL];
            [UIView setAnimationDuration: 0.2];
            [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
            
            // transformation-- larger, slightly transparent
            draggingCell_.transform = CGAffineTransformMakeScale( 1.2, 1.2 );
            draggingCell_.alpha = 0.7;
            
            // also make it center on the touch point
            draggingCell_.center = [recognizer locationInView: self.view];
            
            [UIView commitAnimations];
            
            // reload the grid underneath to get the empty cell in place
            [gridView_ reloadItemsAtIndices: [NSIndexSet indexSetWithIndex: index]
                              withAnimation: AQGridViewItemAnimationNone];
            
            break;
        }
            
        case UIGestureRecognizerStateChanged:
        {
            // update draging cell location
            draggingCell_.center = [recognizer locationInView: self.view];
            
            // don't do anything with content if grid view is in the middle of an animation block
            if ( gridView_.isAnimatingUpdates )
                break;
            
            // update empty cell to follow, if necessary
            NSUInteger index = [gridView_ indexForItemAtPoint: [recognizer locationInView: gridView_]];
            
			// don't do anything if it's over an unused grid cell
			if ( index == NSNotFound )
			{
				// snap back to the last possible index
				index = [icons_ count] - 1;
			}
            
            if ( index != emptyCellIndex_ )
            {
                NSLog( @"Moving empty cell from %u to %u", emptyCellIndex_, index );
                
                // batch the movements
                [gridView_ beginUpdates];
                
                // move everything else out of the way
                if ( index < emptyCellIndex_ )
                {
                    for ( NSUInteger i = index; i < emptyCellIndex_; i++ )
                    {
                        NSLog( @"Moving %u to %u", i, i+1 );
                        [gridView_ moveItemAtIndex: i toIndex: i+1 withAnimation: AQGridViewItemAnimationFade];
                    }
                }
                else
                {
                    for ( NSUInteger i = index; i > emptyCellIndex_; i-- )
                    {
                        NSLog( @"Moving %u to %u", i, i-1 );
                        [gridView_ moveItemAtIndex: i toIndex: i-1 withAnimation: AQGridViewItemAnimationFade];
                    }
                }
                
                [gridView_ moveItemAtIndex: emptyCellIndex_ toIndex: index withAnimation: AQGridViewItemAnimationFade];
                emptyCellIndex_ = index;
                
                [gridView_ endUpdates];
            }
            
            break;
        }
    }
}

- (void) finishedSnap: (NSString *) animationID finished: (NSNumber *) finished context: (void *) context
{
    NSIndexSet * indices = [[NSIndexSet alloc] initWithIndex: emptyCellIndex_];
    emptyCellIndex_ = NSNotFound;
    
    // load the moved cell into the grid view
    [gridView_ reloadItemsAtIndices: indices withAnimation: AQGridViewItemAnimationNone];
    
    // dismiss our copy of the cell
    [draggingCell_ removeFromSuperview];
    draggingCell_ = nil;
    
}
*/

#pragma mark -
#pragma mark GridView Data Source

- (NSUInteger) numberOfItemsInGridView: (AQGridView *) gridView
{
    return ( [icons_ count] );
}

- (AQGridViewCell *) gridView: (AQGridView *) gridView cellForItemAtIndex: (NSUInteger) index
{
    static NSString * EmptyIdentifier = @"EmptyIdentifier";
    static NSString * CellIdentifier = @"CellIdentifier";
    
    if ( index == emptyCellIndex_ )
    {
        NSLog( @"Loading empty cell at index %u", index );
        AQGridViewCell * hiddenCell = [gridView dequeueReusableCellWithIdentifier: EmptyIdentifier];
        if ( hiddenCell == nil )
        {
            // must be the SAME SIZE AS THE OTHERS
            // Yes, this is probably a bug. Sigh. Look at -[AQGridView fixCellsFromAnimation] to fix
            hiddenCell = [[AQGridViewCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 72.0, 72.0)
                                               reuseIdentifier: EmptyIdentifier];
        }
        
        hiddenCell.hidden = YES;
        return ( hiddenCell );
    }
    
    SpringBoardIconCell * cell = (SpringBoardIconCell *)[gridView dequeueReusableCellWithIdentifier: CellIdentifier];
    if ( cell == nil )
    {
        cell = [[SpringBoardIconCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 72.0, 72.0) reuseIdentifier: CellIdentifier];
    }
    
    cell.icon = [icons_ objectAtIndex: index];
    
    return ( cell );
}

- (CGSize) portraitGridCellSizeForGridView: (AQGridView *) gridView
{
    return ( CGSizeMake(self.scrollView.frame.size.width / 3, self.scrollView.frame.size.height / 3) );
}

-(void)gridView:(AQGridView *)gridView didSelectItemAtIndex:(NSUInteger)index
{
    self.amountTextField.text = [NSString stringWithFormat:@"$ %d.00", index + 1];
    [gridView deselectItemAtIndex:index animated:YES];
    
    [self push:gridView];
}

@end
