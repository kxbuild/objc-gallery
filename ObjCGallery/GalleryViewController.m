//
//  GalleryViewController.m
//  ObjCGallery
//

#import "GalleryViewController.h"

/// One row of the gallery: the view controller class is created by name when the row is tapped.
@interface GalleryDemo : NSObject
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, copy) NSString *className;
@end

@implementation GalleryDemo
+ (instancetype)demo:(NSString *)identifier title:(NSString *)title summary:(NSString *)summary symbol:(NSString *)symbol color:(UIColor *)color className:(NSString *)className {
    GalleryDemo *d = [[GalleryDemo alloc] init];
    d.identifier = identifier;
    d.title = title;
    d.summary = summary;
    d.symbol = symbol;
    d.color = color;
    d.className = className;
    return d;
}
@end

@interface GalleryViewController () <UISearchResultsUpdating>
@property (nonatomic, copy) NSArray<NSDictionary *> *sections; // @{ @"title": NSString, @"demos": NSArray<GalleryDemo *> }
@property (nonatomic, copy) NSArray<NSDictionary *> *visibleSections;
@end

@implementation GalleryViewController

- (instancetype)init {
    return [super initWithStyle:UITableViewStyleInsetGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"UIKit Gallery";
    self.sections = @[
        @{ @"title": @"Controls", @"demos": @[
            [GalleryDemo demo:@"buttons" title:@"Buttons" summary:@"UIButton.Configuration styles, menus, pop-up buttons" symbol:@"button.programmable" color:UIColor.systemBlueColor className:@"ButtonsViewController"],
            [GalleryDemo demo:@"controls" title:@"Switches, Sliders & More" summary:@"UISwitch, UISlider, UIStepper, UISegmentedControl, UIColorWell" symbol:@"slider.horizontal.3" color:UIColor.systemGreenColor className:@"ControlsViewController"],
            [GalleryDemo demo:@"pickers" title:@"Pickers" summary:@"UIDatePicker styles, UIPickerView, UIPageControl" symbol:@"calendar" color:UIColor.systemRedColor className:@"PickersViewController"],
            [GalleryDemo demo:@"text" title:@"Text" summary:@"UITextField, UITextView, attributed strings, UILabel" symbol:@"textformat" color:UIColor.systemOrangeColor className:@"TextViewController"],
            [GalleryDemo demo:@"progress" title:@"Progress" summary:@"UIProgressView, UIActivityIndicatorView, refresh control" symbol:@"hourglass" color:UIColor.systemPurpleColor className:@"ProgressViewController"],
        ]},
        @{ @"title": @"Collections & Presentation", @"demos": @[
            [GalleryDemo demo:@"collection" title:@"Collection View" summary:@"Compositional layout, orthogonal scrolling, diffable data source" symbol:@"square.grid.2x2" color:UIColor.systemTealColor className:@"CollectionViewController"],
            [GalleryDemo demo:@"table" title:@"Table View" summary:@"Swipe actions, context menus, reordering" symbol:@"list.bullet.rectangle" color:UIColor.systemIndigoColor className:@"TableFeaturesViewController"],
            [GalleryDemo demo:@"alerts" title:@"Alerts & Sheets" summary:@"UIAlertController, sheet detents, activity view" symbol:@"exclamationmark.bubble" color:UIColor.systemPinkColor className:@"AlertsViewController"],
        ]},
        @{ @"title": @"Graphics & Motion", @"demos": @[
            [GalleryDemo demo:@"uiview" title:@"UIView Animation" summary:@"Springs, transitions, interactive UIViewPropertyAnimator" symbol:@"wand.and.stars" color:UIColor.systemOrangeColor className:@"ViewAnimationViewController"],
            [GalleryDemo demo:@"layers" title:@"Core Animation" summary:@"Shape, gradient, replicator and emitter layers" symbol:@"square.stack.3d.up" color:UIColor.systemBlueColor className:@"CoreAnimationViewController"],
            [GalleryDemo demo:@"dynamics" title:@"UIKit Dynamics" summary:@"Gravity, collision, elasticity; tap to add, drag to throw" symbol:@"circle.grid.cross" color:UIColor.systemGreenColor className:@"DynamicsViewController"],
            [GalleryDemo demo:@"drawing" title:@"Core Graphics" summary:@"drawRect:, paths, gradients and finger painting" symbol:@"paintbrush.pointed" color:UIColor.systemRedColor className:@"DrawingViewController"],
            [GalleryDemo demo:@"effects" title:@"Blur & Symbols" summary:@"UIVisualEffectView, vibrancy, SF Symbol configurations" symbol:@"drop.halffull" color:UIColor.systemCyanColor className:@"EffectsViewController"],
            [GalleryDemo demo:@"gestures" title:@"Gestures" summary:@"Tap, long press, pan, pinch, rotation, swipe" symbol:@"hand.draw" color:UIColor.systemPurpleColor className:@"GesturesViewController"],
        ]},
    ];
    self.visibleSections = self.sections;

    UISearchController *search = [[UISearchController alloc] initWithSearchResultsController:nil];
    search.searchResultsUpdater = self;
    search.obscuresBackgroundDuringPresentation = NO;
    search.searchBar.placeholder = @"Search demos";
    self.navigationItem.searchController = search;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;

    // Launch with `-demo <id>` to open a demo directly.
    NSString *launchDemo = [NSUserDefaults.standardUserDefaults stringForKey:@"demo"];
    if (launchDemo.length) {
        for (NSDictionary *section in self.sections) {
            for (GalleryDemo *demo in section[@"demos"]) {
                if ([demo.identifier isEqualToString:launchDemo]) {
                    [self openDemo:demo animated:NO];
                }
            }
        }
    }
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *query = searchController.searchBar.text;
    if (query.length == 0) {
        self.visibleSections = self.sections;
    } else {
        NSMutableArray *filtered = [NSMutableArray array];
        for (NSDictionary *section in self.sections) {
            NSPredicate *match = [NSPredicate predicateWithBlock:^BOOL(GalleryDemo *demo, NSDictionary *bindings) {
                return [demo.title localizedCaseInsensitiveContainsString:query] || [demo.summary localizedCaseInsensitiveContainsString:query];
            }];
            NSArray *demos = [section[@"demos"] filteredArrayUsingPredicate:match];
            if (demos.count) {
                [filtered addObject:@{ @"title": section[@"title"], @"demos": demos }];
            }
        }
        self.visibleSections = filtered;
    }
    [self.tableView reloadData];
}

- (void)openDemo:(GalleryDemo *)demo animated:(BOOL)animated {
    Class cls = NSClassFromString(demo.className);
    UIViewController *vc = [[cls alloc] init];
    vc.title = demo.title;
    vc.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    [self.navigationController pushViewController:vc animated:animated];
}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.visibleSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.visibleSections[section][@"demos"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.visibleSections[section][@"title"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"demo"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"demo"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    GalleryDemo *demo = self.visibleSections[indexPath.section][@"demos"][indexPath.row];
    UIListContentConfiguration *content = [UIListContentConfiguration subtitleCellConfiguration];
    content.text = demo.title;
    content.secondaryText = demo.summary;
    content.secondaryTextProperties.color = UIColor.secondaryLabelColor;
    content.secondaryTextProperties.numberOfLines = 1;
    content.image = [self iconForDemo:demo];
    content.imageProperties.cornerRadius = 7;
    content.imageToTextPadding = 12;
    cell.contentConfiguration = content;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self openDemo:self.visibleSections[indexPath.section][@"demos"][indexPath.row] animated:YES];
}

/// A white SF Symbol on a rounded colored square, drawn with UIGraphicsImageRenderer.
- (UIImage *)iconForDemo:(GalleryDemo *)demo {
    CGSize size = CGSizeMake(30, 30);
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:15 weight:UIImageSymbolWeightSemibold];
    UIImage *symbol = [[UIImage systemImageNamed:demo.symbol withConfiguration:config] imageWithTintColor:UIColor.whiteColor renderingMode:UIImageRenderingModeAlwaysOriginal];
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *ctx) {
        [demo.color setFill];
        [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height) cornerRadius:7] fill];
        CGSize s = symbol.size;
        [symbol drawInRect:CGRectMake((size.width - s.width) / 2, (size.height - s.height) / 2, s.width, s.height)];
    }];
}

@end
