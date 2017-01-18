#ifdef __OBJC__
#import <UIKit/UIKit.h>
#endif

#import "FEMAssignmentPolicy.h"
#import "FEMRelationshipAssignmentContext+Internal.h"
#import "FEMRelationshipAssignmentContext.h"
#import "FEMManagedObjectCache.h"
#import "FEMDeserializer.h"
#import "FEMManagedObjectDeserializer.h"
#import "FEMObjectDeserializer.h"
#import "FEMAttribute.h"
#import "FEMManagedObjectMapping.h"
#import "FEMMapping.h"
#import "FEMObjectMapping.h"
#import "FEMProperty.h"
#import "FEMRelationship.h"
#import "FEMSerializer.h"
#import "FEMManagedObjectStore.h"
#import "FEMObjectStore.h"
#import "FastEasyMapping.h"
#import "FEMMappingUtility.h"
#import "FEMRepresentationUtility.h"
#import "FEMTypeIntrospection.h"

FOUNDATION_EXPORT double FastEasyMappingVersionNumber;
FOUNDATION_EXPORT const unsigned char FastEasyMappingVersionString[];

