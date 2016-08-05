//
//  OrderTableViewCell.h
//  Demo
//
//  Created by quan on 16/8/4.
//  Copyright © 2016年 quan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderTableViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *shippingMethod; //下单方式

@property (strong, nonatomic) UILabel *customerName; //订单用户

@property (strong, nonatomic) UILabel *tableName; //订单名

@property (strong, nonatomic) UILabel *tableSize; //订单量


@end
