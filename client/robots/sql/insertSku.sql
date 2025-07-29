use kavalok;

insert into RobotSKU(created, name,  price, currency, currencyCode, currencySign, currencyText, currencyCentsText, startDate, endDate, specialOffer, robotType_id)
values(now(), 'Rocket Pack 5', 2.99, 1, 'USD','usdSign', 'usd', 'usdCents', now(), null, false, (select id from RobotType where name='rocket'));

insert into RobotSKU(created, name,  price, currency, currencyCode, currencySign, currencyText, currencyCentsText, startDate, endDate, specialOffer, robotType_id)
values(now(), 'Rocket Pack 10', 4.99, 1, 'USD','usdSign', 'usd', 'usdCents', now(), null, false, (select id from RobotType where name='rocket'));


insert into RobotSKU(created, name,  price, currency, currencyCode, currencySign, currencyText, currencyCentsText, startDate, endDate, specialOffer, robotType_id)
values(now(), 'Power Rocket Pack', 5.99, 1, 'USD','usdSign', 'usd', 'usdCents', now(), null, false, (select id from RobotType where name='rocket2'));

insert into RobotSKU(created, name,  price, currency, currencyCode, currencySign, currencyText, currencyCentsText, startDate, endDate, specialOffer, robotType_id)
values(now(), 'Defence Upgrade', 7.99, 1, 'USD','usdSign', 'usd', 'usdCents', now(), null, false, (select id from RobotType where name='defencePlus'));

insert into RobotSKU(created, name,  price, currency, currencyCode, currencySign, currencyText, currencyCentsText, startDate, endDate, specialOffer, robotType_id)
values(now(), 'Attack Upgrade', 7.99, 1, 'USD','usdSign', 'usd', 'usdCents', now(), null, false, (select id from RobotType where name='attackPlus'));

insert into RobotSKU(created, name,  price, currency, currencyCode, currencySign, currencyText, currencyCentsText, startDate, endDate, specialOffer, robotType_id)
values(now(), 'Skills Upgrade', 2.99, 1, 'USD','usdSign', 'usd', 'usdCents', now(), null, false, (select id from RobotType where name='allPlus'));

insert into RobotSKU(created, name,  price, currency, currencyCode, currencySign, currencyText, currencyCentsText, startDate, endDate, specialOffer, robotType_id)
values(now(), 'Full Energy Repair Pack', 2.99, 1, 'USD','usdSign', 'usd', 'usdCents', now(), null, false, (select id from RobotType where name='energyRepair3'));

