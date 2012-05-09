//
//  SpringBoardIconCell.m
//  PushCoin
//
//  Created by Gilbert Cheung on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "SpringBoardIconCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation SpringBoardIconCell

- (id) initWithFrame: (CGRect) frame reuseIdentifier:(NSString *) reuseIdentifier
{
    self = [super initWithFrame: frame reuseIdentifier: reuseIdentifier];
    if ( self == nil )
        return ( nil );
    
    _iconView = [[UIImageView alloc] initWithFrame: CGRectMake(0.0, 0.0, 72.0, 72.0)];
    _iconView.backgroundColor = [UIColor clearColor];
    _iconView.opaque = NO;
//  _iconView.layer.shadowPath = path.CGPath;
//  _iconView.layer.shadowRadius = 20.0;
//  _iconView.layer.shadowOpacity = 0.4;
//  _iconView.layer.shadowOffset = CGSizeMake( 20.0, 20.0 );
    
    [self.contentView addSubview: _iconView];
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    self.contentView.opaque = NO;
    self.opaque = NO;
    
    self.selectionStyle = AQGridViewCellSelectionStyleNone;
    
    return ( self );
}


- (UIImage *) icon
{
    return ( _iconView.image );
}

- (void) setIcon: (UIImage *) anIcon
{
    _iconView.image = anIcon;
}

@end