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
	
	refreshView = [[SKPullRefreshView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 200.0) scrollView:table backgroundColor:[UIColor colorWithRed:0.50 green:0.59 blue:0.78 alpha:1.00]];
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
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[refreshView restore];
	});
}

@end
