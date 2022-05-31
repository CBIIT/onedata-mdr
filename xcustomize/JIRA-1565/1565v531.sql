select count(*) from sbrext.COMPONENT_CONCEPTS_EXT c,SBREXT.CON_DERIVATION_RULES_EXT d  --274714,274223,283882,283882
where c.CONDR_IDSEQ=d.CONDR_IDSEQ;
select count(*) from onedata_wa.CNCPT_ADMIN_ITEM where nvl(fld_delete,0)=0 ;--284332


select * from sbrext.COMPONENT_CONCEPTS_EXT;
select * from onedata_wa.CNCPT_ADMIN_ITEM where nvl(fld_delete,0)=0;

select count(*) from sbrext.COMPONENT_CONCEPTS_EXT c,SBR.ADMINISTERED_COMPONENTS d--274714
where c.cc_IDSEQ=d.AC_IDSEQ;

select count(*) from sbrext.COMPONENT_CONCEPTS_EXT c,SBR.ADMINISTERED_COMPONENTS oce,SBREXT.CON_DERIVATION_RULES_EXT d  --274714
where c.CONDR_IDSEQ=d.CONDR_IDSEQ;

select COUNT(*)
FROM sbrext_m.COMPONENT_CONCEPTS_EXT  cc,
               SBR.ADMINISTERED_COMPONENTS oce,-- sbrext_m.object_classes_ext      oce,
               admin_item                     con,
               admin_item                     oc
         WHERE     cc.CONDR_IDSEQ = oce.CONDR_IDSEQ
               AND oce.ac_idseq = oc.nci_idseq
               AND cc.con_idseq = con.nci_idseq;
               
               select * from SBR.ADMINISTERED_COMPONENTS;
               
               select count(*) from sbrext.COMPONENT_CONCEPTS_EXT c,SBR.ADMINISTERED_COMPONENTS d,SBREXT.CON_DERIVATION_RULES_EXT d--274714
where c.cc_IDSEQ=d.AC_IDSEQ;

select *from SBREXT.CON_DERIVATION_RULES_EXT where NAME like'%:%';
select* from sbr.CONCEPTS_EXT;

select*from sbrext_m.object_classes_ext;
select*from sbrext_m.properties_ext ;


select COUNT(*)
FROM sbrext_m.COMPONENT_CONCEPTS_EXT  cc,
               SBR.concepts_ext con ,
               (select OC_IDSEQ NCI_IDSEQ,condr_idseq from sbrext.object_classes_ext
               union 
               select PROP_IDSEQ,condr_idseq from sbrext.properties_ext 
                union 
               select rep_IDSEQ,condr_idseq from SBREXT.REPRESENTATIONS_EXT
               union
               select VD_IDSEQ,condr_idseq from SBR.VALUE_DOMAINS
               union
               select VM_IDSEQ,condr_idseq from SBR.VALUE_MEANINGS
               UNION 
               select CD_IDSEQ,condr_idseq from sbr.conceptual_domains 
               )ai
         WHERE    cc.con_idseq = con.con_idseq
         and ai.condr_idseq= cc.CONDR_IDSEQ;--284185
         
         select count(*) from onedata_wa.CNCPT_ADMIN_ITEM where nvl(fld_delete,0)=0 ;--284895 284895
         
select*from ONEDATA_WA.ADMIN_ITEM  where NCI_IDSEQ  in(
   
         SELECT ai.NCI_IDSEQ from ONEDATA_WA.ADMIN_ITEM ai,onedata_wa.CNCPT_ADMIN_ITEM c where nvl(c.fld_delete,0)=0 
         and ai.item_id=c.item_id 
         and ai.VER_NR = c.VER_NR
         minus
         select NCI_IDSEQ
FROM sbrext.COMPONENT_CONCEPTS_EXT  cc,
               SBR.concepts_ext con ,
               (select OC_IDSEQ NCI_IDSEQ,condr_idseq from sbrext.object_classes_ext
               union 
               select PROP_IDSEQ,condr_idseq from sbrext.properties_ext 
                union 
               select rep_IDSEQ,condr_idseq from SBREXT.REPRESENTATIONS_EXT
               union
               select VD_IDSEQ,condr_idseq from SBR.VALUE_DOMAINS
               union
               select VM_IDSEQ,condr_idseq from SBR.VALUE_MEANINGS
               UNION 
               select CD_IDSEQ,condr_idseq from sbr.conceptual_domains 
               )ai
         WHERE    cc.con_idseq = con.con_idseq
         and ai.condr_idseq= cc.CONDR_IDSEQ);
         
         
         select *from SBR.ADMINISTERED_COMPONENTS ac where ac.public_id in (10387113,6160650,10387112,
10387110,10387111,10385189,10203769,10203768);
select*from SBR.VALUE_MEANINGS where VM_ID in (10387113,6160650,10387112,
10387110,10387111,10385189,10203769,10203768);


 select *
FROM sbrext.COMPONENT_CONCEPTS_EXT  cc,
              sBR.concepts_ext con ,
             SBR.VALUE_MEANINGS vm            
         WHERE    
        vm.condr_idseq= cc.CONDR_IDSEQ
       and   cc.con_idseq = con.con_idseq
                and VM_ID=10387113;
                
                select NCI_IDSEQ,ai.item_id
             --   select count(*)
FROM sbrext.COMPONENT_CONCEPTS_EXT  cc,
               SBR.concepts_ext con ,
               (select OC_IDSEQ NCI_IDSEQ,condr_idseq,oc_id item_id from sbrext.object_classes_ext
               union 
               select PROP_IDSEQ,condr_idseq ,prop_id from sbrext.properties_ext 
                union 
               select rep_IDSEQ,condr_idseq ,rep_id from SBREXT.REPRESENTATIONS_EXT
               union
               select VD_IDSEQ,condr_idseq ,vd_id from SBR.VALUE_DOMAINS
               union
               select VM_IDSEQ,condr_idseq, vm_id from SBR.VALUE_MEANINGS
               UNION 
               select CD_IDSEQ,condr_idseq,cd_id from sbr.conceptual_domains 
               )ai
         WHERE    cc.con_idseq = con.con_idseq
         and ai.condr_idseq= cc.CONDR_IDSEQ
         and ai.item_id in (10387113,6160650,10387112,
10387110,10387111,10385189,10203769,10203768);

select*from  sbr.conceptual_domains ;