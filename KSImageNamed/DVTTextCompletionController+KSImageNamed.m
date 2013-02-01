//
//  DVTTextCompletionController+KSImageNamed.m
//  KSImageNamed
//
//  Created by Kent Sutherland on 1/22/13.
//
//

#import "DVTTextCompletionController+KSImageNamed.h"
#import "KSImageNamedIndexCompletionItem.h"
#import "MethodSwizzle.h"

#import "KSImageNamed.h"

@implementation DVTTextCompletionController (KSImageNamed)

+ (void)load
{
    MethodSwizzle(self, @selector(acceptCurrentCompletion), @selector(swizzle_acceptCurrentCompletion));
}

- (BOOL)swizzle_acceptCurrentCompletion
{
    BOOL success = [self swizzle_acceptCurrentCompletion];
    
    if (success) {
        @try {
            NSRange range = [[self textView] realSelectedRange];
            for (NSString *complitition in [[KSImageNamed sharedPlugin] compplititionStrings]) {
                //If an autocomplete causes imageNamed: to get inserted, remove the token and immediately pop up autocomplete
                if (range.location > [complitition length]) {
                    NSString *insertedString = [[[self textView] string] substringWithRange:NSMakeRange(range.location - [complitition length], [complitition length])];
                    
                    if ([insertedString isEqualToString:complitition]) {
                        [[self textView] _replaceCellWithCellText:@""];
                        [self _showCompletionsAtCursorLocationExplicitly:YES];
                    }
                }
            }
        } @catch (NSException *exception) {
            //I'd rather not crash if Xcode chokes on something
        }
    }
    
    return success;
}

@end
