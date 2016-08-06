//
//  UDPSocketSingleton.h
//  Demo__
//
//  Created by quan on 16/8/6.
//  Copyright © 2016年 quan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GCDAsyncUdpSocket;

static NSString *didReceiveDataFromUdpSocketNotification = @"didReceiveDataFromUdpSocket"; 

@interface UDPSocketSingleton : NSObject

@property (nonatomic, strong) GCDAsyncUdpSocket    *socket;       // socket
@property (nonatomic, assign) UInt16         socketPort;    // socket的prot

+ (instancetype)sharedInstance;


- (void)startReciveUdpBroadcast;

- (void)startReciveUdpBroadcastWithPort:(UInt16)socketPort;

- (void)pauseReceivingUdpBroadcast;

@end
