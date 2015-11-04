//
//  StringUtil.m

#import "NSString+Utilities.h"
// NOTE: .m文件可以 以下两种方式import framework文件
//#import <RegexKitLite/RegexKitLite.h>
#import "RegexKitLite.h"

// http://www.wilshipley.com/blog/2005/10/pimp-my-code-interlude-free-code.html
static inline BOOL IsEmpty(id thing) {
	return thing == nil ||
	([thing isEqual:[NSNull null]]) ||
	([thing respondsToSelector:@selector(length)] && [(NSData *)thing length] == 0) ||
	([thing respondsToSelector:@selector(count)]  && [(NSArray *)thing count] == 0);
}

@implementation NSString (NSStringUtils)

- (int)wbt_asciiCount
{
    int result = 0;
    
    NSUInteger n = [self length];
    
    for (int i = 0; i < n; i++)
    {
        unichar c = [self characterAtIndex:i];
        
        if (isblank(c) || isascii(c))
        {
            result += 1;
        }
        else
        {
            result += 2;
        }
    }
    
    return result;
}

- (BOOL)matchRegex:(NSString *)regex
{
    __block BOOL match = NO;
    [self enumerateStringsMatchedByRegex:regex usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        for (int i = 0; i < captureCount; i++)
        {
            if ([self isEqualToString:capturedStrings[i]])
            {
                match = YES;
                *stop = YES;
            }
        }
    }];
    return match;
}

- (NSString *)stringWithMaxLength:(NSUInteger)maxLen {
  NSUInteger length = [self length];
  if (length <= maxLen || length <= 3) {
    return self;
  }else {
    return [NSString stringWithFormat:@"%@...", [self substringToIndex:maxLen - 3]];
  }
}


- (NSString *)urlWithoutParameters {
  NSRange r;
  NSString *newUrl;

  r = [self rangeOfString:@"?" options: NSBackwardsSearch];
  if (r.length > 0)
    newUrl = [self substringToIndex: NSMaxRange (r) - 1];
  else
    newUrl = self;

  return newUrl;
}

- (NSString *)stringByReplacingRange:(NSRange)aRange with:(NSString *)aString {
  unsigned int bufferSize;
  unsigned int selfLen = (unsigned int)[self length];
  unsigned int aStringLen = (unsigned int)[aString length];
  unichar *buffer;
  NSRange localRange;
  NSString *result;

  bufferSize = selfLen + aStringLen - (unsigned int)aRange.length;
  buffer = NSAllocateMemoryPages(bufferSize*sizeof(unichar));

  /* Get first part into buffer */
  localRange.location = 0;
  localRange.length = aRange.location;
  [self getCharacters:buffer range:localRange];

  /* Get middle part into buffer */
  localRange.location = 0;
  localRange.length = aStringLen;
  [aString getCharacters:(buffer+aRange.location) range:localRange];

  /* Get last part into buffer */
  localRange.location = aRange.location + aRange.length;
  localRange.length = selfLen - localRange.location;
  [self getCharacters:(buffer+aRange.location+aStringLen) range:localRange];

  /* Build output string */
  result = [NSString stringWithCharacters:buffer length:bufferSize];

  NSDeallocateMemoryPages(buffer, bufferSize);

  return result;
}

- (NSString *)trimmedString
{
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)htmlDecodedString
{
	NSMutableString *temp = [NSMutableString stringWithString:self];
	
	[temp replaceOccurrencesOfString:@"&amp;" withString:@"&" options:0 range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"&gt;" withString:@">" options:0 range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"&lt;" withString:@"<" options:0 range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:0 range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"&apos;" withString:@"'" options:0 range:NSMakeRange(0, [temp length])];
	
	return [NSString stringWithString:temp];
}

- (NSString *)htmlEncodedString
{
	NSMutableString *temp = [NSMutableString stringWithString:self];
	
	[temp replaceOccurrencesOfString:@"&" withString:@"&amp;" options:0 range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@">" withString:@"&gt;" options:0 range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"<" withString:@"&lt;" options:0 range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:0 range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"'" withString:@"&apos;" options:0 range:NSMakeRange(0, [temp length])];
	
	return [NSString stringWithString:temp];
}

/*
 * source: http://stackoverflow.com/questions/1967399/parse-nsurl-path-and-query-iphoneos
 */
- (NSMutableDictionary *)explodeToDictionaryInnerGlue:(NSString *)innerGlue outterGlue:(NSString *)outterGlue {
    // Explode based on outter glue
    NSArray *firstExplode = [self componentsSeparatedByString:outterGlue];
    NSArray *secondExplode;
    
    // Explode based on inner glue
    NSInteger count = [firstExplode count];
    NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithCapacity:count];
    for (NSInteger i = 0; i < count; i++) {
        secondExplode = [(NSString *)[firstExplode objectAtIndex:i] componentsSeparatedByString:innerGlue];
        if ([secondExplode count] == 2) {
            [returnDictionary setObject:[secondExplode objectAtIndex:1] forKey:[secondExplode objectAtIndex:0]];
        }
    }
    
    return returnDictionary;
}

- (NSMutableDictionary *)explodeToDictionaryInnerGlueUTF8Decode:(NSString *)innerGlue outterGlue:(NSString *)outterGlue isCompatibleMode:(BOOL) isCompatibleMode
{
    NSMutableDictionary *srcDictionary = [self explodeToDictionaryInnerGlue:innerGlue outterGlue:outterGlue];
    
    NSEnumerator* keyEnum = [srcDictionary keyEnumerator];
    NSMutableDictionary* returnDictionary = [NSMutableDictionary dictionary];
    id key = nil;
    NSString* src = nil;
    NSString* dec = nil;
    while (key = [keyEnum nextObject])
    {
        src = [srcDictionary objectForKey:key];
        if ([src isKindOfClass:[NSString class]])
        {
            if (isCompatibleMode)
            {
                src = [src stringByReplacingOccurrencesOfString:@"+" withString:@"%20"];
            }
            dec = [src stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if ([dec length] > 0)
            {
                src = dec;
            }
        }
        if (key && [key lowercaseString])
        {
            [returnDictionary setObject:src forKey:[key lowercaseString]];
        }
    }
    
    return returnDictionary;
}

+ (NSString *)firstNonNsNullStringWithString:(NSString*)string, ...
{
    NSString* result = nil;
    
    id arg = nil;
    va_list argList;
    
    if (string && [string isKindOfClass:[NSString class]])
    {
        return string;
    }
    
    va_start(argList, string);
    while ((arg = va_arg(argList, id)))
    {
        if (arg && [arg isKindOfClass:[NSString class]])
        {
            result = arg;
            break;
        }
    }
    va_end(argList);
    
    
    return result;
}

@end


@implementation NSString  (UUID)
+ (NSString*) stringWithUUID {
	CFUUIDRef uuidObj = CFUUIDCreate(nil);
	NSString *UUIDstring = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
	CFRelease(uuidObj);
	return UUIDstring;
}
@end

@implementation NSString  (RangeAvoidance)
- (BOOL) hasSubstring:(NSString*)substring;
{
	if(IsEmpty(substring))
		return NO;
	NSRange substringRange = [self rangeOfString:substring];
	return substringRange.location != NSNotFound && substringRange.length > 0;
}

- (NSString*) substringAfterSubstring:(NSString*)substring;
{
	if([self hasSubstring:substring])
		return [self substringFromIndex:NSMaxRange([self rangeOfString:substring])];
	return nil;
}

//Note: -isCaseInsensitiveLike should work when avalible!
- (BOOL) isEqualToStringIgnoringCase:(NSString*)otherString;
{
	if(!otherString)
		return NO;
	return NSOrderedSame == [self compare:otherString options:NSCaseInsensitiveSearch + NSWidthInsensitiveSearch];
}
@end


@implementation NSString (IndempotentPercentEscapes)
- (NSString*) stringByReplacingPercentEscapesOnce;
{
	NSString *unescaped = [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	//self may be a string that looks like an invalidly escaped string,
	//eg @"100%", in that case it clearly wasn't escaped,
	//so we return it as our unescaped string.
	return unescaped ? unescaped : self;
}
- (NSString*) stringByAddingPercentEscapesOnce;
{
	return [[self stringByReplacingPercentEscapesOnce] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
@end
