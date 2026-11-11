//
//  ControlsDemos.m
//  ObjCGallery
//
//  Buttons, value controls, pickers, text and progress.
//

#import "DemoKit.h"

#pragma mark - Buttons

@interface ButtonsViewController : DemoViewController
@property (nonatomic, strong) UILabel *status;
@property (nonatomic) NSInteger taps;
@end

@implementation ButtonsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIStackView *status = [self addSection:@"Status"];
    self.status = DemoLabel(@"Tap a button.", UIFontTextStyleBody);
    [status addArrangedSubview:self.status];

    UIStackView *styles = [self addSection:@"UIButton.Configuration"];
    [styles addArrangedSubview:DemoRow(@[
        [self button:@"Plain" config:[UIButtonConfiguration plainButtonConfiguration]],
        [self button:@"Gray" config:[UIButtonConfiguration grayButtonConfiguration]],
        [self button:@"Tinted" config:[UIButtonConfiguration tintedButtonConfiguration]],
    ])];
    UIButtonConfiguration *filled = [UIButtonConfiguration filledButtonConfiguration];
    filled.cornerStyle = UIButtonConfigurationCornerStyleCapsule;
    UIButtonConfiguration *bordered = [UIButtonConfiguration borderedButtonConfiguration];
    bordered.baseForegroundColor = UIColor.systemPinkColor;
    [styles addArrangedSubview:DemoRow(@[
        [self button:@"Filled" config:[UIButtonConfiguration filledButtonConfiguration]],
        [self button:@"Capsule" config:filled],
        [self button:@"Bordered" config:bordered],
    ])];

    UIStackView *rich = [self addSection:@"Images, subtitles and activity"];
    UIButtonConfiguration *download = [UIButtonConfiguration filledButtonConfiguration];
    download.title = @"Download";
    download.subtitle = @"12.4 MB";
    download.image = [UIImage systemImageNamed:@"arrow.down.circle.fill"];
    download.imagePadding = 8;
    download.titleAlignment = UIButtonConfigurationTitleAlignmentLeading;
    UIButton *downloadButton = [UIButton buttonWithConfiguration:download primaryAction:nil];
    __weak typeof(downloadButton) weakDownload = downloadButton;
    downloadButton.configurationUpdateHandler = ^(UIButton *button) {
        UIButtonConfiguration *c = button.configuration;
        c.showsActivityIndicator = button.isSelected;
        c.title = button.isSelected ? @"Downloading…" : @"Download";
        button.configuration = c;
    };
    [downloadButton addAction:[UIAction actionWithHandler:^(UIAction *action) {
        weakDownload.selected = !weakDownload.selected;
    }] forControlEvents:UIControlEventTouchUpInside];
    [rich addArrangedSubview:downloadButton];

    UIButtonConfiguration *heart = [UIButtonConfiguration tintedButtonConfiguration];
    heart.image = [UIImage systemImageNamed:@"heart"];
    heart.baseForegroundColor = UIColor.systemRedColor;
    heart.baseBackgroundColor = UIColor.systemRedColor;
    UIButton *heartButton = [UIButton buttonWithConfiguration:heart primaryAction:nil];
    heartButton.changesSelectionAsPrimaryAction = YES;
    heartButton.configurationUpdateHandler = ^(UIButton *button) {
        UIButtonConfiguration *c = button.configuration;
        c.image = [UIImage systemImageNamed:button.isSelected ? @"heart.fill" : @"heart"];
        button.configuration = c;
    };
    UIButton *disabled = [self button:@"Disabled" config:[UIButtonConfiguration filledButtonConfiguration]];
    disabled.enabled = NO;
    [rich addArrangedSubview:DemoRow(@[heartButton, disabled])];

    UIStackView *menus = [self addSection:@"Menus" note:@"A pull-down menu, and a pop-up button that shows its selection."];
    __weak typeof(self) weakSelf = self;
    UIAction *delete = [UIAction actionWithTitle:@"Delete" image:[UIImage systemImageNamed:@"trash"] identifier:nil handler:^(UIAction *a) { [weakSelf say:@"Delete"]; }];
    delete.attributes = UIMenuElementAttributesDestructive;
    UIMenu *menu = [UIMenu menuWithTitle:@"" children:@[
        [UIAction actionWithTitle:@"Duplicate" image:[UIImage systemImageNamed:@"plus.square.on.square"] identifier:nil handler:^(UIAction *a) { [weakSelf say:@"Duplicate"]; }],
        [UIAction actionWithTitle:@"Rename" image:[UIImage systemImageNamed:@"pencil"] identifier:nil handler:^(UIAction *a) { [weakSelf say:@"Rename"]; }],
        [UIMenu menuWithTitle:@"" image:nil identifier:nil options:UIMenuOptionsDisplayInline children:@[delete]],
    ]];
    UIButtonConfiguration *more = [UIButtonConfiguration grayButtonConfiguration];
    more.title = @"Actions";
    more.image = [UIImage systemImageNamed:@"ellipsis.circle"];
    more.imagePadding = 6;
    UIButton *menuButton = [UIButton buttonWithConfiguration:more primaryAction:nil];
    menuButton.menu = menu;
    menuButton.showsMenuAsPrimaryAction = YES;

    NSMutableArray *sortActions = [NSMutableArray array];
    for (NSString *option in @[@"Name", @"Date", @"Size"]) {
        [sortActions addObject:[UIAction actionWithTitle:option image:nil identifier:nil handler:^(UIAction *a) { [weakSelf say:[@"Sort by " stringByAppendingString:option]]; }]];
    }
    UIButton *popup = [UIButton buttonWithConfiguration:[UIButtonConfiguration borderedButtonConfiguration] primaryAction:nil];
    popup.menu = [UIMenu menuWithChildren:sortActions];
    popup.showsMenuAsPrimaryAction = YES;
    popup.changesSelectionAsPrimaryAction = YES;
    [menus addArrangedSubview:DemoRow(@[menuButton, popup])];
}

- (UIButton *)button:(NSString *)title config:(UIButtonConfiguration *)config {
    config.title = title;
    __weak typeof(self) weakSelf = self;
    return [UIButton buttonWithConfiguration:config primaryAction:[UIAction actionWithHandler:^(UIAction *action) {
        weakSelf.taps += 1;
        [weakSelf say:[NSString stringWithFormat:@"%@ tapped (%ld)", title, (long)weakSelf.taps]];
    }]];
}

- (void)say:(NSString *)text {
    self.status.text = text;
}

@end

#pragma mark - Switches, sliders and more

@interface ControlsViewController : DemoViewController
@property (nonatomic, strong) UILabel *value;
@end

@implementation ControlsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIStackView *switches = [self addSection:@"UISwitch"];
    for (NSArray *item in @[@[@"Wi-Fi", @YES, UIColor.systemGreenColor], @[@"Bluetooth", @NO, UIColor.systemBlueColor], @[@"Airplane Mode", @NO, UIColor.systemOrangeColor]]) {
        UISwitch *toggle = [[UISwitch alloc] init];
        toggle.on = [item[1] boolValue];
        toggle.onTintColor = item[2];
        UILabel *label = DemoLabel(item[0], UIFontTextStyleBody);
        [label setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [switches addArrangedSubview:DemoRow(@[label, toggle])];
    }

    UIStackView *sliders = [self addSection:@"UISlider and UIStepper"];
    self.value = DemoLabel(@"Volume 50% · Quantity 2", UIFontTextStyleBody);
    [sliders addArrangedSubview:self.value];
    UISlider *slider = [[UISlider alloc] init];
    slider.value = 0.5;
    slider.minimumValueImage = [UIImage systemImageNamed:@"speaker.fill"];
    slider.maximumValueImage = [UIImage systemImageNamed:@"speaker.wave.3.fill"];
    UIStepper *stepper = [[UIStepper alloc] init];
    stepper.value = 2;
    stepper.maximumValue = 10;
    __weak typeof(self) weakSelf = self;
    __weak typeof(slider) weakSlider = slider;
    __weak typeof(stepper) weakStepper = stepper;
    UIAction *update = [UIAction actionWithHandler:^(UIAction *a) {
        weakSelf.value.text = [NSString stringWithFormat:@"Volume %d%% · Quantity %d", (int)roundf(weakSlider.value * 100), (int)weakStepper.value];
    }];
    [slider addAction:update forControlEvents:UIControlEventValueChanged];
    [stepper addAction:update forControlEvents:UIControlEventValueChanged];
    [sliders addArrangedSubview:slider];
    UISlider *tinted = [[UISlider alloc] init];
    tinted.value = 0.3;
    tinted.minimumTrackTintColor = UIColor.systemPinkColor;
    tinted.thumbTintColor = UIColor.systemPinkColor;
    [sliders addArrangedSubview:tinted];
    [sliders addArrangedSubview:DemoRow(@[DemoLabel(@"Quantity", UIFontTextStyleBody), stepper])];

    UIStackView *segments = [self addSection:@"UISegmentedControl"];
    UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:@[@"Day", @"Week", @"Month", @"Year"]];
    seg.selectedSegmentIndex = 1;
    [segments addArrangedSubview:seg];
    UISegmentedControl *icons = [[UISegmentedControl alloc] initWithItems:@[
        [UIImage systemImageNamed:@"list.bullet"], [UIImage systemImageNamed:@"square.grid.2x2"], [UIImage systemImageNamed:@"rectangle.grid.1x2"],
    ]];
    icons.selectedSegmentIndex = 0;
    icons.selectedSegmentTintColor = UIColor.systemBlueColor;
    [icons setTitleTextAttributes:@{ NSForegroundColorAttributeName: UIColor.whiteColor } forState:UIControlStateSelected];
    [segments addArrangedSubview:icons];

    UIStackView *colors = [self addSection:@"UIColorWell" note:@"Tap the well to open the system color picker."];
    UIColorWell *well = [[UIColorWell alloc] init];
    well.selectedColor = UIColor.systemIndigoColor;
    well.supportsAlpha = YES;
    UIView *swatch = DemoTile(UIColor.systemIndigoColor, 44);
    __weak typeof(well) weakWell = well;
    [well addAction:[UIAction actionWithHandler:^(UIAction *a) { swatch.backgroundColor = weakWell.selectedColor; }] forControlEvents:UIControlEventValueChanged];
    [colors addArrangedSubview:DemoRow(@[well, swatch, DemoLabel(@"Selected color", UIFontTextStyleBody)])];
}

@end

#pragma mark - Pickers

@interface PickersViewController : DemoViewController <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, strong) UILabel *picked;
@property (nonatomic, copy) NSArray<NSArray<NSString *> *> *components;
@end

@implementation PickersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIStackView *compact = [self addSection:@"UIDatePicker · compact"];
    UIDatePicker *compactPicker = [[UIDatePicker alloc] init];
    compactPicker.preferredDatePickerStyle = UIDatePickerStyleCompact;
    [compact addArrangedSubview:DemoRow(@[DemoLabel(@"Starts", UIFontTextStyleBody), compactPicker])];

    UIStackView *inline_ = [self addSection:@"UIDatePicker · inline"];
    UIDatePicker *inlinePicker = [[UIDatePicker alloc] init];
    inlinePicker.datePickerMode = UIDatePickerModeDate;
    inlinePicker.preferredDatePickerStyle = UIDatePickerStyleInline;
    [inline_ addArrangedSubview:inlinePicker];

    UIStackView *wheels = [self addSection:@"UIDatePicker · countdown wheels"];
    UIDatePicker *countdown = [[UIDatePicker alloc] init];
    countdown.datePickerMode = UIDatePickerModeCountDownTimer;
    countdown.preferredDatePickerStyle = UIDatePickerStyleWheels;
    countdown.countDownDuration = 25 * 60;
    [wheels addArrangedSubview:countdown];

    self.components = @[@[@"Small", @"Medium", @"Large"], @[@"Latte", @"Mocha", @"Flat white", @"Americano"], @[@"Hot", @"Iced"]];
    UIStackView *custom = [self addSection:@"UIPickerView"];
    self.picked = DemoLabel(@"Medium Mocha, Hot", UIFontTextStyleHeadline);
    [custom addArrangedSubview:self.picked];
    UIPickerView *picker = [[UIPickerView alloc] init];
    picker.dataSource = self;
    picker.delegate = self;
    [picker selectRow:1 inComponent:0 animated:NO];
    [picker selectRow:1 inComponent:1 animated:NO];
    [custom addArrangedSubview:picker];

    UIStackView *pages = [self addSection:@"UIPageControl"];
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = 6;
    pageControl.currentPage = 2;
    pageControl.pageIndicatorTintColor = UIColor.systemGray4Color;
    pageControl.currentPageIndicatorTintColor = UIColor.systemBlueColor;
    pageControl.backgroundStyle = UIPageControlBackgroundStyleProminent;
    [pages addArrangedSubview:pageControl];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.components.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.components[component].count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.components[component][row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.picked.text = [NSString stringWithFormat:@"%@ %@, %@",
                        self.components[0][[pickerView selectedRowInComponent:0]],
                        self.components[1][[pickerView selectedRowInComponent:1]],
                        self.components[2][[pickerView selectedRowInComponent:2]]];
}

@end

#pragma mark - Text

@interface TextViewController : DemoViewController <UITextFieldDelegate>
@end

@implementation TextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIStackView *fields = [self addSection:@"UITextField"];
    NSArray *specs = @[
        @[@"Name", @(UIKeyboardTypeDefault), @NO, @"person"],
        @[@"Email", @(UIKeyboardTypeEmailAddress), @NO, @"envelope"],
        @[@"Password", @(UIKeyboardTypeDefault), @YES, @"lock"],
        @[@"Phone", @(UIKeyboardTypePhonePad), @NO, @"phone"],
    ];
    for (NSArray *spec in specs) {
        UITextField *field = [[UITextField alloc] init];
        field.placeholder = spec[0];
        field.keyboardType = [spec[1] integerValue];
        field.secureTextEntry = [spec[2] boolValue];
        field.borderStyle = UITextBorderStyleRoundedRect;
        field.clearButtonMode = UITextFieldViewModeWhileEditing;
        field.returnKeyType = UIReturnKeyDone;
        field.delegate = self;
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:spec[3]]];
        icon.tintColor = UIColor.secondaryLabelColor;
        icon.contentMode = UIViewContentModeCenter;
        icon.frame = CGRectMake(0, 0, 32, 24);
        field.leftView = icon;
        field.leftViewMode = UITextFieldViewModeAlways;
        [fields addArrangedSubview:field];
    }

    UIStackView *textView = [self addSection:@"UITextView" note:@"Editable, with detected links and phone numbers."];
    UITextView *tv = [[UITextView alloc] init];
    tv.text = @"UITextView scrolls and edits multiple lines. Visit https://developer.apple.com or call 10086.";
    tv.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    tv.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber;
    tv.editable = NO;
    tv.backgroundColor = UIColor.tertiarySystemFillColor;
    tv.layer.cornerRadius = 8;
    [tv.heightAnchor constraintEqualToConstant:90].active = YES;
    [textView addArrangedSubview:tv];

    UIStackView *attributed = [self addSection:@"NSAttributedString"];
    NSMutableAttributedString *s = [[NSMutableAttributedString alloc] init];
    UIFont *body = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [s appendAttributedString:[[NSAttributedString alloc] initWithString:@"Bold " attributes:@{ NSFontAttributeName: [UIFont boldSystemFontOfSize:body.pointSize] }]];
    [s appendAttributedString:[[NSAttributedString alloc] initWithString:@"colored " attributes:@{ NSForegroundColorAttributeName: UIColor.systemPinkColor, NSFontAttributeName: body }]];
    [s appendAttributedString:[[NSAttributedString alloc] initWithString:@"underlined " attributes:@{ NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle), NSFontAttributeName: body }]];
    [s appendAttributedString:[[NSAttributedString alloc] initWithString:@"struck " attributes:@{ NSStrikethroughStyleAttributeName: @(NSUnderlineStyleSingle), NSFontAttributeName: body }]];
    [s appendAttributedString:[[NSAttributedString alloc] initWithString:@"highlighted " attributes:@{ NSBackgroundColorAttributeName: [UIColor.systemYellowColor colorWithAlphaComponent:0.4], NSFontAttributeName: body }]];
    NSTextAttachment *attachment = [NSTextAttachment textAttachmentWithImage:[UIImage systemImageNamed:@"star.fill"]];
    [s appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    [s appendAttributedString:[[NSAttributedString alloc] initWithString:@" and an inline symbol." attributes:@{ NSFontAttributeName: body }]];
    UILabel *rich = [[UILabel alloc] init];
    rich.attributedText = s;
    rich.numberOfLines = 0;
    [attributed addArrangedSubview:rich];

    UIStackView *styles = [self addSection:@"Dynamic Type styles"];
    NSArray *textStyles = @[@[@"Large Title", UIFontTextStyleLargeTitle], @[@"Title 2", UIFontTextStyleTitle2], @[@"Headline", UIFontTextStyleHeadline], @[@"Body", UIFontTextStyleBody], @[@"Caption", UIFontTextStyleCaption1]];
    for (NSArray *style in textStyles) {
        [styles addArrangedSubview:DemoLabel(style[0], style[1])];
    }
    UILabel *rounded = DemoLabel(@"Rounded design", UIFontTextStyleTitle3);
    UIFontDescriptor *desc = [rounded.font.fontDescriptor fontDescriptorWithDesign:UIFontDescriptorSystemDesignRounded];
    rounded.font = [UIFont fontWithDescriptor:desc size:0];
    [styles addArrangedSubview:rounded];
    UILabel *mono = DemoLabel(@"Monospaced digits 0123456789", UIFontTextStyleBody);
    mono.font = [UIFont monospacedDigitSystemFontOfSize:17 weight:UIFontWeightRegular];
    [styles addArrangedSubview:mono];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end

#pragma mark - Progress

@interface ProgressViewController : DemoViewController
@property (nonatomic, strong) UIProgressView *download;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation ProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIStackView *spinners = [self addSection:@"UIActivityIndicatorView"];
    UIActivityIndicatorView *medium = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    UIActivityIndicatorView *large = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    UIActivityIndicatorView *colored = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    colored.color = UIColor.systemPinkColor;
    for (UIActivityIndicatorView *v in @[medium, large, colored]) { [v startAnimating]; }
    [spinners addArrangedSubview:DemoRow(@[medium, large, colored])];

    UIStackView *bars = [self addSection:@"UIProgressView" note:@"The first bar advances on a timer; the others show styles and tints."];
    self.download = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [bars addArrangedSubview:self.download];
    UIProgressView *bar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    bar.progress = 0.6;
    [bars addArrangedSubview:bar];
    UIProgressView *tinted = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    tinted.progress = 0.35;
    tinted.progressTintColor = UIColor.systemGreenColor;
    tinted.trackTintColor = [UIColor.systemGreenColor colorWithAlphaComponent:0.2];
    [tinted.heightAnchor constraintEqualToConstant:8].active = YES;
    tinted.layer.cornerRadius = 4;
    tinted.clipsToBounds = YES;
    [bars addArrangedSubview:tinted];

    UIStackView *refresh = [self addSection:@"UIRefreshControl" note:@"Pull this page down to see the refresh control."];
    [refresh addArrangedSubview:DemoLabel(@"↓ Pull down", UIFontTextStyleBody)];
    UIRefreshControl *control = [[UIRefreshControl alloc] init];
    control.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing…"];
    __weak typeof(control) weakControl = control;
    [control addAction:[UIAction actionWithHandler:^(UIAction *a) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ [weakControl endRefreshing]; });
    }] forControlEvents:UIControlEventValueChanged];
    self.scrollView.refreshControl = control;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 repeats:YES block:^(NSTimer *t) {
        float p = weakSelf.download.progress + 0.01f;
        [weakSelf.download setProgress:(p > 1 ? 0 : p) animated:p <= 1];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.timer invalidate];
}

@end
