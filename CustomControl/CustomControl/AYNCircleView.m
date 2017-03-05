//
//  AYNCircleView.m
//  CustomControl
//
//  Created by Andrey Nazarov on 05/03/17.
//  Copyright © 2017 Andrey Nazarov. All rights reserved.
//

#import "AYNCircleView.h"

static CGFloat const kAYNCircleViewScrollViewContentSizeLength = 1000000000;

@interface AYNCircleView () <UIScrollViewDelegate>

@property (assign, nonatomic) BOOL isInitialized;

@property (assign, nonatomic) CGFloat circleRadius;

@property (strong, nonatomic) UIView *circleView;
@property (strong, nonatomic) UIScrollView *scrollView;

@end

@implementation AYNCircleView

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

#pragma mark - Accessors

- (void)setContentView:(UIView *)contentView {
    [_contentView removeFromSuperview];
    
    _contentView = contentView;
    
    [self.circleView insertSubview:_contentView atIndex:0];
    
    [self setNeedsLayout];
}

#pragma mark - Private

- (void)commonInit {
    self.circleView = [UIView new];
    self.circleView.layer.masksToBounds = YES;
    self.circleView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.circleView];
    
    self.scrollView = [UIScrollView new];
    self.scrollView.contentSize = CGSizeMake(kAYNCircleViewScrollViewContentSizeLength, kAYNCircleViewScrollViewContentSizeLength);
    self.scrollView.contentOffset = CGPointMake(kAYNCircleViewScrollViewContentSizeLength / 2.0, kAYNCircleViewScrollViewContentSizeLength / 2.0);
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    
    [self addSubview:self.scrollView];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.isInitialized) {
        self.isInitialized = YES;

        self.circleRadius = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) / 2;
        
        self.circleView.frame = CGRectMake(0, 0, 2 * self.circleRadius, 2 * self.circleRadius);
        self.circleView.layer.cornerRadius = self.circleRadius;
        
        self.scrollView.frame = self.circleView.bounds;
        
        self.circleView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(self.bounds));
        self.scrollView.center = self.circleView.center;
        self.contentView.frame = self.circleView.bounds;
    }
}

@end
