//
//  MotionDemos.m
//  ObjCGallery
//
//  UIView animation, Core Animation layers, UIKit Dynamics, Core Graphics, effects and gestures.
//

#import "DemoKit.h"

static UIButton *TintedButton(NSString *title, void (^handler)(void)) {
    UIButtonConfiguration *config = [UIButtonConfiguration tintedButtonConfiguration];
    config.title = title;
    return [UIButton buttonWithConfiguration:config primaryAction:[UIAction actionWithHandler:^(UIAction *a) { handler(); }]];
}

#pragma mark - UIView animation

@interface ViewAnimationViewController : DemoViewController
@property (nonatomic, strong) UIView *springBox;
@property (nonatomic, strong) NSLayoutConstraint *springLeading;
@property (nonatomic, strong) UIView *flipCard;
@property (nonatomic) BOOL flipped;
@property (nonatomic, strong) UIView *scrubBox;
@property (nonatomic, strong) UIViewPropertyAnimator *animator;
@end

@implementation ViewAnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakSelf = self;

    UIStackView *springs = [self addSection:@"Spring animation" note:@"animateWithDuration:delay:usingSpringWithDamping:… moves the box with a bounce."];
    UIView *track = [[UIView alloc] init];
    [track.heightAnchor constraintEqualToConstant:60].active = YES;
    self.springBox = DemoTile(UIColor.systemBlueColor, 60);
    self.springBox.translatesAutoresizingMaskIntoConstraints = NO;
    [track addSubview:self.springBox];
    self.springLeading = [self.springBox.leadingAnchor constraintEqualToAnchor:track.leadingAnchor];
    self.springLeading.active = YES;
    [self.springBox.centerYAnchor constraintEqualToAnchor:track.centerYAnchor].active = YES;
    [springs addArrangedSubview:track];
    [springs addArrangedSubview:DemoRow(@[
        TintedButton(@"Bouncy", ^{ [weakSelf moveSpringWithDamping:0.35]; }),
        TintedButton(@"Smooth", ^{ [weakSelf moveSpringWithDamping:1.0]; }),
    ])];

    UIStackView *transitions = [self addSection:@"Transitions" note:@"transitionWithView: flips between the two faces of the card."];
    self.flipCard = [[UIView alloc] init];
    self.flipCard.layer.cornerRadius = 16;
    [self.flipCard.heightAnchor constraintEqualToConstant:120].active = YES;
    [self renderCard];
    [transitions addArrangedSubview:self.flipCard];
    [transitions addArrangedSubview:DemoRow(@[
        TintedButton(@"Flip", ^{ [weakSelf flipWithOptions:UIViewAnimationOptionTransitionFlipFromLeft]; }),
        TintedButton(@"Curl", ^{ [weakSelf flipWithOptions:UIViewAnimationOptionTransitionCurlUp]; }),
        TintedButton(@"Dissolve", ^{ [weakSelf flipWithOptions:UIViewAnimationOptionTransitionCrossDissolve]; }),
    ])];

    UIStackView *scrub = [self addSection:@"UIViewPropertyAnimator" note:@"Drag the slider to scrub a paused animation; release Play to run it."];
    UIView *scrubTrack = [[UIView alloc] init];
    [scrubTrack.heightAnchor constraintEqualToConstant:90].active = YES;
    self.scrubBox = DemoTile(UIColor.systemPinkColor, 60);
    self.scrubBox.frame = CGRectMake(0, 15, 60, 60);
    self.scrubBox.translatesAutoresizingMaskIntoConstraints = YES;
    [scrubTrack addSubview:self.scrubBox];
    [scrub addArrangedSubview:scrubTrack];
    UISlider *slider = [[UISlider alloc] init];
    __weak typeof(slider) weakSlider = slider;
    [slider addAction:[UIAction actionWithHandler:^(UIAction *a) {
        [weakSelf ensureAnimator];
        weakSelf.animator.fractionComplete = weakSlider.value;
    }] forControlEvents:UIControlEventValueChanged];
    [scrub addArrangedSubview:slider];
    [scrub addArrangedSubview:TintedButton(@"Play", ^{
        [weakSelf ensureAnimator];
        [weakSelf.animator startAnimation];
    })];
}

- (void)moveSpringWithDamping:(CGFloat)damping {
    CGFloat end = self.springBox.superview.bounds.size.width - 60;
    self.springLeading.constant = self.springLeading.constant > 0 ? 0 : end;
    [UIView animateWithDuration:0.9 delay:0 usingSpringWithDamping:damping initialSpringVelocity:0.5 options:0 animations:^{
        self.springBox.transform = self.springLeading.constant > 0 ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformIdentity;
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)renderCard {
    for (UIView *v in self.flipCard.subviews) { [v removeFromSuperview]; }
    self.flipCard.backgroundColor = self.flipped ? UIColor.systemOrangeColor : UIColor.systemIndigoColor;
    UILabel *label = DemoLabel(self.flipped ? @"Back side" : @"Front side", UIFontTextStyleTitle2);
    label.textColor = UIColor.whiteColor;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [self.flipCard addSubview:label];
    [label.centerXAnchor constraintEqualToAnchor:self.flipCard.centerXAnchor].active = YES;
    [label.centerYAnchor constraintEqualToAnchor:self.flipCard.centerYAnchor].active = YES;
}

- (void)flipWithOptions:(UIViewAnimationOptions)options {
    self.flipped = !self.flipped;
    [UIView transitionWithView:self.flipCard duration:0.6 options:options animations:^{ [self renderCard]; } completion:nil];
}

- (void)ensureAnimator {
    if (self.animator && self.animator.state != UIViewAnimatingStateInactive) { return; }
    CGFloat end = self.scrubBox.superview.bounds.size.width - 60;
    self.scrubBox.frame = CGRectMake(0, 15, 60, 60);
    self.scrubBox.transform = CGAffineTransformIdentity;
    self.scrubBox.backgroundColor = UIColor.systemPinkColor;
    self.animator = [[UIViewPropertyAnimator alloc] initWithDuration:1.2 curve:UIViewAnimationCurveEaseInOut animations:^{
        self.scrubBox.frame = CGRectMake(end, 15, 60, 60);
        self.scrubBox.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.scrubBox.backgroundColor = UIColor.systemTealColor;
    }];
    self.animator.pausesOnCompletion = NO;
    [self.animator pauseAnimation];
}

@end

#pragma mark - Core Animation

@interface CoreAnimationViewController : DemoViewController
@property (nonatomic, strong) CAShapeLayer *ring;
@end

@implementation CoreAnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakSelf = self;

    UIStackView *shape = [self addSection:@"CAShapeLayer stroke" note:@"strokeEnd animated with CABasicAnimation."];
    UIView *ringHost = [[UIView alloc] init];
    [ringHost.heightAnchor constraintEqualToConstant:130].active = YES;
    self.ring = [CAShapeLayer layer];
    self.ring.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(65, 65) radius:52 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES].CGPath;
    self.ring.frame = CGRectMake(0, 0, 130, 130);
    self.ring.fillColor = UIColor.clearColor.CGColor;
    self.ring.strokeColor = UIColor.systemGreenColor.CGColor;
    self.ring.lineWidth = 14;
    self.ring.lineCap = kCALineCapRound;
    self.ring.strokeEnd = 0.75;
    CAShapeLayer *trackLayer = [CAShapeLayer layer];
    trackLayer.path = self.ring.path;
    trackLayer.frame = self.ring.frame;
    trackLayer.fillColor = UIColor.clearColor.CGColor;
    trackLayer.strokeColor = UIColor.tertiarySystemFillColor.CGColor;
    trackLayer.lineWidth = 14;
    [ringHost.layer addSublayer:trackLayer];
    [ringHost.layer addSublayer:self.ring];
    [shape addArrangedSubview:ringHost];
    [shape addArrangedSubview:TintedButton(@"Animate", ^{
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        anim.fromValue = @0;
        anim.toValue = @0.75;
        anim.duration = 1.2;
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [weakSelf.ring addAnimation:anim forKey:@"stroke"];
    })];

    UIStackView *gradient = [self addSection:@"CAGradientLayer" note:@"The colors animate with a repeating CABasicAnimation."];
    UIView *gradientHost = [[UIView alloc] init];
    [gradientHost.heightAnchor constraintEqualToConstant:90].active = YES;
    gradientHost.layer.cornerRadius = 14;
    gradientHost.clipsToBounds = YES;
    CAGradientLayer *g = [CAGradientLayer layer];
    g.colors = @[(id)UIColor.systemPinkColor.CGColor, (id)UIColor.systemOrangeColor.CGColor, (id)UIColor.systemYellowColor.CGColor];
    g.startPoint = CGPointMake(0, 0.5);
    g.endPoint = CGPointMake(1, 0.5);
    g.frame = CGRectMake(0, 0, 1000, 90);
    CABasicAnimation *colors = [CABasicAnimation animationWithKeyPath:@"colors"];
    colors.toValue = @[(id)UIColor.systemBlueColor.CGColor, (id)UIColor.systemPurpleColor.CGColor, (id)UIColor.systemTealColor.CGColor];
    colors.duration = 2.5;
    colors.autoreverses = YES;
    colors.repeatCount = HUGE_VALF;
    [g addAnimation:colors forKey:@"colors"];
    [gradientHost.layer addSublayer:g];
    [gradient addArrangedSubview:gradientHost];

    UIStackView *replicator = [self addSection:@"CAReplicatorLayer" note:@"One dot, replicated twelve times with a delay: an activity spinner."];
    UIView *repHost = [[UIView alloc] init];
    [repHost.heightAnchor constraintEqualToConstant:110].active = YES;
    CAReplicatorLayer *rep = [CAReplicatorLayer layer];
    rep.frame = CGRectMake(0, 0, 110, 110);
    rep.instanceCount = 12;
    rep.instanceTransform = CATransform3DMakeRotation(M_PI * 2 / 12, 0, 0, 1);
    rep.instanceDelay = 1.0 / 12;
    CALayer *dot = [CALayer layer];
    dot.frame = CGRectMake(49, 6, 12, 12);
    dot.cornerRadius = 6;
    dot.backgroundColor = UIColor.systemIndigoColor.CGColor;
    CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fade.fromValue = @1;
    fade.toValue = @0.1;
    fade.duration = 1;
    fade.repeatCount = HUGE_VALF;
    [dot addAnimation:fade forKey:@"fade"];
    [rep addSublayer:dot];
    [repHost.layer addSublayer:rep];
    [replicator addArrangedSubview:repHost];

    UIStackView *emitter = [self addSection:@"CAEmitterLayer" note:@"Confetti from a line emitter."];
    UIView *emitHost = [[UIView alloc] init];
    emitHost.clipsToBounds = YES;
    emitHost.backgroundColor = UIColor.blackColor;
    emitHost.layer.cornerRadius = 12;
    [emitHost.heightAnchor constraintEqualToConstant:200].active = YES;
    CAEmitterLayer *confetti = [CAEmitterLayer layer];
    confetti.emitterPosition = CGPointMake(200, -10);
    confetti.emitterSize = CGSizeMake(400, 1);
    confetti.emitterShape = kCAEmitterLayerLine;
    NSMutableArray *cells = [NSMutableArray array];
    for (UIColor *color in @[UIColor.systemRedColor, UIColor.systemYellowColor, UIColor.systemGreenColor, UIColor.systemBlueColor, UIColor.systemPinkColor]) {
        CAEmitterCell *cell = [CAEmitterCell emitterCell];
        cell.birthRate = 6;
        cell.lifetime = 6;
        cell.velocity = 120;
        cell.velocityRange = 40;
        cell.emissionLongitude = M_PI;
        cell.emissionRange = M_PI / 6;
        cell.spin = 3;
        cell.spinRange = 4;
        cell.scale = 0.6;
        cell.scaleRange = 0.3;
        cell.color = color.CGColor;
        cell.contents = (id)[self confettiImage].CGImage;
        [cells addObject:cell];
    }
    confetti.emitterCells = cells;
    [emitHost.layer addSublayer:confetti];
    [emitter addArrangedSubview:emitHost];
}

- (UIImage *)confettiImage {
    UIGraphicsImageRenderer *r = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(10, 16)];
    return [r imageWithActions:^(UIGraphicsImageRendererContext *ctx) {
        [UIColor.whiteColor setFill];
        UIRectFill(CGRectMake(0, 0, 10, 16));
    }];
}

@end

#pragma mark - UIKit Dynamics

@interface DynamicsViewController : UIViewController
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravity;
@property (nonatomic, strong) UICollisionBehavior *collision;
@property (nonatomic, strong) UIDynamicItemBehavior *bounce;
@property (nonatomic, strong) UIAttachmentBehavior *drag;
@property (nonatomic) NSInteger count;
@end

@implementation DynamicsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.gravity = [[UIGravityBehavior alloc] initWithItems:@[]];
    self.collision = [[UICollisionBehavior alloc] initWithItems:@[]];
    self.collision.translatesReferenceBoundsIntoBoundary = YES;
    self.bounce = [[UIDynamicItemBehavior alloc] initWithItems:@[]];
    self.bounce.elasticity = 0.6;
    self.bounce.friction = 0.2;
    [self.animator addBehavior:self.gravity];
    [self.animator addBehavior:self.collision];
    [self.animator addBehavior:self.bounce];

    UILabel *hint = DemoLabel(@"Tap to drop a shape, drag one to throw it.", UIFontTextStyleFootnote);
    hint.textColor = UIColor.secondaryLabelColor;
    hint.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:hint];
    [hint.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:12].active = YES;
    [hint.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;

    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)]];
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.count == 0) {
        for (int i = 0; i < 6; i++) {
            [self dropAt:CGPointMake(60 + i * 50, 160 + (i % 2) * 40)];
        }
    }
}

- (void)tapped:(UITapGestureRecognizer *)tap {
    [self dropAt:[tap locationInView:self.view]];
}

- (void)dropAt:(CGPoint)point {
    CGFloat size = 36 + arc4random_uniform(30);
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(point.x - size / 2, point.y - size / 2, size, size)];
    v.backgroundColor = [UIColor colorWithHue:(self.count % 12) / 12.0 saturation:0.6 brightness:0.95 alpha:1];
    v.layer.cornerRadius = self.count % 2 ? size / 2 : 8;
    [self.view addSubview:v];
    [self.gravity addItem:v];
    [self.collision addItem:v];
    [self.bounce addItem:v];
    self.count += 1;
}

- (void)panned:(UIPanGestureRecognizer *)pan {
    CGPoint p = [pan locationInView:self.view];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            UIView *hit = [self.view hitTest:p withEvent:nil];
            if (hit && hit != self.view && [self.gravity.items containsObject:hit]) {
                self.drag = [[UIAttachmentBehavior alloc] initWithItem:hit attachedToAnchor:p];
                [self.animator addBehavior:self.drag];
            }
            break;
        }
        case UIGestureRecognizerStateChanged:
            self.drag.anchorPoint = p;
            break;
        default:
            if (self.drag) {
                UIView *item = (UIView *)self.drag.items.firstObject;
                [self.animator removeBehavior:self.drag];
                self.drag = nil;
                [self.bounce addLinearVelocity:[pan velocityInView:self.view] forItem:item];
            }
            break;
    }
}

@end

#pragma mark - Core Graphics

@interface ChartView : UIView
@end

@implementation ChartView

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat values[] = {0.3, 0.55, 0.42, 0.8, 0.62, 0.9, 0.7};
    NSInteger n = 7;
    CGFloat w = rect.size.width, h = rect.size.height - 10;
    UIBezierPath *line = [UIBezierPath bezierPath];
    for (NSInteger i = 0; i < n; i++) {
        CGPoint p = CGPointMake(w * i / (n - 1), h - h * values[i] + 5);
        i == 0 ? [line moveToPoint:p] : [line addLineToPoint:p];
    }
    // Gradient fill under the line.
    UIBezierPath *area = [line copy];
    [area addLineToPoint:CGPointMake(w, rect.size.height)];
    [area addLineToPoint:CGPointMake(0, rect.size.height)];
    [area closePath];
    CGContextSaveGState(ctx);
    [area addClip];
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    NSArray *colors = @[(id)[UIColor.systemBlueColor colorWithAlphaComponent:0.45].CGColor, (id)[UIColor.systemBlueColor colorWithAlphaComponent:0.0].CGColor];
    CGGradientRef gradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)colors, NULL);
    CGContextDrawLinearGradient(ctx, gradient, CGPointZero, CGPointMake(0, rect.size.height), 0);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(space);
    CGContextRestoreGState(ctx);
    [UIColor.systemBlueColor setStroke];
    line.lineWidth = 3;
    line.lineJoinStyle = kCGLineJoinRound;
    [line stroke];
    for (NSInteger i = 0; i < n; i++) {
        CGPoint p = CGPointMake(w * i / (n - 1), h - h * values[i] + 5);
        [UIColor.systemBackgroundColor setFill];
        UIBezierPath *dot = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(p.x - 5, p.y - 5, 10, 10)];
        [dot fill];
        [dot stroke];
    }
}

@end

@interface SketchView : UIView
@property (nonatomic, strong) NSMutableArray<UIBezierPath *> *paths;
@property (nonatomic, strong) UIColor *ink;
@end

@implementation SketchView

- (instancetype)init {
    if ((self = [super initWithFrame:CGRectZero])) {
        _paths = [NSMutableArray array];
        _ink = UIColor.systemPinkColor;
        self.backgroundColor = UIColor.tertiarySystemFillColor;
        self.layer.cornerRadius = 12;
        self.multipleTouchEnabled = NO;
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 5;
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    [path moveToPoint:[touches.anyObject locationInView:self]];
    [self.paths addObject:path];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.paths.lastObject addLineToPoint:[touches.anyObject locationInView:self]];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [self.ink setStroke];
    for (UIBezierPath *p in self.paths) { [p stroke]; }
}

@end

@interface DrawingViewController : DemoViewController
@end

@implementation DrawingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIStackView *chart = [self addSection:@"drawRect: with paths and a gradient"];
    ChartView *chartView = [[ChartView alloc] init];
    chartView.backgroundColor = UIColor.clearColor;
    chartView.contentMode = UIViewContentModeRedraw;
    [chartView.heightAnchor constraintEqualToConstant:150].active = YES;
    [chart addArrangedSubview:chartView];

    UIStackView *renderer = [self addSection:@"UIGraphicsImageRenderer" note:@"Images drawn in code: a badge, a striped pattern and a pie."];
    [renderer addArrangedSubview:DemoRow(@[
        [[UIImageView alloc] initWithImage:[self badgeImage]],
        [[UIImageView alloc] initWithImage:[self stripesImage]],
        [[UIImageView alloc] initWithImage:[self pieImage]],
    ])];

    UIStackView *sketch = [self addSection:@"Finger painting" note:@"Draw with one finger; the strokes are UIBezierPaths."];
    SketchView *pad = [[SketchView alloc] init];
    [pad.heightAnchor constraintEqualToConstant:220].active = YES;
    [sketch addArrangedSubview:pad];
    __weak typeof(pad) weakPad = pad;
    UISegmentedControl *colors = [[UISegmentedControl alloc] initWithItems:@[@"Pink", @"Blue", @"Green"]];
    colors.selectedSegmentIndex = 0;
    __weak typeof(colors) weakColors = colors;
    [colors addAction:[UIAction actionWithHandler:^(UIAction *a) {
        weakPad.ink = @[UIColor.systemPinkColor, UIColor.systemBlueColor, UIColor.systemGreenColor][weakColors.selectedSegmentIndex];
        [weakPad setNeedsDisplay];
    }] forControlEvents:UIControlEventValueChanged];
    UIButtonConfiguration *clearConfig = [UIButtonConfiguration grayButtonConfiguration];
    clearConfig.title = @"Clear";
    UIButton *clear = [UIButton buttonWithConfiguration:clearConfig primaryAction:[UIAction actionWithHandler:^(UIAction *a) {
        [weakPad.paths removeAllObjects];
        [weakPad setNeedsDisplay];
    }]];
    [sketch addArrangedSubview:DemoRow(@[colors, clear])];

    // The scroll view must not steal the drawing touches.
    self.scrollView.canCancelContentTouches = NO;
    self.scrollView.delaysContentTouches = NO;
}

- (UIImage *)badgeImage {
    UIGraphicsImageRenderer *r = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(80, 80)];
    return [r imageWithActions:^(UIGraphicsImageRendererContext *ctx) {
        [UIColor.systemOrangeColor setFill];
        [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(4, 4, 72, 72)] fill];
        NSDictionary *attrs = @{ NSFontAttributeName: [UIFont systemFontOfSize:30 weight:UIFontWeightHeavy], NSForegroundColorAttributeName: UIColor.whiteColor };
        CGSize s = [@"42" sizeWithAttributes:attrs];
        [@"42" drawAtPoint:CGPointMake((80 - s.width) / 2, (80 - s.height) / 2) withAttributes:attrs];
    }];
}

- (UIImage *)stripesImage {
    UIGraphicsImageRenderer *r = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(80, 80)];
    return [r imageWithActions:^(UIGraphicsImageRendererContext *ctx) {
        [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 80, 80) cornerRadius:14] addClip];
        for (int i = -8; i < 16; i++) {
            [(i % 2 ? UIColor.systemTealColor : UIColor.systemIndigoColor) setFill];
            UIBezierPath *band = [UIBezierPath bezierPath];
            [band moveToPoint:CGPointMake(i * 10, 0)];
            [band addLineToPoint:CGPointMake(i * 10 + 10, 0)];
            [band addLineToPoint:CGPointMake(i * 10 + 90, 80)];
            [band addLineToPoint:CGPointMake(i * 10 + 80, 80)];
            [band fill];
        }
    }];
}

- (UIImage *)pieImage {
    UIGraphicsImageRenderer *r = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(80, 80)];
    return [r imageWithActions:^(UIGraphicsImageRendererContext *ctx) {
        CGFloat shares[] = {0.45, 0.3, 0.25};
        NSArray *colors = @[UIColor.systemRedColor, UIColor.systemYellowColor, UIColor.systemGreenColor];
        CGFloat start = -M_PI_2;
        for (int i = 0; i < 3; i++) {
            CGFloat end = start + shares[i] * 2 * M_PI;
            UIBezierPath *slice = [UIBezierPath bezierPath];
            [slice moveToPoint:CGPointMake(40, 40)];
            [slice addArcWithCenter:CGPointMake(40, 40) radius:38 startAngle:start endAngle:end clockwise:YES];
            [slice closePath];
            [colors[i] setFill];
            [slice fill];
            start = end;
        }
    }];
}

@end

#pragma mark - Blur and symbols

@interface EffectsViewController : DemoViewController
@end

@implementation EffectsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIStackView *blur = [self addSection:@"UIVisualEffectView" note:@"System materials over a colorful background, with vibrant labels."];
    UIView *backdrop = [[UIView alloc] init];
    backdrop.clipsToBounds = YES;
    backdrop.layer.cornerRadius = 12;
    [backdrop.heightAnchor constraintEqualToConstant:220].active = YES;
    CAGradientLayer *g = [CAGradientLayer layer];
    g.colors = @[(id)UIColor.systemPinkColor.CGColor, (id)UIColor.systemOrangeColor.CGColor, (id)UIColor.systemBlueColor.CGColor];
    g.startPoint = CGPointZero;
    g.endPoint = CGPointMake(1, 1);
    g.frame = CGRectMake(0, 0, 1000, 220);
    [backdrop.layer addSublayer:g];
    NSArray *styles = @[@[@"Ultra thin", @(UIBlurEffectStyleSystemUltraThinMaterial)], @[@"Thin", @(UIBlurEffectStyleSystemThinMaterial)],
                        @[@"Regular", @(UIBlurEffectStyleSystemMaterial)], @[@"Thick", @(UIBlurEffectStyleSystemThickMaterial)]];
    UIStackView *grid = [[UIStackView alloc] init];
    grid.axis = UILayoutConstraintAxisVertical;
    grid.distribution = UIStackViewDistributionFillEqually;
    grid.spacing = 10;
    grid.translatesAutoresizingMaskIntoConstraints = NO;
    for (int row = 0; row < 2; row++) {
        UIStackView *line = [[UIStackView alloc] init];
        line.distribution = UIStackViewDistributionFillEqually;
        line.spacing = 10;
        for (int col = 0; col < 2; col++) {
            NSArray *style = styles[row * 2 + col];
            UIBlurEffect *effect = [UIBlurEffect effectWithStyle:[style[1] integerValue]];
            UIVisualEffectView *v = [[UIVisualEffectView alloc] initWithEffect:effect];
            v.layer.cornerRadius = 12;
            v.clipsToBounds = YES;
            UIVisualEffectView *vibrancy = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect effectForBlurEffect:effect style:UIVibrancyEffectStyleLabel]];
            vibrancy.frame = v.contentView.bounds;
            vibrancy.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            UILabel *label = DemoLabel(style[0], UIFontTextStyleHeadline);
            label.textAlignment = NSTextAlignmentCenter;
            label.frame = vibrancy.contentView.bounds;
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [vibrancy.contentView addSubview:label];
            [v.contentView addSubview:vibrancy];
            [line addArrangedSubview:v];
        }
        [grid addArrangedSubview:line];
    }
    [backdrop addSubview:grid];
    [NSLayoutConstraint activateConstraints:@[
        [grid.topAnchor constraintEqualToAnchor:backdrop.topAnchor constant:12],
        [grid.bottomAnchor constraintEqualToAnchor:backdrop.bottomAnchor constant:-12],
        [grid.leadingAnchor constraintEqualToAnchor:backdrop.leadingAnchor constant:12],
        [grid.trailingAnchor constraintEqualToAnchor:backdrop.trailingAnchor constant:-12],
    ]];
    [blur addArrangedSubview:backdrop];

    UIStackView *symbols = [self addSection:@"SF Symbol configurations"];
    NSArray *names = @[@"cloud.sun.rain.fill", @"heart.text.square.fill", @"person.crop.circle.badge.checkmark", @"externaldrive.fill.badge.wifi"];
    NSArray *configs = @[
        @[@"Monochrome", [UIImageSymbolConfiguration configurationWithHierarchicalColor:UIColor.labelColor]],
        @[@"Hierarchical", [UIImageSymbolConfiguration configurationWithHierarchicalColor:UIColor.systemBlueColor]],
        @[@"Palette", [UIImageSymbolConfiguration configurationWithPaletteColors:@[UIColor.systemBlueColor, UIColor.systemOrangeColor, UIColor.systemGreenColor]]],
        @[@"Multicolor", [UIImageSymbolConfiguration configurationPreferringMulticolor]],
    ];
    for (NSArray *config in configs) {
        NSMutableArray *views = [NSMutableArray arrayWithObject:DemoLabel(config[0], UIFontTextStyleSubheadline)];
        [views[0] setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        for (NSString *name in names) {
            UIImageSymbolConfiguration *size = [UIImageSymbolConfiguration configurationWithPointSize:24];
            UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:name withConfiguration:[size configurationByApplyingConfiguration:config[1]]]];
            [iv setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
            [views addObject:iv];
        }
        [symbols addArrangedSubview:DemoRow(views)];
    }

    UIStackView *weights = [self addSection:@"Weights and scales"];
    NSMutableArray *weightViews = [NSMutableArray array];
    for (NSNumber *w in @[@(UIImageSymbolWeightUltraLight), @(UIImageSymbolWeightRegular), @(UIImageSymbolWeightBold), @(UIImageSymbolWeightBlack)]) {
        UIImageSymbolConfiguration *c = [UIImageSymbolConfiguration configurationWithPointSize:30 weight:w.integerValue];
        [weightViews addObject:[[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"star.circle" withConfiguration:c]]];
    }
    for (NSNumber *s in @[@(UIImageSymbolScaleSmall), @(UIImageSymbolScaleLarge)]) {
        UIImageSymbolConfiguration *c = [UIImageSymbolConfiguration configurationWithTextStyle:UIFontTextStyleTitle2 scale:s.integerValue];
        [weightViews addObject:[[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"folder.fill" withConfiguration:c]]];
    }
    for (UIView *v in weightViews) { [v setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal]; }
    [weightViews addObject:[[UIView alloc] init]];  // trailing spacer takes the free width
    [weights addArrangedSubview:DemoRow(weightViews)];
}

@end

#pragma mark - Gestures

@interface GesturesViewController : UIViewController <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *card;
@property (nonatomic, strong) UILabel *log;
@end

@implementation GesturesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;

    self.log = DemoLabel(@"Tap, double-tap, long-press, drag, pinch, rotate or swipe the card.", UIFontTextStyleFootnote);
    self.log.textColor = UIColor.secondaryLabelColor;
    self.log.numberOfLines = 0;
    self.log.textAlignment = NSTextAlignmentCenter;
    self.log.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.log];
    [NSLayoutConstraint activateConstraints:@[
        [self.log.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:16],
        [self.log.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:24],
        [self.log.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-24],
    ]];

    self.card = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 180, 180)];
    self.card.backgroundColor = UIColor.systemIndigoColor;
    self.card.layer.cornerRadius = 24;
    self.card.layer.shadowColor = UIColor.blackColor.CGColor;
    self.card.layer.shadowOpacity = 0.2;
    self.card.layer.shadowRadius = 12;
    self.card.layer.shadowOffset = CGSizeMake(0, 6);
    UILabel *label = DemoLabel(@"Card", UIFontTextStyleTitle1);
    label.textColor = UIColor.whiteColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.frame = self.card.bounds;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.card addSubview:label];
    [self.view addSubview:self.card];

    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
    doubleTap.numberOfTapsRequired = 2;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [tap requireGestureRecognizerToFail:doubleTap];
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressed:)];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinched:)];
    UIRotationGestureRecognizer *rotate = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotated:)];
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    swipe.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
    swipe.numberOfTouchesRequired = 2;
    for (UIGestureRecognizer *g in @[doubleTap, tap, press, pan, pinch, rotate, swipe]) {
        g.delegate = self;
        [self.card addGestureRecognizer:g];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (CGPointEqualToPoint(self.card.center, CGPointMake(90, 90))) {
        self.card.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)a shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)b {
    // Pinch and rotate work together; everything else is exclusive.
    return ([a isKindOfClass:[UIPinchGestureRecognizer class]] || [a isKindOfClass:[UIRotationGestureRecognizer class]]) &&
           ([b isKindOfClass:[UIPinchGestureRecognizer class]] || [b isKindOfClass:[UIRotationGestureRecognizer class]]);
}

- (void)say:(NSString *)text {
    self.log.text = text;
}

- (void)tapped:(UITapGestureRecognizer *)g {
    self.card.backgroundColor = [UIColor colorWithHue:drand48() saturation:0.6 brightness:0.85 alpha:1];
    [self say:@"Tap: new color"];
}

- (void)doubleTapped:(UITapGestureRecognizer *)g {
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:0 animations:^{
        self.card.transform = CGAffineTransformIdentity;
        self.card.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    } completion:nil];
    [self say:@"Double tap: reset"];
}

- (void)pressed:(UILongPressGestureRecognizer *)g {
    if (g.state == UIGestureRecognizerStateBegan) {
        [[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium] impactOccurred];
        [UIView animateWithDuration:0.2 animations:^{ self.card.alpha = 0.6; }];
        [self say:@"Long press"];
    } else if (g.state == UIGestureRecognizerStateEnded || g.state == UIGestureRecognizerStateCancelled) {
        [UIView animateWithDuration:0.2 animations:^{ self.card.alpha = 1; }];
    }
}

- (void)panned:(UIPanGestureRecognizer *)g {
    CGPoint t = [g translationInView:self.view];
    self.card.center = CGPointMake(self.card.center.x + t.x, self.card.center.y + t.y);
    [g setTranslation:CGPointZero inView:self.view];
    [self say:[NSString stringWithFormat:@"Pan: %.0f, %.0f", self.card.center.x, self.card.center.y]];
}

- (void)pinched:(UIPinchGestureRecognizer *)g {
    self.card.transform = CGAffineTransformScale(self.card.transform, g.scale, g.scale);
    g.scale = 1;
    [self say:@"Pinch"];
}

- (void)rotated:(UIRotationGestureRecognizer *)g {
    self.card.transform = CGAffineTransformRotate(self.card.transform, g.rotation);
    g.rotation = 0;
    [self say:@"Rotate"];
}

- (void)swiped:(UISwipeGestureRecognizer *)g {
    [self say:@"Two-finger swipe"];
}

@end
