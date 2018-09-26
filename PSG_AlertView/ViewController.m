//
//  ViewController.m
//  PSG_AlertView
//
//  Created by SNICE on 2018/9/19.
//  Copyright © 2018年 G. All rights reserved.
//

#import "ViewController.h"
#import "PSG_AlertView.h"
#import "PersonModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    PersonModel *model1 = [[PersonModel alloc] init];
//    model1.name = @"haha1";
//    PersonModel *model2 = [[PersonModel alloc] init];
//    model2.name = @"haha2";
//
//    [PSG_AlertView showAlertWithDataSource:@[model1, model2] titleKey:@"name" didSelected:^(id  _Nonnull obj, NSInteger index) {
//
//    } didCanceled:^{
//
//    }];
    
    NSDictionary *dic1 = @{@"name" : @"hehehehe1"};
    NSDictionary *dic2 = @{@"name" : @"hehehehe2"};

    [PSG_AlertView showAlertWithDataSource:@[dic1, dic2] titleKey:@"name" didSelected:^(id  _Nonnull obj, NSInteger index) {

    } didCanceled:^{

    }];
}


@end
