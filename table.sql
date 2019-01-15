create table persoon(
    id number,
    voornaam varchar2(48) not null,
    achternaan varchar2(48) not null,
    tv varchar(8),
    email varchar(148) not null,
    mobiel number
)
/
create table docent(
    pers_id number,
    soort varchar2(48),
    beschikbaar number
)
/
create table cursist(
    pers_id number,
    BSN varchar2(48),
    geslacht varchar2(1) not null,
    land varchar(96),
    fam_pers_id number,
    opleiding_land varchar2(148),
    leerprofiel varchar2(4),
    werk_land varchar2(48),
    werk_huidig varchar2(48)
)
/
create table les(
    id number,
    docent_id number not null,
    datum date not null,
    end_datum_duo date,
    start_tijd TIMESTAMP,
    end_tijd TIMESTAMP,
    module_id number
)
/
create table deelname(
    les_id number not null,
    curs_id number not null,
    aanwezig varchar2(1) not null
)
/
create table foto(
    id number,
    pers_id number,
    image blob,
    image_name varchar2(128),
    image_mimetype varchar2(128),
    image_lastupdated date
)
/