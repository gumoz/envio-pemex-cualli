@interface NSData (CryptoHashing)

- (NSData *)md5Hash;
- (NSString *)md5HexHash;

- (NSData *)sha1Hash;
- (NSString *)sha1HexHash;

- (NSData *)sha256Hash;
- (NSString *)sha256HexHash;

- (NSData *)sha512Hash;
- (NSString *)sha512HexHash;

@end