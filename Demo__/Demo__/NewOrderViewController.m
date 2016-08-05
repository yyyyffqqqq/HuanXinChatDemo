//
//  NewOrderViewController.m
//  Demo
//
//  Created by quan on 16/8/4.
//  Copyright © 2016年 quan. All rights reserved.
//

#import "NewOrderViewController.h"

#include <arpa/inet.h>

#import "GCDAsyncUdpSocket.h"

#import "OrderModel.h"
#import <FMDB/FMDB.h>
#import <Mantle/Mantle.h>
#import <MTLFMDBAdapter/MTLFMDBAdapter.h>

FMDatabase *db;

#import "Masonry.h"

@interface NewOrderViewController ()<NSNetServiceDelegate, NSNetServiceBrowserDelegate, GCDAsyncUdpSocketDelegate>

@property (strong, nonatomic) UITextField *shippingMethod; //下单方式

@property (strong, nonatomic) UITextField *customerName; //订单用户

@property (strong, nonatomic) UITextField *tableName; //订单名

@property (strong, nonatomic) UITextField *tableSize; //订单量

@property(strong,nonatomic) NSNetService *service;

@property(strong,nonatomic) NSNetServiceBrowser *serviceBrowser;

@property (strong,atomic) NSMutableArray *serviceList; //搜索到的服务列表，找出是名为master的服务并在保存订单时给给服务发送订单信息
@property (strong,atomic) NSMutableArray *serviceIps; //搜索到的服务ip

@property (strong,atomic) NSNetService *masterServiceIp;

@property (strong,atomic) NSMutableDictionary *sendMessage;

@end

@implementation NewOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化服务，指定服务的域，类型，名称和端口
    NSNetService *netService = [[NSNetService alloc] initWithDomain:@"local." type:@"_http._tcp." name:@"DamonWebServer" port:5222];
    //指定代理
    [netService setDelegate:self];
    //发布注册服务
    [netService publish];
    
    self.serviceList = [[NSMutableArray alloc] init];
    self.serviceIps = [[NSMutableArray alloc] init];
    
    _serviceBrowser = [[NSNetServiceBrowser alloc] init];
    [_serviceBrowser setDelegate:self];
    [_serviceBrowser searchForServicesOfType:@"_http._tcp." inDomain:@"local."];
    
    UIBarButtonItem *saveOrderBt = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveOrder)];
    
    self.navigationItem.rightBarButtonItem = saveOrderBt;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _shippingMethod = [[UITextField alloc]init];
    _customerName = [[UITextField alloc]init];
    _tableName = [[UITextField alloc]init];
    _tableSize = [[UITextField alloc]init];
    
    _tableSize.keyboardType = UIKeyboardTypeNumberPad;
    
    _shippingMethod.placeholder = @"下单方式";
    _customerName.placeholder = @"订单用户";
    _tableName.placeholder = @"订单名";
    _tableSize.placeholder = @"订单量";
    
    if (_isEditButNew) {
        _shippingMethod.text = _order.shippingMethod;
        _customerName.text = _order.customerName;
        _tableName.text = _order.tableName;
        _tableSize.text = [NSString stringWithFormat:@"%@",_order.tableSize];
    } else {
        _order = [OrderModel new];
        _editAtIndex = -1;
    }
    
    _shippingMethod.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    _customerName.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    _tableName.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    _tableSize.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    
    [self.view addSubview:_shippingMethod];
    [self.view addSubview:_customerName];
    [self.view addSubview:_tableName];
    [self.view addSubview:_tableSize];
    
    [self layoutMySubView];
}

//保存订单，应该判断各个输入的数据是否符合要求，这里略。。。
- (void)saveOrder {
    _sendMessage = (NSMutableDictionary*)@{@"shippingMethod":_shippingMethod.text, @"customerName":_customerName.text, @"tableName":_tableName.text, @"tableSize":_tableSize.text, @"isEditButNew":[[NSNumber alloc]initWithBool: _isEditButNew], @"index":[[NSNumber alloc]initWithInteger:_editAtIndex]};
    
    [self broadCast];
    
    [self saveDataToDB];
    
    //应该在保存订单和及发送订单信息成功后返回
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)saveDataToDB {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Sets the database filename
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"Order.sqlite"];
    
    NSLog(@"filePath : %@", filePath);
    
    // Tell FMDB where the database is
    db = [FMDatabase databaseWithPath:filePath];
    
    if ([db open])
    {
        //4.创表
        BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS MyOrder (identifier INTEGER PRIMARY KEY AUTOINCREMENT, customerName TEXT NOT NULL, tableName TEXT, shippingMethod TEXT, tableSize INTEGER)"];
        if (result)
        {
            NSLog(@"创建或打开表成功");
            NSString *stmt = nil;
            NSArray *params = nil;
            _order.customerName = _customerName.text;
            _order.tableName = _tableName.text;
            _order.shippingMethod = _shippingMethod.text;
            _order.tableSize = [NSNumber numberWithInt:[_tableSize.text intValue]];
            
            if (_isEditButNew) {
                stmt = @"update MyOrder set identifier = ?, customerName = ?, tableName = ?, shippingMethod = ?, tableSize = ? where identifier = ?";
                params = @[_order.identifier, _order.customerName, _order.tableName, _order.shippingMethod, _order.tableSize, _order.identifier];
                
                //下面的model转sql语句有问题，属性列与参数个数不匹配；
//                stmt = [MTLFMDBAdapter updateStatementForModel:_order];
//                params = [MTLFMDBAdapter columnValues:_order];
                
                
            } else {
                stmt = [MTLFMDBAdapter insertStatementForModel:_order];
                params = [MTLFMDBAdapter columnValues:_order];
            }
            
            NSLog(@"stmt : %@", stmt);
            NSLog(@"params : %@", params);
            // Get the values of the record in a format we can use with FMDB
            
            NSError *error = nil;
            [db executeUpdate:stmt values:params error:&error];
//            [db executeUpdate:stmt withArgumentsInArray:params];
            
            NSLog(@"error : %@", error);
            
            [db close];
        }
        
    }
    
    
    
    
}

- (void)layoutMySubView {
    [_customerName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(80);
        make.height.mas_equalTo(40);
        make.centerX.mas_equalTo(self.view);
        make.left.mas_equalTo(self.view.mas_left).offset(20);
        make.right.mas_equalTo(self.view).offset(-20);
    }];
    [_tableName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_customerName.mas_bottom).offset(20);
        make.centerX.mas_equalTo(self.view);
        make.height.mas_equalTo(40);
        make.left.mas_equalTo(self.view.mas_left).offset(20);
        make.right.mas_equalTo(self.view).offset(-20);
    }];
    [_shippingMethod mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_tableName.mas_bottom).offset(20);
        make.centerX.mas_equalTo(self.view);
        make.height.mas_equalTo(40);
        make.left.mas_equalTo(self.view.mas_left).offset(20);
        make.right.mas_equalTo(self.view).offset(-20);
    }];
    [_tableSize mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_shippingMethod.mas_bottom).offset(20);
        make.height.mas_equalTo(40);
        make.centerX.mas_equalTo(self.view);
        make.left.mas_equalTo(self.view.mas_left).offset(20);
        make.right.mas_equalTo(self.view).offset(-20);
    }];
}

//service begin search
-(void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser{
    NSLog(@"is searching ..");
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing{
    
    
}
-(void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveDomain:(NSString *)domainString moreComing:(BOOL)moreComing{
    NSLog(@"this domain is not available %@",domainString);
    
}

//service stop search
-(void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser{
    
    NSLog(@"Stoped Searching");
    
}



- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
             didNotSearch:(NSDictionary *)errorDict
{
    NSLog(@"Stoped Searchingasd");
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing{
    //如果找到的service是master
    
    [self.serviceList addObject:service.name];
    //    if (service.name ... ) {//是master ipad
    //        self obtainService:service.name];
    //    }
    [self obtainService:service.name];
    
    // If moreComing is NO, it means that there are no more messages in the queue from the Bonjour daemon,
    if (!moreComing) {
        
    }
    
}

- (void)netServiceWillPublish:(NSNetService *)sender {
    NSLog(@"published service ..  ");
}

-(void)obtainService:(NSString *)name{
    _service = [[NSNetService alloc] initWithDomain:@"local." type:@"_http._tcp." name:name];
    
    if (_service) {
        [_service setDelegate:self];
        [_service resolveWithTimeout:0.5];
    }else
    {
        NSLog(@"An error occurred initializing the NSNetService object.");
    }
    
}

//NSNetService Delegates
//解析成功
-(void)netServiceDidResolveAddress:(NSNetService *)sender{
    NSLog(@"Sender %@",sender.addresses);
    
    for (NSData *address in [sender addresses]) {
        struct sockaddr_in *socketAddress = (struct sockaddr_in *) [address bytes];
        
        NSLog(@";Service name: %@ , ip: %s, port: %ld ", [sender name], inet_ntoa(socketAddress->sin_addr), (long)sender.port);
        NSString *addr = [NSString stringWithUTF8String:inet_ntoa(socketAddress->sin_addr)];
        
        [self.serviceIps addObject:addr];
    }
}
//解析失败
-(void)netService:(NSNetService *)sender didNotResolve:(NSDictionary<NSString *,NSNumber *> *)errorDict{
    
}


//
/*
 *start
 */
- (void)broadCast {
    GCDAsyncUdpSocket *udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    //    NSError *error = nil;
    //    [udpSocket enableBroadcast:YES error:&error];//允许广播 必须 否则后面无法发送组播和广播,作为客户端可不用设置
    //    NSString *message = @"{\"type\":49}";
    //[udpSocket sendData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:10];//该函数只能用户已经连接的socket
    //可以根据bonjour获取到的服务并解析，将其中的host和port作为参数传入
    [udpSocket sendData:[NSJSONSerialization dataWithJSONObject:_sendMessage options:NSJSONWritingPrettyPrinted error:nil] toHost:[NSString stringWithFormat:@"%@",_serviceIps[0]]   port:8400 withTimeout:-1 tag:10];//客户端socket发送组播或是广播 根据host的ip地址来定
    [udpSocket beginReceiving:nil];//必须要  开始准备接收数据
}

#pragma mark- GCDAsyncUdpSocketDelegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext {
    NSLog(@"ReceiveData ：。。。： = %@, fromAddress = %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding],[[NSString alloc] initWithData:address encoding:NSUTF8StringEncoding]);
    NSString *host = nil;
    uint16_t port = 0;
    [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];//从此可以获取服务端回应的ip和端口 用于后面的tcp连接
    NSLog(@"Adress = %@ %i",host,port);
    
}

/*
 *end
 */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
