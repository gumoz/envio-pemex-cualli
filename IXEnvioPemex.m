//
//  IXEnvioPemex.m
//  EnvioPemex
//
//  Created by Gustavo Moya Ortiz on 17/10/08.
//  Copyright 2008 Ixaya. All rights reserved.
//

#import "IXEnvioPemex.h"
#import "NSURLRequest.h"


@implementation IXEnvioPemex

// URL Pruebas
//https://convol.ref.pemex.com/php/sccvp001_02.php

// URL Real
//https://convol.ref.pemex.com/php/sccvg001_02.php

// Nuevo URL
//https://convol.ref.pemex.com/php/sccvg001_03.php

- (id) init
{
	self = [super init];
	if (self != nil) {
	}
	return self;
}


@synthesize archivos;
@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
}

-(IBAction)enviar:(id)sender{
	user = [userField stringValue];
	password =  [passwordField stringValue];
	[self enviarArchivos:self.archivos];	
	NSLog(@"%@", archivos);
}

-(NSError *)enviarArchivos:(NSArray *)arc{
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@:%@@convol.ref.pemex.com/php/sccvg002_02.php", user, password]];		

    NSLog(@"\n\nurl: %@\n\n", url);

	//creamos un diccionario donde pondremos toda la información para enviarla
	NSMutableDictionary* postDict = [[NSMutableDictionary alloc] init];
	
	// ponemos la clave en el archivo
	[postDict setObject:password forKey:@"clave"];
	

	// agregamos cada archivo a un diccionario que se encargara de enviarlos posteriormente
	for(NSString *archivo in arc)
	{
		NSURL *archivoURL = [NSURL fileURLWithPath:archivo];
		NSString *checksum = [self checksumForFile:archivo];
		NSString *fileKey = [self formKeyForFile:archivo];
		NSString *checksumKey = [fileKey stringByAppendingString:@"_checksum"];
		[postDict setObject:archivoURL forKey:fileKey];
		[postDict setObject:checksum forKey:checksumKey];
		NSLog(@"Archivo: %@, Checksum: %@", archivoURL, checksum);
	}
	
	// generamos los datos para el envio
	NSData* regData = [self generateFormData:postDict];
	[postDict release];
	
	// creamos un request y esperamos de forma syncrona una respuesta
	NSMutableURLRequest* post = [NSMutableURLRequest requestWithURL: url];
	[post addValue: @"multipart/form-data; boundary=_______lx4y4_______ixaya________lx4y4_______ixaya________" forHTTPHeaderField: @"Content-Type"];
	[post setHTTPMethod: @"POST"];
	[post setHTTPBody:regData];
	NSHTTPURLResponse* response;
	NSError* error;
	NSLog(@"enviando....");
	NSData* result = [NSURLConnection sendSynchronousRequest:post returningResponse:&response error:&error];
	NSLog(@"enviado....");

	[[webview mainFrame] loadRequest:post];
	[resultadoWindow makeKeyAndOrderFront:self];
	if(error)
		err = YES;
	
	
	
	NSLog(@"Error: %d", err);
	
	// obtenemos la cabezera de la respuesta para evitar que se quede esperando el ciclo
	dictionaryResponse = [response allHeaderFields];
	[self showResult:result];
	return error;
}
-(IBAction)verResultado:(id)sender{
  [resultadoWindow makeKeyAndOrderFront:self];
}
-(IBAction)clear:(id)sender{
	self.archivos = [NSArray new];
}
-(void)showResult:(NSData *)result{
	  
	  
	  // create a string from data
	  NSString *resultString = [[NSString alloc] initWithData:result encoding:NSASCIIStringEncoding];
	  
	  // declare NSString filename and alloc string value
	  NSString *filenameStr = @"pemex-result.html";
	  
	  // NSObject which contains all the error information
	  NSError *error;
	  
	  // write contents and check went ok
	  if(![resultString writeToFile: filenameStr atomically: YES encoding:NSUTF8StringEncoding error:&error]) {
		  NSLog(@"Error: %@\r\n",[error localizedFailureReason]);
	  }	
	  NSLog(@"Resultado: \n\n %@", resultString);
	  
	  //	[resul
	  [webview setMainFrameURL:filenameStr];
//    [[webview mainFrame] loadRequest:
	
	  [resultadoWindow makeKeyAndOrderFront:self];
}
-(NSString *)checksumForFile:(NSString *)archivo{
	NSData *archivoData = [[NSData alloc] initWithContentsOfFile:archivo];
    
    //Usamos perform selector para eliminar un Warning
	NSString *checksum = [archivoData performSelector:@selector(sha1HexHash)];
	return checksum;
}
- (NSData*)generateFormData:(NSDictionary*)dict
{
	NSString* boundary = [NSString stringWithString:@"_______lx4y4_______ixaya________lx4y4_______ixaya________"];
	NSArray* keys = [dict allKeys];
	NSMutableData* result = [[NSMutableData alloc] initWithCapacity:100];
	int i;
	
	for (i = 0; i < [keys count]; i++) 
	{
		id value = [dict valueForKey: [keys objectAtIndex: i]];
		[result appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSASCIIStringEncoding]];
        NSLog(@"value: %@, class: %@", value, [value className]);
		if ([value class] == [NSString class] || [[value className] isEqualToString:@"NSCFString"] || [[value className] isEqualToString:@"NSString"]|| [[value className] isEqualToString:@"__NSCFString"])
		{
			[result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", [keys objectAtIndex:i]] dataUsingEncoding:NSASCIIStringEncoding]];
			[result appendData:[[NSString stringWithFormat:@"%@",value] dataUsingEncoding:NSASCIIStringEncoding]];
		}
		else if (([value class] == [NSURL class] && [value isFileURL]) || [[value className] isEqualToString:@"NSConcreteData"])
		{
			[result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", [keys objectAtIndex:i], [[value path] lastPathComponent]] dataUsingEncoding:NSASCIIStringEncoding]];
			[result appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSASCIIStringEncoding]];
			[result appendData:[NSData dataWithContentsOfFile:[value path]]];
		}
		[result appendData:[[NSString stringWithString:@"\r\n"] dataUsingEncoding:NSASCIIStringEncoding]];
	}
	[result appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSASCIIStringEncoding]];
	
        // NSObject which contains all the error information
    NSError *error;
    
        // write contents and check went ok
    if(![[[NSString alloc] initWithBytes:[result bytes] length:[result length] encoding:NSASCIIStringEncoding] writeToFile: @"post.txt" atomically: YES encoding:NSUTF8StringEncoding error:&error]) {
        NSLog(@"Error: %@\r\n",[error localizedFailureReason]);
    }	
	return [result autorelease];
}

- (NSString *)formKeyForFile:(NSString *)file
{		
	NSString *kind = [self keyForFile:file];
	NSString *key = nil;	
	if([kind isEqualToString:@"ADI"])
		key = @"alarmadispensario";
	else if([kind isEqualToString:@"ATQ"])
		key = @"alarmatanque";
	else if([kind isEqualToString:@"DIS"])
		key = @"catdisp";
	else if([kind isEqualToString:@"EXI"])
		key = @"existencias";
	else if([kind isEqualToString:@"REC"])
		key = @"recibo";
	else if([kind isEqualToString:@"TQS"])
		key = @"cattanque";
	else if([kind isEqualToString:@"VTA"])
		key = @"ventas";
	
	return key;
}
- (NSString *)keyForFile:(NSString *)file
{
	int length = [file length];
	int kindpos = length - 22;
	NSString *kind = [file substringWithRange:NSMakeRange(kindpos, 3)];
	return kind;
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{	
		dictionaryResponse = [response allHeaderFields];
		NSLog(@"response %@", dictionaryResponse);
			NSLog(@"%@",[connection description]);
}
-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	NSLog(@"challenge");
	NSURLCredential *credential = [[NSURLCredential alloc] initWithUser:user password:password persistence:NSURLCredentialPersistenceForSession];	
	[[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename{
	
	NSMutableArray *temp = [NSArray arrayWithArray:self.archivos];
	[temp addObject:filename];
	self.archivos = [NSArray arrayWithArray:temp];
	NSLog(@"archivos: %@", self.archivos);
	return TRUE;
}
- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames{

	NSMutableArray *temp = [NSMutableArray arrayWithArray:self.archivos];
	[temp addObjectsFromArray:filenames];
	self.archivos = [NSArray arrayWithArray:temp];
	NSLog(@"archivos: %@", self.archivos);

}
@end
