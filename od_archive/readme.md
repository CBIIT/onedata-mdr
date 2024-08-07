# OneData Object Archive
This directory serves as a place to store OneData objects, tables, views, etc... that have been deprecated and/or marked for deletion. If the object needs to be restored, the necessary scripts and files to do so should be found here.
## Directory Structure
Each folder should be prefixed with the Jira tracker number assigned to the object to be deleted followed by the name of the object. If multiple objects are to be deleted, then this readme should be updated to include the folder name with its list of objects.
## Standard Steps to Restore Object
1. Connect to the database of your target environment.
2. Execute the .sql script in the appropriate schema. (Tables and materialized views may need to be dropped first.)
3. Login to OneData as Admin.
4. Navigate to Administer >> Metadata >> Import Metadata.
5. Add a Profile. Fill out any necessary fields and load the .xml file. Save.
6. Select the profile and click Import, then Import again.
7. Once the import is complete, find the object and allocate the necessary roles.
## List of Archived Objects
- Classification - AI Hierarchy (Jira 3543)
