jotform-api-ios 
===============
[JotForm API](http://api.jotform.com/docs/) - iOS 


### Installation

Download the zipped project from downloads page or clone the git repository to your computer.

      $ git clone git://github.com/jotform/jotform-api-ios.git
      $ cd jotform-api-ios

Please open the project and select target "JotForm-Universal" and build it and select "Products/libJotForm.a" and click mouse-right button and click "Show in Finder"
Please look all the files in "Release-iphoneuniversal" directory and copy all the files and add them to you project.
All libraries that we use are as following:

      * ASIHTTPRequest
      * SBJson

If you have build conflicts with any of the libraries above, you have the choice of either removing the the particular library from ExternalLib/XXX.m and .h, or you can remove the conflicting files from your app.


### Documentation

You can find the docs for the API of this client at [http://api.jotform.com/docs/](http://api.jotform.com/docs)

### Examples

Print all forms of the user

    #import <JotForm/JotForm.h>

    JotForm *jotform;

    jotform = [[JotForm alloc] initWithApiKey:"Your API KEY" debugMode:NO];
    jotform.delegate = self;

    [jotform setDidFinishSelector:@selector(getFormsFinish:)];
    [jotform setDidFailSelector:@selector(getFormsFail:)];
    [jotform getForms];

    // get successfully forms
    - (void) getFormsFinish : (id) result
    {
        NSLog(@"response = %@", result);
    }

    // there was an error getting forms
    - (void) getFormsFail : (id) error
    {
        NSLog(@"response = %@", result);
    }


Get latest 100 submissions ordered by creation date

    #import <JotForm/JotForm.h>

    JotForm *jotform;

    jotform = [[JotForm alloc] initWithApiKey:"Your API KEY" debugMode:NO];
    jotform.delegate = self;

    [jotform setDidFinishSelector:@selector(getSubmissionsFinish:)];
    [jotform setDidFailSelector:@selector(getSubmissionsFail:)];
    [jotform getSubmissions:0 limit:100 orderBy:@"created_at" filter:nil];

    // get successfully submissions
    - (void) getSubmissionsFinish : (id) result
    {
        NSLog(@"response = %@", result);
    }

    // there was an error getting submissions
    - (void) getSubmissionsFail : (id) error
    {
        NSLog(@"response = %@", result);
    }

Submission filter examples

    #import <JotForm/JotForm.h>

    JotForm *jotform;

    jotform = [[JotForm alloc] initWithApiKey:"Your API KEY" debugMode:NO];
    jotform.delegate = self;


    NSMutableDictionary *submissionFilter = [[NSMutableDictionary alloc] init];
    [submissionFilter setObject:@"2013-08-06 21:10:08" forKey:@"created_at:gt"];
    
    [jotform setDidFinishSelector:@selector(getSubmissionsFinish:)];
    [jotform setDidFailSelector:@selector(getSubmissionsFail:)];
    [jotform getSubmissions:0 limit:0 orderBy:nil filter:submissionFilter];

    // get successfully submissions
    - (void) getSubmissionsFinish : (id) result
    {
        NSLog(@"response = %@", result);
    }

    // there was an error getting submissions
    - (void) getSubmissionsFail : (id) error
    {
        NSLog(@"response = %@", result);
    }

Delete submission

    #import <JotForm/JotForm.h>

    JotForm *jotform;

    jotform = [[JotForm alloc] initWithApiKey:"Your API KEY" debugMode:NO];
    jotform.delegate = self;

    [jotform setDidFinishSelector:@selector(deleteSubmissionFinish:)];
    [jotform setDidFailSelector:@selector(deleteSubmissionFail:)];
    [jotform deleteSubmission:32243555745860];

    // deleted successfully submission
    - (void) deleteSubmissionFinish : (id) result
    {
        NSLog(@"response = %@", result);
    }

    // there was an error deleting submission
    - (void) deleteSubmissionFail : (id) error
    {
        NSLog(@"response = %@", result);
    }