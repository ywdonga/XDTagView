//
//  ViewController.m
//  XDTagViewDemo
//
//  Created by MAC on 2020/9/24.
//

#import "ViewController.h"
#import "UIView+XDTag.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backViewHeight;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSMutableArray<NSString *> *mtbArray = [NSMutableArray array];
    for (int i=0; i<10; i++) {
        NSMutableString *str = [NSMutableString string];
        for (int j=0; j<=i; j++) {
            [str appendString:@(j).stringValue];
        }
        [mtbArray addObject:str];
    }
     self.backViewHeight.constant = [self.backView updateTagWithTitles:mtbArray maxWidth:self.backView.frame.size.width selectBack:^(NSArray<NSNumber *> * _Nonnull selectIndexs) {
         NSLog(@"-->%@", selectIndexs);
    }];
}


@end
