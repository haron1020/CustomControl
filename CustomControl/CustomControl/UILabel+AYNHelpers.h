//
//  UILabel+AYNHelpers.h
//  CustomControl
//
//  Created by Andrey Nazarov on 05/03/17.
//  Copyright © 2017 Andrey Nazarov. All rights reserved.
//

@import UIKit;

@interface UILabel (AYNHelpers)

+ (UILabel *)ayn_rotatedLabelWithText:(NSString *)text angle:(CGFloat)angle circleRadius:(CGFloat)circleRadius offset:(CGFloat)offset font:(UIFont *)font textColor:(UIColor *)textColor;

@end
