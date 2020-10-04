create index AC_CHANGE_HISTORY_IDX on AC_CHANGE_HISTORY_EXT (AC_IDSEQ);

grant select on sbr.administered_components to onedata_md;
grant select on sbr.definitions to onedata_md;
grant select on sbr.designations  to onedata_md;
grant select on sbr.user_accounts to onedata_md;
grant all on sbr.administered_components to onedata_wa;
grant all on sbr.value_domains to onedata_wa;
grant all on sbr.data_elements to onedata_wa;
grant all on sbr.contact_comms to onedata_wa;

