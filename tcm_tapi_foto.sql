-- DESCRIPTION --
create or replace package pk_tcmtapi_foto
is
    procedure bewaar_foto(p_id in number, P_imgcontent in blob);
end pk_tcmtapi_foto;
/

-- BODY --
create or replace package body pk_tcmtapi_foto
is
    procedure bewaar_foto(p_id in number, P_imgcontent in foto.image_name%type)
    is
    begin
        insert into foto(
        pers_id,
        image,
        image_name,
        image_mimetype
        -- image_lastupdated
        ) values
        (
            p_id,
            P_imgcontent,
            P_imgcontent,
            'image/png'
        );
    end bewaar_foto;
end pk_tcmtapi_foto; 
/
  ----
  
--    IMAGE_CONTENT
--    IF ( :P1_FILE_NAME is not null ) THEN 
--     INSERT INTO oehr_file_subject(id,NAME, SUBJECT, BLOB_CONTENT, MIME_TYPE) 
--      SELECT ID,:P1_FILE_NAME,:P1_SUBJECT,blob_content,mime_type
--            FROM APEX_APPLICATION_FILES
--            WHERE name = :P1_FILE_NAME;
--   DELETE from APEX_APPLICATION_FILES WHERE name = :P1_FILE_NAME;
--  END IF;
--  
  
