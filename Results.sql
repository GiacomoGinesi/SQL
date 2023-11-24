/* eta dei clienti*/
create temporary table eta(
SELECT id_cliente,round(datediff(current_date, data_nascita)/365,0) as eta
from cliente)



/*Numero di transazioni in uscita su tutti i conti*/
create temporary table transazioni_uscita (
select id_cliente, count(data) as transazioni_uscita
from (select trans.data, trans.id_conto 
	  from transazioni trans inner join tipo_transazione tipotrans
	  on (trans.id_tipo_trans = tipotrans.id_tipo_transazione) 
      where segno = '-') as subquery
                       inner join conto 
                       on (subquery.id_conto = conto.id_conto)
group by id_cliente
order by id_cliente asc
)



/*Numero di transazioni in entrata su tutti i conti*/
create temporary table transazioni_entrata (
select id_cliente, count(data) as transazioni_entrata
from (select trans.data, trans.id_conto 
	  from transazioni trans inner join tipo_transazione tipotrans
	  on (trans.id_tipo_trans = tipotrans.id_tipo_transazione) 
      where segno = '+') as subquery
                       inner join conto 
                       on (subquery.id_conto = conto.id_conto)
group by id_cliente
order by id_cliente asc



/*Importo transato in uscita su tutti i conti*/
create temporary table importo_transato_in_uscita (
select id_cliente, round(sum(importo),2)  as importo_transato_in_uscita
from (select importo,trans.id_conto 
	        from transazioni trans inner join tipo_transazione tipotrans
			on trans.id_tipo_trans =  tipotrans.id_tipo_transazione
            where tipotrans.segno = '-') as subquery
						     inner join conto
						     on (subquery.id_conto = conto.id_conto)
group by id_cliente
order by id_cliente asc
)



/*Importo transato in entrata su tutti i conti*/
create temporary table importo_transato_in_entrata (
select id_cliente, round(sum(importo),2)  as importo_transato_in_entrata
from (select importo,trans.id_conto 
	        from transazioni trans inner join tipo_transazione tipotrans
			on trans.id_tipo_trans =  tipotrans.id_tipo_transazione
            where tipotrans.segno = '+') as subquery
						     inner join conto
						     on (subquery.id_conto = conto.id_conto)
group by id_cliente
order by id_cliente asc
)


/*Numero totale di conti posseduti*/
create temporary table conti_posseduti(
select id_cliente, count(id_conto) as conti_posseduti
from conto
group by id_cliente
)


/*Numero di conti posseduti per tipologia (un indicatore per tipo)*/
create temporary table tipologia_conti_posseduti (
select conto.id_cliente,
count(case when conto.id_tipo_conto = 0 then conto.id_cliente else null end) as conti_base_posseduti,
count(case when conto.id_tipo_conto = 1 then conto.id_cliente else null end) as conti_business_posseduti,
count(case when conto.id_tipo_conto = 2 then conto.id_cliente else null end) as conti_privati_posseduti,
count(case when conto.id_tipo_conto = 3 then conto.id_cliente else null end) as conti_famiglie_posseduti
              from conto left join cliente 
              on (conto.id_cliente = cliente.id_cliente)
group by conto.id_cliente

)


/*Numero di transazioni in uscita per tipologia (un indicatore per tipo)*/
create temporary table numero_transazioni_uscita_tipologia (
select conto.id_cliente,
count(case when transazioni_uscita.transazioni_negative = 'Acquisto su Amazon' then conto.id_cliente else null end) as n_transazioni_Acquisto_su_Amazon,
count(case when transazioni_uscita.transazioni_negative = 'Rata mutuo' then conto.id_cliente else null end) as n_transazioni_Rata_mutuo,
count(case when transazioni_uscita.transazioni_negative = 'Hotel' then conto.id_cliente else null end) as n_transazioni_Hotel,
count(case when transazioni_uscita.transazioni_negative = 'Biglietto aereo' then conto.id_cliente else null end) as n_transazioni_Biglietto_aereo,
count(case when transazioni_uscita.transazioni_negative = 'Supermercato' then conto.id_cliente else null end) as n_transazioni_Supermercato
from conto left join (select id_conto, desc_tipo_trans as transazioni_negative
               from tipo_transazione join transazioni 
			   on (tipo_transazione.id_tipo_transazione = transazioni.id_tipo_trans)
               where segno='-') transazioni_uscita on (conto.id_conto = transazioni_uscita.id_conto)
group by conto.id_cliente
)




/*Numero di transazioni in entrata per tipologia (un indicatore per tipo)*/
create temporary table numero_transazioni_entrata_tipologia (
select conto.id_cliente,
count(case when transazioni_entrata.transazioni_positive = 'Stipendio' then conto.id_cliente else null end) as n_transazioni_Stipendio,
count(case when transazioni_entrata.transazioni_positive = 'Pensione' then conto.id_cliente else null end) as n_transazioni_Pensione,
count(case when transazioni_entrata.transazioni_positive = 'Dividendi' then conto.id_cliente else null end) as n_transazioni_Dividendi
from conto left join (select id_conto, desc_tipo_trans as transazioni_positive
               from tipo_transazione join transazioni 
			   on (tipo_transazione.id_tipo_transazione = transazioni.id_tipo_trans)
               where segno='+') transazioni_entrata on (conto.id_conto = transazioni_entrata.id_conto)
group by conto.id_cliente
)



/*Importo transato in uscita per tipologia di conto (un indicatore per tipo)*/
create temporary table importo_uscita_tipologia(
select conto.id_cliente,
round(sum(case when importo_uscita.transazioni_negative='Acquisto su Amazon' then importo else 0 end),2) as importo_Acquisto_su_Amazon,
round(sum(case when importo_uscita.transazioni_negative='Rata mutuo' then importo else 0 end),2) as importo_Rata_mutuo,
round(sum(case when importo_uscita.transazioni_negative='Hotel' then importo else 0 end),2) as importo_Hotel,
round(sum(case when importo_uscita.transazioni_negative='Biglietto aereo' then importo else 0 end),2) as importo_Biglietto_aereo,
round(sum(case when importo_uscita.transazioni_negative='Supermercato' then importo else 0 end),2) as importo_Supermercato
            from conto left join (select id_conto, desc_tipo_trans as transazioni_negative, importo
                                  from tipo_transazione inner join transazioni 
                                  on (tipo_transazione.id_tipo_transazione = transazioni.id_tipo_trans)
							      where segno='-') as importo_uscita on (conto.id_conto = importo_uscita.id_conto)
group by conto.id_cliente
)




/*Importo transato in entrata per tipologia di conto (un indicatore per tipo)*/
create temporary table importo_entrata_tipologia (
select conto.id_cliente,
round(sum(case when importo_entrata.transazioni_positive='Stipendio' then importo else 0 end),2) as importo_Stipendio,
round(sum(case when importo_entrata.transazioni_positive='Pensione' then importo else 0 end),2) as importo_Pensione,
round(sum(case when importo_entrata.transazioni_positive='Dividendi' then importo else 0 end),2) as importo_Dividendi
            from conto left join (select id_conto, desc_tipo_trans as transazioni_positive, importo
                                  from tipo_transazione inner join transazioni 
                                  on (tipo_transazione.id_tipo_transazione = transazioni.id_tipo_trans)
							      where segno = '+') as importo_entrata on (conto.id_conto = importo_entrata.id_conto)
group by conto.id_cliente
)



/*Creazione tabella finale*/
create table banca.tabella_denormalizzata as
select eta.id_cliente, eta, transazioni_uscita, transazioni_entrata, importo_transato_in_uscita, importo_transato_in_entrata, conti_posseduti, conti_base_posseduti, conti_business_posseduti, conti_privati_posseduti, conti_famiglie_posseduti, n_transazioni_Acquisto_su_Amazon, n_transazioni_Rata_mutuo, n_transazioni_Hotel, n_transazioni_Biglietto_aereo, n_transazioni_Supermercato, n_transazioni_Stipendio, n_transazioni_Pensione, n_transazioni_Dividendi,importo_Acquisto_su_Amazon, importo_Rata_mutuo, importo_Hotel, importo_Biglietto_aereo, importo_Supermercato, importo_Stipendio, importo_Pensione, importo_Dividendi
from eta left join transazioni_uscita on (eta.id_cliente = transazioni_uscita.id_cliente)
left join transazioni_entrata on (eta.id_cliente = transazioni_entrata.id_cliente)
left join importo_transato_in_uscita on (eta.id_cliente = importo_transato_in_uscita.id_cliente)
left join importo_transato_in_entrata on (eta.id_cliente = importo_transato_in_entrata.id_cliente)
left join conti_posseduti on (eta.id_cliente = conti_posseduti.id_cliente)
left join tipologia_conti_posseduti on (eta.id_cliente = tipologia_conti_posseduti.id_cliente)
left join numero_transazioni_uscita_tipologia on (eta.id_cliente = numero_transazioni_uscita_tipologia.id_cliente)
left join numero_transazioni_entrata_tipologia on (eta.id_cliente = numero_transazioni_entrata_tipologia.id_cliente)
left join importo_uscita_tipologia on (eta.id_cliente = importo_uscita_tipologia.id_cliente)
left join importo_entrata_tipologia on (eta.id_cliente = importo_entrata_tipologia.id_cliente)
