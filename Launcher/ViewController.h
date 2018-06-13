//
//  ViewController.h
//  WWApp
//
//  Created by Stephen Delisle on 2018-06-07.
//  Copyright © 2018 Stephen Delisle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface ViewController : UIViewController <WKNavigationDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *DockView;
@property (weak, nonatomic) IBOutlet UIScrollView *IconsView;
@property (weak, nonatomic) IBOutlet UIView *DockInnerView;
@property (weak, nonatomic) IBOutlet UIView *IconsInnerView;

@end

