//
//  PSG_AlertView.m
//  PSG_AlertView
//
//  Created by SNICE on 2018/9/19.
//  Copyright © 2018年 G. All rights reserved.
//

#import "PSG_AlertView.h"

#define PSG_AlertView_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width      //屏幕宽
#define PSG_AlertView_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height    //屏幕高

#define PSG_AlertView_HexColor(c) [UIColor colorWithRed:((c>>16)&0xFF)/255.0f green:((c>>8)&0xFF)/255.0f blue:(c&0xFF)/255.0f alpha:1.0f]

#define PSG_AlertView_ANIMATION_DURATION   0.25f        //动画时长

#define PSG_AlertView_TABLEVIEW_ROW_HEIGHT 35.0f
#define PSG_AlertView_TABLEVIEW_WIDTH      (PSG_AlertView_SCREEN_WIDTH  - 15.0f * 2)
#define PSG_AlertView_TABLEVIEW_HEIGHT     (PSG_AlertView_SCREEN_HEIGHT * 2.0 / 3.0)
#define PSG_AlertView_CANCEL_BUTTON_SPACE  10.0f

#define PSG_AlertView_WINDOWVIEW_HEIGHT    (PSG_AlertView_CANCEL_BUTTON_SPACE * 3 + PSG_AlertView_TABLEVIEW_ROW_HEIGHT + PSG_AlertView_TABLEVIEW_HEIGHT)       //显示视图高度

@implementation UIView (Frame)

- (void)setPosition:(CGPoint)point atAnchorPoint:(CGPoint)anchorPoint
{
    CGFloat x = point.x - anchorPoint.x * self.frame.size.width;
    CGFloat y = point.y - anchorPoint.y * self.frame.size.height;
    CGRect frame = self.frame;
    frame.origin = CGPointMake(x, y);
    self.frame = frame;
}

@end

@interface PSG_AlertView () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIWindow *window;                     //window
@property (nonatomic, strong) UIView *blackMask;                    //黑色笼罩
@property (nonatomic, strong) UIView *windowView;                   //显示view

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSString *titleKey;

@property (nonatomic, strong) void (^selectedRowAtIndexPath)(id obj, NSInteger index);
@property (nonatomic, strong) void (^didCancelClicked)(void);

@end

@implementation PSG_AlertView

+ (void)showAlertWithDataSource:(NSArray *)dataSource titleKey:(NSString *)titleKey didSelected:(void (^)(id obj, NSInteger index))didSelected didCanceled:(void (^)(void))didCanceled {
    if (!dataSource || dataSource.count == 0) return;
    PSG_AlertView *alertView = [[PSG_AlertView alloc] initWithDataSource:dataSource];
    alertView.titleKey = titleKey;
    alertView.selectedRowAtIndexPath = ^(id obj, NSInteger index) {
        if (didSelected) didSelected(obj, index);
    };
    alertView.didCancelClicked = ^{
        if (didCanceled) didCanceled();
    };
    [alertView show];
}

- (instancetype)initWithDataSource:(NSArray *)dataSource
{
    self = [super init];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        
        [self addSubview:self.blackMask];
        
        _dataSource = dataSource;
        CGFloat viewHeight = _dataSource.count * PSG_AlertView_TABLEVIEW_ROW_HEIGHT;
        CGFloat tableViewHeight = viewHeight < PSG_AlertView_TABLEVIEW_HEIGHT ? viewHeight : PSG_AlertView_TABLEVIEW_HEIGHT;
        CGFloat windowViewHeight = tableViewHeight + (PSG_AlertView_CANCEL_BUTTON_SPACE * 3 + PSG_AlertView_TABLEVIEW_ROW_HEIGHT);
        
        self.tableView.frame = CGRectMake(0, 0, PSG_AlertView_TABLEVIEW_WIDTH, tableViewHeight);
        [self.tableView setPosition:CGPointMake(PSG_AlertView_SCREEN_WIDTH / 2, 0) atAnchorPoint:CGPointMake(0.5, 0)];
        [self.windowView addSubview:self.tableView];
        
        [self.cancelButton setPosition:CGPointMake(PSG_AlertView_SCREEN_WIDTH / 2, tableViewHeight + PSG_AlertView_CANCEL_BUTTON_SPACE) atAnchorPoint:CGPointMake(0.5, 0)];
        [self.windowView addSubview:self.cancelButton];
        
        self.windowView.frame = CGRectMake(0, 0, PSG_AlertView_SCREEN_WIDTH, windowViewHeight);
        [self.windowView setPosition:CGPointMake(0, PSG_AlertView_SCREEN_HEIGHT) atAnchorPoint:CGPointZero];
        [self addSubview:self.windowView];
        
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        tapGR.numberOfTapsRequired = 1;
        tapGR.numberOfTouchesRequired = 1;
        tapGR.delegate = self;
        [self addGestureRecognizer:tapGR];
    }
    return self;
}

- (void)show {
    [self.window addSubview:self];
    [UIView animateWithDuration:PSG_AlertView_ANIMATION_DURATION animations:^{
        self.blackMask.alpha = 0.2f;
        [self.windowView setPosition:CGPointMake(0, PSG_AlertView_SCREEN_HEIGHT) atAnchorPoint:CGPointMake(0, 1)];
    } completion:^(BOOL finished) {
    }];
}

- (void)hide {
    [UIView animateWithDuration:PSG_AlertView_ANIMATION_DURATION animations:^{
        self.blackMask.alpha = 0.0f;
        [self.windowView setPosition:CGPointMake(0, PSG_AlertView_SCREEN_HEIGHT) atAnchorPoint:CGPointMake(0, 0)];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)cancelButtonAction:(UIButton *)sender {
    [self hide];
    if (self.didCancelClicked) {
        self.didCancelClicked();
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return  YES;
}

#pragma mark - tableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        cell.textLabel.textColor = PSG_AlertView_HexColor(0x111111);
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.numberOfLines = 1;
        cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
        cell.clipsToBounds = YES;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PSG_AlertView_SCREEN_WIDTH, 1.0f)];
        lineView.backgroundColor = PSG_AlertView_HexColor(0xf5f7f9);
        [cell.contentView addSubview:lineView];
        lineView.translatesAutoresizingMaskIntoConstraints = NO;
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:0.5f]];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.0f]];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeRight multiplier:1.0f constant:0.0f]];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f]];
    }
    id obj = self.dataSource[indexPath.row];
    id value = [obj valueForKey:_titleKey];
    if ([value isKindOfClass:[NSString class]]) {
        cell.textLabel.text = value;
    }
    return cell;
}

#pragma mark - tableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedRowAtIndexPath(self.dataSource[indexPath.row], indexPath.row);
    [self hide];
}

#pragma mark - Lazy loading

- (UIWindow *)window {
    if (!_window) {
        _window = [UIApplication sharedApplication].keyWindow;
    }
    return _window;
}

- (UIView *)blackMask {
    if (!_blackMask) {
        _blackMask = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _blackMask.clipsToBounds = YES;
        _blackMask.alpha = 0.0f;
        _blackMask.backgroundColor = [UIColor blackColor];
    }
    return _blackMask;
}

- (UIView *)windowView {
    if (!_windowView) {
        _windowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PSG_AlertView_SCREEN_WIDTH, PSG_AlertView_WINDOWVIEW_HEIGHT)];
        _windowView.backgroundColor = [UIColor clearColor];
        _windowView.clipsToBounds = YES;
    }
    return _windowView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, PSG_AlertView_TABLEVIEW_WIDTH, PSG_AlertView_TABLEVIEW_HEIGHT) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = PSG_AlertView_TABLEVIEW_ROW_HEIGHT;
        _tableView.layer.cornerRadius = 8.0f;
        _tableView.layer.masksToBounds = YES;
    }
    return _tableView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, PSG_AlertView_TABLEVIEW_WIDTH, PSG_AlertView_TABLEVIEW_ROW_HEIGHT)];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:PSG_AlertView_HexColor(0x111111) forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:13];
        _cancelButton.backgroundColor = [UIColor whiteColor];
        _cancelButton.layer.cornerRadius = 4.0f;
        _cancelButton.layer.masksToBounds = YES;
        [_cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

@end
