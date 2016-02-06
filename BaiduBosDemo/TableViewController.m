//
//  TableViewController.m
//  BaiduBosDemo
//
//  Created by xunyanan on 2/6/16.
//  Copyright © 2016 xunyanan. All rights reserved.
//
#import <AFNetworking.h>
#import "TableViewController.h"
#import "DownLoadTableViewCell.h"
#import "ImageItem.h"
#import "BcsSignatureManager.h"



@interface TableViewController ()
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) DownLoadTableViewCell *uploadCell;
@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor grayColor];
    
    _dataSource = [NSMutableArray array];
    //download file
    ImageItem *item1 = [[ImageItem alloc] init];
    item1.object = @"/test.jpg";
    item1.title = @"download file from BOS";
    
    [_dataSource addObject:item1];
    //upload file
    ImageItem *item2 = [[ImageItem alloc] init];
    item2.object = @"/test.jpg";
    item2.title = @"upload file to BOS";
    [_dataSource addObject:item2];
    
    //use bos image to clipp image
    ImageItem *item3 = [[ImageItem alloc] init];
    item3.object = @"/test.jpg";
    item3.title = @"download clipping image file from BOS";
    item3.clippingParam = @"@w_200";
    [_dataSource addObject:item3];
    
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
 
}
- (void)dealloc{
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)downloadClippingImage:(ImageItem *)item tableCell:(DownLoadTableViewCell *)cell{
    NSString *objectWithParam = [NSString stringWithFormat:@"%@%@",item.object,item.clippingParam];
    NSString *str = [BcsSignatureManager bcsImagteURLWithObject:objectWithParam];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:str];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:BOS_GET];
    
    [BcsSignatureManager signaturedImageHeader:request object:objectWithParam queryString:@""];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:@"test1.jpg"];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
        NSData *data = [[NSData alloc] initWithContentsOfURL:filePath];
        cell.imageView.image = [[UIImage alloc] initWithData:data];
    }];
    [downloadTask resume];
}

- (void)downloadFile:(ImageItem *)item tableCell:(DownLoadTableViewCell *)cell{
    NSString *str = [BcsSignatureManager bcsURLWithObject:item.object];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:str];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:BOS_GET];
    
    [BcsSignatureManager signaturedHeader:request object:item.object queryString:@""];
    
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
        NSData *data = [[NSData alloc] initWithContentsOfURL:filePath];
        cell.imageView.image = [[UIImage alloc] initWithData:data];
    }];
    [downloadTask resume];
}
- (void)uploadFile:(ImageItem *)item tableCell:(DownLoadTableViewCell *)cell{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"];
    
    NSString *str = [BcsSignatureManager bcsURLWithObject:item.object];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:str];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:BOS_PUT];
    NSURL *filePath = [NSURL fileURLWithPath:path];
    NSProgress *progress;
     _uploadCell = cell;
    request = [BcsSignatureManager signaturedHeader:request object:item.object queryString:@""];
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromFile:filePath progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"Success: %@ %@", response, responseObject);
            NSData *data = [[NSData alloc] initWithContentsOfURL:filePath];
            cell.imageView.image = [[UIImage alloc] initWithData:data];
           
        }
    }];
    [uploadTask resume];
    
    // Observe fractionCompleted using KVO
    [progress addObserver:self
               forKeyPath:@"fractionCompleted"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{

    if ([keyPath isEqualToString:@"fractionCompleted"] && [object isKindOfClass:[NSProgress class]]) {
        NSProgress *progress = (NSProgress *)object;
        NSLog(@"Progress is %f", progress.fractionCompleted);
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            _uploadCell.progressView.hidden = NO;
            [_uploadCell.progressView setProgress:progress.fractionCompleted];
        }];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row <=[_dataSource count]) {
        DownLoadTableViewCell *cell = (DownLoadTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        ImageItem *item = [_dataSource objectAtIndex:indexPath.row];
        if (indexPath.row == 0) {
            [self downloadFile:item tableCell:cell];
        }
        if (indexPath.row == 1) {
            [self uploadFile:item tableCell:cell];
        }
        if (indexPath.row == 2) {
            [self downloadClippingImage:item tableCell:cell];
        }

        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0;
}

#pragma mark - table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_dataSource count];

}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    DownLoadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[DownLoadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (indexPath.row <=[_dataSource count]) {
        ImageItem *item = [_dataSource objectAtIndex:indexPath.row];
        cell.lable.text = item.title;
        //cell.backgroundColor =[ UIColor greenColor];
        
    }
    
    return cell;
}

@end
