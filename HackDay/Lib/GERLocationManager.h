//
//  GERLocationManager.h
//  LExpress
//
//  Created by rcodarini on 23/09/2014.
//  Copyright (c) 2014 Groupe Express-Roularta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GERLocationManager : NSObject

+ (GERLocationManager *)sharedLocationManager;

- (BOOL)startup:(NSError **)error;

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

- (BOOL)isLocationServicesEnabled;
- (CLLocation *)currentLocation;

@end
