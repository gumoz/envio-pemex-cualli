// NSURLRequest.m

#import "NSURLRequest.h"

@implementation NSURLRequest (NSURLRequestWithIgnoreSSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host
{
//	NSLog(@"accept certificate %@", host);	
	printf("Aceptando certificado invalido de pemex\n");
    return YES;
}

@end