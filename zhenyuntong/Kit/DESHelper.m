//
//  DESHelper.m
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/10.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

#import "DESHelper.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation DESHelper
    
+(NSString *) encryptUseDES:(NSString *)plainText
    {
        NSString *ciphertext = nil;
        NSData *textData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
        NSUInteger dataLength = [textData length];
        unsigned char buffer[dataLength*10];
        memset(buffer, 0, sizeof(char));
        size_t numBytesEncrypted = 0;
        CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                              kCCOptionPKCS7Padding | kCCOptionECBMode,
                                              [@"lechong_951357" UTF8String], kCCKeySizeDES,
                                              nil,
                                              [textData bytes], dataLength,
                                              buffer, dataLength*10,
                                              &numBytesEncrypted);
        if (cryptStatus == kCCSuccess) {
            NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
            
            NSLog(@"data lenght:%ld",data.length);
            ciphertext = [self hexStringFromData:data];
        }
        return ciphertext;
    }
    
+ (NSString *)hexStringFromData:(NSData *)data
    {
        NSMutableString *str = [NSMutableString string];
        Byte *byte = (Byte *)[data bytes];
        for (int i = 0; i<[data length]; i++) {
            // byte+i为指针
            [str appendString:[self stringFromByte:*(byte+i)]];
        }
        return str;  
    }
    
+ (NSString *)stringFromByte:(Byte)byteVal
    {
        NSMutableString *str = [NSMutableString string];
        
        //取高四位
        Byte byte1 = byteVal>>4;
        //取低四位
        Byte byte2 = byteVal & 0xf;
        //拼接16进制字符串
        [str appendFormat:@"%x",byte1];
        [str appendFormat:@"%x",byte2];
        return str;  
    }
    
+(NSString *)UrlEncodedString:(NSString *)sourceText{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)sourceText ,NULL ,CFSTR("!*'();:@&=+$,/?%#[]") ,kCFStringEncodingUTF8));
    return result;
}

@end
