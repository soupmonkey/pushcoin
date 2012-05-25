//
//  KeypadView.m
//  KeyPad
//
//  Created by Manuel on 03.08.10.
//  Copyright 2010 vikingosegundo. All rights reserved.
//

#import "KeypadView.h"

@implementation KeypadView
@synthesize delegate;

- (id)initWithFrame:(CGRect)r 
{
	self = [super initWithFrame:r];
	if (self == nil)
		return nil;
	[self setOpaque:NO];
	return self;
}
+ (KeypadView *)keypadViewWithFrame:(CGRect)r 
{
	KeypadView *v = [[self alloc] initWithFrame:r];
	return v;//[v autorelease];
}

/*
- (void)dealloc {
	delegate = nil;
	[keypadButtons release];
    [super dealloc];
}
*/

-(BOOL) canBecomeFirstResponder
{
	return YES;
}

-(void) setDelegate:(id <KeypadViewDelegate>)d
{
	delegate = d;
	if ( delegate != nil ) {
		NSMutableArray *array = [[NSMutableArray alloc] init];
		keypadButtons = [[NSArray alloc] init];
		
		CGPoint p;
		p = [delegate keypadOrigin];
		CGRect r;
		
		for (int i = 0; i< [self.delegate numberOfRows]; i++) {
			for (int j = 0;j< [self.delegate numberOfColumns]; j++) {
				
				r.size = [delegate sizeForButtonOnRow:i andColumn:j];
				r.origin = CGPointMake((j%[delegate numberOfColumns])*r.size.width+p.x+j/*border*/,
                                       (i%[delegate numberOfRows])*r.size.height+p.y+i/*border*/);
				UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
				b.frame = r;
				[b setBackgroundColor:[UIColor clearColor]];
				[b setOpaque:!NO];
				[b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
				[b setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                b.titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
				[b setTitle:[delegate titleForButtonOnRow:i andColumn:j] forState:UIControlStateNormal];
				[b setEnabled:[delegate isButtonEnabledAtRow:i andColumn:j]];

				
				[b addTarget:self action:@selector(fireKeypadButton:) forControlEvents: UIControlEventTouchUpInside ];
				[b addTarget:self action:@selector(setHighlightStateForSender:) forControlEvents:UIControlEventTouchDown];
				
				[b setBackgroundImage:[delegate backgroundImageForState:UIControlStateNormal 
															forKeyAtRow:i andColumn:j] 
							 forState:UIControlStateNormal];
				[b setBackgroundImage:[delegate backgroundImageForState:UIControlStateDisabled 
															forKeyAtRow:i andColumn:j] 
							 forState:UIControlStateDisabled];
				
				
				[b setBackgroundImage:[delegate backgroundImageForState:UIControlStateHighlighted 
															forKeyAtRow:i andColumn:j] 
							 forState:UIControlStateHighlighted];
				[array addObject:b];
				
			}
		}
        
               
		keypadButtons = (NSArray *)array;
		for (UIButton *b in keypadButtons) {
			[self addSubview:b];
		}
		if ([(NSObject *)delegate respondsToSelector:@selector(additionalButtonsForKeypad)]) {
			for (UIButton *b in [delegate additionalButtonsForKeypad]) {
				[self addSubview:b];
			}
		}

	}	
}

-(void)setHighlightStateForSender:(id)sender
{
	[(UIButton *)sender setHighlighted:YES];
	[sender setNeedsDisplay];
}

-(void)fireKeypadButton:(id)sender
{
	int i,x,y;
	i=[keypadButtons indexOfObject:sender];
	
	
	x = i%[delegate numberOfColumns];
	
	y = i/[delegate numberOfColumns] ;
	
	[delegate receivedValue:[delegate valueForButtonOnRow:y andColumn:x]];
}


@end
