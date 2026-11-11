//
//  DemoKit.h
//  ObjCGallery
//
//  Shared pieces for the demo screens: a scrolling page of titled cards.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// A view controller whose content is a vertical stack of titled cards inside a scroll view.
@interface DemoViewController : UIViewController

@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, strong, readonly) UIStackView *stack;

/// Adds a card with a small uppercase title; returns the card's vertical stack for the content.
- (UIStackView *)addSection:(NSString *)title;
/// Same as addSection: with a footnote under the card.
- (UIStackView *)addSection:(NSString *)title note:(nullable NSString *)note;

@end

/// A horizontal stack that wraps nothing but spaces its items evenly.
UIStackView *DemoRow(NSArray<UIView *> *views);
/// A label with the given text style.
UILabel *DemoLabel(NSString *text, UIFontTextStyle style);
/// A fixed-size colored rounded square.
UIView *DemoTile(UIColor *color, CGFloat size);

NS_ASSUME_NONNULL_END
