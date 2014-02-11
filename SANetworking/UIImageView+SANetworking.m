// UIImageView+SANetworking.m
//
// Copyright (c) 2011 Gowalla (http://gowalla.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
#import "UIImageView+SANetworking.h"

@interface SAImageCache : NSCache
- (UIImage *)cachedImageForRequest:(NSURLRequest *)request;
- (void)cacheImage:(UIImage *)image
        forRequest:(NSURLRequest *)request;
@end

#pragma mark -

static char kSAImageRequestOperationObjectKey;

@interface UIImageView (_SANetworking)
@property (readwrite, nonatomic, strong, setter = sa_setImageRequestOperation:) SAImageRequestOperation *sa_imageRequestOperation;
@end

@implementation UIImageView (_SANetworking)
@dynamic sa_imageRequestOperation;
@end

#pragma mark -

@implementation UIImageView (SANetworking)

- (SAHTTPRequestOperation *)sa_imageRequestOperation {
    return (SAHTTPRequestOperation *)objc_getAssociatedObject(self, &kSAImageRequestOperationObjectKey);
}

- (void)sa_setImageRequestOperation:(SAImageRequestOperation *)imageRequestOperation {
    objc_setAssociatedObject(self, &kSAImageRequestOperationObjectKey, imageRequestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSOperationQueue *)sa_sharedImageRequestOperationQueue {
    static NSOperationQueue *_sa_imageRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sa_imageRequestOperationQueue = [[NSOperationQueue alloc] init];
        [_sa_imageRequestOperationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    });

    return _sa_imageRequestOperationQueue;
}

+ (SAImageCache *)sa_sharedImageCache {
    static SAImageCache *_sa_imageCache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sa_imageCache = [[SAImageCache alloc] init];
    });

    return _sa_imageCache;
}

#pragma mark -

- (void)setImageWithURL:(NSURL *)url {
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];

    [self setImageWithURLRequest:request placeholderImage:placeholderImage success:nil failure:nil];
}

- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(UIImage *)placeholderImage
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    [self cancelImageRequestOperation];

    UIImage *cachedImage = [[[self class] sa_sharedImageCache] cachedImageForRequest:urlRequest];
    if (cachedImage) {
        self.sa_imageRequestOperation = nil;

        if (success) {
            success(nil, nil, cachedImage);
        } else {
            self.image = cachedImage;
        }
    } else {
        if (placeholderImage) {
            self.image = placeholderImage;
        }

        SAImageRequestOperation *requestOperation = [[SAImageRequestOperation alloc] initWithRequest:urlRequest];
		
#ifdef _SANETWORKING_ALLOW_INVALID_SSL_CERTIFICATES_
		requestOperation.allowsInvalidSSLCertificate = YES;
#endif
		
        [requestOperation setCompletionBlockWithSuccess:^(SAHTTPRequestOperation *operation, id responseObject) {
            if ([urlRequest isEqual:[self.sa_imageRequestOperation request]]) {
                if (self.sa_imageRequestOperation == operation) {
                    self.sa_imageRequestOperation = nil;
                }

                if (success) {
                    success(operation.request, operation.response, responseObject);
                } else if (responseObject) {
                    self.image = responseObject;
                }
            }

            [[[self class] sa_sharedImageCache] cacheImage:responseObject forRequest:urlRequest];
        } failure:^(SAHTTPRequestOperation *operation, NSError *error) {
            if ([urlRequest isEqual:[self.sa_imageRequestOperation request]]) {
                if (self.sa_imageRequestOperation == operation) {
                    self.sa_imageRequestOperation = nil;
                }

                if (failure) {
                    failure(operation.request, operation.response, error);
                }
            }
        }];

        self.sa_imageRequestOperation = requestOperation;

        [[[self class] sa_sharedImageRequestOperationQueue] addOperation:self.sa_imageRequestOperation];
    }
}

- (void)cancelImageRequestOperation {
    [self.sa_imageRequestOperation cancel];
    self.sa_imageRequestOperation = nil;
}

@end

#pragma mark -

static inline NSString * SAImageCacheKeyFromURLRequest(NSURLRequest *request) {
    return [[request URL] absoluteString];
}

@implementation SAImageCache

- (UIImage *)cachedImageForRequest:(NSURLRequest *)request {
    switch ([request cachePolicy]) {
        case NSURLRequestReloadIgnoringCacheData:
        case NSURLRequestReloadIgnoringLocalAndRemoteCacheData:
            return nil;
        default:
            break;
    }

	return [self objectForKey:SAImageCacheKeyFromURLRequest(request)];
}

- (void)cacheImage:(UIImage *)image
        forRequest:(NSURLRequest *)request
{
    if (image && request) {
        [self setObject:image forKey:SAImageCacheKeyFromURLRequest(request)];
    }
}

@end

#endif
