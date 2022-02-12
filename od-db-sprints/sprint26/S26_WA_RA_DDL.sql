create table nci_job_log 
(log_id integer not null primary key, 
 start_dt datetime default sysdate,
 job_step_desc  varchar2(255) not null,
 end_dt datetime,
 
