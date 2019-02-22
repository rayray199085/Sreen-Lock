//
//  ViewController.m
//  ScreenLock
//
//  Created by Stephen Cao on 22/2/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

#import "ViewController.h"
#import "SCMyView.h"
@interface ViewController ()<SCMyViewDelegate>
@property (weak, nonatomic) IBOutlet SCMyView *passwordView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //Set up the background image
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Home_refresh_bg"]];
    self.passwordView.delegate = self;
}
- (BOOL)getInputPasswordWithView:(SCMyView *)view andPassword:(NSString *)pwd andScreenShot:(UIImage *)image{
    self.imageView.image = image;
    NSLog(@"%@",pwd);
    return [pwd isEqualToString:@"012"];
}

@end
