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

@property (nonatomic,assign) BOOL isEditButNew; //NO新建,yes编辑

@property (nonatomic,assign) NSInteger editAtIndex;

@property (nonatomic, strong) OrderModel *order; //接受编辑时的初始数据；

@end
