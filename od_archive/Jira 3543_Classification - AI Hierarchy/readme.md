# DO: Classification - AI Hierarchy
Exported from Production - 08/07/2024
## Jira 3543 Tracker Description
"Form - Classification View" based on "Classification - AI Hierarchy" was created to search Forms by CS/CSI. Later, users provide feedback that they prefer to browse for Forms by Context/CS/CSI similar to Browse CDEs by Classifications (DSRMWS-1992) in a tree view. A new “Browse Forms by Classifications” CO was implemented and more widely used. Curator team confirmed that no one in their team is using the old "Form - Classification View". Will delete the DO in Sprint 58.
## Steps to Restore Object
1. Connect to the database of your target environment.
2. Execute the .sql script in this folder in the appropriate schema. (Tables and materialized views may need to be dropped first.)
3. Login to OneData as Admin.
4. Navigate to Administer >> Metadata >> Import Metadata.
5. Add a Profile. Fill out any necessary fields and load the .xml file from this folder. Save.
6. Select the profile and click Import, then Import again.
7. Once the import is complete, find the object and allocate the necessary roles.
