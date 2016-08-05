//
//  OrderModel.m
//  Demo
//
//  Created by quan on 16/8/4.
//  Copyright © 2016年 quan. All rights reserved.
//

#import "OrderModel.h"


@implementation OrderModel

+ (NSDictionary *)FMDBColumnsByPropertyKey
{
    return @{
             @"identifier":@"identifier",
             @"customerName": @"customerName",
             @"tableName": @"tableName",
             @"shippingMethod": @"shippingMethod",
             @"tableSize": @"tableSize"
             };
}


+ (NSArray *)FMDBPrimaryKeys
{
    return @[@"identifier"];
}

+ (NSString *)FMDBTableName {
    return @"MyOrder";
}

@end
