//
//  PSG_AlertView.h
//  PSG_AlertView
//
//  Created by SNICE on 2018/9/19.
//  Copyright © 2018年 G. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSG_AlertView : UIView

/**
 选择弹框
 
 @param dataSource 传入字典或者模型数组
 @param titleKey 需要显示的title的字段
 @param didSelected 选择d回调
 @param didCanceled 取消回调
 */
+ (void)showAlertWithDataSource:(NSArray *)dataSource titleKey:(NSString *)titleKey didSelected:(void (^)(id obj, NSInteger index))didSelected didCanceled:(void (^)(void))didCanceled;

@end
