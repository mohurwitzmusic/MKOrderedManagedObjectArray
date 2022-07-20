# MKOrderedManagedObjectArrayController

A CoreData utility to manage an ordered collection of NSManagedObject as an array.

Since CoreData does not support ordered collections out of the box, array indices 
must be explicitly modeled as entity attributes. This utility manages the assignment
of the array index. It defines a single protocol, `MKOrderedManagedObject`, which requires adopters
to define a single attribute `arrayIndex` in their entity defintion. 
This utility can then be used to create, delete, and move items in the array 
and the array indices will be updated as needed. The objects can then 
be fetched using a SortDescriptor based on `arrayIndex`. 
