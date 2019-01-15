-- Persoon
alter table persoon
add constraint pk_pers_id
    primary key(id);
    
alter table persoon
add constraint un_pers_email
    unique (email);
    
-- Cursist
alter table cursist
add constraint fk_curs_pers_id
    foreign key(pers_id) references persoon(id);
    
--alter table cursist
--add constraint pk_cursid
--    primary key(pers_id);
--    
--alter table cursist
--drop constraint pk_curs_id;
    
alter table cursist
add constraint ck_curs_geslacht
    check (geslacht = 'M' or geslacht = 'V');
    
-- Les
alter table les
add constraint pk_les_id
    primary key(id);
    

-- Deelname
alter table deelname
add constraint fk_deeln_les
    foreign key(les_id) references les(id);

alter table deelname
add constraint fk_deeln_pers
    foreign key(curs_id) references cursist(pers_id);
    
alter table deelname
add constraint pk_deeln_id
    primary key(les_id, curs_id);
    
-- Foto
alter table foto
add constraint fk_pers_id
    foreign key(pers_id) references persoon(id);