//
//  ViewController.m
//  HackDay
//
//  Created by rcodarini on 04/12/2014.
//  Copyright (c) 2014 CodeMaison. All rights reserved.
//

#import "ViewController.h"
#import "ProblemFormViewController.h"


#define kSiteURLString @"http://code-maison.cloud.ger.systems/SharePA/"

//#define kSiteURLString @"http://openlayers.org/en/master/examples/geolocation-orientation.html?q=mobile"

@interface ViewController () <UIWebViewDelegate>
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kSiteURLString]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showFormPage:(id)sender
{
    ProblemFormViewController *formVC = [[ProblemFormViewController alloc] init];
    [self presentViewController:formVC animated:YES completion:NULL];
}

@end
