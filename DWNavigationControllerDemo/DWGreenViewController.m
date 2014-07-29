//
//  DWGreenViewController.m
//  DWNavigationControllerDemo
//
//  Created by Yue Song on 13-3-11.
//  Copyright (c) 2013年 Yue Song. All rights reserved.
//

#import "DWGreenViewController.h"
#import "DWNavgationStackViewControllerProtocol.h"

@interface DWGreenViewController ()<DWNavgationStackViewControllerProtocol>
- (IBAction)next:(id)sender;

@end

@implementation DWGreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationController.navigationBar.tintColor = [UIColor greenColor];
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

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)next:(id)sender {
    DWGreenViewController *green = [[[DWGreenViewController alloc] init] autorelease];
    [self.navigationController pushViewController:green animated:YES];
}

#pragma mark - DWNavgationStackViewControllerProtocol
- (UIView *)navBarViewForContainerSize:(CGSize)containerSize
{
    UIView *navBarView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, containerSize.width, containerSize.height)] autorelease];
    navBarView.backgroundColor = [UIColor greenColor];
    UIButton *back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame = CGRectMake(30.0, 5.0, 200.0, 34.0);
    [back setTitle:@"Go back to blue" forState:UIControlStateNormal];
    back.titleLabel.textColor = [UIColor blackColor];
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [navBarView addSubview:back];
    return navBarView;
}


@end
