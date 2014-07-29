//
//  DWBlueViewController.m
//  DWNavigationControllerDemo
//
//  Created by Yue Song on 13-3-11.
//  Copyright (c) 2013年 Yue Song. All rights reserved.
//

#import "DWBlueViewController.h"
#import "DWGreenViewController.h"
#import "DWNavgationStackViewControllerProtocol.h"

@interface DWBlueViewController ()<DWNavgationStackViewControllerProtocol>
- (IBAction)goToGreen:(id)sender;

@end

@implementation DWBlueViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goToGreen:(id)sender {
    DWGreenViewController *green = [[[DWGreenViewController alloc] init] autorelease];
    [self.navigationController pushViewController:green animated:YES];
}

#pragma mark - DWNavgationStackViewControllerProtocol
- (UIView *)navBarViewForContainerSize:(CGSize)containerSize
{
    UIView *navBarView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, containerSize.width, containerSize.height)] autorelease];
    navBarView.backgroundColor = [UIColor blueColor];
    UITextField *textFiled = [[[UITextField alloc] initWithFrame:CGRectMake(30.0, 5.0, 100.0, 34.0)] autorelease];
    textFiled.borderStyle = UITextBorderStyleRoundedRect;
    [navBarView addSubview:textFiled];
    return navBarView;
}

@end
