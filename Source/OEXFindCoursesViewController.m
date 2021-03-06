//
//  OEXFindCoursesViewController.m
//  edXVideoLocker
//
//  Created by Abhradeep on 02/02/15.
//  Copyright (c) 2015 edX. All rights reserved.
//

@import MessageUI;

#import "OEXFindCoursesViewController.h"

#import "edX-Swift.h"

#import "OEXConfig.h"
#import "OEXCourseInfoViewController.h"
#import "OEXDownloadViewController.h"
#import "OEXEnrollmentConfig.h"
#import "OEXRouter.h"
#import "OEXStyles.h"
#import "NSURL+OEXPathExtensions.h"

static NSString* const OEXFindCoursesCourseInfoPath = @"course_info/";
static NSString* const OEXFindCoursesPathIDKey = @"path_id";
static NSString* const OEXFindCoursePathPrefix = @"course/";

@interface OEXFindCoursesViewController () <OEXFindCoursesWebViewHelperDelegate>
@property(nonatomic, strong) IBOutlet UIActivityIndicatorView* loadingIndicator;
@property (strong, nonatomic) OEXFindCoursesWebViewHelper* webViewHelper;

@end

@implementation OEXFindCoursesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.webViewHelper = [[OEXFindCoursesWebViewHelper alloc] initWithWebView:self.webView delegate:self];
    self.webViewHelper.progressIndicator = self.loadingIndicator;

    if(self.dataInterface.reachable) {
        [self.webViewHelper loadWebViewWithURLString:[self enrollmentConfig].searchURL];
    }
}

- (OEXEnrollmentConfig*)enrollmentConfig {
    return [[OEXConfig sharedConfig] courseEnrollmentConfig];
}

- (void)reachabilityDidChange:(NSNotification*)notification {
    [super reachabilityDidChange:notification];
    if([self enrollmentConfig].enabled && self.dataInterface.reachable && !self.webViewHelper.isWebViewLoaded) {
        [self.webViewHelper loadWebViewWithURLString:[self enrollmentConfig].searchURL];
    }
}

- (void)setNavigationBar {
    [super setNavigationBar];

    self.customNavView.lbl_TitleView.text = [Strings findCourses];
    for(UIView* view in self.customNavView.subviews) {
        if([view isKindOfClass:[UIButton class]]) {
            [((UIButton*)view)setImage : nil forState : UIControlStateNormal];
        }
    }
    [self.customNavView.btn_Back setImage:[UIImage MenuIcon] forState:UIControlStateNormal];
    [self.customNavView.btn_Back setFrame:CGRectMake(8, 31, 22, 22)];
    [self.customNavView.btn_Back addTarget:self action:@selector(backNavigationPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [[OEXStyles sharedStyles] applyMockNavigationBarStyleToView:self.customNavView label:self.customNavView.lbl_TitleView leftIconButton:self.customNavView.btn_Back];
}

- (void)backNavigationPressed {
    [self toggleReveal];
}

- (void)toggleReveal {
    [self.revealViewController toggleDrawerAnimated:YES];
}

- (void)showCourseInfoWithPathID:(NSString*)coursePathID {
    OEXCourseInfoViewController* courseInfoViewController = [[OEXCourseInfoViewController alloc] initWithPathID:coursePathID];
    [self.navigationController pushViewController:courseInfoViewController animated:YES];
}

- (BOOL)webViewHelper:(OEXFindCoursesWebViewHelper*)webViewHelper shouldLoadURLWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString* coursePathID = [self getCoursePathIDFromURL:request.URL];
    if(coursePathID != nil) {
        [self showCourseInfoWithPathID:coursePathID];
        return NO;
    }
    return YES;
}

- (NSString*)getCoursePathIDFromURL:(NSURL*)url {
    if([url.scheme isEqualToString:OEXFindCoursesLinkURLScheme] && [url.oex_hostlessPath isEqualToString:OEXFindCoursesCourseInfoPath]) {
        NSString* path = url.oex_queryParameters[OEXFindCoursesPathIDKey];
        // the site sends us things of the form "course/<path_id>" we only want the path id
        NSString* pathID = [path stringByReplacingOccurrencesOfString:OEXFindCoursePathPrefix withString:@"" options:0 range:NSMakeRange(0, OEXFindCoursePathPrefix.length)];
        return pathID;
    }
    return nil;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [OEXStyles sharedStyles].standardStatusBarStyle;
}

@end
