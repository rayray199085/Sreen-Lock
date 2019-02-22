//
//  SCMyView.h
//  ScreenLock
//
//  Created by Stephen Cao on 22/2/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SCMyView;
// Delegate for delivering the password and the image of selected numbers
@protocol SCMyViewDelegate <NSObject>
-(BOOL)getInputPasswordWithView:(SCMyView *)view andPassword:(NSString *)pwd andScreenShot:(UIImage *)image;
@end
NS_ASSUME_NONNULL_BEGIN

@interface SCMyView : UIView
@property(nonatomic,weak)id<SCMyViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
