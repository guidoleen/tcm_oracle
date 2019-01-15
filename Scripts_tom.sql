--drop table error_log cascade constraints;

create table error_log
(datum varchar2(30 char), bron varchar2(50 char), melding varchar2(4000))
/

create table error_log
(datum varchar2(30 char), bron varchar2(50 char), melding varchar2(4000))
/


create table parameters(
  ID               number
 ,parameter        varchar2(140)         not null enable
 ,waarde           varchar2(1000)        not null enable
 ,omschrijving     varchar2(500)
 ,gewijzigd_op     date default sysdate  not null enable
);

alter table parameters add constraint prr_pk primary key (id);
alter table parameters add constraint prr_uk01 unique (parameter);

create sequence prr_seq nocache;

create or replace trigger parameters_briu
 before insert or update on parameters
  for each row
begin
  if
    inserting
  then
    :new.parameter   := upper(:new.parameter);
    :new.id      := prr_seq.nextval;
  end if;

  if
    updating
  then
    :new.parameter   := upper(:new.parameter);
  end if;

  if
    inserting or updating
  then
    :new.gewijzigd_op   := sysdate;
  end if;
end alg_parameters_briu;
/

alter trigger parameters_briu enable;


insert into parameters(parameter, waarde, omschrijving) values ('mail_hostname', 'transfer-solutions.com', 'naam van de mail-host');
insert into parameters(parameter, waarde, omschrijving) values ('mail_portno', '25', 'poortnummer van de mail-host');


create table gebruikers
( id number not null
, naam varchar2(50) not null
, username varchar2(25) not null
, password varchar2(35) not null
, verlopen_op date
);

alter table gebruikers add constraint gbr_pk primary key (id);
alter table gebruikers add constraint gbr_uk01 unique (username);

create sequence gbr_seq nocache;

create or replace trigger gebruikers_briu
 before insert or update on gebruikers
  for each row
begin
  if
    inserting
  then
    :new.id      := gbr_seq.nextval;
  end if;

  if
    inserting or updating
  then
    :new.verlopen_op  := sysdate + 61;  -- is ong 2 maanden, maar moet een parameterwaarde worden?
  end if;
end gebruikers_briu;
/

alter trigger gebruikers_briu enable;


create or replace package tools
is
  -- to log errormessages into table error_log, for debugging
  procedure log_error(p_bron varchar2, p_melding in varchar2);
--
  -- function to retreive parameter-values
  function get_parameter(p_parameter in varchar2)
  return varchar2;
--
  function valideer_email(p_email in varchar2)
  return boolean;
--
procedure stuur_email(v_to        in varchar2
                     ,p_email     in varchar2
                     ,p_onderwerp in varchar2
                     ,v_body      in varchar2
                     );
--
  function custom_hash(p_username in varchar2, p_password in varchar2)
  return varchar2;
--
  function custom_auth (p_username in varchar2, p_password in varchar2)
  return boolean;
--
end tools;
/

create or replace package body TOOLS
is
/*
  MODIFICATION HISTORY:
  WHO            WHEN           WHY
  T. Zegers      11-JAN-2019    Initial creation
  T. Zegers      11-JAN-2019    added proc log_error
  T. Zegers      11-JAN-2019    added func get_parameter
  T. Zegers      11-JAN-2019    added func valideer_email
  T. Zegers      11-JAN-2019    added proc stuur_email
  T. Zegers      11-JAN-2019    added func custom_hash
  T. Zegers      11-JAN-2019    added func custom_auth
*/
--
procedure log_error
   (p_bron varchar2, p_melding in varchar2)
is
  -- to log errormessages into table error_log, for debugging
   pragma autonomous_transaction;
begin
  insert into error_log
  (datum, bron, melding)
  values
  (to_char(sysdate,'yyyy-mm-dd hh24:mi:ss'), p_bron, p_melding);
  commit;
--
--example of usage:
--
--declare
--   v_err         varchar2(250);
--   c_bron        varchar2(40);       -- := functie/procedure-naam
-- etc

--exception
--   when others then
--      v_err := dbms_utility.format_error_stack;
--      tools.log_error(c_bron, v_err);
--end;
end log_error;
--
function get_parameter(
    p_parameter in varchar2  
) return varchar2
is
-- function to retreive parameter-values
  v_err         varchar2(250);
  c_bron        varchar2(40) := 'tools.get_parameter';
--
begin
  for i in (select waarde
              from parameters
             where parameter = p_parameter
           )
  loop
    return i.waarde;
  end loop;
  return null;
exception
  when others then
    v_err := dbms_utility.format_error_stack;
    tools.log_error(c_bron, v_err);
end get_parameter;
--
function valideer_email(p_email in varchar2)
  return boolean
  -- functie die met een regexp controleert of het een correct emailadres is.
is
  v_err         varchar2(250);
  c_bron        varchar2(40) := 'tools.valideer_email';
--
  v_email_check varchar2(1);
begin
  select 'x' 
  into   v_email_check
  from   dual
  where  regexp_like(p_email
                    ,'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$'
                    );
  return true;
exception
  when no_data_found then return false;
  when others then
    v_err := dbms_utility.format_error_stack;
    tools.log_error(c_bron, v_err);
end valideer_email;
--
procedure stuur_email(v_to        in varchar2
                     ,p_email     in varchar2
                     ,p_onderwerp in varchar2
                     ,v_body      in varchar2
                     )
is
  -- procedure die email verstuurt
  v_err         varchar2(250);
  c_bron        varchar2(40) := 'tools.stuur_email';
--
  v_hostname varchar2(140);
  v_portno varchar2(140);
begin
  if valideer_email(p_email)
  then
    v_hostname := tools.get_parameter(p_parameter => 'MAIL_HOSTNAME');
    v_portno   := tools.get_parameter(p_parameter => 'MAIL_PORTNO');
    apex_mail.send(p_to   => v_to
                  ,p_from => p_email
                  ,p_subj => p_onderwerp
                  ,p_body => v_body
                  );
    apex_mail.push_queue(v_hostname, v_portno);
--  else
--    --foutboodschap: opgegeven emailadres is niet correct
  end if;
exception
  when others then
    v_err := dbms_utility.format_error_stack;
    tools.log_error(c_bron, v_err);
end stuur_email;
--
function custom_hash(p_username in varchar2, p_password in varchar2)
return varchar2
is
  -- functie die het password onleesbaar maakt
  v_err         varchar2(250);
  c_bron        varchar2(40) := 'tools.custom_hash';
--
  l_password varchar2(4000);
  l_salt varchar2(4000) := '2CMJY4VNCN4H8CF9589GUF6CTK44TY';
begin
-- This function should be wrapped, as the hash algorhythm is exposed here.
-- You can change the value of l_salt or the method of which to call the
-- DBMS_OBFUSCATION toolkit, but you much reset all of your passwords
-- if you choose to do this.
--
  l_password := utl_raw.cast_to_raw(dbms_obfuscation_toolkit.md5
    (input_string => p_password || substr(l_salt,10,13) || p_username ||
    substr(l_salt, 4,10)));
  return l_password;
exception
  when others then
    v_err := dbms_utility.format_error_stack;
    tools.log_error(c_bron, v_err);
end custom_hash;
--
function custom_auth(p_username in VARCHAR2, p_password in VARCHAR2)
return BOOLEAN
is
  -- functie die (bij inloggen) het wachtwoord van een gebruiker controleert
  v_err         varchar2(250);
  c_bron        varchar2(40) := 'tools.custom_auth';
--
  l_password varchar2(4000);
  l_stored_password varchar2(4000);
  l_expires_on date;
  l_count number;
begin
  -- First, check to see if the user is in the user table
  select count(*) into l_count from gebruikers where username = p_username;
  if l_count > 0 then
    -- First, we fetch the stored hashed password & expire date
    select password, verlopen_op into l_stored_password, l_expires_on
      from gebruikers where username = p_username;
--  
    -- Next, we check to see if the user's account is expired
    -- If it is, return FALSE
    if l_expires_on > sysdate or l_expires_on is null then
      -- If the account is not expired, we have to apply the custom hash
      -- function to the password
      l_password := custom_hash(p_username, p_password);
--  
      -- Finally, we compare them to see if they are the same and return
      -- either TRUE or FALSE
      if l_password = l_stored_password then
        return true;
      else
        return false;
      end if;
    else
      return false;
    end if;
  else
    -- The username provided is not in the 'gebruikers' table
    return false;
  end if;
exception
  when others then
    v_err := dbms_utility.format_error_stack;
    tools.log_error(c_bron, v_err);
end;
--
end tools;
/
