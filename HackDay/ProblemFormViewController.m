//
//  ProblemFormViewController.m
//  HackDay
//
//  Created by rcodarini on 04/12/2014.
//  Copyright (c) 2014 CodeMaison. All rights reserved.
//

#import "ProblemFormViewController.h"
#import "TableViewCell.h"
#import "GERHTTPCachedDownloadOperation.h"
#import "GERAlertDisplayController.h"

#define kCommentPlaceholder @"Laissez ici votre commentaire"
#define kPostProblemURLString @"http://hack-day-ger.services/postCommentURL"

static NSString *CellIdentifier = @"contentCell";

@interface ProblemFormViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (nonatomic, strong) NSArray *incidentsList;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *footerView;
@property (nonatomic, weak) IBOutlet UITextView *commentView;
@property (strong) NSMutableArray *problemList;
@end

@implementation ProblemFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.incidentsList = @[@"Trottoir mal adapté",@"Travaux",@"Ascenseur en panne",@"Mobilier urbain inadéquat",@"Autre"];
    self.problemList = [NSMutableArray array];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    

    // customize comment text view
    self.commentView.layer.borderWidth = 0.8;
    self.commentView.layer.cornerRadius = 8.0;
    self.commentView.layer.borderColor = [UIColor colorWithWhite:135.0/255.0 alpha:1.0].CGColor;
    
    self.commentView.text = kCommentPlaceholder;
    self.commentView.textColor = [UIColor lightGrayColor];
    self.tableView.tableFooterView = self.footerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma  mark -

- (IBAction)closeForm:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)sendIncident:(id)sender
{
    ADLog(@"");
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"problem"]=[self.problemList copy];
    NSString *st =  self.commentView.text;
    if (st.length > 0 && ![st isEqualToString:kCommentPlaceholder]) {
        params[@"comment"]=st;
    }
    [GERHTTPCachedDownloadOperation postRequestForURL:[NSURL URLWithString:kPostProblemURLString] parameters:params completionBlock:^(NSInteger code, NSData *data, NSURL *URLSource, NSError *error, BOOL isCancelled) {
//        error = nil;
        NSString *messageToDisplay = nil;
        if (error) {
            messageToDisplay = @"Echec de l'envoi...";
        }
        else {
            messageToDisplay = @"Merci de votre aide !";
            
        [self closeForm:nil];
        }
        [GERAlertDisplayController displayAlertMessage:messageToDisplay];
    }];
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.incidentsList count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = self.incidentsList[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ADLog(@"%@",indexPath);
    [self.problemList addObject:self.incidentsList[indexPath.row]];
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ADLog(@"%@",indexPath);
    
    [self.problemList removeObject:self.incidentsList[indexPath.row]];
}

#pragma mark -

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    self.commentView.text = @"";
    self.commentView.textColor = [UIColor blackColor];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    ADLog(@"");
}
-(void) textViewDidChange:(UITextView *)textView
{
    if(self.commentView.text.length == 0){
        self.commentView.textColor = [UIColor lightGrayColor];
        self.commentView.text = kCommentPlaceholder;
        [self.commentView resignFirstResponder];
    }
}


@end
