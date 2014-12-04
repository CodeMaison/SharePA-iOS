//
//  AlertDisplayController.m
//  LExpress
//
//  Created by rcodarini on 20/06/2012.
//  Copyright (c) 2012 Groupe Express-Roularta. All rights reserved.
//

#import "GERAlertDisplayController.h"

@implementation GERAlertDisplayController

static BOOL isVisible;

+ (void)displayAlertMessage:(NSString *)message{
    if (message && !isVisible){
        isVisible = TRUE;
        UIAlertView *theAlertView = [[UIAlertView alloc] initWithTitle:@"SharePA" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [theAlertView show];
        });
    }
}

+ (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    isVisible = false;
}

@end
