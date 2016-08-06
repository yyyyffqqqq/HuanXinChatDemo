//
//  OrderTableViewCell.m
//  Demo
//
//  Created by quan on 16/8/4.
//  Copyright © 2016年 quan. All rights reserved.
//

#import "OrderTableViewCell.h"
#import "Masonry.h"

@implementation OrderTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
             reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self createView ];
        
    }
    
    return self;
}

//初始化视图
- (void)createView{
    
    _shippingMethod = [UILabel new];
    _customerName = [UILabel new];
    _tableName = [UILabel new];
    _tableSize = [UILabel new];
    
    [self.contentView addSubview:_shippingMethod];
    [self.contentView addSubview:_customerName];
    [self.contentView addSubview:_tableName];
    [self.contentView addSubview:_tableSize];
    
    _shippingMethod.backgroundColor = [UIColor redColor];
    _customerName.backgroundColor = [UIColor greenColor];
    _tableName.backgroundColor = [UIColor grayColor];
    _tableSize.backgroundColor = [UIColor yellowColor];
    
    _shippingMethod.text = @"微信支付";
    _customerName.text = @"支付宝";
    _tableName.text = @"芯片";
    _tableSize.text = @"50份";
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self layoutMySubViews];
}

/*
 * 约束布局
 */
- (void)layoutMySubViews {
    [_customerName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_customerName.superview.mas_top).offset(30);
        make.left.mas_equalTo(_customerName.superview.mas_left).offset(15);
        make.right.mas_lessThanOrEqualTo(_customerName.superview.mas_right).offset(-15);
    }];
    
    [_tableName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_customerName.mas_bottom).offset(5);
        make.left.mas_equalTo(_tableName.superview.mas_left).offset(15);
        make.right.mas_lessThanOrEqualTo(_tableName.superview.mas_right).offset(-15);
        
    }];
    
    [_tableSize mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_tableName.mas_bottom).offset(5);
        make.left.mas_equalTo(_tableSize.superview.mas_left).offset(15);
        make.right.mas_lessThanOrEqualTo(_tableSize.superview.mas_right).offset(-15);
    }];
    [_shippingMethod mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_tableSize.mas_bottom).offset(5);
        make.left.mas_equalTo(_shippingMethod.superview.mas_left).offset(15);
        make.right.mas_lessThanOrEqualTo(_shippingMethod.superview.mas_right).offset(-15);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-30);
    }];
    
}


@end
