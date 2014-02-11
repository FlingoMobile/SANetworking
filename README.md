
SANetworking is renamed version of AFNetworking which is a delightful networking library for iOS and Mac OS X. It's built on top of [NSURLConnection](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSURLConnection_Class/Reference/Reference.html), [NSOperation](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/NSOperation_class/Reference/Reference.html), and other familiar Foundation technologies. It has a modular architecture with well-designed, feature-rich APIs that are a joy to use. For example, here's how easy it is to get JSON from a URL:

```objective-c
NSURL *url = [NSURL URLWithString:@"https://alpha-api.app.net/stream/0/posts/stream/global"];
NSURLRequest *request = [NSURLRequest requestWithURL:url];
SAJSONRequestOperation *operation = [SAJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
    NSLog(@"App.net Global Stream: %@", JSON);
} failure:nil];
[operation start];
```

Perhaps the most important feature of all, however, is the amazing community of developers who use and contribute to AFNetworking every day. AFNetworking powers some of the most popular and critically-acclaimed apps on the iPhone, iPad, and Mac.

Choose AFNetworking for your next project, or migrate over your existing projects—you'll be happy you did!

## How To Get Started

- [Download AFNetworking](https://github.com/AFNetworking/AFNetworking/zipball/master) and try out the included Mac and iPhone example apps
- Read the ["Getting Started" guide](https://github.com/AFNetworking/AFNetworking/wiki/Getting-Started-with-AFNetworking), [FAQ](https://github.com/AFNetworking/AFNetworking/wiki/AFNetworking-FAQ), or [other articles in the wiki](https://github.com/AFNetworking/AFNetworking/wiki)
- Check out the [complete documentation](http://cocoadocs.org/docsets/AFNetworking/) for a comprehensive look at the APIs available in AFNetworking
- Watch the [NSScreencast episode about AFNetworking](http://nsscreencast.com/episodes/6-afnetworking) for a quick introduction to how to use it in your application
- Questions? [Stack Overflow](http://stackoverflow.com/questions/tagged/afnetworking) is the best place to find answers

## License

SANetworking is available under the MIT license. See the LICENSE file for more info.
