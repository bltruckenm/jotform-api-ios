//
//  JotFormTestViewController.m
//  JotFormTest
//
//  Created by Administrator on 6/26/13.
//  Copyright (c) 2013 wang. All rights reserved.
//

#import "JotFormTestViewController.h"
#import "Common.h"

@interface JotFormTestViewController ()

@end

@implementation JotFormTestViewController

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
    
    [self callJotFormAPI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) callJotFormAPI
{
    jotform = [[JotForm alloc] initWithApiKey:API_KEY debugMode:NO];
    
    
    __weak typeof(UILabel) *resultlabel = resultLabel;
    
    jotform.didFinishBlock = ^(id result) {
        
        NSLog(@"%@", result);
        
        NSString *contentStr = @"";
        
        NSArray *contentArray = [result objectForKey:@"content"];
        
        for ( id content in contentArray ) {
            
            contentStr = [contentStr stringByAppendingString:[NSString stringWithFormat:@"count = %d\n", [[content objectForKey:@"count"] integerValue]]];
            contentStr = [contentStr stringByAppendingString:[NSString stringWithFormat:@"created_at = %@\n", [content objectForKey:@"created_at"]]];
            contentStr = [contentStr stringByAppendingString:[NSString stringWithFormat:@"height = %d\n", [[content objectForKey:@"height"] integerValue]]];
            contentStr = [contentStr stringByAppendingString:[NSString stringWithFormat:@"id = %lld\n", [[content objectForKey:@"id"] longLongValue]]];
            contentStr = [contentStr stringByAppendingString:[NSString stringWithFormat:@"new = %d\n", [[content objectForKey:@"new"] integerValue]]];
            contentStr = [contentStr stringByAppendingString:[NSString stringWithFormat:@"status = %@\n", [content objectForKey:@"status"]]];
            contentStr = [contentStr stringByAppendingString:[NSString stringWithFormat:@"title = %@\n", [content objectForKey:@"title"]]];
            contentStr = [contentStr stringByAppendingString:[NSString stringWithFormat:@"updated_at = %@\n", [content objectForKey:@"updated_at"]]];
            contentStr = [contentStr stringByAppendingString:[NSString stringWithFormat:@"url = %@\n", [content objectForKey:@"url"]]];
            contentStr = [contentStr stringByAppendingString:[NSString stringWithFormat:@"username = %@ \n\n", [content objectForKey:@"username"]]];
            
        }
        
        resultlabel.text = contentStr;
    };
    
    jotform.didFailBlock = ^(id error) {
        
    };
    
    [jotform getForms];
}

@end