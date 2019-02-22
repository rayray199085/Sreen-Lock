//
//  SCMyView.m
//  ScreenLock
//
//  Created by Stephen Cao on 22/2/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

#import "SCMyView.h"
#define buttonCount 9
#define imageWidth [[UIImage imageNamed:@"gesture_node_normal"] size].width
@interface SCMyView()
@property(nonatomic,strong)NSMutableArray *buttons;
@property(nonatomic,strong)NSMutableArray *buttonPath;
@property(nonatomic,assign)CGPoint currentPoint;
@property(nonatomic,assign)BOOL shouldRemoveRedundantPath;
@end
@implementation SCMyView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
/*
 Initialize all buttons and disable them
 */
- (NSMutableArray *)buttons{
    if(_buttons == nil){
        _buttons = [NSMutableArray arrayWithCapacity:buttonCount];
        for(int i = 0; i < buttonCount; i++){
            UIButton *button = [[UIButton alloc]init];
            button.userInteractionEnabled = NO;
            [self addSubview:button];
            [_buttons addObject:button];
        }
    }
    return _buttons;
}
/*
 This array for storing selected buttons
 */
- (NSMutableArray *)buttonPath{
    if(_buttonPath == nil){
        _buttonPath = [[NSMutableArray alloc]init];
    }
    return _buttonPath;
}
/*
 Build the frame of the board and set up button's image in normal, selected and error status
 */
- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat parentW = self.frame.size.width;
//    CGFloat parentH = self.frame.size.height;
    UIImage *image = [UIImage imageNamed:@"gesture_node_normal"];
    CGFloat imageW = image.size.width;
    CGFloat imageH = image.size.height;
    CGFloat margin = (parentW - imageW * 3)/2;
    for(int i = 0; i < self.buttons.count; i++){
        UIButton *currentBtn = self.buttons[i];
        currentBtn.frame = CGRectMake((margin + imageW) *(i % 3), (margin + imageW) *(i / 3), imageW, imageH);
        [currentBtn setImage:image forState:UIControlStateNormal];
        [currentBtn setImage:[UIImage imageNamed:@"gesture_node_highlighted"] forState:UIControlStateSelected];
        [currentBtn setImage:[UIImage imageNamed:@"gesture_node_error"] forState:UIControlStateDisabled];
        currentBtn.tag = i;
    }
}
/*
 Draw lines between buttons
 */
- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    for(int i = 0; i < self.buttonPath.count; i++){
        CGPoint point = [self.buttonPath[i] center];
        if(i == 0){
            CGContextMoveToPoint(context, point.x, point.y);
        }else{
              CGContextAddLineToPoint(context, point.x, point.y);
        }
    }
    if(self.buttonPath.count > 0 && !self.shouldRemoveRedundantPath){
        CGContextAddLineToPoint(context, self.currentPoint.x, self.currentPoint.y);
    }
    CGContextSetRGBStrokeColor(context, 1, 1, 1, 1);
    CGContextSetLineWidth(context, 10);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextStrokePath(context);
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self updateButtonStatusWithTouchSet:touches andIsSelected:YES andShoudReset:NO];
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self updateButtonStatusWithTouchSet:touches andIsSelected:YES andShoudReset:NO];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.shouldRemoveRedundantPath = YES;
    [self checkCorrectnessOfPassword];
    [self updateButtonStatusWithTouchSet:touches andIsSelected:NO andShoudReset:YES];
}
/*
 Main function for recording selected buttons, and reset all buttons when wrong password is provided
 */
-(void)updateButtonStatusWithTouchSet:(NSSet<UITouch *>*)touches andIsSelected:(BOOL)isSelected andShoudReset:(BOOL)shouldReset{
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    self.currentPoint = point;
    for(UIButton *button in self.buttons){
        if(!shouldReset){
            if(CGRectContainsPoint(button.frame, point)){
                button.selected = isSelected;
                if(![self.buttonPath containsObject:button]){
                    [self.buttonPath addObject:button];
                }
            }
        }
        else{
             button.selected = NO;
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                for(UIButton *button in self.buttonPath){
                    button.enabled = YES;
                }
                self.userInteractionEnabled = YES;
                [self.buttonPath removeAllObjects];
                [self setNeedsDisplay];
                self.shouldRemoveRedundantPath = NO;
            });
        }
    }
    [self setNeedsDisplay];
}
/*
 Use a string to store selected buttons' tags and send them to the controller.
 A screenshot will also be sent as an image.
 */
-(void)checkCorrectnessOfPassword{
    NSMutableString *password = [[NSMutableString alloc]init];
    for(UIButton *button in self.buttonPath){
        [password appendString:[NSString stringWithFormat:@"%ld",button.tag]];
    }
    if([self.delegate respondsToSelector:@selector(getInputPasswordWithView:andPassword:andScreenShot:)]){
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self.layer renderInContext:context];
        UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        BOOL isCorrect = [self.delegate getInputPasswordWithView:self andPassword:password andScreenShot:image];
        if(!isCorrect){
            for(UIButton *button in self.buttonPath){
                button.enabled = NO;
            }
            self.userInteractionEnabled = NO;
        }
    }
    
}
@end
