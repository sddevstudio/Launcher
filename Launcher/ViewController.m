//
//  ViewController.m
//  WWApp
//
//  Created by Stephen Delisle on 2018-06-07.
//  Copyright © 2018 Stephen Delisle. All rights reserved.
//

#import "ViewController.h"

@interface PrivateApi_LSApplicationWorkspace
- (bool)openApplicationWithBundleID:(id)arg1; //LSApplicationWorkspace
@end

@interface ViewController ()

@end



@implementation ViewController  {
    NSMutableArray* _icons; // button tag is the index corrilate with bundleID
    int currentTag;
    WKWebViewConfiguration *theConfiguration;
}
@synthesize DockView, DockInnerView;
@synthesize IconsView, IconsInnerView;

-(void)addButtons:(NSString*) listFile view:(UIView*) view scrollView:(UIScrollView*)scrollView {
    NSString * bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString * path = [bundlePath stringByAppendingPathComponent:listFile];
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"DockIcons" ofType:@"plist"];
    
    NSDictionary* iconData = [NSDictionary dictionaryWithContentsOfFile:path];
    if (iconData == nil)
        return;
    NSDictionary* iconSettings = [iconData valueForKey:@"iconsettings"];
    if (iconSettings == nil)
        return;
    NSDictionary* viewSettings = [iconData valueForKey:@"viewsettings"];
    if (viewSettings != nil){
        [scrollView setBackgroundColor:[UIColor colorWithRed:[(NSNumber*)[viewSettings valueForKey:@"red"] floatValue]/255 green:[(NSNumber*)[viewSettings valueForKey:@"green"] floatValue]/255 blue:[(NSNumber*)[viewSettings valueForKey:@"blue"] floatValue]/255 alpha:[(NSNumber*)[viewSettings valueForKey:@"alpha"] floatValue]/255]];
    }
    NSArray* icons = [iconData valueForKey:@"icons"];
    if (icons == nil)
        return;
    int maxWidth = view.frame.size.width,maxHeight = view.frame.size.height;
    for (NSDictionary* icon in icons) {
        int tag = currentTag;
        currentTag++;
        [_icons insertObject:[icon valueForKey:@"bundleid"] atIndex:tag];
         
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTag:tag];
        [button addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"" forState:UIControlStateNormal];
        if (![[iconSettings valueForKey:@"backgroundimage"] isEqualToString:@""]) {
            UIImage* bg = [UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:[iconSettings valueForKey:@"backgroundimage"]]];
            [button setBackgroundImage:bg  forState:UIControlStateNormal];
        }
        if (![[icon valueForKey:@"image"] isEqualToString:@""]) {
            UIImage* img = [UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:[icon valueForKey:@"image"]]];
            [button setImage:img  forState:UIControlStateNormal];
        }
        NSNumber* w = [iconSettings valueForKey:@"width"];
        NSNumber* h = [iconSettings valueForKey:@"height"];
        if ([icon valueForKey:@"width"] > 0)
            w = [icon valueForKey:@"width"];
        if ([icon valueForKey:@"height"] > 0)
            h =[icon valueForKey:@"height"];
        NSNumber* t = [icon valueForKey:@"top"];
        NSNumber* l = [icon valueForKey:@"left"];
        button.frame = CGRectMake(l.floatValue, t.floatValue, w.floatValue, h.floatValue);

        [view addSubview:button];
        if (l.intValue > maxWidth)
            maxWidth = l.intValue;
        if (t.intValue > maxHeight)
            maxHeight = t.intValue;
    }
    int hPages = (maxWidth+scrollView.frame.size.width-1 ) / scrollView.frame.size.width;
    int vPages = (maxHeight+scrollView.frame.size.height-1) / scrollView.frame.size.height;
    int w = scrollView.frame.size.width * hPages;
    int h = scrollView.frame.size.height * vPages;
    CGRect newFrame = view.frame;
    newFrame.size.width = w;
    newFrame.size.height = h;
    [view setFrame:newFrame];
    [scrollView setContentSize:CGSizeMake(w,h)];
}
-(void)addWidgets:(NSString*) listFile view:(UIView*) view scrollView:(UIScrollView*)scrollView {
    NSString * bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString * path = [bundlePath stringByAppendingPathComponent:listFile];
    
    NSDictionary* iconData = [NSDictionary dictionaryWithContentsOfFile:path];
    if (iconData == nil)
        return;
    NSDictionary* iconSettings = [iconData valueForKey:@"iconsettings"];
    if (iconSettings == nil)
        return;
    
    NSArray* widgets = [iconData valueForKey:@"widgets"];
    if (widgets == nil)
        return;
    int maxWidth = view.frame.size.width,maxHeight = view.frame.size.height;
    for (NSDictionary* widget in widgets) {
        
        CGRect webFrame = CGRectMake([[widget valueForKey:@"left"] floatValue], [[widget valueForKey:@"top"] floatValue], [[widget valueForKey:@"width"] floatValue], [[widget valueForKey:@"height"] floatValue]);
        WKWebView *webView = [[WKWebView alloc] initWithFrame:webFrame configuration:theConfiguration];
        webView.navigationDelegate = self;
        NSURL *nsurl=[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Widgets/%@/Widget.html",bundlePath,[widget valueForKey:@"widgetname"]]];

        NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];

        [webView loadRequest:nsrequest];
        [webView setOpaque:NO];
        [webView setBackgroundColor:UIColor.clearColor];

        [webView setContentMode:UIViewContentModeTopLeft];
        [view addSubview:webView];

        NSNumber* t = [widget valueForKey:@"top"];
        NSNumber* l = [widget valueForKey:@"left"];

        if (l.intValue > maxWidth)
            maxWidth = l.intValue;
        if (t.intValue > maxHeight)
            maxHeight = t.intValue;
    }
    int hPages = (maxWidth+scrollView.frame.size.width-1 ) / scrollView.frame.size.width;
    int vPages = (maxHeight+scrollView.frame.size.height-1) / scrollView.frame.size.height;
    int w = scrollView.frame.size.width * hPages;
    int h = scrollView.frame.size.height * vPages;

    CGRect newFrame = view.frame;
    newFrame.size.width = w;
    newFrame.size.height = h;
    [view setFrame:newFrame];
    [scrollView setContentSize:CGSizeMake(w,h)];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"%@",error.description);
    
}

- (void)launchApp:(NSString*)bundleId {
    PrivateApi_LSApplicationWorkspace* _workspace;
    _workspace = [NSClassFromString(@"LSApplicationWorkspace") new];
    [_workspace openApplicationWithBundleID:bundleId];
}
- (IBAction)buttonPress:(UIButton *)sender {
    [self launchApp:[_icons objectAtIndex:sender.tag]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // set the status bar white
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    theConfiguration = [[WKWebViewConfiguration alloc] init];
    [theConfiguration.preferences setValue:@"TRUE" forKey:@"allowFileAccessFromFileURLs"];
    
    currentTag = 0;
    _icons = [[NSMutableArray alloc] init];
    // add icons to dock view
    [self addButtons:@"DockIcons.plist" view:DockInnerView scrollView:DockView];
    [self addButtons:@"Icons.plist" view:IconsInnerView scrollView:IconsView];
    [self addWidgets:@"Icons.plist" view:IconsInnerView scrollView:IconsView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
