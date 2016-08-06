//
//  UDPSocketSingleton.m
//  Demo__
//
//  Created by quan on 16/8/6.
//  Copyright © 2016年 quan. All rights reserved.
//

#import "UDPSocketSingleton.h"

#import "GCDAsyncUdpSocket.h"

@interface UDPSocketSingleton ()<GCDAsyncUdpSocketDelegate>

@end

@implementation UDPSocketSingleton

static UDPSocketSingleton * sharedSingleton = nil;

+ (id)allocWithZone:(struct _NSZone *)zone
{
    if (sharedSingleton == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedSingleton = [super allocWithZone:zone];
            sharedSingleton.socketPort = 8400;
        });
    }
    return sharedSingleton;
}

- (id)init
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSingleton = [super init];
        sharedSingleton.socketPort = 8400;
    });
    return sharedSingleton;
}

+(instancetype)sharedInstance
{
    return [[self alloc] init];
}

+ (id)copyWithZone:(struct _NSZone *)zone
{
    return sharedSingleton;
}
+ (id)mutableCopyWithZone:(struct _NSZone *)zone
{
    return sharedSingleton;
}

- (void)startReciveUdpBroadcast {
    if (_socket) {
        [_socket pauseReceiving];
        _socket = nil;
    }
    [self startReciveUdpBroadcast:_socket port:self.socketPort];
}

- (void)startReciveUdpBroadcastWithPort:(UInt16)socketPort {
    if (_socket) {
        [_socket pauseReceiving];
        _socket = nil;
    }
    [self startReciveUdpBroadcast:_socket port:socketPort];
}

- (void)pauseReceivingUdpBroadcast {
    if (_socket) {
        [_socket pauseReceiving];
    }
}

//开启服务端
- (void)startReciveUdpBroadcast:(GCDAsyncUdpSocket *)aUdpSocket port:(int)port
{
    if (aUdpSocket == nil)
    {
        aUdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        NSError *error = nil;
        
        if (![aUdpSocket bindToPort:port error:&error])
        {
            NSLog(@"udpSocket Error binding: %@", error);
            return;
        }
        if (![aUdpSocket beginReceiving:&error])
        {
            NSLog(@"udpSocket Error receiving: %@", error);
            return;
        }
        
        NSLog(@"start Receive Broadcast:%@============== ,%d",aUdpSocket,port);
        
        //如果当前用户是master iPad，就可以广播，否则不可以；
        [aUdpSocket enableBroadcast:YES error:&error];
        
    }
    
    if(port == 8400)
    {
        _socket = aUdpSocket;
    }
}

//接受其他客户端发送来的数据
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"sever receive data .... %@", msg);
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil]];
    [dic setObject:address forKey:@"UdpAddress"];
    [dic setObject:data forKey:@"UdpData"];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:didReceiveDataFromUdpSocketNotification object:_socket userInfo:dic];
//    NSString *host = nil;
//    uint16_t port = 0;
//    [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
//    //可获取客户端socket的ip和端口，不过直接打印address是空的
//    NSLog(@"Adress = %@ %i",host,port);
}

@end
