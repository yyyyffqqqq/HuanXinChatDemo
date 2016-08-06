//
//  ViewController.m
//  Demo__
//
//  Created by quan on 16/8/5.
//  Copyright © 2016年 quan. All rights reserved.
//

#import "ViewController.h"

#import "NewOrderViewController.h"

#import "OrderTableViewCell.h"

#import "OrderModel.h"
#import <FMDB/FMDB.h>
#import <Mantle/Mantle.h>
#import <MTLFMDBAdapter/MTLFMDBAdapter.h>

#import "GCDAsyncUdpSocket.h"
#import "UDPSocketSingleton.h"

@interface ViewController (){
    FMDatabase *db;
}

@property (strong, nonatomic) NSMutableArray<OrderModel*> *dataArrays; //存储订单列表数据；


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configurationInitData];
    
//    [self startReciveUdpBroadcast:_udpSocket8400 port:8400];
    
    [[UDPSocketSingleton sharedInstance] startReciveUdpBroadcastWithPort:8400];
    
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveDataFromUdpSocketNotifi:) name:didReceiveDataFromUdpSocketNotification object:nil];
    
    [self queryDb];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}
//收到客户端iPad发送的消息后进行处理
-(void)receiveDataFromUdpSocketNotifi:(NSNotification *)notifi{
    NSLog(@"object=====%@",notifi.object);
    NSLog(@"userInfo=====%@",notifi.userInfo);
    
    OrderModel *order = [OrderModel new];
    order.shippingMethod = [notifi.userInfo objectForKey:@"shippingMethod"];
    order.customerName = [notifi.userInfo objectForKey:@"customerName"];
    order.tableName = [notifi.userInfo objectForKey:@"tableName"];
    order.tableSize = [notifi.userInfo objectForKey:@"tableSize"];

    //收到master iPad广播的消息就保存到数据库,
    if (![[notifi.userInfo objectForKey:@"isEditButNew"] boolValue]) {
        [self saveDataToDB:order];
    }


    if ([[notifi.userInfo objectForKey:@"isEditButNew"] intValue] == 0) {
        [_dataArrays addObject:order];
    } else { //
        [_dataArrays replaceObjectAtIndex:[[notifi.userInfo objectForKey:@"index"] intValue] withObject:order];
    }
    
    [self.tableView reloadData];

    //收到消息后作出响应
    //    NSString *jsonString = @"回复的消息..." ;
    [((GCDAsyncUdpSocket*)notifi.object) sendData:[notifi.userInfo objectForKey:@"UdpData"] toAddress:[notifi.userInfo objectForKey:@"UdpAddress"] withTimeout:-1 tag:10];
}

- (void)configurationInitData {
    _dataArrays = [[NSMutableArray alloc]init];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50;
    [self.view addSubview:_tableView];
    
    UIBarButtonItem *newOrderBt = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newOrder)];
    
    self.navigationItem.rightBarButtonItem = newOrderBt;
    
    self.title = @"订单列表";
}

- (void)queryDb {
    
    [_dataArrays removeAllObjects];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Sets the database filename
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"Order.sqlite"];
    
    // Tell FMDB where the database is
    db = [FMDatabase databaseWithPath:filePath];
    
    if ([db open]) {
        // Read the record we've just written to the database
        OrderModel *resultOrder = nil;
        NSError *error = nil;
        FMResultSet *resultSet = [db executeQuery:@"select * from MyOrder"];
        
        while ([resultSet next]) {
            resultOrder = [MTLFMDBAdapter modelOfClass:OrderModel.class fromFMResultSet:resultSet error:&error];
            NSLog(@".... %@", resultOrder);
            NSLog(@"error .... %@", error);
            [_dataArrays addObject:resultOrder];
        }
        NSLog(@"%ld", _dataArrays.count);
        [self.tableView reloadData];
        [db close];
    }
    
}

////开启服务端
//- (void)startReciveUdpBroadcast:(GCDAsyncUdpSocket *)aUdpSocket port:(int)port
//{
//    if (aUdpSocket == nil)
//    {
//        aUdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
//        NSError *error = nil;
//        
//        if (![aUdpSocket bindToPort:port error:&error])
//        {
//            NSLog(@"udpSocket Error binding: %@", error);
//            return;
//        }
//        if (![aUdpSocket beginReceiving:&error])
//        {
//            NSLog(@"udpSocket Error receiving: %@", error);
//            return;
//        }
//        
//        NSLog(@"start Receive Broadcast:%@============== ,%d",aUdpSocket,port);
//        
//        //如果当前用户是master iPad，就可以广播，否则不可以；
//        [aUdpSocket enableBroadcast:YES error:&error];
//        
//    }
//    
//    if(port == 8400)
//    {
//        _udpSocket8400 = aUdpSocket;
//    }
//}
//
////接受其他客户端发送来的数据
//- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
//{
//    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"sever receive data .... %@", msg);
//    
//    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
//    OrderModel *order = [OrderModel new];
//    order.shippingMethod = [dic objectForKey:@"shippingMethod"];
//    order.customerName = [dic objectForKey:@"customerName"];
//    order.tableName = [dic objectForKey:@"tableName"];
//    order.tableSize = [dic objectForKey:@"tableSize"];
//    
//    //收到master iPad广播的消息就保存到数据库,
//    if (![[dic objectForKey:@"isEditButNew"] boolValue]) {
//        [self saveDataToDB:order];
//    }
//    
//    
//    if ([[dic objectForKey:@"isEditButNew"] intValue] == 0) {
//        [_dataArrays addObject:order];
//    } else { //
//        [_dataArrays replaceObjectAtIndex:[[dic objectForKey:@"index"] intValue] withObject:order];
//    }
//    
//    
//    [self.tableView reloadData];
//    
//    NSString *host = nil;
//    uint16_t port = 0;
//    [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
//    //可获取客户端socket的ip和端口，不过直接打印address是空的
//    NSLog(@"Adress = %@ %i",host,port);
//    
//    //收到消息后作出响应
//    //    NSString *jsonString = @"回复的消息..." ;
//    [sock sendData:data toAddress:address withTimeout:-1 tag:10];
//}

- (void)saveDataToDB:(OrderModel*)order {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // 设置数据库文件名
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"Order.sqlite"];
    
    //获取数据库对象
    db = [FMDatabase databaseWithPath:filePath];
    
    if ([db open]) {
        BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS MyOrder (identifier INTEGER PRIMARY KEY AUTOINCREMENT, customerName TEXT NOT NULL, tableName TEXT, shippingMethod TEXT, tableSize INTEGER)"];
        if (result) {
            NSString *stmt;
            
            // Get the values of the record in a format we can use with FMDB
            NSArray *params = [MTLFMDBAdapter columnValues:order];
            
            stmt = [MTLFMDBAdapter insertStatementForModel:order];
            // Execute our INSERT or update
            [db executeUpdate:stmt withArgumentsInArray:params];
            
            [db close];
        }
    }
    
    
    
    
}


- (void)newOrder {
    NewOrderViewController *neworderVC = [NewOrderViewController new];
    neworderVC.title = @"新建订单";
    [self showViewController:neworderVC sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(NSInteger)numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArrays.count;
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reuseIdentifier = @"cellID2";
    
    OrderTableViewCell *cell = [[OrderTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    cell.shippingMethod.text = [_dataArrays objectAtIndex:indexPath.row].shippingMethod;
    cell.customerName.text = [_dataArrays objectAtIndex:indexPath.row].customerName;
    cell.tableName.text = [_dataArrays objectAtIndex:indexPath.row].tableName;
    cell.tableSize.text = [NSString stringWithFormat:@"%@",[_dataArrays objectAtIndex:indexPath.row].tableSize];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NewOrderViewController *editVC = [NewOrderViewController new];
    editVC.isEditButNew = YES; //编辑
    editVC.order = [_dataArrays objectAtIndex:indexPath.row];
    editVC.editAtIndex = indexPath.row;
    editVC.title = @"编辑订单";
    [self showViewController:editVC sender:self];
    
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:didReceiveDataFromUdpSocketNotification object:nil];
}

@end
