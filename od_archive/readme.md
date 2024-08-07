# OneData Object Archive
This directory serves as a place to store OneData objects, tables, views, etc... that have been deprecated and/or marked for deletion. If the object needs to be restored, the necessary scripts and files to do so should be found here.
## Directory Structure
Each folder should be prefixed with the Jira tracker number assigned to the object to be deleted followed by the name of the object. If multiple objects are to be deleted, then this readme should be updated to include the folder name with its list of objects.
## Steps to Restore Object
1. Download the files from the object's folder.
2. Connect to the database of your target environment.
3. Execute the .sql script in the appropriate schema. (Tables and materialized views may need to be dropped first.)
4. Login to OneData as Admin.
5. Navigate to Administer >> Metadata >> Import Metadata.
6. Add a Profile. Fill out any necessary fields and load the .xml file. Save.
7. Select the profile and click Import, then Import again.
8. Once the import is complete, find the object and allocate the necessary roles.
## List of Archived Objects
- Classification - AI Hierarchy (Jira 3543)
