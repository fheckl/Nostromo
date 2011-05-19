//
//  QSNostromoObjectView.m
//  Nostromo
//
//  Created by Rob McBroom on 5/16/11.
//

#import "QSNostromoObjectView.h"


@implementation QSNostromoObjectView

- (void)transmogrifyWithText:(NSString *)string {
	if (![self allowText]) return;
	if ([self currentEditor]) {
		[[self window] makeFirstResponder: self];
	} else {
		NSText *editor = [[self window] fieldEditor:YES forObject: self];
		if (string) {
			[editor setString:string];
			[editor setSelectedRange:NSMakeRange([[editor string] length] , 0)];
		} else if ([partialString length] && ([resetTimer isValid] || ![[NSUserDefaults standardUserDefaults] floatForKey:kResetDelay]) ) {
			[editor setString:[partialString stringByAppendingString:[[NSApp currentEvent] charactersIgnoringModifiers]]];
			[editor setSelectedRange:NSMakeRange([[editor string] length] , 0)];
		} else {
			NSString *stringValue = [[self objectValue] stringValue];
			if (stringValue) [editor setString:stringValue];
			[editor setSelectedRange:NSMakeRange(0, [[editor string] length])];
		}
		NSRect titleFrame = [self frame];
		NSRect editorFrame = NSInsetRect(titleFrame, NSHeight(titleFrame) /16, NSHeight(titleFrame)/16);
		editorFrame.origin = NSMakePoint(NSHeight(titleFrame) /16, NSHeight(titleFrame)/16);
        
		[editor setHorizontallyResizable: YES];
		[editor setVerticallyResizable: YES];
		[editor setDrawsBackground: NO];
		[editor setDelegate: self];
		[editor setMinSize: editorFrame.size];
		[editor setFont:[NSFont fontWithName:@"Helvetica Neue" size:20.0]];
		[editor setTextColor:[NSColor blackColor]];
		[editor setEditable:YES];
		[editor setSelectable:YES];
        
		NSScrollView *scrollView = [[[NSScrollView alloc] initWithFrame:editorFrame] autorelease];
		[scrollView setBorderType:NSNoBorder];
		[scrollView setHasVerticalScroller:NO];
		[scrollView setAutohidesScrollers:YES];
		[scrollView setDrawsBackground:NO];
        
		NSSize contentSize = [scrollView contentSize];
		[editor setMinSize:NSMakeSize(0, contentSize.height)];
		[editor setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
        
		[editor setVerticallyResizable:YES];
		[editor setHorizontallyResizable:YES];
        
		[editor setFieldEditor:YES];
		[scrollView setDocumentView:editor];
		[self addSubview:scrollView];
        
		[[self window] makeFirstResponder:editor];
		[self setCurrentEditor:editor];
	}
}

@end
