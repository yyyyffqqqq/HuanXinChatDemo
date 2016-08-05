//
//  OrderModel.h
//  Demo
//
//  Created by quan on 16/8/4.
//  Copyright © 2016年 quan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MTLModel.h"
#import <Mantle/Mantle.h>
#import <MTLFMDBAdapter/MTLFMDBAdapter.h>

@interface OrderModel : MTLModel<MTLFMDBSerializing>

@property (nonatomic, copy) NSString *shippingMethod;
@property (nonatomic, copy) NSString *customerName;
@property (nonatomic, copy) NSString *tableName;
@property (nonatomic, copy) NSNumber *tableSize;
@property (nonatomic, copy) NSNumber *identifier;

@end
