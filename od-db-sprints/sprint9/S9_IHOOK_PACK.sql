CREATE OR REPLACE PACKAGE ONEDATA_WA.ihook
AS
   FUNCTION getcolumn (ROW IN t_row, columnname IN VARCHAR2)
      RETURN t_column;
   FUNCTION getcolumnvalue (ROW IN t_row, columnname IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION getcolumnoldvalue (ROW IN t_row, columnname IN VARCHAR2)
      RETURN VARCHAR2;
   PROCEDURE setcolumnvalue (
      ROW           IN OUT   t_row,
      columnname    IN       VARCHAR2,
      columnvalue   IN       VARCHAR2
   );
   PROCEDURE setcolumnvalue (
      ROW           IN OUT   t_row,
      columnname    IN       VARCHAR2,
      columnvalue   IN       BLOB
   );
   PROCEDURE setcolumnvalue (
      ROW           IN OUT   t_row,
      columnname    IN       VARCHAR2,
      columnvalue   IN       CLOB
   );
   FUNCTION gethookinput (DATA IN CLOB)
      RETURN t_hookinput;
   FUNCTION gethookoutput (hookoutput IN t_hookoutput)
      RETURN CLOB;
   FUNCTION getmscolumnvalue (ROW IN t_row, columnname IN VARCHAR2)
      RETURN t_ms_values;
   FUNCTION getmscolumnoldvalue (ROW IN t_row, columnname IN VARCHAR2)
      RETURN t_ms_values;
   PROCEDURE setmscolumnvalue (
      ROW             IN OUT   t_row,
      columnname      IN       VARCHAR2,
      mscolumnvalue   IN       t_ms_values
   );
   PROCEDURE setmscolumnoldvalue (
      ROW             IN OUT   t_row,
      columnname      IN       VARCHAR2,
      mscolumnvalue   IN       t_ms_values
   );
END;
/
CREATE OR REPLACE PACKAGE BODY ONEDATA_WA.ihook
AS
   FUNCTION blobtobase64 (b IN BLOB)
      RETURN CLOB
   AS
      sizeb    PLS_INTEGER := 4080;
      buffer   RAW (4080);
      offset   PLS_INTEGER DEFAULT 1;
      RESULT   CLOB;
   BEGIN
      DBMS_LOB.createtemporary (RESULT, FALSE, DBMS_LOB.CALL);
      LOOP
         BEGIN
            DBMS_LOB.READ (b, sizeb, offset, buffer);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               EXIT;
         END;
         offset := offset + sizeb;
         DBMS_LOB.append
            (RESULT,
             TO_CLOB
                   (UTL_RAW.cast_to_varchar2 (UTL_ENCODE.base64_encode (buffer)
                                             )
                   )
            );
      END LOOP;
      RETURN RESULT;
   END;
   FUNCTION getcolumn (ROW IN t_row, columnname IN VARCHAR2)
      RETURN t_column
   AS
   BEGIN
      FOR i IN 1 .. ROW.COUNT
      LOOP
         IF (ROW (i).NAME = columnname)
         THEN
            RETURN ROW (i);
         END IF;
      END LOOP;
      RETURN NULL;
   END;
   FUNCTION getcolumnvalue (ROW IN t_row, columnname IN VARCHAR2)
      RETURN VARCHAR2
   AS
      COLUMN   t_column;
   BEGIN
      COLUMN := getcolumn (ROW, columnname);
      IF COLUMN IS NOT NULL
      THEN
         RETURN COLUMN.VALUE;
      END IF;
      RETURN NULL;
   END;
   FUNCTION getmscolumnvalue (ROW IN t_row, columnname IN VARCHAR2)
      RETURN t_ms_values
   AS
      COLUMN   t_column;
   BEGIN
      COLUMN := getcolumn (ROW, columnname);
      IF COLUMN IS NOT NULL
      THEN
         RETURN COLUMN.msvalues;
      END IF;
      RETURN NULL;
   END;
   FUNCTION getmscolumnoldvalue (ROW IN t_row, columnname IN VARCHAR2)
      RETURN t_ms_values
   AS
      COLUMN   t_column;
   BEGIN
      COLUMN := getcolumn (ROW, columnname);
      IF COLUMN IS NOT NULL
      THEN
         RETURN COLUMN.msoldvalues;
      END IF;
      RETURN NULL;
   END;
   FUNCTION getcolumnoldvalue (ROW IN t_row, columnname IN VARCHAR2)
      RETURN VARCHAR2
   AS
      COLUMN   t_column;
   BEGIN
      COLUMN := getcolumn (ROW, columnname);
      IF COLUMN IS NOT NULL
      THEN
         RETURN COLUMN.oldvalue;
      END IF;
      RETURN NULL;
   END;
   PROCEDURE setmscolumnvalue (
      ROW             IN OUT   t_row,
      columnname      IN       VARCHAR2,
      mscolumnvalue   IN       t_ms_values
   )
   AS
      COLUMN   t_column;
   BEGIN
      FOR i IN 1 .. ROW.COUNT
      LOOP
         IF (ROW (i).NAME = columnname)
         THEN
            ROW (i).msvalues := mscolumnvalue;
            ROW (i).columntype := 4;
            RETURN;
         END IF;
      END LOOP;
      COLUMN := t_column (columnname, 1, mscolumnvalue);
      ROW.EXTEND;
      ROW (ROW.LAST) := COLUMN;
   END;
   PROCEDURE setmscolumnoldvalue (
      ROW             IN OUT   t_row,
      columnname      IN       VARCHAR2,
      mscolumnvalue   IN       t_ms_values
   )
   AS
   BEGIN
      FOR i IN 1 .. ROW.COUNT
      LOOP
         IF (ROW (i).NAME = columnname)
         THEN
            ROW (i).msoldvalues := mscolumnvalue;
            ROW (i).columntype := 4;
            RETURN;
         END IF;
      END LOOP;
   END;
   PROCEDURE setcolumnvalue (
      ROW           IN OUT   t_row,
      columnname    IN       VARCHAR2,
      columnvalue   IN       VARCHAR2
   )
   AS
      COLUMN   t_column;
   BEGIN
      FOR i IN 1 .. ROW.COUNT
      LOOP
         IF (ROW (i).NAME = columnname)
         THEN
            ROW (i).VALUE := columnvalue;
            ROW (i).columntype := 1;
            RETURN;
         END IF;
      END LOOP;
      COLUMN := t_column (columnname, columnvalue);
      ROW.EXTEND;
      ROW (ROW.LAST) := COLUMN;
   END;
   PROCEDURE setcolumnvalue (
      ROW           IN OUT   t_row,
      columnname    IN       VARCHAR2,
      columnvalue   IN       BLOB
   )
   AS
      COLUMN   t_column;
   BEGIN
      FOR i IN 1 .. ROW.COUNT
      LOOP
         IF (ROW (i).NAME = columnname)
         THEN
            ROW (i).blobvalue := columnvalue;
            ROW (i).columntype := 2;
            RETURN;
         END IF;
      END LOOP;
      COLUMN := t_column (columnname, columnvalue);
      ROW.EXTEND;
      ROW (ROW.LAST) := COLUMN;
   END;
   PROCEDURE setcolumnvalue (
      ROW           IN OUT   t_row,
      columnname    IN       VARCHAR2,
      columnvalue   IN       CLOB
   )
   AS
      COLUMN   t_column;
   BEGIN
      FOR i IN 1 .. ROW.COUNT
      LOOP
         IF (ROW (i).NAME = columnname)
         THEN
            ROW (i).clobvalue := columnvalue;
            ROW (i).columntype := 3;
            RETURN;
         END IF;
      END LOOP;
      COLUMN := t_column (columnname, columnvalue);
      ROW.EXTEND;
      ROW (ROW.LAST) := COLUMN;
   END;
   FUNCTION getmsvalues (msvaluesnodelist IN xmldom.domnodelist)
      RETURN t_ms_values
   AS
      msvalues      t_ms_values;
      msvaluenode   xmldom.domnode;
   BEGIN
      msvalues := t_ms_values ();
      FOR j IN 0 .. xmldom.getlength (msvaluesnodelist) - 1
      LOOP
         msvaluenode := xmldom.item (msvaluesnodelist, j);
         msvalues.EXTEND;
         msvalues (msvalues.LAST) := xslprocessor.valueof (msvaluenode, '.');
      END LOOP;
      RETURN msvalues;
   END;
   FUNCTION getrows (rownodelist IN xmldom.domnodelist)
      RETURN t_rows
   AS
      COLUMN                t_column;
      ROW                   t_row;
      ROWS                  t_rows;
      msvalues              t_ms_values;
      msoldvalues           t_ms_values;
      msvaluesnodelist      xmldom.domnodelist;
      msoldvaluesnodelist   xmldom.domnodelist;
      columnnodelist        xmldom.domnodelist;
      rownode               xmldom.domnode;
      columnnode            xmldom.domnode;
   BEGIN
      ROWS := t_rows ();
      FOR i IN 0 .. xmldom.getlength (rownodelist) - 1
      LOOP
         rownode := xmldom.item (rownodelist, i);
         columnnodelist := xslprocessor.selectnodes (rownode, 'Column');
         ROW := t_row ();
         FOR j IN 0 .. xmldom.getlength (columnnodelist) - 1
         LOOP
            columnnode := xmldom.item (columnnodelist, j);
            IF     xslprocessor.valueof (columnnode, '@MultiSelect') IS NOT NULL
               AND xslprocessor.valueof (columnnode, '@MultiSelect') = 'true'
            THEN
               msvaluesnodelist :=
                              xslprocessor.selectnodes (columnnode, 'values');
               msoldvaluesnodelist :=
                           xslprocessor.selectnodes (columnnode, 'oldValues');
               msvalues := getmsvalues (msvaluesnodelist);
               msoldvalues := getmsvalues (msoldvaluesnodelist);
               COLUMN :=
                  t_column (xslprocessor.valueof (columnnode, '@Name'),
                            1,
                            msvalues
                           );
               IF msoldvalues IS NOT NULL AND msoldvalues.COUNT > 0
               THEN
                  COLUMN.msoldvalues := msoldvalues;
               END IF;
               IF     xslprocessor.valueof (columnnode, '@PrimaryKey') IS NOT NULL
                  AND xslprocessor.valueof (columnnode, '@PrimaryKey') = 'yes'
               THEN
                  COLUMN.primarykey := 1;
               END IF;
            ELSE
               COLUMN :=
                  t_column (xslprocessor.valueof (columnnode, '@Name'),
                            xslprocessor.valueof (columnnode, '.'),
                            xslprocessor.valueof (columnnode, '@OldValue')
                           );
               IF     xslprocessor.valueof (columnnode, '@PrimaryKey') IS NOT NULL
                  AND xslprocessor.valueof (columnnode, '@PrimaryKey') = 'yes'
               THEN
                  COLUMN.primarykey := 1;
               END IF;
            END IF;
            ROW.EXTEND;
            ROW (ROW.LAST) := COLUMN;
         END LOOP;
         ROWS.EXTEND;
         ROWS (ROWS.LAST) := ROW;
      END LOOP;
      RETURN ROWS;
   END;
   PROCEDURE setrows (
      xmldoc            xmldom.domdocument,
      parentnode        xmldom.domnode,
      ROWS         IN   t_rows
   )
   AS
      COLUMN              t_column;
      ROW                 t_row;
      rowelement          xmldom.domelement;
      rownode             xmldom.domnode;
      columnelement       xmldom.domelement;
      columnnode          xmldom.domnode;
      msvalueelement      xmldom.domelement;
      msvaluenode         xmldom.domnode;
      msvalues            t_ms_values;
      msoldvalueelement   xmldom.domelement;
      msoldvaluenode      xmldom.domnode;
      msoldvalues         t_ms_values;
   BEGIN
      IF ROWS IS NULL
      THEN
         RETURN;
      END IF;
      FOR i IN 1 .. ROWS.COUNT
      LOOP
         ROW := ROWS (i);
         rowelement := xmldom.createelement (xmldoc, 'Row');
         rownode :=
                xmldom.appendchild (parentnode, xmldom.makenode (rowelement));
         FOR j IN 1 .. ROW.COUNT
         LOOP
            COLUMN := ROW (j);
            columnelement := xmldom.createelement (xmldoc, 'Column');
            xmldom.setattribute (columnelement, 'Name', COLUMN.NAME);
            IF COLUMN.oldvalue IS NOT NULL
            THEN
               xmldom.setattribute (columnelement,
                                    'OldValue',
                                    COLUMN.oldvalue
                                   );
            END IF;
            IF COLUMN.primarykey = 1
            THEN
               xmldom.setattribute (columnelement, 'PrimaryKey', 'yes');
            END IF;
            IF COLUMN.multiselect = 1
            THEN
               xmldom.setattribute (columnelement, 'MultiSelect', 'true');
            END IF;
            columnnode :=
                 xmldom.appendchild (rownode, xmldom.makenode (columnelement));
            IF COLUMN.columntype = 1
            THEN
               columnnode :=
                  xmldom.appendchild
                        (columnnode,
                         xmldom.makenode (xmldom.createtextnode (xmldoc,
                                                                 COLUMN.VALUE
                                                                )
                                         )
                        );
            ELSIF COLUMN.columntype = 2
            THEN
               columnnode :=
                  xmldom.appendchild
                     (columnnode,
                      xmldom.makenode
                         (xmldom.createtextnode
                                               (xmldoc,
                                                blobtobase64 (COLUMN.blobvalue)
                                               )
                         )
                     );
            ELSIF COLUMN.columntype = 3
            THEN
               columnnode :=
                  xmldom.appendchild
                     (columnnode,
                      xmldom.makenode (xmldom.createtextnode (xmldoc,
                                                              COLUMN.clobvalue
                                                             )
                                      )
                     );
            ELSIF COLUMN.columntype = 4
            THEN
               msvalues := COLUMN.msvalues;
               FOR mscount IN 1 .. msvalues.COUNT
               LOOP
                  msvalueelement := xmldom.createelement (xmldoc, 'values');
                  msvaluenode :=
                     xmldom.appendchild (columnnode,
                                         xmldom.makenode (msvalueelement)
                                        );
                  msvaluenode :=
                     xmldom.appendchild
                        (msvaluenode,
                         xmldom.makenode
                                     (xmldom.createtextnode (xmldoc,
                                                             msvalues (mscount)
                                                            )
                                     )
                        );
               END LOOP;
               msoldvalues := COLUMN.msoldvalues;
               IF msoldvalues IS NOT NULL
               THEN
                  FOR mscount IN 1 .. msoldvalues.COUNT
                  LOOP
                     msoldvalueelement :=
                                   xmldom.createelement (xmldoc, 'oldValues');
                     msoldvaluenode :=
                        xmldom.appendchild
                                          (columnnode,
                                           xmldom.makenode (msoldvalueelement)
                                          );
                     msoldvaluenode :=
                        xmldom.appendchild
                           (msoldvaluenode,
                            xmldom.makenode
                                  (xmldom.createtextnode (xmldoc,
                                                          msoldvalues (mscount)
                                                         )
                                  )
                           );
                  END LOOP;
               END IF;
            END IF;
         END LOOP;
      END LOOP;
   END;
   PROCEDURE setelement (
      xmldoc            xmldom.domdocument,
      parentnode        xmldom.domnode,
      NAME         IN   VARCHAR2,
      VALUE        IN   VARCHAR2
   )
   AS
      ELEMENT   xmldom.domelement;
      node      xmldom.domnode;
   BEGIN
      IF VALUE IS NOT NULL
      THEN
         ELEMENT := xmldom.createelement (xmldoc, NAME);
         node := xmldom.appendchild (parentnode, xmldom.makenode (ELEMENT));
         node :=
            xmldom.appendchild
                             (node,
                              xmldom.makenode (xmldom.createtextnode (xmldoc,
                                                                      VALUE
                                                                     )
                                              )
                             );
      END IF;
   END;
   FUNCTION gethookinput (DATA IN CLOB)
      RETURN t_hookinput
   AS
      hookinput        t_hookinput        := t_hookinput ();
      originalrowset   t_actionrowset;
      selectedrowset   t_rowset;
      parser           xmlparser.parser;
      xmldoc           xmldom.domdocument;
      rootnode         xmldom.domnode;
      formsnodelist    xmldom.domnodelist;
      formnode         xmldom.domnode;
      forms            t_forms;
      formrowset       t_rowset;
      form1            t_form;
   BEGIN
      parser := xmlparser.newparser;
      xmlparser.parseclob (parser, DATA);
      xmldoc := xmlparser.getdocument (parser);
      xmlparser.freeparser (parser);
      rootnode := xmldom.makenode (xmldoc);
      hookinput.invocationnumber :=
         TO_NUMBER
            (xslprocessor.valueof
                             (rootnode,
                              '/OnedataInteractiveHookInput/@InvocationNumber'
                             )
            );
      hookinput.userid :=
         xslprocessor.valueof (rootnode,
                               '/OnedataInteractiveHookInput/@UserId'
                              );
      hookinput.clientid :=
         xslprocessor.valueof (rootnode,
                               '/OnedataInteractiveHookInput/@ClientId'
                              );
      hookinput.projectid :=
         xslprocessor.valueof (rootnode,
                               '/OnedataInteractiveHookInput/@ProjectId'
                              );
      hookinput.schemaid :=
         xslprocessor.valueof (rootnode,
                               '/OnedataInteractiveHookInput/@SchemaId'
                              );
      hookinput.repositoryid :=
         xslprocessor.valueof (rootnode,
                               '/OnedataInteractiveHookInput/@RepositoryId'
                              );
      hookinput.databasetype :=
         xslprocessor.valueof (rootnode,
                               '/OnedataInteractiveHookInput/@DatabaseType'
                              );
      hookinput.invokedfromworkflow :=
         xslprocessor.valueof
                          (rootnode,
                           '/OnedataInteractiveHookInput/@InvokedFromWorkflow'
                          );
      hookinput.approverid :=
         xslprocessor.valueof (rootnode,
                               '/OnedataInteractiveHookInput/@ApproverID'
                              );
      hookinput.updatedcolname :=
         xslprocessor.valueof (rootnode,
                               '/OnedataInteractiveHookInput/@UpdColName'
                              );
      hookinput.workflowpassphrase :=
         xslprocessor.valueof
                           (rootnode,
                            '/OnedataInteractiveHookInput/@WorkflowPassPhrase'
                           );
      hookinput.refreshtransaction :=
         xslprocessor.valueof
                           (rootnode,
                            '/OnedataInteractiveHookInput/@RefreshTransaction'
                           );
      originalrowset :=
         t_actionrowset
            (t_rows (),
             xslprocessor.valueof
                    (rootnode,
                     '/OnedataInteractiveHookInput/OriginalRowset/@ObjectName'
                    ),
             xslprocessor.valueof
                    (rootnode,
                     '/OnedataInteractiveHookInput/OriginalRowset/@ObjectType'
                    ),
             xslprocessor.valueof
                     (rootnode,
                      '/OnedataInteractiveHookInput/OriginalRowset/@TableName'
                     ),
             0,
             xslprocessor.valueof
                          (rootnode,
                           '/OnedataInteractiveHookInput/OriginalRowset/@Type'
                          ),
             xslprocessor.valueof
                (rootnode,
                 '/OnedataInteractiveHookInput/OriginalRowset/@ConceptualObjectName'
                )
            );
      originalrowset.rowset :=
         getrows
            (xslprocessor.selectnodes
                            (rootnode,
                             '/OnedataInteractiveHookInput/OriginalRowset/Row'
                            )
            );
      hookinput.originalrowset := originalrowset;
      IF xmldom.getlength
            (xslprocessor.selectnodes
                            (rootnode,
                             '/OnedataInteractiveHookInput/SelectedRowset/Row'
                            )
            ) > 0
      THEN
         selectedrowset :=
            t_rowset
               (t_rows (),
                xslprocessor.valueof
                    (rootnode,
                     '/OnedataInteractiveHookInput/SelectedRowset/@ObjectName'
                    ),
                xslprocessor.valueof
                    (rootnode,
                     '/OnedataInteractiveHookInput/SelectedRowset/@ObjectType'
                    ),
                NULL
               );
         selectedrowset.rowset :=
            getrows
               (xslprocessor.selectnodes
                            (rootnode,
                             '/OnedataInteractiveHookInput/SelectedRowset/Row'
                            )
               );
         hookinput.selectedrowset := selectedrowset;
      END IF;
      hookinput.answerid :=
         TO_NUMBER
              (xslprocessor.valueof (rootnode,
                                     '/OnedataInteractiveHookInput/Answer/@Id'
                                    )
              );
      IF xmldom.getlength
            (xslprocessor.selectnodes
                                    (rootnode,
                                     '/OnedataInteractiveHookInput/Forms/Form'
                                    )
            ) > 0
      THEN
         formsnodelist :=
            xslprocessor.selectnodes
                                   (rootnode,
                                    '/OnedataInteractiveHookInput/Forms/Form'
                                   );
         forms := t_forms ();
         forms.EXTEND (xmldom.getlength (formsnodelist));
         FOR i IN 0 .. xmldom.getlength (formsnodelist) - 1
         LOOP
            formnode := xmldom.item (formsnodelist, i);
            formrowset :=
               t_rowset (getrows (xslprocessor.selectnodes (formnode,
                                                            'Rowset/Row'
                                                           )
                                 ),
                         xslprocessor.valueof (rootnode, 'Rowset/@TableName')
                        );
            form1 :=
               t_form (xslprocessor.valueof (formnode, '@ObjectName'),
                       xslprocessor.valueof (formnode, '@ObjectType'),
                       xslprocessor.valueof (formnode, '@Cardinality'),
                       formrowset
                      );
            forms (i + 1) := form1;
         END LOOP;
         hookinput.forms := forms;
      END IF;
      xmldom.freedocument (xmldoc);
      RETURN hookinput;
   END;
   FUNCTION gethookoutput (hookoutput IN t_hookoutput)
      RETURN CLOB
   AS
      xmldoc           xmldom.domdocument;
      mainnode         xmldom.domnode;
      rootnode         xmldom.domnode;
      rootelement      xmldom.domelement;
      element1         xmldom.domelement;
      node1            xmldom.domnode;
      element2         xmldom.domelement;
      node2            xmldom.domnode;
      element3         xmldom.domelement;
      node3            xmldom.domnode;
      question         t_question;
      answer           t_answer;
      showrowset       t_showablerowset;
      originalrowset   t_actionrowset;
      action           t_actionrowset;
      form1            t_form;
      xmlheader        VARCHAR2 (32767)
                      := '<?xml version="1.0" encoding="UTF-8"?>' || CHR (10);
      xmlclob          CLOB;
      tempclob         CLOB;
   BEGIN
      xmldoc := xmldom.newdomdocument;
      mainnode := xmldom.makenode (xmldoc);
      rootelement :=
                xmldom.createelement (xmldoc, 'OnedataInteractiveHookOutput');
      xmldom.setattribute (rootelement,
                           'InvocationNumber',
                           hookoutput.invocationnumber
                          );
      rootnode := xmldom.appendchild (mainnode, xmldom.makenode (rootelement));
      setelement (xmldoc, rootnode, 'Message', hookoutput.MESSAGE);
      setelement (xmldoc, rootnode, 'Status', hookoutput.status);
      IF hookoutput.forwardhookname IS NOT NULL
      THEN
         element1 := xmldom.createelement (xmldoc, 'Forward');
         node1 := xmldom.appendchild (rootnode, xmldom.makenode (element1));
         xmldom.setattribute (element1,
                              'HookName',
                              hookoutput.forwardhookname
                             );
      END IF;
      IF hookoutput.question IS NOT NULL
      THEN
         question := hookoutput.question;
         element1 := xmldom.createelement (xmldoc, 'Question');
         node1 := xmldom.appendchild (rootnode, xmldom.makenode (element1));
         setelement (xmldoc, node1, 'Text', question.text);
         FOR i IN question.answers.FIRST .. question.answers.LAST
         LOOP
            answer := question.answers (i);
            element2 := xmldom.createelement (xmldoc, 'Answer');
            xmldom.setattribute (element2, 'Id', answer.ID);
            xmldom.setattribute (element2, 'Order', answer.answerorder);
            node2 := xmldom.appendchild (node1, xmldom.makenode (element2));
            node2 :=
               xmldom.appendchild
                         (node2,
                          xmldom.makenode (xmldom.createtextnode (xmldoc,
                                                                  answer.text
                                                                 )
                                          )
                         );
         END LOOP;
      END IF;
      IF hookoutput.showrowset IS NOT NULL
      THEN
         showrowset := hookoutput.showrowset;
         element1 := xmldom.createelement (xmldoc, 'ShowRowset');
         node1 := xmldom.appendchild (rootnode, xmldom.makenode (element1));
         xmldom.setattribute (element1,
                              'SelectionType',
                              showrowset.selectiontype
                             );
         IF showrowset.objectname IS NOT NULL
         THEN
            xmldom.setattribute (element1,
                                 'ObjectName',
                                 showrowset.objectname
                                );
         END IF;
         IF showrowset.objecttype IS NOT NULL
         THEN
            xmldom.setattribute (element1,
                                 'ObjectType',
                                 showrowset.objecttype
                                );
         END IF;
         setrows (xmldoc, node1, showrowset.rowset);
      END IF;
      IF hookoutput.originalrowset IS NOT NULL
      THEN
         originalrowset := hookoutput.originalrowset;
         element1 := xmldom.createelement (xmldoc, 'OriginalRowset');
         node1 := xmldom.appendchild (rootnode, xmldom.makenode (element1));
         xmldom.setattribute (element1, 'TableName',
                              originalrowset.tablename);
         IF originalrowset.actiontype IS NOT NULL
         THEN
            xmldom.setattribute (element1, 'Type', originalrowset.actiontype);
         END IF;
         IF originalrowset.objectname IS NOT NULL
         THEN
            xmldom.setattribute (element1,
                                 'ObjectName',
                                 originalrowset.objectname
                                );
         END IF;
         IF originalrowset.objecttype IS NOT NULL
         THEN
            xmldom.setattribute (element1,
                                 'ObjectType',
                                 originalrowset.objecttype
                                );
         END IF;
         IF originalrowset.conceptualobjectname IS NOT NULL
         THEN
            xmldom.setattribute (element1,
                                 'ConceptualObjectName',
                                 originalrowset.conceptualobjectname
                                );
         END IF;
         setrows (xmldoc, node1, originalrowset.rowset);
      END IF;
      IF hookoutput.actions IS NOT NULL
      THEN
         element1 := xmldom.createelement (xmldoc, 'Actions');
         node1 := xmldom.appendchild (rootnode, xmldom.makenode (element1));
         FOR i IN hookoutput.actions.FIRST .. hookoutput.actions.LAST
         LOOP
            action := hookoutput.actions (i);
            element2 := xmldom.createelement (xmldoc, 'Action');
            xmldom.setattribute (element2, 'Type', action.actiontype);
            xmldom.setattribute (element2, 'TableName', action.tablename);
            xmldom.setattribute (element2, 'Order', action.actionorder);
            IF action.objectname IS NOT NULL
            THEN
               xmldom.setattribute (element2, 'ObjectName',
                                    action.objectname);
            END IF;
            IF action.objecttype IS NOT NULL
            THEN
               xmldom.setattribute (element2, 'ObjectType',
                                    action.objecttype);
            END IF;
            IF action.conceptualobjectname IS NOT NULL
            THEN
               xmldom.setattribute (element2,
                                    'ConceptualObjectName',
                                    action.conceptualobjectname
                                   );
            END IF;
            node2 := xmldom.appendchild (node1, xmldom.makenode (element2));
            setrows (xmldoc, node2, action.rowset);
         END LOOP;
      END IF;
      IF hookoutput.forms IS NOT NULL
      THEN
         element1 := xmldom.createelement (xmldoc, 'Forms');
         node1 := xmldom.appendchild (rootnode, xmldom.makenode (element1));
         FOR i IN hookoutput.forms.FIRST .. hookoutput.forms.LAST
         LOOP
            form1 := hookoutput.forms (i);
            element2 := xmldom.createelement (xmldoc, 'Form');
            xmldom.setattribute (element2, 'ObjectName', form1.objectname);
            xmldom.setattribute (element2, 'Cardinality', form1.CARDINALITY);
            IF form1.objecttype IS NOT NULL
            THEN
               xmldom.setattribute (element2, 'ObjectType', form1.objecttype);
            END IF;
            xmldom.setattribute (element2,
                                 'SkipReferenceValidation',
                                 form1.skipreferencevalidation
                                );
            node2 := xmldom.appendchild (node1, xmldom.makenode (element2));
            element3 := xmldom.createelement (xmldoc, 'Rowset');
            node3 := xmldom.appendchild (node2, xmldom.makenode (element3));
            setrows (xmldoc, node3, form1.rowset.rowset);
         END LOOP;
      END IF;
      DBMS_LOB.createtemporary (tempclob, TRUE, DBMS_LOB.CALL);
      DBMS_LOB.OPEN (tempclob, DBMS_LOB.lob_readwrite);
      xmldom.writetoclob (xmldoc, tempclob, 'UTF-8');
      xmldom.freedocument (xmldoc);
      DBMS_LOB.createtemporary (xmlclob, TRUE, DBMS_LOB.CALL);
      DBMS_LOB.OPEN (xmlclob, DBMS_LOB.lob_readwrite);
      DBMS_LOB.writeappend (xmlclob, LENGTH (xmlheader), xmlheader);
      DBMS_LOB.append (xmlclob, tempclob);
      DBMS_LOB.CLOSE (tempclob);
      DBMS_LOB.CLOSE (xmlclob);
      RETURN xmlclob;
   END;
END;
/
