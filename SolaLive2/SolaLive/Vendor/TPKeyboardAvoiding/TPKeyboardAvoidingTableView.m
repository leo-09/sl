//
//  TPKeyboardAvoidingTableView.m
//
//  Created by Michael Tyson on 30/09/2013.
//  Copyright 2013 A Tasty Pixel. All rights reserved.
//

#import "TPKeyboardAvoidingTableView.h"

@interface TPKeyboardAvoidingTableView () <UITextFieldDelegate, UITextViewDelegate>

@end

@implementation TPKeyboardAvoidingTableView

#pragma mark - Setup/Teardown

- (void) setup {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TPKeyboardAvoiding_keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TPKeyboardAvoiding_keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToActiveTextField) name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToActiveTextField) name:UITextFieldTextDidBeginEditingNotification object:nil];
}

- (id) initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]) ) {
        return nil;
    }
    
    [self setup];
    return self;
}

- (id) initWithFrame:(CGRect)frame style:(UITableViewStyle)withStyle {
    if ( !(self = [super initWithFrame:frame style:withStyle]) ) {
        return nil;
    }
    
    [self setup];
    return self;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

- (void) setFrame:(CGRect) frame {
    [super setFrame:frame];
    [self TPKeyboardAvoiding_updateContentInset];
}

- (void) setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    [self TPKeyboardAvoiding_updateContentInset];
    
    // 我自己添加的调用，更新contentSize，要更新priorContentSize
    [self TPKeyboardAvoiding_updateFromContentSizeChange];
}

- (BOOL) focusNextTextField {
    return [self TPKeyboardAvoiding_focusNextTextField];
}

- (void) scrollToActiveTextField {
    return [self TPKeyboardAvoiding_scrollToActiveTextField];
}

#pragma mark - Responders, events

-(void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(TPKeyboardAvoiding_assignTextDelegateForViewsBeneathView:) object:self];
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self TPKeyboardAvoiding_findFirstResponderBeneathView:self] resignFirstResponder];
    [super touchesEnded:touches withEvent:event];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (![self focusNextTextField]) {
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(TPKeyboardAvoiding_assignTextDelegateForViewsBeneathView:) object:self];
    [self performSelector:@selector(TPKeyboardAvoiding_assignTextDelegateForViewsBeneathView:) withObject:self afterDelay:0.1];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
//    AppDelegate *delegae =[[UIApplication sharedApplication]delegate];
//    //取消高亮
//    [[[delegae.appData objectForKey:@"cells"]objectForKey:[[delegae.appData objectForKey:@"keysAll"] objectAtIndex:textField.tag]]setBackgroundColor:[UIColor whiteColor]];
//    //自动求和
//    NSArray *arry =[delegae.appData objectForKey:@"tfArray"];
//    int  totalNum =0;
//    int rrNum =0;
//    for (UITextField *tv in arry) {
//        if (tv == textField) {
//            UITextField * total = [arry objectAtIndex:[arry count]-1];
//  
//            for (UITextField *cc in arry) {
//                if ([arry indexOfObject:cc]<[arry count]-1) {
//                    rrNum = [cc.text intValue];
//                    totalNum = totalNum+rrNum;
//                }
//            }
//            total.text = [NSString stringWithFormat:@"%d",totalNum];
//            break;
//        }
//    }
}

@end
