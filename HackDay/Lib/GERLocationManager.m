//
//  GERLocationManager.m
//  LExpress
//
//  Created by rcodarini on 23/09/2014.
//  Copyright (c) 2014 Groupe Express-Roularta. All rights reserved.
//

#import "GERLocationManager.h"



#define DELAY_LOCATION_AUTO_UPDATE 30 // 0,5 minutes


@interface GERLocationManager() <CLLocationManagerDelegate>

@property (nonatomic ,strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSTimer *autoUpdateTimer;

@end

#pragma mark -

@implementation GERLocationManager
static GERLocationManager *sharedInstance = nil;

+ (GERLocationManager *)sharedLocationManager
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (BOOL)startup:(NSError **)error
{
    ADLog(@"");
    BOOL bRes = NO;
    
    if ([CLLocationManager locationServicesEnabled]) {
        bRes = YES;
        [self initCoreLocationManager];
        ADLog(@"%d",[CLLocationManager authorizationStatus]);
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined && [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            
            [self.locationManager requestWhenInUseAuthorization];
            
        }
        else {
            [self startUpdatingLocation];
        }
        if ((![CLLocationManager locationServicesEnabled]) || (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted))) {
            
            bRes = NO;
        }
    }
        return bRes;
}

- (BOOL)isLocationServicesEnabled
{
    BOOL locationIsEnabled = NO;
    if ([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
        if (! (authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted)) {
            locationIsEnabled = YES;
        }
    }
    return locationIsEnabled;
}

- (void)initCoreLocationManager
{
    ADLog(@"");
    CLLocationManager *manager = [[CLLocationManager alloc] init];
    manager.delegate = self;
    manager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager = manager;
}

- (void)startUpdatingLocation
{
   ADLog(@"");
    [self.locationManager startUpdatingLocation];
}
- (void)stopUpdatingLocation
{
    ADLog(@"");
    [self.locationManager stopUpdatingLocation];
    [self.autoUpdateTimer invalidate];
    self.autoUpdateTimer = nil;
}

- (void)delayUpdatingLocation
{
    ADLog(@"");
    [self.autoUpdateTimer invalidate];
    self.autoUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:DELAY_LOCATION_AUTO_UPDATE target:self selector:@selector(startUpdatingLocation) userInfo:nil repeats:YES];
}

- (CLLocation *)currentLocation
{
    return self.locationManager.location;
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
//    ADLog(@"%@",locations);
    if ([locations count]) {

        
        
//        [self stopUpdatingLocation];
//        [self delayUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    ADLog(@"%@",error);
    // report any errors returned back from Location Services
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    ADLog(@"% d",status);
    [self startUpdatingLocation];
}


@end
