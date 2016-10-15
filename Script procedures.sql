DROP TRIGGER IF EXISTS setPlanHistory;
DELIMITER //
CREATE TRIGGER setPlanHistory BEFORE UPDATE ON Planes
FOR EACH ROW
	INSERT INTO planHistorial(idPlan, nombre, descripcion, idPeriodicidad, cantidad, tiempoMinimo, tiempoMaximo, precio, fechaInicio, fechaFinal, userName, ComputerName, checksum)
	SELECT idPlan, nombre, descripcion, idPeriodicidad, cantidad, tiempoMinimo, tiempoMaximo, precioActual, FechaCreacion, NOW(), user(), ComputerName, SHA1(CONCAT(idPlan, nombre, descripcion, idPeriodicidad, cantidad, tiempoMinimo, tiempoMaximo, precioActual, FechaCreacion, NOW(), user(), ComputerName))
	FROM planes WHERE idPlan = old.idPlan;
//
DELIMITER ;

DROP FUNCTION IF EXISTS getInsertDataIdEvent;
DELIMITER //
CREATE FUNCTION getInsertDataIdEvent() RETURNS int
BEGIN
	DECLARE idTipoDeEvento int;
	SELECT idTipoEvento FROM TipoEventos WHERE nombre = "Ingreso de datos" INTO idTipoDeEvento;
	RETURN idTipoDeEvento;
END //
DELIMITER ;

DROP FUNCTION IF EXISTS getInsertPaymentIdEvent;
DELIMITER //
CREATE FUNCTION getInsertPaymentIdEvent() RETURNS int
BEGIN
	DECLARE idTipoDeEvento int;
	SELECT idTipoEvento FROM TipoEventos WHERE nombre = "Insertar pago" INTO idTipoDeEvento;
	RETURN idTipoDeEvento;
END //
DELIMITER ;

DROP TRIGGER IF EXISTS setUserBlog;
DELIMITER //
CREATE TRIGGER setUserBlog AFTER INSERT ON Usuarios
FOR EACH ROW
	INSERT INTO bitacoraEventos (idTipoEvento, descripcion, Fecha, userName, ComputerName, checksum)
	VALUES (getInsertDataIdEvent(), CONCAT("Nuevo ingreso de usuario, con id: ", getLastUserId()," a la base de datos Fashion"), NOW(), User(), getComputerName(), SHA1(CONCAT(getInsertDataIdEvent(),getLastUserId(),NOW(),User(),getComputerName())));
//
DELIMITER ;

DROP TRIGGER IF EXISTS setNotificationBlog;
DELIMITER //
CREATE TRIGGER setNotificationBlog AFTER INSERT ON Notificaciones
FOR EACH ROW
	INSERT INTO bitacoraEventos (idTipoEvento, descripcion, Fecha, userName, ComputerName, checksum)
	VALUES (getInsertDataIdEvent(), "Nuevo ingreso de notificacion a la base de datos", NOW(), User(),getComputerName(), SHA1(CONCAT(getInsertDataIdEvent(),NOW(),User(),getComputerName())));
//
DELIMITER ;

DROP TRIGGER IF EXISTS setPaymentBlog;
DELIMITER //
CREATE TRIGGER setPaymentBlog AFTER INSERT ON Pagos
FOR EACH ROW
	INSERT INTO bitacoraEventos (idTipoEvento, descripcion, Fecha, userName, ComputerName, checksum)
	VALUES (getInsertPaymentIdEvent(), CONCAT("Nuevo ingreso de pago con id: ", getLastPaymentId()), NOW(), User(),getComputerName(), SHA1(CONCAT(getInsertPaymentIdEvent(),getLastPaymentId(),NOW(),User(),getComputerName())));
//
DELIMITER ;

DROP TRIGGER IF EXISTS setDesignBlog;
DELIMITER //
CREATE TRIGGER setDesignBlog AFTER INSERT ON Diseños
FOR EACH ROW
	INSERT INTO bitacoraEventos (idTipoEvento, descripcion, Fecha, userName, ComputerName, checksum)
	VALUES (getInsertDataIdEvent(), CONCAT("Nuevo ingreso de diseño, con id: ", getLastDesignId()," a la base de datos Fashion"), NOW(), User(),getComputerName(), SHA1(CONCAT(getInsertDataIdEvent(),getLastDesignId(),NOW(),User(),getComputerName())));
//
DELIMITER ;

DROP FUNCTION IF EXISTS login;
DELIMITER //
CREATE FUNCTION login(pEmail varchar(50), pPassword varchar(50)) RETURNS int
BEGIN
	DECLARE actualUser int;
	SELECT idUsuario FROM usuarios WHERE email = pEmail AND password = SHA1(pPassword) INTO actualUser;
	RETURN actualUser;
END //
DELIMITER ;

DROP FUNCTION IF EXISTS getHighestoffer;
DELIMITER //
CREATE FUNCTION getHighestOffer(pIdSale int)RETURNS decimal(14,2)
BEGIN
	DECLARE highestAmmount decimal(14,2);
	SELECT MontoOfertado FROM ofertas WHERE idSubasta = pIdSale ORDER BY MontoOfertado DESC LIMIT 1 INTO highestAmmount;
	RETURN highestAmmount;
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


DROP FUNCTION IF EXISTS getRateProm;
DELIMITER //
CREATE FUNCTION getRateProm(pIdDesign) RETURNS float
BEGIN
	RETURN
	(
		SELECT sum(pun.valor)/count(pun.valor) FROM diseños dis
		INNER JOIN registroReseñas rew ON dis.idDiseño = rew.idDiseño 
		INNER JOIN catalogoPuntuaciones pun ON rew.idPuntuacion = pun.idPuntuacion
		WHERE dis.idDiseño = pIdDesign
		GROUP BY dis.idDiseño;
	)
END //
DELIMITER ;

DROP FUNCTION IF EXISTS getLastDesignId;
DELIMITER //
CREATE FUNCTION getLastDesignId() RETURNS int
BEGIN
  DECLARE lastIdDesign int;
  SELECT idDiseño FROM diseños ORDER BY idDiseño DESC LIMIT 1 INTO lastIdDesign;
  RETURN lastIdDesign;
END //
DELIMITER ;

DROP FUNCTION IF EXISTS getLastUserId;
DELIMITER //
CREATE FUNCTION getLastUserId() RETURNS int
BEGIN
  DECLARE lastIdUser int;
  SELECT idUsuario FROM usuarios ORDER BY idUsuario DESC LIMIT 1 INTO lastIdUser;
  RETURN lastIdUser;
END //
DELIMITER ;

DROP FUNCTION IF EXISTS getLastPaymentId;
DELIMITER //
CREATE FUNCTION getLastPaymentId() RETURNS int
BEGIN
	DECLARE lastPaymentId int;
	SELECT idPago FROM pagos ORDER BY idPago DESC LIMIT 1 INTO lastPaymentId;
	RETURN lastPaymentId;
END //
DELIMITER ;

DROP FUNCTION IF EXISTS split;
DELIMITER //
CREATE FUNCTION split(x VARCHAR(255),delim VARCHAR(12),pos INT)
RETURNS VARCHAR(255)
BEGIN
RETURN REPLACE(SUBSTRING(SUBSTRING_INDEX(x, delim, pos),
       LENGTH(SUBSTRING_INDEX(x, delim, pos -1)) + 1),
       delim, '');
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


DROP FUNCTION IF EXISTS stringLen;
DELIMITER //
CREATE FUNCTION stringLen(string varchar(5000), delim varchar(10))
RETURNS INT
BEGIN
	RETURN (length(string) - length(replace(string, delim, ""))) DIV LENGTH(delim);
END //
DELIMITER ;


DROP PROCEDURE IF EXISTS insertRole;
DELIMITER //
CREATE PROCEDURE insertRole(pIdUser int, pNombreRol varchar(30))
BEGIN
	DECLARE idRole int;
	SELECT idRol FROM roles WHERE nombre = pNombreRol INTO idRole; 
	INSERT INTO usuariosXRoles (idUsuario, idRol)
	VALUES (pIdUser, idRole);
END //
DELIMITER ;


DROP PROCEDURE IF EXISTS insertUserContact;
DELIMITER //
CREATE PROCEDURE insertUserContact(pIdUser int, pIdContactType int, pValue varchar(150))
BEGIN
	INSERT INTO contactos (idUsuario, idMedioContacto, valor)
	VALUES (pIdUser, pIdContactType, pValue);
END //
DELIMITER ;


DROP PROCEDURE IF EXISTS signUser;
DELIMITER //
CREATE PROCEDURE signUser(pName varchar(50), pFirstName varchar(50), pLastName varchar(50), pBirthday date, pPassword varbinary(500), pEmail varchar(50), pPais varchar(50), pRoles varchar(200))
BEGIN
	DECLARE idUserPais int;
	DECLARE idPlanDefault int;

	DECLARE rolesLenght int;
	DECLARE contactsLenght int;

	DECLARE contRole int;

	set rolesLenght = stringLen(pRoles,",");

	set contRole = 1;

	SELECT idPais FROM paises WHERE nombre = pPais INTO idUserPais;
	SELECT idPlan FROM planes WHERE nombre = "Plan Default" INTO idPlanDefault;

	INSERT INTO usuarios (nombre, apellido1, apellido2, fechaNacimiento, password, email, fechaIngreso, idPais, token)
	VALUES (pName, pFirstName, pLastName, pBirthday, sha1(pPassword), pEmail, NOW(), idUserPais, SHA1(CONCAT(pName, pFirstName, pLastName, pBirthday, pPassword, pEmail, NOW(), pPais)));

	WHILE (contRole <= rolesLenght) DO
		call insertRole(getLastUserId(), split(pRoles,",",contRole));
		set contRole = contRole + 1; 
	END WHILE;

	INSERT INTO planesXUsuarios (idPlan, idUsuario, idTipoCobro, idTipoPago, FechaCreacion)
	VALUES (idPlanDefault, getLastUserId(), 1, 1, NOW());

END //
DELIMITER ;

DROP PROCEDURE IF EXISTS featureFilterDesigns;
DELIMITER //
CREATE PROCEDURE featureFilterDesigns(pFilterFeature varchar(100))
BEGIN
	IF (pFilterFeature != "") THEN
		CREATE TEMPORARY TABLE designTemp
		SELECT * FROM designsResults WHERE idDiseño IN
		(
			SELECT dis.idDiseño FROM diseños dis
			INNER JOIN diseñosXcaracteristicas DXC ON dis.idDiseño = DXC.idDiseño
			INNER JOIN caracteristicasDeDiseño car ON DXC.idCaracteristica = car.idCaracteristica
			INNER JOIN tiposDeDiseño tipo ON car.idTipo = tipo.idTipo
			Group by dis.idDiseño
			Having (Group_concat(DISTINCT car.nombre) LIKE Concat("%",pFilterFeature,"%"))
			order by dis.idDiseño
		);
		DROP TEMPORARY TABLE designsResults;
		CREATE TEMPORARY TABLE designsResults SELECT * FROM designTemp;
		DROP TEMPORARY TABLE designTemp;
	END IF;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS typeFilterDesigns;
DELIMITER //
CREATE PROCEDURE typeFilterDesigns(pFilterType varchar(100))
BEGIN
	IF (pFilterType != "") THEN
		CREATE TEMPORARY TABLE designTemp
		SELECT * FROM designsResults WHERE idDiseño IN
		(
			SELECT dis.idDiseño FROM diseños dis
			INNER JOIN diseñosXcaracteristicas DXC ON dis.idDiseño = DXC.idDiseño
			INNER JOIN caracteristicasDeDiseño car ON DXC.idCaracteristica = car.idCaracteristica
			INNER JOIN tiposDeDiseño tipo ON car.idTipo = tipo.idTipo
			Group by dis.idDiseño
			Having (Group_concat(DISTINCT tipo.nombre) LIKE Concat("%",pFilterType,"%"))
			order by dis.idDiseño
		);
		DROP TEMPORARY TABLE designsResults;
		CREATE TEMPORARY TABLE designsResults SELECT * FROM designTemp;
		DROP TEMPORARY TABLE designTemp;
	END IF;
END //
DELIMITER ;


DROP PROCEDURE IF EXISTS dateFilterDesign;
DELIMITER //
CREATE PROCEDURE dateFilterDesign(pDateRangeA date, pDateRangeB date) 
BEGIN
	IF (pDateRangeA <> "1000-1-1" AND pDateRangeB <> "9999-12-31") THEN
		CREATE TEMPORARY TABLE designTemp
		SELECT * FROM designsResults WHERE idDiseño IN
		(
			SELECT idDiseño FROM diseños
			WHERE (FechaDeCreacion BETWEEN pDateRangeA AND pDateRangeB)
		);
		DROP TEMPORARY TABLE designsResults;
		CREATE TEMPORARY TABLE designsResults SELECT * FROM designTemp;
		DROP TEMPORARY TABLE designTemp;
	END IF;
END //
DELIMITER ;


DROP PROCEDURE IF EXISTS rateFilterDesign;
DELIMITER //
CREATE PROCEDURE rateFilterDesign(pRate int) 
BEGIN
	IF (pRate <> 0) THEN
		CREATE TEMPORARY TABLE designTemp
		SELECT * FROM designsResults WHERE idDiseño IN
		(
			SELECT idDiseño FROM diseños
			WHERE (PromedioPuntos DIV 1 = pRate)
		);
		DROP TEMPORARY TABLE designsResults;
		CREATE TEMPORARY TABLE designsResults SELECT * FROM designTemp;
		DROP TEMPORARY TABLE designTemp;
	END IF;
END //
DELIMITER ;


DROP PROCEDURE IF EXISTS countryFilterDesign;
DELIMITER //
CREATE PROCEDURE countryFilterDesign(pCountry varchar(30)) 
BEGIN
	IF (pCountry <> "") THEN
		CREATE TEMPORARY TABLE designTemp
		SELECT * FROM designsResults WHERE idDiseño IN
		(
			SELECT dis.idDiseño FROM diseños dis
			INNER JOIN usuarios user ON dis.idUsuario = user.idUsuario
			INNER JOIN paises pais ON user.idPais = pais.idPais
			WHERE (pais.nombre = pCountry)
		);
		DROP TEMPORARY TABLE designsResults;
		CREATE TEMPORARY TABLE designsResults SELECT * FROM designTemp;
		DROP TEMPORARY TABLE designTemp;
	END IF;
END //
DELIMITER ;


DROP PROCEDURE IF EXISTS searchDesigns;
DELIMITER //
CREATE PROCEDURE searchDesigns(pListFeactures varchar(1000), pListTypes varchar(1000), pDateRangeA date, pDateRangeB date, pCountry varchar(50), pRate int)
BEGIN
	DECLARE lenFeactures int;
	DECLARE lenTypes int;
	DECLARE cont int;
	
	set cont = 1;
	set lenFeactures = stringLen(pListFeactures,",");
	set lenTypes = stringLen(pListTypes,",");
	
	DROP TEMPORARY TABLE IF EXISTS designsResults;
	DROP TEMPORARY TABLE IF EXISTS designTemp;
	CREATE TEMPORARY TABLE IF NOT EXISTS designsResults SELECT idDiseño FROM diseños;
	
	WHILE (cont <= lenFeactures) DO
		call featureFilterDesigns(split(pListFeactures,",",cont));
		set cont = cont + 1;
	END WHILE;
	
	set cont = 1;
	
	WHILE (cont <= lenTypes) DO
		call typeFilterDesigns(split(pListTypes,",",cont));
		set cont = cont + 1;
	END WHILE;

	CALL dateFilterDesign(pDateRangeA, pDateRangeB);
	CALL rateFilterDesign(pRate);
	CALL countryFilterDesign(pCountry);
	
	SELECT dis.idDiseño, 
		   dis.titulo,
		   dis.descripcion,
		   dis.FechaDeCreacion,
		   dis.PromedioPuntos,
		   dis.CantidadVisitas,
		   dis.esta
		   pais.nombre, 
		   Group_concat(DISTINCT car.nombre ORDER BY car.nombre SEPARATOR ",") Features, 
		   Group_concat(DISTINCT tipo.nombre ORDER BY tipo.nombre SEPARATOR ",") Types 
	FROM diseños dis
	INNER JOIN designsResults des ON des.idDiseño = dis.idDiseño
	INNER JOIN diseñosXcaracteristicas DXC ON dis.idDiseño = DXC.idDiseño
	INNER JOIN caracteristicasDeDiseño car ON DXC.idCaracteristica = car.idCaracteristica
	INNER JOIN tiposDeDiseño tipo ON car.idTipo = tipo.idTipo
	INNER JOIN usuarios user ON dis.idUsuario = user.idUsuario
	INNER JOIN paises pais ON user.idPais = pais.idPais
	GROUP BY dis.idDiseño
	ORDER BY dis.idDiseño;
END //
DELIMITER ;


DROP PROCEDURE IF EXISTS newNotificationFinalOffer;
DELIMITER //
CREATE PROCEDURE newNotificationFinalOffer(pIdOriginUser int, pIdDestinyUser int, pIdDesign int)
BEGIN
	DECLARE idNotRead int;
	DECLARE idTipoDeEvento int;
	DECLARE authorName varchar(50);
	DECLARE authorFirstName varchar(50);
	DECLARE authorLastName varchar(50);
	DECLARE authorEmail varchar(50);
	DECLARE designName varchar(50);

	SELECT nombre, apellido1, apellido2, email FROM usuarios WHERE idUsuario = idDestinyUser INTO authorName, authorFirstName, authorLastName, authorEmail;
	SELECT idEstado FROM EstadoNotificaciones WHERE nombre = "No leido" INTO idNotRead;
	SELECT titulo FROM diseños WHERE idDiseño = idDesign INTO designName;

	INSERT INTO Notificaciones (idUsuarioOrigen, idUsuarioDestino, idDiseño, idEstado, descripcion, fecha)
	VALUES (idDestinyUser, idOriginUser, idDesign, idNotRead, CONCAT("Tu oferta a ganado la subasta del diseño: ", designName, " del autor: ", authorName ," ", authorFirstName, " ", authorLastName), NOW());

END //
DELIMITER ;

DROP PROCEDURE IF EXISTS newNotificationPlan;
DELIMITER //
CREATE PROCEDURE newNotificationPlan(pIdUser, pIdPlan)
BEGIN
	DECLARE idNotRead int;
	DECLARE planName varchar(50);

	SELECT nombre FROM planes WHERE idPlan = pIdPlan INTO planName;
	SELECT idEstado FROM EstadoNotificaciones WHERE nombre = "No leido" INTO idNotRead;
	
	INSERT INTO Notificaciones (idUsuarioOrigen, idUsuarioDestino, idDiseño, idEstado, descripcion, fecha)
	VALUES (pIdUser, pIdUser, idDesign, idNotRead, CONCAT("Has alcanzado el tiempo minimo requerido para que el plan ", planName, "sea finalizado"), NOW());

END //
DELIMITER ;

DROP PROCEDURE IF EXISTS newNotificationOffer;
DELIMITER //
CREATE PROCEDURE newNotificationOffer(pIdOriginUser int, pIdDestinyUser int, pIdDesign int)
BEGIN
	DECLARE idNotRead int;
	DECLARE buyerName varchar(50);
	DECLARE buyerFirstName varchar(50);
	DECLARE buyerLastName varchar(50);
	DECLARE buyerEmail varchar(50);
	DECLARE designName varchar(50);

	SELECT nombre, apellido1, apellido2, email FROM usuarios WHERE idUsuario = idOriginUser INTO buyerName, buyerFirstName, buyerLastName, buyerEmail;
	SELECT idEstado FROM EstadoNotificaciones WHERE nombre = "No leido" INTO idNotRead;
	SELECT titulo FROM diseños WHERE idDiseño = idDesign INTO designName;

	INSERT INTO Notificaciones (idUsuarioOrigen, idUsuarioDestino, idDiseño, idEstado, descripcion, fecha)
	VALUES (idDestinyUser, idOriginUser, idDesign, idNotRead, CONCAT("El comprador ", buyerName, " ", buyerFirstName, " ", buyerLastName," con el correo: ", buyerEmail, " a hecho una oferta a tu diseño: ", designName), NOW());

END //
DELIMITER ;


DROP PROCEDURE IF EXISTS newPayment;
DELIMITER //
CREATE PROCEDURE newPayment(pDescription varchar(50), pAmmount decimal(12,4), pOriginCoin varchar(50), pPaymentType varchar(50), pUser int)
BEGIN
	DECLARE idPaymentType int;
	DECLARE idOriginCoin int;
	DECLARE idDestinyCoin int;
	DECLARE idExchangeRate int;
	DECLARE ExchangeRate float;
	DECLARE coinSimbol varchar(5);	
	DECLARE description varchar(100);
	
	IF (pDescription LIKE "%subasta%") THEN
		SET description = "Pago por compra de subasta"; 
	ELSEIF (pDescription LIKE "%plan%") THEN
		SET description = "Pago de plan premium";
	END IF;

	SELECT idMoneda FROM monedas WHERE acronimo = pOriginCoin INTO idOriginCoin;
	SELECT idMoneda FROM monedas WHERE monedaDefault = 1 INTO idDestinyCoin;
	SELECT simbolo FROM monedas WHERE idMoneda = idOriginCoin INTO coinSimbol;
	SELECT idTasaCambio FROM tasasDeCambio WHERE idMonedaOrigen = idOriginCoin AND idMonedaDestino = idDestinyCoin AND Actual = 1 INTO idExchangeRate;
	SELECT ValorTasaCambio FROM tasasDeCambio WHERE idTasaCambio = idExchangeRate INTO ExchangeRate;
	SELECT idTipoPago FROM tiposDePago WHERE nombre = pPaymentType INTO idPaymentType;
	INSERT INTO pagos(descripcion, monto, fecha, idMoneda, idTipoPago, idUsuario, idTasaCambio, TasaCambio, UserName, ComputerName, checksum)
	VALUES(description, pAmmount, NOW(), idOriginCoin, idPaymentType, pUser, idExchangeRate, ExchangeRate, User(), "Farcem-PC", SHA1(CONCAT(pAmmount, NOW(), idOriginCoin, idPaymentType, pUser, idExchangeRate, ExchangeRate, User(), "Farcem-PC")));

END //
DELIMITER ;


DROP PROCEDURE IF EXISTS finalizePurchase;
DELIMITER //
CREATE PROCEDURE finalizePurchase(pIdOffer int, pOriginCoin varchar(50), pPaymentType varchar(50), pUser int)
BEGIN
	DECLARE finalSale int;
	DECLARE idOfferDesign int;
	DECLARE idFinalized int;
	DECLARE idNotAvailable int;
	DECLARE idAwarded int;
	DECLARE idAuthor int;
	DECLARE idBuyer int;
	DECLARE idSold int;
	DECLARE idSoldDesign int;
	DECLARE lastPaymentId int;
	DECLARE ammount decimal(14,2);

	SELECT idUsuario FROM ofertas WHERE idOferta = pIdOffer INTO idBuyer;
	SELECT idUsuario FROM diseños WHERE idDiseño = idOfferDesign INTO idAuthor;
	SELECT idDiseño FROM ofertas WHERE idOferta = pIdOffer INTO idOfferDesign;
	SELECT idSubasta FROM ofertas WHERE idOferta = pIdOffer INTO finalSale;
	SELECT MontoOfertado FROM ofertas WHERE idOferta = pIdOffer INTO ammount;
	SELECT idDiseño FROM ofertas WHERE idOferta = pIdOffer INTO idSoldDesign;
	SELECT idEstado FROM EstadoDeSubastas WHERE nombre = "Finalizada" INTO idFinalized;
	SELECT idEstado FROM EstadoDeSubastas WHERE nombre = "Adjudicada" INTO idAwarded;
	SELECT idEstado FROM EstadoDeSubastas WHERE nombre = "No Disponible" INTO idNotAvailable;
	SELECT idSold FROM EstadoDeDiseños WHERE nombre = "Vendido" INTO idSold;
	
	UPDATE subastas SET idEstado = idFinalized WHERE idSubasta = finalSale;
	UPDATE ofertas SET idEstado = idAwarded WHERE idOferta = pIdOffer;
	UPDATE ofertas SET OfertaFinal = 1 WHERE idOferta = pIdOffer;
	UPDATE ofertas SET idEstado = idNotAvailable WHERE idSubasta = finalSale AND OfertaFinal = 0;
	UPDATE diseños SET idEstado = idSold WHERE idDiseño = idSoldDesign;

	call newPayment("Subasta", ammount, pOriginCoin, pPaymentType, pUser);
	
	SELECT idPago FROM pagos ORDER BY idPago DESC LIMIT 1 INTO lastPaymentId;
	INSERT INTO pagoDeSubastas(idPago, idSubasta)
	VALUES(lastPaymentId, finalSale); 
	
	call newNotificationFinalOffer(idBuyer, idAuthor, idOfferDesign);
END //
DELIMITER ; 

DROP PROCEDURE IF EXISTS makeOffer;
DELIMITER //
CREATE PROCEDURE makeOffer(pIdUsuarioActual int, pAmmount decimal(14,2), pIdSale int)
BEGIN
	DECLARE saleDesign int;
	DECLARE idAvailable int;
	DECLARE buyerName varchar(50);
	DECLARE buyerFirstName varchar(50);
	DECLARE buyerLastName varchar(50);
	DECLARE buyerEmail varchar(50);
	DECLARE designName varchar(50);
	DECLARE idDesignAuthor int;
	DECLARE finalSaleDate date;
	DECLARE highestOffer decimal(14,2);

	SELECT FechaFinal FROM subastas WHERE idSubasta = pIdSale INTO finalSaleDate;
	set highestOffer = getHighestoffer(pIdSale);

	IF (NOW() <= finalSaleDate) AND (pAmmount > highestOffer) THEN
		SELECT idEstado FROM EstadoDeSubastas WHERE nombre = "Disponible" INTO idAvailable;
		SELECT idDiseño FROM subastas WHERE idSubasta = pIdSale INTO saleDesign;
		SELECT nombre, apellido1, apellido2, email FROM usuarios WHERE idUsuario = pIdUsuarioActual INTO buyerName, buyerFirstName, buyerLastName, buyerEmail;
		SELECT idUsuario, titulo FROM diseños WHERE idDiseño = saleDesign INTO idDesignAuthor, designName;

		INSERT INTO ofertas (idUsuario, idSubasta, idDiseño, idEstado, descripcion, MontoOfertado, FechaOferta, userName, ComputerName, checksum)
		VALUES (pIdUsuarioActual, pIdSale, saleDesign, idAvailable, CONCAT("El comprador ", buyerName, " ", buyerFirstName, " ", buyerLastName," con el correo: ", buyerEmail," a ofertado el diseño: ", designName), pAmmount, NOW(), User(),getComputerName(),SHA1(CONCAT(pIdUsuarioActual, pIdSale, saleDesign, idAvailable, buyerName, buyerFirstName, buyerLastName, designName, pAmmount, NOW(), User(),getComputerName())));

		call newNotificationOffer(pIdUsuarioActual, idDesignAuthor, saleDesign);
	END IF;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS setTopDesigns;
DELIMITER //
CREATE PROCEDURE setTopDesigns(pRate int)
BEGIN
	DROP TEMPORARY TABLE IF EXISTS topDesignsDates; 
	CREATE TEMPORARY TABLE topDesignsDates;
	SELECT * FROM diseños ORDER BY FechaDeCreacion DESC;

	DROP TEMPORARY TABLE IF EXISTS topDesignsVisits; 
	CREATE TEMPORARY TABLE topDesignsVisits;
	SELECT * FROM diseños ORDER BY CantidadVisitas DESC; 

	DROP TEMPORARY TABLE IF EXISTS topDesignsRates; 
	CREATE TEMPORARY TABLE topDesignsRates;
	SELECT * FROM diseños WHERE PromedioPuntos DIV 1 = pRate ORDER BY PromedioPuntos DESC; 

END //
DELIMITER ;

DROP PROCEDURE IF EXISTS showNotifications;
DELIMITER //
CREATE PROCEDURE showNotifications(pIdUsuarioActual int)
BEGIN
	DECLARE idNotRead int;

	SELECT idEstado FROM EstadoNotificaciones WHERE nombre = "No leido" INTO idNotRead;
	
	DROP TEMPORARY TABLE IF EXISTS notifications; 
	CREATE TEMPORARY TABLE notifications
	SELECT * FROM notifications WHERE idUsuarioDestino = pIdUsuarioActual AND idEstado = idNotRead; 
END //
DELIMITER ;


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


DROP PROCEDURE IF EXISTS setDesignTag;
DELIMITER //
CREATE PROCEDURE setDesignTag(pIdDesign int, pTag varchar(30))
BEGIN
	DECLARE idTag int;
	SELECT idTag FROM tags WHERE nombre = pTag INTO idTag;
	INSERT INTO TagsXDiseños(idTag, idDiseño)
	VALUES (idTag, pIdDesign);
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS setDesignImage;
DELIMITER //
CREATE PROCEDURE setDesignImage(pIdDesign int, pURL varchar(140))
BEGIN
	INSERT INTO Imagenes(idDiseño, URL)
	VALUES (pIdDesign, pURL);
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS setDesignFeature;
DELIMITER //
CREATE PROCEDURE setDesignFeature(pIdDesign int, pFeature varchar(30))
BEGIN
	DECLARE idFeature int;
	SELECT idCaracteristica FROM caracteristicasDeDiseño WHERE nombre = pFeature INTO idFeature;
	INSERT INTO diseñosXcaracteristicas(idCaracteristica, idDiseño)
	VALUES (idFeature, pIdDesign);
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS newDesign;
DELIMITER //
CREATE PROCEDURE newDesign(pIdAuthor int, pTitle varchar(40), pDescription varchar(320), pArea varchar(30), pImages(3000), pFeatures varchar(1000))
BEGIN
	DECLARE idStateNotOffer int;
	DECLARE idArea int;
	DECLARE idLastDesign int;
	
	DECLARE tagsLenght int;
	DECLARE imagesLenght int;
	DECLARE featuresLenght int;

	DECLARE contTags int;
	DECLARE contImages int;
	DECLARE contFeatures int;

	set contTags = 1;
	set contImages = 1;
	set contFeatures = 1;

	set tagsLenght = stringLen(pTags,",");
	set imagesLenght = stringLen(pImages,",");
	set featuresLenght = stringLen(pFeatures,",");

	SELECT idEstado FROM EstadoDeDiseños WHERE nombre = "Sin Subastar" INTO idStateNotOffer;
	SELECT idArea FROM areas WHERE nombre = pArea INTO idArea;

	INSERT INTO diseños(idUsuario, titulo, descripcion, idEstado)
	VALUES(pIdAuthor, pTitle, pDescription, idStateNotOffer);

	SELECT idDiseño FROM diseños ORDER BY idDiseño DESC LIMIT 1 INTO idLastDesign;

	WHILE (contTags <= tagsLenght) DO
		call setDesignTag(idLastDesign, split(pTags,",",contTags));
		set contTags = contTags + 1;
	END WHILE;

	WHILE (contImages <= imagesLenght) DO
		call setDesignImage(idLastDesign, split(pImages,",",contImages));
		set contImages = contImages + 1;
	END WHILE;

	WHILE (contFeatures <= featuresLenght) DO
		call setDesignFeature(idLastDesign, split(pFeatures,",",contFeatures));
		set contFeatures = contFeatures + 1;
	END WHILE;

	INSERT INTO DiseñosXAreas (idDiseño, idArea)
	VALUES (idLastDesign, idArea);

	UPDATE usuarios SET cantidadDiseños = cantidadDiseños + 1 WHERE idUsuario = pIdAuthor;

END //
DELIMITER ;

DROP PROCEDURE IF EXISTS newSale;
DELIMITER //
CREATE PROCEDURE newSale(pIdDesign int, pInitialDate date, pFinalDate date, pAmmount decimal(14,2))
BEGIN
	DECLARE idAvailable int;
	DECLARE idInSale int;

	SELECT idEstado FROM EstadoDeSubastas WHERE nombre = "Disponible" INTO idAvailable;
	SELECT idEstado FROM EstadoDeDiseños WHERE nombre = "En subasta" INTO idInSale;

	INSERT INTO subastas (idDiseño, idEstado, fechaInicial, fechaFinal, montoInicial, checksum)
	VALUES (pIdDesign, idAvailable, pInitialDate, pFinalDate, pAmmount, SHA1(CONCAT(pIdDesign, idAvailable, pInitialDate, pFinalDate, pAmmount)));

	UPDATE diseños SET idEstado	= idInSale WHERE idDiseño = pIdDesign;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS newReview;
DELIMITER //
CREATE PROCEDURE newReview(pIdActualUser int, pIdDesign int, pIdLogin, pTitle varchar(70), pDescription varchar(320), pRate int)
BEGIN
	DECLARE idRate int;
	SELECT idPuntuacion FROM catalogoPuntuaciones WHERE pRate = valor INTO idRate;
	
	INSERT INTO registroReseñas(idUsuario, idDiseño, idSesion, titulo, descripcion, idPuntuacion)
	VALUES(pIdActualUser, pIdDesign, UUID(), pTitle, pDescription, idRate)

	UPDATE diseños set PromedioPuntos = getRateProm(pIdDesign); 
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS getPlan;
DELIMITER //
CREATE PROCEDURE getPlan(pIdPlan varchar(40), pIdUser varchar(40), pPaymentType varchar(40), pPaymentCharge varchar(40), pPlanSelect bit)
BEGIN
	DECLARE idPaymentType int;
	DECLARE idPaymentCharge int;
	DECLARE minTime int;
	DECLARE maxTime int;
	DECLARE price decimal(14,2);

	SELECT idTipoCobro FROM TipoDeCobro WHERE nombre = pPaymentCharge INTO idPaymentCharge;
	SELECT idTipoPago FROM TipoDePago WHERE nombre = pPaymentType INTO idPaymentType;
	SELECT precioActual, tiempoMinimo, tiempoMaximo 
	FROM planes WHERE idPlan = pIdPlan INTO price, minTime, maxTime;
	IF (pPaymentCharge = "Automatico") THEN
		call newPayment("Plan", price, "CRC", pPaymentType, pIdUser);
		INSERT INTO pagoDePlanes(idPago, idPlan) VALUES(getLastPaymentId(), pIdPlan);	
	ELSEIF (pPaymentCharge = "Manual") THEN
		IF (pPlanSelect = 0) THEN
			call newPayment("Plan", price*minTime, "CRC", pPaymentType, pIdUser);
			INSERT INTO pagoDePlanes(idPago, idPlan) VALUES(getLastPaymentId(), pIdPlan);
		ELSE
			call newPayment("Plan", price*maxTime, "CRC", pPaymentType, pIdUser);
			INSERT INTO pagoDePlanes(idPago, idPlan) VALUES(getLastPaymentId(), pIdPlan);
		END IF;
	END IF;
	INSERT INTO PlanesXUsuarios(idPlan, idUsuario, idTipoCobro, idTipoPago)
	VALUES (pIdPlan, pIdUser, idPaymentCharge, idPaymentType);
END //
DELIMITER ;

call newPlan("Plan premium", "Este plan permite ver y publicar diseños premium a los usuarios", "Diario", 1, 2, 4, 2000, NULL, "Privado");


DROP FUNCTION IF EXISTS planPayment;
DELIMITER //
CREATE FUNCTION planPayment(pIdUser int, pInitialDate date, pMinDate date, pMaxDate date, pAmount int, pPeriodicity varchar(20), pIdplan int, pPrice decimal(14,2)) RETURNS bit
BEGIN
	DECLARE lastPaymentId int;
	WHILE (pInitialDate <= CURDATE()) DO
		CASE pPeriodicity
			WHEN "Diario" THEN set pInitialDate = ADDDATE(pInitialDate, interval pAmount Day);
			WHEN "Mensual" THEN set pInitialDate = ADDDATE(pInitialDate, interval pAmount Month);
			WHEN "Anual" THEN set pInitialDate = ADDDATE(pInitialDate, interval pAmount Year);	
		END CASE;
		IF (CURDATE() = pInitialDate) THEN
			call newPayment("plan", pPrice, "CRC", "Paypal", pIdUser);
			INSERT INTO pagoDePlanes(idPago, idPlan) VALUES(getLastPaymentId(), pIdPlan);
			IF (CURDATE() = pMinDate) THEN
				call newNotificationPlan(pIdUser, pIdPlan);
			END IF;
		END IF;
	END WHILE;
	RETURN 0;
END //
DELIMITER ;


DROP PROCEDURE IF EXISTS setAutomaticPayments;
DELIMITER //
CREATE PROCEDURE setAutomaticPayments()
BEGIN
	SELECT planPayment(PlanDate.user, PlanDate.initial, PlanDate.min, PlanDate.max, PlanDate.amount, PlanDate.nombre, PlanDate.idPlan, PlanDate.precio) FROM
	(
		SELECT user.idUsuario user, PXU.FechaCreacion initial, plan.cantidad amount, per.nombre nombre, plan.idPlan idPlan, plan.precioActual precio,
		case per.nombre
			WHEN "Diario" THEN ADDDATE(PXU.FechaCreacion, interval plan.Cantidad * plan.tiempoMinimo Day)
			WHEN "Mensual" THEN ADDDATE(PXU.FechaCreacion, interval plan.Cantidad * plan.tiempoMinimo Month)
			WHEN "Anual" THEN ADDDATE(PXU.FechaCreacion, interval plan.Cantidad * plan.tiempoMinimo Year)
		END AS min,
		case per.nombre
			WHEN "Diario" THEN ADDDATE(PXU.FechaCreacion, interval plan.Cantidad * plan.tiempoMaximo Day)
			WHEN "Mensual" THEN ADDDATE(PXU.FechaCreacion, interval plan.Cantidad * plan.tiempoMaximo Month)
			WHEN "Anual" THEN ADDDATE(PXU.FechaCreacion, interval plan.Cantidad * plan.tiempoMaximo Year)
		END AS max
		FROM PlanesXUsuarios PXU
		INNER JOIN planes plan ON PXU.idPlan = plan.idPlan
		INNER JOIN periodicidades per ON per.idPeriodicidad = plan.idPeriodicidad
		INNER JOIN usuarios user ON PXU.idUsuario = user.idUsuario
		INNER JOIN tiposDePago tipo ON tipo.idTipoPago = PXU.idTipoPago
		WHERE plan.precioActual > 0 AND tipo.nombre = "Automatico";
	) AS PlanDate;
END //
DELIMITER ;

DROP EVENT IF EXISTS automaticPayment;
SET GLOBAL event_scheduler = ON;
CREATE EVENT automaticPayment
    ON SCHEDULE EVERY 1 DAY STARTS NOW()
    COMMENT "Retrive premium automatic payment plans"
    DO
      call setAutomaticPayments();

SELECT
	CONCAT("Reviews from design with id: ", dis.idDiseño) "Reviews",
	CONCAT(user.nombre," ",user.apellido1," ",user.apellido2) Authors,
	pun.valor Rates,
	rew.titulo"Comment title",
	rew.descripcion Comment,
	DATE(rew.FechaCreacion)"Post date"
FROM registroReseñas rew
INNER JOIN diseños dis ON dis.idDiseño = rew.idDiseño
INNER JOIN catalogoPuntuaciones pun ON pun.idPuntuacion = rew.idPuntuacion
INNER JOIN usuarios user ON rew.idUsuario = user.idUsuario
ORDER BY dis.idDiseño;

DROP PROCEDURE IF EXISTS showDesignReview;
DELIMITER //
CREATE PROCEDURE showDesignReview(pIdDesign int)
BEGIN
	SELECT
		CONCAT(user.nombre," ",user.apellido1," ",user.apellido2) Authors,
		pun.valor Rates,
		rew.titulo"Comment title",
		rew.descripcion Comment,
		DATE(rew.FechaCreacion)"Post date"
	FROM registroReseñas rew
	INNER JOIN diseños dis ON dis.idDiseño = rew.idDiseño
	INNER JOIN catalogoPuntuaciones pun ON pun.idPuntuacion = rew.idPuntuacion
	INNER JOIN usuarios user ON rew.idUsuario = user.idUsuario
	WHERE dis.idDiseño = pIdDesign
	ORDER BY dis.idDiseño;
END //
DELIMITER ;
