//
//  BannerScrollView.h
//  Wheaton App
//
//  Created by Chris Anderson on 8/31/13.
//
//

#import <UIKit/UIKit.h>

@interface BannerScrollView : UIScrollView <UIScrollViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (nonatomic, retain) NSTimer *scrollTimer;
@property (strong,nonatomic) NSArray *bannerImages;

- (void)loaded:(UIViewController *)parent;


@end
 