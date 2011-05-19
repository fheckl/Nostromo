#import "QSNostromoInterfaceController.h"

@implementation QSNostromoInterfaceController
- (id)init {
    return [self initWithWindowNibName:NSStringFromClass([self class])];
}

- (void)windowDidLoad {
    NSString *interfaceFont = @"Helvetica Neue";
    standardRect = centerRectInRect([[self window] frame], [[NSScreen mainScreen] frame]);
    standardIObjectRect = [iSelector frame];
    heightDifference = NSMinY([aSelector frame]) - NSMinY(standardIObjectRect);
    [super windowDidLoad];
    QSWindow *window = (QSWindow *)[self window];
    //[window setLevel:kCGOverlayWindowLevel];
    [window setLevel:NSModalPanelWindowLevel];
    [window setBackgroundColor:[NSColor clearColor]];
    
    [window setHideOffset:NSMakePoint(0, 0)];
    [window setShowOffset:NSMakePoint(0, 0)];
    
    // Effect when showing the interface
    [window setShowEffect:[NSDictionary dictionaryWithObjectsAndKeys:@"QSSlightGrowEffect",@"transformFn",@"show",@"type",[NSNumber numberWithFloat:0.15],@"duration",nil]];
    // Effect when hiding the interface
    [window setHideEffect:[NSDictionary dictionaryWithObjectsAndKeys:@"QSSlightShrinkEffect",@"transformFn",@"hide",@"type",[NSNumber numberWithFloat:0.15],@"duration",nil]];
    // Effect when running a command
    [window setWindowProperty:[NSDictionary dictionaryWithObjectsAndKeys:@"QSExplodeEffect", @"transformFn", @"hide", @"type", [NSNumber numberWithFloat:0.2], @"duration", nil] forKey:kQSWindowExecEffect];
    // Effect when interface fades
    [window setWindowProperty:[NSDictionary dictionaryWithObjectsAndKeys:@"hide", @"type", [NSNumber numberWithFloat:0.15], @"duration", nil] forKey:kQSWindowFadeEffect];
    // Effect when user cancels
    [window setWindowProperty:[NSDictionary dictionaryWithObjectsAndKeys:@"QSVContractEffect", @"transformFn", @"hide", @"type", [NSNumber numberWithFloat:0.333], @"duration", nil, [NSNumber numberWithFloat:0.25] , @"brightnessB", @"QSStandardBrightBlending", @"brightnessFn", nil] forKey:kQSWindowCancelEffect];
    
    [(QSBezelBackgroundView *)[[self window] contentView] setRadius:4.0];
    /* Gloss Types
    QSGlossFlat = 0,            // Flat Highlight.
    QSGlossUpArc = 1,           // Upward Arc.
    QSGlossDownArc = 2,         // Downward Arc.
    QSGlossRisingArc = 3,       // Flat Highlight.
    QSGlossControl = 4,         // Glass Control style. */
    [(QSBezelBackgroundView *)[[self window] contentView] setGlassStyle:QSGlossControl];
    
    [[self window] setFrame:standardRect display:YES];
    
    [[[self window] contentView] bind:@"color" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:@"values.QSAppearance1B" options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName forKey:@"NSValueTransformerName"]];
    [[self window] bind:@"hasShadow" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:@"values.QSBezelHasShadow" options:nil];
    [commandView bind:@"textColor" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:@"values.QSAppearance1T" options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName forKey:@"NSValueTransformerName"]];
    [commandView setFont:[NSFont systemFontOfSize:12.0]];
    
    [[self window] setMovableByWindowBackground:NO];
    
    NSArray *theControls = [NSArray arrayWithObjects:dSelector, aSelector, iSelector, nil];
    for(QSNostromoObjectView *theControl in theControls) {
        [theControl setCell:[QSNostromoCell cellWithText]];
        QSNostromoCell *theCell = [theControl cell];
        [theCell setAlignment:NSLeftTextAlignment];
        [theCell setImagePosition:NSImageLeft];
        [theControl setPreferredEdge:NSMaxXEdge];
        [theControl setResultsPadding:NSMinX([dSelector frame])];
        [theControl setPreferredEdge:NSMinY([dSelector frame])];
        [(QSWindow *)[(theControl)->resultController window] setHideOffset:NSMakePoint(NSMaxX([iSelector frame]), 0)];
        [(QSWindow *)[(theControl)->resultController window] setShowOffset:NSMakePoint(NSMaxX([dSelector frame]), 0)];
        
        [theCell setShowDetails:YES];
        [theCell setTextColor:[NSColor whiteColor]];
        [theCell setFont:[NSFont fontWithName:interfaceFont size:0.0]];
        [theCell setState:NSOnState];
        
        [theCell bind:@"highlightColor" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:@"values.QSAppearance1A" options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName forKey:@"NSValueTransformerName"]];
        [theCell bind:@"textColor" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:@"values.QSAppearance1T" options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName forKey:@"NSValueTransformerName"]];
    }
    
    [self contractWindow:nil];
}

- (void)dealloc {
    if ([self isWindowLoaded]) {
        [[[self window] contentView] unbind:@"color"];
        [[self window] unbind:@"hasShadow"];
        [commandView unbind:@"textColor"];
        NSArray *theControls = [NSArray arrayWithObjects:dSelector, aSelector, iSelector, nil];
        for(NSControl * theControl in theControls) {
            NSCell *theCell = [theControl cell];
            [theCell unbind:@"highlightColor"];
            [theCell unbind:@"textColor"];
            [(QSNostromoCell *)theCell setTextColor:nil];
            [(QSNostromoCell *)theCell setHighlightColor:nil];
        }
    }
    [super dealloc];
}

- (NSSize) maxIconSize {
    return NSMakeSize(512, 512);
}

- (void)showMainWindow:(id)sender {
    [[self window] setFrame:[self rectForState:[self expanded]]  display:YES];
    if ([[self window] isVisible]) [[self window] pulse:self];
    [super showMainWindow:sender];
    [[[self window] contentView] setNeedsDisplay:YES];
}

- (void)expandWindow:(id)sender {
    if (![self expanded]) {
        [[self window] setFrame:[self rectForState:YES] display:YES animate:YES];
    }
    [super expandWindow:sender];
}

- (void)contractWindow:(id)sender {
    if ([self expanded]) {
        [[self window] setFrame:[self rectForState:NO] display:YES animate:YES];
        NSRect iNewRect = standardIObjectRect;
        iNewRect.size.height = iNewRect.size.height - heightDifference;
        [iSelector setFrame:iNewRect];
    }
    [super contractWindow:sender];
}

- (NSRect)window:(NSWindow *)window willPositionSheet:(NSWindow *)sheet usingRect:(NSRect)rect {
    return NSOffsetRect(NSInsetRect(rect, 8, 0), 0, -21);
}

- (NSRect) rectForState:(BOOL)shouldExpand {
    NSRect newRect = standardRect;
    NSRect screenRect = [[NSScreen mainScreen] frame];
    if (!shouldExpand) {
        newRect.size.height -= heightDifference;
        newRect = centerRectInRect(newRect, [[NSScreen mainScreen] frame]);
    }
    return NSOffsetRect(centerRectInRect(newRect, screenRect), 0, NSHeight(screenRect) /8);
}

- (void)searchObjectChanged:(NSNotification*)notif {
    [super searchObjectChanged:notif];
    NSString *commandName = [[self currentCommand] name];
    if (!commandName) commandName = @"";
    [commandView setStringValue:([dSelector objectValue] ? commandName : @"Quicksilver")];
}
@end
