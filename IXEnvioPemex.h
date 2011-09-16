//
//  IXEnvioPemex.h
//  EnvioPemex
//
//  Created by Gustavo Moya Ortiz on 17/10/08.
//  Copyright 2008 Ixaya. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface IXEnvioPemex : NSObject {
	bool sent;
	bool err;
	IBOutlet NSTextField *userField;
	IBOutlet NSTextField *passwordField;
	NSString *user;
	NSString *password;

	NSArray *archivos;
	
	NSDictionary *dictionaryResponse;
	IBOutlet NSArrayController *arrayController;
	IBOutlet NSWindow *resultadoWindow;
	IBOutlet WebView *webview;
	
    NSWindow *window;
}
@property (assign, readwrite) NSArray* archivos;
@property (assign) IBOutlet NSWindow *window;
-(IBAction)clear:(id)sender;
-(IBAction)enviar:(id)sender;
-(IBAction)verResultado:(id)sender;
-(void)showResult:(NSData *)result;
- (NSError *)enviarArchivos:(NSArray *)archivos;
- (NSString *)formKeyForFile:(NSString *)file;
- (NSString *)keyForFile:(NSString *)file;
- (NSData*)generateFormData:(NSDictionary*)dict;
-(NSString *)checksumForFile:(NSString *)archivo;
@end
