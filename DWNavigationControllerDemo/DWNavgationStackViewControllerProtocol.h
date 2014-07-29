//
//  DWNavgationStackViewControllerProtocol.h
//  DWNavigationControllerDemo
//
//  Created by seven on 12-10-17.
//  Copyright (c) 2012年 www.dreamingwish.com All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    DWStackOperationPush,
    DWStackOperationPop
}DWStackOperation;

@protocol DWNavgationStackViewControllerProtocol <NSObject>

@optional
- (void)prepareHiddingNavBarView:(UIView *)navBarView forStackOperation:(DWStackOperation)stackOperation;
- (void)hideNavBarView:(UIView *)navBarView forStackOperation:(DWStackOperation)stackOperation;

- (void)prepareShowingNavBarView:(UIView *)navBarView forStackOperation:(DWStackOperation)stackOperation;
- (void)showNavBarView:(UIView *)navBarView forStackOperation:(DWStackOperation)stackOperation;

- (UIView *)navBarViewForContainerSize:(CGSize)containerSize;

@end
