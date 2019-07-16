//
//  LoginInfo.h
//  CaseByMe
//
//  Created by coanyaa on 2015. 12. 29..
//  Copyright © 2015년 Joy2x. All rights reserved.
//

@import Foundation;
#import "MCPModelBase.h"

@interface MCPLoginInfo : MCPModelBase

@property (strong, nonatomic) NSString *userIdx;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *profileImageUrl;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *accessPage;
@end
