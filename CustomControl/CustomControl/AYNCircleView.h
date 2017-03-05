//
//  AYNCircleView.h
//  CustomControl
//
//  Created by Andrey Nazarov on 05/03/17.
//  Copyright © 2017 Andrey Nazarov. All rights reserved.
//

@import UIKit;

@interface AYNCircleView : UIView

@property (assign, nonatomic) NSInteger numberOfLabels;

@property (strong, nonatomic) UIView *contentView;

@property (strong, nonatomic) UIFont *labelFont;
@property (strong, nonatomic) UIColor *labelTextColor;

@end
