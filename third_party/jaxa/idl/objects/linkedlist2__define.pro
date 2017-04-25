;+
; NAME:
;   LINKEDLIST2
;
; FILENAME:
;   linkedlist2__define.pro
;
; PURPOSE:
;   The purpose of this program is to implement a list that
;   is linked in both the forward and backward directions. There
;   is no restriction as to what can be stored in a linked list
;   node. The linked list is implemented as an object.
;
; AUTHOR:
;   FANNING SOFTWARE CONSULTING
;   David Fanning, Ph.D.
;   2642 Bradbury Court
;   Fort Collins, CO 80521 USA
;   Phone: 970-221-0438
;   E-mail: davidf@dfanning.com
;   Coyote's Guide to IDL Programming: http://www.dfanning.com/
;
;   Modified, May 2000, Tolbert (Raytheon) & Zarro (SM&A) - added some
;   error checks
;   Modified, 4 July 2000, Zarro (EIT/GSFC) -- added needed
;    PTR_FREE call in DELETE_NODES to prevent memory leak
;   Modified, March 12 2001, Bilodeau, (Raytheon) - fixed bug in
;    ADD_AFTER where nodes to be added at number of nodes-1 were not
;    added to the end of the list.  Removed redundant call to ptr_exist
;     in HELP method.
;   Modified, Sept 20, 2001,  Zarro (EIT/GSFC) -- added /no_copy and /replace
;   Modified, 7-Dec-2002, Zarro (EER/GSFC) -- use free_var when deleting
;     items
;   Modified, 10-Jan-2003, Zarro (EER/GSFC) -- switch to use heap_free 
;     when deleting items
;
; CATEGORY:
;   General programming. Objects
;
; CALLING SEQUENCE:
;   mylist = Obj_New('LINKEDLIST2', item)
;
; OPTIONAL INPUTS:
;   item: The first item added to the list. Items can be any
;     valid IDL variable type.
;
; COMMON BLOCKS:
;   Are you kidding?!
;
; RESTRICTIONS:
;   Be sure to destroy the LINKEDLIST2 object when you are finished
;   with it: Obj_Destroy, mylist
;
;   Node index numbers start at 0 and go to n-1, where n is the
;   number of items in the list.
;
; PUBLIC METHODS:
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; PRO LINKEDLIST2::ADD, item, index, AFTER=after, BEFORE=before
;
;   The ADD method adds a data item to the list.
;
;   Parameters:
;
;   item: The data item to be added to the list. Required.
;
;   index: The location in the list where the data item is
;     to be added. If neither the AFTER or BEFORE keyword is
;     set, the item is added AFTER the item at the index location.
;     If index is missing, the index points to the last item in
;     the list. Optional.
;
;   Keywords:
;
;   AFTER: If this keyword is set, the item is added after the
;     item at the current index.
;
;   BEFORE: If this keyword is set, the item is added before the
;     item at the current index.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; PRO LINKEDLIST2::DELETE, index, ALL=all
;
;   The DELETE method deletes an item from the list.
;
;   Parameters:
;
;   index: The location in the list where the data item is
;     to be delete. If index is missing, the index points to
;     the last item in the list. Optional.
;
;   Keywords:
;
;   ALL: If this keyword is set, all items in the list are deleted.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; FUNCTION LINKEDLIST2::GET_COUNT
;
;   The GET_COUNT method returns the number of items in the list.
;
;   Return Value: The number of items stored in the linked list.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; FUNCTION LINKEDLIST2::GET_ITEM, index
;
;   The GET_ITEM method returns a pointer to the specified data
;   item from the list.
;
;   Parameters:
;
;   index: The location in the list from which the data item is
;     to be retrieved. If not present, the last item in the list
;     is retrieved. Optional.
;
;   Return Value: A pointer to the specified data item stored
;     in the list.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; FUNCTION LINKEDLIST2::GET_NODE, index
;
;   The GET_NODE method returns a pointer to the specified node
;   from the list.
;
;   Parameters:
;
;   index: The location in the list from which the data node is
;     to be retrieved. If not present, the last node in the list
;     is retrieved. The node is a structure with three fields:
;     Previous is a pointer to the previous node in the list.
;     Next is a pointer to the next node in the list. A null pointer
;     in the previous field indicates the first node on the list. A
;     null pointer in the next field indicates the last node on the
;     list. The item field is a pointer to the item stored in the
;     node. Optional.
;
;   Return Value: A pointer to the specified node structure in
;     the linked list.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; PRO LINKEDLIST2::HELP, PRINT=print
;
; The HELP method performs a HELP command on each item
; in the linked list.
;
;   Keywords:
;
;    PRINT: If this keyword is set, the PRINT command is used
;      instead of the HELP command on the items in the list.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; PRO LINKEDLIST2::MOVE_NODE, nodeIndex, location, BEFORE=before
;
;   The MOVE_NODE method moves a list node from one location to another.
;
;   Parameters:
;
;   nodeIndex: The location in the list of the node you are moving.
;     Required.
;
;   location: The location (index) you are moving the node to. If
;     location is missing, the location points to the node at the
;     end of the list.
;
;   Keywords:
;
;    BEFORE: If this keyword is set, the node is added to the
;      list before the location node. Otherwise, it is added after
;      the location node.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; EXAMPLE:
;
;   mylist = Obj_New("LINKEDLIST2", 5)
;   mylist->Add, 10
;   mylist->Add, 7.5, 1, /Before
;   mylist->Add, 12.5
;   mylist->Help
;   mylist->Delete
;   mylist->Help, /Print
;
; MODIFICATION HISTORY:
;   Written by: David Fanning, 25 August 98.
;   08-Nov-2011, Kim Tolbert. Renamed to linkedlist2 from linkedlist to avoid conflict with
;     linkedlist in coyote library. 
;-


PRO LINKEDLIST2::MOVE_NODE, nodeIndex, location, Before=before,err=err

err=''

; This method moves the requested node to a new location.
; The node is added AFTER the target location, unless the BEFORE
; keyword is used.

Catch, error
IF error NE 0 THEN BEGIN
   RETURN ; Silently
ENDIF

   ; A node index is required.

IF N_Elements(nodeIndex) EQ 0 THEN BEGIN
   err='A node index is required in MOVE_NODE method.'
   message,err,/cont
   RETURN
ENDIF

   ; If location is not specified the node is moved to the
   ; end of the list.

IF N_Elements(location) EQ 0 THEN BEGIN
   location = (self->Get_Count()) - 1
ENDIF

   ; Add the node to the list.



currentNode = self->Get_Node(nodeIndex)

if not ptr_exist(currentNode) then return

IF Keyword_Set(before) THEN BEGIN
   self->Add, *(*currentNode).item, location, /Before
ENDIF ELSE BEGIN
   self->Add, *(*currentNode).item, location, /After
ENDELSE

   ; Delete the node from its current location.

self->Delete, nodeIndex

END
;------------------------------------------------------------------------



PRO LINKEDLIST2::DELETE_NODE, index,err=err

err=''

; This method deletes the indicated node from the list.

IF self.count EQ 0 THEN BEGIN
   err='No nodes to delete.'
   message,err,/cont
   RETURN
ENDIF

IF index GT (self.count - 1) THEN BEGIN
   err='No node with the requested index number.'
   message,err,/cont
   RETURN
ENDIF

   ; Get the current node and free the item pointer.

currentNode = self->Get_Node(index)

if not ptr_exist(currentNode) then return

if ptr_valid((*currentNode).item) then heap_free, (*currentNode).item

   ; Is this the last node?

;IF index EQ (self.count - 1) THEN self->Delete_Last_Node

IF index EQ (self.count - 1) THEN begin
 self->Delete_Last_Node
 return
ENDIF

    ; Is this the first node in the list?

IF NOT Ptr_Valid((*currentNode).previous) THEN BEGIN
    nextNode = (*currentNode).next
    if ptr_valid((*nextNode).previous) then Ptr_Free, (*nextNode).previous
    (*nextNode).previous = Ptr_New()
    self.head = nextNode
ENDIF ELSE BEGIN
    previousNode = (*currentNode).previous
    nextNode = (*currentNode).next
    (*nextNode).previous = previousNode
    (*previousNode).next = nextNode
ENDELSE

   ; Release the currentNode pointer.

if ptr_valid(currentNode) then Ptr_Free, currentNode
self.count = self.count - 1
END
;------------------------------------------------------------------------



PRO LINKEDLIST2::DELETE_LAST_NODE

; This method deletes the last node in the list.

IF self.count EQ 0 THEN RETURN

currentNode = self.tail

if not ptr_exist(currentNode) then return

if ptr_valid((*currentNode).item) then heap_free, (*currentNode).item

    ; Is this the last node in the list?

IF NOT Ptr_Valid((*currentNode).previous) THEN BEGIN
    self.head = Ptr_New()
    self.tail = Ptr_New()
    self.count = 0
    if ptr_valid((*currentNode).next) then Ptr_Free, (*currentNode).next
ENDIF ELSE BEGIN
    previousNode = (*currentNode).previous
    self.tail = previousNode
    if ptr_valid((*self.tail).next) then Ptr_Free, (*self.tail).next
    (*self.tail).next = Ptr_New()
    self.count = self.count - 1
ENDELSE

   ; Release the currentNode pointer.

if ptr_valid(currentNode) then  Ptr_Free, currentNode
END
;------------------------------------------------------------------------



PRO LINKEDLIST2::DELETE_NODES

; This method deletes all of the nodes.

WHILE Ptr_exist(self.head) DO BEGIN
     currentNode = *self.head
     if ptr_valid(currentNode.previous) then Ptr_Free, currentNode.previous
     if ptr_valid(currentNode.item) then heap_free, currentNode.item
     ptr_free,self.head        ;-- added DMZ (4 July '00)
     self.head = currentNode.next
ENDWHILE


    ; Update the count.

self.count = 0

END
;------------------------------------------------------------------------



PRO LINKEDLIST2::DELETE, index, All=all

; This method is the public interface to the private DELETE_+ methods.
; If INDEX is not specified, the last item on the list is always deleted.
; The ALL keyword will delete all the items on the list.

   ; Delete all the nodes?

IF Keyword_Set(all) THEN BEGIN
   self->Delete_Nodes
   RETURN
ENDIF

   ; Check for index. If there is none, delete last node on list.

IF N_Elements(index) EQ 0 THEN BEGIN
   self->Delete_Last_Node
   RETURN
ENDIF

   ; Delete specified node.

self->Delete_Node, index

END
;------------------------------------------------------------------------



PRO LINKEDLIST2::ADD_AFTER, item, index, no_copy=no_copy,err=err

err=''

; This method adds an item node AFTER the item specified by
; the index number.

   ; Be sure there is an item to add.

IF N_Elements(item) EQ 0 THEN BEGIN
   err='Must pass an ITEM to add to the list.'
   message,err,/cont
   RETURN
ENDIF

   ; If no index is specified, add the item to the end of the list.

IF N_Elements(index) EQ 0 THEN BEGIN
   self->Add_To_End, item, no_copy=no_copy,err=err
   RETURN
ENDIF

; PB 03/12/01 - If index is equal to the number of nodes minus one, we
; must add the node to the end of the list, since we are adding a node
; after the end
   ; If index is equal to the number of nodes, add the item to
   ; the end of the list.

IF index GE self.count-1L THEN BEGIN
   self->Add_To_End, item,no_copy=no_copy,err=err
   RETURN
ENDIF

   ; Create a new node and store the item in it.

currentNode = Ptr_New( {LINKEDLIST2_NODE} )


(*currentNode).item = Ptr_New(item,no_copy=no_copy)
self.count = self.count + 1

   ; Get the node currently located at the index.

indexNode = self->Get_Node(index)

   ; Get the node that follows the indexNode.

nextNode = (*indexNode).next

   ; Update pointers.

(*indexNode).next = currentNode
(*currentNode).previous = indexNode
(*nextNode).previous = currentNode
(*currentNode).next = nextNode

END
;------------------------------------------------------------------------


PRO LINKEDLIST2::ADD_BEFORE, item, index,no_copy=no_copy,err=err

err=''

; This method adds an item node BEFORE the item specified by
; the index number.

   ; Be sure there is an item to add.

IF N_Elements(item) EQ 0 THEN BEGIN
   err='Must pass an ITEM to add to the list.'
   message,err,/cont
   RETURN
ENDIF

   ; If no index is specified or the index is 0,
   ; add the item to the head of the list.

IF N_Elements(index) EQ 0 THEN index = 0

   ; Create a new node and store the item in it.

currentNode = Ptr_New( {LINKEDLIST2_NODE} )

(*currentNode).item = Ptr_New(item,no_copy=no_copy)
self.count = self.count + 1

   ; Get the node currently located at the index.

indexNode = self->Get_Node(index)

   ; Get the node that is before the indexNode.

previousNode = (*indexNode).previous

   ; Update pointers.

(*indexNode).previous = currentNode
(*currentNode).previous = previousNode
(*currentNode).next = indexNode
IF Ptr_Valid(previousNode) THEN $
   (*previousNode).next = currentNode ELSE $
   self.head = currentNode

END
;------------------------------------------------------------------------



PRO LINKEDLIST2::ADD_TO_END, item,no_copy=no_copy,err=err

err=''

; This method adds an item to the tail of the list.

   ; Be sure you have an item to add.

IF N_Elements(item) EQ 0 THEN BEGIN
   err='Must pass an ITEM to add to the list.'
   message,err,/cont
   RETURN
ENDIF

IF self.count EQ 0 THEN BEGIN

        ; Create a new node.
    currentNode = Ptr_New({ LINKEDLIST2_NODE })


        ; Add the item to the node.
    (*currentNode).item = Ptr_New(item,no_copy=no_copy)

        ; The head and tail point to current node.
    self.head = currentNode
    self.tail = currentNode

        ; Update the node count.
    self.count = self.count + 1

ENDIF ELSE BEGIN

        ; Create a new node.
    currentNode = Ptr_New({ LINKEDLIST2_NODE })


        ; Set the next field of the previous node.
    (*self.tail).next = currentNode

        ; Add the item to the current node.
    (*currentNode).item = Ptr_New(item,no_copy=no_copy)

        ; Set the previous field to point to previous node.
    (*currentNode).previous = self.tail

        ; Update the tail field to point to current node.
    self.tail = currentNode

        ; Update the node count.
    self.count = self.count + 1
ENDELSE
END
;------------------------------------------------------------------------



PRO LINKEDLIST2::ADD, item, index, Before=before, After=after, $
                     replace=replace,no_copy=no_copy,err=err

err=''

; This method is the public interface to the private ADD_+ methods.
; If INDEX is not specified, the item is always added to the end
; of the list. If INDEX is specified, but neither the BEFORE or
; AFTER keywords are used, the item is added AFTER the INDEX specified.

   ; Must supply an item to add to the list.

IF N_Elements(item) EQ 0 THEN BEGIN
   err='Must supply an item to add to the list.'
   message,err,/cont
   RETURN
END

   ; Check for index. If there is none, add to end of list.

IF N_Elements(index) EQ 0 THEN BEGIN
   self->Add_To_End, item,no_copy=no_copy,err=err
   RETURN
ENDIF

;-- check if replacing

if keyword_set(replace) then begin
 ptr=self->get_item(index,err=err)
 if not ptr_valid(ptr) then return
 if keyword_set(no_copy) then *ptr=temporary(item) else *ptr=item
 return
endif

   ; Are keywords set?

before = Keyword_Set(before)
after = Keyword_Set(after)

   ; No BEFORE or AFTER keywords. Add to location AFTER index.

IF (before + after) EQ 0 THEN BEGIN
   self->Add_After, item, index,no_copy=no_copy,err=err
   RETURN
ENDIF

   ; BEFORE keyword set.

IF before THEN BEGIN
   self->Add_Before, item, index,no_copy=no_copy,err=err
   RETURN
ENDIF

   ; AFTER keyword set.

IF after THEN BEGIN
   self->Add_After, item, index,no_copy=no_copy,err=err
   RETURN
ENDIF

END

;------------------------------------------------------------------------

function linkedlist2::get_value,index,no_copy=no_copy,err=err

err=''
item=self->get_item(index,err=err)
if err ne '' then return,-1
if ptr_exist(item) then begin
 if keyword_set(no_copy) then return,temporary(*item) else return,*item
endif else begin
 err='Empty pointer value'
 message,err,/cont
 return,-1
endelse

end

;------------------------------------------------------------------------

function linkedlist2::have_item,index,err=err

err=''
item=self->get_item(index,err=err)
if err ne '' then return,0b
if not ptr_exist(item) then begin
 err='Empty pointer value'
 message,err,/cont
 return,0b
endif

return,1b

end

;------------------------------------------------------------------------

FUNCTION LINKEDLIST2::GET_ITEM, index,err=err

err=''

; This method returns a pointer to the information
; stored in the list. Ask for the item by number or
; order in the list (list numbers start at 0).

   ; Gets last item by default.

;IF n_elements(index) EQ 0 THEN index = self.count - 1
 IF n_elements(index) EQ 0 THEN index = 0

    ; Make sure there are items in the list.

IF self.count EQ 0 THEN BEGIN
   err='Nothing is currently stored in the list.'
   message,err,/cont
   RETURN, Ptr_New()
ENDIF

IF index GT (self.count - 1) OR index LT 0 THEN BEGIN
   err='Requested node is not in list.'
   message,err,/cont
   RETURN, Ptr_New()
ENDIF

    ; Start at the head of the list.

currentNode = self.head

    ; Find the item asked for by traversing the list.

if not ptr_exist(currentNode) then return,Ptr_New()

FOR j=0, index-1 DO currentNode = (*currentNode).next

    ; Return the pointer to the item.

RETURN, (*currentNode).item

END
;------------------------------------------------------------------------



FUNCTION LINKEDLIST2::GET_NODE, index,err=err

err=''
; This method returns a pointer to the asked-for node.
; Ask for the node by number or order in the list
; (node numbers start at 0).

   ; Gets last node by default.

;IF n_elements(index) eq 0 THEN index = self.count - 1
 IF n_elements(index) eq 0 THEN index = 0

    ; Make sure there are items in the list.

IF self.count EQ 0 THEN BEGIN
   err='Nothing is currently stored in the list.'
   message,err,/cont
   RETURN, Ptr_New()
ENDIF

IF index GT (self.count - 1) OR index LT 0 THEN BEGIN
   err='Requested node is not in list.'
   message,err,/cont
   RETURN, Ptr_New()
ENDIF

    ; Start at the head of the list.

currentNode = self.head

    ; Find the item asked for by traversing the list.


if not ptr_exist(currentNode) then return,Ptr_New()

FOR j=0, index-1 DO currentNode = (*currentNode).next

    ; Return the pointer to the node.

RETURN, currentNode
END
;------------------------------------------------------------------------


FUNCTION LINKEDLIST2::GET_COUNT

; This method returns the number of items in the list.

RETURN, self.count
END
;------------------------------------------------------------------------



PRO LINKEDLIST2::HELP, Print=print,err=err

err=''

; This method performs a HELP command on the items
; in the linked list. If the PRINT keyword is set, the
; data items are printed instead.

   ; Are there nodes to work with?

IF NOT Ptr_Valid(self.head) THEN BEGIN
    err='No nodes in Linked List.'
    message,err,/cont
    RETURN
ENDIF

    ; First node.


; Removed call to ptr_exist - will always fail since currentNode is a
; structure.  If currentNode is supposed to be a pointer, this call is
; redundant for error checking

if not ptr_exist(self.head) then return
currentNode = *self.head

IF Keyword_Set(print) THEN Print, *currentNode.item ELSE $
    Help, *currentNode.item

    ; The rest of the nodes. End of list indicated by null pointer.

WHILE currentNode.next NE Ptr_New() DO BEGIN
    nextNode = *currentNode.next
    IF Keyword_Set(print) THEN Print, *nextNode.item ELSE $
        Help, *nextNode.item
    currentNode = nextNode
ENDWHILE

END
;------------------------------------------------------------------------



PRO LINKEDLIST2::CLEANUP

; This method deletes all of the nodes and cleans up
; the objects pointers.

dprint,'% LINKEDLIST2::CLEANUP'

self->Delete_Nodes
if ptr_valid(self.head) then Ptr_Free, self.head
if ptr_valid(self.tail) then Ptr_Free, self.tail
END

;------------------------------------------------------------------------



FUNCTION LINKEDLIST2::INIT, item,no_copy=no_copy

; Initialize the linked list. Add an item if required.

IF n_elements(item) eq 0 THEN RETURN, 1
self->Add, item,no_copy=no_copy

RETURN, 1
END
;------------------------------------------------------------------------



PRO LINKEDLIST2__DEFINE

; The implementation of a LINKEDLIST2 object.

   struct = { LINKEDLIST2, $         ; The LINKEDLIST2 object.
              head:Ptr_New(), $     ; A pointer to the first node.
              tail:Ptr_New(), $     ; A pointer to the last node.
              count:0L $            ; The number of nodes in the list.
              }

   struct = { LINKEDLIST2_NODE, $    ; The LINKEDLIST2 NODE structure.
              previous:Ptr_New(), $ ; A pointer to the previous node.
              item:Ptr_New(), $     ; A pointer to the data item.
              next:Ptr_New()  $     ; A pointer to the next node.
              }

END
;------------------------------------------------------------------------

