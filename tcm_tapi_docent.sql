-- DROP
--drop package body pk_tcmapi_docent;
--drop package pk_tcmapi_docent;
--/

-- DESCRIPTION --
create or replace package pk_tcmapi_docent
is
    procedure display_docent;
    procedure save_docent;
end pk_tcmapi_docent;
/

-- BODY --
create or replace package body pk_tcmapi_docent
is
     -- DISPLAY DOCENT --
    procedure display_docent
    is
        v_persoonid pls_integer;
        v_voornaam persoon.voornaam%type;
        v_achternaam persoon.achternaan%type;
        v_tv persoon.tv%type;
        v_email persoon.email%type;
        v_mobiel persoon.mobiel%type;
        
        v_soort docent.soort%type;
        v_beschikbaar docent.beschikbaar%type;
    begin
        v_persoonid := nv('P2_ID');
        if ( v_persoonid <> NULL or v_persoonid > 0 ) THEN
            select  persoon.voornaam, 
                    persoon.achternaan,
                    persoon.tv,
                    persoon.email,
                    persoon.mobiel,
                    docent.soort,
                    docent.beschikbaar
            into    v_voornaam,
                    v_achternaam,
                    v_tv,
                    v_email,
                    v_mobiel,
                    v_soort,
                    v_beschikbaar
            from persoon, docent
            where 
            docent.pers_id = persoon.id and docent.pers_id = 
            v_persoonid;
            
            APEX_UTIL.set_session_state('P2_VOORNAAM',v_voornaam);
            APEX_UTIL.set_session_state('P2_ACHTERNAAN',v_achternaam);
            APEX_UTIL.set_session_state('P2_TV',v_tv);
            APEX_UTIL.set_session_state('P2_EMAIL',v_email);
            APEX_UTIL.set_session_state('P2_MOBIEL',v_mobiel);
            APEX_UTIL.set_session_state('P2_SOORT',v_soort);
            APEX_UTIL.set_session_state('P2_BESCHIKBAAR',v_beschikbaar);
        end if;
        commit;
    end display_docent;
    
    -- INSERT DOCENT --
    procedure save_docent
    is
            v_persoonid pls_integer;
    begin
            v_persoonid := nv('P2_ID');
            -- INSERT DOCENT --
            if ( v_persoonid is NULL or v_persoonid <= 0 ) THEN
                insert into persoon (
                voornaam,
                achternaan,
                tv,
                email,
                mobiel
                ) values
                (
                    v('P2_VOORNAAM'),
                    v('P2_ACHTERNAAN'),
                    v('P2_TV'),
                    v('P2_EMAIL'),
                    nv('P2_MOBIEL')
                );
                
                insert into docent(
                pers_id,
                soort,
                beschikbaar
                ) values
                (
                    seq_persoon_id.CURRVAL,
                    v('P2_SOORT'),
                    nv('P2_BESCHIKBAAR')
                );
                commit;
            else
                -- UPDATE --
                update persoon
                set
                voornaam = v('P2_VOORNAAM'),
                achternaan = v('P2_ACHTERNAAN'),
                tv = v('P2_TV'),
                email = v('P2_EMAIL'),
                mobiel = v('P2_MOBIEL')
                where id = v_persoonid;
                
                update docent
                set
                soort = v('P2_SOORT'),
                beschikbaar = nv('P2_BESCHIKBAAR')
                where pers_id = v_persoonid;
                
                commit;
        end if;
        exception
            when others then
                -- Exception here...
            raise;
        commit;
    end save_docent;
end pk_tcmapi_docent;
/
    
