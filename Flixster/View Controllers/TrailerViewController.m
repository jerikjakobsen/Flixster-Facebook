//
//  TrailerViewController.m
//  Flixster
//
//  Created by johnjakobsen on 6/25/21.
//

#import "TrailerViewController.h"
#import "AFNetworking/AFNetworking.h"
#import <WebKit/WebKit.h>

@interface TrailerViewController ()
@property (weak, nonatomic) IBOutlet WKWebView *trailerView;
@property (strong, nonatomic) NSString *trailerURL;

@end

@implementation TrailerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self getMovieTrailerURL];
    // Do any additional setup after loading the view.
}

-(void) getMovieTrailerURL {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@/videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed", self.movieID]];
    NSLog([NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@/videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed", self.movieID]);
    NSURLRequest *request = [NSURLRequest requestWithURL: url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: 10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest: request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        } else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData: data options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"%@", dataDictionary);
            self.trailerURL = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=\%@", dataDictionary[@"results"][0][@"key"]];
            NSURL *url = [NSURL URLWithString: self.trailerURL];
            NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
            [self.trailerView loadRequest:request];
        }
    }];
    [task resume];
}



@end
