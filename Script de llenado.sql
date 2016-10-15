DROP PROCEDURE IF EXISTS newPlan;
DELIMITER //
CREATE PROCEDURE newPlan(pName varchar(60), pDescription varchar(140), pPeriodicity varchar(40), pAmount int, pMinTime int, pMaxTime int, pPrice decimal(14,4), pUrlPlan varchar(180), pArea varchar(30))
BEGIN
  DECLARE idPeriodicity int;
  DECLARE idArea int;
  DECLARE lastPlanId int;

  SELECT idPeriodicidad FROM periodicidades WHERE nombre = pPeriodicity INTO idPeriodicity;
  SELECT ar.idArea FROM areas ar WHERE ar.nombre = pArea INTO idArea;
  
  INSERT INTO planes(nombre, descripcion, idPeriodicidad, cantidad, tiempoMinimo, tiempoMaximo, precioActual, URLPlan, userName, ComputerName, checksum)
  VALUES(pName, pDescription, idPeriodicity, pAmount, pMinTime, pMaxTime, pPrice, pUrlPlan, user(), getComputerName(), SHA1(CONCAT(pName, pDescription, idPeriodicity, pAmount, pMinTime, pMaxTime, pPrice)));

  SELECT idPlan FROM planes ORDER BY idPlan DESC LIMIT 1 INTO lastPlanId;

  INSERT INTO PlanesXAreas(idPlan, idArea)
  VALUES(lastPlanId, idArea);
END //
DELIMITER ;


DROP PROCEDURE IF EXISTS newExchangeRate;
DELIMITER //
CREATE PROCEDURE newExchangeRate(pOriginCoin varchar(30), pDestinyCoin varchar(30), pNewExchangeRateValue float)
BEGIN
  DECLARE idOriginCoin int;
  DECLARE idDestinyCoin int;
  DECLARE idActualExchangeRate int;
  DECLARE idOldExchangeRate int;

  SELECT idMoneda FROM monedas WHERE acronimo = pOriginCoin INTO idOriginCoin;
  SELECT idMoneda FROM monedas WHERE acronimo = pDestinyCoin INTO idDestinyCoin;
  SELECT idTasaCambio FROM tasasDeCambio WHERE (idMonedaOrigen = idOriginCoin) AND 
                         (idMonedaDestino = idDestinyCoin) AND 
                         (Actual = 1) INTO idActualExchangeRate;

  UPDATE tasasDeCambio SET Actual = 0 WHERE idTasaCambio = idActualExchangeRate;
  UPDATE tasasDeCambio SET FechaVigencia = NOW() WHERE idTasaCambio = idActualExchangeRate;
    
  IF (pNewExchangeRateValue NOT IN (SELECT ValorTasaCambio FROM tasasDeCambio WHERE idMonedaOrigen = idOriginCoin AND idMonedaDestino = idDestinyCoin)) THEN
    INSERT INTO tasasDeCambio(idMonedaOrigen, idMonedaDestino, ValorTasaCambio, checksum, userName, ComputerName)
    VALUES (idOriginCoin, idDestinyCoin, pNewExchangeRateValue, SHA1(CONCAT(pOriginCoin, pDestinyCoin, pNewExchangeRateValue)), user(), getComputerName());
  ELSE 
    SELECT idTasaCambio FROM tasasDeCambio WHERE (idMonedaOrigen = idOriginCoin) AND (idMonedaDestino = idDestinyCoin) AND (ValorTasaCambio = pNewExchangeRateValue) INTO idOldExchangeRate;

    UPDATE tasasDeCambio SET actual = 1 WHERE idTasaCambio = idOldExchangeRate;
    UPDATE tasasDeCambio SET FechaVigencia = "9999-12-31" WHERE idTasaCambio = idOldExchangeRate;     
  END IF;
END //
DELIMITER ;


DROP FUNCTION IF EXISTS getComputerName;
DELIMITER //
CREATE FUNCTION getComputerName() RETURNS VARCHAR(64)
DETERMINISTIC
BEGIN
    DECLARE local_hostname VARCHAR(64);
    SELECT variable_value INTO local_hostname
    FROM information_schema.global_variables
    WHERE variable_name = 'hostname';
    RETURN local_hostname;
END //
DELIMITER ;

drop FUNCTION if EXISTS getIdPaymentType;
delimiter //
CREATE FUNCTION getIdPaymentType(pPaymentType varchar(50))RETURNS int
BEGIN
  declare idPaymenType int;
  SELECT idTipoPago from tiposDePago where nombre = pPaymentType into idPaymenType;
  return idPaymenType;
end //
delimiter ;

drop FUNCTION if EXISTS getIdPaymentName;
delimiter //
CREATE FUNCTION getIdPaymentName(pPaymentName varchar(50))RETURNS int
BEGIN
  declare idPaymentName int;
  SELECT idNombre from NombreInformacionPago where nombre = pPaymentName into idPaymentName;
  return idPaymentName;
end //
delimiter ;

insert into NombreInformacionPago (nombre) 
values 
("Card number"),("Expiration month"),("Expiration date"),("Card Security Code"),("Name on Card"),
("Paypal account");

insert into tiposDePago (nombre) 
values ("Debit card"), ("Credit card"), ("Paypal");

drop procedure IF exists PaymentInformation;
delimiter //
create procedure PaymentInformation()
begin
  declare paymentTypeLenght int;
  declare paymentType VARCHAR(40);
  declare cont int;
  set cont = 1;
  SELECT count(*) FROM tiposDePago into paymentTypeLenght;
  while (cont <= paymentTypeLenght) do
    SELECT nombre FROM tiposDePago where idTipoPago = cont into paymentType;
    IF(paymentType like "%card%") THEN
      insert into InformacionTipoPago (idNombre, idTipoPago)
      values 
      (getIdPaymentName("Card number"),cont),
      (getIdPaymentName("Expiration month"),cont),
      (getIdPaymentName("Expiration date"),cont),
      (getIdPaymentName("Card Security Code"),cont),
      (getIdPaymentName("Name on Card"),cont);
    ELSEIF(paymentType = "Paypal") THEN
      insert into InformacionTipoPago (idNombre, idTipoPago)
      values (getIdPaymentName("Paypal account"),cont);
    END IF;
    set cont = cont + 1;
  END while;
END //
delimiter ;
call PaymentInformation();

insert into roles (nombre) values ("Designer"),("Buyer"),("Admin");
insert into paises (nombre) values ("Costa Rica"),("España"),("Italia"),("Brasil"),("Alemania"),("Panama"),("Ecuador"),("Rusia"),("Nigeria"),("Francia"),("Chile"),("Peru"),("Argentina"),("Estados Unidos"),("Canada"),("Mexico"),("Iran"),("Colombia"),("Australia"),("Bolivia"),("Cuba"),("Egipto"),("Grecia"),("India");
insert into areas (nombre,requierepago,requiereusuario) values ("Publico",0,0),("Privado",0,1),("Premium",1,1);
insert into tiposdeDiseño (nombre) values ("Estacion Climatica"), ("Genero"), ("Rango Edad");
insert into CaracteristicasdeDiseño (nombre,display,idTipo) values ("Ropa de otoño","Otoño",1),("Ropa de primavera","Primavera",1),("Ropa de verano","Verano",1),("Ropa de invierno","Invierno",1),("Ropa de hombre","Hombre",2),("Ropa de mujer","Mujer",2),("Ropa entre 14-20","14-20",3),("Ropa entre 5-10","5-10",3),("Ropa entre 20-30","14-20",3),("Ropa entre 2-5","5-10",3); 
insert into periodicidades (nombre) values ("Anual"),("Mensual"),("Diario");  
insert into monedas (acronimo,nombre,simbolo,monedaDefault,checksum) 
values 
("CRC","Colon costarricense","₡",0,SHA1(CONCAT("CRC","Colon costarricense","₡",0))),
("USD","Dolar estadounidense","$",1,SHA1(CONCAT("USD","Dolar estadounidense","$",1))),
("EUR","Euro","€",0,SHA1(CONCAT("EUR","Euro","€",0))),
("JPY","Yen japones","¥",0,SHA1(CONCAT("JPY","Yen japones","¥",0))),
("GBP","Libra esterlina","£",0,SHA1(CONCAT("GBP","Libra esterlina","£",0)));

call newExchangeRate("USD","USD",1);

call newExchangeRate("CRC","USD",1/545.52);
call newExchangeRate("USD","CRC",545.52);

call newExchangeRate("EUR","USD",1.29);
call newExchangeRate("USD","EUR",1/1.29);

call newExchangeRate("JPY","USD",0.0091800);
call newExchangeRate("USD","JPY",1/0.0091800);

call newExchangeRate("GBP","USD",1.6348);
call newExchangeRate("USD","GBP",1/1.6348);

values (1,2,545.38,CURRENT_TIMESTAMP(),CURRENT_TIMESTAMP(),1,"jnbyutvrc5xe4e5rctvybnubyuvt7","Farcem11","FabianPC");
insert into planes (nombre,descripcion,idperiodicidad,cantidad,tiempoMinimo,TiempoMaximo,precioActual,username,computername,checksum) 
values ("Plan Default","Este es el plan default para los usuarios nuevos",1,0,0,0,0,"Farcem11","FabianPC",sha1(CONCAT("Plan Default",1,0,0,0,0)));
call newPlan("Plan Premium", "Este plan permite ver y publicar diseños premium a los usuarios", "Diario", 1, 2, 4, 2000, NULL, "Premium");
insert into severidad (Nombre) values('Muy alta'),('Alta'),('Media'),('Baja'),('Muy baja');
insert into tipoeventos(nombre,idSeveridad) values('Insertar pago',3),('Ingreso de datos',1),('Modificacion o borrado de datos',4),('Modificacion o borrado de pagos',2),('Modificacion o borrado de la base de datos',5);
insert into MediosdeContacto(Tipo) values('Correo electronico'),('Telefono'),('Facebook'),('Skype'),('Twitter');
insert into EstadoDeSubastas(Nombre)values('Disponible'),('No disponible'),('Anulada'),('Finalizada'),("Adjudicada");
insert into EstadoDeDiseños(Nombre)values('En subasta'),("Sin subastar"),('Vendido');
insert into tiposDeCobro (nombre) values ("Automatic"),("Manual");
insert into estadoNotificaciones (nombre) values ("No leido"),("Leido"),("Hide");
insert into tipoNotificaciones(nombre) values ("Offer"), ("Final offer");
insert into catalogoPuntuaciones (valor,label,descripcion) 
values
#(0,"https://raw.githubusercontent.com/Farcem11/Rate-stars/master/Rate/0%20stars.png","No review"),
(1,"https://raw.githubusercontent.com/Farcem11/Rate-stars/master/Rate/1%20star.png","Very bad"),
(2,"https://raw.githubusercontent.com/Farcem11/Rate-stars/master/Rate/2%20stars.png","Bad"),
(3,"https://raw.githubusercontent.com/Farcem11/Rate-stars/master/Rate/3%20stars.png","Regular"),
(4,"https://raw.githubusercontent.com/Farcem11/Rate-stars/master/Rate/4%20stars.png","Good"),
(5,"https://raw.githubusercontent.com/Farcem11/Rate-stars/master/Rate/5%20stars.png","Excelent");

DROP FUNCTION getLastUserId;
DELIMITER //
CREATE FUNCTION getLastUserId() RETURNS int
BEGIN
  DECLARE lastIdUser int;
  SELECT idUsuario FROM usuarios ORDER BY idUsuario DESC LIMIT 1 INTO lastIdUser;
  RETURN lastIdUser;
END //
DELIMITER ;


DROP PROCEDURE signUser;
DELIMITER //
CREATE PROCEDURE signUser(pName varchar(50), pFirstName varchar(50), pLastName varchar(50), pBirthday date, pPassword varbinary(500), pEmail varchar(50), pPais varchar(50))
BEGIN
  DECLARE idUserPais int;
  DECLARE idPlanDefault int;
  DECLARE idTipoDeEvento int;

  SELECT idPais FROM paises WHERE nombre = pPais INTO idUserPais;
  SELECT idPlan FROM planes WHERE nombre = "Plan Default" INTO idPlanDefault;
  SELECT idTipoEvento FROM  TipoEventos WHERE nombre = "Ingreso de datos" INTO idTipoDeEvento;

  INSERT INTO usuarios (nombre, apellido1, apellido2, fechaNacimiento, password, email, fechaIngreso, idPais, token)
  VALUES (pName, pFirstName, pLastName, pBirthday, sha1(pPassword), pEmail, NOW(), idUserPais, SHA1(CONCAT(pName, pFirstName, pLastName, pBirthday, pPassword, pEmail, NOW(), pPais)));

  INSERT INTO planesXUsuarios (idPlan, idUsuario, idTipoCobro, idTipoPago, idMoneda,FechaCreacion)
  VALUES (idPlanDefault, getLastUserId(), 1, 1, 1, NOW());

  INSERT INTO bitacoraEventos (idTipoEvento, descripcion, Fecha, userName, ComputerName, checksum)
  VALUES (idTipoDeEvento, CONCAT("Nuevo ingreso de usuario, con id: ", getLastUserId()," a la base de datos Fashion"), NOW(), "Farcem11","Fabian-PC", SHA1(CONCAT(idTipoDeEvento,getLastUserId())));
END //
DELIMITER ;

drop procedure setPlanDefault;
delimiter //
create procedure setPlanDefault()
begin
  declare idPlanDefault int;
  declare idAreaPublica int;
  select idPlan from planes where nombre = "Plan default" into idPlanDefault;
  select idArea from areas where nombre = "Privado" into idAreaPublica;
  insert into PlanesXAreas (idPlan, IdArea)
  values (idPlanDefault, idAreaPublica);
end //
delimiter ;
call setPlanDefault();

delimiter //
create procedure logins(num int)
begin
  declare cont int;
  set cont = 0;
  while cont < num do
    insert into inicioSesiones (sesion) values (UUID());
    set cont = cont + 1;
  end while;
end //
delimiter ;

-- Crea una tabla temporal de usuarios
CREATE TEMPORARY TABLE temporal_tabla
(
id int(11) NOT NULL auto_increment,
nombrePersona varchar(50),
apellidos1 varchar(50),
apellidos2 varchar(50),
fechaNacimiento datetime,
fechaIngreso datetime,
PRIMARY KEY (id),
UNIQUE KEY (id)
);

-- almacena los datos del txt en una tabla temporal
LOAD DATA lOCAL INFILE "c:/Fashion/DatosUsuarios.txt"
INTO TABLE temporal_tabla
FIELDS TERMINATED BY ","
LINES TERMINATED BY "\n"
(nombrePersona,apellidos1,apellidos2,fechaNacimiento,FechaIngreso);

-- Procedimiento para generar 100 usuarios
drop procedure usuariosLlenado;
delimiter //
create procedure usuariosLlenado(cant int)
begin
  declare nombreRandom varchar(50);
  declare apellido1Random varchar(50);
  declare apellido2Random varchar(50);
  declare emailRandom varchar(50);
  declare nacimientoRandom datetime;
  declare passwords varbinary(500);
  declare paisRandom varchar(50);
  declare cont int;
  set cont = 0;
  while (cont < cant) do
    select nombrePersona from temporal_tabla order by rand() limit 1 into nombreRandom;
    select apellidos1 from temporal_tabla order by rand() limit 1 into apellido1Random;
    select apellidos2 from temporal_tabla order by rand() limit 1 into apellido2Random;
    select fechaNacimiento from temporal_tabla order by rand() limit 1 into nacimientoRandom;
    select nombre from paises order by rand() limit 1 into paisRandom;
    SET emailRandom=(select ELT(1+FLOOR(RAND() * 3),'@itcr.ac.cr','@yahoo.com','@gmail.com','@hotmail.com'));
    SET passwords=CONCAT(nombreRandom,apellido1Random);
    call signUser(nombreRandom,apellido1Random,apellido2Random,nacimientoRandom,passwords,emailRandom,paisRandom);
    set cont = cont + 1;
  end while;
  call logins(cant);
end //
delimiter ;
call usuariosLlenado(100);

-- Crea una tabla temporal de usuarios
CREATE TEMPORARY TABLE temporal4_tabla
(
id int(11) NOT NULL auto_increment,
Titulo varchar(40),
Descripcion  varchar(320),
PRIMARY KEY (id),
UNIQUE KEY (id)
);

-- almacena los datos del txt en una tabla temporal
LOAD DATA lOCAL INFILE "c:/Fashion/Disenos.txt"
INTO TABLE temporal4_tabla
FIELDS TERMINATED BY ","
LINES TERMINATED BY "\r"
(Titulo,Descripcion);

drop procedure DiseñosLlenados;
delimiter //
create procedure DiseñosLlenados()
begin
  declare usuarioRandom int;
  declare ingresoRandom datetime;
  declare TituloRandom varchar(40);
  declare DescripcionRandom varchar(320);
  declare cantDiseños int;
  declare contDiseños int;
  declare idNotInOffer int;
  declare cont int;
  declare num int;
  set cont = 0;
  select count(*) from usuarios into num;
  select idEstado from EstadoDeDiseños where nombre = "Sin subastar" into idNotInOffer;
  while (cont < num) DO
    set cantDiseños = FLOOR(1 + rand()*3);
    select idUsuario from usuarios where cantidadDiseños = 0 order by rand() limit 1 into usuarioRandom;
    set contDiseños = 0;
    while (contDiseños < cantDiseños) DO
      select Titulo from temporal4_tabla order by rand() limit 1 into TituloRandom;
      select Descripcion from temporal4_tabla order by rand() limit 1 into DescripcionRandom;
      select FechaIngreso from usuarios where idUsuario = usuarioRandom into ingresoRandom;
      insert into diseños(idUsuario,Titulo,Descripcion,FechaDeCreacion,idEstado)
      values (usuarioRandom,TituloRandom,DescripcionRandom,DATE_ADD(ingresoRandom,INTERVAL 5 DAY),idNotInOffer);
      update usuarios set cantidadDiseños = cantidadDiseños + 1 where idUsuario = usuarioRandom;
      set contDiseños = contDiseños + 1;
    END while;
    set cont = cont + 1; 
  end while;

end //
delimiter ;
call DiseñosLlenados();


drop procedure Caracteristicas;
delimiter //
create procedure Caracteristicas()
begin
  declare cantidadDiseños int;
  declare cont int;
  declare diseñoRandom int;
  declare CaracteristicaRandom int;
  set cont = 0;
  select count(*) from diseños into cantidadDiseños;
  set cantidadDiseños = cantidadDiseños * 2;
  while (cont < cantidadDiseños) do
    select idDiseño from diseños order by rand() limit 1 into diseñoRandom;
    select idCaracteristica from CaracteristicasdeDiseño order by rand() limit 1 into CaracteristicaRandom;
    insert IGNORE into diseñosXCaracteristicas (idDiseño, idCaracteristica)
    values (diseñoRandom,CaracteristicaRandom);

    set cont = cont + 1;
  end while;
end //
delimiter ;
call Caracteristicas();

drop procedure calificaciones;
delimiter //
create procedure calificaciones()
begin
  declare usuarioRandom int;
  declare diseñoRandom int;
  declare sesionRandom int;
  declare ingresoRandom date;
  declare cantPuntuacion int;
  declare contPuntuacion int;
  declare cantDiseños int;
  declare cont int;
  declare Puntuacion int;
  declare totalPuntos int;
  declare puntos int;
  declare TituloCom varchar(80);
  declare DescripcionCom varchar(80);
  declare diaReview date;
  set DescripcionCom = "Campo para una descripcion del diseño";
  set cont = 1;
  select count(*) from diseños into cantDiseños;
  
  while (cont <= cantDiseños) DO
    set cantPuntuacion = FLOOR(2 + rand()*4);
    select idDiseño from diseños where PromedioPuntos = 0 order by rand() limit 1 into diseñoRandom;
    set contPuntuacion = 0;
    set totalPuntos = 0;
    while (contPuntuacion < cantPuntuacion) DO
      select idUsuario from usuarios order by rand() limit 1 into usuarioRandom;
      select idSesion from inicioSesiones order by rand() limit 1 into sesionRandom;
      select FechaIngreso from usuarios where idUsuario = usuarioRandom into ingresoRandom;

      IF (cont < cantDiseños * 0.70) THEN
        select idPuntuacion from catalogoPuntuaciones where valor between 3 AND 5 order by rand() limit 1 into Puntuacion;
      ELSE
        select idPuntuacion from catalogoPuntuaciones where valor between 1 AND 2 order by rand() limit 1 into Puntuacion;
      END IF;
      
      set diaReview = DATE_ADD(ingresoRandom,INTERVAL 25 DAY);
      select descripcion from catalogoPuntuaciones where idPuntuacion = Puntuacion into TituloCom;
      
      insert into registroReseñas(idUsuario,idDiseño,idSesion,titulo,descripcion,idPuntuacion,FechaCreacion)
      values (usuarioRandom,diseñoRandom,sesionRandom,TituloCom,DescripcionCom,Puntuacion,diaReview);

      set contPuntuacion = contPuntuacion + 1;
      select valor from catalogoPuntuaciones where idPuntuacion = Puntuacion into puntos;
      set totalPuntos = totalPuntos + puntos;
    END while;
    update diseños set PromedioPuntos = totalPuntos/cantPuntuacion where idDiseño = diseñoRandom;
    set cont = cont + 1; 
  end while;

end //
delimiter ;
call calificaciones();


drop procedure roles;
delimiter //
create procedure roles()
begin
  declare contInicio int;
  declare contFin int;
  declare rol int;
  declare usuarioRandom int;

  select idUsuario from usuarios order by idUsuario limit 1 into contInicio;
  select idUsuario from usuarios order by idUsuario desc limit 1  into contFin;
  select idRol from roles where nombre = "Designer" into rol;

  while (contInicio < contFin) DO
    insert into UsuariosXRoles (idUsuario,idRol)
    values (contInicio,rol);
    set contInicio = contInicio + 1;
  end while;

  set contInicio = 0;
  select idRol from roles where nombre = "Buyer" into rol;
  while (contInicio < 10) do
    select idUsuario from usuarios order by rand() limit 1 into usuarioRandom;
    insert ignore into UsuariosXRoles(idUsuario,idRol)
    values (usuarioRandom,rol);
    set contInicio = contInicio + 1;
  end while;
end //
delimiter ;
call roles();


CREATE TEMPORARY TABLE URLS
(
url varchar(140),
PRIMARY KEY (url),
UNIQUE KEY (url)
);

insert into urls (url)
values
("http://t0.gstatic.com/images?q=tbn:ANd9GcT7YofHBiQbCTdn556GDGs9gk0D0nPCyEkyyb1vzZRgeRJgs2mV9Q"),
("http://3.bp.blogspot.com/-9EMvz_YdlqQ/USIgsLSs-zI/AAAAAAAAADg/9ZxCvyPUP9c/s1600/bershka.jpg"),
("http://estasdemoda.com/wp-content/uploads/2012/07/moda-bershka-4.jpg"),
("http://es.globedia.com/imagenes/noticias/2012/6/4/moda-juvenil-cavalli-2012_1_1242807.jpg"),
("http://2.bp.blogspot.com/-p2tPnK0q7mg/TjA04VYyQHI/AAAAAAAABvo/PSLp9kf6B7E/s400/Moda%2Bjuvenil%2B2011%2Bque%2Bte%2Benamora%2B5.JPG"),
("http://3.bp.blogspot.com/-Vt_UBxWL5n8/TZJJbGRNbpI/AAAAAAAAAAQ/CwTDO3iSw6A/s1600/Moda-juvenil-oto%25C3%25B1o.jpg"),
("http://1.bp.blogspot.com/-803B5UG55Q8/TZIaUup9WcI/AAAAAAAAAAQ/ifTJk1ayYQA/s1600/Miley+Clothing+Line23.jpg"),
("http://m1.paperblog.com/i/236/2365426/moda-juvenil-2014-fotos-L-_H5A60.jpeg"),
("http://www.tendencias-moda.com/wp-content/uploads/2012/12/Pull-and-Bear-moda-juvenil-1.jpg"),
("http://1.bp.blogspot.com/-HHCgvV3Sfkc/UhNIMPd2d_I/AAAAAAAAs_w/3buYnUC3skE/s1600/muaa+verano+2014+moda+juvenil.jpg"),
("http://1.bp.blogspot.com/-7Jqmdlu-mHo/UweVfamFYVI/AAAAAAAACSU/YS5IY1Xa15g/s1600/NEON+A+LA+MODA.jpg"),
("http://www.solostocks.com/img/corsets-moda-juvenil-7578698z1.jpg"),
("http://blusasdemoda.info/wp-content/uploads/2012/09/moda-juvenil-en-blusas-para-antros-2.jpg"),
("http://entrecalzones.com/wp-content/uploads/2012/02/Moda-juvenil-2012-1.jpg"),
("http://4.bp.blogspot.com/-fHKpO9JjqS0/Tr-DRK2rFII/AAAAAAAAg74/tFX8s0pt62Q/s1600/bershka2.jpg"),
("http://directoriofemenino.com/wp-content/uploads/2011/11/moda-juvenil-2.jpg"),
("http://images.evisos.com.co/2012/06/08/ropa-juvenil-actual-fresca-y-de-moda-en_8c84d9960_3.jpg"),
("http://directoriofemenino.com/wp-content/uploads/2011/10/Hermosos-vestidos-de-fiesta-1.jpg"),
("http://mlm-s2-p.mlstatic.com/vestido-casual-juvenil-coqueto-moda-japonesa-12057-MLM20054393314_022014-O.jpg"),
("http://www.masdemoda.com/wp-content/uploads/2013/08/moda-mujer-pimkie-2.jpg"),
("http://www.famosetes.com/wp-content/uploads/2013/10/b5fe7__moda-2013-2014-5.jpg"),
("http://vestidosdenoviaoriginales.com/wp-content/uploads/2013/07/vestidos-juveniles-de-fiesta1.jpg"),
("http://2.bp.blogspot.com/-Ax9Jz08ZDzM/T_2FXwLI54I/AAAAAAAAAM4/NT-ym-Jckno/s1600/Vestidos-cortos-de-fiesta-de-moda-juvenil-2012-2.jpg");

drop procedure if exists setImages;
delimiter //
CREATE procedure setImages()
begin
  declare lenDesigns int;
  declare urlRandom varchar(140);
  declare cont int;
  set cont = 1;
  select count(idDiseño) from diseños into lenDesigns;
  while(cont <= lenDesigns) do
    select url from urls order by rand() limit 1 into urlRandom;
    INSERT into imagenes (idDiseño,url)
    values(cont, urlRandom);
    set cont = cont + 1;
  end while;
end //
delimiter ;
call setImages();

drop procedure setPremiumUsers;
delimiter //
create procedure setPremiumUsers()
begin
  declare cont int;
  declare idPlanPremium int;
  declare idRandomUser int;
  declare idRandomCharge int;
  declare idRandomType int;
  declare idRandomCoin int;
  SELECT idPlan FROM planes WHERE nombre = "Plan Premium" INTO idPlanPremium;
  set cont = 0;
  while (cont < 40) do
    SELECT idUsuario FROM usuarios ORDER by rand() limit 1 into idRandomUser;
    SELECT idTipoPago FROM tiposDePago ORDER BY rand() limit 1 into idRandomType;
    SELECT idTipoCobro FROM tiposDeCobro ORDER BY rand() limit 1 into idRandomCharge;
    SELECT idMoneda FROM monedas ORDER BY rand() limit 1 INTO idRandomCoin;
    INSERT INTO planesXUsuarios (idUsuario, idPlan, idTipoPago, idTipoCobro, idMoneda)
    values (idRandomUser, idPlanPremium, idRandomType, idRandomCharge, idRandomCoin);
    set cont = cont + 1;
  end while;
end //
delimiter ;
call setPremiumUsers();

drop procedure setDesignsArea;
delimiter //
create procedure setDesignsArea()
begin
  declare idRandomDesign int;
  declare idRandomArea int;
  declare designsLenght int;
  declare cont int;
  set cont = 0;
  SELECT count(*) FROM diseños into designsLenght;
  while (cont < designsLenght) do
    SELECT idArea FROM areas ORDER BY rand() limit 1 INTO idRandomArea;
    SELECT idDiseño FROM diseños
    where idDiseño NOT IN
    (
      select idDiseño FROM diseñosxAreas
    ) ORDER BY rand() limit 1 INTO idRandomDesign;
    insert into diseñosxAreas (idDiseño, idArea)
    values (idRandomDesign, idRandomArea);
    set cont = cont + 1;
  end while;
end //
delimiter ;
call setDesignsArea();

create table finalDesignsResults select idDiseño FROM diseños;
  