use kavalok; 


insert into RobotSKU(created, name,  price, currency, currencyCode, currencySign, currencyText, currencyCentsText, startDate, endDate, specialOffer, robotType_id)
values(now(), 'Raketen Paket 10', 4.99, 2, 'EUR','euroSign', 'euro', 'euroCents', now(), null, false, (select id from RobotType where name='rocket'));

insert into RobotSKU(created, name,  price, currency, currencyCode, currencySign, currencyText, currencyCentsText, startDate, endDate, specialOffer, robotType_id)
values(now(), 'St&auml;rkeres Raketen Paket', 5.99, 2, 'EUR','euroSign', 'euro', 'euroCents', now(), null, false, (select id from RobotType where name='rocket2'));

insert into RobotSKU(created, name,  price, currency, currencyCode, currencySign, currencyText, currencyCentsText, startDate, endDate, specialOffer, robotType_id)
values(now(), 'Verteidigungs Verbesserung', 7.99, 2, 'EUR','euroSign', 'euro', 'euroCents', now(), null, false, (select id from RobotType where name='defencePlus'));

insert into RobotSKU(created, name,  price, currency, currencyCode, currencySign, currencyText, currencyCentsText, startDate, endDate, specialOffer, robotType_id)
values(now(), 'Angriffs Verbesserung', 7.99, 2, 'EUR','euroSign', 'euro', 'euroCents', now(), null, false, (select id from RobotType where name='attackPlus'));

insert into RobotSKU(created, name,  price, currency, currencyCode, currencySign, currencyText, currencyCentsText, startDate, endDate, specialOffer, robotType_id)
values(now(), 'Geschicklichkeits Verbesserung', 5.99, 2, 'EUR','euroSign', 'euro', 'euroCents', now(), null, false, (select id from RobotType where name='allPlus'));

insert into RobotSKU(created, name,  price, currency, currencyCode, currencySign, currencyText, currencyCentsText, startDate, endDate, specialOffer, robotType_id)
values(now(), 'Volles Energie Reperatur Paket', 2.99, 2, 'EUR','euroSign', 'euro', 'euroCents', now(), null, false, (select id from RobotType where name='energyRepair3'));





