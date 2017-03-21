//
//  AYNCircleView.m
//  CustomControl
//
//  Created by Andrey Nazarov on 05/03/17.
//  Copyright © 2017 Andrey Nazarov. All rights reserved.
//

#import "AYNCircleView.h"

#import "UILabel+AYNHelpers.h"

#import "math.h"

typedef NS_ENUM(NSUInteger, AYNCircleViewHalf) {
    AYNCircleViewHalfLeft,
    AYNCircleViewHalfRight,
};

static CGFloat const kAYNCircleViewScrollViewContentSizeLength = 1000000000;
static CGFloat const kAYNCircleViewLabelOffset = 10;

@interface AYNCircleView () <UIScrollViewDelegate>

@property (assign, nonatomic) NSUInteger numberOfLabels;

@property (assign, nonatomic) BOOL isInitialized;

@property (assign, nonatomic) CGFloat circleRadius;
@property (assign, nonatomic, readonly) CGFloat circleLength;
@property (assign, nonatomic) CGFloat angleStep;

@property (assign, nonatomic) CGFloat currentAngle;
@property (assign, nonatomic) CGPoint startPoint;
@property (assign, nonatomic) CGFloat previousAngle;

@property (weak, nonatomic) IBOutlet UIView *circleView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewDimension;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewOffset;

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

- (void)setCircleRadius:(CGFloat)circleRadius {
    _circleRadius = circleRadius;
    
    _circleLength = 2 * M_PI * circleRadius;
}

- (NSInteger)value {
    NSInteger value = self.currentAngle > 0 ? floorf(self.currentAngle / self.angleStep) - self.numberOfLabels : floorf(self.currentAngle / self.angleStep);
    
    return labs(value) % self.numberOfLabels;
}

#pragma mark - Private

- (void)commonInit {
    UIView *nibView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil].firstObject;
    [self addSubview:nibView];
    
    self.scrollView.contentSize = CGSizeMake(kAYNCircleViewScrollViewContentSizeLength, kAYNCircleViewScrollViewContentSizeLength);
    self.scrollView.contentOffset = CGPointMake(kAYNCircleViewScrollViewContentSizeLength / 2.0, kAYNCircleViewScrollViewContentSizeLength / 2.0);
    
    self.scrollView.delegate = self;
    self.startPoint = self.scrollView.contentOffset;
    self.numberOfLabels = 12;
    
    [self addLabelsWithNumber:self.numberOfLabels];
    
    __weak __typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
        strongSelf.isInitialized = NO;
        
        [strongSelf setNeedsLayout];
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)addLabelsWithNumber:(NSInteger)numberOfLabels {
    [self.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
        
    self.angleStep = 2 * M_PI / numberOfLabels;
    for (NSInteger i = 0; i < numberOfLabels; i++) {
        UILabel *rotatedLabel = [UILabel ayn_rotatedLabelWithText:[NSString stringWithFormat:@"%ld", i]
                                                                        angle:self.angleStep * i
                                                                 circleRadius:self.circleRadius
                                                                       offset:kAYNCircleViewLabelOffset
                                                                         font:self.labelFont
                                                                    textColor:self.labelTextColor];
        
        [self.contentView addSubview:rotatedLabel];
    }
}

- (void)rotateWithAngle:(CGFloat)angle {
    if (self.delegate && [self.delegate respondsToSelector:@selector(circleViewWillRotate:)]) {
        [self.delegate circleViewWillRotate:self];
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        self.circleView.transform = CGAffineTransformMakeRotation(angle);
    } completion:^(BOOL finished) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(circleView:didRotateWithValue:)]) {
            [self.delegate circleView:self didRotateWithValue:self.value];
        }
    }];
}

#pragma mark - Math

- (CGFloat)deltaWithOffset:(CGPoint)offset {
    return sqrt(pow(self.startPoint.x - offset.x, 2) + pow(self.startPoint.y - offset.y, 2));
}

- (CGFloat)deltaWithAngle:(CGFloat)angle {
    return angle * self.circleLength / (2 * M_PI);
}

- (CGFloat)signWithOffset:(CGPoint)offset half:(AYNCircleViewHalf)half {
    CGFloat sign = offset.x > self.startPoint.x ? -1 : 1;
    
    BOOL isYDominant = fabs(offset.y - self.startPoint.y) > fabs(offset.x - self.startPoint.x);
    if (isYDominant) {
        sign = offset.y > self.startPoint.y ? -1 : 1;
        sign *= half == AYNCircleViewHalfLeft ? -1 : 1;
    }
    
    return sign;
}

- (CGFloat)angleWithOffset:(CGPoint)offset half:(AYNCircleViewHalf)half {
    CGFloat delta = [self deltaWithOffset:offset] / self.circleLength;
    
    CGFloat sign = [self signWithOffset:offset half:half];
    
    return sign * delta * 2 * M_PI;
}

- (AYNCircleViewHalf)halfWithPoint:(CGPoint)point {
    return point.x > self.circleView.center.x ? AYNCircleViewHalfRight : AYNCircleViewHalfLeft;
}

- (CGFloat)floorAngle:(CGFloat)angle {
    NSInteger times = floorf(fabs(angle) / (2 * M_PI));
    
    NSInteger sign = angle > 0 ? -1 : 1;
    
    return angle + sign * times * 2 * M_PI;
}

- (CGFloat)normalizeAngle:(CGFloat)angle {
    return lroundf(angle / self.angleStep) * self.angleStep;
}

- (CGPoint)endPointWithTargetPoint:(CGPoint)targetPoint scrollView:(UIScrollView *)scrollView {
    CGPoint point = [scrollView.panGestureRecognizer locationInView:self];
    
    CGFloat tickOffset = [self angleWithOffset:targetPoint half:[self halfWithPoint:point]];

    CGFloat rotationAngle = self.previousAngle + tickOffset;
    CGFloat delta = [self deltaWithAngle:rotationAngle];
    CGFloat normalizedRotationAngle = [self normalizeAngle:rotationAngle];
    CGFloat normalizedDelta = [self deltaWithAngle:normalizedRotationAngle];

    CGFloat angle = [self angleWithOffset:targetPoint startPoint:self.startPoint];
    
    CGFloat sign = normalizedRotationAngle <= 0 ? -1 : 1;
    
    CGPoint result = CGPointMake(targetPoint.x + sign * (normalizedDelta - delta) * cos(angle), targetPoint.y + sign * (normalizedDelta - delta) * sin(angle));

    return result;
}

- (CGFloat)angleWithOffset:(CGPoint)offset startPoint:(CGPoint)startPoint {
    CGFloat y = (offset.y - self.startPoint.y);
    CGFloat x = (offset.x - self.startPoint.x);
    
    if (!isnan(x) && x != 0) {
        CGFloat value = atan(y / x);
        
        if (x <= 0 && y >=0) {
            return value + M_PI;
        }
        
        if (x <= 0 && y <= 0) {
            return value - M_PI;
        }
        
        return value;
    }
    
    return 0;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.isInitialized) {
        self.isInitialized = YES;
        
        self.subviews.firstObject.frame = self.bounds;
        self.circleRadius = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) / 2;
        
        self.contentView.layer.cornerRadius = self.circleRadius;
        self.contentView.layer.masksToBounds = YES;
        
        self.circleView.layer.cornerRadius = self.circleRadius;
        self.circleView.layer.masksToBounds = YES;
        
        [self addLabelsWithNumber:self.numberOfLabels];
        
        [self setNeedsUpdateConstraints];
    }
}

- (void)updateConstraints {
    self.contentViewDimension.constant = self.circleRadius * 2;
    self.contentViewOffset.constant = self.circleRadius;

    [super updateConstraints];
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint point = [scrollView.panGestureRecognizer locationInView:self];
    
    CGFloat tickOffset = [self angleWithOffset:scrollView.contentOffset half:[self halfWithPoint:point]];
    self.currentAngle = [self floorAngle:(self.previousAngle + tickOffset)];
    
    [self rotateWithAngle:self.currentAngle];
    
    self.previousAngle = self.currentAngle;
    self.startPoint = scrollView.contentOffset;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    *targetContentOffset = [self endPointWithTargetPoint:*targetContentOffset scrollView:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        self.currentAngle = [self normalizeAngle:self.previousAngle];
        
        [self rotateWithAngle:self.currentAngle];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.currentAngle = [self normalizeAngle:self.previousAngle];
    
    [self rotateWithAngle:self.currentAngle];
}

@end
