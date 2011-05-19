//
//  QSNostromoCollectingView.h
//  Nostromo
//
//  Created by Rob McBroom on 5/16/11.
//

#import <Cocoa/Cocoa.h>
#import "QSNostromoObjectView.h"

@interface QSNostromoCollectingView : QSNostromoObjectView {
	NSMutableArray *collection;
	BOOL 			collecting;
	NSRectEdge		collectionEdge;
	float			collectionSpace;
}

- (IBAction)emptyCollection:(id)sender;
- (BOOL)objectIsInCollection:(QSObject *)thisObject;

- (NSRectEdge) collectionEdge;
- (void)setCollectionEdge:(NSRectEdge)value;

- (float) collectionSpace;
- (void)setCollectionSpace:(float)value;

@end
