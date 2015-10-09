//
//  ViewController.m
//  Pleasantry
//
//  Created by Victor Anyirah on 10/3/15.
//  Copyright (c) 2015 Victor Anyirah. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "PleasantViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet UIWebView *webViewBG;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UITextField *userText;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.errorLabel.text = @"";
    [self loadPleasantBackgroundGIF];
    self.submitButton.layer.borderColor = [[UIColor blackColor]CGColor];
    self.userText.layer.borderColor = [[UIColor blackColor]CGColor];
}


- (IBAction)userDidSubmit:(id)sender {
    if (![self.userText.text isEqualToString:@""]){
        NSString *userName = self.userText.text;
        PleasantViewController *pleasantVC = [self.storyboard instantiateViewControllerWithIdentifier:@"pleasantVC"];
        NSLog(@"%@", self.userText.text);
        pleasantVC.userName = userName;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:userName forKey:@"name"];
        [self presentViewController:pleasantVC animated:true completion:nil];
    }
    else{
        self.errorLabel.text = @"Sorry, it looks like you did not enter a username.";
    }
}

- (void)loadPleasantBackgroundGIF{
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"cat400" ofType:@".gif"];
    NSData *gif = [NSData dataWithContentsOfFile:filePath];
    [self.webViewBG loadData:gif MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    self.webViewBG.scalesPageToFit = YES;
    self.webViewBG.userInteractionEnabled = YES;
   
}




@end
