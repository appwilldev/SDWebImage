/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+WebCache.h"

@implementation UIImageView (WebCache)

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self setImageWithURL:url placeholderImage:placeholder options:0];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];

    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];

    self.image = placeholder;

    if (url)
    {
        [manager downloadWithURL:url delegate:self options:options];
    }
}

#if NS_BLOCKS_AVAILABLE
- (void)setImageWithURL:(NSURL *)url success:(void (^)(UIImage *image))success failure:(void (^)(NSError *error))failure;
{
    [self setImageWithURL:url placeholderImage:nil success:success failure:failure];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder success:(void (^)(UIImage *image))success failure:(void (^)(NSError *error))failure;
{
    [self setImageWithURL:url placeholderImage:placeholder options:0 success:success failure:failure];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options success:(void (^)(UIImage *image))success failure:(void (^)(NSError *error))failure;
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];

    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];

    self.image = placeholder;

    if (url)
    {
        [manager downloadWithURL:url delegate:self options:options success:success failure:failure];
    }
}
#endif

- (void)cancelCurrentImageLoad
{
    [self hideActivity];

    [[SDWebImageManager sharedManager] cancelForDelegate:self];
}

- (void)webImageManager:(SDWebImageManager *)imageManager didProgressWithPartialImage:(UIImage *)image forURL:(NSURL *)url
{
    [self hideActivity];

    self.image = image;
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    [self hideActivity];

    self.image = image;
}

#pragma mark - Add UIActivityIndicatorView
#define kActivityViewTag 55404
- (void)showActivityWithStyle:(UIActivityIndicatorViewStyle)style
{
    [self hideActivity];

    UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    aiView.tag = kActivityViewTag;
    aiView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    aiView.hidesWhenStopped = YES;
    aiView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [aiView startAnimating];
    [self addSubview:aiView];
    SDWIRelease(aiView);
}

- (void)hideActivity
{
    UIActivityIndicatorView *aiView = (UIActivityIndicatorView *)[self viewWithTag:kActivityViewTag];
    if (aiView && [aiView isKindOfClass:[UIActivityIndicatorView class]]) {
        [aiView removeFromSuperview];
    }
}

- (void)setImageWithURL:(NSURL *)url style:(UIActivityIndicatorViewStyle)style
{
    [self setImageWithURL:url placeholderImage:nil style:style];
}

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholder
                  style:(UIActivityIndicatorViewStyle)style
{
    if (style != NSNotFound) {
        [self showActivityWithStyle:style];
    } else {
        [self hideActivity];
    }

    [self setImageWithURL:url placeholderImage:placeholder];
}

- (void)setImageWithURL:(NSURL *)url
                  style:(UIActivityIndicatorViewStyle)style
                success:(void (^)(UIImage *))success
                failure:(void (^)(NSError *))failure
{
    if (style != NSNotFound) {
        [self showActivityWithStyle:style];
    } else {
        [self hideActivity];
    }

    [self setImageWithURL:url success:success failure:failure];
}

@end
