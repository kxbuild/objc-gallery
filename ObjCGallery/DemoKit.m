//
//  DemoKit.m
//  ObjCGallery
//

#import "DemoKit.h"

@interface DemoViewController ()
@property (nonatomic, strong, readwrite) UIScrollView *scrollView;
@property (nonatomic, strong, readwrite) UIStackView *stack;
@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;

    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self.view addSubview:self.scrollView];

    self.stack = [[UIStackView alloc] init];
    self.stack.axis = UILayoutConstraintAxisVertical;
    self.stack.spacing = 22;
    self.stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.stack];

    UILayoutGuide *content = self.scrollView.contentLayoutGuide;
    UILayoutGuide *frame = self.scrollView.frameLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.stack.topAnchor constraintEqualToAnchor:content.topAnchor constant:16],
        [self.stack.bottomAnchor constraintEqualToAnchor:content.bottomAnchor constant:-32],
        [self.stack.leadingAnchor constraintEqualToAnchor:frame.leadingAnchor constant:16],
        [self.stack.trailingAnchor constraintEqualToAnchor:frame.trailingAnchor constant:-16],
    ]];
}

- (UIStackView *)addSection:(NSString *)title {
    return [self addSection:title note:nil];
}

- (UIStackView *)addSection:(NSString *)title note:(NSString *)note {
    UIStackView *wrapper = [[UIStackView alloc] init];
    wrapper.axis = UILayoutConstraintAxisVertical;
    wrapper.spacing = 6;

    UILabel *heading = DemoLabel(title.uppercaseString, UIFontTextStyleFootnote);
    heading.textColor = UIColor.secondaryLabelColor;
    UIStackView *headingRow = DemoRow(@[heading]);
    headingRow.layoutMargins = UIEdgeInsetsMake(0, 12, 0, 12);
    headingRow.layoutMarginsRelativeArrangement = YES;
    [wrapper addArrangedSubview:headingRow];

    UIView *card = [[UIView alloc] init];
    card.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
    card.layer.cornerRadius = 12;
    card.layer.cornerCurve = kCACornerCurveContinuous;
    UIStackView *body = [[UIStackView alloc] init];
    body.axis = UILayoutConstraintAxisVertical;
    body.spacing = 12;
    body.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:body];
    [NSLayoutConstraint activateConstraints:@[
        [body.topAnchor constraintEqualToAnchor:card.topAnchor constant:14],
        [body.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-14],
        [body.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:16],
        [body.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-16],
    ]];
    [wrapper addArrangedSubview:card];

    if (note.length) {
        UILabel *footnote = DemoLabel(note, UIFontTextStyleFootnote);
        footnote.textColor = UIColor.secondaryLabelColor;
        footnote.numberOfLines = 0;
        UIStackView *noteRow = DemoRow(@[footnote]);
        noteRow.layoutMargins = UIEdgeInsetsMake(0, 12, 0, 12);
        noteRow.layoutMarginsRelativeArrangement = YES;
        [wrapper addArrangedSubview:noteRow];
    }
    [self.stack addArrangedSubview:wrapper];
    return body;
}

@end

UIStackView *DemoRow(NSArray<UIView *> *views) {
    UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:views];
    row.axis = UILayoutConstraintAxisHorizontal;
    row.spacing = 10;
    row.alignment = UIStackViewAlignmentCenter;
    return row;
}

UILabel *DemoLabel(NSString *text, UIFontTextStyle style) {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont preferredFontForTextStyle:style];
    label.adjustsFontForContentSizeCategory = YES;
    return label;
}

UIView *DemoTile(UIColor *color, CGFloat size) {
    UIView *tile = [[UIView alloc] init];
    tile.backgroundColor = color;
    tile.layer.cornerRadius = size * 0.2;
    tile.layer.cornerCurve = kCACornerCurveContinuous;
    [tile.widthAnchor constraintEqualToConstant:size].active = YES;
    [tile.heightAnchor constraintEqualToConstant:size].active = YES;
    return tile;
}
