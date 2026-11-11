//
//  SceneDelegate.m
//  ObjCGallery
//

#import "SceneDelegate.h"
#import "GalleryViewController.h"

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:[UIWindowScene class]]) {
        return;
    }
    self.window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    GalleryViewController *gallery = [[GalleryViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:gallery];
    nav.navigationBar.prefersLargeTitles = YES;
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
}

@end
