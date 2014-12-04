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
@property (nonatomic, weak) IBOutlet UILabel *infoLab;
@property (nonatomic, weak) IBOutlet UILabel *valueLab;

@property (nonatomic, strong) NSDictionary *dataDico;
@end

@implementation LayoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.dataDico = @{@"3000":@"Le nombre de kilomètres de trottoirs offert par les rues parisiennes",
                      @"332 000":@"Le nombre de personnes en situation de handicap à Paris (Source Mairie de Paris) ",
                      @"3,6 millions":@"Le nombre de déplacements effectué quotidiennement par les piétons à Paris",
                      @"120 000":@"Le nombre (arrondi et extrapolé) de poussettes à Paris sur la base des naissances 2011/2014 dans l'aglomération (Source INSEE)",
                      @"600 mètres":@"La distance moyenne des trajets piétons à Paris",
                      @"13 minutes":@"La durée moyenne d'un trajet piéton à Paris"};
    
    NSUInteger  index = arc4random_uniform([self.dataDico count]);
    NSLog(@"rand : %u",index);
    
    self.valueLab.text = [self.dataDico allKeys][index];
    self.infoLab.text = self.dataDico[self.valueLab.text];
    [self performSelector:@selector(dismissDefaultImage) withObject:nil afterDelay:2.0];
}
- (BOOL) prefersStatusBarHidden {
    return YES;
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
        [self performSelector:@selector(showMainPage) withObject:nil afterDelay:3.0];
        
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
