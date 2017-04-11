//
//  DESHelper.h
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/10.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DESHelper : NSObject
    
+(NSString *) encryptUseDES:(NSString *)plainText;
+(NSString *)UrlEncodedString:(NSString *)sourceText;
    
@end
