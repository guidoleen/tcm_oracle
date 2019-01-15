create or replace trigger trg_persoon_id
before insert on persoon
for each row
    when (new.id is null)
    begin
        select seq_persoon_id.nextval
        into :new.id
        from dual;
    end;
/

create or replace trigger trg_les_id
before insert on les
for each row
    when (new.id is null)
    begin
        select seq_les_id
        into :new.id
        from dual;
    end;
/