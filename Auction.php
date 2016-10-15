<?php
include("DBConnection.php");

function designImages($Images)
{
	for($i = 0; $i < sizeof($Images); $i++)
	{
		echo
		"<img src=".$Images[$i]."
		height = '300px'
		width = '300px'><br>";
	}
}

function designTypes($Types)
{
	for($i = 0; $i < sizeof($Types); $i++)
	{
		echo "<label>$Types[$i]</label><br>";
	}	
}

function designFeatures($Features)
{
	for($i = 0; $i < sizeof($Features); $i++)
	{
		echo "<label>$Features[$i]</label><br>";
	}
}

function createDesigns()
{
	$idDesign = $_POST["idDesign"];
	$result = mysql_query
	("
	SELECT dis.idDiseño, 
		   dis.titulo,
		   dis.descripcion,
		   date(dis.FechaDeCreacion) Fecha,
		   CONCAT(user.Nombre,' ',user.Apellido1,' ',user.Apellido2) Autor,
		   dis.PromedioPuntos,
		   dis.CantidadVisitas,
		   estado.nombre Estado,
		   pais.nombre Pais, 
		   Group_concat(DISTINCT car.nombre ORDER BY car.nombre SEPARATOR ',') Features, 
		   Group_concat(DISTINCT tipo.nombre ORDER BY tipo.nombre SEPARATOR ',') Types,
		   Group_concat(DISTINCT img.url SEPARATOR ',') Images
	FROM diseños dis
	INNER JOIN estadoDeDiseños estado ON dis.IdEstado = estado.IdEstado
	INNER JOIN imagenes img ON img.idDiseño = dis.idDiseño
	INNER JOIN diseñosXcaracteristicas DXC ON dis.idDiseño = DXC.idDiseño
	INNER JOIN caracteristicasDeDiseño car ON DXC.idCaracteristica = car.idCaracteristica
	INNER JOIN tiposDeDiseño tipo ON car.idTipo = tipo.idTipo
	INNER JOIN usuarios user ON dis.idUsuario = user.idUsuario
	INNER JOIN paises pais ON user.idPais = pais.idPais
	WHERE dis.idDiseño = $idDesign
	GROUP BY dis.idDiseño;");
	if (!$result) 
	{
		die('Invalid query: ' . mysql_error());
	}
	while($row = mysql_fetch_array($result)) 
	{
		newDesign($row["idDiseño"],$row["titulo"],$row["descripcion"],$row["Fecha"],$row["PromedioPuntos"],$row["CantidadVisitas"],$row["Estado"],$row["Pais"],explode(",",$row["Features"]),explode(",",$row["Types"]),explode(",",$row["Images"]),$row["Autor"]);
	}
}
function newDesign($idDiseño, $title, $description, $date, $rate, $visits, $state, $country, $Features, $Types, $Images, $Author)
{

	echo "
		<form action='AuctionDB' method='Post' id='design'>
			<div id='images'>";
				designImages($Images);
	echo
		"
			</div>    
		</form>
	<br><br><br>";
}
?>
<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<link rel="stylesheet" type="text/css" href="Auction.css">
</head>

<body>
	<center>
	<form action="AuctionDB.php" method="Post">
    	<h3>Select the initial day of the auction</h3><br>
		<input type="date" name="date1" min="<?php echo date('Y-m-d'); ?>" required/><br><br>
		<h3>Select the final day of the auction</h3><br>
		<input type="date" name="date2" min="<?php echo date('Y-m-d'); ?>" required/><br><br>
		<h3>Type the initial offer</h3><br>
		<label>$</label>
		<input type="text" name="money" pattern="\d*" required/><br><br>
        <input type="submit" value="Iniciate auction">
        <input type="hidden" name="id" value="<?php echo $_POST['idDesign']; ?>">
	</form>
    <br>
	<br>    
    <?php createDesigns(); ?>
</body>
</html>