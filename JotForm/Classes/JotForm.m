//
//  JotForm.m
//  JotForm
//
//  Created by Wang YuPing on 7/9/13.
//  Copyright (c) 2013 Interlogy, LLC. All rights reserved.
//

#import "JotForm.h"

@implementation JotForm
@synthesize operationQueue;
@synthesize delegate;
@synthesize didFinishSelector;
@synthesize didFailSelector;

- (id) init
{
    if ( self = [super init] ) {
        
        apiKey = @"";
        debugMode = NO;
        baseUrl = BASE_URL;
        apiVersion = API_VERSION;
        operationQueue = [[NSOperationQueue alloc] init];
        [operationQueue setMaxConcurrentOperationCount:1];
        
    }
    
    return self;
}

- (id) initWithApiKey : (NSString *) apikey debugMode : (BOOL) debugmode
{
    if ( self = [super init] ) {
        
        apiKey = apikey;
        debugMode = debugmode;
        baseUrl = BASE_URL;
        apiVersion = API_VERSION;
        operationQueue = [[NSOperationQueue alloc] init];
        [operationQueue setMaxConcurrentOperationCount:1];

    }
    
    return self;
}

- (void) debugLog : (NSString *) str
{
    if ( debugMode == YES )
        NSLog(@"\n%@", str);
}

- (void) executeHttpRequest : (NSString *) path params : (NSMutableDictionary *) params method : (NSString *) method
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@/%@", baseUrl, apiVersion, path];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:
     NSASCIIStringEncoding];
    
    [self debugLog:[NSString stringWithFormat:@"urlstr = %@", urlStr]];
    
    if ( [method isEqualToString:HTTPREQUEST_METHOD_GET] == YES ) {
        
        NSMutableArray *paramarray = [[NSMutableArray alloc] init];
        
        NSArray *keys = [params allKeys];
        
        for ( NSString *key in keys )
            [paramarray addObject:[NSString stringWithFormat:@"%@=%@", key, [params objectForKey:key]]];
        
        NSString *paramstr = [paramarray componentsJoinedByString:@"&"];
        
        [self debugLog:[NSString stringWithFormat:@"paramstr = %@", paramstr]];
        
        urlStr = [NSString stringWithFormat:@"%@?%@", urlStr, paramstr];
        
        [paramarray release];
    }
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request setDelegate:self];

    NSMutableDictionary *userinfo = [[[NSMutableDictionary alloc] init] autorelease];
    [userinfo setObject:NSStringFromSelector(didFinishSelector) forKey:@"didFinishSelector"];
    [userinfo setObject:NSStringFromSelector(didFailSelector) forKey:@"didFailSelector"];
    
    [request setUserInfo:userinfo];
    [request setUserAgentString:USER_AGENT];
    [request addRequestHeader:@"apiKey" value:apiKey];
    [request setRequestMethod:method];
    
    if ( [method isEqualToString:HTTPREQUEST_METHOD_POST] ) {
        
        NSArray *keys = [params allKeys];
        
        for ( NSString *key in keys )
            [request addPostValue:[params objectForKey:key] forKey:key];
    }
    
    [operationQueue addOperation:request];
}

- (void) executeGetRequest : (NSString *) url params : (NSMutableDictionary *) params
{
    return [self executeHttpRequest:url params:params method:HTTPREQUEST_METHOD_GET];   
}

- (void) executePostRequest : (NSString *) url params : (NSMutableDictionary *) params
{
    return [self executeHttpRequest:url params:params method:HTTPREQUEST_METHOD_POST];
}

- (void) executeDeleteRequest : (NSString *) url params : (NSMutableDictionary *) params
{
    return [self executeHttpRequest:url params:params method:HTTPREQUEST_METHOD_DELETE];
}

- (void) executePutRequest : (NSString *) url params : (NSString *) params
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@/%@", baseUrl, apiVersion, url];
    
    [self debugLog:[NSString stringWithFormat:@"urlstr = %@", urlStr]];
    [self debugLog:urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request setDelegate:self];
    [request setRequestMethod:HTTPREQUEST_METHOD_PUT];
    
    NSMutableDictionary *userinfo = [[NSMutableDictionary alloc] init];
    [userinfo setObject:NSStringFromSelector(didFinishSelector) forKey:@"didFinishSelector"];
    [userinfo setObject:NSStringFromSelector(didFailSelector) forKey:@"didFailSelector"];
    
    [request setUserInfo:userinfo];
    [request setUserAgentString:USER_AGENT];
    [request addRequestHeader:@"apiKey" value:apiKey];
    [request appendPostData:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    [operationQueue addOperation:request];
}

- (NSMutableDictionary *) createConditions : (NSInteger) offset limit : (NSInteger) limit filter : (NSMutableDictionary *) filter orderBy : (NSString *) orderBy
{
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    
    if ( offset != 0 )
        [params setObject:[NSNumber numberWithInteger:offset] forKey:@"offset"];
    
    if ( limit != 0 )
        [params setObject:[NSNumber numberWithInteger:limit] forKey:@"limit"];
    
    if ( filter != nil ) {
        
        NSString *filterStr = @"";
        NSInteger count = 0;
        NSArray *keys = [filter allKeys];

        for( NSString *key in keys ) {
            
            filterStr = [filterStr stringByAppendingString:[NSString stringWithFormat:@"%%7b%%22%@%%22:%%22%@%%22%%7d", key, [[filter objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            count++;
            
            if( count < [filter count] ) {
                filterStr = [filterStr stringByAppendingString:@"%2c"];
            }
            
        }
        
        [self debugLog:[NSString stringWithFormat:@"filterStr = %@", filterStr]];
        
        [params setObject:filterStr forKey:@"filter"];
    }
    
    if ( orderBy != nil )
        [params setObject:orderBy forKey:@"orderby"];
    
    return params;
}

- (NSMutableDictionary *) createHistoryQuery : (NSString *) action date : (NSString *) date sortBy : (NSString *) sortBy startDate : (NSString *) startDate endDate : (NSString *) endDate
{
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    
    if ( action != nil && action.length > 0 )
        [params setObject:action forKey:@"action"];
    
    if ( date != nil && date.length > 0 )
        [params setObject:date forKey:@"date"];
    
    if ( sortBy != nil && sortBy.length > 0 )
        [params setObject:sortBy forKey:@"sortBy"];
    
    if ( startDate != nil && sortBy.length > 0 )
        [params setObject:startDate forKey:@"startDate"];
    
    if ( endDate != nil && endDate.length > 0 )
        [params setObject:endDate forKey:@"endDate"];
    
    return params;
}

- (void) getApiKey : (NSString *) username password : (NSString *) password
{
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    
    [params setObject:username forKey:@"username"];
    [params setObject:password forKey:@"password"];
    [params setObject:@"iOS" forKey:@"appName"];
    
    [self executePostRequest:@"login" params:params];
}

- (void) getUser
{
    [self executeGetRequest:@"user" params:nil];
}

- (void) getUsage
{
    [self executeGetRequest:@"user/usage" params:nil];
}

- (void) getForms
{
     [self executeGetRequest:@"user/forms" params:nil];
}

- (void) getForms : (NSInteger) offset limit : (NSInteger) limit orderBy : (NSString *) orderBy filter : (NSMutableDictionary *) filter
{
    NSMutableDictionary *params = [self createConditions:offset limit:limit filter:filter orderBy:orderBy];
    
    [self executeGetRequest:@"user/forms" params:params];
}

- (void) getSubmissions
{
    [self executeGetRequest:@"user/submissions" params:nil];
}

- (void) getSubmissions : (NSInteger) offset limit : (NSInteger) limit orderBy : (NSString *) orderBy filter : (NSMutableDictionary *) filter
{
    NSMutableDictionary *params = [self createConditions:offset limit:limit filter:filter orderBy:orderBy];
    
    [self executeGetRequest:@"user/submissions" params:params];
}

- (void) getSubusers
{
    [self executeGetRequest:@"user/subusers" params:nil];
}

- (void) getFolders
{
    [self executeGetRequest:@"user/folders" params:nil];
}

- (void) getReports
{
    [self executeGetRequest:@"user/reports" params:nil];
}

- (void) getSettings
{
    [self executeGetRequest:@"user/settings" params:nil];
}

- (void) getHistory
{
    [self executeGetRequest:@"user/history" params:nil];
}

- (void) getHistory : (NSString *) action date : (NSString *) date sortBy : (NSString *) sortBy startDate : (NSString *) startDate endDate : (NSString *) endDate
{
    NSMutableDictionary *params = [self createHistoryQuery:action date:date sortBy:sortBy startDate:startDate endDate:endDate];
    
    [self executeGetRequest:@"user/history" params:params];
}

- (void) getForm : (long long) formID
{
    [self executeGetRequest:[NSString stringWithFormat:@"form/%lld", formID] params:nil];
}

- (void) getFormQuestions : (long long) formID
{
    [self executeGetRequest:[NSString stringWithFormat:@"form/%lld/questions", formID] params:nil];
}

- (void) getFormQuestion : (long long) formID questionID : (long long) qid
{
    [self executeGetRequest:[NSString stringWithFormat:@"form/%lld/question/%lld", formID, qid] params:nil];
}

- (void) getFormSubmissions : (long long) formID
{
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    [params setObject:@"true" forKey:@"qid_enabled"];
    
    [self executeGetRequest:[NSString stringWithFormat:@"form/%lld/submissions", formID] params:params];
}

- (void) getFormSubmissions : (long long) formID offset : (NSInteger) offset limit : (NSInteger) limit orderBy : (NSString *) orderBy filter : (NSMutableDictionary *) filter
{
    NSMutableDictionary *params = [self createConditions:offset limit:limit filter:filter orderBy:orderBy];
    
    [self executeGetRequest:[NSString stringWithFormat:@"form/%lld/submissions", formID] params:params];
}

- (void) createFormSubmissions : (long long) formID submission : (NSMutableDictionary *) submission
{
    NSMutableDictionary *parameters = [[[NSMutableDictionary alloc] init] autorelease];
    
    NSArray *keys = [submission allKeys];
    
    NSString *subkey = @"";
    
    for ( NSString *key in keys ) {
        
        if ( [key rangeOfString:@"_"].location != NSNotFound )
            subkey = [NSString stringWithFormat:@"submission[%@][%@]", [key substringToIndex:[key rangeOfString:@"_"].location], [key substringToIndex:([key rangeOfString:@"_"].location + 1)]];
        else
            subkey = [NSString stringWithFormat:@"submission[%@]", key];
        
        if ( [submission objectForKey:key] != nil )
            [parameters setObject:[submission objectForKey:key] forKey:subkey];
        
    }
    
    [self executePostRequest:[NSString stringWithFormat:@"form/%lld/submissions", formID] params:parameters];
}

- (void) getFormFiles : (long long) formID
{
    [self executeGetRequest:[NSString stringWithFormat:@"form/%lld/files", formID] params:nil];
}

- (void) getFormWebhooks : (long long) formID
{
    [self executeGetRequest:[NSString stringWithFormat:@"form/%lld/webhooks", formID] params:nil];
}

- (void) createFormWebhooks : (long long) formID hookUrl : (NSString *) webhookURL
{
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    
    if ( webhookURL != nil && webhookURL.length > 0 )
    [params setObject:webhookURL forKey:@"webhookURL"];
    
    [self executePostRequest:[NSString stringWithFormat:@"form/%lld/webhooks", formID] params:params];
}

- (void) getSubmission : (long long) sid
{
    [self executeGetRequest:[NSString stringWithFormat:@"submission/%lld", sid] params:nil];
}

- (void) getReport : (long long) reportID
{
    [self executeGetRequest:[NSString stringWithFormat:@"report/%lld", reportID] params:nil];
}

- (void) getFormProperties : (long long) formID
{
    [self executeGetRequest:[NSString stringWithFormat:@"form/%lld/properties", formID] params:nil];
}

- (void) getFormProperty : (long long) formID propertyKey : (NSString *) propertyKey
{
    [self executeGetRequest:[NSString stringWithFormat:@"form/%lld/properties/%@", formID, propertyKey] params:nil];
}

- (void) deleteSubmission : (long long) sid
{
    [self executeDeleteRequest:[NSString stringWithFormat:@"submission/%lld", sid] params:nil];
}

- (void) editSubmission : (long long) sid name : (NSString *) submissionName new : (NSInteger) new flag : (NSInteger) flag
{
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    
    if ( submissionName != nil )
        [params setObject:submissionName forKey:@"submission[1][first]"];
    
    
    [params setObject:[NSString stringWithFormat:@"%d", new] forKey:@"submission[new]"];
    [params setObject:[NSString stringWithFormat:@"%d", flag] forKey:@"submission[flag]"];
    
    [self executePostRequest:[NSString stringWithFormat:@"submission/%lld", sid] params:params];
}

- (void) cloneForm : (long long) formID
{
    [self executePostRequest:[NSString stringWithFormat:@"form/%lld/clone", formID] params:nil];
}

- (void) deleteFormQuestion : (long long) formID questionID : (long long) qid
{
    [self executeDeleteRequest:[NSString stringWithFormat:@"form/%lld/question/%lld", formID, qid] params:nil];
}

- (void) createFormQuestion : (long long) formID question : (NSMutableDictionary *) question
{
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    
    NSArray *keys = [question allKeys];
    
    for ( NSString *key in keys )
        [params setObject:[question objectForKey:key] forKey:[NSString stringWithFormat:@"question[%@]", key]];
    
    [self executePostRequest:[NSString stringWithFormat:@"form/%lld/questions", formID] params:params];
}

- (void) createFormQuestions : (long long) formID questions : (NSString *) questions
{
    [self executePutRequest:[NSString stringWithFormat:@"form/%lld/questions", formID] params:questions];
}

- (void) editFormQuestion : (long long) formID questionID : (long long) qid questionProperties : (NSMutableDictionary *) properties
{
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    
    NSArray *keys = [properties allKeys];
    
    for ( NSString *key in keys )
        [params setObject:[properties objectForKey:key] forKey:[NSString stringWithFormat:@"question[%@]", key]];
    
    [self executePostRequest:[NSString stringWithFormat:@"form/%lld/question/%lld", formID, qid] params:params];
}

- (void) setFormProperties : (long long) formID formProperties : (NSMutableDictionary *) properties
{
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    
    NSArray *keys = [properties allKeys];
    
    for ( NSString *key in keys )
        [params setObject:[properties objectForKey:key] forKey:[NSString stringWithFormat:@"properties[%@]", key]];
    
    [self executePostRequest:[NSString stringWithFormat:@"form/%lld/properties", formID] params:params];
}

- (void) setMultipleFormProperties : (long long) formID formProperties : (NSString *) properties
{
    [self executePutRequest:[NSString stringWithFormat:@"form/%lld/properties", formID] params:properties];
}

- (void) createForm : (NSString *) form
{
    [self executePutRequest:@"user/forms" params:form];
}

- (void) deleteForm : (long long) formID
{
    [self executeDeleteRequest:[NSString stringWithFormat:@"form/%lld", formID] params:nil];
}

#pragma mark - ASIHttpRequest Delegate Method

- (void) requestFinished : (ASIHTTPRequest *) request
{
    [self debugLog:[request responseString]];
    
    SEL finishSelector = NSSelectorFromString([request.userInfo objectForKey:@"didFinishSelector"]);
    
    NSInteger statuscode = [request responseStatusCode];
    
    if ( statuscode != 200 ) {
        [self debugLog:[request responseStatusMessage]];
    }
    
    [self debugLog:[request responseString]];
    
    SBJsonParser *jsonparser = [SBJsonParser new];
    
    id result = [jsonparser objectWithString:[request responseString]];

    if ( self.delegate != nil && [self.delegate respondsToSelector:finishSelector] ) {
        [self.delegate performSelector:finishSelector withObject:result];
    }
}

- (void) requestFailed : (ASIHTTPRequest *) request
{
    SEL failSelector = NSSelectorFromString([request.userInfo objectForKey:@"didFailSelector"]);
    
    if ( self.delegate != nil && [self.delegate respondsToSelector:failSelector] ) {
        [self.delegate performSelector:failSelector withObject:[request error]];
    }
}

- (void) dealloc
{
    [operationQueue release];
    
    [super dealloc];
}

@end
