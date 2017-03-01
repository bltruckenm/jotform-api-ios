//
//  GetAppKeyViewController.m
//  JotFormTest
//
//  Created by Interlogy, LLC on 1/5/14.
//  Copyright (c) 2014 Interlogy, LLC. All rights reserved.
//

#import "GetAppKeyViewController.h"
#import "SampleListViewController.h"
#import "SharedData.h"
#import "SVProgressHUD.h"
#import <JotForm_iOS/JotForm.h>
#import "Common.h"

@interface GetAppKeyViewController ()

@property (nonatomic,weak) IBOutlet UITextField *usernameTextField;
@property (nonatomic,weak) IBOutlet UITextField *passwordTextField;

@end

@implementation GetAppKeyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Get App Key";
    [self showAlertView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - user definition method

- (void) showSampleListViewController
{
    SampleListViewController *sampleListVc = [[SampleListViewController alloc] initWithNibName:@"SampleListViewController" bundle:nil];
    
    [self.navigationController pushViewController:sampleListVc animated:YES];
}

- (void) showAlertView
{
    
    UIAlertController *alertView = [UIAlertController
                                    alertControllerWithTitle:@"JotFormAPISample"
                                    message:@"Do you have your Jotform account?"
                                    preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *noButton = [UIAlertAction
                                   actionWithTitle:@"No, I have an API key"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action){
                                       if ([API_KEY isEqualToString:@""]) {
                                           
                                           UIAlertController *alertViewCancel = [UIAlertController
                                                                           alertControllerWithTitle:@"JotFormAPISample"
                                                                           message:@"Please put your API key in Common.h 12 line." preferredStyle:UIAlertControllerStyleAlert];
                                           
                                           UIAlertAction *noCancelButton = [UIAlertAction
                                                                      actionWithTitle:@"No, I have an API key"
                                                                      style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction *action){
                                                                      }];
                                           [alertViewCancel addAction:noCancelButton];
                                           [self presentViewController:alertViewCancel animated:YES completion:nil];
                                       } else {
                                           
                                           SharedData *sharedData = [SharedData sharedData];
                                           [sharedData initAPIClient:API_KEY];
                                           
                                           [self showSampleListViewController];
                                       }

                                   }];
    
    UIAlertAction *yesButton = [UIAlertAction
                               actionWithTitle:@"Yes, I have an API key"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action){
                                   exit(0);
                               }];
    
    [alertView addAction:yesButton];
    [alertView addAction:noButton];
    [self presentViewController:alertView animated:YES completion:nil];
}

#pragma mark - IBAction

- (IBAction) getAppKeyButtonClicked : (id) sender
{
    JotForm *apiClient = [[JotForm alloc] init];
    
    NSString *username = self.usernameTextField.text;
    
    if ( [username isEqualToString:@""] )
        [self.usernameTextField becomeFirstResponder];
    
    NSString *password = self.passwordTextField.text;
    
    if ( [password isEqualToString:@""] )
        [self.passwordTextField becomeFirstResponder];
    
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
    [SVProgressHUD showWithStatus:@"Getting app key..."];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:username forKey:@"username"];
    [userInfo setObject:password forKey:@"password"];
    [userInfo setObject:@"JotFormAPISample" forKey:@"appName"];
    [userInfo setObject:@"full" forKey:@"access"];

    [apiClient login:userInfo onSuccess:^(id result) {
        if ( result != nil ) {
            NSInteger responseCode = [[result objectForKey:@"responseCode"] integerValue];
            
            if ( responseCode == 200 || responseCode == 206 ) {
                
                id content = [result objectForKey:@"content"];
                
                SharedData *sharedData = [SharedData sharedData];
                [sharedData initAPIClient:[content objectForKey:@"appKey"]];
                
                [self showSampleListViewController];
            }
        }
        
        [SVProgressHUD dismiss];
    } onFailure:^(id error) {
          [SVProgressHUD dismiss];
    }];
}

#pragma mark - Jotform delegate

- (void) loginFinish : (id) result
{
    if ( result != nil ) {
        NSInteger responseCode = [[result objectForKey:@"responseCode"] integerValue];
        
        if ( responseCode == 200 || responseCode == 206 ) {
            id content = [result objectForKey:@"content"];
            
            SharedData *sharedData = [SharedData sharedData];
            [sharedData initAPIClient:[content objectForKey:@"appKey"]];
            
            [self showSampleListViewController];
        }
    }
    
    [SVProgressHUD dismiss];
}

- (void) loginFail : (id) error
{
    [SVProgressHUD dismiss];
}



@end
