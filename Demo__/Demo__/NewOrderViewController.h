//
//  NewOrderViewController.h
//  Demo
//
//  Created by quan on 16/8/4.
//  Copyright © 2016年 quan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OrderModel;

@interface NewOrderViewController : UIViewController

@property BOOL isEditButNew; //NO新建,yes编辑

@property NSInteger editAtIndex;

@property OrderModel *order; //接受编辑时的初始数据；

@end
