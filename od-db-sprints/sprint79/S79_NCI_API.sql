create or replace PACKAGE            nci_api AS
  
 function                       getAPIURL(v_use in varchar2) return varchar2; -- stored in NCI_LLM_CNFG
 function                       getLLMParam(v_mdl in varchar2, v_use in varchar2) return varchar2; -- stored in NCI_LLM_CNFG
 procedure  setStdRequestHdr;
 function                       getCFGParam(v_use in varchar2) return varchar2; -- stored in NCI_MDR_CNTRL
 function getllmDefinition (v_def in varchar2) return varchar2;
 procedure testLLM (v_def in varchar2);
procedure sendEmail (v_to in varchar2, v_subject in varchar2, v_body in clob) ;
procedure spTestISConnection;
END;
/
create or replace PACKAGE BODY            nci_api AS


function                       getAPIURL(v_use in varchar2) return varchar2
as
    l_url      VARCHAR2(4000);
    v_temp integer;
    v_host varchar2(100);
BEGIN

v_host := nci_api.getCFGPAram('DOWNLOAD_HOST');
for cur in (select * from nci_llm_cnfg where use_case = v_use and LLM_MDL_VER= 'CADSRAPI') loop
    l_url := v_host || cur.param_Val;
    end loop;
   -- raise_application_error(-20000, l_url);
  return l_url; 
end;


function                       getLLMParam(v_mdl in varchar2, v_use in varchar2) return varchar2
as
    l_param      VARCHAR2(4000);
    v_temp integer;
BEGIN
for cur in (select * from nci_llm_cnfg where use_case = v_use and LLM_MDL_VER= v_mdl) loop
    l_param := cur.param_Val;
    end loop;
   -- raise_application_error(-20000, l_url);
  return trim(l_param); 
end;

function                       getCFGParam(v_use in varchar2) return varchar2  -- ISAPIUSER - User; ISAPIUSERPWD - Password
as
    l_param     VARCHAR2(4000);
    v_temp integer;
BEGIN
for cur in (select * from nci_mdr_cntrl where param_nm= v_use ) loop
    l_param := cur.param_Val;
    end loop;
   -- raise_application_error(-20000, l_url);
  return l_param; 
end;

procedure setStdRequestHdr
as
v_int integer;
begin
   apex_web_service.g_request_headers(1).name := 'User-Agent';
    apex_web_service.g_request_headers(1).value := 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)';
    apex_web_service.g_request_headers(3).name := 'Content-Type';
    apex_web_service.g_request_headers(3).value := 'application/json';
    apex_web_service.g_request_headers(2).name := 'accept';
    apex_web_service.g_request_headers(2).value := 'application/json';
end;

/* “to” : “<emailAddress>”
  “subject”:”<subject>”
  “emailBody”:”<text>” */
  
procedure sendEmail (v_to in varchar2, v_subject in varchar2, v_body in clob) 
as
v_int integer;
 l_url varchar2(4000);
l_body clob;
v_usr varchar2(100);
v_pwd varchar2(100);
l_response clob;
begin

    apex_web_service.g_request_headers.delete();
    nci_api.setStdRequestHdr;
   -- v_usr := nci_api.getAPIParam('ISAPIUSER');
   -- v_pwd := nci_api.getAPIParam('ISAPIUSERPWD');
  
    l_url := nci_api.getAPIUrl('EMAIL');
     l_body := 
  '{"to" : "' || v_to ||
  '",  "subject" : "' || v_subject || '",
  "emailBody" : "'|| v_body || '"}'
    ;

dbms_output.put_line(l_url);  
dbms_output.put_line(l_body);

    l_response := apex_web_service.make_rest_request(
        p_url           => l_url,
        p_http_method   => 'POST',
        p_body          => l_body,
      --  p_username     => 'onedataapi',
      -- p_password      => 'onedataapi-dev',
        p_scheme        => 'basic',
        p_wallet_path=> 'file:/app/oracle/product/dbhome/19.3.0.0/network/admin/oracle_wallet'
    );
  
dbms_output.put_line(l_response);  

end;

procedure                       spTestISConnection
as
    l_response CLOB;
    l_body     CLOB;
    l_url      VARCHAR2(4000);
    l_raw_auth RAW(200); 
    l_enc_auth VARCHAR2(400); 
    
BEGIN
    -- 1. Setup URL (Example: Gemini 1.5 Flash)
  --  l_url := 'https://cadsrapi-dev.cancer.gov/rad/brad/llmtest/getLLMResponse';
   -- l_url := 'https://cadsrapi-dev.cancer.gov/rad/cdeai.api.producer.v2:cdeai_rad/performCDEAIMatch';
   l_url := nci_api.getAPIUrl('CDEAIMATCH');
 
   apex_web_service.g_request_headers.delete();
    apex_web_service.g_request_headers(1).name := 'User-Agent';
    apex_web_service.g_request_headers(1).value := 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)';
   
   l_body := '{
  "match_limit": 10,
  "cde_model_variant": ["CDEMeta-SapBERT"],
  "cde_match_threshold": 0.5,
  "pv_match_threshold": 0.5,
  "source_entities": [
    {
      "sequence_id": "1",
      "entity_text": "Library"
    }
  ],
  "compute_auc": true
  }';

    -- 3. Set Request Headers
  apex_web_service.g_request_headers(3).name := 'Content-Type';
    apex_web_service.g_request_headers(3).value := 'application/json';
    apex_web_service.g_request_headers(2).name := 'accept';
    apex_web_service.g_request_headers(2).value := 'application/json';
 --.set_header(l_http_req, 'Authorization', l_enc_auth);
    -- 4. Make Request using stored credentials
    l_response := apex_web_service.make_rest_request(
        p_url           => l_url,
        p_http_method   => 'POST',
        p_body          => l_body,
        p_username     => 'onedataapi',
        p_password      => 'onedataapi-dev',
        p_scheme        => 'basic',
   -- p_body => 
    --    p_credential_static_id => 'AIzaSyC1fMXLBGFkd88g6GdikdfKKBqWfitzPjU',
        p_wallet_path=> 'file:/app/oracle/product/dbhome/19.3.0.0/network/admin/oracle_wallet'
    );
              
  
  dbms_output.put_line(l_response);
end;


procedure testLLM (v_def in varchar2) 
as
v_int integer;
 l_url varchar2(4000);
l_body clob;
v_usr varchar2(100);
v_pwd varchar2(100);
l_prompt varchar2(4000);
l_response clob;
begin

    apex_web_service.g_request_headers.delete();
    nci_api.setStdRequestHdr;
   -- v_usr := nci_api.getAPIParam('ISAPIUSER');
   -- v_pwd := nci_api.getAPIParam('ISAPIUSERPWD');
  
    l_url := nci_api.getAPIUrl('LLM');
 -- l_url := 'https://cadsrapi-dev.cancer.gov/rad/aws.bedrock:bedrock_rad/v1/converse';
    l_prompt := nci_api.getLLMParam('ALL','DEFINITION');
     l_body := 
  '{
"payload":"' || l_prompt  || ' ' || v_def || '"
}'
    ;
--"modelID":"us.moonshotai.kimi-k3.1",

dbms_output.put_line(l_url);  
dbms_output.put_line(l_body);
begin
    l_response := apex_web_service.make_rest_request(
        p_url           => l_url,
        p_http_method   => 'POST',
        p_body          => l_body,
      --  p_username     => 'onedataapi',
      -- p_password      => 'onedataapi-dev',
        p_scheme        => 'basic',
        p_wallet_path=> 'file:/app/oracle/product/dbhome/19.3.0.0/network/admin/oracle_wallet'
    );
      EXCEPTION WHEN OTHERS THEN
          dbms_output.put_line( 'Issue with API. G_STATUS_CODE: ' || apex_web_service.g_status_code);
    end;
dbms_output.put_line('status code : ' || apex_web_service.g_status_code);
dbms_output.put_line(l_response);  
raise_application_Error(-20000,l_response);

end;

function getllmDefinition (v_def in varchar2) return varchar2
as
v_int integer;
 l_url varchar2(4000);
l_body clob;
v_usr varchar2(100);
v_pwd varchar2(100);
l_prompt varchar2(4000);
l_response clob;
begin

    apex_web_service.g_request_headers.delete();
    nci_api.setStdRequestHdr;
   -- v_usr := nci_api.getAPIParam('ISAPIUSER');
   -- v_pwd := nci_api.getAPIParam('ISAPIUSERPWD');
  
    l_url := nci_api.getAPIUrl('LLM');
    l_prompt := nci_api.getLLMParam('ALL','DEFINITION');
     l_body := 
  '{
"payload":"' || l_prompt  || ' ' || v_def || '"
}'
    ;
--"modelID":"us.moonshotai.kimi-k3.1",

dbms_output.put_line(l_url);  
dbms_output.put_line(l_body);
    begin
    l_response := apex_web_service.make_rest_request(
        p_url           => l_url,
        p_http_method   => 'POST',
        p_body          => l_body,
      --  p_username     => 'onedataapi',
      -- p_password      => 'onedataapi-dev',
        p_scheme        => 'basic',
        p_wallet_path=> 'file:/app/oracle/product/dbhome/19.3.0.0/network/admin/oracle_wallet'
    );
    EXCEPTION WHEN OTHERS THEN
          return  ( 'Issue with API. G_STATUS_CODE: ' || apex_web_service.g_status_code);
    end;
    return   JSON_VALUE(l_response, '$.response');
     /*   WHEN OTHERS THEN
            log_api_error(
                p_url           => c_endpoint,
                p_error_type    => 'NETWORK_OR_SSL_ERROR',
                p_error_message => SQLERRM
            );
            apex_error.add_error(
                p_message          => 'Unable to connect to the external order service. Please try again later.',
                p_display_location => apex_error.c_inline_in_notification
            );
            RETURN;
    END;
*/

   -- if (apex_web_service.g_status_code < 300) then 
--dbms_output.put_line(JSON_VALUE(l_response, '$.response'));  
    
        
   -- end if;
    /*--
    -- 3. Evaluate HTTP Status Code

    l_status_code := apex_web_service.g_status_code;

 

    IF l_status_code NOT BETWEEN 200 AND 299 THEN
        BEGIN
            apex_json.parse(l_response);
            l_api_err_msg := COALESCE(
                apex_json.get_varchar2('error.message'),
                apex_json.get_varchar2('message'),
                'HTTP ' || l_status_code || ' returned by server.'
            );
        EXCEPTION
            WHEN OTHERS THEN
                -- Response wasn't valid JSON (e.g., HTML 502 Bad Gateway page)
                l_api_err_msg := 'HTTP ' || l_status_code || ' (Non-JSON response)';
        END;

 

        log_api_error(
            p_url           => c_endpoint,
            p_http_status   => l_status_code,
            p_error_type    => 'HTTP_STATUS_ERROR',
            p_error_message => l_api_err_msg,
            p_response_body => l_response
        );
        -- Tailor user message based on status category

        IF l_status_code IN (401, 403) THEN
            apex_error.add_error(
                p_message          => 'Authorization failed with the external service. Contact your administrator.',
                p_display_location => apex_error.c_inline_in_notification
            );
        ELSIF l_status_code BETWEEN 400 AND 499 THEN
            apex_error.add_error(
                p_message          => 'The request was rejected: ' || l_api_err_msg,
                p_display_location => apex_error.c_inline_in_notification
            );
        ELSE
            apex_error.add_error(
                p_message          => 'The external service encountered an internal error (HTTP ' || l_status_code || ').',
                p_display_location => apex_error.c_inline_in_notification
            );
        END IF;
        RETURN;
    END IF;
    -- 4. Parse Successful Response Safely

    BEGIN
        IF l_response IS NULL OR DBMS_LOB.GETLENGTH(l_response) = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Empty response body received on HTTP ' || l_status_code);
        END IF;
        apex_json.parse(l_response);
        l_order_id := apex_json.get_varchar2(p_path => 'data.orderId');
        :P10_ORDER_ID := l_order_id;
    EXCEPTION
        WHEN OTHERS THEN
            log_api_error(
                p_url           => c_endpoint,
                p_http_status   => l_status_code,
                p_error_type    => 'JSON_PARSE_ERROR',
                p_error_message => SQLERRM,
                p_response_body => l_response
            );
            apex_error.add_error(
                p_message          => 'Received an unreadable response from the order service.',
                p_display_location => apex_error.c_inline_in_notification
            );
    END;
*/
 
end;


  
end;
/
