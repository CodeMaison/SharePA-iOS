//
//  LayoutViewController.m
//  HackDay
//
//  Created by rcodarini on 04/12/2014.
//  Copyright (c) 2014 CodeMaison. All rights reserved.
//

#import "LayoutViewController.h"
#import "ViewController.h"

@interface LayoutViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *defaultImageView;


@end

@implementation LayoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self performSelector:@selector(dismissDefaultImage) withObject:nil afterDelay:3.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dismissDefaultImage
{
    [UIView animateWithDuration:0.5 animations:^{
        self.defaultImageView.alpha = 0,0;
        self.view.backgroundColor = [UIColor whiteColor];
    } completion:^(BOOL finished) {
        [self performSelector:@selector(showMainPage) withObject:nil afterDelay:5.0];
        
    }];
}

- (void)showMainPage
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        ViewController *formVC = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
//        formVC.modalPresentationStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:formVC animated:YES completion:NULL];
    });
    
    
}

@end
