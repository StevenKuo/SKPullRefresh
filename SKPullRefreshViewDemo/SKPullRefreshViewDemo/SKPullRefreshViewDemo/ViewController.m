//
//  ViewController.m
//  SKPullRefreshViewDemo
//
//  Created by steven on 2015/4/17.
//  Copyright (c) 2015年 KKBOX. All rights reserved.
//

#import "ViewController.h"
#import "SKPullRefreshView.h"

@interface ViewController ()
{
	SKPullRefreshView *refreshView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 100.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 100.0) style:UITableViewStylePlain];
	table.backgroundColor = [UIColor clearColor];
	table.delegate = self;
	table.dataSource = self;
	
	refreshView = [[SKPullRefreshView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 200.0) scrollView:table];
	refreshView.delegate = self;
	[self.view addSubview:refreshView];
	[self.view addSubview:table];
	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 10.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *identifier = @"testCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	}
	cell.backgroundColor = [UIColor redColor];
	return cell;
}

- (void)dragAnimatioinFinish
{
	NSURLSession *taskSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue currentQueue]];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://boiling-fjord-8215.herokuapp.com/testDelay"]];
	[request setHTTPMethod:@"POST"];
	NSData *time = [@"2" dataUsingEncoding:NSUTF8StringEncoding];
	[request setHTTPBody:time];
	NSURLSessionDataTask *task = [taskSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		[refreshView restore];
	}];
	[task resume];
}

@end
