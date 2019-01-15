insert into persoon (
    voornaam,
    achternaan,
    tv,
    email,
    mobiel
    ) values
    ('Rene', 'Droftic', 'van', 'rdroftic@live.nl', 555);
    /
    
 -- select * from persoon

insert into cursist(
    pers_id,
    BSN,
    geslacht,
    land,
    fam_pers_id,
    opleiding_land,
    leerprofiel,
    werk_land,
    werk_huidig
    ) values
    (
        1,
        '333bnaa',
        'M',
        'Duitsland',
        null,
        'Straat maker',
        'HBO',
        'Pleinveger',
        'Starrbucks maker'
    );
/

--select * from cursist;
--/

insert into docent(
    pers_id,
    soort,
    beschikbaar
    ) values
    (
        2,
        'Nederlands',
        5
    );



