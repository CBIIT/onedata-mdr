create or replace function get_concepts_PRN(v_item_id in number, v_ver_nr in number) return varchar2 is
cursor con is
select c.item_nm, cai.NCI_CNCPT_VAL,Item_long_nm
from cncpt_admin_item cai, admin_item c
where cai.item_id = v_item_id and cai.ver_nr = v_ver_nr 
and cai.cncpt_item_id = c.item_id and cai.cncpt_ver_nr = c.ver_nr and c.admin_item_typ_id = 49
order by  nci_ord desc;

v_name varchar2(255);

begin
    for c_rec in con loop
        if v_name is null then
            v_name := ':'||c_rec.Item_long_nm;

            /* Check if Integer Concept */
            if c_rec.item_nm = 'C45255' then
                v_name := v_name||'::'||c_rec.nci_cncpt_val;
            end if;
        else
            v_name := v_name||':'||c_rec.Item_long_nm;

            /* Check if Integer Concept */
            if c_rec.item_nm = 'C45255' then
                v_name := v_name||'::'||c_rec.nci_cncpt_val;
            end if;
        end if;

    end loop;
return v_name;
end;

