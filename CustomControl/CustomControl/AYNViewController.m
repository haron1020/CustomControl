//
//  AYNViewController.m
//  CustomControl
//
//  Created by Andrey Nazarov on 05/03/17.
//  Copyright © 2017 Andrey Nazarov. All rights reserved.
//

#import "AYNViewController.h"

#import "AYNCircleView.h"

@interface AYNViewController ()

@property (weak, nonatomic) IBOutlet AYNCircleView *circleView;

@end

@implementation AYNViewController

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *contentView = [UIView new];
    contentView.backgroundColor = [UIColor redColor];
    
    self.circleView.contentView = contentView;
    self.circleView.numberOfLabels = 12;
}

@end
