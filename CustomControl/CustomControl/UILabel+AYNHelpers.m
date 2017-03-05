//
//  UILabel+AYNHelpers.m
//  CustomControl
//
//  Created by Andrey Nazarov on 05/03/17.
//  Copyright © 2017 Andrey Nazarov. All rights reserved.
//

#import "UILabel+AYNHelpers.h"

@implementation UILabel (AYNHelpers)

+ (UILabel *)ayn_rotatedLabelWithText:(NSString *)text angle:(CGFloat)angle circleRadius:(CGFloat)circleRadius offset:(CGFloat)offset font:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *rotatedLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    rotatedLabel.text = text;
    
    rotatedLabel.font = font ?: [UIFont boldSystemFontOfSize:22.0];
    rotatedLabel.textColor = textColor ?: [UIColor blackColor];
    
    [rotatedLabel sizeToFit];
    
    rotatedLabel.transform = CGAffineTransformMakeRotation(angle);
    
    CGFloat angleForPoint = M_PI - angle;
    
    CGFloat xOffset = sin(angleForPoint) * (circleRadius - offset);
    CGFloat yOffset = cos(angleForPoint) * (circleRadius - offset);
    
    rotatedLabel.center = CGPointMake(circleRadius + xOffset, circleRadius + yOffset);
    
    return rotatedLabel;
}

@end
