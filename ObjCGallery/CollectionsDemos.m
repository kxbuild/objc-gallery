//
//  CollectionsDemos.m
//  ObjCGallery
//
//  UICollectionView with a compositional layout, UITableView features, alerts and sheets.
//

#import "DemoKit.h"

#pragma mark - Collection view

static NSString *const kBannerSection = @"Featured";
static NSString *const kGridSection = @"Colors";

@interface CollectionViewController : UIViewController <UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewDiffableDataSource<NSString *, NSNumber *> *dataSource;
@property (nonatomic) NSInteger nextItem;
@end

@implementation CollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;

    UICollectionViewCompositionalLayout *layout = [[UICollectionViewCompositionalLayout alloc] initWithSectionProvider:^NSCollectionLayoutSection *(NSInteger index, id<NSCollectionLayoutEnvironment> env) {
        NSCollectionLayoutSection *section;
        if (index == 0) {
            // A horizontally paging row of large cards.
            NSCollectionLayoutItem *item = [NSCollectionLayoutItem itemWithLayoutSize:[NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1] heightDimension:[NSCollectionLayoutDimension fractionalHeightDimension:1]]];
            NSCollectionLayoutGroup *group = [NSCollectionLayoutGroup horizontalGroupWithLayoutSize:[NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:0.85] heightDimension:[NSCollectionLayoutDimension absoluteDimension:170]] subitems:@[item]];
            section = [NSCollectionLayoutSection sectionWithGroup:group];
            section.orthogonalScrollingBehavior = UICollectionLayoutSectionOrthogonalScrollingBehaviorGroupPagingCentered;
            section.interGroupSpacing = 12;
        } else {
            // An adaptive grid: three columns on iPhone, more on wider screens.
            NSInteger columns = MAX(3, (NSInteger)(env.container.effectiveContentSize.width / 120));
            NSCollectionLayoutItem *item = [NSCollectionLayoutItem itemWithLayoutSize:[NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0 / columns] heightDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0 / columns]]];
            item.contentInsets = NSDirectionalEdgeInsetsMake(4, 4, 4, 4);
            NSCollectionLayoutGroup *group = [NSCollectionLayoutGroup horizontalGroupWithLayoutSize:[NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1] heightDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.0 / columns]] subitems:@[item]];
            section = [NSCollectionLayoutSection sectionWithGroup:group];
        }
        section.contentInsets = NSDirectionalEdgeInsetsMake(8, 12, 20, 12);
        NSCollectionLayoutBoundarySupplementaryItem *header = [NSCollectionLayoutBoundarySupplementaryItem boundarySupplementaryItemWithLayoutSize:[NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1] heightDimension:[NSCollectionLayoutDimension estimatedDimension:30]] elementKind:UICollectionElementKindSectionHeader alignment:NSRectAlignmentTop];
        section.boundarySupplementaryItems = @[header];
        return section;
    }];

    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.collectionView];

    UICollectionViewCellRegistration *cellReg = [UICollectionViewCellRegistration registrationWithCellClass:[UICollectionViewCell class] configurationHandler:^(UICollectionViewCell *cell, NSIndexPath *indexPath, NSNumber *item) {
        NSInteger n = item.integerValue;
        UIBackgroundConfiguration *bg = [UIBackgroundConfiguration listPlainCellConfiguration];
        bg.backgroundColor = [UIColor colorWithHue:fmod(n * 0.083, 1.0) saturation:0.55 brightness:0.95 alpha:1];
        bg.cornerRadius = indexPath.section == 0 ? 18 : 10;
        cell.backgroundConfiguration = bg;
        UIListContentConfiguration *content = [UIListContentConfiguration cellConfiguration];
        content.text = indexPath.section == 0 ? [NSString stringWithFormat:@"Featured %ld", (long)n - 999] : [NSString stringWithFormat:@"%ld", (long)n];
        content.textProperties.font = indexPath.section == 0 ? [UIFont systemFontOfSize:26 weight:UIFontWeightBold] : [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
        content.textProperties.color = UIColor.whiteColor;
        content.textProperties.alignment = UIListContentTextAlignmentCenter;
        cell.contentConfiguration = content;
    }];
    UICollectionViewSupplementaryRegistration *headerReg = [UICollectionViewSupplementaryRegistration registrationWithSupplementaryClass:[UICollectionViewListCell class] elementKind:UICollectionElementKindSectionHeader configurationHandler:^(UICollectionViewListCell *view, NSString *kind, NSIndexPath *indexPath) {
        UIListContentConfiguration *content = [UIListContentConfiguration groupedHeaderConfiguration];
        content.text = indexPath.section == 0 ? @"Paging cards (orthogonal scrolling)" : @"Adaptive grid · tap to remove";
        view.contentConfiguration = content;
    }];

    self.dataSource = [[UICollectionViewDiffableDataSource alloc] initWithCollectionView:self.collectionView cellProvider:^UICollectionViewCell *(UICollectionView *cv, NSIndexPath *indexPath, NSNumber *item) {
        return [cv dequeueConfiguredReusableCellWithRegistration:cellReg forIndexPath:indexPath item:item];
    }];
    self.dataSource.supplementaryViewProvider = ^UICollectionReusableView *(UICollectionView *cv, NSString *kind, NSIndexPath *indexPath) {
        return [cv dequeueConfiguredReusableSupplementaryViewWithRegistration:headerReg forIndexPath:indexPath];
    };

    NSDiffableDataSourceSnapshot<NSString *, NSNumber *> *snapshot = [[NSDiffableDataSourceSnapshot alloc] init];
    [snapshot appendSectionsWithIdentifiers:@[kBannerSection, kGridSection]];
    [snapshot appendItemsWithIdentifiers:@[@1000, @1001, @1002, @1003, @1004] intoSectionWithIdentifier:kBannerSection];
    NSMutableArray *grid = [NSMutableArray array];
    for (NSInteger i = 1; i <= 24; i++) { [grid addObject:@(i)]; }
    self.nextItem = 25;
    [snapshot appendItemsWithIdentifiers:grid intoSectionWithIdentifier:kGridSection];
    [self.dataSource applySnapshot:snapshot animatingDifferences:NO];

    __weak typeof(self) weakSelf = self;
    self.navigationItem.rightBarButtonItems = @[
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd primaryAction:[UIAction actionWithHandler:^(UIAction *a) { [weakSelf addItem]; }]],
        [[UIBarButtonItem alloc] initWithPrimaryAction:[UIAction actionWithTitle:@"Shuffle" image:[UIImage systemImageNamed:@"shuffle"] identifier:nil handler:^(UIAction *a) { [weakSelf shuffle]; }]],
    ];

    self.collectionView.delegate = self;
}

- (void)addItem {
    NSDiffableDataSourceSnapshot *snapshot = self.dataSource.snapshot;
    [snapshot appendItemsWithIdentifiers:@[@(self.nextItem++)] intoSectionWithIdentifier:kGridSection];
    [self.dataSource applySnapshot:snapshot animatingDifferences:YES];
}

- (void)shuffle {
    NSDiffableDataSourceSnapshot *snapshot = self.dataSource.snapshot;
    NSMutableArray *items = [[snapshot itemIdentifiersInSectionWithIdentifier:kGridSection] mutableCopy];
    for (NSUInteger i = items.count; i > 1; i--) { [items exchangeObjectAtIndex:i - 1 withObjectAtIndex:arc4random_uniform((uint32_t)i)]; }
    [snapshot deleteItemsWithIdentifiers:items];
    [snapshot appendItemsWithIdentifiers:items intoSectionWithIdentifier:kGridSection];
    [self.dataSource applySnapshot:snapshot animatingDifferences:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 1) { return; }
    NSNumber *item = [self.dataSource itemIdentifierForIndexPath:indexPath];
    NSDiffableDataSourceSnapshot *snapshot = self.dataSource.snapshot;
    [snapshot deleteItemsWithIdentifiers:@[item]];
    [self.dataSource applySnapshot:snapshot animatingDifferences:YES];
}

@end

#pragma mark - Table view features

@interface TableFeaturesViewController : UITableViewController
@property (nonatomic, strong) NSMutableArray<NSString *> *items;
@property (nonatomic, strong) NSMutableSet<NSString *> *flagged;
@end

@implementation TableFeaturesViewController

- (instancetype)init {
    return [super initWithStyle:UITableViewStyleInsetGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.items = [@[@"Weekly report", @"Team lunch", @"Flight tickets", @"Dentist", @"Birthday gift", @"Car service", @"Gym class", @"Book club"] mutableCopy];
    self.flagged = [NSMutableSet set];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"Swipe left or right, long-press for a context menu, or tap Edit to reorder.";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"row"] ?: [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"row"];
    NSString *item = self.items[indexPath.row];
    UIListContentConfiguration *content = [UIListContentConfiguration valueCellConfiguration];
    content.text = item;
    BOOL flagged = [self.flagged containsObject:item];
    content.image = [UIImage systemImageNamed:flagged ? @"flag.fill" : @"circle"];
    content.imageProperties.tintColor = flagged ? UIColor.systemOrangeColor : UIColor.tertiaryLabelColor;
    cell.contentConfiguration = content;
    cell.showsReorderControl = YES;
    return cell;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *item = self.items[indexPath.row];
    BOOL flagged = [self.flagged containsObject:item];
    UIContextualAction *flag = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:flagged ? @"Unflag" : @"Flag" handler:^(UIContextualAction *a, UIView *v, void (^done)(BOOL)) {
        flagged ? [self.flagged removeObject:item] : [self.flagged addObject:item];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        done(YES);
    }];
    flag.backgroundColor = UIColor.systemOrangeColor;
    flag.image = [UIImage systemImageNamed:@"flag"];
    return [UISwipeActionsConfiguration configurationWithActions:@[flag]];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIContextualAction *delete = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction *a, UIView *v, void (^done)(BOOL)) {
        [self.items removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        done(YES);
    }];
    delete.image = [UIImage systemImageNamed:@"trash"];
    UIContextualAction *archive = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Archive" handler:^(UIContextualAction *a, UIView *v, void (^done)(BOOL)) { done(YES); }];
    archive.backgroundColor = UIColor.systemIndigoColor;
    archive.image = [UIImage systemImageNamed:@"archivebox"];
    return [UISwipeActionsConfiguration configurationWithActions:@[delete, archive]];
}

- (UIContextMenuConfiguration *)tableView:(UITableView *)tableView contextMenuConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point {
    NSString *item = self.items[indexPath.row];
    return [UIContextMenuConfiguration configurationWithIdentifier:nil previewProvider:nil actionProvider:^UIMenu *(NSArray<UIMenuElement *> *suggested) {
        UIAction *copy = [UIAction actionWithTitle:@"Copy" image:[UIImage systemImageNamed:@"doc.on.doc"] identifier:nil handler:^(UIAction *a) { UIPasteboard.generalPasteboard.string = item; }];
        UIAction *share = [UIAction actionWithTitle:@"Share" image:[UIImage systemImageNamed:@"square.and.arrow.up"] identifier:nil handler:^(UIAction *a) {
            UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:@[item] applicationActivities:nil];
            activity.popoverPresentationController.sourceView = [tableView cellForRowAtIndexPath:indexPath];
            [self presentViewController:activity animated:YES completion:nil];
        }];
        return [UIMenu menuWithTitle:item children:@[copy, share]];
    }];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)from toIndexPath:(NSIndexPath *)to {
    NSString *item = self.items[from.row];
    [self.items removeObjectAtIndex:from.row];
    [self.items insertObject:item atIndex:to.row];
}

@end

#pragma mark - Alerts and sheets

@interface AlertsViewController : DemoViewController
@property (nonatomic, strong) UILabel *result;
@end

@implementation AlertsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIStackView *status = [self addSection:@"Last action"];
    self.result = DemoLabel(@"—", UIFontTextStyleBody);
    [status addArrangedSubview:self.result];

    __weak typeof(self) weakSelf = self;
    UIStackView *alerts = [self addSection:@"UIAlertController"];
    [alerts addArrangedSubview:[self button:@"Alert" handler:^{
        UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Saved" message:@"Your changes were saved." preferredStyle:UIAlertControllerStyleAlert];
        [a addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *x) { weakSelf.result.text = @"OK"; }]];
        [weakSelf presentViewController:a animated:YES completion:nil];
    }]];
    [alerts addArrangedSubview:[self button:@"Alert with a text field" handler:^{
        UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Rename" message:@"Enter a new name." preferredStyle:UIAlertControllerStyleAlert];
        [a addTextFieldWithConfigurationHandler:^(UITextField *field) { field.placeholder = @"Name"; }];
        [a addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        __weak typeof(a) weakAlert = a;
        [a addAction:[UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *x) {
            weakSelf.result.text = [@"Renamed to " stringByAppendingString:weakAlert.textFields.firstObject.text ?: @""];
        }]];
        [weakSelf presentViewController:a animated:YES completion:nil];
    }]];
    [alerts addArrangedSubview:[self button:@"Action sheet" handler:^{
        UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Delete this photo?" message:@"This cannot be undone." preferredStyle:UIAlertControllerStyleActionSheet];
        [a addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *x) { weakSelf.result.text = @"Deleted"; }]];
        [a addAction:[UIAlertAction actionWithTitle:@"Move to album" style:UIAlertActionStyleDefault handler:^(UIAlertAction *x) { weakSelf.result.text = @"Moved"; }]];
        [a addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        a.popoverPresentationController.sourceView = weakSelf.view;
        [weakSelf presentViewController:a animated:YES completion:nil];
    }]];

    UIStackView *sheets = [self addSection:@"Sheets" note:@"UISheetPresentationController with medium and large detents, and the share sheet."];
    [sheets addArrangedSubview:[self button:@"Sheet with detents" handler:^{
        UIViewController *content = [[UIViewController alloc] init];
        content.view.backgroundColor = UIColor.systemBackgroundColor;
        UILabel *label = DemoLabel(@"Drag me between medium and large.", UIFontTextStyleHeadline);
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [content.view addSubview:label];
        [label.centerXAnchor constraintEqualToAnchor:content.view.centerXAnchor].active = YES;
        [label.topAnchor constraintEqualToAnchor:content.view.topAnchor constant:40].active = YES;
        UISheetPresentationController *sheet = content.sheetPresentationController;
        sheet.detents = @[UISheetPresentationControllerDetent.mediumDetent, UISheetPresentationControllerDetent.largeDetent];
        sheet.prefersGrabberVisible = YES;
        sheet.preferredCornerRadius = 24;
        [weakSelf presentViewController:content animated:YES completion:nil];
    }]];
    [sheets addArrangedSubview:[self button:@"Share sheet" handler:^{
        UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:@[@"UIKit Gallery", [NSURL URLWithString:@"https://github.com/kxbuild/objc-gallery"]] applicationActivities:nil];
        activity.popoverPresentationController.sourceView = weakSelf.view;
        activity.completionWithItemsHandler = ^(UIActivityType type, BOOL completed, NSArray *items, NSError *error) {
            weakSelf.result.text = completed ? [NSString stringWithFormat:@"Shared via %@", type] : @"Share cancelled";
        };
        [weakSelf presentViewController:activity animated:YES completion:nil];
    }]];
}

- (UIButton *)button:(NSString *)title handler:(void (^)(void))handler {
    UIButtonConfiguration *config = [UIButtonConfiguration tintedButtonConfiguration];
    config.title = title;
    UIButton *button = [UIButton buttonWithConfiguration:config primaryAction:[UIAction actionWithHandler:^(UIAction *a) { handler(); }]];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeading;
    return button;
}

@end
