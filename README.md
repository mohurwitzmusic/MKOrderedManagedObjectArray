# MKOrderedManagedObjectArray

A CoreData utility to manage an ordered collection of NSManagedObject as an array.

Since CoreData does not support ordered collections out of the box, array indices 
must be explicitly modeled as entity attributes. This utility manages the assignment
of the array index. It defines a single protocol, `MKOrderedManagedObject`, which requires adopters
to define a single attribute `arrayIndex` in their entity defintion. 
The `MKOrderedManagedObjectArrayController` can then be used to ineract with the persistent store
to create, delete, and move objects, and will update the array index as needed.
The managed objects can then be fetched in order using a SortDescriptor based on `arrayIndex`. 
